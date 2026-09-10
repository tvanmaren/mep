#!/usr/bin/env python3
"""MEP integration curation — deterministic measure, validate, and execute.

Preview synthesis stays with the executor (agent). This script owns git mechanics:
product-LOC measurement, artifact validation, and publication-branch materialization.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import subprocess
import sys
from collections import deque
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


PRODUCT_EXCLUDE_GLOBS = (
    "wiki/**",
    "**/*.md",
    "**/*.test.js",
    "**/*.spec.js",
    "**/*smoke*",
    "**/fixtures/**",
)


def run_git(repo: Path, *args: str, check: bool = True) -> str:
    cmd = ["git", "-C", str(repo), *args]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if check and result.returncode != 0:
        raise RuntimeError(
            f"git {' '.join(args)} failed: {result.stderr.strip() or result.stdout.strip()}"
        )
    return result.stdout.strip()


def emit(payload: dict[str, Any]) -> None:
    print(json.dumps(payload, indent=2, sort_keys=True))


def fail(status: str, detail: str, **extra: Any) -> None:
    payload: dict[str, Any] = {"status": status, "detail": detail}
    payload.update(extra)
    emit(payload)
    sys.exit(1 if status not in ("ok", "dry_run") else 0)


def glob_match(path: str, pattern: str) -> bool:
    path = path.replace("\\", "/")
    pattern = pattern.replace("\\", "/")
    if pattern.endswith("/**"):
        prefix = pattern[:-3].rstrip("/")
        return path == prefix or path.startswith(prefix + "/")
    return fnmatch.fnmatch(path, pattern)


def matches_any(path: str, patterns: list[str]) -> bool:
    return any(glob_match(path, pattern) for pattern in patterns)


def is_product_path(path: str) -> bool:
    return not matches_any(path, PRODUCT_EXCLUDE_GLOBS)


def artifact_paths(repo: Path, prep_root: str, slug: str) -> tuple[Path, Path]:
    base = repo / prep_root / slug
    return base / "integration-curation.json", base / "integration-curation.md"


def rel_path(repo: Path, path: Path) -> str:
    try:
        return str(path.resolve().relative_to(repo.resolve()))
    except ValueError:
        return str(path)


def template_file() -> Path:
    return Path(__file__).resolve().parent.parent / "templates" / "integration-curation.json"


def branch_exists(repo: Path, branch: str) -> bool:
    result = subprocess.run(
        ["git", "-C", str(repo), "show-ref", "--verify", "--quiet", f"refs/heads/{branch}"],
        capture_output=True,
    )
    return result.returncode == 0


def porcelain_paths(line: str) -> list[str]:
    entry = line[3:].strip() if len(line) > 3 else line.strip()
    if " -> " in entry:
        return [part.strip() for part in entry.split(" -> ", 2)]
    return [entry]


def execute_tree_blockers(repo: Path, prep_root: str, slug: str) -> list[str]:
    dirty = run_git(repo, "status", "--porcelain", "-uall", check=False)
    if not dirty:
        return []
    json_path, md_path = artifact_paths(repo, prep_root, slug)
    prep_dir = repo / prep_root / slug
    allowed = {
        rel_path(repo, json_path),
        rel_path(repo, md_path),
        rel_path(repo, prep_dir / "merge-playbook.md"),
    }
    blockers: list[str] = []
    seen: set[str] = set()
    for line in dirty.splitlines():
        if not line.strip():
            continue
        for path in porcelain_paths(line):
            if path in seen or path in allowed:
                seen.add(path)
                continue
            seen.add(path)
            blockers.append(path)
    return blockers


def load_artifact(json_path: Path) -> dict[str, Any]:
    if not json_path.is_file():
        fail("not_found", "integration-curation.json missing", path=str(json_path))
    try:
        data = json.loads(json_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail("invalid", f"integration-curation.json parse error: {exc}", path=str(json_path))
    if not isinstance(data, dict):
        fail("invalid", "integration-curation.json must be an object", path=str(json_path))
    return data


def save_artifact(json_path: Path, data: dict[str, Any]) -> None:
    json_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def resolve_trunk(repo: Path, trunk: str, artifact: dict[str, Any]) -> str:
    return str(artifact.get("trunk") or trunk)


def resolve_lab_sha(repo: Path, artifact: dict[str, Any]) -> str:
    if artifact.get("sourceSha"):
        return str(artifact["sourceSha"])
    branch = artifact.get("sourceBranch")
    if branch:
        return run_git(repo, "rev-parse", str(branch))
    return run_git(repo, "rev-parse", "HEAD")


def changed_paths(repo: Path, base: str, tip: str) -> list[str]:
    out = run_git(repo, "diff", "--name-only", f"{base}...{tip}", check=False)
    if not out:
        out = run_git(repo, "diff", "--name-only", base, tip, check=False)
    return [line for line in out.splitlines() if line.strip()]


def numstat(repo: Path, base: str, tip: str) -> list[tuple[int, int, str]]:
    out = run_git(repo, "diff", "--numstat", f"{base}...{tip}", check=False)
    if not out:
        out = run_git(repo, "diff", "--numstat", base, tip, check=False)
    rows: list[tuple[int, int, str]] = []
    for line in out.splitlines():
        parts = line.split("\t")
        if len(parts) != 3:
            continue
        added, deleted, path = parts
        if added == "-" or deleted == "-":
            continue
        rows.append((int(added), int(deleted), path))
    return rows


def measure_paths(
    repo: Path, base: str, tip: str, patterns: list[str] | None = None
) -> dict[str, Any]:
    rows = numstat(repo, base, tip)
    product_added = 0
    total_added = 0
    matched: list[dict[str, Any]] = []
    for added, deleted, path in rows:
        total_added += added
        if patterns and not matches_any(path, patterns):
            continue
        entry = {"path": path, "added": added, "deleted": deleted, "product": is_product_path(path)}
        if entry["product"]:
            product_added += added
        if patterns is None or matches_any(path, patterns):
            matched.append(entry)
    return {
        "productLocAdded": product_added,
        "totalLocAdded": total_added,
        "files": matched,
    }


def topo_sort_courses(courses: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id = {str(c["id"]): c for c in courses}
    indeg = {cid: 0 for cid in by_id}
    graph: dict[str, list[str]] = {cid: [] for cid in by_id}
    for course in courses:
        cid = str(course["id"])
        for dep in course.get("dependsOn") or []:
            dep = str(dep)
            if dep not in by_id:
                fail("invalid", f"course {cid} depends on unknown course {dep}")
            graph[dep].append(cid)
            indeg[cid] += 1
    queue = deque(sorted(cid for cid, deg in indeg.items() if deg == 0))
    ordered: list[dict[str, Any]] = []
    while queue:
        cid = queue.popleft()
        ordered.append(by_id[cid])
        for nxt in sorted(graph[cid]):
            indeg[nxt] -= 1
            if indeg[nxt] == 0:
                queue.append(nxt)
    if len(ordered) != len(courses):
        fail("invalid", "course dependency graph has a cycle")
    return ordered


def branch_name(slug: str, course_id: str, title: str) -> str:
    safe = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:40]
    return f"integrate/{slug}/course-{course_id}-{safe}"


def schema_version(artifact: dict[str, Any]) -> int:
    version = artifact.get("schemaVersion", 1)
    if not isinstance(version, int):
        return 1
    return version


def validate_artifact(artifact: dict[str, Any], slug: str) -> list[str]:
    errors: list[str] = []
    if artifact.get("slug") and artifact.get("slug") != slug:
        errors.append(f"artifact slug {artifact.get('slug')!r} != requested {slug!r}")
    version = schema_version(artifact)
    if version >= 2:
        for key in ("requirements", "architecturalDecisions", "discoveries"):
            value = artifact.get(key)
            if not isinstance(value, list):
                errors.append(f"schemaVersion {version} requires {key} array")
        if not isinstance(artifact.get("reviewerLearningPath"), list):
            errors.append(f"schemaVersion {version} requires reviewerLearningPath array")
        if not isinstance(artifact.get("confidenceReport"), dict):
            errors.append(f"schemaVersion {version} requires confidenceReport object")
    courses = artifact.get("courses")
    if not isinstance(courses, list) or not courses:
        errors.append("courses must be a non-empty array")
        return errors
    ids: set[str] = set()
    for course in courses:
        if not isinstance(course, dict):
            errors.append("each course must be an object")
            continue
        cid = course.get("id")
        if not cid:
            errors.append("course missing id")
            continue
        cid = str(cid)
        if cid in ids:
            errors.append(f"duplicate course id {cid}")
        ids.add(cid)
        if not course.get("title"):
            errors.append(f"course {cid} missing title")
        if not course.get("paths"):
            errors.append(f"course {cid} missing paths")
        if not course.get("commitMessage"):
            errors.append(f"course {cid} missing commitMessage")
        if version >= 2:
            for key in ("whyNow", "whyNotMergedWithPrevious", "trunkStateAfterMerge"):
                if not course.get(key):
                    errors.append(f"course {cid} missing {key} (schemaVersion {version})")
        verdict = course.get("budgetVerdict")
        loc = course.get("productLocAdded")
        if isinstance(loc, int) and loc > 500 and verdict != "cannot-separate":
            errors.append(f"course {cid} productLocAdded {loc} > 500 without cannot-separate")
    return errors


def cmd_status(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    json_path, md_path = artifact_paths(repo, args.prep_root, args.slug)
    roadmap = repo / args.prep_root / args.slug / "04-iteration-roadmap.md"
    trunk = args.trunk
    payload: dict[str, Any] = {
        "status": "ok",
        "slug": args.slug,
        "trunk": trunk,
        "artifact": {
            "json": {"relative": rel_path(repo, json_path), "exists": json_path.is_file()},
            "markdown": {"relative": rel_path(repo, md_path), "exists": md_path.is_file()},
        },
        "roadmap": {"relative": rel_path(repo, roadmap), "exists": roadmap.is_file()},
        "vcs": {
            "branch": run_git(repo, "rev-parse", "--abbrev-ref", "HEAD", check=False) or None,
            "head": run_git(repo, "rev-parse", "HEAD", check=False) or None,
            "dirty": bool(run_git(repo, "status", "--porcelain", check=False)),
        },
    }
    if json_path.is_file():
        artifact = load_artifact(json_path)
        payload["curation"] = {
            "status": artifact.get("status"),
            "courseCount": len(artifact.get("courses") or []),
            "executed": bool((artifact.get("execute") or {}).get("courses")),
        }
        tip = resolve_lab_sha(repo, artifact)
        base = resolve_trunk(repo, trunk, artifact)
        payload["measure"] = measure_paths(repo, base, tip)
    emit(payload)


def cmd_measure(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    json_path, _ = artifact_paths(repo, args.prep_root, args.slug)
    artifact = load_artifact(json_path)
    base = resolve_trunk(repo, args.trunk, artifact)
    tip = resolve_lab_sha(repo, artifact)
    courses = artifact.get("courses") or []
    course_stats: list[dict[str, Any]] = []
    for course in courses:
        patterns = [str(p) for p in course.get("paths") or []]
        stats = measure_paths(repo, base, tip, patterns)
        stats["courseId"] = course.get("id")
        stats["title"] = course.get("title")
        course_stats.append(stats)
    emit(
        {
            "status": "ok",
            "slug": args.slug,
            "base": base,
            "tip": tip,
            "courses": course_stats,
            "total": measure_paths(repo, base, tip),
        }
    )


def cmd_validate(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    json_path, _ = artifact_paths(repo, args.prep_root, args.slug)
    artifact = load_artifact(json_path)
    errors = validate_artifact(artifact, args.slug)
    if errors:
        emit({"status": "invalid", "errors": errors, "path": str(json_path)})
        sys.exit(1)
    emit({"status": "ok", "path": str(json_path), "courseCount": len(artifact.get("courses") or [])})


@dataclass
class ExecutePlan:
    course_id: str
    title: str
    branch: str
    base_ref: str
    paths: list[str]
    files: list[str]
    commit_message: str


def path_exists_at_ref(repo: Path, ref: str, path: str) -> bool:
    result = subprocess.run(
        ["git", "-C", str(repo), "cat-file", "-e", f"{ref}:{path}"],
        capture_output=True,
    )
    return result.returncode == 0


def materialize_lab_files(repo: Path, lab_sha: str, files: list[str]) -> None:
    """Checkout tip versions; `git rm` paths deleted on the lab tip."""
    present = [path for path in files if path_exists_at_ref(repo, lab_sha, path)]
    deleted = [path for path in files if path not in present]
    if present:
        run_git(repo, "checkout", lab_sha, "--", *present)
    for path in deleted:
        run_git(repo, "rm", "-f", "--ignore-unmatch", "--", path)


def build_execute_plan(
    repo: Path, artifact: dict[str, Any], slug: str, trunk: str
) -> tuple[str, list[ExecutePlan]]:
    errors = validate_artifact(artifact, slug)
    if errors:
        fail("invalid", "artifact validation failed", errors=errors)
    if artifact.get("status") != "approved":
        fail("blocked", "artifact status must be approved before execute")
    lab_sha = resolve_lab_sha(repo, artifact)
    base_trunk = resolve_trunk(repo, trunk, artifact)
    courses = topo_sort_courses(list(artifact.get("courses") or []))
    branch_tips: dict[str, str] = {}
    plans: list[ExecutePlan] = []
    for course in courses:
        cid = str(course["id"])
        patterns = [str(p) for p in course.get("paths") or []]
        deps = [str(d) for d in course.get("dependsOn") or []]
        mergeability = course.get("mergeability") or ("stacked" if deps else "independent")
        if deps:
            base_ref = branch_tips[deps[-1]]
        elif mergeability == "stacked" and branch_tips:
            base_ref = next(reversed(branch_tips.values()))
        else:
            base_ref = base_trunk
        all_changed = changed_paths(repo, base_trunk, lab_sha)
        files = sorted(path for path in all_changed if matches_any(path, patterns))
        plans.append(
            ExecutePlan(
                course_id=cid,
                title=str(course.get("title") or cid),
                branch=branch_name(slug, cid, str(course.get("title") or cid)),
                base_ref=base_ref,
                paths=patterns,
                files=files,
                commit_message=str(course.get("commitMessage") or course.get("title") or cid),
            )
        )
        branch_tips[cid] = plans[-1].branch
    return lab_sha, plans


def cmd_execute(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    json_path, _ = artifact_paths(repo, args.prep_root, args.slug)
    artifact = load_artifact(json_path)
    lab_sha, plans = build_execute_plan(repo, artifact, args.slug, args.trunk)

    if args.dry_run or not args.confirm:
        emit(
            {
                "status": "dry_run",
                "slug": args.slug,
                "labSha": lab_sha,
                "confirmRequired": not args.confirm,
                "plans": [
                    {
                        "courseId": p.course_id,
                        "title": p.title,
                        "integrationBranch": p.branch,
                        "baseRef": p.base_ref,
                        "pathGlobs": p.paths,
                        "files": p.files,
                        "commitMessage": p.commit_message,
                    }
                    for p in plans
                ],
            }
        )
        return

    original_branch = run_git(repo, "rev-parse", "--abbrev-ref", "HEAD")
    original_head = run_git(repo, "rev-parse", "HEAD")
    blockers = execute_tree_blockers(repo, args.prep_root, args.slug)
    if blockers:
        fail(
            "blocked",
            "working tree dirty outside integration-curation artifacts — commit or stash before execute",
            blockers=blockers,
        )

    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    backup_ref = f"refs/backup/curate-{args.slug}-{ts}"
    run_git(repo, "update-ref", backup_ref, original_head)

    executed: list[dict[str, Any]] = []
    try:
        for plan in plans:
            if branch_exists(repo, plan.branch):
                fail("blocked", f"integration branch already exists: {plan.branch}")
            run_git(repo, "checkout", "-b", plan.branch, plan.base_ref)
            if plan.files:
                materialize_lab_files(repo, lab_sha, plan.files)
            else:
                fail("blocked", f"course {plan.course_id} matched no changed files")

            if not run_git(repo, "status", "--porcelain", check=False):
                fail("blocked", f"course {plan.course_id} produced no changes to commit")

            run_git(repo, "commit", "-m", plan.commit_message)
            commit_sha = run_git(repo, "rev-parse", "HEAD")
            executed.append(
                {
                    "courseId": plan.course_id,
                    "integrationBranch": plan.branch,
                    "baseRef": plan.base_ref,
                    "commits": [commit_sha],
                }
            )
    finally:
        run_git(repo, "checkout", original_branch, check=False)

    if not isinstance(artifact.get("execute"), dict):
        artifact["execute"] = {}
    artifact["execute"].update(
        {
            "executedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "backupRef": backup_ref,
            "labBranch": original_branch,
            "labSha": lab_sha,
            "courses": executed,
        }
    )
    artifact["status"] = "executed"
    save_artifact(json_path, artifact)

    emit(
        {
            "status": "ok",
            "slug": args.slug,
            "backupRef": backup_ref,
            "labBranch": original_branch,
            "labSha": lab_sha,
            "courses": executed,
            "artifactPath": str(json_path),
            "nextCommand": f"/mep stage {args.slug} preview",
        }
    )


def cmd_template(args: argparse.Namespace) -> None:
    repo = Path(args.repo_root).resolve()
    tpl = template_file()
    if not tpl.is_file():
        fail("missing", "integration-curation template missing", path=str(tpl))
    raw = tpl.read_text(encoding="utf-8").replace("<slug>", args.slug)
    payload = json.loads(raw)
    payload["slug"] = args.slug
    payload["trunk"] = args.trunk
    payload["status"] = "draft"
    payload["courses"] = []
    json_path, _ = artifact_paths(repo, args.prep_root, args.slug)
    if json_path.exists() and not args.force:
        fail("exists", "integration-curation.json already exists", path=rel_path(repo, json_path))
    json_path.parent.mkdir(parents=True, exist_ok=True)
    save_artifact(json_path, payload)
    emit({"status": "ok", "path": rel_path(repo, json_path), "template": payload})


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--prep-root", default="wiki/prep")
    parser.add_argument("--trunk", default="develop")
    parser.add_argument("slug")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("status", help="preflight + artifact presence + total measure")
    sub.add_parser("measure", help="product LOC per course path globs")
    sub.add_parser("validate", help="validate integration-curation.json")
    tpl = sub.add_parser("template", help="write empty integration-curation.json")
    tpl.add_argument("--force", action="store_true")

    exe = sub.add_parser("execute", help="materialize integration branches")
    exe.add_argument("--dry-run", action="store_true")
    exe.add_argument("--confirm", action="store_true")

    args = parser.parse_args()
    handlers = {
        "status": cmd_status,
        "measure": cmd_measure,
        "validate": cmd_validate,
        "execute": cmd_execute,
        "template": cmd_template,
    }
    handlers[args.command](args)
    return 0


if __name__ == "__main__":
    sys.exit(main())

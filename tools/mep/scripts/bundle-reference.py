#!/usr/bin/env python3
"""Bundle the MEP framework into a single markdown reference export.

Canonical portable content lives under tools/mep/. Cursor integration files
(commands, hooks, peer skills) are included as adapters. Regenerate after
framework moves:

    python3 tools/mep/scripts/bundle-reference.py
    python3 tools/mep/scripts/bundle-reference.py --out wiki/mise-en-place-complete-reference.md
"""

from __future__ import annotations

import argparse
import fnmatch
import re
import sys
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]  # repo root
DEFAULT_OUT = ROOT / "wiki/mise-en-place-complete-reference.md"

GLOBAL_EXCLUDE_GLOBS = (
    "**/test/tmp/**",
    "**/__pycache__/**",
    "**/*.zip",
    "**/.git/**",
)

GLOBAL_EXCLUDE_DIR_NAMES = {
    "test/tmp",
    "__pycache__",
}


@dataclass
class Section:
    title: str
    description: str
    roots: list[str] = field(default_factory=list)
    files: list[str] = field(default_factory=list)
    exclude_globs: tuple[str, ...] = ()


def repo_rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def should_exclude(rel: str, extra: tuple[str, ...] = ()) -> bool:
    parts = Path(rel).parts
    if any(part.startswith("test-") for part in parts if rel.startswith(".mep/")):
        return True
    if ".mep/" in rel and "/test-" in rel:
        return True
    for pattern in (*GLOBAL_EXCLUDE_GLOBS, *extra):
        if fnmatch.fnmatch(rel, pattern):
            return True
    return False


def lang_for(path: Path) -> str:
    ext = path.suffix.lstrip(".")
    return {
        "md": "markdown",
        "json": "json",
        "sh": "bash",
        "js": "javascript",
        "mdc": "markdown",
    }.get(ext, ext or "text")


def section_anchor(title: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")


def anchor_id(rel: str) -> str:
    return "file-" + re.sub(r"[^a-zA-Z0-9]+", "-", rel).strip("-")


def collect_under(root_rel: str, extra_exclude: tuple[str, ...] = ()) -> list[str]:
    base = ROOT / root_rel
    if not base.exists():
        return []
    out: list[str] = []
    if base.is_file():
        rel = repo_rel(base)
        return [] if should_exclude(rel, extra_exclude) else [rel]
    for path in sorted(base.rglob("*")):
        if not path.is_file():
            continue
        rel = repo_rel(path)
        if should_exclude(rel, extra_exclude):
            continue
        out.append(rel)
    return out


def collect_section(section: Section) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for rel in section.files:
        if rel not in seen and (ROOT / rel).is_file():
            seen.add(rel)
            ordered.append(rel)
    for root in section.roots:
        for rel in collect_under(root, section.exclude_globs):
            if rel not in seen:
                seen.add(rel)
                ordered.append(rel)
    return ordered


SECTIONS: list[Section] = [
    Section(
        "Repo runtime config",
        "Active `.mep/config` and repo-owned profiles (not bundled examples).",
        files=[
            ".mep/config",
        ],
        roots=[
            ".mep/profiles",
        ],
        exclude_globs=(".mep/profiles/test-*", ".mep/**/test-*"),
    ),
    Section(
        "Portable tool (`tools/mep/`)",
        "Canonical deterministic bundle — bin, lib, docs, templates, examples, adapters, tests.",
        roots=["tools/mep"],
        exclude_globs=("tools/mep/test/tmp/**",),
    ),
    Section(
        "Cursor commands",
        "Slash-command adapters; `/mep` delegates to `tools/mep/bin/mep` for routing.",
        files=[
            ".cursor/commands/mep.md",
            ".cursor/commands/prep.md",
            ".cursor/commands/prep-cleanup.md",
            ".cursor/commands/prep-stage.md",
            ".cursor/commands/prep-pr-description.md",
            ".cursor/commands/implement-plan.md",
            ".cursor/commands/pr-description.md",
        ],
    ),
    Section(
        "Cursor peer skills",
        "Orchestration skills not lifted into `tools/mep/docs`.",
        roots=[
            ".cursor/skills/tidy",
            ".cursor/skills/commit-prep",
            ".cursor/skills/staged-audit",
            ".cursor/skills/commit-msg",
        ],
    ),
    Section(
        "Cursor mise-en-place mirrors",
        "Live Cursor skill tree. Prefer `tools/mep/docs/` for portable copies; these remain until adapter cutover.",
        roots=[".cursor/skills/mise-en-place"],
        exclude_globs=(
            ".cursor/skills/mise-en-place/templates.zip",
        ),
    ),
    Section(
        "Cursor subagents",
        "Readonly scouts invoked by commit-prep (MEP-relevant only).",
        files=[".cursor/agents/staged-audit-scout.md"],
    ),
    Section(
        "Cursor hooks",
        "Shell guards wired via `.cursor/hooks.json`.",
        roots=[".cursor/hooks"],
    ),
]


RELATED_COMMANDS = """| Command | Path | When MEP uses it |
|---------|------|------------------|
| `/create-plan` | `.cursor/commands/create-plan.md` | Late consolidation → master plan |
| `/update-plan` | `.cursor/commands/update-plan.md` | Plan amendment after checkpoint |
| `/improve-plan` | `.cursor/commands/improve-plan.md` | Plan refinement |
| `/assess-plan` | `.cursor/commands/assess-plan.md` | Pre-implement plan review |
| `/execute-plan` | `.cursor/skills/execute-plan/SKILL.md` | Slice brief `fanout: parallel` |
| `/architect` | `.cursor/skills/architect/SKILL.md` | Foundation-strategy fork; AD docs |
| `/feature-flag` | `.cursor/skills/feature-flag/SKILL.md` | Rollout gating (profile house pattern) |"""


ARCHITECTURE = """```
Operator surface              Deterministic tool              Adapters / orchestration
─────────────────             ───────────────────             ─────────────────────────
/mep next|where|…      ──►    tools/mep/bin/mep               .cursor/commands/mep.md
                              ├─ status --compact --json      .cursor/skills/{tidy,commit-prep,…}
                              ├─ where --json  (+ resolver_routed events)
                              ├─ profile dump --json
                              ├─ events tail --json           (observability; not routing input)
                              ├─ finish scan / lifecycle status
                              ├─ checkpoint --json [--fix]  (step 0 inside /prep checkpoint)
                              └─ doctor / check / pr scaffold

/prep checkpoint = atomic session: sync → replan → next brief → docs-delta

State: .mep/config + roadmap/iteration frontmatter + git + structured profile seed (.mep/profiles/<name>.json)
History: append-only .mep/history/events.jsonl (runtime observability, not route input)
Routing: lib/resolver.sh (glossary = human-readable contract)
Profiles: lib/profile.sh + docs/profile-capabilities.md
Lifecycle: lib/lifecycle.sh | Events: lib/events.sh
```

```mermaid
flowchart LR
  subgraph operator
    MEP["/mep verbs"]
  end
  subgraph tool
    BIN["tools/mep/bin/mep"]
    LIB["tools/mep/lib/*"]
  end
  subgraph adapters
    CMD[".cursor/commands"]
    SK[".cursor/skills"]
    HK[".cursor/hooks"]
  end
  subgraph state
    CFG[".mep/config"]
    ROADMAP["04-iteration-roadmap.md<br/>frontmatter"]
    ITERATION["iterations/*.md<br/>frontmatter"]
    GIT["git"]
  end
  MEP --> BIN
  BIN --> LIB
  CFG --> BIN
  ROADMAP --> BIN
  ITERATION --> BIN
  GIT --> BIN
  MEP --> CMD
  CMD --> SK
  BIN -.-> CMD
```"""


def build_toc(sections: list[tuple[Section, list[str]]]) -> list[str]:
    lines = ["## Table of contents", ""]
    for section, files in sections:
        anchor = section_anchor(section.title)
        lines.append(f"- [{section.title}](#{anchor}) — {section.description}")
        for rel in files:
            lines.append(f"  - [`{rel}`](#{anchor_id(rel)})")
    lines.append("- [Related commands (paths only)](#related-commands-paths-only)")
    lines.append("- [Runtime artifacts](#runtime-artifacts)")
    return lines


def render_file(rel: str) -> list[str]:
    path = ROOT / rel
    lines = [f"### `{rel}` {{#{anchor_id(rel)}}}", ""]
    if not path.is_file():
        lines.append("*File not found at generation time.*")
        lines.append("")
        return lines
    try:
        content = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        lines.append(f"*Binary or non-UTF-8 file skipped ({path.stat().st_size} bytes).*")
        lines.append("")
        return lines
    lines.extend([f"```{lang_for(path)}", content.rstrip("\n"), "```", ""])
    return lines


def generate(out: Path) -> int:
    resolved: list[tuple[Section, list[str]]] = []
    total_files = 0
    for section in SECTIONS:
        files = collect_section(section)
        if section.title == "Repo runtime config":
            files = [f for f in files if not should_exclude(f, (".mep/**/test-*",))]
        resolved.append((section, files))
        total_files += len(files)

    lines: list[str] = [
        "# mise-en-place — complete reference",
        "",
        f"> Auto-generated by `tools/mep/scripts/bundle-reference.py`.",
        f"> Generated: {date.today().isoformat()}",
        "",
        "Single-file export of the portable MEP tool (`tools/mep/`) plus Cursor adapters.",
        "Regenerate after framework moves:",
        "",
        "```bash",
        "python3 tools/mep/scripts/bundle-reference.py",
        "```",
        "",
        "**Canonical vs mirror:** docs/templates under `tools/mep/` are the portable home;",
        "matching paths under `.cursor/skills/mise-en-place/` remain live Cursor mirrors until cutover.",
        "",
        "---",
        "",
        *build_toc(resolved),
        "",
        "---",
        "",
        "## Architecture at a glance",
        "",
        ARCHITECTURE,
        "",
        "### Authorship modes",
        "",
        "| Mode | Status command | Actor policy | Policy doc |",
        "|------|----------------|--------------|------------|",
        "| `manual` | `mep lifecycle status <slug> --mode manual --json` | human implements; human authors/ratifies finishes | `tools/mep/docs/execution-policies/manual.md` |",
        "| `default` | `mep lifecycle status <slug> --mode default --json` | agent may implement/propose; human owns approval | same lifecycle substrate |",
        "| `autopilot` | `mep lifecycle status <slug> --mode autopilot --json` | parent agent implements; proxy authors/ratifies finishes | `tools/mep/docs/execution-policies/autopilot.md` |",
        "",
        "Set via `/mep mode <slug> <mode>`. Marker scan: `mep finish scan <slug> --json`.",
        "",
        "### Checkpoint session (atomic)",
        "",
        "`/prep <slug> checkpoint` is **one session per slice boundary**: step 0 runs `mep checkpoint",
        "<slug> --json` (and `--fix` only when unblocked) **inside** the prep session; then replan and",
        "draft the next brief; then docs-delta if the prep tree changed. Do not treat checkpoint sync",
        "as a standalone `/mep next` step before the prep session.",
        "",
        "### Review presentation",
        "",
        "`/mep stage <slug> [mode]` is the normal review-prep surface. It owns committed-work discovery,",
        "promised-work checks, PR scaffold/body readiness, stack preview, and gated local/remote effects.",
        "`mep pr scaffold`, `/prep-pr-description`, and `/prep-stage` are internals or escape hatches.",
        "",
        "### `mep` CLI surface",
        "",
        "```text",
        "mep config dump --json",
        "mep profile dump --json",
        "mep paths <slug> --json",
        "mep status <slug> --compact --json",
        "mep where <slug> --json",
        "mep events tail --json [--slug <slug>] [--event <name>] [--limit <n>]",
        "mep finish scan <slug> --json",
        "mep checkpoint <slug> --json [--fix]",
        "mep lifecycle status <slug> --mode <manual|default|autopilot> --json",
        "mep doctor <slug> --json [--fix] [--trunk <ref>]",
        "mep check scaffolding [--broad|--product-code] [paths...]",
        "mep check prep-active --json",
        "mep pr scaffold <slug> <n> --json",
        "```",
        "",
        "See `tools/mep/docs/event-ledger.md` and `tools/mep/docs/profile-capabilities.md` for",
        "observability and structured profile contracts.",
        "",
        "### Directory tree (source layout)",
        "",
        "```",
        ".mep/config                       # storage roots, adapter, profile binding",
        ".mep/profiles/                    # repo profile seed (<name>.json) + prose (<name>.md)",
        ".mep/history/events.jsonl         # append-only runtime event ledger (local, gitignored)",
        "tools/mep/",
        "├── bin/mep                       # deterministic CLI",
        "├── lib/                          # resolver, profile, events, lifecycle, …",
        "├── docs/                         # portable skill docs (incl. event-ledger, profile-capabilities)",
        "├── templates/                    # prep artifact templates",
        "├── examples/profiles/            # bundled profile examples",
        "├── adapters/cursor/              # Cursor adapter contract notes",
        "├── test/run-unix-contract.sh     # gate tests",
        "└── scripts/bundle-reference.py   # this export",
        ".cursor/",
        "├── commands/                     # slash-command adapters",
        "├── skills/mise-en-place/         # live Cursor mirrors (cutover pending)",
        "├── skills/{tidy,commit-prep,…}/",
        "├── agents/staged-audit-scout.md",
        "└── hooks/                        # prep-active + archaeology gates",
        "wiki/prep/<slug>/                 # per-initiative runtime artifacts",
        "```",
        "",
        "---",
        "",
    ]

    for section, files in resolved:
        sec_anchor = section_anchor(section.title)
        lines.extend([f"## {section.title} {{#{sec_anchor}}}", "", section.description, ""])
        if not files:
            lines.extend(["*No files matched this section.*", ""])
            continue
        for rel in files:
            lines.extend(render_file(rel))

    lines.extend(
        [
            "## Related commands (paths only)",
            "",
            "Referenced at graduation, consolidation, or parallel fanout — not inlined.",
            "",
            RELATED_COMMANDS,
            "",
            "## Runtime artifacts",
            "",
            "Per-initiative outputs (slug-specific; not part of the framework bundle):",
            "",
            "```",
            "wiki/prep/<slug>/0*.md                  # roadmap frontmatter owns initiative state",
            "wiki/prep/<slug>/iterations/*.md        # iteration frontmatter owns slice state",
            "wiki/prep/<slug>/06-graduation.md",
            "wiki/plans/<slug>.md",
            "wiki/pr-descriptions/<slug>-*.md",
            ".mep/history/events.jsonl            # runtime observability (local, gitignored)",
            ".cursor/prep-active                  # blocks git during forward prep (cursor adapter)",
            "```",
            "",
            "---",
            "",
            f"*End of reference — {total_files} files inlined.*",
            "",
        ]
    )

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size:,} bytes, {total_files} files)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"output markdown path (default: {DEFAULT_OUT.relative_to(ROOT)})",
    )
    args = parser.parse_args()
    out = args.out if args.out.is_absolute() else ROOT / args.out
    return generate(out)


if __name__ == "__main__":
    sys.exit(main())

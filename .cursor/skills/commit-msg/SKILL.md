---
name: commit-msg
description: >-
  Generate a semantic one-liner commit message with trailing gitmoji for staged
  changes. Output only, does not commit. Use when the user says "/commit-msg",
  "commit message", or "what should I call this commit".
---

# Commit Message Generator

Generate a semantic one-liner commit message with a trailing gitmoji for staged changes. Output only — do not commit.

## Procedure

1. Run `git diff --cached --stat` and `git diff --stat` in parallel.
2. If there are unstaged changes, prompt the user: list the unstaged files and ask whether they should be staged before generating the message. Wait for a response before continuing.
3. Run `git diff --cached` and `git log --oneline -10` to understand the staged changes and match repo style.
4. Compose the message following the format below.
5. Output the message for the user to copy. Do not run `git commit`.

### staged-only mode

When invoked by `/commit-prep` (or the user says `staged only`), **skip step 2** — the
caller has already curated the index, so do not prompt about unstaged files. Steps 1, 3, 4,
5 are unchanged. Default standalone mode keeps step 2.

## Format

```
<type>(<scope>): <imperative summary> <gitmoji>
```

| Field | Rules |
|-------|-------|
| **type** | `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `style` |
| **scope** | lowercase domain area (e.g. `auth`, `auth`, `permissions`). omit if change spans many domains. |
| **summary** | imperative mood, lowercase, no period, max ~72 chars total. focus on *why* over *what* when possible. |
| **gitmoji** | single emoji at the end, space-separated. pick from the table below. |

## Gitmoji Reference

| Emoji | Meaning |
|-------|---------|
| ✨ | new feature |
| 🐛 | bug fix |
| ♻️ | refactor |
| 🔥 | remove dead code |
| 📝 | docs |
| ✅ | add/update tests |
| ⚡ | performance |
| 🔀 | merge |
| 🔖 | release/version tag |
| 🏗️ | architectural change |
| 💄 | UI/style |
| 🔧 | config/tooling |
| 🚚 | move/rename |
| 🗃️ | migration/schema |
| 🚩 | feature flag |
| 🧑‍💻 | developer experience / DX tooling |

Pick the single best match. When in doubt, prefer the more specific emoji.

## Examples

```
feat(refinery): add spot lock settlement workflow ✨
fix(refinery): persist backend-validated interest fee on settlement approval 🐛
refactor(refinery): centralize cash advance interest calculation on backend ♻️
chore(refinery): cleanup ♻️
docs(release): v1.92.0 release notes 📝
test(refinery): add coverage for settlement fee validation ✅
```

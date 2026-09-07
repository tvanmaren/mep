---
description: "prep (mise en place) entry point — iterative slice prep, checkpoints, slice briefs; delegates to the mise-en-place skill"
alwaysApply: false
---

# prep — mise en place entry point

`/prep` is the registered command handle for the **mise-en-place** framework skill.

Cursor registers skills by their **directory name**; the skill is named `prep` in frontmatter but
lives in `.cursor/skills/mise-en-place/`, so `/prep` does not resolve without this thin command.

**Follow `.cursor/skills/mise-en-place/SKILL.md` in full**, treating everything after `/prep` as the
skill invocation — e.g. `/prep <slug> checkpoint`, `/prep <slug> <idea>`, `/prep <slug> docs-only`.
All hard rules, phases, session modes, and gates in that skill are binding.

Do **not** duplicate the skill's logic here — that file is the single source of truth; this command
is only the resolvable handle.

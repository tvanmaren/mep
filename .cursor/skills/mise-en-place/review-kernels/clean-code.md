# Clean Code Review Kernel

This is the portable clean-code review kernel. It contains principles and checks that should survive
moving the review workflow to another repository. Repo-specific examples, file paths, frameworks,
and test commands are intentionally outside this core.

## Review Lens

Clean code reads like intentional prose. A reviewer should be able to understand what changed, why it
is correct, and where to make the next related change without reconstructing hidden context.

Apply local conventions and examples after these portable checks.

## Naming

- Names should reveal intent at the point of use — the call site, not only the definition.
- Functions should use verb phrases that describe the action they perform.
- Variables should use noun phrases that identify the value's role, not just its type.
- Booleans should read as predicates (`is`, `has`, `can`, `should`) that answer one collaborator's
  question; if two unrelated lists of what would flip the answer appear, split into two names.
- Shared vocabulary (same wording reused across call sites — usually question-shaped helpers,
  sometimes structure nouns): invent 2–3 options from the call-site question, then wait for human
  (or authorship-mode proxy) agreement before landing identifiers. Mechanical renames of
  already-agreed names may proceed.
- Collections and maps should name what they contain (and, when useful, what keys them) with one
  vocabulary across layers — avoid synonym drift for the same graph concept.
- If call sites compose several booleans to ask one question, extract a named predicate instead of
  leaving the soup inline.
- Constants should replace repeated magic values when the value encodes meaning.

## Functions

- A function should do one thing at one level of abstraction.
- Split a function when its summary needs "and" to describe unrelated responsibilities.
- Prefer short, named steps over long blocks of mixed validation, transformation, and side effects.
- Keep arguments few and intention-revealing; group related domain input into one object when a call
  otherwise becomes positional archaeology.
- Return one coherent result shape. Avoid functions that sometimes return data and sometimes perform
  unrelated orchestration.

## Structure

- Put the headline behavior where a reader sees it first.
- Move supporting details below the high-level operation they support.
- Keep modules cohesive: one reason to change, one vocabulary, one stable responsibility.
- Put business rules in their natural home. Call that home instead of duplicating the rule elsewhere.
- Keep boundary conversion near the boundary. Code past the boundary should use the receiving layer's
  own language.

## Comments

- Prefer names and structure over explanatory comments.
- Write comments for intent, risk, invariants, non-obvious constraints, and rejected obvious choices.
- Delete comments that merely restate the next line of code.
- Keep process notes out of product code except for markers explicitly allowed by the target repo.

## Errors

- Handle errors at the layer that can add useful context or recover correctly.
- Let lower layers throw precise failures instead of swallowing them.
- Avoid catch blocks that only log and continue with corrupted state.
- Cleanup state in a `finally`-style path when the language supports it.

## Tests

- New behavior should have a test at the cheapest level that proves the behavior.
- Tests should exercise public behavior, not private wiring.
- Test names should describe the rule being protected.
- If a refactor changes structure but not behavior, keep or add tests before moving the structure.

## Practical Checklist

- [ ] Can a new developer understand each changed function without reading the whole file?
- [ ] Do names explain intent without comments?
- [ ] Does each function or method have one clear responsibility?
- [ ] Are repeated rules or constants centralized in the right home?
- [ ] Are boundary conversions explicit and near the boundary?
- [ ] Do comments explain why, not what?
- [ ] Are errors handled at the layer that can recover or add context?
- [ ] Is the touched behavior covered by an appropriate test?
- [ ] Does the change match local conventions unless deliberately refactoring them?

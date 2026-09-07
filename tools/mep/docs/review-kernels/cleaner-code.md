# Cleaner Code Review Kernel

This is the portable structural review kernel. It assumes the base clean-code checks in
`clean-code.md` and focuses on reducing future change cost. Repo-specific examples are intentionally
outside this core.

## Review Lens

Cleaner code minimizes blast radius. A reviewer should ask: when this rule changes later, how many
places must change, and how much distant context must the next developer remember?

## One Change, One Place

- A business rule should have one authoritative home.
- Duplicate stable rules are a warning sign; extract them when the repeated behavior is proven.
- Do not extract speculative generality. Duplication is cheaper than the wrong abstraction.
- If a helper needs mode flags to serve unrelated callers, the abstraction probably came too early.

## Boundary Discipline

- Convert external or infrastructure-shaped data at the boundary.
- Pass plain domain-shaped data into logic that does not need framework or persistence methods.
- Keep data access details inside the data access layer.
- Keep orchestration focused on sequencing work, not embedding queries, formatting, or rule math.
- **Contract at the boundary:** intermediaries must not silently change caller intent so a call
  succeeds with different semantics (contract laundering). Reject at the layer that owns the contract.
  Review question: does this call succeed while meaning something different than the caller asked?
  Repo-specific examples live in the active profile's review-kernel examples, not here.

## Headline First

- Put the highest-level operation at the top of a file or module.
- Let the file read from policy to detail: orchestration first, helper mechanics later.
- Group helpers by the headline behavior they support.
- Avoid making a reader scroll through private details before seeing the main behavior.

## Earned Abstractions

- Extract when it reduces the number of future edits, clarifies a stable concept, or isolates a
  meaningful rule.
- Do not extract just to make a function shorter if the extracted name adds no concept.
- Prefer explicit focused code while a requirement is still moving.
- Revisit duplication after the second or third real example, not after the first guess.

## Local Reasoning

- A reader should verify correctness from the changed module and direct collaborators.
- Avoid hidden call-order dependencies.
- Avoid global state coupling and implicit side effects.
- Make invariants visible in names, types, constants, tests, or narrow module boundaries.

## Proportionality

- Match cleanup scope to the reason for the change.
- Fix adjacent issues when they reduce risk in the touched behavior.
- Split broad structural cleanup into its own change when it would obscure the primary diff.
- Do not let a guideline become license for review-hostile churn.

## Practical Checklist

- [ ] If this rule changes next month, is there one obvious place to edit?
- [ ] Does data cross boundaries in the receiving layer's shape?
- [ ] Does the file present headline behavior before helper details?
- [ ] Does each abstraction remove real future editing cost?
- [ ] Can correctness be understood from local collaborators?
- [ ] Is cleanup proportional to the diff under review?
- [ ] **Contract at boundary:** caller intent is not silently changed so the call succeeds with different semantics?

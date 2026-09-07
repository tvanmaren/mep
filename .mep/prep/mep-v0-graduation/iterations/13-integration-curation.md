# Iteration 13 — Integration curation (`/mep curate`)

**Phase:** 5  
**Status:** committed  
**Slice type:** behavioral  
**Delivery track:** mixed  
**Fanout:** sequential  
**Shortcut:** sc-102

**Epistemic transition:** MEP's signature merge verb — **lossy compression** of discovery into review
narrative (AI-assisted **communication**, not implementation).

**Irreversible decision:** v0.1 ships **`preview` + `execute`**. Preview approves communication
strategy; execute writes **publication history** on integration branches (curated, not fabricated).

**Blocked by:** iteration 3 (workflow CLI / stage plumbing) and iteration 12 (CONTRIBUTING/examples).

**Dogfood slug:** `txn-adjustment-revamp` (deferred to iteration 14 — prep tree absent in repo).

---

## Goal

Add **`/mep curate <slug>`** — distill **discoveries**, plan **merge courses** + **review shards**,
then **materialize publication history** on integration branches. Hand off to **`/mep stage`**.

---

## Acceptance criteria

- [x] Preview: knowledge base (R/AD/D) → merge courses → shards + interaction policy + mergeability + narrative honesty
- [x] `--optimize` preset documented (executor + manifest; CLI passthrough deferred)
- [x] Execute: publication history on integration branches; lab unchanged (fixture-tested)
- [x] Outline + schema v2 (`discoveries`, `trunkStateAfterMerge`, gating)
- [ ] `/mep stage` reads approved artifact (stage integration noted; full dogfood iter 14)
- [ ] CONTRIBUTING documents curate workflow (blocked on iteration 12)
- [ ] txn-adjustment dogfood or documented blocker → **iteration 14**

---

## Architectural diff (landed `954828bdd`)

| area | truth after merge |
|------|-------------------|
| Operator | `/mep curate` → `prep-curate`; seventh verb; curate skill + outline |
| CLI | `curate.py` measure/validate/template/execute; artifact-path dirty allowance on execute |
| Artifact | v2 `integration-curation.json` template; publication branches `integrate/<slug>/course-*` |
| Tests | curate preview + execute dry-run + execute confirm + lab branch preserved |

---

## Avoid

- Rebasing discovery branch
- 1:1 iteration → PR mapping
- Chronological bias in publication order
- Invented dependencies (narrative dishonesty)
- Operator-facing "synthetic" vocabulary (use publication / integration history)

---

## Checkpoint (closed)

Curate preview + execute on fixture landed. txn-adjustment dogfood + CONTRIBUTING → iteration 14.

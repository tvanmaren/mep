# Iteration 16 — Document-colocated workflow state (post-v0.1)

**Phase:** 5  
**Status:** draft  
**Slice type:** architectural  
**Delivery track:** mixed  
**Fanout:** sequential  
**Shortcut:** sc-101

**Epistemic transition:** `manifest.json` retires; workflow state lives on plan documents.

**Blocked by:** iteration 15 (v0.1.0 tag), iteration 5 (resolver golden matrix).

**Not a v0.1 gate.** v0.1 ships the authoring contract and transitional manifest.

---

## Goal

Eliminate `manifest.json`. Checkpoint writes brief frontmatter; resolver reads initiative + brief
documents + git. Same routing semantics as iteration 5 golden matrix.

---

## Acceptance criteria

- [ ] Resolver reads document-colocated state with golden-matrix parity
- [ ] Checkpoint updates brief frontmatter instead of manifest fields
- [ ] Transitional manifest migration path documented

---

## Checkpoint

Manifest retired; document-native routing passes golden matrix; v0.2 program unblocked.

# Graduation — {{SLUG}}

**Status:** graduated  
**Date:** {{ISO_DATE}}

## Summary

Final cleanup pass completed. In-code epistemic markers removed; durable intent
comments retained.

## Tags removed

| file | tag | action taken |
|------|-----|--------------|
| | | removed / rewritten to durable comment |

## Durable comments kept

| file | comment | why it stays |
|------|---------|--------------|
| | | permanent business rule / invariant |

## Verification

- [ ] `rg '@(experimental|provisional|stable|foundational|reference-only)'` → 0 in ownedPaths
- [ ] tests green
- [ ] `/commit-prep {{SLUG}}` — code scope (cleanup)
- [ ] `/commit-prep {{SLUG}} docs-delta` — `06-graduation.md`

## Final PR

`/pr-description` — graduation PR; epistemic lead: initiative complete, tags stripped.

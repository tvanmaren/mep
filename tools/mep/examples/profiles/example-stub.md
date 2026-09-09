# Profile — example-stub

A minimal skeleton showing what a profile has to answer. To point the framework at another repo:

1. Copy this file to `.mep/profiles/<name>.md` and replace the placeholders with your repo's facts.
2. Add `.mep/profiles/<name>.json` beside it. That JSON is what the tool reads; this markdown is for
   people, so list it under `referenceOnly`. Fields are documented in
   [`profile-capabilities.md`](../../docs/profile-capabilities.md).
3. Set `profile.active=<name>` and `profile.dir=.mep/profiles` in `.mep/config`.
4. Don't edit the engine — retargeting never requires it.

The longer walkthrough is in the repo-root `CONTRIBUTING.md`. Placeholder content follows.

## reducers — uncertainty type → how to reduce it here

| Type | Reducer |
|------|---------------------|
| UX | `<your UI prototype path + fixtures>` |
| Domain | `<your domain / pure-function module path>` |
| Data / schema shape | `<your mock-data + validator pattern>` |
| Full-stack | `<your smoke-test runner + server entry points>` |

## house patterns — established approach for recurring domain areas (optional)

| Area | Pattern |
|------|---------|
| `<recurring feature area>` | `<the house move — e.g. defer compute, feature-flag rollout>` |

## zones — semantic zone → where code lives

| Zone | Home | Tag rigor |
|------|-------------------|-----------|
| experience | `<ui components / views>` | `@experimental` early |
| facade | `<api facade / mocks>` | `@provisional` until real API |
| domain | `<domain logic home>` | `@stable` early |
| integration | `<backend actions / routes>` | lowest AI autonomy |
| fixtures | `<mock data home>` | fidelity tags in brief |

## unit/spec — focused test command

`<your focused unit/spec test command>`

## smoke — full-stack test path

`<your smoke-test path>`

## comment syntax — maturity-tag examples

Use the host language's ordinary comments. Replace these placeholders with examples from your repo:

```text
<block comment start>
<module purpose>
@provisional — <why this boundary is still settling>
<block comment end>
```

```text
<line comment> @experimental — <what is still being proven>
```

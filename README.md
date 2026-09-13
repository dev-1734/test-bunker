# test-bunker

Public CI harness for smoke-testing code extracted from private repositories.

## Rules

- Never copy a private repository wholesale.
- Never copy secrets, production assets, real catalogs, credentials, signing files, private endpoints, or proprietary datasets.
- Each source project gets an isolated directory under `projects/<project-name>/`.
- Only the minimum source files needed for compile/runtime smoke tests are mirrored here.
- Shared workflows live under `.github/workflows/` and discover project configuration from `projects/<project-name>/bunker.env`.

## iOS projects

Each iOS project directory should provide:

- `bunker.env` — Xcode project, scheme and bundle/test identifiers
- `project.yml` — XcodeGen project definition
- `Sources/` — minimal public-safe source subset
- `Tests/` — simulator smoke tests

The shared iOS workflow runs only the project directories changed by a push. It can also be started manually for a named project.

This repository is a test harness, not a production source mirror.

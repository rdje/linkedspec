# ADR 0052: Repository-owned paths are relocation-safe

- Date: 2026-07-25
- Status: accepted; remediation and enforcement in progress
- Tags: architecture, paths, repository-root, relocation, portability, doctrine, tooling, cli

## Context

LinkedSpec is developed and verified from a movable checkout. A repository may be renamed, copied, restored on a
different machine, or moved between a home directory and another volume. A checked-in absolute checkout path, a
developer-specific home or mount value, or a compiled-in build directory turns the location of one checkout into
project identity. Moving the repository can then silently select files from the old tree or make a command fail.

The project already required repo-root-relative references in live Markdown and the mdBook, and most tools derive
their root from their own file. That policy did not cover all tracked source/configuration or shipped runtime
discovery. The 2026-07-25 audit found no checked-in literal of the current or former checkout and found that the
Perl, Dart, Julia, and Lua primary commands locate bundled content from runtime anchors. It also reproduced one
production defect: the Rust primary command used a compile-time Cargo manifest directory, so a copied binary
searched the checkout where it was compiled rather than the repository beside the relocated executable. Leaf
`.1.1` removed that build identity: the command now discovers a marked checkout from current executable ancestry
first, then cwd ancestry, with cwd as a deterministic no-marker fallback.

Absolute filesystem strings also have legitimate roles. A caller may explicitly request `/tmp/input.spec` or
`C:/Demo`, a test may prove path redaction, and an external interpreter or tool may live under `/usr` or `/opt`.
Those values do not identify repository-owned content and must not be conflated with checkout identity.

## Decision

1. Every persisted reference to repository-owned content is relative to the repository root. Tracked source,
   configuration, tests, fixtures, generated inputs, durable commands, and documentation may not store a concrete
   checkout directory as project identity.
2. Runtime code that needs repository-owned content derives the current root from its executing script/module or
   executable, or accepts an explicit caller-supplied root. It may use an absolute path only as an ephemeral value
   computed from that current root. A compiler/build directory is never a runtime checkout locator.
3. A command may explicitly require invocation from the repository root, but it must say so and all persisted
   operands remain root-relative. Primary shipped commands and repository gates instead resolve their root from a
   stable runtime anchor so an arbitrary caller cwd does not redirect bundled-content discovery.
4. Developer homes, private session directories, and private workspace/mount locations are not checked-in
   defaults. Legacy configuration expresses repo-owned values relatively and exposes external inputs through
   caller configuration or PATH-selected tools.
5. Caller-owned absolute paths, neutral path-contract fixtures, URLs, temporary directories, devices, and stable
   OS/tool installation paths remain legal when their role is explicit. They may not be used to infer, reconstruct,
   or persist a repository root.
6. Ignored tool caches may contain tool-generated absolute metadata and are regenerated after relocation. Their
   contents are not durable project identity. Debug information in a compiled binary may record source paths, so
   binary string absence is not the oracle; relocated execution is.
7. A fast structural doctrine scans the tracked parent repository and locks the five primary-command root anchors.
   A recurring process oracle copies the Rust executable beneath a synthetic moved root and invokes it from outside
   that tree. The `rgx` gitlink retains its own repository/task/commit boundary.

## Consequences

- Moving or renaming a checkout cannot make LinkedSpec use the previous checkout's repository-owned files.
- Rust primary-command discovery is runtime-rooted as of `REPO-ROOT-PATH-PORTABILITY.1.1`; a copied executable
  beneath a synthetic moved checkout loads that checkout's unique adjacent spec from an outside cwd.
- Audited legacy developer-home/private-mount values and machine-specific Knowledge Map commands are repaired in
  separate leaves so production discovery, legacy configuration, and durable documentation remain reviewable.
- The checker must be false-positive-safe: rejecting an explicit caller path or `/usr/bin/env` would weaken native
  path contracts rather than improve checkout portability.
- New checkout-path doctrine work is not complete until both the static tree and a relocated process reproduce.

## Links

- Task tree: `docs/tasks/REPO-ROOT-PATH-PORTABILITY.md`
- Existing documentation rule: `COMMIT.md`
- Caller path/loading contract: `docs/decisions/0026-native-spec-resolution-and-loading-contract.md`
- Enforcement architecture: `DOCTRINE_ENFORCEMENT.md`
- Public verification guide: `docs/linkedspec-book/src/development/local-ci-and-regression.md`

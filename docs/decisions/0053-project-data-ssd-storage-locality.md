# ADR 0053: Project-owned data stays on the repository filesystem

- Date: 2026-07-26
- Status: accepted; initializer and standard workflow routing implemented, migration pending
- Tags: architecture, storage, filesystem, ssd, caches, temporary-data, portability, doctrine, tooling

## Context

The repository now resides on a 4-TB SSD, but supported workflows still inherit operating-system and language-tool
defaults that place project state elsewhere. The audit at `PROJECT-DATA-SSD-ROOTING.0` reproduced the mismatch:
the current repository and the current per-user temporary root are on different filesystems. Sixty-five retained
CLI workspaces plus two Julia depots occupy 135,756 KiB on the internal temporary filesystem. Two global Dart
active-root records identify the current and former LinkedSpec checkouts, and one shared Julia usage log retains a
former LinkedSpec manifest entry.

The tracked mechanism is broader than those current residues. One hundred files allocate through default temporary
APIs or explicit temporary roots. By language/tool family, the ownership census reaches 24 Perl, 16 Rust, 18 Dart,
17 Julia, 13 Lua, three Python, and 12 shell files, with some multi-language harnesses counted in more than one
family. Twenty-four executable files contain explicit off-repository storage defaults. Ninety-seven Knowledge Map
fact cards still contain 107 old temporary/home-depot command lines. Inert redaction and path-value fixtures are a
separate class because they do not perform filesystem IO.

External toolchains and operating-system libraries are not project data. The current required Git, Perl, Python,
Rust, Dart, Julia, Lua, LuaJIT, and mdBook entrypoints are installed on the internal filesystem. Reading those
externally managed prerequisites is necessary until the caller supplies equivalents on the repository filesystem;
copying system tools into the repository would neither make them project-owned nor remove their operating-system
library dependency. Package caches, depots, temporary workspaces, logs, generated output, and checkout-identity
metadata are not necessary exceptions: LinkedSpec can own those locally.

ADR `0052` permits explicit caller paths and recognizes temporary directories as a legal filesystem data type. It
does not require project-owned temporary state to use an external temporary filesystem. This record narrows that
boundary for storage locality.

## Decision

1. The filesystem containing the current repository is the authority for all LinkedSpec-owned state. Durable
   path expressions remain relative to the repository root; absolute runtime paths are derived from that root.
2. Project-owned state includes build products, generated outputs, logs, traces, TAP/oracle dumps, temporary test
   workspaces, package/dependency caches populated for LinkedSpec, depots, and retained reproducibility artifacts.
3. Supported entrypoints establish repo-derived scratch and retained-cache roots before any child process or
   language runtime can allocate project state. An inherited temporary/cache variable is accepted only when its
   resolved destination is on the repository filesystem; otherwise LinkedSpec replaces it with the local root.
4. Supported workflows do not read another volume by default. Cross-volume access is allowed only for an explicit
   caller input/configuration or an externally managed executable, system library, device, credential, or OS
   service that the workflow strictly requires. Each default exception is documented and mechanically bounded.
5. Cargo registries, Dart packages, Julia packages/precompile state, and similar dependencies used by supported
   LinkedSpec workflows are populated into repo-local caches. The workflows stop consulting shared global caches.
   Shared caches are not moved or deleted wholesale because their contents may belong to other projects.
6. Migration is copy/verify/use/delete for retained data and delete-after-owner-proof for disposable data. File
   counts, byte sizes, and hashes are checked where material; the SSD-backed replacement is exercised before the
   exact old LinkedSpec-owned source is deleted in the same leaf. No duplicate old project data is retained.
7. Caller-supplied external paths authorize only that invocation's explicit input or output contract. They never
   become a project default, repository locator, cache/depot root, or blanket cross-volume exception.
8. A structural doctrine and representative process oracle enforce storage locality. The process proof uses
   hostile inherited temporary/cache variables, verifies the actual filesystem of project IO, and admits only the
   frozen necessary external-access classes.

## Consequences

- Moving the repository between filesystems moves the project-data authority with it; no concrete SSD mount path is
  stored.
- Reusable caches are retained on the SSD instead of repeatedly deleted for disk pressure.
- Supported local gates become insulated from a developer home, per-user OS temporary location, and shared package
  caches.
- Direct low-level commands that bypass supported entrypoints must first initialize the repo-local environment or
  explicitly supply equivalent repo-filesystem roots.
- The implemented default hierarchy is repository-relative `/.linkedspec-data/`, split into disposable `scratch/`
  and retained `cache/`. `tools/project_data_env.sh` derives its absolute value at runtime and validates device
  identity before and after creating a caller override.
- The pre-commit hook, doctrine and Knowledge Map scripts, canonical Perl gate, Rust/Dart/Julia/Lua local gates,
  and mdBook wrapper source that helper at their self-rooted boundary. Direct lower-level commands remain explicit.
- External compiler/interpreter and system-library reads remain visible necessary dependencies, not hidden storage
  defaults. Installing caller-selected toolchains on the SSD can reduce that exception surface later.
- ADR `0052` remains authoritative for repository identity and explicit caller paths; ADR `0053` supersedes any
  interpretation that project-owned scratch may default to an external temporary filesystem.

## Links

- Task tree: `docs/tasks/PROJECT-DATA-SSD-ROOTING.md`
- Repository relocation: `docs/decisions/0052-repository-root-path-portability.md`
- Local verification: `docs/linkedspec-book/src/development/local-ci-and-regression.md`
- Doctrine registry: `DOCTRINE_ENFORCEMENT.md`

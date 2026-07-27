---
id: repository-root-path-portability
title: Repository-owned paths must survive checkout relocation
answers:
  - can the LinkedSpec repository root be moved or renamed
  - may LinkedSpec store an absolute checkout path
  - how must tools find the LinkedSpec repository root
  - may a runtime use CARGO_MANIFEST_DIR to find shipped specs
  - are caller supplied absolute spec paths still allowed
  - are usr opt and tmp paths repository path violations
  - do ignored build caches have to be free of absolute paths
  - which LinkedSpec primary command failed the relocation audit
  - how does the Rust primary command discover a relocated repository
  - does executable or cwd repository discovery win in Rust
  - do legacy LinkedSpec configs contain developer home or private mount defaults
  - how do legacy LinkedSpec configs select external tools and design inputs
  - how should portable Julia reverify commands compose depot paths
  - does a trailing empty JULIA DEPOT PATH include the user depot
  - why do direct Julia semantic query tests define REPO ROOT
  - how is repository root path portability mechanically enforced
  - what does the REPO ROOT PATHS doctrine scan
  - which primary commands does the repository path doctrine lock
  - which absolute paths does the repository path doctrine allow
  - what did REPO ROOT PATH PORTABILITY 0 discover
  - why can repository local TMPDIR not model an external executable
  - which recurring oracle proves a copied LinkedSpec binary uses its moved repository
  - how is executable root precedence proved against an ambient repository
  - do all five LinkedSpec primary runtimes resolve named specs outside the checkout
date: 2026-07-27
status: current
tags: [architecture, paths, repository-root, relocation, portability, doctrine, cli, rust, REPO-ROOT-PATH-PORTABILITY]
evidence: "REPO-ROOT-PATH-PORTABILITY.0 found zero current/former checkout literals and zero tracked symlinks, with outside-cwd Perl/Dart/Julia/Lua probes green and a copied Rust binary RED. REPO-ROOT-PATH-PORTABILITY.1.1 replaces Rust compile-time CARGO_MANIFEST_DIR discovery with current-executable then cwd marker discovery; the moved-tree process exits 0 with exact relocated-root. PROJECT-DATA-SSD-ROOTING.2.2 finds that a synthetic executable below repository-local TMPDIR is genuinely below the checkout and therefore cannot model external ancestry; the topology unit now injects the marker predicate over relative paths, while the storage oracle separately exercises an actual copied binary and same-device trace. PROJECT-DATA-SSD-ROOTING.2.4 migrates 88 existing current Julia reverify cards to self-rooted repository-storage wrappers and removes disposable package-manager usage metadata containing runtime absolute paths. REPO-ROOT-PATH-PORTABILITY.2.1 registers the read-only REPO-ROOT-PATHS structural doctrine with 14 classifier cases and all five runtime-anchor locks. REPO-ROOT-PATH-PORTABILITY.2.2 adds a Rust integration owner that distinguishes a synthetic moved repository from a conflicting ambient repository by exact named-spec output, requires exact failure after marker removal, composes Perl/Dart/Julia/Lua outside-cwd named-spec proof in one self-rooted oracle, raises routing to 39 entrypoints, and registers the process proof once in canonical local CI. ADR 0052 is fully implemented."
reverify: "bash scripts/check_repo_root_path_portability.sh && bash tools/test_repo_root_process_portability.sh && bash scripts/check_doctrines.sh"
---

ADR `0052` makes checkout relocation a correctness property. Checked-in references to repository-owned files are
root-relative. Code that needs an absolute path computes it ephemerally from the current script, module,
executable, or an explicit caller root; a build directory or a former checkout is never runtime identity.

The audit began at clean commit `99a3df5b`. No tracked parent-repository text names the current SSD checkout or
the former `Documents/github` checkout shape, and the tree contains no tracked symlink. Twenty-five of 27 tracked
shell/hook files derive their root from their own location or git; the other two access no repository content.
Perl uses `FindBin`, Dart ascends from cwd and `Platform.script`, Julia joins from `@__DIR__`, and Lua derives from
`debug.getinfo`. Named-Lispish commands launched outside the checkout returned exact
`["hello",["world"]]` on all four.

Rust was the confirmed exception. `rust/linkedspec-runtime/src/primary_cli.rs` constructed the repository root from
`env!("CARGO_MANIFEST_DIR")`. Copying the built executable beneath a synthetic moved tree, adding a unique adjacent
named spec, and launching from outside both trees reproduced exit 1 with `parser compilation failed`: the binary
looked back into its compile-time checkout. `REPO-ROOT-PATH-PORTABILITY.1.1` replaced that mechanism: `run` now
searches upward from the current executable for the checked-in `specs/user_function_definition.spec` marker, then
searches cwd ancestry, then deterministically falls back to cwd. Executable precedence keeps a bundled command
attached to its own relocated tree; cwd ancestry supports an installed command invoked within a checkout. The
original copied-binary reproduction now exits 0 with exact `"relocated-root"`.

`REPO-ROOT-PATH-PORTABILITY.2.2` makes that process proof recurring and mutation-sensitive. The Rust integration
test copies the freshly built primary beneath a synthetic moved repository and gives a conflicting ambient cwd a
different sentinel. Exact `"relocated-root"` output proves executable-root precedence; removing the moved marker
then requires exit 1 and exact compile-failure output. `tools/test_repo_root_process_portability.sh` composes that
integration owner with exact Perl, Dart, Julia, and Lua named-`Lispish` execution from a same-SSD cwd outside the
checkout. It initializes managed repository storage, keeps generated Lua/Cargo state below that run, is the 39th
routed entrypoint, and runs once in canonical local CI.

SSD-local temporary routing makes filesystem ancestry semantically important. A test executable created beneath
repository-local `TMPDIR` is beneath the real checkout, so discovery correctly reaches the real bundled-spec
marker; calling that path external was a test-model defect. The topology-only unit now supplies a marker predicate
over relative synthetic paths. `tools/test_rust_project_data_storage.sh` remains the independent filesystem proof:
it copies the built primary into managed scratch, invokes it from a nested cwd, creates a trace, and verifies all
outputs stay on the repository device.

The same audit found 12 Julia fact-card commands plus four legacy source/config files containing 42 developer-home
or private-session lines; four legacy config/plugin files contained six `/vobs/` mount values, and one contained a
`/dsync/` workspace. `REPO-ROOT-PATH-PORTABILITY.1.2` removes those values from all eight frozen legacy owners.
Project defaults are relative to the caller-selected root, `perl`/`mktemp`/`enscript`/CGI interpreters use `PATH`,
EasyTk leaves Tcl/Tkx package discovery to caller configuration, and `network.plg` consumes the existing
`dc_load_cmd` plus `ddc` fields. Stable external `/usr/bin/csplit` remains explicit OS/tool data. The derived
`KNOWLEDGE_MAP.md` is not a separate source; `.1.3` normalizes the 12 fact cards and regenerates it.

The `.1.3` commands originally selected `julia` through `PATH` and retained root-relative project/test operands.
Storage migration `.2.4` now routes all 88 existing current Julia reverify cards through
`tools/run_julia_project_data.sh`, `tools/run_julia_local.sh`, or the self-rooted primary checker. The wrappers
derive managed temporary and retained depot roots from their own checkout, resolve packages offline from the
repository cache, and admit only Julia-managed system depots after the writable first entry. A trailing empty
depot entry still means system depots, not the developer-home depot. Julia's disposable manifest-usage index is
removed after supported package commands because it records runtime absolute paths; package sources, registry,
and compiled cache remain retained.

`REPO-ROOT-PATH-PORTABILITY.2.1` makes the rule mechanical through
`scripts/check_repo_root_path_portability.sh`, registered once as `REPO-ROOT-PATHS`. The read-only checker derives
its own root, inventories only `git ls-files` parent-repository text, excludes the `rgx` gitlink, skips binaries,
and therefore ignores generated/package caches by construction. It rejects the current checkout, concrete Unix/
macOS/Windows developer roots, private session/workspace roots, and `env!("CARGO_MANIFEST_DIR")` specifically in
the shipped Rust primary command. Its always-run self-test proves seven rejection and seven legal classes. Legal
data stays legal: relative operands, repository URLs, `/usr`/`/opt` tools, caller `/tmp`, `C:/Demo`, and bare path-
denial needles. Fixed structural locks retain Perl `FindBin`, Rust executable-then-cwd marker discovery, Dart cwd/
script ascent, Julia `@__DIR__`, and Lua `debug.getinfo` anchors. The doctrine driver supplies E3/E4 through the
existing pre-commit hook and local CI registration.

This doctrine does not ban filesystem absolutes as a data type. Explicit caller paths, neutral path-contract
fixtures such as `C:/Demo`, redaction-test needles, URLs, caller-owned `/tmp` path values, and external `/usr` or `/opt` tools remain
valid. Ignored caches are regenerated after a move, and debug symbols may retain source locations. The invariant
is that none of those values becomes an implicit or durable repository root.

Related facts: [[native-spec-resolution-contract]], [[native-spec-resolution-policy-drift]],
[[neutral-cli-fixture-runner]], [[rust-local-verification-gate]], [[rust-project-data-ssd-storage]],
[[julia-project-data-ssd-storage]], [[lua-toolchain-package-policy]],
[[repository-root-relocation-process-proof]].

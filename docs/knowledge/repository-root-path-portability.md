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
date: 2026-07-26
status: current
tags: [architecture, paths, repository-root, relocation, portability, doctrine, cli, rust, REPO-ROOT-PATH-PORTABILITY]
evidence: "REPO-ROOT-PATH-PORTABILITY.0 found zero current/former checkout literals and zero tracked symlinks, with outside-cwd Perl/Dart/Julia/Lua probes green and a copied Rust binary RED. REPO-ROOT-PATH-PORTABILITY.1.1 replaces Rust compile-time CARGO_MANIFEST_DIR discovery with current-executable then cwd marker discovery; the same moved-tree process exits 0 with exact relocated-root. REPO-ROOT-PATH-PORTABILITY.1.2 removes developer-home/private-mount values from all eight frozen legacy config/source owners: project defaults are relative, tools use PATH, EasyTk package discovery is caller-owned, and network.plg consumes its configured command/input fields. REPO-ROOT-PATH-PORTABILITY.1.3 normalizes all 12 Julia reverify commands to PATH-selected Julia, root-relative operands, and runtime-composed caller-writable depots. REPO-ROOT-PATH-PORTABILITY.2.1 registers the read-only REPO-ROOT-PATHS structural doctrine: tracked parent text is scanned, 14 reject/accept classifier cases self-test, compile-time Rust primary discovery is forbidden, and Perl/Rust/Dart/Julia/Lua runtime anchors are locked. ADR 0052 freezes the boundary."
reverify: "bash scripts/check_repo_root_path_portability.sh && bash scripts/check_doctrines.sh"
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
original copied-binary reproduction now exits 0 with exact `"relocated-root"`. `.2.2` owns the recurring process
oracle.

The same audit found 12 Julia fact-card commands plus four legacy source/config files containing 42 developer-home
or private-session lines; four legacy config/plugin files contained six `/vobs/` mount values, and one contained a
`/dsync/` workspace. `REPO-ROOT-PATH-PORTABILITY.1.2` removes those values from all eight frozen legacy owners.
Project defaults are relative to the caller-selected root, `perl`/`mktemp`/`enscript`/CGI interpreters use `PATH`,
EasyTk leaves Tcl/Tkx package discovery to caller configuration, and `network.plg` consumes the existing
`dc_load_cmd` plus `ddc` fields. Stable external `/usr/bin/csplit` remains explicit OS/tool data. The derived
`KNOWLEDGE_MAP.md` is not a separate source; `.1.3` normalizes the 12 fact cards and regenerates it.

The `.1.3` commands now select `julia` through `PATH`, retain root-relative `--project=julia` and test operands,
and prepend caller-writable `${TMPDIR:-/tmp}` depots to the default depots reported by Julia at runtime. The
explicit runtime composition matters: a trailing empty `JULIA_DEPOT_PATH` entry expands to Julia's system depots,
not the user package depot, so the first attempted rewrite lost installed packages and tried to fetch the General
registry while offline. The corrected commands persist no expanded home/session path. Three direct semantic-query
commands also define `REPO_ROOT=pwd()` before including shared tests because those fixtures consume that harness
constant; this is an explicit repo-root invocation contract, not baked-in checkout identity.

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
fixtures such as `C:/Demo`, redaction-test needles, URLs, `/tmp` scratch, and external `/usr` or `/opt` tools remain
valid. Ignored caches are regenerated after a move, and debug symbols may retain source locations. The invariant
is that none of those values becomes an implicit or durable repository root.

Related facts: [[native-spec-resolution-contract]], [[native-spec-resolution-policy-drift]],
[[neutral-cli-fixture-runner]], [[rust-local-verification-gate]], [[lua-toolchain-package-policy]].

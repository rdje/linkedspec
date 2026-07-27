---
id: repository-root-relocation-process-proof
title: Recurring process proof locks moved-checkout root selection
answers:
  - which test proves a copied Rust primary uses its moved repository
  - how does LinkedSpec distinguish executable root selection from ambient cwd selection
  - what happens when the copied Rust primary has no moved repository marker
  - which command proves all five primary runtimes resolve named specs outside the checkout
  - does the relocation process oracle keep project data on the repository filesystem
  - where does the relocation oracle build Lua native modules
  - is the moved checkout process proof part of canonical local CI
  - how many project data workflow entrypoints are currently routed
  - can every backend be rebuilt locally when canonical backend flags are optional
date: 2026-07-27
status: current
tags: [architecture, paths, repository-root, relocation, portability, process-oracle, rust, cli, REPO-ROOT-PATH-PORTABILITY]
evidence: "REPO-ROOT-PATH-PORTABILITY.2.2 adds rust/linkedspec-runtime/tests/repository_root_relocation.rs and tools/test_repo_root_process_portability.sh. The Rust test copies CARGO_BIN_EXE_linkedspec-rust below a synthetic moved repository in managed scratch. Moved and ambient repositories contain the required marker and same uniquely named spec but return relocated-root and ambient-wrong-root respectively; launch from the ambient cwd returns exact relocated-root. Removing only the moved marker and launching from outside returns exit 1 with exact parser compilation failed. The shell oracle then launches Perl, Dart, Julia, and Lua named Lispish commands from the repository's same-filesystem parent and requires exact [hello,[world]] JSON. It uses routed Dart/Julia storage state, builds Lua modules below LINKEDSPEC_RUN_DIR, is the 39th routed entrypoint, and runs once in tools/run_ci_local.sh. Focused proof, workflow routing, structural path/storage doctrines, process containment, fresh complete Rust/Dart/Julia/PUC Lua/LuaJIT local gates, primary 660/660, Unicode 10/10, all maintained focused matrices, scalar numeric 55/55, and canonical CI pass."
reverify: "bash tools/test_repo_root_process_portability.sh && bash tools/test_project_data_workflow_routing.sh && bash tools/project_data_run.sh --list"
---

The static `REPO-ROOT-PATHS` doctrine prevents persisted checkout identity and locks the five source anchors, but a
runtime proof is still required: compiled debug strings are not behavior, and a copied binary below the real
checkout can accidentally rediscover the real marker through its ancestors.

`rust/linkedspec-runtime/tests/repository_root_relocation.rs` owns the exact moved-root behavior. It creates a
synthetic moved repository, a conflicting ambient repository, and an outside directory below the current managed
run. Both repositories contain `specs/user_function_definition.spec` and `RelocationSentinel.spec`, but the moved
sentinel returns `relocated-root` while the ambient sentinel returns `ambient-wrong-root`. The freshly built Rust
primary is copied below the moved root and launched with the ambient repository as cwd. Exact moved output proves
that executable ancestry wins; removing the moved marker and requiring exact compilation failure proves that an
incomplete moved topology cannot silently fall back to unrelated repository content.

`tools/test_repo_root_process_portability.sh` is the composed process boundary. It self-roots, enters managed
repository storage, and selects the repository's parent directory as an outside-checkout cwd only after confirming
that it shares the repository filesystem. It runs the Rust integration owner and then exact named-`Lispish`
commands for Perl, Dart, Julia, and Lua. Dart uses its targeted project-data wrapper; Julia uses the already routed
writable depot with network-free package behavior; Lua native modules are built below `LINKEDSPEC_RUN_DIR`.
Expected stdout is byte-exact for every anchor, and no project output is written to the caller cwd.

Canonical local CI invokes the composed oracle once after the broader six-family kernel containment proof. The
workflow-routing oracle treats it as the 39th entrypoint and confirms hostile inherited storage values are replaced
before its Cargo preflight. Canonical backend flags control scheduling; they do not prevent direct local rebuilds.
Closeout independently ran every complete backend gate plus primary 660/660, Unicode self-hosted 10/10, every
maintained diagnostic/logical/root/cursor/duplicate/repeated/punctuation matrix, and scalar numeric 55/55 across
six runtimes. Related facts: [[repository-root-path-portability]],
[[project-data-ssd-storage-locality]], [[project-data-process-locality-proof]].

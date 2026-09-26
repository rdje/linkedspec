---
id: rust-format-owned-packages
title: Rust formatting must explicitly select LinkedSpec packages to respect the dependency boundary
answers:
  - "why does cargo fmt all check RGX and PGEN source"
  - "how does the Rust gate restrict formatting to LinkedSpec packages"
  - "which formatting failure blocked LS-004 native adoption"
date: 2026-09-26
status: corrected under RGX-CONSUMER-BUILD-REPORTS.1.2
tags: [rust, formatting, dependency-boundary, verification]
evidence: "The first adoption gate's --all invocation emitted dependency formatting diffs. The corrected explicit package selection passes all65 LinkedSpec targets with zero dependency targets. No dependency diff was analyzed or source changed. Two formatting-only hunks in map_leaves_mutation_contract.rs are corrected."
reverify: "bash tools/run_cargo_local.sh fmt --verbose --manifest-path rust/Cargo.toml -p linkedspec-core -p linkedspec-runtime -- --check"
---

`tools/run_rust_local.sh` selects `linkedspec-core` and `linkedspec-runtime`
explicitly. Cargo fmt's `--all` also traverses local path dependencies, so it
does not express the required LinkedSpec ownership boundary. Keep dependency
implementation formatting upstream-owned; never run a source-changing formatter
on RGX or its transitive dependencies to make LinkedSpec's gate pass.

The verbose selected-package command independently enumerates65 targets under
the two LinkedSpec packages and no RGX target. Its output hash and the gate's
initial failure are retained in the adoption checkpoint. The initial dependency
diff stream is opaque diagnostic output, not implementation reading credit.

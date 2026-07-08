---
id: terse-lifecycle-value-drop-return-channel
title: SPEC-FORMAT-TERSE.2.3.2 lifecycle blocks are intended as statement blocks; explicit return writes the rule/action channel, with a current Perl handler-shape caveat
answers:
  - "are lifecycle blocks expression-valued in LinkedSpec"
  - "does the last statement in I LS LE E EX IT LX return implicitly"
  - "can Perl lifecycle blocks leak the final statement value"
  - "what does return(expr) inside a lifecycle block do"
  - "is return(expr) inside an expression-valued block the same as lifecycle return"
  - "does Rust stop after a top-level lifecycle return"
  - "how is lifecycle value drop locked"
date: 2026-06-30
status: current
tags: [spec-format-terse, lifecycle, return-channel, expression-valued-blocks, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.2 landed focused locks on 2026-06-30. Perl phase0 subtest `spec_format_terse_2_3_2_locks_lifecycle_value_drop_and_return_channel` source-locks structured blocks for all seven lifecycle markers (`I`, `LS`, `LE`, `LX`, `E`, `EX`, `IT`) and runtime-locks three distinctions using action-edge-shaped probes: (1) a final ordinary lifecycle statement such as `set(ignored, \"i-final\")` mutates state but is not the explicit action-edge return; (2) a top-level Perl lifecycle `return(\"i\")` writes the surrounding rule channel through host return semantics; (3) `return(\"block\")` inside an expression-valued block remains block-local, so later outer statements still run. Rust integration tests `terse_2_3_2_*` lock the same intended value/drop distinction and the Rust backend's existing return-event shape. SPEC-LANG-REFERENCE.10.5.9 added an important Perl reference caveat on 2026-07-08: TOOLBOX probes showed some current generated-Perl handler shapes still expose a host-language final statement value when an `I` block omits explicit `return(...)`, and direct `Top:: I ... /x/ E { ... }` generated source omitted the regex/E path and returned the final I statement value. Treat final-statement leakage and direct E finalization in those shapes as non-portable current-backend drift; public examples should use explicit lifecycle `return(...)` and not rely on lifecycle fallthrough."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_2 && mdbook build docs/linkedspec-book"
---

Lifecycle blocks are statement blocks.

Ground truth:

- The portable authoring contract is statement-oriented: ordinary statement values in lifecycle blocks are not
  something authors should rely on as implicit rule returns.
- Current Perl generated handlers have legacy shapes where an omitted explicit lifecycle `return(...)` can leak
  the host-language final statement value. Write explicit `return(...)` when a lifecycle block should surface a
  value, and do not use final-statement leakage as a language feature.
- Top-level lifecycle/action `return(expr)` writes the surrounding rule/action return channel.
- `return(expr)` inside an expression-valued block is block-local: it yields that block's value and skips later
  statements only inside that value block.
- Rust's top-level `execute(...)` result is an accumulator of return events. Current Rust lifecycle execution
  can therefore expose multiple top-level return events from one lifecycle path; this is existing runtime
  behavior and is separately locked from Perl's host-level early return behavior.

---
id: terse-string-comparison-bridge-contract
title: "SPEC-FORMAT-TERSE.3.2.3.2 ships the explicit str_* string comparison bridge."
answers:
  - "why do str_eq str_ne str_gt str_ge str_lt str_le receiver chains stay raw DSL"
  - "does Perl str_eq coerce undef to empty text"
  - "what is str_eq"
  - "are str_eq and str_gt implemented"
  - "what is the string comparison bridge contract"
  - "when can bare gt become numeric"
  - "what is next after SPEC-FORMAT-TERSE.3.2.3.1"
  - "should docs use str_eq now"
date: 2026-10-26
status: Perl/Rust ordinary counterparts checked; other backends/full admission open
tags: [spec-format-terse, comparisons, string-helpers, helper-aliases, task-tree, mdbook]
evidence: "Historical bridge3.2.3.1/.2 and numeric migration3.2.3.3/.4; assessment TYPE23.2.11 and Perl23.3.12.1. Full prior implementation/replay/assignment chronology at Gitd9d81fa9a491380ca6d7b2a24cca727c581399ba for this path."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/string_comparison_result_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test string_comparison_result_receivers"
---

str_eq/str_ne/str_gt/str_ge/str_lt/str_le are lexical helpers. Bare eq/ne/gt/ge/lt/le and comparison symbols stay numeric. TYPE23.2.11 freezes one-RHS ordinary receiver counterparts under the comprehensive fluent directive. Detailed prior assessment/migration records remain in this path at Gite227e9e8199527dc358e81c588c49afe210a5ef3 and the earlier Git pointer above.

Perl23.3.12.1 extends registration/preflight lists; Rust23.3.12.2 adds String/scalar/one-operand lists. Perl producers remain numeric1/0; Rust remains Bool. Both preserve false0! through coalesce_nonempty and existing undef-as-empty comparison compatibility. Perl retains enabled legacy warnings. No new portable null/scalar/Unicode domain or producer normalization.

Native/fresh Perl and native/restored/plan Rust shared/direct definedness checks pass after raw/compile or null/24-effect RED. All six true/false/raw-kind pairs, null/empty/zero twins, source families, false/generic/bridges/scalar guards,12 malformed no-effects and1!/SOC/once-only/final-null snapshots pass. Free producers/order already worked; no snapshot repair inferred. Contract/probe: string-comparison-results.md/probe_string_comparison_results.pl. Full admission23.4, mandatory Perl selection23.4.1 and Dart Unicode-order2.13 remain separately owned; other backends require independent assessment.

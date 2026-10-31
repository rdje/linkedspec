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
status: Five ordinary backends targeted-checked; full admission open
tags: [spec-format-terse, comparisons, string-helpers, helper-aliases, task-tree, mdbook]
evidence: "Historical bridge3.2.3.1/.2 and numeric migration3.2.3.3/.4; assessment TYPE23.2.11 and Perl23.3.12.1. Prior chronology at Gitd9d81fa9a491380ca6d7b2a24cca727c581399ba."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/string_comparison_result_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test string_comparison_result_receivers"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/string_comparison_result_receivers_test.dart"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; include(\"julia/test/string_comparison_result_receivers_test.jl\")'"
  - "bash tools/run_lua_project_data.sh puc lua/test/string_comparison_result_receivers_test.lua"
---

str_eq/str_ne/str_gt/str_ge/str_lt/str_le compare lexical text; bare eq/ne/gt/ge/lt/le and symbols remain numeric. TYPE23.2.11 freezes one-RHS ordinary receivers. Prior full records: this path at Gita9f7b0bb766934ba25fe0c4cc106d5df2486fe7d and the earlier history above.

Perl23.3.12.1 extends preflight/scalar registration; Rust2 adds String/scalar/preflight lists; Dart3/Julia4 add scalar/preflight lists; Lua5 removes terminal fence and adds scalar/preflight guards. Producers stay Perl numeric1/0 versus Rust/Dart/Julia/Lua Bool. False renders0! and survives coalesce_nonempty. Perl/Rust retain undef-as-empty comparison (Perl legacy warnings); Dart/Julia/Lua propagate null operands. No portable null/Unicode-domain normalization; Dart UTF-16 gap stays DART2.13.

Native/fresh Perl and native/restored/plan Rust/Dart/Julia/Lua shared plus direct definedness checks pass after raw/compile, receiver-null or empty-Array/24-effect RED. Six pairs/raw kinds, null/empty/zero twins, source families, false/generic/bridges/scalar guards,12 malformed no-effects and1!/SOC/once-only/final-null pass. Producers/snapshots already worked; Julia checks raw isa Bool. Contract/probe: string-comparison-results.md/probe_string_comparison_results.pl; .perl.json numeric, .json Bool, .null.json Dart/Julia/Lua null-boundary variant. Full admission23.4/Perl selection23.4.1 remain open.

Lua native/plan/fresh/direct checks pass on available PUC5.5.1/LuaJIT; declared5.4 remains LUA2.2. Baseline fence suppressed consumer C (SO/sourcezzz), not a proved source snapshot defect.

Canonical free/ordinary prefix lexical guard composition through Array bridges/later immediate with is separately repaired by Perl66.1: [[lexical-result-source-guards]]. Original numeric1-0/copy/null/warning/Unicode/alias qualifications unchanged; peers independently use existing Boolean profiles/full23.4 separate.

Rust66.2 independently repairs canonical free/ordinary prefix source guards through bridges/later with while preserving Bool and existing null/Unicode qualifications: [[rust-lexical-result-source-guards]].

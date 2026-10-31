---
id: rust-string-predicate-source-guards
title: Rust String-predicate guards admit the existing matches RegexLiteral operand
answers:
  - "how does Rust guard free String-predicate and matches continuations"
  - "why did Rust matches still run with after other String predicates were guarded"
  - "which Rust source role accepts RegexLiteral only for matches"
  - "where are Rust String-predicate source guard tests"
date: 2026-10-31
status: bounded Rust70.2 targeted-checked; full admission separate
tags: [rust, string, predicates, regex, guards, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.70.2; string-predicate-guard-rust-intake.json.gz retains original/intermediate/repaired epochs, actual sources/instruments/fixtures and public AST observations."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test string_predicate_result_guard_composition --test string_predicate_result_receivers"
---

Rust70.2 preserves canonical String-predicate free-two/ordinary one-operand source guards. Independent unchanged23 tests15PASS8RED become23PASS on native/restored CompiledSpec/in-process plan routes;15 includes thirteen healthy values/one needed source error/one eighteen-shape scaffold. All21 values/four existing profiles/thirteen healthy observations/error/eighteen public syntax observations retain exact kinds and behavior. Initial pure-role implementation gives20PASS3RED: only matches members still yield free[]/A or run with/AW. Existing public CodeBlock::parse observations expose kind=regex/Expr::RegexLiteral omitted from the copied lexical operand union. Recognize that existing node only as matches final positional operand (free index1/prefix index0), leaving payload/flags/evaluator and text-predicate operands unchanged. Both existing guard admissions retain source-operand SOC snapshots, numeric text flags versus Bool matches, strict arithmetic/copy/default/generic/valid false-null-empty with/returned Array/errors/function state; incompatible operands/later bodies skip. Selected nearest predicate/free String/receiver bridge/presence 58 tests and owned core/runtime fmt pass. 533 other declared activation inputs exact. Twelve actual include_str fixtures derive from five consumers and match base Git bytes; all phase declared identities exact, not complete transitive closure. Initial fixture instrument correctly derived twelve but assumed ten; repaired before runtime baseline with original writer retained, no runtime RED credit. Original/intermediate/repaired epochs, actual instruments/templates/inputs/raw channels retained in string-predicate-guard-rust-intake.json.gz. Rebuild Rust apps/runtime. Dart70.3 independently next; no isolated emitted, full regex/domain/context/portable admission23.4 or general isolation claim. Dependency warnings remain opaque/upstream-owned.

`Engine::is_ordinary_string_predicate_result_chain` in `rust/linkedspec-runtime/src/engine.rs` joins both direct and trailing-with guard admissions. Existing `Expr::RegexLiteral { pattern }` is not a StringLiteral or a new runtime value kind. Public AST shape and the actual missing matches members distinguish that operand omission from a regex evaluator/flag bug. Source and prefix arities constrain the final positional regex operand to free index1/receiver index0.

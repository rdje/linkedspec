---
id: perl-explicit-push-result-fluent
title: Perl push snapshots initialize ordinary fluent result dispatch
answers:
  - "why did push last uppercase fail while copy and with chains worked"
  - "which Perl owner initializes fluent push results"
  - "does fluent push execute its source before consumer rebinding"
  - "does fluent push change logical copy or with semantics"
date: 2026-10-31
status: bounded Perl58.1.2 targeted-checked; peers/full admission separate
tags: [perl, push, fluent, array, scope, values]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.58.1.2; push-fluent-perl-intake.json.gz retains unchanged10groups7healthy/3RED to10GREEN, closest read6/syntax and actual producers/source/inputs."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/push_result_fluent.t t/push_result_selection.t"
---

Atbfcf0ccb4 full12 is ready/raw0 yet plain push.last.uppercase invokes undefined
host uppercase. Eager source/consumer local returns and function-local String
push chains compile-fail. Other copy/logical/with/Array-Hash-Number/error/shape
controls already work, not missing consumer implementations. emitted_result_chain
does not recognize push itself; nonaggregate semantic value initialization falls
back rather than using the complete existing push owner.

Two additions reuse _ordinary_explicit_push_result_source/_lower_push_statement
in semantic prefixes and current emitted-result/default-result dispatch. Existing
logical/copy folding can consume the same typed source; no new method table or
source policy. Original push/aggregate/read/selected/parser/arity/child/deferred/
copy/mutation/schema and remaining owner bytes stay exact. Six healthy value
observations/original source error row byte-equal; full12, SC/once-only source
before consumer rebinding/local returns/function caller scope pass. New10groups
7healthy/3RED to10GREEN, nearest read6/eight AST-error exclusions/syntax pass.

Regenerate affected emitted Perl parsers. New normal/full fixture canonical
registration remains23.4.1. All bounded Perl58 outcomes are recorded; independent
Rust58.2 and later peers/full23.4 remain separate.

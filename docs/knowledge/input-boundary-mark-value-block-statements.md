---
id: input-boundary-mark-value-block-statements
title: Perl ordinary value blocks share original input-boundary mark statement bodies
answers:
  - "why does mark_input_end inside a String block generate invalid Perl"
  - "can mark_input_start and mark_input_end run as ordinary block statements"
  - "does an input-boundary mark statement change cursor or capture boundary"
  - "which factory owns Perl input-boundary mark statement bodies"
  - "why do bare Unicode mark names work but remain unready on Perl"
date: 2026-10-28
status: bounded42.4 repaired;42.1/42.2 name roles and42.3 Unicode/wider admission remain
tags: [perl, marks, statements, blocks, source, readiness, functions]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.42.4 at clean351ac1214; input-mark-value-block-intake.json.gz retains public source/control, initial/candidate/refined producers/results, final9 and isolated appended1, nearest2, module syntax and exact original two body identity."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/input_mark_value_block_statements.t"
---

Ordinary value blocks previously lacked a nonfinal input-boundary statement
handoff. Late native expansion left do{mark_write...} inside raw Hash braces in
cat's initializer; native handlers/fresh load failed despite ready1. The shared
Contracts::_input_boundary_mark_statement_expr now feeds unchanged native
callbacks and narrow AST/text statement owners after function guards.

Both native/public body strings are byte-identical. Final nine scoped test groups pass,
covering input-start/end, zero snapshot, unchanged cursor/capture boundary, lazy
skip, local returns, numeric word0 and specific function fences. An appended
isolated source1 separately passes with no prior mark writer, proving fresh
runtime/trace dependencies. Exact unchanged9 prefix and test-scope subtraction
are retained; no final10 combined run is claimed. Nearest reset/named2 pass.

The initial10 has8 failed groups; candidate fixes values but leaves an invalid
Unicode ready1 expectation in one group. Bare τέλος already returned6 native/
fresh outside blocks with raw2/ready0. RawDependencies reports two raw argument
spans because AST variable parsing is ASCII. The repaired block returns ok/6
with the same qualification. Its portable-ready expectation is removed from
normal scope, not blessed;42.3 owns symbolic role/domain admission before full23.4.
No String-name, writer-as-data/fluent, deferred, alias/schema or frame grant.
42.1 can now implement its eager name2-moves-begin oracle against valid blocks.

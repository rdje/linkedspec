---
id: perl-boundary-quoted-marker-current-oracle
title: Current Perl quoted boundary marker remains literal without moving the cursor
answers:
  - "why did nested_boundary_quoted_labels quoted-marker fail after the emitted catalog repair"
  - "is the historical quoted boundary marker compile failure still current"
  - "does a quoted capture_until_boundary string execute the helper"
date: 2026-10-29
status: stale current oracle repaired in TYPE37; broader lexical ownership remains separate
tags: [perl, boundary, quoted-source, oracle, regression]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.37 packet perl-emitted-boundary-catalog-intake.json.gz retains canonical old/new four-pair dump/nodump matrix, exact origins/hashes, restored candidate bytes and current test PASS."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/nested_boundary_quoted_labels.t"
---

The immutable October6 case expected rule_handler_compile for the assignment
body = "capture_until_boundary(end)"; return(body). Exact committed baseline
18478841f6acb176dc45eb3cc1eec7022c25d948 instead returns that String literally,
cursor0, without an error. The current emitted-catalog change does not introduce
that behavior: old/new Compiler.pm and ActionIR/Contracts.pm in all four canonical
file combinations, with/without source dumping, agree. Candidate files were
restored byte-exactly. The initial @INC overlay failed module-origin validation
after Get and receives no baseline credit. No historical fix identity is inferred.

Only the current ordinary test t/nested_boundary_quoted_labels.t changes its
quoted-marker branch to assert exact literal/cursor0/no error. Immutable case
JSON and claim records remain byte-identical. The corrected current28groups pass;
no broader quoted/comment-source membership closure is claimed. Existing
SPEC-LANGUAGE-SELF-CONTAINMENT .7.2.2 remains the broad owner, as documented in
[[perl-boundary-call-lexical-serialization]].

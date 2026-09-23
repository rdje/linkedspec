---
id: rust-outer-action-source-fidelity
title: Rust outer block collection normalizes source before ActionIR parsing
answers:
  - why does Rust action source lose CRLF before compilation
  - why do direct CodeBlock and whole spec action spans differ
  - does Rust outer block collection retain indentation and blank lines
  - which task repairs Rust outer action source preservation
date: 2026-09-23
status: confirmed source-fidelity defect; immediate repair SESSION-STARTUP-READING.47.2
tags: [rust, parser, source, spans, crlf, mutation]
evidence: "SESSION-STARTUP-READING.47.1 exact whole-spec assertion fails in runtime-green.log: CRLF becomes LF; both direct CodeBlock modes retain the original text. The suite has 179 passing library tests and 11 passing mutation tests plus that one failure. This is not a green full-suite result."
reverify: "Run the whole-spec source-retention regression owned by SESSION-STARTUP-READING.47.2; .47.1 separately verifies caller-supplied verbatim SpecFile action code through the mutation contract target."
---

The public outer parser collects `source.lines()` in
`rust/linkedspec-core/src/parser.rs::parse_spec`, discarding line terminators.
`consume_block_from_rest` trims block line fragments and rejoins them with LF;
its callers also trim remaining physical-line suffixes. This occurs before
`CodeBlock` parsing and compilation, so a correct compiler cannot reconstruct
the original CRLF or indentation from that input.

The observed action is `tree . map_leaves! (\r\n) { return(value) } . count_keys()`
after a Unicode prefix. The retained compiled source instead contains `\n`.
Direct `CodeBlock` parsing retains exact supplied source and scalar spans.
The caller-supplied `SpecFile` action-code seam isolates compiler/carrier fidelity
from this independent outer capture defect; it does not prove whole-spec fidelity.

The first whole-spec failure remains recorded in
`.linkedspec-data/scratch/mutation-arguments47/runtime-green.log` and the owning
task. Its expected CRLF must not be weakened to normalized LF. Repair `.47.2`
follows the clean validator commit immediately, with canonical closeout `.47.3`.
Compact-call, header-suffix and regex-brace defects retain `.52`–`.54` ownership.

Additional actual quoted-newline probes reject in both native Rust and Perl
`Get`; the Perl probe subsequently called an undefined parser. Those observations
do not establish accepted string-value corruption or backend equivalence.

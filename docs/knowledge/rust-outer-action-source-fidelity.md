---
id: rust-outer-action-source-fidelity
title: Rust outer action collection preserves internal source and closing-line origins
answers:
  - why does Rust action source lose CRLF before compilation
  - why do direct CodeBlock and whole spec action spans differ
  - does Rust outer block collection retain indentation and blank lines
  - which task repairs Rust outer action source preservation
  - why do Rust compact header strings lose spaces or tabs
  - why does a Rust block on a closing line skip its first continuation statement
date: 2026-09-23
status: repaired and verified under SESSION-STARTUP-READING.47.2; .47.3 closes the parent with required canonical receipt
tags: [rust, parser, source, spans, crlf, mutation]
evidence: "Historical whole-spec CRLF failure, compact-header literal corruption and skipped continuation are independently reproduced. The repaired complete Rust component gate exits0: core238, every runtime target, storage oracle and CLI66x2 pass. Final native25 passes against SHA256 2025d1ce7556aaae4b5ef516344ed7054e7620bc51d7f454c778938279464be4. Exact logs live under .linkedspec-data/scratch/action-source47-2/."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core --test action_source_fidelity; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test action_source_fidelity --test map_leaves_mutation_contract; bash tools/run_rust_local.sh"
---

The repaired public outer parser in `rust/linkedspec-core/src/parser.rs`
uses `split_terminator('\n')` to retain CR, preserves raw block fragments and
trims only the complete interior. Accepted internal LF/CRLF, blank lines,
indentation and trailing physical-line whitespace survive into action code.
ActionIR coordinates remain relative to that collected, outer-trimmed code;
this does not introduce absolute file spans or multiline string syntax.

Before repair, `source.lines()`, per-line trimming and LF joining discarded
source before `CodeBlock` parsing and compilation. A later stage cannot
reconstruct source removed by an older parser: rebuild affected source ASTs,
compiled JSON and generated modules from the original `.spec`.

The historical action was `tree . map_leaves! (\r\n) { return(value) } . count_keys()`
after a Unicode prefix. The old compiled source instead contained `\n`.
Direct `CodeBlock` parsing retains exact supplied source and scalar spans.
The caller-supplied `SpecFile` action-code seam isolates compiler/carrier fidelity
from this independent outer capture defect; it does not prove whole-spec fidelity.

The first whole-spec failure remains recorded in
`.linkedspec-data/scratch/mutation-arguments47/runtime-green.log` and the owning
task. Its expected CRLF must not be weakened to normalized LF. Repair `.47.2`
follows clean validator commit `a6ff64e569a040de62a404bea568dda11a8a844c`, with canonical closeout `.47.3`.
Compact-call, header-suffix and regex-brace defects retain `.52`–`.54` ownership.

Additional actual quoted-newline probes reject in both native Rust and Perl
`Get`; the Perl probe subsequently called an undefined parser. Those observations
do not establish accepted string-value corruption or backend equivalence.

## Compact-header literal corruption confirmed during repair

A distinct pre-repair accepted-value probe confirms that `Top:: E{return("a  b")} /x/`
returned `"a b"`; an actual tab also became one space. Moving the same action to
the following body line retains `"a  b"`. All three native CLI processes exit zero
with compile/invoke success. Exact commands/results are retained in
`.linkedspec-data/scratch/action-source47-2/header-literal-before.jsonl`.

`parse_rule_header_fields` takes a mode candidate up to the first whitespace.
For unrecognized candidates, the old `parse_rule_header` rebuilt the body with one space
between that candidate and the rest. A candidate can end inside a quoted literal
in compact header code. Repair `.47.2` therefore retains the original post-colon
slice and verifies exact literal values, as well as CRLF and block coordinates.
The earlier rejected multiline-quote probes remain separate observations.

## Closing-line origins can skip authored statements

The first `.47.2` component attempt passes 201 core library tests and four new
source groups, but the remainder group loses its first continuation line. A native
control with an `I` block closing where `E` begins returns 3 after the E body
authors `note = 3;`, then `note = 4;`, then `return(note)` on successive lines.
Exact source and successful trace: `.linkedspec-data/scratch/action-source47-2/remainder-value-before.jsonl`.

The braced collector advances its cursor past the closing line but returns a
suffix from that closing line. Reusing the advanced cursor as the suffix origin
skips the next line when collecting its block. The existing attached-conditional
helper already distinguishes these positions through `block_remainder_origin`;
`.47.2` applies that distinction to body/header element loops and gives multiline
fluent collection the same past-consumed-lines cursor contract. Six core groups
and a native/serialized/generated assignment-value regression verify the repair.

## Verified boundary

The complete Rust component gate passes with 238 core tests, 179 runtime library
tests, every runtime integration target, managed storage proof and both 66-case CLI
environments. Six source-fidelity groups include 88 combinations of LF/CRLF,
header/body, default/AND and lifecycle/edge/shorthand blocks, exact remainder
origins, fluent closing-line origins, scalar spans, outer trim and EOF controls.
Two runtime groups verify 15 literal values and the formerly skipped assignment
through native, source-AST serde, compiled serde and generated plans. All 12
mutation tests pass, including exact whole-spec and programmatic action text
through independently compiled emitted consumers. The staged consumer target
passes in 471.20 seconds; all jobs are consumed.

All 25 native controls pass against the final gate executable, including the exact
integration-guide example returning 4, compact-header spaces/tabs and retained
malformed/quoted-newline rejection. The neutral authority remains byte-identical
with 167 base and 592 composition mutations rejected. Book rendering and public
no-drift checks pass. This focused leaf does not claim canonical repository CI;
.47.3 closes that boundary only with an exact staged canonical receipt; its commit
and promoted receipt retain acceptance. `.49`, `.52`–`.54` and `.58`/`.59` remain separate.

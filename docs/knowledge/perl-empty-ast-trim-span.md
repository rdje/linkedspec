---
id: perl-empty-ast-trim-span
title: Whitespace-only public AST intervals are ordered after leading trim
answers:
  - "why does a whitespace-only AST expression have an inverted source span"
  - "what owns the empty AST trim span defect"
  - "does the native AST input-frame change cause reversed empty public intervals"
  - "how can the original empty source-span failure be reproduced"
date: 2026-10-09
status: resolved by .2.1.2.4; original diagnosis retained
tags: [perl, actionir, ast, source-span, defect, trim]
evidence: "Repair .2.1.2.4 retains original18 semantic RED/47 controls, final65 assertions/four effective source inverses,12 consumers/three Toolbox routes/eight evidence controls. Historical SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0 retains original0d52a407 and live actual public AST observations:4 authored inputs per route,3 inverted whitespace-only intervals per route and a narrow trim-helper intervention."
reverify:
  - "perl -Iperl -MLinkedSpec::ActionIR::AST -MJSON::PP -e 'print JSON::PP->new->canonical->encode(LinkedSpec::ActionIR::AST::parse_action_expr(q{  }, {base_start => 7}))'"
  - "Original/live exact source and intervention captures: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0-empty.json; original producer is the adjacent -empty-probe.py."
---

# Actual public empty-span invariant failure

At original `0d52a407c4c508cfb00d45765471f741a10de616` and the native-frame
candidate, `LinkedSpec::ActionIR::AST::parse_action_expr(q{  }, {base_start => 7})`
returns an empty raw_perl node with `{start => 9, end => 7}`. Empty input itself
returns `[7, 7)` correctly. Two spaces, CRLF and a five-character whitespace string
including U+2003 each produce an inverted public interval on both routes. The
independent ordered-interval oracle therefore observes six product RED rows; the
probe commands themselves succeed and report these values.

Actual `_trim_with_offsets` returns `['', base + length(input), base]` for the
nonempty whitespace strings. Its source measures the entire input independently
as both leading and trailing whitespace, subtracting the trailing edge after all
characters were already removed at the leading edge. A narrow dynamic intervention
changes only a reversed end to its returned start; all four inputs then have the
independently expected ordered zero-width interval on both original/live routes.
The defect predates the native-frame addition. Actual helper/caller locations,
commands, exits, full channels and production hashes are retained in the probe.

The repair limits trailing whitespace to the characters remaining after leading
trim. Whitespace-only input therefore retains an ordered zero-width public span
at `base_start + length(input)`; two spaces at base7 now produce `[9, 9)`.
Empty or undefined input produces `[base_start, base_start)`. Nonempty inputs
retain their existing trimmed text and interval; whitespace inside literals remains
part of the literal. Expression and statement facade routes share the correction.

The resolved P1 owner is `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4` in
`docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`. Its same65-assertion fixture fails18
public whitespace assertions on original e0eb while47 native/nonempty controls
pass, then passes all65 with the two-line correction. Four valid source inverses
restore double trimming, choose a wrong zero-width anchor, drop the public base
or consume a nonempty body; each reaches a distinguishing semantic failure.
Twelve direct suites, three actual Toolbox lowering routes and eight independent
evidence controls pass. Exact producers/channels/bindings are adjacent to
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4-review.json`.

Impact was the public AST source-interval invariant. Broader runtime failure is
not claimed. Native parser-input frames independently retain ordered zero-width
spans after leading whitespace, so public coordinates grant no compiler-source
authority. The earlier original/live diagnosis above remains historical evidence;
source-event joining and mapped-runtime acceptance remain separately open.

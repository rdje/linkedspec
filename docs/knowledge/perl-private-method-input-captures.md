---
id: perl-private-method-input-captures
title: MethodExpr input captures bind actual returns and preserve direct aliases
answers:
  - "how do private MethodExpr captures retain actual input authority"
  - "do new input captures preserve callback scalar aliases"
  - "why do legacy MethodExpr frame wrappers still copy scalar arguments"
  - "can copied MethodExpr captures or arrays select original argument frames"
  - "which consumer artifacts belong to the MethodExpr capture proof"
date: 2026-10-09
status: standalone MethodExpr input captures verified; compiler-event joining open
tags: [perl, actionir, methodexpr, csv, callbacks, identity, source-provenance]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1 verifies107 supplied assertions/13 effective source inverses,14 supplied consumer suites,3 actual Toolbox routes,3 actual missing-artifact REDs and10 reason-sensitive evidence controls."
reverify:
  - "PERL5LIB= prove -v -Iperl t/actionir_method_input_captures.t t/actionir_method_argument_source_frames.t"
  - "Exact source/fixture/inverse/artifact producer and original supplied input identities: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1-review.json and its claim."
---

# Actual captures and direct argument aliases

`MethodExpr::_with_input_captures` owns an invocation-local strong registry.
`_capture_method_input` and `_capture_csv_input` call their actual callback once
in scalar context and return its unchanged value under `value`. A reference to
the remaining original arguments preserves direct scalar aliases and reference
identity. Successful caller error state and fatal exception identity stay exact.
The existing `_parse_method_with_source_frames` and `_split_csv_with_source_frames`
wrappers deliberately keep their copied local argument semantics; shared internal
collectors accept either argument-reference form without changing old callers.

`_argument_input_for` requires the actual scope/capture/callback/returned object
and argument array, plus an unchanged array length and indexed raw value. Method
results must also retain their original argument-array reference and the captured
method/source_method/source fields. Copies, opaque/foreign returns, changed roots,
expired or foreign nested scopes decline. A changed argument declines individually
while its unchanged neighbor retains its original occurrence. Returned frame
hashes/spans are detached descriptions; mutating them cannot change the registry.

Frames come from the actual CSV producer's retained flush occurrences, including
omitted empty slots, and explicit parser payload/leading-trim offsets. The test's
Unicode, CRLF, repeated, nested-call and quoted-comma expectations are accumulated
from authored pieces independently of parser searches. Nested same-scope captures
and nested successful/fatal scopes restore the outer collector and registry.
These are original **parser-input descriptions**, not compiler-event SourceOrigins
or permission to copy/consume compiler source. Event joining remains `.2.1.2.2`.

The original interface RED establishes availability only;13 final valid source
inverses establish semantics. An initial invalid no-method-fields mutation is
retained as a rejected syntax control. The initial broad live consumer manifest
also omitted three checkpoint JSON inputs; its passing transcript stays a draft.
The final14 suites run in a supplied tree with Perl/spec, selected tests and all
three actual JSON artifacts, with before/after content and population equality.
Actual omission of each JSON makes its unchanged reader fail. Ten independent
record corruptions reject failed/forged/incomplete evidence. Standard read-only
Perl/prove modules and project-volume TMPDIR are reused; complete Phase0, toolchain
reproduction and mapped/canonical admission are not established.

The same known artifact-binding gap in earlier finite supplemental captures is
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5`, now verified with three explicit historical
gap entries and complete current recurrence; see
`docs/knowledge/private-consumer-artifact-binding-audit.md`. No current
hashes retroactively bind original per-read artifact bytes. Original standalone
fixture/inverse proof remains separate; the broad historical audit stays startup `.5`.

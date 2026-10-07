---
id: perl-compiler-source-membership
title: Perl compiler helper collection selects original executable occurrences
answers:
  - "where does compiler helper collection exclude quoted source occurrences"
  - "does compiler membership change the ordinary syntactic scanner API"
  - "why can a repaired quoted literal still have unresolved helper diagnostics"
  - "which tests prove compiler membership and native fresh quoted values"
date: 2026-10-07
status: compiler integrated; callable signature correction and canonical acceptance remain open
tags: [perl, actionir, compiler, source-membership, diagnostics, provenance]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1 retains original public producers, before/after channels and literal oracles/RED. Independent .0.2.2 recurrence reconstructs clean864b1a939 without overlays, preserves every public channel and original consumer plan, within the original bounded population. Canonical CI exposes a callable signature membership regression; acceptance remains open. Later source repairs and backend admission remain separate."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_compiler_source_membership.t t/actionir_executable_source_membership.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1-review.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-review.py"
---

EmitContext::_scan_contract_ir_events delegates to the compiler-only
Scanner::_scan_executable_contract_ir_events entry, with the same real scanner
dependency bundle. Scanner's trace/error wrapper obtains original
ScannerCore::_scan_contract_ir_events_with_provenance results and passes them to
SourceMembership. Diagnostics then receives the original selected event array;
event and argument references, source, family/occurrence order and public shapes
are preserved. The ordinary Scanner::scan_contract_ir_events API still returns
the original unfiltered syntactic observations. Compiler discovery does not parse
masked source, infer equal-raw occurrence pairs or substitute fake dependencies.

Full-tail numeric slash recognition can reject a call followed by a newline and
a different statement. Generic pattern scanning would then consume the later
host quote's slash and exclude its real assignment origin. The retained regression
probe shows that exact range and lost event. SourceMembership now applies the same
existing discriminator through the original call's following newline when needed;
helper pattern roles retain precedence. Original LF/CRLF host-quote-after-division
compatibility returns7. No MethodExpr, splitter, regex precedence or portable
host-quote grammar change follows.

The original `return("set(counter, 2)")`, nested `cat` and `matches` sources now
preserve their independently authored values on native and fresh emitted routes.
The retained original public corpus is broader than those fixes; the reviewer
reports its exact repaired and remaining source IDs. `unsupported_nested` and
`raw_operand` deliberately have no original successful-value oracle; retain
their full channels and disclose that limit rather than inventing expectations.
Scanner lexical controls
are not new executable grammar admission or arbitrary callback coverage.

Unresolved-pattern scanning still examines lowered text. Preserving helper-looking
data can therefore expose an unresolved-helper count that corruption previously
removed. A correct value is not readiness acceptance. Diagnostic marker/text
origin remains .7.2.2.1-owned, precise residual replacement .0.3-owned, and source
comments .7.3-owned. Independent committed recurrence .0.2.2.0 verifies its bounded original
population. [[perl-source-membership-callable-signature-precedence]] owns the
new callable regression; corrective .0.2.2.1 and committed canonical .0.2.2.2
are required before membership acceptance.
Its immutable activation inputs contain no overlays or production replacements;
the earlier .2.1 claim remains historical ataf5d19971. Recur the new .2.2
reviewer for current acceptance rather than refreshing the old publication inputs.
Actual working permissions are separate from Git executable mode; retrieve
[[project-root-evidence-filesystem-modes]] before checking current-root inputs.
The immutable capture normalizes and guards full snapshot permissions. Acceptance
checks original root bytes and Git executable bits without chmod.

Initial test identity/regex expectations and a book review of smart apostrophes
were instrument errors. Their original producers, rejected channels and exact
corrections are retained. The initial public reviewer also wrongly required
an expected value for the two unassessed controls; its KeyError is retained and
recurred independently. These do not establish product defects or authorize
suppressing diagnostics. The known wrapper startup warning retains startup .7;
no recovery or purge is authorized.

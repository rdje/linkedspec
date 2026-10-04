---
id: perl-helper-source-provenance-channel
title: Three Perl scanner contracts retain match spans in a private invocation-local sidecar
answers:
  - "where are helper scanner match positions recorded"
  - "does source provenance add public helper event fields"
  - "which scanner contracts currently have source provenance"
  - "does the private source recorder filter quoted helpers"
  - "how does nested scanner provenance preserve caller error state"
date: 2026-10-04
status: first three-contract implementation; remaining producer families pending
tags: [perl, actionir, scanner, source-provenance, source-span, event-order]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0 owns four source owners, actual13-group provenance RED/GREEN and six exact sources/18 before-after public compiler pairs. Original parser dumps, emissions, diagnostics and event arrays remain identical; private match positions satisfy independent scalar-span oracles."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/actionir_helper_source_provenance.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0-review.py"
---

# Three Perl scanner contracts retain match spans in a private invocation-local sidecar

ScannerCore::_scan_contract_ir_events_with_provenance scopes its recorder per
invocation and returns the original events plus a separate source_origins array.
The public scan_contract_ir_events interface, five family dependency callbacks and
first-defined dispatch order remain unchanged. Normal producer hooks return the
exact original event object without recording or adding public fields.

LegacyRules return_general, PrimitivePipelineRules set_value and FlowRules if_flow
capture match coordinates before nested parsing and record the exact original source
slice. The return scanner matches its existing helper-pattern view but retrieves
raw text from the unmasked source. Unicode coordinates are scalar indices; original
quotes, escapes, CRLF, arguments and supported slash patterns stay intact.

Each private record retains its event object, full current scan input and start/end
span. The collector follows the chosen event array by reference identity, preserving
duplicate occurrence order rather than draining hash keys or globally sorting spans.
Records for an unowned dispatcher do not enter the chosen result. Invocation-local
scoping restores an outer recorder after a nested private scan; OwnerDispatch preserves
caller error state on normal return. Empty and opaque results keep their original shape
and identity and gain no invented event origins.

For `return('return("x")'); return("x")`, actual return matches start at0 and23,
not quoted8. For `text="set(counter,1)"; set(counter,2); set(counter,1); return(counter)`,
actual set matches start at6,23,39. The first is still a quoted syntactic match.
The recorder establishes origin; it does not decide executable membership. Public
substitution, readiness metadata, parser dumps and emitted source remain byte-identical
in all eighteen source/seed comparisons. These probes compile and inspect source;
they do not execute newly emitted source or admit another backend.

Coverage is exactly the three named contracts. Other producers, recursive/argument/
statement source-frame translations and their independent composition remain owned
by the sibling leaves. Executable membership, exact residual replacement, recurring
registration/canonical acceptance, unsupported-marker provenance and source comments
are subsequent work. The existing quoted-value/readiness defects remain unresolved.

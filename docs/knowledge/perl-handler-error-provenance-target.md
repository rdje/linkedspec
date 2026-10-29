---
id: perl-handler-error-provenance-target
title: Native child handler errors require actual invocation provenance rather than parent AST shape
answers:
  - "may a defined Perl parent value clear an actual child runtime error"
  - "how must native Perl distinguish actual handler failure from stale context"
  - "does a valid collection containing null imply a Perl runtime error"
  - "which target preserves native direct failure and next-call recovery during nested error repair"
date: 2026-10-29
status: bounded41.0 target/41.1 native repair focused-verified; named47/referenced-blind48/Phase0 owner45/selection/full admission separate
tags: [perl, errors, provenance, context, recovery, collection, generated]
evidence: "TYPE41.0 perl-nested-error-authority-intake.json.gz retains9-source/22-call native/separate emitted proof,12 actual nested losses,2 preserved direct errors,8 healthy values and six canonical groups75 nested assertions plus discovery."
reverify: "Recover probe_perl_nested_error.pl/fresh.pl and read_perl_nested_error.py from the41.0 packet; use project-routed Perl/Python and frozen tests/fixtures/nested_handler_error.json. Read nested-handler-error-provenance-authority.md before41.1."
---

Compiler clears runtime_handler context solely because a parent AST is defined.
Actual Value callback failure can therefore disappear into[null],[[null]] or
an explicit[override]. A healthy deep nonmatch also returns[[null]], and valid
match_text absence returns[null]; return shape cannot determine error provenance.
Current9-source/22-call native/separate emitted controls have12 native losses,
2 healthy direct failure-channel and8 healthy value/nonmatch/reuse observations.
Fresh emitted reports all14 actual errors with existing top wrapper envelope.

Existing book diagnostic fallback preserves richer lower-level payloads. Real
handler failure must survive with original typed detail/object/child attribution
and existing direct undef/inner-eval/context surface. Synthetic stale-context
success is a distinct established compatibility case; six exact canonical groups
pass75 nested assertions plus discovery, including real-error next-call recovery.
Private invocation-local provenance stays within existing error owners; no public
field/schema/throwing policy, helper grant or null-container rejection follows.

Target nested-handler-error-provenance-authority.md and qualified fixture freeze
41.0 before41.1 production. Initial deep referenced-no-regex compilation fails
separately, owned48; qualified deep error source uses direct calls. Four nonmatch
candidate expectations changed[null] to actual[] before freeze, with source/input/
observations unchanged. No product error credit for setup epochs. Deferred helper
readiness31.6.4.4, named47/referenced-blind48/Phase0 owner45 and admission separate.

2026-10-29 bounded41.1 now preserves actual invocation-local handler failure
identity through RuntimeContext/SpecEntry/Compiler.12 nested losses repaired,
2 original direct failures/8 healthy observations retained; normal original-object
and no-slot-leak checks pass. Three selected files30 groups/six canonical groups75
nested assertions plus discovery and module syntax pass. Source/rewriter/emitted/
all fresh outcomes/metadata exact; NONE timestamps alone normalized for direct/
forced-compile controls. [[perl-invocation-handler-failure-provenance]] retains
closure. No public schema/helper/throwing/generation change;47/48/45 and broader
readiness/host isolation/selection/full admission remain independent.

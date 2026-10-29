---
id: perl-collecting-parent-runtime-error-loss
title: A defined Perl collecting parent clears a real child runtime error
answers:
  - "why does a Perl callback failure return null without last_error in a collecting parent"
  - "why does native Perl clear a child runtime_handler error"
  - "which task owns nested Perl error delivery through defined parent values"
date: 2026-10-28
status: bounded41.0 target/41.1 native repair focused-verified; named47/referenced-blind48/Phase0 owner45/selection/full admission separate
tags: [perl, errors, callbacks, context, collection, generated]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.35.1 retains exact six-source intake/native/fresh bytes and focused public runtime trace in capture-reset-value-block-perl-intake.json.gz."
reverify: "Recover probe_capture_reset_native_error.pl; use tools/project_data_run.sh env PERL5LIB= perl -Iperl. It enables debug only after Get compilation; inspect rule_handler_eval:Value and invoke_top_rule:Top context."
---

The explicit matched Value[2] action creates/invokes a literal callback containing
excluded start_capture_slice(). Fresh emitted execution raises typed generated
error/detail unknown_helper/name. Native Value fails, but its Top collecting
parent returns[null], with empty thrown error and runtime_ctx_ref last_error null.
Four exact literal/registered canonical/alias cases show the same value/error
distinction in the finite intake. No new helper vocabulary is authorized.

Public runtime-only debug shows rule_handler_eval:Value skipped after the actual
failure, then invoke_top_rule:Top reports a defined AST and clears the purportedly
stale runtime_handler context. SpecEntry::_build_runtime_handler catches the real
exception, records typed context and returns undef. Compiler's public parser
wrapper clears that context solely because the parent AST is defined. A defined
Array containing a failed child does not establish recovery. These tool/source
facts identify error delivery rather than a capture-reset producer problem.

Owner41 freezes provenance-aware error/recovery authority and direct/nested/
collecting/legitimately handled controls before repair. Preserve actual typed
detail and rule attribution; do not remove valid recovery by guessing or reject
ordinary null values. Deferred false-ready metadata stays31.6.4.4; the ordinary
reset statement fix35.1 grants neither deferred vocabulary nor silent-null credit.

## Qualified target41.0 (2026-10-29)

Independent9-source/22-call current native/separate emitted intake confirms12
native nested losses,2 preserved direct errors and8 healthy null/nonmatch/reuse
observations. Fresh reports all14 errors. Six exact canonical diagnostic/recovery
groups pass75 nested assertions plus discovery, including synthetic stale-context
success and actual-error next-call recovery. [[perl-handler-error-provenance-target]]
freezes private actual-failure provenance, original detail/child attribution and
existing direct undef/inner-eval/context surface before41.1. No production repair
yet. Initial intermediate-no-regex build gap is separately owned48 after41/47,
before45/wider features/admission; qualified deeper source uses direct calls.

2026-10-29 bounded41.1 now preserves actual invocation-local handler failure
identity through RuntimeContext/SpecEntry/Compiler.12 nested losses repaired,
2 original direct failures/8 healthy observations retained; normal original-object
and no-slot-leak checks pass. Three selected files30 groups/six canonical groups75
nested assertions plus discovery and module syntax pass. Source/rewriter/emitted/
all fresh outcomes/metadata exact; NONE timestamps alone normalized for direct/
forced-compile controls. [[perl-invocation-handler-failure-provenance]] retains
closure. No public schema/helper/throwing/generation change;47/48/45 and broader
readiness/host isolation/selection/full admission remain independent.

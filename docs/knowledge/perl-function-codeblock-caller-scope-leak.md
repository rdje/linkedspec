---
id: perl-function-codeblock-caller-scope-leak
title: Perl pure-function callbacks inherit unrelated rule-caller slots
answers:
  - "can a callback invoked by a pure function read the outer rule caller"
  - "why does a Perl function callback leak rule bindings"
  - "which task owns fresh function callback working frames"
  - "is the function callback scope leak the startup32 argument shadow defect"
date: 2026-10-02
status: verified P1 defect; repair scheduled before registered-function bridge
tags: [perl, codeblock, user-functions, scope, language-readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.0 diagnosis checkpoint preserves three exact native/fresh emitted sources, values, metadata, producer hashes and unchanged authorities."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/selfcontain13302/diagnosis.pl"
---

The admitted pure-function contract creates fresh function-local parameters and working variables.
A deferred callback uses its invocation-time caller, so a callback invoked inside a function must see
that function's frame. It must not implicitly capture unrelated rule bindings.

On clean eedf599c0, `fn apply(callback: codeblock) { return(callback()) }` called by a rule with
`secret="outer"` and `cb={|| return(secret) }` returns `"outer"` instead of null. Declaring
`secret="local"` in apply returns `"local"`; a direct function read of secret returns null.
All three native Get and independent fresh emitted controls agree, with ready1/raw0/fallback0/
unresolved0 and no context error. Exact sources and producer identities are in the checkpoint.

`_user_function_deps_with_call` shallow-copies the caller's `bare_symbol_names` inventory.
`_codeblock_runtime_binding_expr` includes those scalar references before adding function locals.
The generated invoke therefore passes callback/cb/secret references explicitly. Both helpers are
byte-identical to c02129217, before the deferred-push repair; this is a preexisting mechanism,
not a claim that the old base was executed.

Repair `.1.3.3.0.2.0.1` must exclude unrelated caller slots, preserve actual function parameter/local
references, retain callback-created working slots across callbacks within one invocation, and reset
those slots across fresh invocations. Keep copied callback parameters/restoration and rule callbacks
correct. The plain eight-field record gains no closure or stored environment. Verify writes, nested
calls and actual identities before closing the prerequisite and implementing bridge `.1.3.3.0.2.1`.
Startup32's argument/local shadowing is a different defect and remains owned, as do startup19/35/87.

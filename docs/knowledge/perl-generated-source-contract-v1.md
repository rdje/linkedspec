---
id: perl-generated-source-contract-v1
title: Perl emits independently loadable generated-source v1 with validated family plans
answers:
  - "how do I emit standalone Perl source from LinkedSpec"
  - "what functions does generated Perl source expose"
  - "how are Perl dependency regex indexes preserved in emitted source"
  - "does legacy parser_source_ref match emit_generated_source"
  - "how does Perl generated source validate family plans"
  - "what trace roles does generated Perl expose"
date: 2026-07-11
status: superseded
tags: [perl, generated-source, public-api, LinkedRE, trace, diagnostics]
evidence: "FUTURE-PARITY-BACKLOG.3.1.2 adds LinkedSpec::emit_generated_source, perl/LinkedSpec/GeneratedSource.pm, Compiler.pm reconstruction from compiled dependency_refs, and t/generated_source_contract.t. Public and legacy captures are deterministic and byte-identical. Independently evaluated source exposes Execute, ExecuteWithTrace, LinkedSpecGeneratedMetadata, LinkedSpecGeneratedPlan, and ValidateGeneratedPlan; exact result, arbitrary-package loading, indexes 0/1, slash regex, identity, generated_rule_enter/family_decision/rule_exit, four rejection codes, and structured emission/execution failures pass. Existing generated trace suites pass; Phase 0 reaches 1..1030."
evidence_update_2026_07_11_admission: "FUTURE-PARITY-BACKLOG.3.1.3.3 repeats focused 69-assertion contract proof and the canonical Perl gate including Phase 0 1..1030 and 61x2 CLI, promotes the generated-source state to pass, and closes .3.1."
reverify: "perl -c perl/LinkedSpec/GeneratedSource.pm && perl -c perl/LinkedSpec/Compiler.pm && PERL5LIB= prove -Iperl t/generated_source_contract.t t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t && rg -n 'emit_generated_source|LinkedRE::oredRE|ValidateGeneratedPlan|ExecuteWithTrace' perl/LinkedSpec.pm perl/LinkedSpec/GeneratedSource.pm perl/LinkedSpec/Compiler.pm t/generated_source_contract.t"
---

# Perl Generated-Source v1

This card records the admitted historical Perl v1 boundary. New Perl emission
is v2 as of `FUTURE-PARITY-BACKLOG.9.1.3.4`; see
[[perl-generated-source-contract-v2]]. Existing v1 artifacts must be regenerated
from `.spec` rather than treated as current emit output.

Application code emits deterministic source through:

```perl
my $source = LinkedSpec::emit_generated_source(
  \$spec,
  source_identity => 'logical/path.spec',
  parse_mode => 'consume',
);
```

The older `Get` generate/dump/capture options produce identical text. Generated
source reconstructs dependency alternations by invoking `LinkedRE::oredRE(...)`
over the referenced rule regexes when the module loads. It no longer serializes
the compiled alternation's dynamically scoped index markers.

The loaded package exposes `Execute`, `ExecuteWithTrace`, metadata/plan readers,
and `ValidateGeneratedPlan`. Plan count/label/family/unknown-family drift is
rejected before execution as an attributed `generated_source_error`. Debug trace
contains generated rule enter, family decision, and rule exit semantic roles.

The implementation completed under `.3.1.2` and its separate `.3.1.3.3`
admission promotes Perl generated source to pass.

Related facts: [[generated-source-contract-v1]],
[[perl-generated-source-capture-not-standalone]], [[handler-ir-design]].

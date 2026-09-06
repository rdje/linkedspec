---
id: perl-typed-error-json-observation-boundary
title: "Permissive JSON encoding can display a retained Perl typed error as null"
answers:
  - "why does a Perl runtime error detail appear null in JSON output"
  - "does JSON null prove that Get lost a blessed diagnostic object"
  - "how should I inspect a retained Perl typed error before claiming diagnostic loss"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","diagnostics","tooling"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.31. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/RuntimeContext.pm perl/LinkedSpec/SpecEntry.pm"
  - "sed -n '380,423p' perl/LinkedSpec/SpecEntry.pm"
  - "sed -n '343,363p' perl/LinkedSpec/RuntimeContext.pm"
---

# Permissive JSON encoding can display a retained Perl typed error as null

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.31](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

The direct receiver-write control returns a runtime_handler failure. JSON::PP with allow_blessed and convert_blessed displays detail as null, yet the retained detail is LinkedSpec::BindingRuntime::ReceiverMutationError and its code is receiver_mutation_reentrant. The observed class has no TO_JSON method. A small encoding control reproduces null output while retaining the original object's class and code.

SpecEntry saves $@ before further work and stores that object in RuntimeContext before tracing. RuntimeContext preserves the supplied detail. This observation does not establish diagnostic loss or a connection to the lazy trace callback defect.

Inspect the original reference, its fields, and the chosen serializer before inferring data loss from JSON output. Snapshot the optional error/detail first so an observer does not autovivify a successful context. The same blessed-detail pitfall was already recorded under `.3.2.16`; this card makes it directly retrievable after the intake caught a repeated derivation.

Sources: `perl/LinkedSpec/RuntimeContext.pm`, `perl/LinkedSpec/SpecEntry.pm`.

The following managed control was executed during intake; its output establishes the bounded observation above.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec::BindingRuntime -MJSON::PP - <<'PERL'
use strict;use warnings;
my $detail=bless {code=>'receiver_mutation_reentrant'},'LinkedSpec::BindingRuntime::ReceiverMutationError';
my $encoded=JSON::PP->new->canonical->allow_blessed->convert_blessed->encode({detail=>$detail});
print "$encoded\n";
print JSON::PP->new->canonical->encode({
 retained_class=>ref($detail),retained_code=>$detail->{code},
 has_to_json=>$detail->can('TO_JSON') ? JSON::PP::true : JSON::PP::false
}),"\n";
PERL
```

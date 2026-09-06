---
id: perl-dynamic-codeblock-receiver-guard-gap
title: "Dynamic codeblock assignment bypasses the Perl map_leaves receiver guard"
answers:
  - "can a dynamic Perl codeblock assign the active map_leaves receiver"
  - "why does direct receiver assignment fail while a dynamic callback succeeds"
  - "which task owns the CodeblockRuntime receiver-write guard"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","codeblock","mutation"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.19. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/CodeblockRuntime.pm perl/LinkedSpec/BindingRuntime.pm"
  - "sed -n '76,105p' perl/LinkedSpec/BindingRuntime.pm"
  - "sed -n '79,102p' perl/LinkedSpec/CodeblockRuntime.pm"
  - "sed -n '220,242p' perl/LinkedSpec/CodeblockRuntime.pm"
---

# Dynamic codeblock assignment bypasses the Perl map_leaves receiver guard

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.19](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

The public direct-write control hits BindingRuntime::ReceiverMutationError; Get returns null with a runtime_handler error whose detail retains that typed object. A dynamic cb = {|| tree = hash("z","Z"); return("X") } invoked inside tree.map_leaves! succeeds and returns [{"a":"X"},{"a":"X"}] for the result/tree pair, without a runtime error.

CodeblockRuntime::_write_binding writes its resolved scalar reference directly. Its assign_scalar evaluation path does not call BindingRuntime::assert_receiver_writable. The repair must guard nonparameter writes by receiver identity while preserving parameter shadowing, pure-function scope, atomic traversal, and detached results.

JSON::PP allow_blessed/convert_blessed displayed the retained detail object as null; that observation is a serialization artifact, separately indexed by [[perl-typed-error-json-observation-boundary]].

Sources: `perl/LinkedSpec/CodeblockRuntime.pm`, `perl/LinkedSpec/BindingRuntime.pm`.

The following managed control was executed during intake; its output establishes the bounded observation above.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;$|=1;
for my $case (
 ['direct', 'tree = hash("a","A"); result = tree.map_leaves!() { tree = hash("z","Z"); return("X") }; return([result, tree])'],
 ['dynamic', 'tree = hash("a","A"); cb = {|| tree = hash("z","Z"); return("X") }; result = tree.map_leaves!() { return(cb()) }; return([result, tree])']
) {
 my ($name,$body)=@$case;my $spec="Top::\n /x/ -> Top { $body }\n";my %ctx;
 my $parser=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx);die "compile failed for $name" unless ref($parser)eq'CODE';
 my $input='x';my $result=eval{$parser->(\$input)};my $failure=$@;
 print JSON::PP->new->canonical->allow_blessed->convert_blessed->encode({
  case=>$name,result=>$result,exception_class=>ref($failure),exception=>"$failure",context_error=>$ctx{last_error}
 }),"\n";
}
PERL
```

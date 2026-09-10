---
id: semantic-rule-calls-empty-function-gate
title: "Rule call projection is gated by an unrelated function definition on all five backends"
answers:
  - "why do helper-only rules expose no semantic helper binding or call records"
  - "why does adding an unused function change semantic rule call projection"
  - "which backends have the empty-function semantic projection gate"
date: 2026-09-07
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","semantic","perl","rust","dart","julia","lua"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.22. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/SemanticCallProjection.pm dart/lib/src/semantic/semantic_call_projection.dart julia/src/semantic/SemanticCallProjection.jl lua/src/linkedspec/semantic_static_projection.lua"
  - "sed -n '73,110p' perl/LinkedSpec/SemanticCallProjection.pm"
  - "sed -n '100,125p' dart/lib/src/semantic/semantic_call_projection.dart"
  - "sed -n '73,95p' julia/src/semantic/SemanticCallProjection.jl"
  - "sed -n '1820,1840p' lua/src/linkedspec/semantic_static_projection.lua"
---

# Rule call projection is gated by an unrelated function definition on all five backends

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.22](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

The same valid Top self-edge assigns trim(" x ") to value and returns it. Perl, Dart, Julia, PUC Lua, and LuaJIT compile and query it successfully but return no helper/binding/call records. Prepending an unused function changes the result to five ordered records: helper:trim, helper:return, binding:edge:rule:Top:0:value:0, and the two call:edge:rule:Top:0 records. The September 7 .3.3.30 Rust/Perl pair reproduces the same zero-versus-five result on Rust; the other runtime measurements remain the September 6 evidence.

Each measured backend returns early when its function registry is empty, before traversing rule bodies. The Julia I-block control was outside its current edge-only call owner scope and is not evidence of this guard. The repair starts with a frozen-model/digest/carrier impact audit; expected payloads must not be silently adapted.

Sources: `perl/LinkedSpec/SemanticCallProjection.pm`, `dart/lib/src/semantic/semantic_call_projection.dart`, `julia/src/semantic/SemanticCallProjection.jl`, `lua/src/linkedspec/semantic_static_projection.lua`.

The following managed control was executed during intake; its output establishes the bounded observation above.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
my $request={contract=>'linkedspec-semantic-query-v1',operation=>'list',subjects=>[],record_kinds=>['helper','binding','call'],relation_kinds=>[],direction=>'outgoing',page=>{after_id=>undef,limit=>100},budget=>{max_records=>1000,max_relations=>2000,max_depth=>4},source=>{detail=>'identity',include_content_digest=>JSON::PP::false}};
my $body=qq{Top::\n /x/ -> Top { value = trim(" x "); return(value) }\n};
for my $case (['no_function',$body],['unused_function',qq{fn unused(value) { return(value) }\n\n}.$body]) {
 my $index=LinkedSpec::semantic_index(\$case->[1],logical_name=>'reading-probe.spec',source_detail_ceiling=>'text');
 my $answer=$index->query($request);die JSON::PP->new->canonical->encode($answer) unless $answer->{ok} && $answer->{snapshot}{state} eq 'compiled';
 my @records=map {{kind=>$_->{kind},id=>$_->{id},name=>$_->{name}}} @{$answer->{records}};
 print JSON::PP->new->canonical->encode({case=>$case->[0],records=>\@records,diagnostics=>$answer->{diagnostics}}),"\n";
}
PERL
```

## September 7 Rust completion of the census

`SESSION-STARTUP-READING.3.3.30` reads Rust call_projection.rs and confirms its `extend` returns
immediately when compiled.functions is empty, before action-owner traversal. The exact same public
SemanticIndex queries return zero records without a function and five with an unused function, as Perl does.
Both snapshots compile; responses have no diagnostics and both process stderr files are empty.
Fixtures/full responses and identity are retained in `.linkedspec-data/scratch/startup89-semantic-bindings/`.
The independent repeated-binding failure in [[rust-semantic-repeated-binding-identity-gap]] is .66-owned.

## September 10 Dart reading reconciliation

`DART-STARTUP-READING.1.29` reads semantic_call_projection.dart 1-347 and
confirms exact source identity with the intake baseline. Its function-empty
guard still precedes action-owner traversal. The four existing call-projection
tests and six static tests pass, but their finite fixture success does not close
this limitation. No fresh zero-versus-five runtime census is claimed; the dated
Dart measurement and startup .22/.22.1-.22.3 repair boundary remain intact.

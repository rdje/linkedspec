---
id: perl-codeblock-boolean-literal-kind-drift
title: "Dynamic Perl codeblock boolean literals become numeric results"
answers:
  - "why does a Perl codeblock return 1 instead of true"
  - "do dynamic Perl codeblocks preserve boolean literal types"
  - "does a boolean argument remain typed through a Perl codeblock"
  - "where does Perl codeblock evaluation lose boolean literal identity"
  - "which task owns dynamic codeblock boolean result parity"
date: 2026-09-06
status: confirmed-open
tags: [perl, codeblock, literal, boolean, actionir, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.34: six public Get controls, emitted record decoding, and CodeblockRuntime.pm 219–231. The typed AST retains kind=boolean, but _eval_expr returns numeric 1/0."
reverify: "Run the managed public and emitted-record probes below; inspect JSON shape, JSON::PP::is_bool, and context_error."
---

# Dynamic codeblock boolean literal kind loss

The typed-literal contract is [[terse-primitive-literal-parity]]. On 2026-09-06, fresh public Perl `Get`
invocations of `Top:: /x/ -> Top { ... }` over input `x` produce:

| Action | JSON result | Scalar boolean? | Context error? |
| --- | --- | --- | --- |
| `return(true)` | `true` | Yes | No |
| `cb = {\|\| return(true) }; return(cb())` | `1` | No | No |
| `return(false)` | `false` | Yes | No |
| `cb = {\|\| return(false) }; return(cb())` | `0` | No | No |
| `cb = {\|value\| return(value) }; return(cb(true))` | `true` | Yes | No |
| `cb = {\|\| return([true,false]) }; return(cb())` | `[1,0]` | Array of numbers | No |

The parameter control shows that passing an existing typed boolean preserves it on this path. The literal-array
case shows that the mismatch also occurs within a container; checking only truthiness would miss it.

`call_spec_handler_subst` emits a JSON-encoded `codeblock_literal`. Decoding its record shows the two array items
still have `kind: "boolean"`, source `true`/`false`, and their normal AST payloads `1`/`0`. The kind tag is
present before interpretation. `CodeblockRuntime::_eval_expr` handles that kind by returning `$node->{value} ? 1 : 0`,
whereas ordinary ValueExpr lowering emits `JSON::PP::true`/`JSON::PP::false`. The runtime branch loses semantic
boolean identity; AST numeric payload storage by itself is not the defect.

[[SESSION-STARTUP-READING]] `.35` owns the repair after full reading and policy review, including focused
live/generated, nested/argument/contextual, and independently justified neutral proof. The existing
`t/callable_codeblock_literal_contract.t` and `t/inter_match_gap_capture_perl_contract.t` pass a combined
134 top-level tests in this checkpoint; that finite success does not close this independently measured defect.
Other runtimes and independently loaded generated-parser executions were not measured for these controls.
Receiver-guard defect [[perl-dynamic-codeblock-receiver-guard-gap]] remains separately owned by `.19`.

## Public control

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;my $json=JSON::PP->new->canonical->allow_nonref;
for my $case (
 ['direct_true','return(true)'],['dynamic_true','cb = {|| return(true) }; return(cb())'],
 ['direct_false','return(false)'],['dynamic_false','cb = {|| return(false) }; return(cb())'],
 ['argument_true','cb = {|value| return(value) }; return(cb(true))'],
 ['dynamic_array','cb = {|| return([true,false]) }; return(cb())']
){my ($name,$body)=@$case;my $spec="Top::\n /x/ -> Top { $body }\n";my %ctx;my $src='';
my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src);
my $input='x';my $got=ref($p)eq'CODE'?$p->(\$input):undef;
print $json->encode({case=>$name,result=>$got,value_class=>ref($got),boolean=>JSON::PP::is_bool($got)?1:0,context_error=>defined($ctx{last_error})?1:0}),"\n";
}
PERL
```

## Emitted typed-record control

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
my $lowered=LinkedSpec::call_spec_handler_subst('Top','cb = {|| return([true,false]) }; return(cb())');
my ($hex)=$lowered =~ /pack\("H\*", "([0-9a-f]+)"\)/;die 'missing emitted record' unless defined $hex;
my $record=JSON::PP->new->utf8->decode(pack('H*',$hex));
my $items=$record->{body_ast}{statements}[0]{expr}{args}[0]{items};
print JSON::PP->new->canonical->encode({record_kind=>$record->{kind},literals=>[map {{kind=>$_->{kind},source=>$_->{source},value=>$_->{value}}} @$items]}),"\n";
PERL
```

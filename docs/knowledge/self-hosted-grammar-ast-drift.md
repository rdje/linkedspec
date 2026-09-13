---
id: self-hosted-grammar-ast-drift
title: "Self-hosted grammar omits accepted syntax and loses AST fields; Perl literal interpolation is also exposed"
answers:
  - "is spec.spec still relevant to current LinkedSpec"
  - "does spec.spec cover final codeblock function definitions"
  - "why does the self hosted parser omit typed functions"
  - "why does a bare fluent edge lose its attached block"
  - "why does Child.with put the fluent chain in the index"
  - "why does fn zero lose its body in spec.spec"
  - "why does a rest only function invent a fixed parameter"
  - "why does indentation turn a lifecycle fluent into a bare edge"
  - "why is the capture_gaps directive AST value empty"
  - "does Perl interpolate sigils in double quoted action literals"
  - "what repairs own the current self hosted grammar drift"
date: 2026-09-13
status: confirmed open; five grammar/literal repair roots and seven implementation-and-verification leaves
tags: [spec, self-hosting, grammar, ast, captures, lifecycle, functions, perl, literals, SUPPORTING-SOURCE-READING]
evidence: "SUPPORTING-SOURCE-READING.1.18 completes canonical spec.spec source reading and dedicated function grammar1–115. Six matched function comparisons, fourteen exact edge AST cases, ten exact mechanism AST cases, three descriptor selection comparisons and three primary literal controls establish the findings below. Descriptor/generated-source evidence identifies each mechanism. SUPPORTING-SOURCE-READING.2.1-.2.5 own repair; none is fixed or closed. No native matrix, gap runtime failure, dependency build or primary typed-function omission is claimed."
reverify: "Run SUPPORTING_CURRENT_GROUP18 in supporting-source-reading-coverage.md, then the four SELF_HOSTED_* blocks below through the project-data wrapper. They assert the dated defective observations and controls, not repaired behavior; update them with evidence when the owning repairs land."
---

# Retained role and limits

The director agrees on September13 that `spec.spec` remains relevant as a tested,
accurate self-description of today's backend-neutral language. It is a current
comparison-parser dependency with maintained fixtures, distinct from the excluded
historical application specs. That role is a maintenance obligation, not evidence
that every accepted construct is already represented faithfully.

Perl's primary path still uses the bootstrap and dedicated function-definition
grammar. All six function controls below register exactly one primary function.
Typed-final and typed-only controls each return one dedicated definition but zero
self-hosted function nodes. Thus this is self-description/comparison drift; it does
not remove typed functions from the primary language. Complete self-hosted source
reading ends at226; dedicated grammar reading currently ends at115, inside its
malformed-definition error construction. Its remaining suffix belongs to `.1.19`.

# Confirmed repair ownership

| Owner | Observed defect | Demonstrated cause and repair boundary |
| --- | --- | --- |
| `.2.1` | `fn probe(value, body: codeblock)` and `fn probe(body: codeblock)` are omitted by the self-hosted AST. | Canonical dispatch/compiled descriptor has only fixed and variadic definition productions. Their parameter patterns omit the dedicated typed grammar's form. Add that accepted form and verify signature/body fidelity. |
| `.2.2` | `Child[1].with() { return("a") }` and the corresponding `"b"` body produce identical nodes. | `bare_edge_fluent` captures `blkBEF` but its return action emits no body or raw source. Preserve the attached text and test differing bodies. |
| `.2.3` | Unindexed fluents, zero-argument functions and rest-only functions shift fields. | Fixed numbered indexes follow optional captures, but the admitted runtime intentionally omits nonparticipating captures. Repair three grammar consumers; preserve runtime semantics. |
| `.2.4` | `@capture_gaps` produces an empty directive string; the same double-quoted text also becomes empty in a primary action. | Perl literal lowering passes quoted source through, leaving host interpolation in generated code. Repair general literal fidelity and verify directive metadata, rather than only changing that grammar quote. |
| `.2.5` | A leading space/tab makes `I.return("a")` a bare edge. | The anchored bare pattern consumes indentation and starts earlier than the unanchored lifecycle fluent. Align grammar reservation while preserving normal matcher choice. |

All ids expand under [[SUPPORTING-SOURCE-READING]]. Implementation retains startup
`.3/.4/.5` prerequisites. Implementation and focused verification share each bounded repair leaf;
`.2.3` has one such leaf per affected production. A separate `.2.6` owns the
commit checker/registry capacity drift recorded in [[task-partition-capacity-registry-drift]].
Logging and exact reproduction are not defect closure.

# Mechanisms and matched controls

**Optional captures.** Numbered `entry_group` values are zero-based participating
captures; an absent optional group is omitted, and subsequent values compact.
[[rust-capture-group-helper-indexing]] records that backend-neutral contract.
`LinkedRE::_build_match_info` preserves it, and dumped handlers access the resulting
array directly. Consequently these self-hosted outputs are currently wrong:

- `Child.with()` has index `.with()` and fluent `()`; `Child[1].with()` retains
  index `1` and fluent `.with()` correctly.
- `fn zero() { return(1) }` has params `{ return(1) }` and null body.
- `fn rest(...args) { return(1) }` has positional params `["args"]`, rest name
  `{ return(1) }`, minimum arity1 and null body. Its intended fixed prefix is empty.

Fixed-parameter and fixed-prefix variadic controls produce function nodes through
both grammars. Primary descriptors register one function for all six controls,
including zero/rest-only cases. This evidence does not assert all dedicated AST
fields or execute those function bodies.

**Attached text.** `specs/spec.spec`171 captures the optional `blkBEF`;172 returns
only type/target/index/fluent/source_form. The dumped return handler agrees.
Explicit action and blind fluent controls retain full raw text; grouped bare
blocks retain code, and plain indexed edges retain their index. Loss is demonstrated
for the self-hosted bare fluent AST, not inferred as a primary execution failure.

**Lifecycle selection.** The generated root calls `LinkedRE::or` with its compiled
dependency alternation. For `Root::` followed by unindented `I.return("a")`, both
candidate patterns start at offset7; lifecycle wins the authored-order tie. With
one space or tab, lifecycle starts at8 while bare fluent starts at7, so the latter
wins. Descriptor regex matches and the actual combined matcher agree in all three
cases. Spacing before the call parentheses does not remove the issue. Brace-form
explicit and standalone lifecycle controls are correct. Source owners are
`lifecycle_fluent`187 and `bare_edge_fluent`171; the earlier anchored
`lifecycle_block_line` production already distinguishes brace-form reservation.
[[duplicate-regex-slot-identity-contract]] documents the correct earliest-start,
then authored-order choice policy. Do not change that runtime policy to mask this
grammar defect or merge it with existing Rust whitespace repair owners.

**Literal fidelity.** `ValueExpr::_lower_primitive_literal_expr` returns the quoted
DSL token unchanged for strings. Dumped primary code contains
`return "@capture_gaps";`, while the directive handler contains the same quoted
value in its returned hash. Perl evaluates it as array interpolation and returns
empty in these probes. The single-quoted control emits `return '@capture_gaps';`
and preserves the literal; ordinary double-quoted `"capture_gaps"` also survives.
Both delimiters are backend-neutral scalar strings under
[[single-quoted-action-strings-variant-contract]]. The demonstrated general defect
belongs to literal lowering and emitted values, not to gap execution semantics.
Other sigils, escapes and affected lowering routes are explicit repair verification
work, not already measured claims.

# Exact dated reproductions

The four blocks intentionally assert the current defective results alongside
positive controls. An exit0 confirms reproduction only. They create no production
source change and require no RGX/PGEN rebuild. Generated parser text is diagnostic
scratch, not an additional physical source-reading credit.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'SELF_HOSTED_FUNCTION_COMPARISON' > .linkedspec-data/scratch/support118/function_grammar_proof.json
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;

my $json = JSON::PP->new->canonical;
my $self = LinkedSpec::get_parser('spec');
my $definitions = LinkedSpec::get_parser('user_function_definition');
my $descriptor = LinkedSpec::get_parser('spec', return_descriptor => 1);
my @function_rules = sort grep { /function_definition/ } keys %{$descriptor->{spec}};
die "unexpected self-hosted function rules\n"
    unless $json->encode(\@function_rules) eq $json->encode(['function_definition', 'variadic_function_definition']);
my @rows;
for my $case (
    ['fixed', 'fn probe(value) { return(value) }'],
    ['variadic', 'fn probe(value, ...rest) { return(value) }'],
    ['zero', 'fn zero() { return(1) }'],
    ['rest_only', 'fn rest(...args) { return(1) }'],
    ['typed_final', 'fn probe(value, body: codeblock) { return(value) }'],
    ['typed_only', 'fn probe(body: codeblock) { return(1) }'],
) {
    my ($name, $definition) = @$case;
    my $self_source = "Root::\n$definition\n";
    my $definition_source = "$definition\n";
    my $self_ast = $self->(\$self_source);
    my $definition_ast = $definitions->(\$definition_source);
    my @self_functions = map { grep { $_->{type} eq 'function_definition' } @$_ } @$self_ast;
    my $typed = $name =~ /^typed_/ ? 1 : 0;
    die "self-hosted comparison changed for $name\n" unless @self_functions == ($typed ? 0 : 1);
    die "definition parser lost $name\n"
        unless ref($definition_ast) eq 'ARRAY' && @$definition_ast == 1
            && $definition_ast->[0]{type} eq 'function_definition';
    my $full_source = "$definition\nRoot::\n I.return(1)\n";
    my $full = LinkedSpec::Get(\$full_source, return_descriptor => 1);
    die "primary registration lost $name\n" unless $full->{meta}{function_count} == 1;
    push @rows, { case => $name, self_hosted => $self_ast,
                  definition_parser => $definition_ast,
                  primary_function_count => 0 + $full->{meta}{function_count} };
}
print $json->encode({ self_hosted_function_rules => \@function_rules, cases => \@rows }), "\n";
SELF_HOSTED_FUNCTION_COMPARISON
```

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'SELF_HOSTED_EDGE_AST' > .linkedspec-data/scratch/support118/edge_grammar_proof.json
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;

my $json = JSON::PP->new->canonical;
my $parser = LinkedSpec::get_parser('spec');
my $body='{ return("a") }';
my $bare={type=>'bare_edge',target=>'Child',index=>'1',fluent=>'.with()',source_form=>'bare'};
my %expected=(
 action_fluent=>{type=>'action_edge',target=>'Child',fluent=>'1',raw=>'-> Child[1].with() '.$body},
 action_bare=>{type=>'action_edge',target=>'Child',index=>'1'},
 blind_block=>{type=>'blind_edge',target=>'Child',code=>$body},
 blind_fluent=>{type=>'blind_edge',target=>'Child',fluent=>'1',raw=>'=> Child.with() '.$body},
 blind_bare=>{type=>'blind_edge',target=>'Child'},
 bare_group=>{type=>'bare_edge',targets=>'Child[1] | Other',code=>$body,source_form=>'bare'},
 bare_fluent_a=>$bare, bare_fluent_b=>$bare,
 bare_plain=>{type=>'bare_edge',target=>'Child',index=>'1',source_form=>'bare'},
 lifecycle_explicit=>{type=>'lifecycle',marker=>'I',code=>$body,source_form=>'explicit'},
 lifecycle_fluent=>{type=>'bare_edge',target=>'I',index=>'.return ("a")',fluent=>' ("a")',source_form=>'bare'},
 lifecycle_bare=>{type=>'lifecycle',marker=>'I',code=>$body,source_form=>'bare'},
 split=>{type=>'split_marker',marker=>'@mark(piece)',name=>'piece'},
 gaps=>{type=>'capture_gaps',directive=>''},
);
my @rows;
for my $case (
    ['action_fluent', '-> Child[1].with() { return("a") }'],
    ['action_bare', '-> Child[1]'],
    ['blind_block', '=> Child { return("a") }'],
    ['blind_fluent', '=> Child.with() { return("a") }'],
    ['blind_bare', '=> Child'],
    ['bare_group', 'Child[1] | Other { return("a") }'],
    ['bare_fluent_a', 'Child[1].with() { return("a") }'],
    ['bare_fluent_b', 'Child[1].with() { return("b") }'],
    ['bare_plain', 'Child[1]'],
    ['lifecycle_explicit', 'I { return("a") }'],
    ['lifecycle_fluent', 'I.return ("a")'],
    ['lifecycle_bare', '{ return("a") }'],
    ['split', '@mark(piece)'],
    ['gaps', '@capture_gaps'],
) {
    my ($name, $item) = @$case;
    my $source = "Root::\n $item\n";
    my $ast = $parser->(\$source);
    my $want=[[{type=>'rule',label=>'Root',mode=>'',top=>1},$expected{$name}]];
    die "exact AST changed for $name\n" unless $json->encode($ast) eq $json->encode($want);
    push @rows, { case => $name, source => $source, ast => $ast };
}
print $json->encode(\@rows), "\n";
SELF_HOSTED_EDGE_AST
```

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'SELF_HOSTED_MECHANISM_AST' > .linkedspec-data/scratch/support118/mechanism_proof.json
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;

my $json = JSON::PP->new->canonical;
my $generated = '';
my $parser = LinkedSpec::get_parser('spec', dump_parser_source => 1,
                                   parser_source_ref => \$generated);
open my $out, '>:raw', '.linkedspec-data/scratch/support118/self_hosted_generated.pl' or die $!;
print {$out} $generated;
close $out or die $!;
die "generated directive changed" unless index($generated,q{return {"type" => "capture_gaps", "directive" => "@capture_gaps"};})>=0;
my @rows;
for my $item (
    'I.return("a")', ' I.return("a")', "\tI.return(\"a\")",
    'I.return ("a")', ' I.return ("a")',
    'Child.with()', 'Child[1].with()',
    'fn zero() { return(1) }', 'fn rest(...args) { return(1) }',
    '@capture_gaps',
) {
    my $source = "Root::\n$item\n";
    my $ast=$parser->(\$source);
    my $expected;
    if ($item eq '@capture_gaps') { $expected={type=>'capture_gaps',directive=>''} }
    elsif ($item =~ /^fn zero/) { $expected={type=>'function_definition',name=>'zero',params=>'{ return(1) }',body=>undef} }
    elsif ($item =~ /^fn rest/) { $expected={type=>'function_definition',version=>2,name=>'rest',signature=>{kind=>'callable_signature',version=>1,positional_params=>['args'],rest_param=>'{ return(1) }',min_arity=>1,max_arity=>undef},body=>undef} }
    elsif ($item eq 'Child.with()') { $expected={type=>'bare_edge',target=>'Child',index=>'.with()',fluent=>'()',source_form=>'bare'} }
    elsif ($item eq 'Child[1].with()') { $expected={type=>'bare_edge',target=>'Child',index=>'1',fluent=>'.with()',source_form=>'bare'} }
    elsif ($item =~ /^I/) { $expected={type=>'lifecycle',marker=>'I',fluent=>'1',raw=>$item} }
    else {
      my $chain=$item;$chain =~ s/^[ \t]*I//;
      my $args=$chain;$args =~ s/^\.return//;
      $expected={type=>'bare_edge',target=>'I',index=>$chain,fluent=>$args,source_form=>'bare'};
    }
    my $want=[[{type=>'rule',label=>'Root',mode=>'',top=>1},$expected]];
    die "exact mechanism AST changed for $item" unless $json->encode($ast) eq $json->encode($want);
    push @rows, { item => $item, ast => $ast };
}
print $json->encode({ generated_characters => length($generated), generated_file_bytes => -s '.linkedspec-data/scratch/support118/self_hosted_generated.pl', cases => \@rows }), "\n";
SELF_HOSTED_MECHANISM_AST
```

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'SELF_HOSTED_SELECTION_LITERAL' > .linkedspec-data/scratch/support118/selection_literal_probe.json
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;
my $json=JSON::PP->new->canonical;
my $d=LinkedSpec::get_parser('spec',return_descriptor=>1);
my @rows;
for my $indent ('', ' ', "\t") {
 my $source="Root::\n${indent}I.return(\"a\")\n";
 my @candidates;
 for my $label ('lifecycle_fluent','bare_edge_fluent') {
  my $re=$d->{spec}{$label}{re}[0];
  pos($source)=7;
  die "candidate missing" unless $source =~ /$re/g;
  push @candidates,{label=>$label,start=>0+$-[0],end=>0+$+[0]};
 }
 pos($source)=7;
 my $match=LinkedRE::or(\$source,$d->{dependency_regex_map}{spec_file});
 my $label=$d->{spec}{spec_file}{dependency_refs}[$match->{index}]{label};
 my $want=length($indent)?'bare_edge_fluent':'lifecycle_fluent';
 die "choice changed" unless $label eq $want;
 die "wrong candidate start" unless $candidates[0]{start}==7+length($indent) && $candidates[1]{start}==7;
 push @rows,{indent=>$indent,candidates=>\@candidates,selected=>$label};
}
my @literal;
for my $case (
 ['double',q{Root::
 I.return("@capture_gaps")
},''],
 ['single',q{Root::
 I.return('@capture_gaps')
},'@capture_gaps'],
 ['ordinary',q{Root::
 I.return("capture_gaps")
},'capture_gaps'],
) {
 my ($name,$source,$want)=@$case;
 my $generated='';
 my $parser=LinkedSpec::Get(\$source,dump_parser_source=>1,parser_source_ref=>\$generated);
 my $input='';my $got=$parser->(\$input);
 die "literal control changed $name" unless defined($got) && $got eq $want;
 my @returns=grep {/^return /} split /\n/,$generated;
 push @literal,{case=>$name,result=>$got,generated_return=>\@returns};
}
print $json->encode({selection=>\@rows,literals=>\@literal}),"\n";
SELF_HOSTED_SELECTION_LITERAL
```

Related: [[spec-spec-self-hosted-grammar]], [[bootstrapspec-vs-spec-spec-dual-path]],
[[spec-defined-user-function-definition-parser]], [[terse-primitive-literal-parity]],
[[supporting-source-reading-coverage]], and [[current-supporting-grammar-dependencies]].

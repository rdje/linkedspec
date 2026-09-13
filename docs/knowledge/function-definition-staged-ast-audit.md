---
id: function-definition-staged-ast-audit
title: Function-definition staged AST tests need a wrapper harness, named captures, and exact provenance
answers:
  - "what is the expected staged function_definition AST shape"
  - "why should function_definition tests use a wrapper top rule"
  - "why does direct top function_definition return null captures"
  - "why are numbered captures wrong for zero-arg functions"
  - "how should zero-arg function definitions parse"
  - "how should regex braces in function bodies be tested"
  - "what function definition variation matrix is required"
  - "what did STAGED-LINKED-PARSING.5.2 audit"
date: 2026-07-02
status: current
tags: [architecture, staged-parsing, user-functions, ast, source-provenance, language-neutral]
evidence: "STAGED-LINKED-PARSING.5.2 audited specs/spec.spec, LinkedSpec::UserFunctionRegistry, Rust parser/compiler structs, phase0 user-function tests, and focused LinkedSpec::Get probes. Direct top regex rules read entry_group(...) as null, so focused AST-shape tests need a wrapper top rule dispatching into a normal function_definition rule. The current specs/spec.spec numbered captures mis-shape zero-arg functions because optional captures are compacted; named captures preserve body correctly. The current body regex also fails or truncates regex literals containing braces. ADR 0017 defines the target neutral function_definition AST shape and variation matrix before implementation."
reverify: "rg -n 'STAGED-LINKED-PARSING\\.5\\.2|0017|function_definition|entry_group\\(\\.\\.\\.\\) as null|zero-argument|regex literals containing braces|body_parse_job' docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0017-function-definition-staged-ast-contract.md docs/linkedspec-book/src ROADMAP_V2.md specs/spec.spec"
---

The focused function-definition AST harness should not make `function_definition` itself
the top regex rule. A top rule has no entering match, so `entry_group(...)` is null
there. Use a small wrapper top rule that dispatches to a normal
`function_definition:` rule, collects child values, and returns them from `LX`.

The current `specs/spec.spec` function rule uses numbered captures around an optional
parameter list. Numbered capture helpers are compacted to participating captures, so
zero-argument functions shift the body into the `params` slot and leave `body` null.
The implementation proof must use named captures or an equivalent structured parse.

The target staged node is a source-ordered function-definition object with `type`,
`name`, parsed `params`, `arity`, exact `source_text`, neutral `source_span`, exact inner
`body_source`, `body_span`, a `body_parse_job`, and a stitched `body_ast` after dispatch.

The variation matrix must include zero/one/many params, whitespace and newline variants,
functions before and between rules, nested bodies, quoted braces, escaped quotes, regex
literals containing braces, adjacency to comments/rules, malformed definitions,
duplicates, collisions, and reserved names.

## September 13 historical finding reconciliation

The July audit above already identified zero-argument capture drift and regex-brace
body loss in `spec.spec`; neither is first discovered in this startup session.
STAGED `.5.3.1/.5.3.2` implemented the dedicated grammar and its consumers, which
retain exact body text. Supporting `.1.18` reconfirmed the self-hosted zero-argument
case; `.1.19` links that existing evidence to repair `.2.3.2` and gives the
self-hosted regex-body gap its own repair `.2.7`.

Four current comparisons use fixed and fixed-prefix variadic definitions, each
with a quoted-brace control and a `/}/` regex body. Self-hosted regex cases return
only `{ return(matches(value, /}` as body, truncating at the regex brace; quoted
controls and all four dedicated inner body strings remain exact. The responsible
self-hosted body regex protects quotes and nested braces but has no regex-token
boundary. The dedicated `regex_literal` child consumes the entire regex before
an outer close can be selected. The source still differs; the earlier dedicated
parser implementation must not be misreported as repair of the canonical
self-description. No primary function-body execution outcome is inferred here.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'SELF_HOSTED_REGEX_BODY_RECONCILIATION'
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;
my $json=JSON::PP->new->canonical;
my $self=LinkedSpec::get_parser('spec');
my $dedicated=LinkedSpec::get_parser('user_function_definition');
my @rows;
for my $params('value','value, ...rest') {
 for my $regex(0,1) {
  my $body=$regex?' return(matches(value, /}/)) ':' return("}") ';
  my $definition="fn probe($params) {$body}";
  my $source="Root::\n$definition\n";
  my $ast=$self->(\$source);
  my @functions=map {grep {$_->{type} eq 'function_definition'} @$_} @$ast;
  die 'self function count' unless @functions==1;
  my $want=$regex?'{ return(matches(value, /}':"{$body}";
  die 'self exact body changed' unless $functions[0]{body} eq $want;
  my $definitions=$dedicated->(\$definition);
  die 'dedicated full body changed' unless @$definitions==1 && $definitions->[0]{body_source} eq $body;
  push @rows,{parameters=>$params,regex=>$regex,self_body=>$functions[0]{body},dedicated_body=>$definitions->[0]{body_source}};
 }
}
print $json->encode(\@rows),"\n";
SELF_HOSTED_REGEX_BODY_RECONCILIATION
```

Related current evidence: [[spec-defined-user-function-definition-parser]] and
[[self-hosted-grammar-ast-drift]]. All prior dated audit evidence remains intact.

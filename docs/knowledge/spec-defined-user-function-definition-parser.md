---
id: spec-defined-user-function-definition-parser
title: User-function definition shells are parsed by specs/user_function_definition.spec, and body_brace does not own the outer close
answers:
  - "how are user function definitions parsed now"
  - "does Perl raw-scan user function definitions"
  - "does Rust raw-scan user function definitions"
  - "what owns user_function_definition AST shape"
  - "why does user_function_definition.spec use body_brace"
  - "can body_brace consume the outer function close"
  - "how are unbalanced user function bodies diagnosed"
  - "where is the user function definition spec file"
  - "how does Rust validate staged function payload and parse job metadata"
  - "how does Rust strip function definitions without moving scalar offsets"
date: 2026-09-07
status: current
tags: [implementation, staged-parsing, user-functions, ast, diagnostics, language-neutral]
evidence: "STAGED-LINKED-PARSING.5.3.1 added specs/user_function_definition.spec as the executable grammar owner for top-level fn name(params) { body } definition shells and made LinkedSpec::UserFunctionRegistry consume its returned AST instead of raw-scanning. STAGED-LINKED-PARSING.5.3.2 made Rust consume the same spec-returned function_definition / function_definition_error AST through linkedspec-runtime::spec_parser; rust/linkedspec-core/src/parser.rs no longer extracts top-level fn definitions. Generated-handler debug showed the function_definition dependency map dispatches nested { to body_brace but dispatches the outer } to function_definition[1]; Rust runtime tests lock the same self-recursive finalizer behavior. Focused Perl/Rust tests cover whitespace params, nested braces, adjacent nested body_brace matches, strings, regex literals, malformed definitions, and unbalanced nested bodies returning function_definition_error nodes."
reverify: "rg -n 'user_function_definitions::|function_definition:|body_brace:|function_definition\\[1\\]|invalid or unbalanced user function definition' specs/user_function_definition.spec && rg -n 'parse_spec_with_user_functions|parse_user_function_definition_asts|spec_defined_user_function_parser_' rust/linkedspec-runtime && rg -n 'UserFunctionRegistry|user_function_definition_spec_ast_shape' perl t/phase0_regression.t"
---

The user-function definition grammar is now a `.spec` file:
`specs/user_function_definition.spec`. It parses the outer `fn name(params) { body }`
shell and returns source-ordered `function_definition` AST nodes with parsed params,
arity, exact source/body text, spans, source-slice provenance, and a neutral
`body_payload`.

The Perl reference registry and Rust runtime adapter consume that returned AST. They no
longer own separate raw scanners for the definition shell. The bridge validates the AST,
preserves the neutral body payload, parses or compiles the already-extracted body text
through the existing action-body machinery, and strips definitions before ordinary rule
parsing.

`body_brace` is for nested brace islands inside the function body. Generated-handler debug
showed `body_brace` can start only on `{`; at the outer `}` close edge,
`function_definition[1]` is the matching edge. Adjacent nested bodies such as
`fn adjacent_braces() { {}{} }` therefore leave the outer close for the function rule.
Unbalanced nested bodies return a `function_definition_error` AST instead of pushing a
null node.

## September 7 Rust projection reading

`SESSION-STARTUP-READING.3.3.35` reads spec_parser.rs 1–836. Ordinary and traced entrypoints parse, validate,
compile and execute the same embedded definition grammar, validate returned node shapes, project definitions,
then parse the stripped rule source. The typed adapter distinguishes fixed-arity v1, callable-signature v2 and
the v1 final-codeblock form, rejecting incompatible signature/parameter fields. Definition and body spans must
match exact decoded-scalar text, with the body contained in its definition.

Body payload and parse job must agree with the projected function's name, signature/parameter kinds, text and
span. Jobs are restricted to actionir-body.spec/action_block, replace_field/body_ast, fail and function_body
diagnostic ownership. Parent paths are checked for the functions/*/body_source shape, then rewritten with the
actual node index; job IDs incorporate that index and the exact body span. The registry executes the validated
job before FunctionDefinition receives body_ast. It does not substitute a Rust definition-shell scanner.

Definition stripping sorts and rejects overlapping/out-of-range scalar spans, substitutes one space per
non-newline scalar and preserves CR/LF. Scalar offsets and line layout are retained; multibyte UTF-8 byte
length need not be retained. The semantic source mapper separately checks scalar-to-byte provenance as described
in [[rust-semantic-call-staged-projection]]. SourceLocation materialization uses a different private authority.

Remaining scalar/signature/error helper suffix 837–1022 is the next reading window. Fresh staged neutral proof
passes 9 rollout legs/123 base mutations and 6 public documents/129 public mutations; this is not a new native
function parser, trace or serialized carrier test run.

## September 7 Rust helper completion

`SESSION-STARTUP-READING.3.3.36` reads 837–1022 and completes spec_parser.rs. Callable signatures require exactly
six named fields, version1, valid ASCII positional/rest names, min_arity equal to positional count and null
max_arity. Scalar extraction checks string/array/object types; unsigned integer conversion is checked, while
the floating fallback's unchecked upper boundary is added to .55.1's source inventory in
[[rust-large-number-conversion-defect]]. Definition-error presentation distinguishes malformed/final/missing
codeblock parameter forms and unknown types, retaining a positive source line or falling back to node index.
These helper checks do not replace compiler-level validation or the executable shell grammar. Fresh staged and
typed-source neutral proof pass; no new native definition/signature or trace suite is claimed.

## September 13 complete dedicated grammar reading

Supporting `.1.18-.1.19` complete all 370 source lines. Named captures preserve
empty fixed lists and rest-only signatures, unlike the self-hosted numbered
capture consumers. Fixed v1, variadic v2 and typed-final internal v1 shapes retain
signature identity in the definition, staged payload and parse job. Source/body
text, half-open spans and source-slice provenance agree. Jobs remain inert metadata
with pending source-order paths until the registry validates and executes them.

Nested `body_brace`, quoted strings, slash/hash comments and `regex_literal` shield
internal braces; the owning definition's finalizer consumes the outer close.
Malformed headers and unterminated bodies return diagnostic records. The rule
paragraph recognizer skips ordinary rule text. These are source mechanisms and
bounded controls, not a claim that every lexical edge case is already covered.

The unchanged `user_function_definition_spec_ast_shape` subtest passes 44 assertions
across 13 valid definitions and malformed/unbalanced cases. Six fresh fixed,
variadic and typed-final controls additionally assert exact signature, body,
source/span, payload provenance and parse-job fields, including rest-only and
comments/regex/adjacent braces. No function body is executed by these grammar
probes and no dependency build or native matrix is run.

The extraction below copies the existing subtest and its two helpers byte-exact;
it records the full test-source identity and runs only that selected fixture.

```bash
bash tools/project_data_run.sh python3 - <<'DEDICATED_AST_FIXTURE_EXTRACT'
from pathlib import Path
import re, hashlib, json
scratch=Path('.linkedspec-data/scratch/support119');scratch.mkdir(parents=True,exist_ok=True)
raw=Path('t/phase0_regression.t').read_bytes();text=raw.decode()
expected={'source_sha256': '6b7fc16ee751ab02f2ae06109cfe4fb2516aa29b22c7a5ba3b2f77827a98a82a', 'block_sha256': '43fa8370fbabf08787b5e26d37e07cd9379e44ccfefe87f6331117306a54a64e', 'block_lines': 117, 'block_bytes': 7112, 'helper_sha256': ['22c5cf09e56596a123b5a51b09d6cd1e79803a86552441a02938ea6f7a174c4d', 'c1a49f9905ceaa3b235867b41ef3ce65643dd83697af8c1cb425f9ef0646fc4e']}
assert hashlib.sha256(raw).hexdigest()==expected['source_sha256']
a=text.index("subtest 'user_function_definition_spec_ast_shape' => sub {")
b=text.index("subtest 'staged_parser_registry_dispatches_function_body_jobs' => sub {",a)
block=text[a:b]
assert hashlib.sha256(block.encode()).hexdigest()==expected['block_sha256']
assert len(block.encode())==expected['block_bytes'] and block.count('\n')==expected['block_lines']
helpers=[]
for name in ['slurp','normalize_error']:
    m=re.search(r'^sub '+name+r' \{.*?^\}\n',text,re.M|re.S);assert m;helpers.append(m[0])
assert [hashlib.sha256(x.encode()).hexdigest() for x in helpers]==expected['helper_sha256']
script="use strict;\nuse warnings;\nuse Test::More;\nuse File::Spec ();\nuse LinkedSpec ();\nmy $spec_dir='specs';\n"+'\n'.join(helpers)+'\n'+block+'done_testing();\n'
(scratch/'focused_ast_fixture.pl').write_text(script)
(scratch/'fixture_identity.json').write_text(json.dumps(expected,indent=2)+'\n')
print('PASS unchanged full test-source identity, complete selected AST subtest and two exact helpers; run the extracted fixture separately.')
DEDICATED_AST_FIXTURE_EXTRACT
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/support119/focused_ast_fixture.pl
```

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'DEDICATED_SIGNATURE_PAYLOAD'
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;
my $json=JSON::PP->new->canonical;
my $parser=LinkedSpec::get_parser('user_function_definition');
my $body="\n # } {\n // } {\n return(\"}\")\n return(matches(value, /}/))\n {}{}\n";
my @rows;
for my $case (
 ['zero','()',[],undef,undef],
 ['fixed','(value)',['value'],undef,undef],
 ['rest_only','(...args)',[],'args',undef],
 ['rest_prefix','(value, ...args)',['value'],'args',undef],
 ['typed_only','(body: codeblock)',[],undef,'body'],
 ['typed_prefix','(value, body: codeblock)',['value'],undef,'body'],
) {
 my($name,$params,$fixed,$rest,$typed)=@$case;
 my $definition="fn $name$params {$body}";
 my $source="# lead\n$definition\nRoot::\n /x/\n";
 my $ast=$parser->(\$source);
 die "definition count $name" unless ref($ast) eq 'ARRAY' && @$ast==1;
 my $node=$ast->[0];
 die "definition identity $name" unless $node->{type} eq 'function_definition' && $node->{kind} eq 'user_function_definition' && $node->{name} eq $name;
 die "exact body/source $name" unless $node->{body_source} eq $body && $node->{source_text} eq $definition;
 my $body_start=index($source,'{')+1;
 my $body_end=$body_start+length($body);
 my $span={start=>7,end=>7+length($definition),line_start=>2,line_end=>2+($definition=~tr/\n//)};
 my $body_span={start=>$body_start,end=>$body_end,line_start=>2,line_end=>2+($body=~tr/\n//)};
 die "definition span $name" unless $json->encode($node->{source_span}) eq $json->encode($span);
 die "body span $name" unless $json->encode($node->{body_span}) eq $json->encode($body_span);
 my %signature;
 if(defined $rest) { %signature=(signature=>{kind=>'callable_signature',version=>1,positional_params=>$fixed,rest_param=>$rest,min_arity=>scalar(@$fixed),max_arity=>undef}) }
 elsif(defined $typed) { %signature=(fixed_params=>$fixed,codeblock_param=>$typed,parameter_kinds=>{$typed=>'codeblock'}) }
 else { %signature=(params=>$fixed,arity=>scalar(@$fixed)) }
 die "version $name" unless $node->{version}==(defined($rest)?2:1);
 for my $record($node,$node->{body_payload},$node->{body_parse_job}) {
  for my $key(keys %signature) {die "signature $name/$key" unless $json->encode($record->{$key}) eq $json->encode($signature{$key})}
 }
 for my $record($node->{body_payload},$node->{body_parse_job}) {
  die "payload identity $name" unless $record->{version}==1 && $record->{node_kind} eq 'function_definition' && $record->{payload_kind} eq 'function_body' && $record->{function_name} eq $name;
  die "pending path $name" unless $json->encode($record->{parent_ast_path}) eq $json->encode(['functions','__pending_source_order__','body_source']);
  die "payload source $name" unless $record->{text} eq $body && $json->encode($record->{source_span}) eq $json->encode($body_span);
 }
 die "payload kind $name" unless $node->{body_payload}{kind} eq 'staged_payload';
 die "provenance $name" unless $json->encode($node->{body_payload}{provenance}) eq $json->encode([{kind=>'source_slice',source_span=>$body_span}]);
 my $job=$node->{body_parse_job};
 my %job_fields=(kind=>'parse_job',job_id=>"parse_job:function_body:$name:actionir-body.spec:action_block",parser_spec_id=>'actionir-body.spec',top_rule=>'action_block',result_policy=>'replace_field',result_field=>'body_ast',failure_policy=>'fail',diagnostic_owner=>'function_body');
 for my $key(keys %job_fields) {die "job field $name/$key" unless $job->{$key} eq $job_fields{$key}}
 die "unexpected inline body execution $name" if exists $node->{body_ast};
 push @rows,{case=>$name,signature=>\%signature,body_span=>$body_span,source_span=>$span};
}
print $json->encode({cases=>\@rows}),"\n";
DEDICATED_SIGNATURE_PAYLOAD
```

The older self-hosted zero-argument and regex-brace findings were already recorded
by [[function-definition-staged-ast-audit]] on July2. Dedicated parser success did
not repair those distinct `spec.spec` productions. Supporting `.2.3.2` and `.2.7`
now retain explicit repair ownership; [[self-hosted-grammar-ast-drift]] keeps the
current comparison boundary.

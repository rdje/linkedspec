---
id: sexpr-document-design
title: A separate tagged s-expression document grammar preserves lexemes and rejects skipped input
answers:
  - which grammar will preserve symbol string and number token kinds
  - what is the planned strict s-expression document result
  - does a final cursor at EOF prove that all input was recognized
  - how does the strict s-expression design prevent silently skipped text
  - where are the SEMULITH kind and ARCHOGEN complete-document requirements owned
  - which compiler defect blocks strict-document delivery
date: 2026-09-22
status: ADR0124 design accepted; production grammar and cross-backend admission pending
tags: [s-expression, grammar, token-kind, validation, compatibility]
evidence: "Startup .83.1 authors 37 independent cases, proves 136 Perl assertions including 21 token-spelling round trips and a skipped-text mutation, and verifies four Rust prototype boundaries. The native probe also reproduced compiler warning/drop defect .45. Task .45.1 now corrects that shared compiler boundary; carrier proof .45.2 passes; canonical closeout .45.3 precedes grammar delivery."
reverify: "Run SEXPR_DOCUMENT_DESIGN_PROOF below from the repository root through the managed wrapper. Resolve the implementation frontier in SESSION-STARTUP-READING.45/.83; prototype proof is not production admission."
---

ADR0124 selects a separate planned `specs/SExprDocumentV1.spec` with a versioned
`format`/`forms` document and tagged list/symbol/number/string nodes. Atom `lexeme`
fields preserve full source spelling, including string quotes and escapes. The
37 authored cases in `tests/sexpr-document-v1/contract.json` are the acceptance
authority, not output regenerated from a parser. Historical Lispish stays intact;
its multiline quote repair is [[lispish-multiline-quoted-payload]].

A successful final cursor alone does not establish complete recognition. Removing
both explicit rejecting catch-all edges from this prototype accepts `(a) junk (b)`
and reaches EOF. The valid implementation must give every character a recognized
branch or an explicit rejection. This is an authored grammar requirement; default
seek dispatch itself is unchanged.

The current feasibility evidence is **Perl plus four Rust boundaries only**.
Perl passes 136 assertions across 21 accepted and 16 rejected documents, exact values,
token-spelling reconstruction, independent-input reuse and the catch-all mutation.
Rust verifies the typed atom example, the complete four-form eADL file, interstitial
junk and an unterminated escaped string using full stdout/stderr and real statuses.
The two rejections have empty stdout, status 1 and the standard parser-invocation
failure heading. No complete six-runtime or generated-artifact admission is claimed.

The initial native probe rejected nonportable infix comparison in LX parsing but
still exited 0 with null after discarding the block. The canonical prototype below
uses `num_ne(...)`, as required by the existing operator-call contract. Compiler
error propagation is a separate compiler repair: [[rust-action-parser-boundary-defects]]
and bounded .45.1/.45.2/.45.3 own its correction and verification before delivery. Historical source evidence
at clean design activation 8259719f8 is compiler.rs:1075-1088 and lifecycle
omission at 1303-1310. The common-boundary correction is now under .45.1; carrier
verification passes under .45.2; canonical closeout remains required.

## Repeat the bounded prototype proof

This is a diagnostic model, not the shipped grammar. It uses only project-local
files and existing public `LinkedSpec::Get` behavior. Its 37 expected outcomes are
loaded from the tracked contract; the prototype never generates those expectations.

```bash
bash tools/project_data_run.sh perl -Iperl - <<'SEXPR_DOCUMENT_DESIGN_PROOF'
use strict; use warnings; use Test::More; use JSON::PP; use lib 'perl'; use LinkedSpec;
sub read_text { open my $f,'<:encoding(UTF-8)',$_[0] or die $!;local $/;return <$f> }
my $s=<<'PROTOTYPE';
Document::
I { forms = [] }
 -> Trivia
 -> List { push(forms, call(List)) }
 -> Invalid { exit_now(1) }
LX {
 if(num_ne(cursor_pos(), input_end_pos()));
  exit_now(1);
 endif();
 return(hash("format", "linkedspec-sexpr-v1", "forms", copy(forms)))
}

List: /\(/ /\)/
I { items = [] }
 -> Trivia
 -> List { push(items, call(List)) }
 -> String { push(items, call(String)) }
 -> Atom { push(items, call(Atom)) }
 -> List[1] { return(hash("kind", "list", "items", copy(items))) }
 -> Invalid { exit_now(1) }
LX { exit_now(1) }

Trivia: /[ \t\r\n\f\x0B]+|;[^\r\n]*(?:\r\n|\r|\n|\z)/

String: /"((?:[^"\\]|\\[\s\S])*)"/
I.return(hash("kind", "string", "lexeme", entry_text()))

Atom: /[^ \t\r\n\f\x0B()\[\]{}";]+/
I {
 spelling = entry_text();
 if(matches(spelling, /^[+-]?(?:0[xX][0-9a-fA-F](?:_?[0-9a-fA-F])*|(?:[0-9](?:_?[0-9])*(?:\.[0-9](?:_?[0-9])*)?|\.[0-9](?:_?[0-9])*)(?:[eE][+-]?[0-9](?:_?[0-9])*)?)$/));
  return(hash("kind", "number", "lexeme", spelling));
 else();
  return(hash("kind", "symbol", "lexeme", spelling));
 endif()
}

Invalid: /[\s\S]/
PROTOTYPE

my $contract=JSON::PP->new->decode(read_text('tests/sexpr-document-v1/contract.json'));
my $p=LinkedSpec::Get(\$s);
sub render_node { my($n)=@_; return $n->{kind} eq 'list' ? '('.join(' ',map{render_node($_)}@{$n->{items}}).')' : $n->{lexeme} }
for my $c (@{$contract->{cases}}) {
 my $input=$c->{input};my $value=eval{$p->(\$input)};my $error=$@;
 if($c->{outcome} eq 'accept') {
  is($error,'',"$c->{id}: no exception");
  is_deeply($value,$c->{expected},"$c->{id}: exact authored tree");
  my $rendered=join("\n",map{render_node($_)}@{$c->{expected}{forms}});
  my $again=eval{$p->(\$rendered)};my $again_error=$@;
  is($again_error,'',"$c->{id}: token-preserving serialization parses");
  is_deeply($again,$c->{expected},"$c->{id}: token kind/spelling round trip");
 } else {
  is(ref($error),'LinkedSpec::RuntimeExitNow',"$c->{id}: explicit grammar rejection");
  is(ref($error) ? $error->{status} : undef,1,"$c->{id}: rejection status 1");
  ok(!defined($value),"$c->{id}: no accepted partial document");
 }
}
my $unsafe=$s;my $removed=($unsafe=~s/ -> Invalid \{ exit_now\(1\) \}\n//g);
is($removed,2,'mutation removes only the two catch-all rejecting edges');
my $q=LinkedSpec::Get(\$unsafe);my $junk='(a) junk (b)';
my $bad=eval{$q->(\$junk)};my $bad_error=$@;
is($bad_error,'','EOF guard alone wrongly accepts interstitial junk');
is(pos($junk),length($junk),'wrongly accepted parse reaches final cursor');
is(scalar(@{$bad->{forms}}),2,'wrongly accepted parse even retains both surrounding forms');
done_testing;
SEXPR_DOCUMENT_DESIGN_PROOF
```

Native probe records and the full warning/drop reproduction are retained at
`.linkedspec-data/scratch/sexpr-contract/native-proof-canonical.log` and
`.linkedspec-data/scratch/sexpr-contract/compiler-drop-reproduction.json`.
The native check uses the already prepared `rust/target/debug/linkedspec-rust`
with `--spec-file` and `--input-file`; it does not inspect dependency internals.

Prototype source SHA-256: `cfa6d7a7594488aac0c4f91264050db67974bcd9b93c5d0385a3d98d7c696fef`.
Acceptance JSON SHA-256: `463d57163499aa71432755e62548bb303740bea120aa2a694d01a8a96af99c51`.

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
  - why does the document grammar avoid a backslash z EOF anchor
  - how do the backend integration guides select the complete document grammar
  - where is the native complete s-expression file consumer
  - how does sexpr_file report a rejected document and locate its grammar
date: 2026-09-23
status: grammar and native Rust file delivery verified; independent final admission pending
tags: [s-expression, grammar, token-kind, validation, compatibility]
evidence: "Startup .83.1 authors 37 independent cases and preserves bounded prototype proof. Task .45 closes the compiler warning/drop repair. Production .83.2.2 passes all 37 cases, 21 round trips and 16 same-engine recovery checks on each of six runtimes, with descriptor readiness and an independent skipped-text mutation; its driver recurs in canonical CI. Native delivery .1 passes the unchanged 37 cases as files and 36 process groups; legacy 26-file/18-group and three adapter checks pass."
reverify: "Run bash tools/check_sexpr_document_v1.sh for the grammar and follow the Rust integration guide's native build plus examples/integration/rust/verify_sexpr.py for file delivery. SEXPR-DOCUMENT-INTEGRATION.2 owns independent final admission. The historical SEXPR_DOCUMENT_DESIGN_PROOF below preserves feasibility scope."
---

ADR0124 selects the separate `specs/SExprDocumentV1.spec` with a versioned
`format`/`forms` document and tagged list/symbol/number/string nodes. Atom `lexeme`
fields preserve full source spelling, including string quotes and escapes. The
37 authored cases in `tests/sexpr-document-v1/contract.json` are the acceptance
authority, not output regenerated from a parser. Historical Lispish stays intact;
its multiline quote repair is [[lispish-multiline-quoted-payload]].

Production .83.2.2 consumes all 37 authored cases across Perl/Rust/Dart/Julia/PUC Lua/LuaJIT,
with 21 token-spelling round trips and 16 same-engine recovery checks per route.
The Perl test adds descriptor readiness, JSON scalar-kind comparison and the
independent catch-all mutation. `tools/check_sexpr_document_v1.sh` is the recurring
authority and runs in canonical CI. Rust/Dart test discovery and Julia/Lua local
gate registrations also retain the consumers. The acceptance case array is unchanged
from ADR0124 (canonical JSON SHA-256
`75b1012504eba16781f0a92282f915f711d51688d59e2868c7c448ccef39cebe`).
Native Rust file delivery is implemented under `SEXPR-DOCUMENT-INTEGRATION.1`
for startup .83.2.3; independent final admission remains .2 under startup .83.3.
All five backend integration guides and their shared landing page now route to
the document contract, explain native result/failure handling and publish each
runtime's focused check command. The maintained Perl/Dart/Julia/Lua word adapters
explicitly select `Top`; an adaptation must select `Document` as well as the new
grammar path. Rust's generic text consumer uses default `ExecutionOptions` and
therefore selects `Document` without an adapter change. The historical Rust
`lispish_file` decoder still expects head/tail values and cannot decode the new
tagged result. These are application integration requirements, not backend API
changes; the shared grammar chapter owns schema and lexical semantics.
The Rust integration guide command builds and returns the exact documented two-form tagged value through the public loader and generic native consumer. Direct consumer boundary checks also pass empty documents, ordered two-form input and interstitial-junk rejection with empty stdout.

## September 23 native file delivery

`examples/integration/rust/src/bin/sexpr_file.rs` uses the public native loader,
selects `Document` explicitly, compiles once and reads each input as exact UTF-8.
It serializes the returned tagged value directly. No kind inference, numeric
conversion, escape decoding or historical depth-limited adapter is involved.
The default grammar is executable-relative `specs/SExprDocumentV1.spec`;
explicit grammar and input paths resolve against the caller's working directory.

Malformed documents produce no value for that file. The example reports
`document_parse_error` with the supplied `input` and native `cause`, preserving
typed exit status 1 or the ordinary structured runtime failure. It stops at the
first error and retains prior result lines. Grammar-loading errors keep the
public pipeline schema; input I/O and invalid-UTF-8 errors identify their file.
The example's envelope is not a new runtime error API.

`examples/integration/rust/verify_sexpr.py` consumes the unchanged 37 authored
cases as files (21 accepted in one engine, 16 rejected) and verifies the published
example plus error, UTF-8, Unicode/relative path, option, asset and relocation
boundaries. All accepted cases repeat after moving the two-file bundle. Source
binary, grammar and contract hashes remain unchanged; owned fixtures are removed.
The historical adapter fails this verifier at the first document as expected,
while its own 26-file/18-group verifier remains green. Grammar source and every
authored expected value remain byte/structure-identical to `77d7b3db1`; only the
contract's delivery-status metadata changes. Formal admission remains .2.
The shipped catalog now lists all 22 source files exactly once. Rust
`integration_test::parse_all_shipped_specs` discovers, parses, validates and compiles
all22; Perl return_descriptor inventory/readiness proof passes67 assertions. These
checks also retain all 21 unchanged existing grammars. Mutable invariant prose uses
automatic discovery; older dated21-file results retain their historical scope.

A successful final cursor alone does not establish complete recognition. Removing
both explicit rejecting catch-all edges from this prototype accepts `(a) junk (b)`
and reaches EOF. The valid implementation must give every character a recognized
branch or an explicit rejection. This is an authored grammar requirement; default
seek dispatch itself is unchanged.

The original feasibility evidence below was **Perl plus four Rust boundaries only**.
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
omission at 1303-1310. The common-boundary correction is .45.1; carrier verification is .45.2,
and .45.3 closes the bounded repair with canonical acceptance.

## Repeat the bounded prototype proof

### Production portability finding under .83.2.2

The prototype below is historical feasibility source. The production grammar
uses `;[^\r\n]*(?:\r\n|\r|\n)?` for comments: its greedy body reaches a line
ending or EOF, and the optional suffix consumes the line ending when present.
It does not depend on `\z`. Dart's public `RuntimeRegexAlternation.compile`
leaves that escape with the host regex meaning: it matches literal `z`, not an
empty end position. `compileRuntimeRegex` and `_normalizePattern` at
`dart/lib/src/runtime/matching.dart:1384` delegate that unchanged pattern to
`RegExp`; the bridge does not promise general PCRE equivalence.

The first production contract run isolates three Dart failures: `trivia_only`,
`ascii_trivia` and `comments_with_delimiters`. Controlled native parser calls
reject `; eof`, accept `; eof\n` and accept `; eofz` with the prototype pattern.
The portable comment branch accepts all three as empty documents. This is a
grammar correction within the accepted EOF-comment contract, owned and fixed
by .83.2.2; no dependency or regex-engine change is needed. The public matcher
probe and source substitution are retained in
`.linkedspec-data/scratch/sexpr-document-v1/dart-portability-proof.log`.
The unchanged authored comment cases lock recurrence across all six runtimes.

### Historical feasibility recipe

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
Historical design-checkpoint acceptance JSON SHA-256: `463d57163499aa71432755e62548bb303740bea120aa2a694d01a8a96af99c51`.

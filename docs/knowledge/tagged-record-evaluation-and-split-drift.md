---
id: tagged-record-evaluation-and-split-drift
title: "Measured tagged-record and pure-split boundaries disagree across runtimes"
answers:
  - "why does Perl scalar split_tagged_records call an undefined host function"
  - "which task repairs the tagged-record String to Array bridge"
  - "does Rust support the split_tagged_records producer and String receiver"
  - "why did Rust return null for split_tagged_records"
  - "why does Perl split_tagged_records evaluate a field more than once"
  - "why do tagged records drop trailing empty items on Perl"
  - "which task owns tagged record evaluation and split parity"
  - "do Perl and Lua split agree on an empty source"
  - "why does Rust split with an empty delimiter add an initial empty item"
  - "does Rust pure split match Perl on empty sources and zero-width delimiters"
date: 2026-10-30
status: all five bounded tagged-record producer/receiver implementations targeted-checked; full split-domain admission remains owned
tags: [startup-reading, perl, rust, lua, tagged-records, split, parity]
evidence: "TYPE22.1.1 repairs the Perl eager producer with native/fresh regression; receiver22.1.2 is also repaired; Rust22.2 adds the missing producer/bridge; SESSION33 broad admission remains. Historical SESSION-STARTUP-READING.3.2.28 compares public Perl Get and the PUC Lua primary CLI for a,b, and empty sources. Perl evaluates the carried increment per emitted row and uses split without a trailing-empty limit. PUC Lua evaluates arguments once and reuses pure split. SESSION-STARTUP-READING.33.1 owns authority/impact review; .33.2 owns the reviewed repair."
reverify: "For current Perl producer run bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/tagged_record_producer_contract.t. Historical comparisons below retain their original scope; rebuild the Rust CLI before the paired Rust/Perl controls. Older Lua observations remain separately reproducible and dated."
---

## Current bounded Perl producer, October27

TYPE22.1.1 repairs eager argument lowering/snapshots and reuses the existing pure
split emitter. Source, dynamic delimiter, tag and carried fields run once in order
even when splitting produces no records; map only assembles captured values.
Literal regex flags, dynamic literal delimiters, legacy tag atoms and carried
kinds/DSL copy bounds are preserved. Native/fresh t/tagged_record_producer_contract.t
passes36 assertions after observed RED; direct ordinary split stays unchanged.
Earlier source/delimiter/tag/field values survive later rebinding. Receiver22.1.2 now classifies text input/Array output alongside split and rejects
fewer than two RHS operands before effects. Its shared valid/local shape native/fresh
regression passes12 assertions; Number/Bool/null/Array/Hash field continuations and
SDTFCE source/operand/consumer order pass. SESSION33 retains full split-domain/cross-runtime/context admission.
The old per-row/zero-field Perl results below describe the historical defect.

## Rust bounded producer and bridge, October27

TYPE22.2 public native intake returns null and unknown-helper warnings for the
ordinary producer; engine.rs lacked the helper arm and String-to-Array role.
It now uses existing split_string_for_arg items, a text tag and cloned captured
fields to construct fresh record Arrays. Generic eager argument evaluation already
retained source/delimiter/tag/field snapshots; no global conversion/split policy
changes. Receiver calls need delimiter/tag before any effects. Five authored
native/restored/in-process-plan tests pass, including shared selected-field chains,
SDTFCE, prior fields/copy, empty/trailing/regex and short free-call preservation;
four direct scalar String tests pass. Reverify with tools/run_cargo_local.sh test
--manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime
--test tagged_record_receivers. Full SESSION33 admission remains separate.

## Dart bounded receiver repair, October27

TYPE22.3 producer-first native/restored/plan controls already retain eager fields,
current pure-split boundaries and row copy independence. Named String receivers
were read as Arrays, trim-prefix was rejected by Array-only guards, regex operands
lost pattern interpretation, and malformed calls ran SSDC effects. Dispatcher
output-family membership is not an input-role guard. The derived unmodifiable
Array-only set now excludes tagged records; dedicated receiver delimiter wrapping
and min-two-RHS preflight fix these paths without changing the producer. Five
new tagged tests and seven direct String tests pass with format/fatal analysis.
Reverify from dart: bash ../tools/run_dart_project_data.sh test
test/tagged_record_receivers_test.dart. Short free calls still return empty Arrays
and evaluate operands; full SESSION33 split-domain/context admission remains open.

## Julia bounded receiver repair, October27

TYPE22.4 producer-first native/plan/fresh strict controls pass15; named/literal/
regex/copy behavior is already healthy. Only trim-prefix and malformed receiver
shapes fail: Array dispatch-family membership incorrectly rejects a scalar String
result, and absent min-two-RHS preflight runs SSDC. A separate actual Array-only
receiver set excludes tagged records; the preflight requires delimiter/tag before
effects. Keep the producer/pattern/copy/split/conversion/free short-call paths.
Registered julia/test/tagged_record_receivers_test.jl passes51 strict assertions;
54 direct String assertions and strict compilation pass. Reverify with the Julia
project-data wrapper, --project=julia --startup-file=no --history-file=no
--depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include("julia/test/tagged_record_receivers_test.jl")'.
Full split-domain/context/portable admission remains with SESSION33.

## Safe Lua bounded receiver repair, October27

TYPE22.5 safe PUC5.5.1/LuaJIT producer/copy/free-short controls already work;
named/literal/regex chains are healthy. Scalar/reduction guards block prior String
results using Array dispatch membership, and absent min-two-RHS preflight runs
SSDC effects. One function-local actual Array-input predicate excludes tagged
records and serves both guards; preflight requires delimiter/tag before effects.
No new module locals; healthy producer/conversion/split/regex/copy/free-short paths
remain. lua/test/tagged_record_receivers_test.lua five strict groups and direct
scalar String fixture pass native/plan/fresh on both safe hosts, with source/runner
loadfile only. Reverify using tools/run_lua_project_data.sh puc and luajit with the
named tagged fixture. Never infer full runner/unsafe malformed native regex or
current declared5.4/full SESSION33 split-domain/context/portable admission.

## Historical producer and cross-runtime split observations

The helper reference at `docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md:1163`
teaches once-only source/tag/carried-field evaluation. The measured Perl implementation conflicts with that
claim; the PUC Lua control follows it. This is not authority to silently change the reference or oracle.
`SESSION-STARTUP-READING.33` owns reconciliation and the resulting implementation work.

Each probe starts `counter` at zero, builds tagged rows with carried field `set(counter, add(counter, 1))`,
and returns `[records, counter, split(source, ",")]`:

| Source | Perl Get | PUC Lua primary CLI |
| --- | --- | --- |
| `"a,b,"` | `[[["row","a",1],["row","b",2]],2,["a","b",""]]` | `[[["row","a",1],["row","b",1],["row","",1]],1,["a","b",""]]` |
| `""` | `[[],0,[]]` | `[[["row","",1]],1,[""]]` |

Both Perl controls have no context error; both PUC commands exit 0. In addition to tagged-row trailing-item
drift, the empty-source controls expose an ordinary pure-split difference. Other backends, LuaJIT, generated
execution, regex/variable delimiters, tag effects, and carried aggregate independence remain unmeasured here.

`perl/LinkedSpec/ActionIR/MethodLowering.pm:6068`–6075 puts carried expressions inside the generated
`map` body and emits Perl `split` without the `-1` used by ordinary split. The dumped handler therefore
increments once per produced item, and not at all when no item exists.
`lua/src/linkedspec/interpreter.lua:1926`–1940 materializes arguments before helper execution;
1897–1907 reuses pure split and copies the materialized fields into each record. Its literal splitter
at 1093–1106 always appends the remaining suffix, including the empty-source suffix.

Perl observation command:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;
for my $input_source ('a,b,','') {
 my $spec='Top::'."\n".' /x/ -> Top { counter = 0; source = "'.$input_source.'"; records = split_tagged_records(source, ",", "row", set(counter, add(counter, 1))); return([records,counter,split(source,",")]) }'."\n";
 my (%ctx,$src);my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src);
 die 'compile' unless ref($p) eq 'CODE';my $input='x';my $got=$p->(\$input);
 print JSON::PP->new->canonical->encode({source=>$input_source,result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
 for my $line(split /\n/,$src){print "$line\n" if $line =~ /\[map \{/}
 die 'context error' if defined($ctx{last_error});
}
PERL
```

Fresh PUC Lua controls (same authored specs and input):

```bash
bash tools/run_lua_project_data.sh puc lua/bin/linkedspec-lua --inline-spec 'Top::
 /x/ -> Top { counter = 0; source = "a,b,"; records = split_tagged_records(source, ",", "row", set(counter, add(counter, 1))); return([records,counter,split(source,",")]) }
' --input x
bash tools/run_lua_project_data.sh puc lua/bin/linkedspec-lua --inline-spec 'Top::
 /x/ -> Top { counter = 0; source = ""; records = split_tagged_records(source, ",", "row", set(counter, add(counter, 1))); return([records,counter,split(source,",")]) }
' --input x
```

Related: [[lua-runtime-tagged-record-construction]], [[lua-pure-split-bridge]],
[[terse-source-migration-runtime-boundaries]].

## September 7 Rust/Perl pure-split boundary comparison

`SESSION-STARTUP-READING.3.3.15` builds the current Rust CLI through the locked,
offline repository wrapper, then compares seven identical explicit-edge specs.
Every spec returns pure `split` from the I hook; Perl receives explicitly decoded
UTF-8 source. All seven commands per backend exit zero, with empty stderr and no
Perl compile, invocation or context error. Five values differ; two controls agree.

| Expression | Perl Get | Rust primary CLI |
| --- | --- | --- |
| `split("a,b,", ",")` | `["a","b",""]` | `["a","b",""]` |
| `split("", ",")` | `[]` | `[""]` |
| `split("ab", "")` | `["a","b",""]` | `["","a","b",""]` |
| `split("éx", "")` | `["é","x",""]` | `["","é","x",""]` |
| `split("", "")` | `[]` | `["",""]` |
| `split("ab", /(?:)/)` | `["a","b",""]` | `["","a","b",""]` |
| `split("ab", /(?=b)/)` | `["a","b"]` | `["a","b"]` |

Rust `engine.rs::split_string_literal` delegates to the host string splitter.
`split_string_regex` pushes the slice before each match, including a zero-width
match at offset zero, then always appends the remaining suffix. Its separate
search cursor advances by a Unicode-scalar boundary for zero-width progress.
The public `split` arm at engine lines 8415–8444 delegates to those exact helpers;
this supporting callsite was inspected separately from the owned reading window.

The dumped Perl handler uses `split` with limit `-1` for both quoted literal and
regex delimiters. The measured Perl boundary suppresses the initial zero-width
field and produces no fields from empty input. Rust's Unicode case preserves
the scalar correctly; the mismatch concerns empty fields rather than byte splitting.

Existing `SESSION-STARTUP-READING.33.1` owns authoritative contract review and the
six-runtime/native/generated census. `.33.2` explicitly owns pure-split repair and
recurrence alongside tagged-record work. These results do not rerun Lua/LuaJIT,
Dart or Julia, scalar receivers, variable delimiters, mutation forms, generated
carriers or tagged-record evaluation. The earlier Lua observations above remain dated.

The CLI build passes in 16m27s. Retained project-local evidence:

- `.linkedspec-data/scratch/startup74-cli-build.log`: 798,454 bytes; SHA-256 `4391b9436291964c11d063d3cf368852c741ce67321ba0e5c5361313a18ec00b`.
- `.linkedspec-data/scratch/startup74-split-perl.jsonl`: 3,962 bytes; SHA-256 `f527a8687ecbe4e16d838c083682821560afe9a8b652f199ce5a071707219841`.
- `.linkedspec-data/scratch/startup74-split-rust.jsonl`: 1,840 bytes; SHA-256 `95799672aa2d9f4bc7f0148d276700880a84c3ccbfa5856098e370b5be65d578`.

The measured `rust/target/debug/linkedspec-rust` binary is 34,992,496 bytes with
SHA-256 `ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`.
Its hash was checked after comparison. This identifies the measured artifact;
fresh clones must build their own current binary using the command below.

The initial collector incorrectly treated optional stdout phase trace as pure JSON.
A separate raw capture confirmed the documented trace protocol and successful control
value. The accepted comparison omits that flag; only the zero-byte failed-collector
file was removed before it. No product trace defect is inferred.

Exact current paired comparison:

```bash
bash tools/run_cargo_local.sh build --manifest-path rust/Cargo.toml --locked --offline --jobs 1 -p linkedspec-runtime --bin linkedspec-rust &&
bash tools/project_data_run.sh env PERL5LIB= PYTHONDONTWRITEBYTECODE=1 python3 - <<'SPLIT_BOUNDARIES'
import json,subprocess
cases=[
 ('literal_trailing','a,b,','","'),
 ('empty_source','','","'),
 ('empty_literal_ascii','ab','""'),
 ('empty_literal_unicode','éx','""'),
 ('empty_source_empty_literal','','""'),
 ('empty_regex_ascii','ab','/(?:)/'),
 ('lookahead_control','ab','/(?=b)/'),
]
perl=r'''use strict;use warnings;use Encode qw(decode FB_CROAK);use JSON::PP;my$s=decode("UTF-8",$ARGV[0],FB_CROAK);my(%ctx,$src);my$p=eval{LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src)};my$ce="$@";my$in="xhello";my($v,$ie);if(ref($p)eq"CODE"){$v=eval{$p->(\$in)};$ie="$@"}my@lowered=grep{/\bsplit\b/}split(/\n/,$src//'');print JSON::PP->new->canonical->utf8->allow_nonref->encode({compiled=>ref($p)eq"CODE"?1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error},lowered_split_lines=>\@lowered}),"\n";'''
for identity,text,delimiter in cases:
 source='Top::\n I { return(split('+json.dumps(text,ensure_ascii=False)+', '+delimiter+')) }\n /x/ -> Done\nDone:\n /[a-z]+/\n'
 for route,args in [
  ('perl',['perl','-Iperl','-MLinkedSpec','-e',perl,source]),
  ('rust',['rust/target/debug/linkedspec-rust','--inline-spec',source,'--input','xhello']),
 ]:
  result=subprocess.run(args,capture_output=True,text=True,timeout=1800)
  print(json.dumps(dict(case=identity,route=route,spec=source,exit=result.returncode,stdout=result.stdout,stderr=result.stderr),ensure_ascii=False),flush=True)
SPLIT_BOUNDARIES
```

October27 TYPE23.1.2 public native/fresh controls still reproduce per-row fields,
missing tagged trailing items and counter0 for empty source. Basic records and
later DSL carried-copy independence already work. Literal/named scalar receiver
tails call an undefined host helper; trim-prefix stops at null. Substitution
retains raw dot DSL, embeds fields in map and omits pure split's -1; dynamic
delimiter/tag expression blocks also leak raw DSL. tagged-record-string-bridge.md
freezes ordinary eager argument/pure-split-reuse prerequisite22.1.1, then receiver
repair22.1.2 and independent other backends22.2-.5. This follows the existing
helper's documented eager semantics, preserves each backend's pure-split policies
and conversion domains, and does not close SESSION33's full six-runtime/empty/
zero-width/variable-regex/context admission. Current primary teaching is qualified
until repair, not silently declared portable. New retained probe:
`bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_tagged_record_results.pl`.

TYPE45.19 reconciles the old Phase0 map/split source assertion against existing
22.1 eager staging/pure-split reuse:1RED/6healthy ->7 GREEN. Original helper
expression/declaration heredoc/other6 assertions remain exact. Public native/
fresh2 execute the original initializer and preserve carried String1/source;
direct producer36 retains SDTF/once-only/empty/trailing/kinds/DSL copy bounds.
Production unchanged. Actual inputs/producers/RED-GREEN retained in
perl-phase0-split-tagged-oracle-intake.json.gz; broader SESSION33 boundaries above
remain separately owned, with no new global split/depth/peer admission.

---
id: julia-contract-consumer-reading
title: Julia contract consumer reading distinguishes callable diagnostic coverage and preserves exact history
answers:
  - which Julia contract consumers are completely read at startup group 34
  - does the Julia diagnostic codeblock fixture construct a callable literal
  - does printing an actual Julia callable execute its body
  - which task strengthens Julia diagnostic callable literal coverage
  - why does the mdBook build warn that its search index is very large
  - which task owns mdBook search index growth and usability
  - which change history segment did Julia reading group 34 create
  - how do I verify Julia group 34 history rollover preservation
date: 2026-09-11
status: exact reading and focused proof complete; diagnostic coverage correction .2.25 pending
tags: [julia, startup, reading, contracts, diagnostics, callable, history]
evidence: "JULIA-STARTUP-READING.1.34 reads five ranges/1500 fragments/55896 bytes; five existing consumers pass1017 assertions and actual callable diagnostic controls pass12. CHANGES rollover preserves213 clean lines/12545 bytes in4979-6e4108166552 under unchanged ADR0115 limits."
reverify:
  - "Run the repository-managed bash blocks below."
---

## Exact reading and proof scope

Eight untruncated windows read the callable consumer670-1012, named-mark1-94,
diagnostic1-310, duplicate-slot1-434 and gap1-319 ranges. The first four consumers
are complete; gap source after319 remains unread. Coverage reaches34/52 groups,
49,425 lines /1,721,486 bytes and47 complete files. Ordered range SHA-256 is
8e34677c9b2e371c510b70845f6215389eab67c0bdbf9aa5cf86ccd3fcc9be04.

| Range | Bytes | Raw SHA-256 |
| --- | ---: | --- |
| callable670-1012 | 14508 | 335cc2710ce483e6c203e89473e4eb01262eed3c6676812a158cda12706e0fc3 |
| named-mark1-94 | 3189 | 33af43ba47d53e3fbaa10ae3f4778c05e8db0efdc1a3473ab066c792d6431e8a |
| diagnostic1-310 | 11628 | f3ceaf02b9f4a7ff18c72e8b7512775a60d1b489ba55847a1c2cd3ed4463b7cd |
| duplicate-slot1-434 | 16490 | afc02f3e84c7e07831ba4e3bff217ddae3c25873e255227e69156b8ade9e5d1b |
| gap1-319 | 10081 | 270da9d26d3559dd109ccf6da2986e1a170b407f7458089b5caca3604f06488f |

Callable completion covers final non-codeblock failures, exact literal/signature
fields, containing Unicode coordinates, nested spans, deferred construction,
function transport and semantic callable shapes. Actual loaded emitted modules
and reconstructed JSON are separate roles. The seven-helper named-mark inventory
runs native/generated-plan/reconstructed/primary roles, without an independent
emitted-module invocation in that particular13-assertion consumer.

Diagnostics cover exact Unicode events, native/traced aliases, arity before
effects, immediate exit, exact caller exception identity and generated outcomes.
Duplicate-slot's15 declared roles run exactly once, including actual emitted
loading, trace identity and malformed compiled index rejection. Those index guards
do not close the reconstructed named/null identity gap .2.23.

The gap prefix retains managed offline emitted-host setup, authored named/numeric/
unindexed metadata, exact source identities, reorder semantics and eligibility
comparisons. Its later lifecycle/rollback/serialization/emitted-role source is not
yet read, although the complete consumer runs as direct-dependent focused proof.
All prior repairs, notably .2.1/.2.8/.2.23, remain pending.

## Diagnostic fixture coverage correction — .2.25

The exact helper `_diagnostic_output_render_expression` at
`julia/test/diagnostic_output_contract_test.jl:34` maps the codeblock row at48 to
`{ return(undef) }`. The native parser identifies that expression as block_value,
not codeblock_literal. The permanent row therefore does not prove rendering of an
actual callable value.

A separate `{|| state = "wrong"; return("never") }` control parses as a typed
literal. Native and generated-plan execution both retain state=before and emit
exactly one empty print event. Eager-block comparisons also produce the expected
empty event. Twelve assertions include exact helper selection, both AST kinds,
values and event records. Runtime behavior is correct for these controls; .2.25
owns a permanent regression correction and counterpart-fixture audit rather than
a runtime repair. No fresh emitted literal-print or independent counterpart run
is claimed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP34_DIAGNOSTIC'
using LinkedSpecJulia,JSON3,Test
const selected=Set{Symbol}()
for expression in Meta.parseall(read("julia/test/diagnostic_output_contract_test.jl",String)).args
 if expression isa Expr && expression.head==:function && expression.args[1] isa Expr && expression.args[1].args[1]==:_diagnostic_output_render_expression
  Core.eval(Main,expression);push!(selected,:_diagnostic_output_render_expression)
 end
end
@testset "group34 actual callable diagnostic rendering" begin
 @test selected==Set([:_diagnostic_output_render_expression])
 legacy=_diagnostic_output_render_expression(Dict("kind"=>"codeblock"))
 literal="{|| state = \"wrong\"; return(\"never\") }"
 @test legacy=="{ return(undef) }"
 @test parse_action_expression(legacy) isa ActionBlockValueExpr
 @test parse_action_expression(literal) isa ActionCodeblockLiteralExpr
 for (expression,state) in [(legacy,"before"),(literal,"before")]
  compiled=compile_spec(parse_spec("Top::\n /x/\n E { state = \"before\"; print("*expression*"); return(state) }\n"))
  for generated in (false,true)
   events=RuntimeDiagnosticOutputEvent[]
   value=generated ? execute_generated_parser_v2(compiled,build_generated_rule_plan(compiled),"x","diagnostic-literal-reading.spec";diagnostic_output_sink=e->push!(events,e)) : runtime_execute(LinkedSpecRuntimeEngine(compiled),"x";diagnostic_output_sink=e->push!(events,e)).value
   @test value==state
   @test [to_json(e) for e in events]==[Dict("helper_name"=>"print","message"=>"","rule_label"=>"Top")]
  end
 end
end
JULIA_GROUP34_DIAGNOSTIC
```

## Existing focused consumers

Callable125/118/239, named-mark13, diagnostic82, duplicate121 and gap105/33/46/105/30
pass1017 assertions. Neutral checks pass named7 helpers/3 mutations,
diagnostic3 helpers/11 render rows/6 scenarios/8 complete/20 mutations,
callable23 mutations, gap9/0/63 with public8/15/10/34, and duplicate7/0/59.
No full component/canonical gate, dependency build or runtime defect closure.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP34_EXISTING'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
include("julia/test/callable_codeblock_literal_contract_test.jl")
include("julia/test/complete_named_mark_contract_test.jl")
include("julia/test/diagnostic_output_contract_test.jl")
include("julia/test/duplicate_regex_slot_identity_contract_test.jl")
include("julia/test/inter_match_gap_capture_contract_test.jl")
JULIA_GROUP34_EXISTING
bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py
bash tools/run_python_project_data.sh tools/check_diagnostic_output_contract.py
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py
```

## Exact governed history rollover

Prepending the complete seven-line .1.34 record required rollover at465 lines.
The tool preserved clean commit148606661bbeb4c505196cbcfab870b5ac81872a CHANGES
lines246-458, blob95f1909a8e3d844fd60b79c9fdcafa61fc71d9d6, as213 lines/12545 bytes
in `docs/history/changes/segment-4979-6e4108166552.md`, SHA-256
6e41081665523985eebc3e6f93a0070419e90be21f2f02898b4d8f25844ae35b.
The tool initially retained252 lines/15238 bytes. One terminal separator LF is
removed from the hot root for whitespace hygiene and restored by exact
reconstruction; no archive byte is normalized. Previous archive bytes
and manifest order are unchanged; the new complete archive query equals this
segment followed by the old query:48920 lines/3536491 bytes, SHA-256
471d05adb19e298948dbd7239d1f18112244cf6f37eb8cf02d67a81086feee18.

At this slice the root is251 lines/15237 bytes, manifest33 lines/18767 bytes and
collection34 files/49204 lines/3570495 bytes. Every ADR0115 limit remains unchanged.
Engineering notes require no rollover. The following replay is read-only and
remains stable after later hot-root updates; it addresses the exact segment.

```bash
bash tools/project_data_run.sh python3 - <<'JULIA_GROUP34_HISTORY'
from pathlib import Path
import subprocess,json,hashlib
base='148606661bbeb4c505196cbcfab870b5ac81872a'
path='docs/history/changes/segment-4979-6e4108166552.md'
raw=Path(path).read_bytes()
source=subprocess.check_output(['git','show',base+':CHANGES.md'])
assert raw==b''.join(source.splitlines(keepends=True)[245:458])
assert len(raw)==12545 and raw.count(b'\n')==213
assert hashlib.sha256(raw).hexdigest()=='6e41081665523985eebc3e6f93a0070419e90be21f2f02898b4d8f25844ae35b'
old=[json.loads(line) for line in subprocess.check_output(['git','show',base+':docs/history/changes/manifest.jsonl']).splitlines()]
current=[json.loads(line) for line in Path('docs/history/changes/manifest.jsonl').read_bytes().splitlines()]
position=next(i for i,row in enumerate(current) if row.get('target_path')==path)
assert current[position+1:]==old[1:]
oldbytes=b''
for row in old[1:]:
 content=Path(row['target_path']).read_bytes()
 assert content==subprocess.check_output(['git','show',base+':'+row['target_path']])
 oldbytes+=content
assert hashlib.sha256(raw+oldbytes).hexdigest()=='471d05adb19e298948dbd7239d1f18112244cf6f37eb8cf02d67a81086feee18'
assert subprocess.check_output(['perl','tools/read_document_history.pl','--surface','change_history','--segment','4979'])==raw
print('PASS exact213-line clean source, old manifest/archive identity and indexed segment retrieval.')
JULIA_GROUP34_HISTORY
```

Related: [[julia-diagnostic-output-helpers]], [[julia-callable-codeblock-literal-state]],
[[julia-governed-capture-mark-parity]], [[julia-duplicate-regex-slot-identity-admission]],
[[bounded-change-notes-history-contract]], [[julia-reading-history-capacity-admission]].

## Book search warning intake — startup .41.9

The initial .1.34 book render on2026-09-11 succeeds but warns that the decoded
search index is10001369 bytes. Its generated JavaScript wrapper is10023516 bytes.
There are913 indexed section records; the inverted index contributes7830230 compact
UTF-8 JSON bytes and the document store2109423. The largest stored bodies include
Project Status / Ongoing91038 bytes and Documentation pressure containment76931.
These are initial-build measurements, not fixed limits or a measured user-visible
failure. Rebuilding after documentation changes can change the counts and hashes.

`docs/linkedspec-book/book.toml` has no search override. Startup .41.9 owns bounded
measurement and repair, including representative query correctness and browser
parse/search performance, preservation of navigable evidence and complete teaching,
and recurrence proof. .41.8 includes this dependency. No configuration, renderer,
search behavior or existing documentation has been removed in this reading slice.

```bash
bash tools/run_mdbook_local.sh
bash tools/project_data_run.sh python3 - <<'JULIA_GROUP34_BOOK_SEARCH'
from pathlib import Path
import ast,json
paths=list(Path('docs/linkedspec-book/book').glob('searchindex-*.js'))
assert len(paths)==1, paths
p=paths[0]
s=p.read_text().strip()
payload=ast.literal_eval(s.split('JSON.parse(',1)[1][:-3])
data=json.loads(payload)
print('search artifact bytes',p.stat().st_size,'decoded bytes',len(payload.encode()))
for key in ['index','documentStore']:
 print(key,'compact bytes',len(json.dumps(data['index'][key],ensure_ascii=False,separators=(',',':')).encode()))
docs=data['index']['documentStore']['docs']
print('indexed sections',len(docs))
for size,title in sorted([(len(d['body'].encode()),d['breadcrumbs']) for d in docs.values()],reverse=True)[:5]:
 print(size,title)
JULIA_GROUP34_BOOK_SEARCH
```

---
id: lua-reading-commit-closeout-audit
title: Lua independent reading audit preserves source commits and unresolved verification
answers:
  - have all 51 Lua reading commits been independently verified
  - which commit completes physical Lua source reading
  - what verification blocks Lua reading parent closeout
  - does complete Lua source reading close its runtime defects
  - which failed and excluded Lua checks remain after reading
  - what exact one-time Lua reading closeout exception is proposed
  - do earlier capacity or Julia approvals waive Lua closeout verification
date: 2026-09-13
status: Lua reading closed under director-authorized ADR0119; all repairs remain open
tags: [lua, startup, reading, audit, continuity, verification]
evidence: "LUA-STARTUP-READING.3.1; physical checkpoint 7ead9e003b2cfb1bb356f990d8644e2d8bcad3d4; baseline baeb984e36a94a15951cd23d4c52def5064cdaca."
reverify: "Run LUA_READING_COMMIT_AUDIT, then LUA_READING_VALIDATION_BOUNDARIES below. The second recipe checks retained artifacts; it runs no Lua tests, excluded native regex case, Cargo build or canonical gate."
---

## September 13 director disposition

After reviewing the exact proposal and its explanation, the director authorizes
unblocking and continuing the read-only work while avoiding unnecessary RGX/PGEN
rebuilds. ADR0119 records this new scope; .3.2 closes only Lua reading and routes
supporting startup .3.7. Both recipes below pass again; all 145 repair nodes and
failed/excluded results remain exact. No canonical CI, fresh full Lua/PUC5.4 pass
or dependency build is claimed. The earlier no-build wording meant the build-reuse
requirement; it is not a blanket prohibition or a restriction on source reading.
The original audit and pending proposal below remain dated evidence from .3.1.

# Independent reading audit

Checkpoint `7ead9e003b2cfb1bb356f990d8644e2d8bcad3d4` contains all 51 committed
Lua reading children. The independent audit reconstructs 99 files, 71,268 physical
LF lines and 2,732,450 bytes through 149 exact ranges. Splitting one oversized MCP
line yields 71,269 reading fragments without duplicating bytes. Each of the 51
Git source trees and the current source bytes remain baseline-identical.

Every child has one unique commit subject, a byte-exact historical task body and
its original first-parent MEMORY activation. Each links its own committed
comprehension/replay card; all 51 touched cards remain checkpoint-identical.
Some historical nodes put comprehension in linked evidence rather than a field
named Comprehension. The audit preserves those original forms. Its structural
checks confirm the evidence links and identities; they do not grant reading
credit or replace the completed physical reading and comprehension records.

All 35 repair roots and their 145 pending nodes remain byte-exact. Reading has
not fixed them. The active startup .3.6 Reading owner pointer still named only
33 roots at activation; this audit corrects that current pointer to .2.1-.2.35.
No historical reading record, source, test, contract, dependency, gate or accepted
decision changes. Named-argument work remains approved and parked.

| Ordered evidence | SHA-256 |
| --- | --- |
| 51 commit/parent/subject/card records | `0eed64c93f6d25783eec492e4d1342c1f4ec03e10607f24de15381851a3e2365` |
| Lua NUL-delimited Git mode/blob/path records | `0d2904c201290e8617a585bdb487a9dcd8bfcfb051cae31bd6e40ec597efd765` |
| 51 linked-card/task-body records | `e08ecf5bc3946bcfd170600d516ad31fc417b56527db2017056f7027c1b8d042` |
| 51 fact path/size/hash records | `698287739e74a2aaf654fa30e3135e0989f4bf0f3e921471771dc199156f8c75` |
| 145 pending repair ID/body-hash records | `3040f28e678f533787eaabb8b04d766d1693d469c8609d406e5f8f978a99e4d2` |

# Validation boundaries

Nine committed retained-result verifiers (.1.41, .1.42 and .1.45-.1.51) pass
against their exact generated verifier payloads, current scoped bytes and saved
results. These are fresh evidence checks, not fresh runtime executions. They
retain prefix/full-suite distinctions, per-host outcomes and mutation controls.
Earlier child results remain dated evidence; no sum of overlapping runs is
presented as a complete component gate.

| Retained result | Disposition |
| --- | --- |
| Generated semantic observation, .1.45 | PUC 5.5: **FAIL**, 79/80, exit 1; LuaJIT: 80/80, exit 0 |
| Native semantic observation, .1.46 | PUC 5.5: **FAIL**, 120/121, exit 1; LuaJIT: 121/121, exit 0 |
| Package .1.41/.1.42 selections | 25 and 17 complete groups per host pass; four native-error groups remain excluded |
| Staged/lifecycle/typed/classifier consumers, .1.49 | 890/109/240/1706 assertions per host pass; identity prefix 341 remains distinct from its later full suite |
| Unicode identity/negative/routes, .1.50 | Full 359/1542/179 assertions per host pass |
| Final full write and dormant authority, .1.51 | 438/273 assertions per host pass; dormant discovery remains unchanged |
| Failure-state fixture controls, .1.50/.1.51 | Nineteen individual wrong expected bindings survive per host, in both prefix and full write suites; .2.35 remains open |
| Public-selector baseline, startup .28.7 | **FAIL** remains recorded: 62 files, 35 references, 34 classified versus expected 32; unchanged rejected fence context and checker |

The PUC generated failure says `nil callback exact identity: expected nil, got
<no error object>`; the native failure says `nil callback value preserved:
expected nil, got <no error object>`. Reading .1.17 isolated the host behavior
with bare `pcall(error, nil, 0)`; .2.2 owns declared-runtime identity and proof.
Current read-only version queries still find PUC 5.5.1 and LuaJIT
2.1.1788460057. Commands `lua5.4` and `lua54` are unavailable on PATH; this does
not establish that no other installation exists anywhere. The installed OS and
toolchain are necessary read-only dependencies; no off-volume project data,
installation or host-cache mutation is introduced.

The excluded `lua/test/run.lua` ranges are 5193-5215, 6820-6860, 6861-6907 and
6908-6977. They cover matching failures, helper matches, pure split and statement
regex substitution. Whole groups, including their valid cases, remain excluded.
The earlier .2.3 observation recorded native error-format detail loss on LuaJIT
and a PUC crash. This audit never repeats that path. Safe malformed source,
JSON, AST and UTF-8 cases in other consumers do not imply native regex-error proof.

`tools/run_lua_local.sh` is baseline-identical at 14,151 bytes, SHA-256
`5ae54713bf65d46d29ed8d1305b0c0865d8cdcb2ff471e37ee7a20664e3ff0bd`.
Its fail-fast primary native observation precedes generated observation and the
unfiltered package runner. The later LuaJIT leg also names the full package.
There is no passing fresh full Lua component gate or declared PUC 5.4 proof at
this boundary; the audit does not claim downstream gate sections ran.

The dated CI build-reuse evidence replays unchanged: eight watched inputs, two
present and six absent, and eleven retained build stages totaling 4,682 seconds.
Six canonical/environment/Cargo/recurring drivers remain byte-identical to startup
.80.0 commit `eaf4331e71bbc8e0c3f04162fb915bddc8cfea96`. They retain dependency-building
routes; build-on-submodule-update lifecycle implementation stays in .80.1-.4.
This does not prove the cost or result of a new gate. No canonical CI, new receipt
or PGEN/RGX build is run by this audit.

# Exact proposal — pending director approval

`LUA-STARTUP-READING.3.1` completes only this focused audit and proposal. Its
parents .1/.3 and startup .3.6 stay open. The concrete requested disposition is:

1. Permit **only LUA-STARTUP-READING.3.2**, the Lua reading closeout, to use focused
   verification without canonical CI or its receipt. Explicitly accept the
   absence of a passing fresh full Lua component gate and declared PUC 5.4 proof
   for this reading-only boundary. Retain the failed and excluded results above.
2. Reverify this committed source/commit/card/repair audit and the exact retained
   validation boundaries; verify current candidate preservation, Knowledge,
   memory, both bounded histories, rendered book and all nine normal doctrines.
   Normal hooks remain enabled. Record approval in a scoped decision; change no
   standing policy, checker, receipt requirement or bypass mechanism.
3. Close only Lua reading .1, audit/closeout .3/.3.2 and startup .3.6. Route the
   next action to supporting-code reading startup .3.7 (158 owned inventory
   entries). Leave all 35 Lua repair roots/145 nodes, startup .28.7, .37.1, .80,
   .81, .82 and every other repair pending. Supporting .3.7-.3.10, aggregate
   .3.11, formal book .4 and policy .5 remain prerequisites; named arguments stay
   parked. No source repair, capacity increase, toolchain change, dependency
   build, push or later milestone exception is authorized by this proposal.

`COMMIT.md` and ADR0073 require canonical proof at parent/milestone closeout.
ADR0117 is Julia-only; ADR0118's verification exception is containment .14-only
and explicitly waives no later milestone. Earlier Granted replies therefore do
not authorize this distinct Lua closeout. No approval is inferred here.
Without a new scoped disposition, .3.2 retains its canonical requirement and
cannot close under the current no-build and unresolved validation constraints.
Changing prerequisite order or authorizing repairs/builds would be a separate
explicit direction, not an action taken by this audit.

# Reproduction

The first recipe reproduces the ordered report from committed Git history.
The second verifies retained local artifacts referenced by the earlier committed
cards and queries installed runtime versions only. Missing retained artifacts
must be reconciled explicitly; do not replace these checks with a full package
run or replay the excluded native probes. All output paths derive from the repo.
A legitimate later source or repair change requires a delta audit against this
frozen checkpoint; an expected identity mismatch does not undo historical proof.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_READING_COMMIT_AUDIT'
from pathlib import Path
import contextlib,hashlib,io,json,re,subprocess
BASE='baeb984e36a94a15951cd23d4c52def5064cdaca'
CHECKPOINT='7ead9e003b2cfb1bb356f990d8644e2d8bcad3d4'
TREE='docs/tasks/LUA-STARTUP-READING.md'; q=chr(96)
def git(*args):return subprocess.check_output(['git',*args])
def digest(v):return hashlib.sha256(json.dumps(v,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
def nodes(text):return dict(re.findall(r'^- ID: '+q+'([^'+q+']+)'+q+r'\n(.*?)(?=^- ID: |^## |\Z)',text,re.M|re.S))
def field(n,name):
 rows=re.findall(r'^  '+re.escape(name)+r': (.+)$',n,re.M)
 assert len(rows)==1,(name,len(rows));return rows[0]
current=nodes(Path(TREE).read_text())
checkpoint=nodes(git('show',CHECKPOINT+':'+TREE).decode())
recipe=Path('docs/knowledge/lua-startup-reading-coverage.md').read_text().split("<<'LUA_READING_COVERAGE'\n",1)[1].split('\nLUA_READING_COVERAGE',1)[0]
ns={}
with contextlib.redirect_stdout(io.StringIO()):exec(compile(recipe,'LUA_READING_COVERAGE','exec'),ns)
assert ns['done']==51
subjects={}
for row in git('log','--format=%H%x09%s',BASE+'..'+CHECKPOINT).decode().splitlines():
 commit,subject=row.split('\t',1);subjects.setdefault(subject,[]).append(commit)
source_tree=git('ls-tree','-r','-z',BASE,'--','lua')
records=[];knowledge=set();prior=None;comprehension=[]
for i in range(1,52):
 leaf='LUA-STARTUP-READING.1.'+str(i);n=current[leaf]
 assert n==checkpoint[leaf],leaf
 assert field(n,'Status')==q+'done'+q
 match=re.fullmatch(q+'([^'+q+']+)'+q+r'\.?',field(n,'Commit'));assert match,leaf
 subject=match[1];assert subject.startswith(leaf+' - ') and len(subjects.get(subject,[]))==1,leaf
 commit=subjects[subject][0];parent=git('rev-parse',commit+'^').decode().strip()
 committed=nodes(git('show',commit+':'+TREE).decode())[leaf]
 assert committed==n,(leaf,'historical reading node changed')
 for name in ['Scope','Baseline evidence','Verification tier','Focused checks','Canonical trigger','Verification']:
  assert field(n,name) not in [q+'pending'+q,q+'in progress'+q],(leaf,name)
 memory=git('show',commit+':MEMORY.md').decode()
 activation=re.search('activation_commit: '+q+'([0-9a-f]+)'+q,memory)[1]
 assert git('rev-parse',activation).decode().strip()==parent,(leaf,activation,parent)
 if prior:subprocess.run(['git','merge-base','--is-ancestor',prior,parent],check=True)
 assert git('ls-tree','-r','-z',commit,'--','lua')==source_tree,leaf
 touched=git('diff-tree','--no-commit-id','--name-only','-r',commit,'--','docs/knowledge/').decode().splitlines();assert touched,leaf
 refs=sorted(set(re.findall(r'docs/knowledge/[a-z0-9-]+[.]md',n)))
 owners=sorted(set(touched)&set(refs));assert owners,(leaf,'no owned linked comprehension card',refs,touched)
 for path in owners:
  raw=git('show',commit+':'+path);s=raw.decode()
  assert len(raw)>1000 and s.startswith('---\n') and re.search(r'^answers:\n',s,re.M),path
  assert re.search(r'^#',s,re.M) and '```' in s,path
 comprehension.append([leaf,owners,hashlib.sha256(n.encode()).hexdigest()])
 knowledge.update(touched);records.append([leaf,commit,parent,subject,owners]);prior=commit
assert prior==CHECKPOINT
for ref in [CHECKPOINT,'HEAD']:assert git('ls-tree','-r','-z',ref,'--','lua')==source_tree
assert not git('diff','--name-only',BASE,'--','lua').strip()
assert not git('diff','--cached','--name-only','--','lua').strip()
assert not git('ls-files','--others','--exclude-standard','--','lua').strip()
knowledge_records=[]
for path in sorted(knowledge):
 raw=Path(path).read_bytes();assert raw==git('show',CHECKPOINT+':'+path),path
 assert raw.startswith(b'---\n') and re.search(rb'^answers:\n',raw,re.M),path
 knowledge_records.append([path,len(raw),hashlib.sha256(raw).hexdigest()])
repairs=[]
for leaf in sorted(checkpoint):
 if re.fullmatch(r'LUA-STARTUP-READING\.2\..+',leaf):
  assert current[leaf]==checkpoint[leaf],leaf
  assert field(current[leaf],'Status')==q+'pending'+q,leaf
  assert re.search(r'^  (?:Acceptance|Children): ',current[leaf],re.M),leaf
  repairs.append([leaf,hashlib.sha256(current[leaf].encode()).hexdigest()])
roots=sorted({r[0].split('.')[2] for r in repairs},key=int);assert roots==[str(i) for i in range(1,36)]
assert Path('docs/tasks/PARSER-AUTHORING-APIS.md').read_bytes()==git('show',CHECKPOINT+':docs/tasks/PARSER-AUTHORING-APIS.md')
report={'checkpoint':CHECKPOINT,'baseline':BASE,'source_paths':99,'physical_lines':71268,'fragments':71269,'source_bytes':2732450,'ranges':149,'children':51,'reading_commits':records,'commit_records_sha256':digest(records),'source_git_tree_sha256':hashlib.sha256(source_tree).hexdigest(),'comprehension_records':comprehension,'comprehension_sha256':digest(comprehension),'knowledge_paths':len(knowledge_records),'knowledge_records':knowledge_records,'knowledge_sha256':digest(knowledge_records),'repair_roots':len(roots),'repair_nodes':len(repairs),'repair_records':repairs,'repair_sha256':digest(repairs),'current_source_delta_paths':0}
expected={'commit_records_sha256': '0eed64c93f6d25783eec492e4d1342c1f4ec03e10607f24de15381851a3e2365', 'source_git_tree_sha256': '0d2904c201290e8617a585bdb487a9dcd8bfcfb051cae31bd6e40ec597efd765', 'comprehension_sha256': 'e08ecf5bc3946bcfd170600d516ad31fc417b56527db2017056f7027c1b8d042', 'knowledge_sha256': '698287739e74a2aaf654fa30e3135e0989f4bf0f3e921471771dc199156f8c75', 'repair_sha256': '3040f28e678f533787eaabb8b04d766d1693d469c8609d406e5f8f978a99e4d2', 'knowledge_paths': 51, 'repair_roots': 35, 'repair_nodes': 145}
for key,value in expected.items():assert report[key]==value,(key,report[key],value)
p=Path('.linkedspec-data/scratch/lua31');p.mkdir(parents=True,exist_ok=True);(p/'audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['reading_commits','comprehension_records','knowledge_records','repair_records']},indent=2))
print('PASS exact source coverage, unique reading commits, byte-exact historical reading nodes, linked comprehension/replay evidence, first-parent MEMORY activations, and open repair preservation. This does not close the milestone or reclassify any failed check.')
LUA_READING_COMMIT_AUDIT
```

```bash
bash tools/project_data_run.sh python3 - <<'LUA_READING_VALIDATION_BOUNDARIES'
from pathlib import Path
import ast,contextlib,hashlib,io,json,re,shutil,subprocess
p=Path('.linkedspec-data/scratch/lua31')
report=json.loads((p/'audit.json').read_text())
records=[]
for i in [41,42,45,46,47,48,49,50,51]:
 card=Path(report['reading_commits'][i-1][4][0]).read_text()
 found=[]
 for block in re.findall(r'```bash\n(.*?)\n```',card,re.S):
  match=re.search(r"<<'(LUA_[A-Z0-9_]+)'\n(.*?)\n\1",block,re.S)
  if not match:continue
  for n in ast.walk(ast.parse(match[2])):
   if (isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute)
       and n.func.attr=='write_text' and len(n.args)==1
       and isinstance(n.args[0],ast.Constant) and isinstance(n.args[0].value,str)
       and isinstance(n.func.value,ast.BinOp)
       and isinstance(n.func.value.right,ast.Constant)
       and n.func.value.right.value=='verify.py'):
    found.append(n.args[0].value)
 assert len(found)==1,(i,len(found))
 path=Path(f'.linkedspec-data/scratch/lua1{i}/verify.py')
 assert path.read_text()==found[0],path
 output=io.StringIO()
 with contextlib.redirect_stdout(output):exec(compile(found[0],str(path),'exec'),{})
 text=output.getvalue();print(text,end='')
 records.append([i,hashlib.sha256(found[0].encode()).hexdigest(),text])
# This executes only the dated read-only evidence recipe, never Cargo or Lua.
card=Path('docs/knowledge/rust-ci-pgen-missing-input-rebuilds.md').read_text()
recipe=card.split("<<'CI_BUILD_REUSE_OBSERVATION'\n",1)[1].split('\nCI_BUILD_REUSE_OBSERVATION',1)[0]
output=io.StringIO()
with contextlib.redirect_stdout(output):exec(compile(recipe,'CI_BUILD_REUSE_OBSERVATION','exec'),{})
print(output.getvalue(),end='')
git=lambda *args:subprocess.check_output(['git',*args])
intake=git('rev-parse','eaf4331e').decode().strip()
assert intake=='eaf4331e71bbc8e0c3f04162fb915bddc8cfea96'
paths=['tools/run_ci_local.sh','tools/project_data_env.sh','tools/run_cargo_local.sh',
 'tools/check_semantic_introspection_six_runtime.sh','tools/check_mcp_six_runtime.sh',
 'tools/check_duplicate_regex_slot_identity_five_backend.sh']
drivers=[]
for path in paths:
 raw=Path(path).read_bytes();assert raw==git('show',intake+':'+path),path
 drivers.append([path,len(raw),hashlib.sha256(raw).hexdigest()])
lua=Path('tools/run_lua_local.sh').read_bytes()
assert lua==git('show',report['baseline']+':tools/run_lua_local.sh')
text=lua.decode();assert text.startswith('#!/usr/bin/env bash\nset -euo pipefail\n')
native=text.index('lua/test/semantic_index_runtime_observation_native_test.lua')
generated=text.index('lua/test/semantic_index_runtime_observation_generated_routes_test.lua')
package=text.index('lua/test/run.lua')
assert native<generated<package
assert text.count('lua/test/run.lua')==2
assert 'progressive_span_dispatch_authority_test' not in text
canonical=Path(paths[0]).read_text()
assert 'cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract' in canonical
assert 'bash "$REPO_ROOT/tools/run_lua_local.sh"' in canonical
versions={}
for command in ['lua','lua5.4','lua54','luajit']:
 if shutil.which(command) is None:versions[command]=None;continue
 proc=subprocess.run([command,'-v'],text=True,capture_output=True,check=True)
 versions[command]=(proc.stdout+proc.stderr).strip()
assert versions['lua'].startswith('Lua 5.5.1 ')
assert versions['luajit'].startswith('LuaJIT 2.1.1788460057 ')
assert versions['lua5.4'] is None and versions['lua54'] is None
print('PASS current command identities: PUC5.5.1 and LuaJIT2.1.1788460057; lua5.4/lua54 unavailable on PATH. Read-only installed toolchain queries only.')
selector=json.loads(Path('.linkedspec-data/scratch/lua18/public-selector-references.json').read_text())
assert selector['base']=='f80a2bde7684d31df9655273023b179e98d64e58'
assert selector['public_files']==62 and len(selector['references'])==35 and selector['expected']==32
bad=[r for r in selector['references'] if not r['classified']]
assert len(bad)==1 and bad[0]['line']==857
assert bad[0]['path']=='docs/linkedspec-book/src/overview/project-status.md'
assert bad[0]['context'] in Path(bad[0]['path']).read_text()
checker=Path('tools/check_public_aggregate_selector_surface.py').read_bytes()
assert hashlib.sha256(checker).hexdigest()=='e51bc0fd45472b844f72d8778c70f96424216306d91822be33e83e48e5d0ecec'
print('PASS retained startup .28.7 census: 62 public files, 35 references, 34 classified against expected32; original rejected fence context and checker remain unchanged. This remains a failed baseline check, not current canonical proof.')
result={'retained_verifiers':records,'ci_intake':intake,'drivers':drivers,
 'lua_driver':[len(lua),hashlib.sha256(lua).hexdigest()],
 'ci_evidence_output':output.getvalue(),'runtime_versions':versions,
 'selector_baseline':[selector['base'],selector['public_files'],len(selector['references']),34,selector['expected']],
 'fresh_lua_test_runs':0,'dependency_builds':0}
(p/'boundaries.json').write_text(json.dumps(result,indent=2)+'\n')
print('PASS nine exact committed retained-result verifiers; six unchanged dependency drivers; baseline-identical Lua driver retains fail-fast ordering and unfiltered package discovery. No fresh component, canonical receipt, dependency build, or excluded regex execution.')
LUA_READING_VALIDATION_BOUNDARIES
```

Related facts: [[lua-startup-reading-coverage]], [[lua-final-source-consumer-reading]],
[[lua-semantic-query-observation-reading-and-evidence-gaps]],
[[lua-native-readme-and-action-ast-reading]],
[[lua-interpreter-helper-reading-and-false-delimiter-gap]],
[[rust-ci-pgen-missing-input-rebuilds]].

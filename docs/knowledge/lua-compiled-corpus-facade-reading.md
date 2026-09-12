---
id: lua-compiled-corpus-facade-reading
title: Lua compiled-state completion and corpus facade reading preserve exact selection and descriptor identities
answers:
  - what did Lua startup reading group six cover
  - what completes Lua compiled state validation
  - how does Lua corpus loading precede fixture selection
  - how does the Lua developer corpus runner choose exit status
  - which stale Lua corpus card still describes the primary CLI scaffold
  - what pure compiled-state checks support Lua reading group six
date: 2026-09-12
status: exact group six read; source unchanged and existing documentation repair extended
tags: [lua, reading, compiler, corpus, facade, descriptor, entry-rule]
evidence: "LUA-STARTUP-READING.1.6 reads four complete ranges /1500 fragments /58462 bytes from 4fc58d3cd6c268ac26514984bfe0a1de92d42b2e. Pure compiled-state checks pass 25 per installed host; regex-slot, callable-signature and cursor contracts pass. An independent census checks 105 corpus directories and 315 UTF-8 fixture files, without claiming Lua execution. Existing .2.1 owns the stale corpus-card primary-scaffold sentence."
reverify:
  - "Run the exact managed replay below on both installed Lua hosts."
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
  - "bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py"
---

# Exact physical reading

Activation is `4fc58d3cd6c268ac26514984bfe0a1de92d42b2e`; frozen source baseline
remains `baeb984e36a94a15951cd23d4c52def5064cdaca`. Ten untruncated windows
read compiled state 890–1049, 1050–1209, 1210–1369, 1370–1529; corpus 1–180,
181–360, 361–524; runner 1–102; facade 1–120 and 121–234.

| Path | Inclusive LF lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/compiled_spec.lua` | 890–1529 | 24706 | `f13641ad03002df1996e4632bc9c475b448c3e37dd853c3afc3d05d5e96735cb` |
| `lua/src/linkedspec/corpus.lua` | 1–524 | 17441 | `a834b19c101d711c8a8203aace9b79f476d17477c249673a83f8adb6b5cb778d` |
| `lua/src/linkedspec/corpus_runner.lua` | 1–102 | 3011 | `2a6d5672cb3ac6beea1cba9535a7e3355267d60c8eaf2b0625c7128bbb5106d5` |
| `lua/src/linkedspec/init.lua` | 1–234 | 13304 | `3d0176c5df9ac26b15ce31dc6781fe1fb65bf2fda775385ed1401929ee9bdf9f` |

Ordered-range SHA:
`682b3852a6e7ad6504ca42236a8b84f91d5eeb38d472836d4831100c5b661347`.
Cumulative: 6/51 groups, 8,445 fragments /342,343 bytes, fourteen complete files
and partial `init.lua`. The remaining facade and interpreter prefix belong to
.1.7. Incidental fixture/API inspection grants no additional reading credit.

# Comprehension and canonical reconciliation

The compiled suffix completes progressive rule/function effect closure and checks
recognition targets before returning compiled state. Regex slot validation binds
an effective parent pattern index to one authored child slot; identical pattern
text does not replace that structural identity. Compilation copies source through
typed SpecFile JSON, optionally validates syntax, builds the function registry and
last-definition state, resolves dependency regexes, then runs slot, selector,
write, mutation, staged, recursive and progressive validations in order.

Entry selection uses an explicit label, then the first effective authored marker,
then the first effective rule; missing/empty cases have typed stage/code records.
Internal JSON retains typed source/slot/body state. Outward descriptors project
mode-derived cursor policy, action/blind ownership, separate semantic and slot
edge rows, regex/capture metadata and function union records; handlers remain
compiled-state-only. These are projections, not an outward descriptor decoder.
Canonical homes: [[lua-compiled-spec-state]], [[lua-rule-local-cursor-descriptor]],
[[lua-outward-function-descriptor-union]] and [[lua-root-rule-selection-core]].

Corpus loading validates strict UTF-8, manifest format/count/name uniqueness,
exact directory membership and all required inputs before selection. Selection
preserves requested name order or applies non-negative offset/positive limit.
The executor uses automatic spec-defined function parsing, source validation,
compilation and source-identified runtime construction. Each fixture records typed
parse/validate/compile/execute failures without aborting subsequent fixtures;
match and compare failures are separate. Expected output is wrapped exactly once.
Runtime values are copied with table identity/cycles handled, trace emitters are
fresh and silent, and queries validate their typed result argument.

The developer runner validates by default, executes the full manifest only with
--execute, and returns 0 for success/help, 1 for recorded fixture failures, and
2 for argument/manifest errors. It is distinct from the parser-oriented primary
command. The facade prefix eagerly composes ordinary modules, lazily imports MCP,
returns copied backend status and forwards semantic, corpus, loading, AST,
function, compile, entry-selection and generated-source APIs to their owners.
Its parity constant is runtime-corpus-primary-cli. No module stub or fake facade
was used in this reading or proof.

Canonical corpus/runtime homes were read first: [[lua-corpus-manifest-io]],
[[lua-controlled-corpus-execution]], [[lua-full-corpus-gate]],
[[lua-native-spec-pipeline]] and [[lua-primary-cli-no-drift-closeout]]. Dated
suite counts are historical proof boundaries, not freshly measured totals.

# Existing documentation repair extension

The current-status corpus IO card ends by describing the primary command as an
explicit parser scaffold failure. This conflicts with the facade's implemented
primary command/status and the later .7.1–.7.3 admission records. Its strict corpus
IO explanation remains useful. Existing Lua `.2.1` now owns this exact stale
current-tense sentence alongside the README status drift; `.2.1.1` repairs the
canonical card while preserving dated evidence and `.2.1.2` independently verifies
both public and canonical current guidance. No new runtime defect or duplicate
repair root is inferred; all seven local roots remain pending behind startup
reading/book/policy prerequisites. The old card remains byte-exact until that
owned correction, and this card records the current qualification.

# Focused proof

Both installed hosts pass 25 pure compiled-state controls: PUC5.5.1 and LuaJIT
2.1.1788460057, 50 total. These cover entry precedence and typed missing-entry
errors, equal regex text with distinct selected slot identity, contract constants,
semantic/slot descriptor rows, cursor projection, normalized SpecFile descriptor
identity, separate internal/dependency JSON, last-definition ordering and a typed
in-memory slot mismatch. An initial fixture incorrectly searched the rendered
validation message for its code; reading the actual typed `code` field corrected
the assertion. The source already rejected the invalid slot correctly.

Neutral regex-slot proof passes 5 fixtures /2 diagnostics /6 runtime rows /
7 complete rollout legs /21 public documents /11 stale-claim checks /59 mutations.
Callable signatures pass 3 definitions /9 calls /7 invalid definitions. Cursor
proof passes 36 family spellings /18 edge cases /8 parent-child cases, all
6 recurring runtime legs, 30 public documents, 28 stale-current checks,
74 migration files, 8 complete legs and 60 mutations.

An independent Python census reads the checked-in manifest and confirms exact
105-case directory membership, all 315 required strict-UTF-8 files and expected
JSON decoding. It does not exercise Lua corpus loading or execution. Corpus and
facade imports reach native matching; pure compiler proof avoids a new native
build during this reading slice. This establishes neither full corpus execution,
facade loading, engine behavior, the full gate nor declared PUC5.4 conformance.
The existing full-corpus and primary-route cards retain their dated proof.

# Exact pure-module replay

Payload SHA-256:
`1cdb4d6d961571b66b9a92f42e867490e159f7395910679b11943ad1bb4b5507`.
Run from repository root through the managed wrapper.

```bash
bash tools/project_data_run.sh python3 - <<'LUA16_REPLAY'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua16/compiled-proof.lua')
p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(r'''package.path = "lua/src/?.lua;lua/src/?/init.lua;" .. package.path
local p = require("linkedspec.spec_parser")
local c = require("linkedspec.compiled_spec")
local a = require("linkedspec.spec_ast")
local j = require("linkedspec.json")
local checks=0
local function check(value,label) assert(value,label);checks=checks+1 end
local function compile(source,options) return c.compile_spec(p.parse_spec(source),options) end
print("RUNTIME",_VERSION,jit and jit.version or "PUC")
local plain=compile("First: /a/\nSecond: /b/\n")
check(plain:resolve_entry_rule().rule.label=="First","first authored fallback")
check(plain:resolve_entry_rule().basis=="first_authored_rule","fallback basis")
local marked=compile("First: /a/\nSecond:: /b/\n")
check(marked:resolve_entry_rule().rule.label=="Second","authored marker selection")
check(marked:resolve_entry_rule().basis=="first_authored_marker","marker basis")
check(marked:resolve_entry_rule("First").rule.label=="First","explicit selection wins")
check(marked:resolve_entry_rule("First").basis=="explicit_selector","explicit basis")
local ok,err=pcall(function() return marked:resolve_entry_rule("Missing") end)
check(not ok and c.is_entry_rule_selection_error(err),"typed missing-entry failure")
check(c.entry_rule_selection_error_to_json(err).code=="entry_rule_not_found","stable entry diagnostic")
local source="Top::\n -> Child[1]\nChild: /x/ /x/\n"
local spec=p.parse_spec(source)
local compiled=c.compile_spec(spec)
local parent=compiled:rule("Top")
check(parent.regex_patterns[1]=="x","selected child pattern")
check(parent.action_edges[1].child_regex_index==1,"duplicate text retains selected child identity")
local identities=c.compiled_regex_slot_identities_for(parent,0)
check(#identities==1 and identities[1].target_rule=="Child" and identities[1].regex_index==1,"resolved slot identity")
local descriptor=compiled:to_descriptor_json()
check(descriptor.meta.cursor_contract==c.RULE_LOCAL_CURSOR_CONTRACT_ID,"cursor contract identity")
check(descriptor.meta.regex_slot_identity_contract==c.REGEX_SLOT_IDENTITY_CONTRACT_ID,"regex identity contract")
check(descriptor.spec.Top.meta.resolved_edges[1].regex_index==1,"descriptor semantic child index")
check(descriptor.spec.Top.meta.resolved_slot_edges[1].regex_index==1,"descriptor slot child index")
check(descriptor.spec.Top.meta.family=="or_default" and descriptor.spec.Top.meta.cursor_policy=="seek","derived cursor projection")
check(descriptor.spec.Top.handler.status=="compiled_state_only","descriptor handler status")
local normalized=a.from_json("SpecFile",j.decode(j.encode(a.to_json(spec))))
check(j.encode(c.compile_spec(normalized):to_descriptor_json())==j.encode(descriptor),"normalized AST descriptor identity")
check(j.encode(c.to_descriptor_json(compiled:descriptor_state()))==j.encode(descriptor),"descriptor state projection identity")
check(c.to_json(compiled).kind=="compiled_spec_state","separate internal state kind")
check(c.to_json(compiled.dependency_regex_state).kind=="compiled_dependency_regex_state","dependency state kind")
local replacement=compile("A: /old/\nB: /b/\nA: /new/\n",{validate_source=false})
check(table.concat(replacement.definition_order,",")=="A,B,A","all definition order retained")
check(table.concat(replacement.compiled_rule_order,",")=="B,A","effective last-definition order")
check(replacement.redefined_rule_labels[1]=="A" and replacement:rule("A").regex_patterns[1]=="new","last definition state")
parent.action_edges[1].child_regex_index=7
local valid,failure=pcall(c.validate_compiled_regex_slot_identities,compiled)
check(not valid and type(failure)=="table" and failure.code=="regex_slot_identity_invalid","typed in-memory identity mismatch rejected")
print("COMPILED_CONTROLS",checks)
''')
LUA16_REPLAY
bash tools/project_data_run.sh lua .linkedspec-data/scratch/lua16/compiled-proof.lua
bash tools/project_data_run.sh luajit .linkedspec-data/scratch/lua16/compiled-proof.lua
```

The independent census is separately reproducible with
`bash tools/project_data_run.sh python3 <script>`:

```python
from pathlib import Path
import json
root=Path('rust/linkedspec-runtime/tests/corpus')
manifest=json.loads((root/'manifest.json').read_text())
assert manifest['format']==1
assert len(manifest['cases'])==manifest['case_count']==105
assert len(set(manifest['cases']))==105
assert set(manifest['cases'])=={p.name for p in root.iterdir() if p.is_dir()}
for name in manifest['cases']:
 for member in ['input.spec','input.txt','expected.json']:
  text=(root/name/member).read_text(encoding='utf-8',errors='strict')
  if member=='expected.json':json.loads(text)
print('PASS independent corpus census: 105 directories, 315 UTF-8 files')
```

# Continuity

The owning leaf preserves all source and earlier evidence, advances only current
coverage/frontier pointers, updates the public book and runs exact reconstruction,
Knowledge/memory/history/diff checks and rendering before normal doctrine hooks.
Reading and selected proof do not close any pending repair.

Verified candidate reconstruction passes all 99 source files /51 groups /149
ranges and exact embedded replay bytes. Preservation checks retain 1,378 prior
source/card/decision/history files, 2,448 unchanged task nodes, all 58 Known
headings, exact chronology suffixes/preambles and the live history query section.
Only the current reading node, startup .3.6 and the existing .2.1 documentation
repair plus its two children change; no node is added. The source baseline and
all previous cards remain byte-identical. Histories are 256/403 lines without
rollover; memory remains 60 lines. Rendered book passes with the existing large
search-index warning (10,033,316 bytes), owned by startup .41.9. Knowledge is
1,092 facts /8,779 question keys. Normal doctrine hooks govern landing.

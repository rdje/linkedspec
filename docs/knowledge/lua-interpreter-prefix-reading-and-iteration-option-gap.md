---
id: lua-interpreter-prefix-reading-and-iteration-option-gap
title: Lua interpreter prefix preserves typed values but defaults an explicitly false iteration option
answers:
  - what did Lua startup reading group seven cover
  - does Lua max_iterations false reject or use the default
  - which task fixes Lua explicit iteration-option validation
  - which old Lua runtime cards need current-behavior corrections
  - what native checks support Lua interpreter prefix reading
  - how does Lua interpreter setup retain typed diagnostics and local bindings
date: 2026-09-12
status: exact group seven read; iteration validation and older guidance repairs pending
tags: [lua, reading, interpreter, options, diagnostics, bindings, runtime]
evidence: "LUA-STARTUP-READING.1.7 reads 1500 fragments /53644 bytes from d337ed89c1dcf50d1326097f00f648a73a556707. Real native-facade controls pass 27 per installed runtime; explicit false max_iterations selects 10000 while other invalid supplied values reject. .2.8 owns bounded repair and independent verification. Write 105 and logical 26 mutations pass."
reverify:
  - "Run the exact managed native replay below on both Lua hosts, recording their identities."
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
  - "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py"
---

# Exact physical reading

Activation is `d337ed89c1dcf50d1326097f00f648a73a556707`; source baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Ten complete untruncated windows:
facade 235–318; interpreter 1–170, 171–340, 341–510, 511–680, 681–850,
851–1020, 1021–1190, 1191–1360 and 1361–1416.

| Path | Inclusive LF lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/init.lua` | 235–318 | 3748 | `4435758d374ad8781d65a1288a6cd6a58faa8572226a10f383b1849d1b9a85a3` |
| `lua/src/linkedspec/interpreter.lua` | 1–1416 | 49896 | `cb9b334e4cb58d80965ff09026c184903ca70b81a4c7b0958dcae24ecc1420d0` |

Ordered-range SHA:
`9617f765df2d7cbefd92c6990395f31b66134368269fd0df84395d9d08685dbe`.
Cumulative: 7/51 groups, 9,945 fragments /395,987 bytes, fifteen complete files
and partial interpreter. Interpreter lines 1417 onward remain .1.8-owned.

# Comprehension and canonical reconciliation

The facade suffix forwards matching, runtime and trace APIs to their canonical
modules; it does not introduce alternate execution semantics. Interpreter setup
reuses typed source, recognition, progressive, staged and mutation namespaces
without exceeding the known top-level-local ceiling. Typed runtime error, exit,
flow, diagnostic-output-sink, engine and result records remain distinct. Value
copying preserves scalar false/null, copies typed arrays/harrays and reparses
codeblock source, rejecting cycles in copied typed containers.

Engine creation rejects removed global cursor options, validates options and
caller-mutated compiled identities/write/mutation/progressive state, then creates
fresh caches. Diagnostics preserve spec identity and typed optional context;
wrapping retains an existing deeper diagnostic. Input context validates UTF-8,
creates fresh source/recognition state, stores binding identities and per-invocation
stacks, and retains explicit diagnostic/observation/trace routes.

Lookup exposes one typed binding despite private stores. Writes clear competing
slots, copy values and retain stable mutation identity; active receiver guards
report authored spans and exact binding context. Nested-write selectors use evaluated
strings or non-negative integers, create dense typed containers on the working
copy and reject kind conflicts/gaps. This prefix defines the mutation mechanism;
its final expression evaluation/publication path is outside the current range.
Child dispatch caches its result and updates retv; passive terminal handling is
qualified by recognition observation. Capture helpers preserve absent/null rules.

String helpers distinguish scalar formatting, codeblocks and aggregates. Diagnostic
helpers evaluate arguments once and emit typed events through the caller sink.
Regex helpers normalize/cache supported flags, use scalar-aware progress for empty
matches and expand numbered replacement groups. Whitespace trimming and lengths
use Unicode decoding. Logical helpers validate positional arity, evaluate every
argument eagerly, then apply typed truthiness. Codeblock setup checks final-argument
contracts, reparses/copies values and uses scoped binding for with; inline-if
validation begins at the end of this range.

Canonical facts were retrieved first: [[lua-runtime-rule-interpreter]],
[[lua-runtime-core-value-capture-helpers]], [[lua-runtime-structured-diagnostics]],
[[lua-uniform-binding-runtime]], [[lua-interpreter-local-variable-ceiling]],
[[write-vivification-lua-runtime]] and [[lua-global-cursor-option-removal]].
No source change or unread-source credit follows from executing imported modules.

# Confirmed explicit-option defaulting gap

The real native facade accepts `runtime_engine(compiled, {max_iterations=false})`
and stores 10000. Omission also selects 10000; explicit 1 and 2 are retained.
Explicit true, 0, -1, 1.5 and string `"2"` all reject with typed runtime errors.
Interpreter line 144 computes `options.max_iterations or 10000`; line 145 then
checks the already-defaulted value. Lua false therefore disappears before the
positive-integer validation. This is an inconsistent option boundary, with no
claim of a long-running parse or exhausted iteration guard.

`LUA-STARTUP-READING.2.8` owns the defect. Child .2.8.1 must default only when the
field is absent, retain valid counts and add RED/GREEN invalid-value coverage.
Child .2.8.2 independently verifies supported direct/loaded-engine routes, checks
any additional route's actual option contract before expanding and closes only
with evidence. The default and repetition/while semantics must remain unchanged.
Startup reading/book/policy and declared-runtime prerequisites still apply.

# Current guidance qualification

The older interpreter card still says engines accept seek/consume mode. The current
engine rejects parse_mode and parseMode with prepare_options/parse_mode_override_removed.
The older value/capture card still says missing intermediate containers are never
created and refers to explicit callable values as future work. Current nested writes
create typed missing containers, and explicit callable literals have codeblock kind.
The native replay confirms these current boundaries and the later canonical cards
supply the admitted behavior owners. Existing documentation repair .2.1/.2.1.1/.2.1.2
now includes these exact sentences, preserving useful dated proof. All old cards
remain byte-identical during reading; this qualification prevents treating those
older sentences as current guidance. Local repair roots now number eight.

# Focused native proof

The normal managed targeted wrapper builds fresh native adapters and runs the exact
same script on PUC 5.5.1 and LuaJIT 2.1.1788460057. Both imports and all 27 valid controls
finish successfully; both wrapper exits and cleanup outcomes were consumed. Controls
cover seven four-kind values, omitted/positive/invalid iteration inputs, removed
cursor keys with source-attributed diagnostics, false results, nested container
creation with a false leaf, logical evaluation, Unicode trim, diagnostic emission
and primary facade status. The separately printed false-default observation is a
defect result, not positive conformance. No malformed native regex is submitted.

The declared PUC 5.4 target remains unavailable under .2.2; these measured host
results do not certify it. No full gate, complete corpus or generated-route proof
is claimed. The earlier native import delay is not reproduced by these two runs;
this observation does not close startup .81.1 or establish its cause.

Write-vivification proof passes 5 valid/7 invalid syntax, 11 successes,
16 structural/3 evaluation failures, 3 read exclusions, 8 composed writes and
105 mutations. Logical proof passes 17 truthiness/10 helper/3 effect cases,
8 complete legs, 19 public documents, 14 stale claims and 26 mutations.

# Exact managed replay

The 2819-byte payload SHA-256 is
`ac20001be7db16e75c4385f0ad17b8e9728930cab94d0f1bcfabfe6f9f38ebda`.
Run from repository root. The wrapper owns native modules and scratch cleanup.

```bash
bash tools/project_data_run.sh python3 - <<'LUA17_REPLAY'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua17/runtime-proof.lua')
p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(r'''print("NATIVE_IMPORT_BEGIN"); io.stdout:flush()
local l=require("linkedspec")
print("NATIVE_IMPORT_COMPLETE",_VERSION,jit and jit.version or "PUC");io.stdout:flush()
local j=l.json
local checks=0
local function check(value,label) assert(value,label);checks=checks+1 end
local function compiled() return l.compile_spec(l.parse_spec('Top::\n /x/\n E { return(false) }\n')) end
for _,row in ipairs({{j.null,"scalar"},{false,"scalar"},{7,"scalar"},{"é","scalar"},{j.array(),"array"},{j.harray(),"harray"},{l.parse_action_expression('{|x| return(x) }'),"codeblock"}}) do
 check(l.runtime_value_kind(row[1])==row[2],"four-kind boundary")
end
local fresh=compiled()
local engine=l.runtime_engine(fresh)
check(engine.max_iterations==10000,"default iterations")
for _,value in ipairs({1,2}) do check(l.runtime_engine(fresh,{max_iterations=value}).max_iterations==value,"explicit positive iterations") end
for _,value in ipairs({true,0,-1,1.5,"2"}) do
 local ok,err=pcall(l.runtime_engine,fresh,{max_iterations=value})
 check(not ok and l.is_runtime_interpreter_error(err),"invalid supplied iterations rejected")
end
local false_ok,false_engine=pcall(l.runtime_engine,fresh,{max_iterations=false})
print("FALSE_ITERATION_OPTION_OBSERVATION",false_ok,false_ok and false_engine.max_iterations or tostring(false_engine));io.stdout:flush()
for _,key in ipairs({"parse_mode","parseMode"}) do
 local options={spec_name="reading",spec_path="specs/reading.spec"};options[key]="seek"
 local ok,err=pcall(l.runtime_engine,fresh,options)
 check(not ok and l.is_runtime_interpreter_error(err),"removed global mode rejected")
 check(err.code=="parse_mode_override_removed" and err.diagnostic.stage=="prepare_options","typed mode diagnostic")
 check(err.diagnostic.spec_name=="reading" and err.diagnostic.spec_path=="specs/reading.spec","source identity retained")
end
local function run(code)
 local spec=l.parse_spec('Top::\n /x/\n E { '..code..' }\n')
 return l.runtime_parse(l.runtime_engine(l.compile_spec(spec)),"").value
end
check(run('return(false)')==false,"false result retained")
local tree=run('tree["a"][0]["b"] = false; return(tree)')
check(j.encode(tree)=='{"a":[{"b":false}]}',"missing containers created with false leaf")
check(run('return(or(false, true))')==true,"eager logical value")
check(run('return("  é  ".trim())')=="é","Unicode trim")
local outputs={}
l.runtime_parse(l.runtime_engine(l.compile_spec(l.parse_spec('Top::\n /x/\n E { say("reading"); return(false) }\n'))),"",{diagnostic_sink=function(event) outputs[#outputs+1]=event end})
check(#outputs==1 and outputs[1].helper_name=="say" and outputs[1].message=="reading\n","typed diagnostic output")
check(l.backend_status().parity=="runtime-corpus-primary-cli" and type(l.run_primary_cli)=="function","facade primary status")
print("RUNTIME_CONTROLS",checks)
''')
LUA17_REPLAY
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua17/runtime-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua17/runtime-proof.lua
```

# Continuity

The exact reading node owns this evidence and all synchronized live/book frontiers.
Source and prior evidence remain unchanged; the newly measured option defect has
repair and verification children before implementation. The next leaf is .1.8,
after focused proof, normal doctrines, clean commit and an empty brief.

Independent reconstruction passes all 99 sources /51 groups /149 ranges and
matches the embedded runtime replay exactly. Preservation retains 1,379 prior
source/card/decision/history files, 2,447 unchanged task nodes and all 58 prior
Known headings. Exactly three new pending .2.8 nodes are added; the book now has
59 Known headings. Chronology suffixes/preambles and live-history query remain
byte-exact. Knowledge is 1,093 facts /8,785 questions; memory remains 60 lines.
Histories are 263/410 lines: notes give the expected 80-percent warning without
required rollover. The rendered book passes; its existing 10,035,813-byte index
warning stays startup .41.9-owned. Normal doctrines govern candidate landing.

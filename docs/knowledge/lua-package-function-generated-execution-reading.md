---
id: lua-package-function-generated-execution-reading
title: Lua package function and generated execution proof distinguishes families and fresh children
answers:
  - "what exact Lua source did startup reading child 40 cover"
  - "which Lua function runtime and generated package groups pass during startup reading"
  - "how does Lua package proof distinguish in-process generated families from fresh host execution"
  - "does Lua generated package proof preserve exact function versions and effective rule order"
  - "does Lua package proof check fresh generated cleanup on success and failure"
  - "which Lua runtime and generated stage pointers remain stale after reading child 40"
  - "what focused evidence passed for Lua reading child 40"
date: 2026-09-13
status: exact source reading and selected proof complete; later package source and all prior repairs remain open
tags: [lua, package, functions, generated-source, descriptors, isolation, startup, evidence]
evidence: "LUA-STARTUP-READING.1.40 activates from 325588c735b1b28daa8af0d87f9159d57f206155. Eight complete windows read 1500 fragments /62438 bytes. Both installed hosts pass 22 complete package groups each, including staged/function execution, descriptors, generated families and fresh valid/malformed-payload children with cleanup. Existing .2.1 guidance extends; no production change or new repair node."
reverify: "Run LUA_PACKAGE_GENERATED_READING_40 and the managed commands below; original helpers support only complete groups3341-4818."
---

# Exact reading

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/run.lua | 3353–4852 | 1500 /62438 | ce5bbf780b8b27e214d4a0ae871049b9a50a384852564cde383130b95cda134c |

Complete credited windows are 3353–3540, 3541–3725, 3726–3910, 3911–4095,
4096–4280, 4281–4465, 4466–4650 and 4651–4852. Ordered range SHA-256 is
`7599b9e3b36b156da6f8c21ae9290f705e848ea6ead86e10fc88017b8ac7142d`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 40/51 groups,
55,540 fragments /2,105,839 bytes and 77 complete files. The package runner
remains partial, ending inside generated_family_host_runner's returned source.

# Staged dispatch and function execution

The staged-registry group begins at 3341, whose prefix was read in child39.
It orders jobs by source paths, projects exact builtin provider/cache identity
and the composite fingerprint, returns typed results and copies stitched bodies.
Mutating a returned result does not alter the stitched spec. Automatic composition
keeps rules and dispatches a supplied function body. Unsupported providers,
unsupported top rules, wrong result fields and duplicate job IDs report their
distinct resolve/compile/sidecar boundaries with exact job/path/source attribution.

Invocation-frame groups copy valid scalar, typed array/harray and structural
codeblock values into fresh stores without caller capture. Mutating frame stores
does not affect the supplied values or a later invocation. Unknown calls, wrong
arity and an active call cycle retain exact registry stage, rule and handler identity.

Fixed-function runtime evaluates arguments once from left to right, including
assignment-valued arguments and a discarded standalone call. Nested nonrecursive
functions, function-local early returns and array/string/number/harray receiver
chains retain exact values. Mutation of parameter copies leaves caller aggregates
unchanged, and undeclared caller bindings read as null in the isolated function.

Contextual callbacks in attached or parenthesized form execute against the current
function frame. Their writes remain visible inside that invocation while outer
caller variables remain unchanged. Callback results can feed receiver chains.
Missing or harray callbacks, nonzero contextual arity and active self invocation
retain typed diagnostics. Registered functions and governed helpers precede
colliding callback parameter names.

The unchanged neutral variadic fixture executes through explicit source-owned
function nodes and staged bodies. A separate runtime group verifies once-only
written argument order, independent empty rest arrays, nested caller-array
isolation and preservation of a block as one rest value. Fixed and variadic
minimum/arity failures remain precise. Typed keyword arguments are inserted into
already-compiled ActionIR by these tests, then rejected by both contract resolution
and runtime with user_function_keyword_arguments_unsupported. This is not evidence
that keyword source syntax is admitted. Direct and mutual function recursion
retain full cycles. Missing and mismatched staged body ASTs fail their authority
checks before function-body execution. Existing malformed-container and option
limitations remain open; valid copied inputs do not cover those earlier probes.

# Compiled state and descriptor contracts

Compiled-state tests preserve source and effective rule order, mode bounds,
parent/dependency regex slots and ActionIR/lifecycle/plain-block payload roles.
Changing the source AST afterward does not change compiled snapshots. With source
validation explicitly disabled, duplicate definitions retain source order A,B,A
and effective order B,A; child dependency slots use the final A pattern.

The descriptor group compares exact top-level keys, current rule-local cursor
required/forbidden metadata and neutral model values. Handler status describes
the compiled descriptor boundary. Three ordered function records carry exact
fixed-v1, variadic-v2 and final-codeblock-v3 fields, versions and indices, with
signature/parameter-kind copies matching their staged sidecars. JSON reconstruction
retains the current cursor-contract identity.

# Generated state, in-process families and fresh children

Generated metadata uses module contract-v2 and format2, distinct from the function
record versions above. Portable emit/compile-load/execution/plan error constructors
retain stage, code, identity and optional rule/family detail. Invalid UTF-8 identity
is intentionally retained in its typed error by the existing test; it is not JSON-
encoded here, so the already-owned invalid-identity serialization gap stays open.
Missing identity and invalid compiled input reject at the emission boundary.

Deterministic emission produces ASCII source with identity and effective payload
encoded as hex. The test reconstructs that payload, checks all three function
representations and preserves only effective last-definition rules. The generated
module is then independently loaded in the current host: direct and traced calls
return the same Unicode value, missing entry selection preserves its typed error,
and the compatibility emitter retains inline identity.

One combined fixture covers all ten generated root families and nested rows.
Typed plans match compiled order; every generated value equals its native value.
Four controlled mutations check row count, ordered label, known-family mismatch
and unknown family with exact attribution. Traced AND blind dispatch includes
portable root/nested generated events. A below-minimum repeated blind call reports
the selected rule and family. These are in-process plan executions.

The neutral variadic fixture also survives actual emitted-module reconstruction
and execution in the current host. Mutating a returned plan does not change a
subsequent plan copy. A separate complete group writes a valid module, a module
with an invalid embedded JSON payload and a host runner under managed TMPDIR.
For each enclosing ABI, it starts one valid and one malformed-payload child with
the selected runtime and explicit project LUA_PATH/LUA_CPATH.

The valid child checks direct/traced Unicode results, exact contract metadata,
source identity, runtime trace presence and missing-entry error attribution.
The malformed-payload child reports generated_source_compile_failed at
compile_or_load_generated_source with the same identity. Both child commands
succeed with exact JSON stdout and empty stderr. Success removes the owned root;
an intentionally raised operation also removes its separate root before propagating
the original error. Parent assertions verify both roots are absent.

The all-family child runner begins at 4819 and is partially read through 4852.
It is excluded from this selected script. No fresh all-family child result is
claimed here; child41 owns the complete test. The fresh children above exercise
the explicit single Unicode fixture and its malformed-payload counterpart.

# Knowledge reconciliation and proof limits

Retrieved [[lua-fixed-v1-user-function-runtime]], [[lua-variadic-v2-runtime]],
[[lua-contextual-user-function-codeblock-runtime]], [[lua-generated-source-family-plan]],
[[lua-generated-source-fresh-process-isolation]] and [[lua-generated-source-emitter-core]].
Staged dispatch, compiled state, outward union and current cursor/generated owners
were read in earlier children; their exact previous facts and repairs remain in force.

Existing .2.1 gains the fixed-runtime final current contextual/native-loading
pointer, variadic-runtime pending-generated wording and emitter-core metadata's
pending census .8.4 despite its closed body/successor. Date these stage pointers
without erasing historical counts. The already-owned .2.33 nested-copy limitation
also qualifies fixed/variadic runtime prose. No old card, historical task node,
source implementation or supported-runtime declaration changes.

The selected script combines original ranges1–199,1718–1753,1940–1984,
2124–2273,3029–3121 and3341–4818. These contain only original preamble/helpers
and the 22 complete new groups. Both managed native jobs exit0 with exact logs,
44 groups total, including all their child-process and cleanup assertions.
Individual assertion counts are not invented. The hosts are installed PUC5.5
and LuaJIT, not certification of unavailable supported PUC5.4. All33 repair roots,
previous nil-error and public-selector failures, startup gates and parked named
arguments remain open. No full CI, primary matrix, PGEN/RGX build or push occurs.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_PACKAGE_GENERATED_READING_40'
from pathlib import Path
p = Path('.linkedspec-data/scratch/lua140')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\nimport re\n\np=Path(\'.linkedspec-data/scratch/lua140\')\nsource=Path(\'lua/test/run.lua\').read_text().splitlines(keepends=True)\nassert source[3340].startswith(\'test("staged parser registry \')\nassert source[4818].startswith(\'local function generated_family_host_runner(\')\nranges=[(1,199),(1718,1753),(1940,1984),(2124,2273),(3029,3121),(3341,4818)]\nselected=\'\'.join(\'\'.join(source[start-1:end]) for start,end in ranges)\nnames=re.findall(r\'^test\\("([^"\\n]+)"\',selected,re.M)\nassert len(names)==22,len(names)\n(p/\'package-selection.lua\').write_text(selected+\'\\nassert(total == 22, "package selection count drift: " .. total)\\nassert(failed == 0, "package selection failures: " .. failed)\\nprint("package selection: " .. total .. " test groups passed")\\n\')\nprint(\'Selected original helpers and complete groups3341-4818: 22 groups; later all-family child runner excluded\')\n')
(p / 'verify.py').write_text('from pathlib import Path\nimport hashlib,json,re\n\np=Path(\'.linkedspec-data/scratch/lua140\')\nfor row in json.loads((p/\'scope.json\').read_text()):\n    data=b\'\'.join(Path(row[\'path\']).read_bytes().splitlines(keepends=True)[row[\'start\']-1:row[\'end\']])\n    assert len(data)==row[\'bytes\'] and hashlib.sha256(data).hexdigest()==row[\'sha256\']\nsource=Path(\'lua/test/run.lua\').read_text().splitlines(keepends=True)\nbody=\'\'.join(source[3340:4818])\nnames=re.findall(r\'^test\\("([^"\\n]+)"\',body,re.M)\nassert len(names)==22\nexpected=\'\'.join(f\'ok {i} - {name}\\n\' for i,name in enumerate(names,1))+\'package selection: 22 test groups passed\\n\'\nfor host in [\'puc\',\'luajit\']:\n    assert (p/f\'package-{host}.log\').read_text()==expected,host\nprint(\'PASS: exact source range and 22 complete package groups per host, 44 total; staged/function/descriptor/generated proof includes fresh valid and malformed-payload children with cleanup\')\n')
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/run.lua",\n    "start": 3353,\n    "end": 4852,\n    "bytes": 62438,\n    "sha256": "ce5bbf780b8b27e214d4a0ae871049b9a50a384852564cde383130b95cda134c"\n  }\n]\n')
LUA_PACKAGE_GENERATED_READING_40
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua140/select-tests.py
for host in puc luajit; do
  bash tools/run_lua_project_data.sh "$host" .linkedspec-data/scratch/lua140/package-selection.lua > ".linkedspec-data/scratch/lua140/package-$host.log" 2>&1 || exit
done
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua140/verify.py
```

Related: [[lua-package-validation-function-registry-reading]],
[[lua-startup-reading-coverage]], [[lua-cursor-completion-package-prefix-reading]].

# Preservation and final focused checks

Independent audit preserves 1,416 baseline source/Knowledge/decision/history/policy
files and 2,579 of 2,582 existing task nodes byte-for-byte. Only this reading leaf,
existing guidance owner .2.1 and startup .3.6 change; no node is added. The parked
authoring tree, all 90 existing Known headings, both prior live-document suffixes
and indexed live-status History remain exact. All three embedded replay payloads
match their executed scratch files. Independent inventory reconstruction confirms
all 99 source files, all 51 groups and exact 40-child reading credit.

Document-history checks pass 34 mutation controls across three surfaces and 67
segments; no rollover is needed. Explicit memory architecture and diff whitespace
checks pass. The book builds successfully; its 10,151,318-byte search-index warning
remains under startup .41.9. The generated map has 1,126 facts and 9,001 question
keys. These are focused pre-commit observations; normal commit hooks remain required.

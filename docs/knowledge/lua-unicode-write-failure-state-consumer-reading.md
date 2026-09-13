---
id: lua-unicode-write-failure-state-consumer-reading
title: Lua Unicode consumer completion and missing write failure-state oracles
answers:
  - "what exact Lua ranges does reading child 50 cover"
  - "what do the complete Lua Unicode identity negative and route tests prove"
  - "do Lua invalid-label loader diagnostics omit all paths"
  - "what does the Lua write consumer prefix through line 384 verify"
  - "does the Lua write failure fixture verify expected_binding"
  - "which nineteen Lua write failure-state mutations survive"
  - "who owns the Lua write failure-state coverage repair"
date: 2026-09-13
status: exact source reading and focused evidence complete; failure-state coverage repair pending
tags: [lua, startup, reading, unicode, assignment, tests, coverage, mutation]
evidence: "LUA-STARTUP-READING.1.50 reads four exact ranges, 1500 fragments/61835 bytes, in eleven complete windows. Eight ordinary runs pass 359+1542+179+408 assertions per host, 4976 total; two neutral checkers pass. Nineteen single-field expected_binding input mutations individually survive the unchanged write prefix per host, 38 observations. New .2.35/.1/.2 own exact state-oracle repair; no runtime-state defect is inferred."
reverify: "Run the exact repository-local replay below; preserve its bounded write prefix, single-field input mutations and earlier native-error exclusions."
---

# Exact source reading

Activation is `204e60348bba50f5ef1ab18bd4c5a52709f03947`.
The unchanged baseline is `baeb984e36a94a15951cd23d4c52def5064cdaca`.
Ordered group digest:
`9ab4482b49acb20b3434666f2d1cd8001bd7bbb0054e6335ac93178a49d93421`.

| Path under lua/test/ | Inclusive lines | Fragments | Bytes | SHA-256 |
| --- | --- | ---: | ---: | --- |
| unicode_rule_label_identity_routes_test.lua | 386-474 | 89 | 3359 | `a0ea3778a7e7653dbab6bf03bee74877e781e4b81886bdbe1317dda2ae1950fb` |
| unicode_rule_label_negative_isolation_test.lua | 1-746 | 746 | 30794 | `067b5319ae2d3f721e0d1fc4396f209c9c0508ca918c68e8bb8f9a84a283cbab` |
| unicode_rule_label_routes_test.lua | 1-266 | 266 | 10168 | `51cf2819102e45f248a4cce6ea0c32a47085da8ed2b02b45048676a2bd9b4a74` |
| write_vivification_contract_test.lua | 1-399 | 399 | 17514 | `63a500b4a11fc25bb7182449d8a1e848017be7301df0e3ff669c209296d91bf0` |

All eleven windows are complete and untruncated: identity 386-474;
negative 1-155/156-310/311-465/466-620/621-746; routes 1-140/141-266;
write 1-135/136-270/271-399. Identity, negative and routes reach EOF;
write remains partial. Cumulative coverage is 50/51 groups, 70,540 fragments /
2,704,332 bytes and 97 complete files. Supporting code, formal book and policy
prerequisites still prevent claiming full codebase reading or starting repairs.

# Unicode identity, invalid labels and parser routes

The complete identity consumer passes 359 assertions per host. Beyond child 49's
341 prefix, it checks native explicit-selection trace basis, exact missing-selector
runtime and generated-source diagnostic records, and file-routed generated tracing.
`規則Missing𐐀` retains authored identity in the `select_entry_rule` /
`entry_rule_not_found` diagnostics. The complete run also repeats the ten-label
fresh emitted process, strict loading and both primary source forms already read
in child 49. It uses a valid regex; no earlier malformed native error probe runs.

The negative consumer passes 1,542 per host. Eight neutral labels cross declaration,
action, blind and bare roles, two programmatic/reconstructed trust paths and five
artifact operations. Each route stops at exact `invalid_rule_label` /
`validate_rule_labels` diagnostics before a compiled artifact exists. Later source
cases preserve whole malformed edge text. A colon at a rule-header boundary starts
a new declaration, and a newline separates an action target from a later bare edge;
those two intentional grammar boundaries are not partial invalid-label recovery.
`$Top` remains malformed in all three edge forms.

Every frozen invalid selector fails native, generated-plan and current-host emitted
execution with exact label-bearing diagnostics. Native trace records requested
identity and `effective=<none>`. A fresh emitted process returns all eight exact
diagnostics/traces, exits successfully and has empty stderr. Loader failures retain
`requested` and `resolved_path` fields intentionally; only their detail excludes
the path. Inline/file compilation fails with exit one, empty stdout and the stable
compilation message. Invalid primary selectors fail invocation while trace uses
an exact byte-wise percent encoding outside ASCII alphanumerics and `_ . : -`.
This is precise context/detail separation, not blanket path absence from errors.

Adjacent identifier grammars retain their original roles: ASCII function, fixed/rest
parameter, variable, call and fluent names; reserved lifecycle words; split/mark
variables; conditionals and bounded-mode syntax. The loader name validator still
accepts Unicode scalar text. Unicode regex literals preserve their exact pattern
bytes. These regex cases validate source syntax and use valid patterns; they do not
exercise malformed native regex compilation. The invalid bounded-mode fixture
retains its raw/default-mode structure, without claiming successful compilation.

The routes consumer passes 179 per host. It directly imports parser/validator/AST
modules, checks all nine positive declaration labels, action/blind/bare identity,
ten accepted action continuations and spaced indices. Six invalid suffix classes
stay whole raw nodes; colon-only text remains declaration punctuation. Invalid
headers and a third colon reject. One invalid label is tested across four roles
and two trust paths with exact diagnostic JSON. The separate eight-label negative
suite supplies the wider finite fixture set; neither finite suite proves every
possible invalid string.

Temporary helpers require repository-managed TMPDIR and successful cleanup commands;
they do not independently assert post-removal absence. Fresh processes use the same
installed host family. No other-backend or full primary matrix is executed.

# Write prefix and what its passing assertions cover

Execution copies unchanged write lines 1-384 through the complete detachment block
and adds only a failure/summary footer. Reading reaches 399 inside the next block,
so function-presence, later carrier and malformed-admission checks are excluded.
The prefix passes 408 per host; this is not a fresh full 438 assertion result.

The fixture freezes 5 valid syntax, 7 invalid syntax, 11 success, 16 structural
failure, 3 expression failure and 3 read-exclusion rows. Syntax checks compare
expression-bearing path segments, source text and Unicode-scalar spans. Invalid
syntax retains exact typed parse diagnostics. Legacy bang arguments now reject
with `map_leaves_mutation_arguments_invalid`; this is not a claim that the admitted
empty-parentheses receiver mutation is unavailable. Astral path/RHS spans remain
scalar offsets.

Success rows check both the updated root and returned detached value plus complete
segment-before-RHS diagnostic-event order. Two special fixtures compose segment/RHS
changes to the same binding. Structural rows check typed code, operation, binding,
segment/prefix/kind/gap fields, authored span, message and event order. Expression
failure rows inject a typed error object from the diagnostic sink at an exact
segment/RHS marker; they require identical object/code/message and stopped order.
The thrown object is a table, so this proof does not reverify the separately failing
PUC nil-error boundary. Reads remain non-creating in the three exact fixtures.
Detachment separately mutates initial state, RHS, result and committed binding and
checks their independent returned shapes.

# Confirmed coverage gap and repair ownership

Structural loop 273-311 and expression-failure loop 313-353 never read their
`expected_binding` fixture fields or observe state after the failed execution.
All nineteen neutral rows nevertheless declare that state. Required cases include
absent roots, present null/scalar/harray/array roots, no partial nested publication,
and the RHS update that must survive a later outer array gap.

For each row independently, the scratch input replaces only that row's
`expected_binding` with a contradictory present object keyed by its fixture id.
Verification restores that single field and requires exact semantic equality with
the entire original contract, proving no other input change. A scratch `io.open`
adapter redirects only the canonical fixture read to that mutant, then executes
the unchanged prefix and restores the original function. All 19 individual runs
retain 408 passing assertions on PUC and again on LuaJIT: 38 surviving mutations.
These repeated assertions are not added to the ordinary 4,976 total.

This establishes a missing state oracle in those complete loops. It does not prove
that runtime state is wrong, nor claim execution of the unread suffix. New
`LUA-STARTUP-READING.2.35.1` owns same-execution presence/value observation for all
nineteen cases; `.2.35.2` owns mutations that must fail for wrong expected state,
forbidden partial writes or discarded completed effects. Both remain gated by
startup .3/.4/.5 and declared-runtime proof. No production or original test bytes
change during this reading slice.

# Reconciliation and focused limits

Canonical Unicode negative-isolation and write Lua/neutral cards were fully read
before their checks. Existing .2.1 now owns the Lua write card's final public-
admission-future sentence, superseded by the neutral owner's dated .19.7-.9
completion. Preserve historical 436/438 evidence and qualify failure-state claims
against .2.35. The Unicode card's broad path language must retain the measured
structured-loader-context/detail distinction. Earlier Unicode next-stage guidance
already has an owner; no historical card is rewritten here.

Neutral write checking passes 5/7/11/16/3/3 plus eight composed writes and 105
rejected mutations. Neutral Unicode retains version 17.0.0, 806 ranges and 9/8/2
fixtures. Passing those neutral checks does not supply the missing Lua state
observation. All 35 repair roots, known installed-PUC failures, native regex
exclusions and parked named arguments remain open. No build, canonical CI, push
or declared-PUC admission is claimed.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_UNICODE_WRITE_READING_50'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua150')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\np=Path(\'.linkedspec-data/scratch/lua150\')\nlines=Path(\'lua/test/write_vivification_contract_test.lua\').read_text().splitlines(keepends=True)\nassert lines[383].strip()==\'end\'\nassert lines[385].strip()==\'do\'\nassert \'local fresh_source\' in lines[386]\nfooter=\'\\nif #failures > 0 then error(table.concat(failures, "\\\\n"), 0) end\\nio.stdout:write("Lua write-vivification read prefix: ", assertions, " assertions passed\\\\n")\\n\'\n(p/\'write-read-prefix.lua\').write_text(\'\'.join(lines[:384])+footer)\nprint(\'Selected unchanged write lines1-384 through detachment; later function/carrier/admission blocks excluded.\')\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib,json,copy\np=Path('.linkedspec-data/scratch/lua150')\nrows=json.loads((p/'scope.json').read_text())\nassert len(rows)==4 and sum(r['end']-r['start']+1 for r in rows)==1500\nassert sum(r['bytes'] for r in rows)==61835\nfor r in rows:\n data=b''.join(Path(r['path']).read_bytes().splitlines(keepends=True)[r['start']-1:r['end']])\n assert len(data)==r['bytes'] and hashlib.sha256(data).hexdigest()==r['sha256'],r['path']\nlines=Path(rows[-1]['path']).read_text().splitlines(keepends=True)\nprefix=(p/'write-read-prefix.lua').read_text()\nassert prefix.startswith(''.join(lines[:384])+'\\nif #failures > 0')\nassert 'local fresh_source' not in prefix\nfor lo,hi in [(273,311),(313,353)]:assert 'expected_binding' not in ''.join(lines[lo-1:hi])\noriginal=json.loads(Path('capability_conformance/write_vivification_contract.json').read_text())\nmutants=json.loads((p/'failure-state-mutants.json').read_text());assert len(mutants)==19\nassert [r['id'] for r in mutants]==[r['id'] for family in ['failure_cases','evaluation_failure_cases'] for r in original[family]]\nfor m in mutants:\n data=json.loads(Path(m['path']).read_text());row=original[m['family']][m['index']]\n assert data[m['family']][m['index']]['expected_binding']!=row['expected_binding']\n data[m['family']][m['index']]['expected_binding']=row['expected_binding'];assert data==original\nexpected_probe=''.join('Lua write-vivification read prefix: 408 assertions passed\\nSURVIVED expected_binding mutation: '+m['id']+'\\n' for m in mutants)+'OBSERVED failure-state coverage gap: 19 of 19 individual input mutations survive\\n'\nfor host in ['puc','luajit']:\n expected={\n  'identity':'Lua Unicode rule-label identity routes: 359 assertions passed\\n',\n  'negative':'Lua Unicode rule-label negative isolation: 1542 assertions passed\\n',\n  'routes':'Lua Unicode rule-label routes: 179 assertions passed\\n',\n  'write':'Lua write-vivification read prefix: 408 assertions passed\\n',\n  'probe':expected_probe}\n for item,value in expected.items():\n  assert (p/f'{item}-{host}.log').read_text()==value,(item,host)\n  assert (p/f'{item}-{host}.exit').read_text()=='0\\n',(item,host)\nneutral={\n 'write_vivification':'write-vivification contract: 5 valid syntax, 7 invalid syntax, 11 success, 16 structural failures, 3 evaluation failures, 3 read exclusions, 8 composed writes, 105 rejected mutations; neutral authority remains frozen; capability admission is external\\n',\n 'unicode_rule_label':'unicode-rule-label-contract: OK (Unicode 17.0.0; 806 XID_Continue ranges; 9 positive; 8 negative; 2 distinct pairs)\\n'}\nfor item,value in neutral.items():assert (p/f'neutral-{item}.log').read_text()==value,item\nprint('PASS exact four ranges/1500 fragments/61835 bytes; eight ordinary runs0 and 4976 assertions (359+1542+179+408 per host); unchanged write1-384; two neutral outputs. OBSERVED19 single-field expected_binding mutants survive per host (38 total), proving loop coverage gap .2.35, not a runtime-state defect. No full438 write or suffix proof.')\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/unicode_rule_label_identity_routes_test.lua",\n    "start": 386,\n    "end": 474,\n    "bytes": 3359,\n    "sha256": "a0ea3778a7e7653dbab6bf03bee74877e781e4b81886bdbe1317dda2ae1950fb"\n  },\n  {\n    "path": "lua/test/unicode_rule_label_negative_isolation_test.lua",\n    "start": 1,\n    "end": 746,\n    "bytes": 30794,\n    "sha256": "067b5319ae2d3f721e0d1fc4396f209c9c0508ca918c68e8bb8f9a84a283cbab"\n  },\n  {\n    "path": "lua/test/unicode_rule_label_routes_test.lua",\n    "start": 1,\n    "end": 266,\n    "bytes": 10168,\n    "sha256": "51cf2819102e45f248a4cce6ea0c32a47085da8ed2b02b45048676a2bd9b4a74"\n  },\n  {\n    "path": "lua/test/write_vivification_contract_test.lua",\n    "start": 1,\n    "end": 399,\n    "bytes": 17514,\n    "sha256": "63a500b4a11fc25bb7182449d8a1e848017be7301df0e3ff669c209296d91bf0"\n  }\n]\n')
(p / 'prepare-probe.py').write_text('from pathlib import Path\nimport json,copy\np=Path(\'.linkedspec-data/scratch/lua150\')\noriginal=json.loads(Path(\'capability_conformance/write_vivification_contract.json\').read_text())\nrows=[]\nfor family in [\'failure_cases\',\'evaluation_failure_cases\']:\n for index,row in enumerate(original[family]):\n  changed=copy.deepcopy(original)\n  wrong={\'present\':True,\'value\':{\'deliberately_wrong_failure_state\':row[\'id\']}}\n  assert wrong!=row[\'expected_binding\']\n  changed[family][index][\'expected_binding\']=wrong\n  check=copy.deepcopy(changed);check[family][index][\'expected_binding\']=row[\'expected_binding\'];assert check==original\n  target=p/f\'failure-state-mutant-{len(rows)+1:02}.json\'\n  target.write_text(json.dumps(changed,ensure_ascii=False,indent=2)+\'\\n\')\n  rows.append({\'family\':family,\'index\':index,\'id\':row[\'id\'],\'path\':str(target)})\nassert len(rows)==19\n(p/\'failure-state-mutants.json\').write_text(json.dumps(rows,indent=2)+\'\\n\')\nrunner=\'\'\'local json = require("linkedspec.json")\nlocal original_open = io.open\nlocal handle = assert(original_open(".linkedspec-data/scratch/lua150/failure-state-mutants.json", "rb"))\nlocal rows = json.decode(assert(handle:read("*a"))); assert(handle:close())\nlocal survived = 0\nfor _, row in ipairs(rows) do\n  io.open = function(path, mode)\n    if path == "capability_conformance/write_vivification_contract.json" then path = row.path end\n    return original_open(path, mode)\n  end\n  local ok, failure = pcall(function()\n    assert(loadfile(".linkedspec-data/scratch/lua150/write-read-prefix.lua"))()\n  end)\n  io.open = original_open\n  if not ok then error("mutant did not survive " .. row.id .. ": " .. tostring(failure), 0) end\n  survived = survived + 1\n  io.stdout:write("SURVIVED expected_binding mutation: ", row.id, "\\\\n")\nend\nassert(survived == 19)\nio.stdout:write("OBSERVED failure-state coverage gap: 19 of 19 individual input mutations survive\\\\n")\n\'\'\'\n(p/\'failure-state-probe.lua\').write_text(runner)\nprint(\'Prepared19 individual fixture-input mutations, each changing only one expected_binding; production and original assertion bytes untouched.\')\n')
LUA_UNICODE_WRITE_READING_50
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua150/select-tests.py
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua150/prepare-probe.py
for host in puc luajit; do
  for item in identity negative routes write probe; do
    case "$item" in
      identity) script=lua/test/unicode_rule_label_identity_routes_test.lua ;;
      negative) script=lua/test/unicode_rule_label_negative_isolation_test.lua ;;
      routes) script=lua/test/unicode_rule_label_routes_test.lua ;;
      write) script=.linkedspec-data/scratch/lua150/write-read-prefix.lua ;;
      probe) script=.linkedspec-data/scratch/lua150/failure-state-probe.lua ;;
    esac
    status=0
    bash tools/run_lua_project_data.sh "$host" "$script" > ".linkedspec-data/scratch/lua150/$item-$host.log" 2>&1 || status=$?
    printf '%s\n' "$status" > ".linkedspec-data/scratch/lua150/$item-$host.exit"
  done
done
for item in write_vivification unicode_rule_label; do
  bash tools/run_python_project_data.sh "tools/check_${item}_contract.py" > ".linkedspec-data/scratch/lua150/neutral-$item.log" 2>&1 || exit
done
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua150/verify.py
```

Related: [[lua-staged-lifecycle-typed-unicode-consumer-reading]],
[[lua-startup-reading-coverage]], [[write-vivification-neutral-contract]],
[[write-vivification-lua-runtime]].

# Preservation and focused completion

Independent preservation retains 1,427 prior source/Knowledge/decision/history/
policy files and 2,581 of 2,585 prior task nodes byte-exactly. Changed prior nodes
are this reading leaf, repair parent .2, existing guidance .2.1 and startup .3.6.
Only .2.35 and its two children are added. All ninety-one prior Known book headings
remain, with the failure-state limitation added as the ninety-second. The parked
authoring tree remains exact. Four embedded payloads match scratch; independent
coverage verifies all 50 groups and unchanged inventory/range/group digests.

History validation passes 34 mutation controls, three surfaces and 68 segments;
both pressure checks pass at Changes 347 and Notes 277 lines. Memory remains 60 lines
with correct activation and handoff semantics. Knowledge regeneration reports
1,136 cards /9,072 question keys. The book renders with its existing large-search-
index warning at 10,189,153 bytes, still owned by startup .41.9. Whitespace checks
pass. Normal doctrine and activation hooks remain required at landing; no full CI
or push is claimed here.

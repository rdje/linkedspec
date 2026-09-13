---
id: lua-unicode-lower-completion-reading
title: Lua reading completes the generated lower-case table and verifies every scoped mapping
answers:
  - "what exact Lua source did startup reading child 26 cover"
  - "which Lua Unicode mapping entries were read and verified in child 26"
  - "how was every scoped Lua lower-case and upper-case mapping checked"
  - "does Lua child 26 change Unicode casing or close earlier repairs"
date: 2026-09-13
status: exact generated-table reading complete; no new defect found in the scoped range
tags: [lua, unicode, casing, generated-data, startup, evidence]
evidence: "LUA-STARTUP-READING.1.26 activates from 67a97d3d32beb8b83fa1864e45102966699d7836. All 1500 lines /35080 bytes of unicode_case_mapping.lua170-1669 are read in seven complete windows. All 1398 lower and 99 upper entries match the pinned neutral contract and execute correctly on both installed hosts: 2994 complete observations plus 198 existing fixture assertions. Twelve generation/proof inputs remain identical to the preceding leaf's successful regeneration. No source changes or new repair closures."
reverify: "Run LUA_UNICODE_LOWER_READING_26 and the managed commands below; exact coverage remains independently owned by lua-startup-reading-coverage."
---

# Exact scope and comprehension

Read all `lua/src/linkedspec/unicode_case_mapping.lua` lines 170–1669, including
table boundaries, without filtering or truncation. Seven windows cover 170–369,
370–569, 570–819, 820–1069, 1070–1319, 1320–1494 and 1495–1669. The range is
1,500 fragments /35,080 bytes, raw SHA-256
`036ad1138aaca049a17fb18e9ceefb8ed6075c10e43371eeea483c934f069a28`;
the owned ordered range digest is
`899f29584aa57d08bbafabeb7e7840e98be6710a2beb66c418dcd09fa4274439`.
All 99 Lua baseline sources remain unchanged from
`baeb984e36a94a15951cd23d4c52def5064cdaca`.

This finishes the lower-case table: 1,398 scoped entries from U+01D1 → U+01D2
at line 170 through U+1E921 → U+1E943 at line 1567. They include regular and
irregular Latin mappings, Greek/Cyrillic/Armenian/Georgian/Cherokee mappings,
compatibility letters, fullwidth Latin and supplementary-plane scripts. All
scoped lower-case outputs are single scalars; 73 explicit identity entries remain
exactly as provided by the neutral full-mapping data.

The upper-case table begins at line 1570; its first 99 entries run from
U+0061 → U+0041 through U+014D → U+014C. U+00DF expands to U+0053 U+0053
(`ß → SS`) and U+0149 expands to U+02BC U+004E. U+0130 explicitly maps to itself.
These sequences illustrate why mapping values are scalar arrays. No normalization,
locale tailoring or new casing policy is introduced by this reading.

Retrieved [[six-variant-unicode-17-case-parity]] and
[[unicode-17-case-contract-data]] before deriving the scoped facts. They own the
Unicode 17.0.0 full Default Case Conversion contract, offline inputs and contextual
Final Sigma behavior. The plain lower-case table entry for sigma remains separate
from that existing contextual rule. The case-conversion function exports at
3844–3845 and existing test lines 9478–9506 were consulted only for executing the
current consumer; they grant no advance physical reading credit.

Reading is now 26/51 groups, 34,651 fragments /1,321,830 bytes. Forty-seven files
are complete; the Unicode module remains partial. `.1.27` owns lines 1670–3169.
All thirty repair roots, earlier failures, supported-PUC prerequisite and parked
named arguments remain unchanged. This range adds no newly confirmed defect.

# Focused verification

The independent preparation script parses every one of the 1,497 scoped mapping
rows, rejects unexpected non-row lines, checks ordering and unique scalar keys,
and compares complete output sequences to the neutral JSON. Only the three table
boundary lines are excluded from the mapping count; they remain physically read.
The neutral data digest stays
`5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae`.

Both installed hosts execute every scoped row through the actual module's public
lowercase/uppercase function with a single-scalar input. All 2,994 observations
match expected strings and retain exact source lines, operation, input, expected
and actual values. The complete per-host canonical JSON digest is
`00eba01ecae99494650646bedb556a9f68c7e42cc4d72b2d5af114d8225ad592`.
This covers every read entry, not every possible contextual input string.

The unchanged Unicode test selected from `lua/test/run.lua` passes 99 assertions
per installed host, 198 total. It covers twelve neutral fixtures through direct,
helper, receiver and array paths plus three contract metadata checks. Those
fixtures retain expansion, combining output, supplementary scalars, contextual
sigma and no-normalization coverage. This is PUC 5.5.1 and LuaJIT execution,
not fresh proof on the still-pending declared PUC 5.4 runtime.

The preceding `.1.25` leaf's Unicode regeneration and independent neutral proof
remain current: this slice byte-compares all twelve relevant inputs with that
clean commit—four compressed upstream inputs, generator, checker, neutral JSON
and five generated backend modules. It does not recount that earlier invocation
as a fresh run or rerun unrelated suites. All local project data stays under
`.linkedspec-data/scratch/lua126`; source and production test files are unchanged.

## Reproduction

The embedded preparation and independent verifier make the exact scope and
runtime observations reproducible without retaining generated scratch outputs.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_UNICODE_LOWER_READING_26'
from pathlib import Path
p = Path(".linkedspec-data/scratch/lua126")
p.mkdir(parents=True, exist_ok=True)
(p / 'prepare.py').write_text("from pathlib import Path\nimport hashlib\nimport json\nimport re\nimport subprocess\n\nroot = Path('.linkedspec-data/scratch/lua126')\nroot.mkdir(parents=True, exist_ok=True)\npath = Path('lua/src/linkedspec/unicode_case_mapping.lua')\nraw = path.read_bytes()\nscoped = b''.join(raw.splitlines(keepends=True)[169:1669])\nassert len(scoped) == 35080\nassert hashlib.sha256(scoped).hexdigest() == '036ad1138aaca049a17fb18e9ceefb8ed6075c10e43371eeea483c934f069a28'\ncontract = json.loads(Path('capability_conformance/unicode_case_contract.json').read_text())\nassert contract['unicode_version'] == '17.0.0'\nassert contract['data_sha256'] == '5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae'\nmaps = {kind: {int(a, 16): [int(b, 16) for b in bs] for a, bs in contract[kind + '_mappings']}\n        for kind in ('lower', 'upper')}\nrows = []\nkind = None\nfor number, line in enumerate(raw.decode().splitlines()[:1669], 1):\n    if line.startswith('local LOWER ='):\n        kind = 'lower'\n    elif line.startswith('local UPPER ='):\n        kind = 'upper'\n    if number < 170:\n        continue\n    match = re.fullmatch(r'  \\[0x([0-9A-F]+)\\] = \\{(.*?)\\},', line)\n    if not match:\n        assert line in ['}', '', 'local UPPER = {'], (number, line)\n        continue\n    scalar = int(match[1], 16)\n    values = [int(value, 16) for value in match[2].split(', ')]\n    assert maps[kind][scalar] == values\n    rows.append({'line': number, 'operation': kind, 'source': scalar, 'result': values,\n                 'input': chr(scalar), 'expected': ''.join(chr(value) for value in values)})\nassert len(rows) == 1497\nfor kind, count in [('lower', 1398), ('upper', 99)]:\n    selected = [row for row in rows if row['operation'] == kind]\n    assert len(selected) == count\n    assert len({row['source'] for row in selected}) == count\n    assert [row['source'] for row in selected] == sorted(row['source'] for row in selected)\n(root / 'mappings.json').write_text(json.dumps(rows, ensure_ascii=False, separators=(',', ':')) + '\\n')\n\nbase = '67a97d3d32beb8b83fa1864e45102966699d7836'\npaths = ['capability_conformance/unicode_case_contract.json',\n         'unicode_case/generate_unicode_case_contract.py', 'tools/check_unicode_case_contract.py',\n         'perl/LinkedSpec/UnicodeCaseMapping.pm', 'rust/linkedspec-runtime/src/unicode_case_mapping.rs',\n         'dart/lib/src/runtime/unicode_case_mapping.dart', 'julia/src/runtime/UnicodeCaseMapping.jl',\n         str(path)]\npaths += ['unicode_case/upstream/17.0.0/' + name + '.gz'\n          for name in ['LICENSE.txt', 'DerivedCoreProperties.txt', 'UnicodeData.txt', 'SpecialCasing.txt']]\nfor name in paths:\n    assert Path(name).read_bytes() == subprocess.check_output(['git', 'show', base + ':' + name]), name\nprint('Lua .1.26: all 1497 scoped mappings match the neutral contract; 12 generation/proof inputs match clean .1.25 commit')\n")
(p / 'mappings.lua').write_text('local json=require("linkedspec.json")\nlocal casing=require("linkedspec.unicode_case_mapping")\nlocal handle=assert(io.open(".linkedspec-data/scratch/lua126/mappings.json","rb"))\nlocal rows=json.decode(handle:read("*a"));handle:close()\nlocal results=json.array()\nfor index,row in ipairs(rows)do\n local actual=casing[row.operation=="lower" and "lowercase" or "uppercase"](row.input)\n assert(actual==row.expected,"mapping differs at source line "..row.line)\n results[index]=json.harray({line=row.line,operation=row.operation,input=row.input,expected=row.expected,actual=actual})\nend\nassert(#results==1497,"scope count drift")\nio.write(json.encode(results),"\\n")\n')
(p / 'select-tests.py').write_text('from pathlib import Path\nimport json\nnames = [\'generated Unicode 17 casing matches all neutral fixtures and runtime paths\']\ns = Path(\'lua/test/run.lua\').read_text()\nselection = \'local selected = {\\n\' + \'\'.join(\'  [\' + json.dumps(n) + \'] = true,\\n\' for n in names) + \'}\\nlocal assertions = 0\\n\'\ns = selection + s\nfor old, new in [\n (\'local function test(name, operation)\\n\', \'local function test(name, operation)\\n  if not selected[name] then return end\\n\'),\n (\'local function assert_equal(actual, expected, label)\\n\', \'local function assert_equal(actual, expected, label)\\n  assertions = assertions + 1\\n\'),\n (\'local function assert_contains(actual, expected, label)\\n\', \'local function assert_contains(actual, expected, label)\\n  assertions = assertions + 1\\n\')]:\n assert s.count(old) == 1\n s = s.replace(old, new, 1)\ns += \'\\nassert(total == 1, "selected test count drift")\\nio.write("selected assertions: ", assertions, "\\\\n")\\n\'\nPath(\'.linkedspec-data/scratch/lua126/selected.lua\').write_text(s)\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib\nimport json\n\nroot = Path('.linkedspec-data/scratch/lua126')\ninputs = json.loads((root / 'mappings.json').read_text())\nexpected = [{'line': row['line'], 'operation': row['operation'], 'input': row['input'],\n             'expected': row['expected'], 'actual': row['expected']} for row in inputs]\nfor host in ('puc', 'luajit'):\n    actual = json.loads((root / ('mappings-' + host + '.json')).read_text())\n    assert actual == expected\n    encoded = json.dumps(actual, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()\n    assert hashlib.sha256(encoded).hexdigest() == '00eba01ecae99494650646bedb556a9f68c7e42cc4d72b2d5af114d8225ad592'\n    log = (root / ('selected-' + host + '.log')).read_text()\n    assert log == ('ok 1 - generated Unicode 17 casing matches all neutral fixtures and runtime paths\\n'\n                   '1..1\\nselected assertions: 99\\n')\nprint('Lua .1.26: 2994 exact scoped mapping observations and 198 existing fixture assertions pass across both installed hosts')\n")
LUA_UNICODE_LOWER_READING_26
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua126/prepare.py
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua126/select-tests.py
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua126/mappings.lua > .linkedspec-data/scratch/lua126/mappings-puc.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua126/selected.lua > .linkedspec-data/scratch/lua126/selected-puc.log
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua126/mappings.lua > .linkedspec-data/scratch/lua126/mappings-luajit.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua126/selected.lua > .linkedspec-data/scratch/lua126/selected-luajit.log
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua126/verify.py
```

Related facts: [[lua-declaration-trace-reading-and-validation-gaps]],
[[lua-startup-reading-coverage]], [[lua-reading-evidence-capacity-admission]].

## Preservation and documentation verification

The independent audit preserves 1,401 prior source, Knowledge, decision, immutable
history and policy files byte-for-byte. Of 2,564 prior task nodes, only the current
reading leaf and startup .3.6 change; all 2,562 others remain exact, with no new
repair node or closure. Both historical suffixes, the live History query section,
all 87 Known book headings and the parked authoring tree remain exact. All four
embedded payloads match their executed scratch originals. Independent range replay
reproduces the baseline inventory, all three digests and 26 completed groups.

Knowledge regeneration reports 1,112 facts /8,909 question keys. Memory passes at
60 lines. History checks pass without rollover: Changes 396 lines /28,262 bytes;
Notes 326 /25,301. The book renders; its 10,112,555-byte search-index warning stays
owned by startup .41.9. `git diff --check` passes. Normal registered commit hooks
remain required; no canonical gate, dependency build, source repair or push occurs.

---
id: lua-unicode-casing-properties-and-rule-label-reading
title: Lua casing properties and conversion complete with exact Unicode rule-label table reading
answers:
  - "what exact Lua source did startup reading child 28 cover"
  - "do all Lua Cased and Case_Ignorable property ranges match neutral Unicode data"
  - "how was Lua Final Sigma checked at property boundaries in startup reading"
  - "does the Lua casing decoder reject malformed UTF-8 before returning output"
  - "are all 806 Lua Unicode rule-label ranges physically read and verified"
  - "which Lua Unicode rule-label next-step guidance remains stale"
date: 2026-09-13
status: exact scoped reading and focused verification complete; existing guidance repair extended
tags: [lua, unicode, casing, rule-labels, startup, evidence]
evidence: "LUA-STARTUP-READING.1.28 activates from e7ddb725afb966836f63574d3afe876bc315f729. All 1500 fragments /34274 bytes are read in seven complete windows. All casing properties and 806 XID_Continue ranges match neutral data. Both installed hosts pass 16276 complete valid casing observations, 136 complete malformed UTF-8 rejection observations and 3412 classifier assertions; offline rule-label regeneration passes. Source and older evidence remain exact; .2.1 gains a precise stale forward-pointer annotation."
reverify: "Run LUA_UNICODE_PROPERTIES_READING_28 and all managed commands below; prior casing fixture and generation proof remains dated in lua-unicode-lower-completion-reading and lua-declaration-trace-reading-and-validation-gaps."
---

# Exact reading and comprehension

Read every scoped byte in seven complete, untruncated windows. The casing suffix
`lua/src/linkedspec/unicode_case_mapping.lua` 3170–3846 is 677 fragments /15,275
bytes, raw SHA-256 `01a21bd8c30e039aef5619d882b21dc71deeb51268dc315f6a3125912ea66e69`.
Its windows are 3170–3389, 3390–3609 and 3610–3846.
The rule-label prefix `lua/src/linkedspec/unicode_rule_label.lua` 1–823 is 823
fragments /18,999 bytes, raw SHA-256
`ef64a61578c00b881c111952a05bfb267a4a0a5ba27980b3a834c36b01e733d5`.
Its windows are 1–220, 221–440, 441–650 and 651–823. The ordered group digest is
`360d869362c55c7aebe072514dfa83394f735829b293831bfd946cbb7c1edd93`.

The casing suffix finishes the remaining 143 Cased rows and all 464 Case_Ignorable
rows. Combined with `.1.27`, all 158 Cased ranges are read. Inclusive binary search
implements membership. Final Sigma scans left and right past Case_Ignorable
scalars, requires a preceding Cased scalar, and chooses final sigma only when no
following Cased scalar remains. An overlapping property such as U+0345 is skipped
as ignorable before testing the surrounding cased context. Thus `ΑΣ` lowers to
`ας`, `ΑΣΑ` to `ασα`, and isolated `Σ` to `σ`; combining marks can be skipped
without changing the surrounding-word decision. Full mapping expansions and
identity fallback remain those read in `.1.26/.1.27`.

The byte decoder accepts one- through four-byte UTF-8 scalar encodings, rejects
invalid leads and continuations, overlong encodings, surrogates and values above
U+10FFFF. It decodes the complete input before conversion, so a malformed suffix
cannot return partially converted text. The encoder reconstructs valid scalar
bytes. These are internal string conversion functions, with no newly introduced
normalization, locale selection or host Unicode dependency. Private decoder
errors are not primary CLI portable diagnostic envelopes.

The rule-label prefix contains its generator notice, pinned contract/version/data
metadata, Lua-5.1-compatible byte/arithmetic aliases, and the complete 806-row
`XID_CONTINUE_RANGES` table at lines 17–822, closed at 823. The first interval is
U+0030–U+0039; the last is U+E0100–U+E01EF. All 149,221 admitted scalars match the
neutral contract. Digits and underscore are allowed at the first position as well
as later positions; rule identity preserves case and exact scalar sequence.
This rule-label class does not widen the separate function/method name grammar.
The classifier algorithm at 824–920 remains physically owned by `.1.29`.

Before code derivation, Knowledge retrieval resolved [[unicode-rule-label-contract]],
[[lua-unicode-rule-label-preflight]], [[lua-unicode-rule-label-implementation-plan]],
[[lua-unicode-rule-label-negative-isolation]] and
[[primary-cli-strict-utf8-text-contract]]. Earlier casing facts remain
[[six-variant-unicode-17-case-parity]] and [[unicode-17-case-contract-data]].
The preflight explicitly identifies its old ASCII-only result as superseded.
The implementation plan's metadata line 19 and final paragraph still name
source/outcome planning `.10.7.2.0` as the next step, despite later admitted semantic
owners. Existing repair `.2.1` now owns qualification of those precise forward
pointers. Historical classifier, native route, identity, body-fluent, negative
isolation and recomposition counts remain intact. The earlier repaired body-fluent
suffix loss is distinct from `.1.22`'s unfinished-argument defect under `.2.24`.
No new runtime defect is established by this source group.

Coverage reaches 28/51 groups, 37,651 fragments /1,392,051 bytes, with 48 complete
files and the rule-label module partial. All 99 Lua sources remain identical to
baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`. Next `.1.29` reads the classifier
suffix, complete function-definition parser and shell, and registry prefix. All
thirty repair roots, earlier failures, startup and supported-PUC prerequisites,
and the approved parked named-argument direction remain open or unchanged.

# Focused evidence and its limits

Exact table comparison covers all 158 Cased, 464 Case_Ignorable and 806 rule-label
ranges against the existing neutral JSON. Unicode remains 17.0.0; casing data SHA
is `5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae`, and rule-label
data SHA is `d1b00bda47306e61ee20a7f63db783f98b15d8d15b876c7506bc4b79ecebc0bb`.
The managed offline rule-label checker freshly regenerates and compares the
contract and generated modules, passing 806 ranges, nine positive fixtures,
eight negative fixtures and two distinct pairs without an external data download.

For casing context, 2,030 unique scalar points cover every Cased/Case_Ignorable
range endpoint and adjacent scalar. Four left/right contexts per point produce
8,120 cases. Eighteen additional direction-specific controls cover empty strings,
valid UTF-8 width/scalar boundaries, Sigma context, overlapping properties and
expansions. Expected full strings come from the existing neutral checker with the
pinned contract, not from Lua or the host Unicode library. Both installed hosts
match every case: 8,138 per host, 16,276 complete observations. The canonical
complete per-host JSON SHA-256 is
`8490d0d1276be63ffd6869dcf85d82401e506da67397c636a4a51f1b63c5bada`.
This is systematic property-boundary coverage, not an exhaustive test of all
possible strings or a new normative Unicode algorithm.

Seventeen malformed byte sequences run in both conversion directions, alone and
after a valid `AΣ` prefix. Both hosts reject all 68 cases, giving 136 complete
observations with exact input hex, direction, prefix, acceptance flag and private
error reason. Only source-location prefixes are excluded from comparison. The
complete canonical per-host result SHA-256 is
`fc57b0b23f1bd7f5b12deb0bf33898677252c8cec501598dd6b847e54289a712`.
There is no malformed regex/native PCRE probe in this proof.

The existing classifier test freshly passes 1,706 assertions on each installed
host, 3,412 total: metadata, every range endpoint, valid/invalid/distinct fixtures,
prefix byte positions, emoji boundaries and malformed UTF-8 suffix behavior.
Reading that diagnostic test does not advance its later physical reading owner.
Earlier native route, identity and negative-isolation totals are not recounted.
The `.1.26` twelve-fixture casing proof and `.1.25` offline casing generation proof
remain dated: the consumer source and twelve generation inputs are compared
byte-for-byte with their clean commits. No full CI, dependency build, source/tool
repair, push or new cross-backend runtime result is claimed. Installed PUC 5.5.1
and LuaJIT results do not close the missing PUC 5.4 target proof.

The initial scratch table reader used the wrong generated table name/spacing and
failed before producing cases. It was corrected to `XID_CONTINUE_RANGES` and the
actual whitespace grammar, then passed in full. That diagnostic-script mistake
is not a product defect; the final payload below is the executed passing version.

## Exact reproduction

```bash
bash tools/project_data_run.sh python3 - <<'LUA_UNICODE_PROPERTIES_READING_28'
from pathlib import Path
p = Path(".linkedspec-data/scratch/lua128")
p.mkdir(parents=True, exist_ok=True)
(p / 'prepare.py').write_text("from pathlib import Path\nimport hashlib\nimport json\nimport re\nimport runpy\nimport subprocess\n\nroot = Path('.linkedspec-data/scratch/lua128')\ncase_path = Path('lua/src/linkedspec/unicode_case_mapping.lua')\nlabel_path = Path('lua/src/linkedspec/unicode_rule_label.lua')\ncase = json.loads(Path('capability_conformance/unicode_case_contract.json').read_text())\nlabel = json.loads(Path('capability_conformance/unicode_rule_label_contract.json').read_text())\nassert case['data_sha256'] == '5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae'\nassert label['data_sha256'] == 'd1b00bda47306e61ee20a7f63db783f98b15d8d15b876c7506bc4b79ecebc0bb'\n\ndef ranges(source, name):\n    block = re.search(r'local ' + name + r' = \\{\\n(.*?)\\n\\}', source, re.S)[1]\n    rows = re.findall(r'  \\{\\s*0x([0-9A-F]+), 0x([0-9A-F]+)\\s*\\},', block)\n    assert len(rows) == len(block.splitlines())\n    return [(int(a, 16), int(b, 16)) for a, b in rows]\n\ncased = ranges(case_path.read_text(), 'CASED')\nignorable = ranges(case_path.read_text(), 'IGNORABLE')\nlabels = ranges(label_path.read_text(), 'XID_CONTINUE_RANGES')\nassert cased == [(int(a, 16), int(b, 16)) for a, b in case['cased_ranges']]\nassert ignorable == [(int(a, 16), int(b, 16)) for a, b in case['case_ignorable_ranges']]\nassert labels == [(int(a, 16), int(b, 16)) for a, b in label['xid_continue_ranges']]\nassert (len(cased), len(ignorable), len(labels), sum(b-a+1 for a,b in labels)) == (158, 464, 806, 149221)\nscoped = b''.join(case_path.read_bytes().splitlines(keepends=True)[3169:3846])\nassert len(scoped) == 15275 and hashlib.sha256(scoped).hexdigest() == '01a21bd8c30e039aef5619d882b21dc71deeb51268dc315f6a3125912ea66e69'\nscoped = b''.join(label_path.read_bytes().splitlines(keepends=True)[:823])\nassert len(scoped) == 18999 and hashlib.sha256(scoped).hexdigest() == 'ef64a61578c00b881c111952a05bfb267a4a0a5ba27980b3a834c36b01e733d5'\n\nneutral = runpy.run_path('tools/check_unicode_case_contract.py')\nlower = neutral['parse_mapping'](case['lower_mappings'], 'lower')\nupper = neutral['parse_mapping'](case['upper_mappings'], 'upper')\npoints = sorted({p for a,b in cased + ignorable for p in (a-1,a,b,b+1)\n                 if 0 <= p <= 0x10FFFF and not 0xD800 <= p <= 0xDFFF})\nassert len(points) == 2030\nrows = []\nfor point in points:\n    value = chr(point)\n    for context, text in [('left', value+'Σ'), ('skip-left', 'A'+value+'Σ'),\n                          ('right', 'AΣ'+value), ('skip-right', 'AΣ'+value+'A')]:\n        rows.append({'case': context + ':' + format(point, 'X'), 'operation': 'lower',\n                     'input': text, 'expected': neutral['convert'](text, lower, cased, ignorable, True)})\nedges = ['', ''.join(chr(p) for p in [0,0x7F,0x80,0x7FF,0x800,0xD7FF,0xE000,0xFFFF,0x10000,0x10FFFF]),\n         'ΑΣ', 'ΑΣΑ', 'Σ', 'A\\u0345Σ', 'AΣ\\u0345A', 'A\\u0301\\u0345Σ\\u0301\\u0345', 'Straße İ ᾀ ﬃ']\nfor index, text in enumerate(edges):\n    for operation, mappings in [('lower', lower), ('upper', upper)]:\n        rows.append({'case': 'edge:' + str(index), 'operation': operation, 'input': text,\n                     'expected': neutral['convert'](text, mappings, cased, ignorable, operation == 'lower')})\n(root / 'cases.json').write_text(json.dumps(rows, ensure_ascii=False, separators=(',', ':')) + '\\n')\nassert len(rows) == 8138\nsummary = {'property_points': len(points), 'contexts': len(points)*4, 'edges': len(edges)*2,\n           'valid_cases_per_host': len(rows), 'cased': len(cased), 'ignorable': len(ignorable),\n           'rule_label_ranges': len(labels), 'rule_label_scalars': sum(b-a+1 for a,b in labels)}\n(root / 'data-summary.json').write_text(json.dumps(summary, indent=2) + '\\n')\ngeneration_base = '67a97d3d32beb8b83fa1864e45102966699d7836'\npaths = ['capability_conformance/unicode_case_contract.json', 'unicode_case/generate_unicode_case_contract.py',\n         'tools/check_unicode_case_contract.py', 'perl/LinkedSpec/UnicodeCaseMapping.pm',\n         'rust/linkedspec-runtime/src/unicode_case_mapping.rs', 'dart/lib/src/runtime/unicode_case_mapping.dart',\n         'julia/src/runtime/UnicodeCaseMapping.jl', str(case_path)]\npaths += ['unicode_case/upstream/17.0.0/' + name + '.gz'\n          for name in ['LICENSE.txt', 'DerivedCoreProperties.txt', 'UnicodeData.txt', 'SpecialCasing.txt']]\nfor name in paths:\n    assert Path(name).read_bytes() == subprocess.check_output(['git', 'show', generation_base + ':' + name]), name\nassert Path('lua/test/run.lua').read_bytes() == subprocess.check_output(['git', 'show', '2e7046a44d0f6cafdc5bfeccc31f76c72b6ab122:lua/test/run.lua'])\nprint(json.dumps(summary, sort_keys=True))\n")
(p / 'algorithm.lua').write_text("local json = require('linkedspec.json')\nlocal casing = require('linkedspec.unicode_case_mapping')\nlocal file = assert(io.open('.linkedspec-data/scratch/lua128/cases.json', 'rb'))\nlocal cases = json.decode(file:read('*a')); file:close()\nlocal results = json.array()\nfor index, row in ipairs(cases) do\n  local actual = casing[row.operation == 'lower' and 'lowercase' or 'uppercase'](row.input)\n  assert(actual == row.expected, row.case .. ':' .. row.operation)\n  results[index] = json.harray({case=row.case, operation=row.operation, input=row.input,\n    expected=row.expected, actual=actual})\nend\nio.write(json.encode(results), '\\n')\n")
(p / 'invalid.lua').write_text("local json = require('linkedspec.json')\nlocal casing = require('linkedspec.unicode_case_mapping')\nlocal malformed = {\n  {'80','lead byte'}, {'BF','lead byte'}, {'C0AF','lead byte'}, {'C1BF','lead byte'},\n  {'F5808080','lead byte'}, {'FF','lead byte'}, {'C2','continuation byte'},\n  {'E282','continuation byte'}, {'F09080','continuation byte'}, {'C241','continuation byte'},\n  {'E24180','continuation byte'}, {'F0904180','continuation byte'},\n  {'E080AF','scalar encoding'}, {'F08080AF','scalar encoding'},\n  {'EDA080','scalar encoding'}, {'EDBFBF','scalar encoding'}, {'F4908080','scalar encoding'},\n}\nlocal results = json.array()\nfor _, row in ipairs(malformed) do\n  local raw = row[1]:gsub('..', function(pair) return string.char(tonumber(pair, 16)) end)\n  for _, operation in ipairs({'lowercase','uppercase'}) do\n    for _, prefix in ipairs({'','AΣ'}) do\n      local ok, err = pcall(casing[operation], prefix .. raw)\n      assert(not ok and type(err) == 'string')\n      local reason = err:match('(invalid UTF%-8 .*)$')\n      assert(reason == 'invalid UTF-8 ' .. row[2], row[1] .. ':' .. operation)\n      results[#results+1] = json.harray({hex=row[1], operation=operation, prefix=prefix,\n        accepted=ok, reason=reason})\n    end\n  end\nend\nassert(#results == 68)\nio.write(json.encode(results), '\\n')\n")
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib\nimport json\n\nroot = Path('.linkedspec-data/scratch/lua128')\nrows = json.loads((root / 'cases.json').read_text())\nexpected = [dict(row, actual=row['expected']) for row in rows]\nassert len(expected) == 8138\nmalformed = [('80','lead byte'),('BF','lead byte'),('C0AF','lead byte'),('C1BF','lead byte'),\n             ('F5808080','lead byte'),('FF','lead byte'),('C2','continuation byte'),\n             ('E282','continuation byte'),('F09080','continuation byte'),('C241','continuation byte'),\n             ('E24180','continuation byte'),('F0904180','continuation byte'),\n             ('E080AF','scalar encoding'),('F08080AF','scalar encoding'),('EDA080','scalar encoding'),\n             ('EDBFBF','scalar encoding'),('F4908080','scalar encoding')]\ninvalid_expected = [dict(hex=raw, operation=op, prefix=prefix, accepted=False, reason='invalid UTF-8 '+reason)\n                    for raw,reason in malformed for op in ['lowercase','uppercase'] for prefix in ['','AΣ']]\ndigests = {}\nfor name, value in [('algorithm',expected),('invalid',invalid_expected)]:\n    for host in ['puc','luajit']:\n        actual = json.loads((root / (name+'-'+host+'.json')).read_text())\n        assert actual == value, (name,host)\n        digest = hashlib.sha256(json.dumps(actual, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()).hexdigest()\n        if name in digests: assert digests[name] == digest\n        digests[name] = digest\nsummary = dict(complete_valid_observations=2*len(expected), complete_invalid_observations=2*len(invalid_expected), digests=digests)\nassert digests == {'algorithm':'8490d0d1276be63ffd6869dcf85d82401e506da67397c636a4a51f1b63c5bada',\n                   'invalid':'fc57b0b23f1bd7f5b12deb0bf33898677252c8cec501598dd6b847e54289a712'}\n(root / 'verification.json').write_text(json.dumps(summary, indent=2) + '\\n')\nprint(json.dumps(summary, indent=2))\n")
LUA_UNICODE_PROPERTIES_READING_28
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua128/prepare.py
bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py
bash tools/run_lua_project_data.sh puc lua/test/unicode_rule_label_classifier_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/unicode_rule_label_classifier_test.lua
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua128/algorithm.lua > .linkedspec-data/scratch/lua128/algorithm-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua128/algorithm.lua > .linkedspec-data/scratch/lua128/algorithm-luajit.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua128/invalid.lua > .linkedspec-data/scratch/lua128/invalid-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua128/invalid.lua > .linkedspec-data/scratch/lua128/invalid-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua128/verify.py
```

Related facts: [[lua-startup-reading-coverage]], [[lua-reading-evidence-capacity-admission]],
[[lua-unicode-lower-completion-reading]], [[lua-unicode-upper-completion-reading]].

## Preservation and documentation verification

The independent audit preserves all 1,403 prior source, Knowledge, decision,
immutable-history and policy files. Three nodes change among 2,564 prior task
nodes: this reading leaf, the precise existing .2.1 guidance annotation and
startup .3.6. The other 2,561 nodes remain exact; no new node is introduced.
Both historical suffixes, live History query instructions, all 87 Known book
headings and the parked authoring tree are exact. Four embedded payloads equal
the executed passing files. Full range replay reproduces every baseline digest
and all 28 completed groups without adding unread-source credit.

Knowledge regeneration reports 1,114 facts /8,919 question keys. Memory passes
at 60 lines. The shared history checker passes 34 mutation controls and all
three surfaces /66 segments. Neither current history needs rollover: Changes
410 lines /29,565 bytes, Notes 340 /26,840. The book renders; its 10,114,171-byte
search-index warning remains startup .41.9-owned. `git diff --check` passes.
Normal registered hooks remain required for this focused commit; no canonical
gate or pending repair closure is claimed.

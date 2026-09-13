---
id: lua-diagnostic-slot-gap-consumer-reading
title: Lua diagnostic and duplicate-slot consumers and the exact gap-prefix proof
answers:
  - "what exact Lua source did startup reading child 31 cover"
  - "which Lua diagnostic and duplicate slot assertions ran during startup reading"
  - "does the duplicate slot emitted source role execute a fresh emitted module"
  - "why does the Lua gap prefix have 185 assertions instead of 257"
  - "where are the 178 Lua gap metadata assertions located in the consumer"
  - "which gap private stage guidance remains owned for qualification"
date: 2026-09-13
status: exact scoped reading and focused proof complete; prior repairs and later gap consumer reading remain open
tags: [lua, diagnostics, regex-slots, gaps, generated-source, startup, evidence]
evidence: "LUA-STARTUP-READING.1.31 activates from 8878c8cb48b28386514e93c5cb0132e06eb5cac2. Eight complete windows read 1500 fragments /54442 bytes. Both installed hosts pass diagnostic119, duplicate-slot112 and gap-prefix185: 832 fresh assertions. Neutral duplicate-slot7/0/59 and gap9/0/63/public8/15/10/34 pass. Existing .2.1 owns precise private-stage guidance qualification; no new runtime defect or production change."
reverify: "Run LUA_SLOT_GAP_READING_31 and the managed commands below; the fresh gap run ends before independent emitted execution."
---

# Exact reading

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/diagnostic_output_contract_test.lua | 242–327 | 86 /3669 | 8ef53c57ac4bf62fe8df337bd23360dd2f2020f31d3ae9a1c0e1c938b874ae9d |
| lua/test/duplicate_regex_slot_identity_contract_test.lua | 1–467 | 467 /17777 | f015dd0fcb8c4d303f47edeef2adc93126ec0eb8c7665c102819167a636ea67b |
| lua/test/inter_match_gap_capture_contract_test.lua | 1–947 | 947 /32996 | 0ff3dfc2147fb2b095690175e251393ff958228f8ab66a47c1b20aad0e1c3ae7 |

Diagnostic242–327 has one viewing window; duplicate-slot windows are 1–240 and
241–467; gap windows are 1–220, 221–440, 441–660, 661–860 and 861–947. All eight
outputs were complete. Ordered range SHA-256 is
`3289093b514031c30ff31b742148da9b5276d643fab27c77daccdc0693d101fc`.
All 99 Lua files remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 31/51 groups,
42,151 fragments /1,557,723 bytes and 56 complete files. The gap module remains
partial: the owned range ends during the emitted value-case table.

# Consumer comprehension

The diagnostic suffix completes trace/event separation, native/generated event
identity, exact caller-object propagation from a failing diagnostic sink, and
the distinct RuntimeExitNow status23 channel with preceding events retained.
Its Unicode diagnostic text remains absent from the trace. The complete consumer
passes 119 assertions per installed host. It does not exercise the known PUC5.5
nil-error discrepancy or malformed native PCRE compilation.

The duplicate-slot consumer executes fifteen declared roles once each. Five
neutral fixtures preserve authored slot identity through ordered, choice, repeat,
cross-target, loaded, reconstructed, descriptor, generated direct/traced, native
trace and existing-primary routes. Required-slot matching indexes the actual
compiled alternative; choice uses earliest start and authored order for ties.
Ordered repetition resets the next required slot correctly. Loaded fixture files
stay in a managed temporary workspace with cleanup after success or failure.

The `emitted_source` role verifies the emitted source header, embedded normalized
hex and contract shape. It does not independently load and execute a fresh module.
The generated direct/traced roles do execute the shared interpreter. Invalid
compiled slot identity is rejected across neutral validation, runtime, emission
and generated boundaries. The ordered First#0/Second#0 mismatch retains the
neutral diagnostic fields; no additional target field or new diagnostic defect
is inferred. All 112 assertions pass on both hosts.

The gap prefix checks named and anonymous regex declarations, numeric positional
selectors versus stable named identity, exact Unicode spelling and directive
eligibility. Default/OR and eligible repetition use capture-only preselection;
blind, mixed, adjacency-owned and incompatible legacy-marker forms reject it.
Named marks remain independent. Static diagnostics retain logical source identity.
Descriptor additions stay within metadata: regex_slots, capture_gaps and the
five-field resolved-slot edges. Existing top-level fields, resolved edges and
dependency references remain exact. Legacy normalized input defaults source_id
to inline; loaded relative requests retain their caller-logical path while an
absolute request uses its basename. Emitted normalized source retains that identity.

Native checks cover Unicode prefix/interstitial/tail and empty spans, entry-slot
identity with falsey payloads, candidate availability before LS, child-extended
cursor commits, nested isolation, checkpoint rollback and successful LX/EX/E tails.
No-match success exposes the full tail; failed minimum and direct entry preserve
null semantics. Unavailable context, accessor arity and cursor regression retain
typed errors. Reconstruction, detached descriptor mutation controls, unchanged
format2 `{label,family}` plans and actual generated direct/traced execution share
the same engine. Recursive, rollback and child-cursor cases retain their results.
The owned final lines start the emitted test table; they do not complete that role.

# Assertion-count root cause and bounded proof

The initial scratch generator had a newline-quoting error and failed before test
execution; the generator was corrected. Its first count guard then expected 257
by summing the historical 178 metadata +33 native +46 carrier categories.
The actual prefix completed successfully but reported 185. Checkpoint-only
instrumentation establishes 106 after line338, 139 after line556 and 185 after
line810, independently locating the native33 and carrier46 groups.

A targeted auxiliary read of lines1159–1269 and1450–1462 explains the discrepancy:
ten portable-diagnostic cases appear after the emitted block, with five common
fields each and 22 case-specific fields, adding 72 metadata checks. Thus the
historical metadata178 is 106+72 across two source regions. The full historical
392 is 185+105 emitted+72 later metadata+30 admission. The printer outputs the
actual counter. This is an incorrect scratch prefix expectation, not a runtime
failure or inconsistent historical result. The auxiliary read does not advance
child32 coverage or claim fresh emitted/admission proof.

Fresh native results are 119+112+185=416 per host, 832 total. The full392 logs from
`.1.23` remain dated evidence. Current neutral gap verification passes nine complete
rows, zero pending, 63 semantic mutations, public8/15/10/34, ten admission mutations
each for Rust/Dart/Julia and sixteen for Lua. Duplicate-slot verification passes
five fixtures, two diagnostics, six runtimes, seven complete rollout rows, zero
pending, 21 public documents, eleven forbidden claims and 59 drift mutations.
These are focused consumer/governance results, not a full gate or PUC5.4 admission.

# Knowledge and repair reconciliation

Retrieved [[lua-diagnostic-output-events]], [[lua-duplicate-regex-slot-identity-admission]],
[[duplicate-regex-slot-identity-contract]], [[inter-match-gap-lua-implementation-plan]],
[[inter-match-gap-executable-contract-plan]] and
[[inter-match-gap-recurring-public-closeout-plan]] before deriving their current
mechanisms. The parent and closed successor explicitly qualify historical rollout
stages and identify current9/0/63/public8/15/10/34; their older evidence is preserved.

Existing `LUA-STARTUP-READING.2.1` now owns qualification of the gap consumer header
and Lua private-plan metadata/lines77/110, which retain recurring/public-pending
guidance. Preserve dated392 and7/2/60 evidence while making the stage boundary clear.
No old Knowledge card or source is edited here. All thirty-three Lua repair roots,
the PUC5.5 nil-error and public-selector baseline failures, startup .3/.4/.5 gates
and parked named arguments remain unchanged.

# Exact replay

All generated files are repository-relative. The first block reconstructs the
small exact payloads; managed wrappers derive runtime paths and host workspaces.
The selected prefix copies original test bytes and adds count-only checkpoints;
all original checks remain unchanged.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_SLOT_GAP_READING_31'
from pathlib import Path
p = Path('.linkedspec-data/scratch/lua131')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\nsource = Path("lua/test/inter_match_gap_capture_contract_test.lua").read_text().splitlines(keepends=True)\nassert source[809] == "end\\n" and source[811] == "do\\n"\nassert source[812] == "  local emitted_assertions_start = assertions\\n"\nPath(".linkedspec-data/scratch/lua131/gap-prefix.lua").write_text("".join(source[:338]) + \'print("gap metadata: " .. assertions)\\n\' + "".join(source[338:556]) + \'print("gap before carrier: " .. assertions)\\n\' + "".join(source[556:811]) + \'\\nassert(assertions == 185, "gap prefix assertion count drift: " .. assertions)\\nprint("gap prefix: " .. assertions .. " assertions passed")\\n\')\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib, json\n\nroot = Path('.linkedspec-data/scratch/lua131')\nfor row in json.loads((root / 'scope.json').read_text()):\n    data = b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start'] - 1:row['end']])\n    assert len(data) == row['bytes']\n    assert hashlib.sha256(data).hexdigest() == row['sha256']\nexpected = {\n    'diagnostic': 'diagnostic output contract: 119 assertions passed\\n',\n    'slots': 'duplicate regex-slot identity dual-ABI admission: 112 assertions passed\\n',\n    'gap': 'gap metadata: 106\\ngap before carrier: 139\\ngap prefix: 185 assertions passed\\n',\n}\nfor host in ['puc', 'luajit']:\n    for suite, result in expected.items():\n        assert (root / f'{suite}-{host}.log').read_text() == result\nneutral_gap = (root / 'neutral-gap.log').read_text()\nfor text in ['9 complete + 0 pending rollout', '63 rejected semantic mutations', '8 public documents', '15 stale-current denials', '10 outward guards', '34 rejected public mutations', '16 rejected Lua admission mutations']:\n    assert text in neutral_gap, text\nneutral_slots = (root / 'neutral-slots.log').read_text()\nfor text in ['5 fixtures', '7 complete + 0 pending rollout', '59 drift mutations']:\n    assert text in neutral_slots, text\nprint('PASS: exact source windows; 119 diagnostic + 112 duplicate-slot + 185 gap-prefix assertions per host, 832 total; current neutral gap and duplicate-slot governance')\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/diagnostic_output_contract_test.lua",\n    "start": 242,\n    "end": 327,\n    "bytes": 3669,\n    "sha256": "8ef53c57ac4bf62fe8df337bd23360dd2f2020f31d3ae9a1c0e1c938b874ae9d"\n  },\n  {\n    "path": "lua/test/duplicate_regex_slot_identity_contract_test.lua",\n    "start": 1,\n    "end": 467,\n    "bytes": 17777,\n    "sha256": "f015dd0fcb8c4d303f47edeef2adc93126ec0eb8c7665c102819167a636ea67b"\n  },\n  {\n    "path": "lua/test/inter_match_gap_capture_contract_test.lua",\n    "start": 1,\n    "end": 947,\n    "bytes": 32996,\n    "sha256": "0ff3dfc2147fb2b095690175e251393ff958228f8ab66a47c1b20aad0e1c3ae7"\n  }\n]\n')
LUA_SLOT_GAP_READING_31
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua131/select-tests.py
for host in puc luajit; do
  bash tools/run_lua_project_data.sh "$host" lua/test/diagnostic_output_contract_test.lua > ".linkedspec-data/scratch/lua131/diagnostic-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" lua/test/duplicate_regex_slot_identity_contract_test.lua > ".linkedspec-data/scratch/lua131/slots-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" .linkedspec-data/scratch/lua131/gap-prefix.lua > ".linkedspec-data/scratch/lua131/gap-$host.log" 2>&1 || exit
done
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py > .linkedspec-data/scratch/lua131/neutral-gap.log 2>&1
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py > .linkedspec-data/scratch/lua131/neutral-slots.log 2>&1
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua131/verify.py
```

Related evidence: [[lua-invocation-and-callable-consumer-reading]],
[[lua-startup-reading-coverage]].

# Candidate verification

Independent base-relative preservation passes for 1,406 source, prior Knowledge,
decision, immutable-history and policy files. Of 2,582 old task nodes, 2,579 are
byte-identical; only this reading leaf, existing guidance repair .2.1 and startup
.3.6 change. No new repair node is added. All 90 prior book limitation headings,
the parked authoring tree, history preambles/suffixes and live-history pointer
remain intact. All three embedded replay payloads match their executed files.
The independent full inventory/range replay passes at 31 completed groups.

Memory is 60 lines and its phase/handoff checks pass. Shared history passes all
34 mutation controls and its three surfaces/66 segments. Changes is 431 lines /
31,569 bytes (within cap, pressure warning); notes is 361 lines /29,270 bytes.
Knowledge generation yields 1,117 cards and 8,940 question keys. The book renders
successfully; its existing search-index warning is 10,125,723 bytes and remains
owned by startup .41.9. Whitespace checks pass. Normal per-leaf hooks still govern
landing; no canonical gate, PGEN/RGX build, dependency change or push is claimed.

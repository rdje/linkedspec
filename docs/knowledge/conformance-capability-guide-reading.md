---
id: conformance-capability-guide-reading
title: Capability guide retains stale current census and callable claims behind passing checkers
answers:
  - "why does the capability guide still say current census 17/85"
  - "why does the capability guide say 24 semantic mutations when the checker reports 19"
  - "why does the capability guide call generic callable codeblocks future"
  - "which tasks fix the capability guide current claim drift"
  - "what is covered by conformance source reading group 1"
date: 2026-09-13
status: guide prefix .1.1 read; confirmed guide defects remain owned by startup .41.6/.41.7
tags: [conformance, reading, capability, callable, documentation, verification]
evidence: "CONFORMANCE-SOURCE-READING.1.1 reads the exact baseline-identical capability guide prefix. Its current17/85 census and24 semantic-mutation text survive capability conformance20/100/19; generic callable future wording survives callable23-governance and signature3/9/7 checks. Existing startup .41.7/.41.6 now explicitly own these exact paragraphs and recurrence. No runtime bug, source repair or new capability admission is claimed."
reverify: "Run CONFORMANCE_GUIDE_CLAIMS below, then managed perl tools/check_capability_conformance.pl and tools/check_callable_codeblock_contract.py plus tools/check_callable_signature_contract.py. These are structural/neutral checks, not a new six-runtime matrix."
---

# Actual current-claim gap

The completed reading covers lines1–770 in11 complete windows,770 fragments/
65,485 bytes; lines771–897 and the following callable-codeblock section remain
`.1.2`-owned. Ordered source-window SHA-256 is
`82c1b7aca6d2fd95e45a51c2b93fb7a50e3c19f1b2b42c77f90cfa8457e7f180`. Baseline scope SHA-256 is
`15e215a231e1fbe97483ee8a318a5934b8ea8336483b4166bebc891590e821df`.

At reading activation `d3cfa5973beed85de5ae58dc81798262cafe18ad`, the unchanged
`capability_conformance/README.md` has three concrete inconsistent claims:

- Lines330–336 call17 capabilities/85 states current and refer to24 semantic
  mutations, while the current manifest and checker report20/100 and19 exclusion
  governance mutations. Startup `.41.7` owns correction or explicit dating and
  recurrence for these exact paragraphs alongside its existing count/workflow work.
- Lines347–348 describe generic callable codeblocks as separately future. Current
  five-backend recurring/public admission removes that exclusion. Startup `.41.6`
  owns explicit historical qualification of the final-codeblock-v3 boundary and
  truthful current generic-callable status, with actual-paragraph controls.

The actual capability tool passes schema v2,20 capabilities,100/0/0 states,one
legacy exclusion,19 exclusion mutations,16 mutation-admission,17 recurring,
four mutation-public-gate,twelve projections,six public andfour language-surface
mutations. The callable checker passes7 literals/11 calls/9 invalid literals/
7 invalid calls/4 invalid declarations/8 contextual forms/23 governance mutations;
the signature checker passes3 definitions/9 calls/7 invalid definitions.
Four further focused neutral checks pass: cursor36 family spellings/18 edges/
8 parent-child cases/74 migration files/8 complete/60 mutations; repeated action
8 modes/10 specials/8 complete/54 mutations; logical17 truthiness/10 helpers/
3 effects/8 complete/19 public documents/14 denials/26 mutations; root selection
8 selections/3 failures/3 strict cases/7 complete/54 mutations. The same read guide
still says current72 cursor migration files,44 repeated-action mutations and
20 logical public documents/13 denials. Startup `.41.7` includes these exact
present-tense count discrepancies. Similar first-class-literal “until” wording at
741–742 joins `.41.6`; explicitly historical rollout paragraphs remain history.
These successful tools do not certify the contradictory surrounding paragraphs.

Root cause: `tools/check_capability_conformance.pl`94–100 selects two guide
markers;660–702 checks prescribed normalized marker/denial strings. It does not
compare the guide's surrounding current census/governance prose to the manifest.
`tools/check_callable_codeblock_contract.py`600–629 similarly checks required
markers and exact forbidden strings. The guide has its current required callable
markers elsewhere, while the actual future claim is absent from those denials.
The same marker/denial mechanism is explicit in cursor1131–1154, repeated
action672–684, and logical816–828. The actual checkers pass with the listed source
claims unchanged. This extends the existing finite-public-checker problem; it does not reverse
historical admission or prove an untested runtime failure.

No guide, checker, contract or runtime source is changed during this reading.
Existing repairs retain startup prerequisites. No newly discovered runtime behavior
is inferred from this technical guide or from structural/neutral checks. Preserve genuinely historical
milestone counts rather than rewriting them as present-day execution evidence.

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_GUIDE_CLAIMS'
from pathlib import Path
import hashlib,json,re,subprocess
p=Path('capability_conformance/README.md');raw=p.read_bytes();text=raw.decode();normal=' '.join(text.split())
assert raw==subprocess.check_output(['git','show','baeb984e36a94a15951cd23d4c52def5064cdaca:'+p.as_posix()])
claims=['making the current census 17/85','without duplicating the manifest\'s 24 semantic mutations','Final-codeblock-v3 admission by Perl and Lua does not promote the separately future generic callable-codeblock capability.']
claims += ['currently owns an exact 72-file migration inventory', 'and rejects 44 drift mutations.', 'Public no-drift additionally locks 20 authoritative documents and 13 forbidden current claims.', 'The codeblock row is model/backend-unit evidence only until the separately owned first-class literal program lands;']
assert all(x in normal for x in claims)
manifest=json.loads(Path('capability_conformance/manifest.json').read_text());assert len(manifest['capabilities'])==20 and len(manifest['backends'])==5
assert [x['id'] for x in manifest['excluded_or_future']]==['legacy.perl_plugin_registry']
contract=json.loads(Path('capability_conformance/callable_codeblock_contract.json').read_text())
public=contract['public_contract'];guide=next(x for x in public['documents'] if x['path']==p.as_posix())
assert all(x in text for x in guide['required_markers'])
for x in public['forbidden_current_claims']:
 if x['path']==p.as_posix():assert x['text'] not in text
report={'source_sha256':hashlib.sha256(raw).hexdigest(),'confirmed_current_claims':claims,'capability_rows':20,'backends':5,'sole_exclusion':'legacy.perl_plugin_registry','callable_public_documents':len(public['documents']),'required_callable_guide_markers_present':guide['required_markers'],'actual_bad_callable_claim_not_rejected':True,'repair_owners':['SESSION-STARTUP-READING.41.6','SESSION-STARTUP-READING.41.7']}
s=Path('.linkedspec-data/scratch/conformance11');s.mkdir(parents=True,exist_ok=True);(s/'guide_claims.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
CONFORMANCE_GUIDE_CLAIMS
bash tools/project_data_run.sh env PERL5LIB= perl tools/check_capability_conformance.pl
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py
```

Related: [[startup-public-teaching-checker-blind-spots]],
[[capability-exclusion-freshness-gap]], [[mutation-capability-admission]],
[[callable-codeblock-five-backend-admission]], [[conformance-source-reading-coverage]].

# Comprehension boundary

The prefix distinguishes capability states/evidence and the retained legacy
exclusion from independent runtime execution. Frozen write/bang/composition data
remain separate from later admission, recurring execution and public teaching.
MCP transport, generated bindings and implementation ledgers have different owners;
semantic snapshots and twenty governed query responses are independent from parser
construction. Typed-source values, recognition, observation, gaps, progressive
bounded dispatch and recursive staged jobs compose through private authority and
explicit public exclusions. Root selection is independent of regex-slot choice;
duplicate identity and repeated-action result collection preserve their own
contracts. Scalar rendering, strict numeric inputs, eager logical values and
variadic signatures retain separate neutral authorities. The callable-codeblock
section itself starts at the final line and is not yet fully read.

Commands in the guide include direct Cargo/Dart/Julia invocations. Existing
startup `.41.7` already requires repository-root managed examples; no unmanaged
command was executed and no off-volume effect is claimed by inspection. Known
runtime defects stay with their existing backend/startup owners even where the
guide describes a historically admitted contract.

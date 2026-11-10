"""Compact only new selection/plan prose; retain its exact pre-edit bodies."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[3]
overview = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
helpers = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
old_overview = gzip.decompress((BASE / (overview.name + '.before.gz')).read_bytes()).decode()
old_helpers = gzip.decompress((BASE / (helpers.name + '.before.gz')).read_bytes()).decode()
assert overview.read_text() == old_overview and helpers.read_text() == old_helpers
contract = ROOT / 'docs/checkpoints/type-operation-inventory/array-pipeline-result-guard-composition.md'
contract_body = contract.read_bytes()
selection = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.39`\n'
prefix, node = old_overview.split(selection)
header = node[:node.index('  Activation:')]
assert header.startswith('  Status: `completed`')
verification = node[node.index('  Verification tier:'):node.index('  Additional owned documentation defect:')]
compact = selection + header + '''  Activation: Clean2a0a4b4ad7a51f2aa7e7a8e511020a5a6768902c after Lua78.5 all10/post-pointer/brief0/clean Git. Canonical syntax/helper/authority ledger/pipeline book and value/standalone contract read; own source/grammar/instruments precede SDK use. No production edit or peer policy inheritance.
''' + verification + '''  Outcome: Original36 public Get/descriptor/substitution/dump_parser_source/native/full emitted-fresh retains17 defects (ten free/later Hash-copy runtime errors/seven literal receiver handler-module compile failures) and19 healthy controls, including four needed errors. Actual metadata29 ready/seven ready0-unresolved1 is preserved. All36 module-handler pairs/first inputs/full channels survive. Constructor HASH-kind rejection distinguishes missing pipeline result roles in MethodLowering.pm retained/copy/logical/with paths. First readonly0/empty stderr/eleven controls passes; qualified current-input producer/command/channels/exit proves unchanged Perl/grammar/instruments. Preliminary inline check has no standalone producer-bound credit. Full detail: docs/checkpoints/array-pipeline-result-selection-2026-11-10/REVIEW.md. Frozen36/contract/five independent family79 owners precede production.
  Continuity: Fix helpers.md's two stale current frontier sentences and obsolete catalog blanket direct-return warning; healthy pure values/source preservation and standalone writeback remain, compact I.return split caveat separate. Book/Knowledge/roadmap/live/history/MEMORY agree. Full source/context/native-cache-transitive custody4.2/SESSION5/registration/declared5.4/full23.4 remain separate.
  Containment: First normal attempt rejects task_evidence12586933/12582912 (4021 over). Preserve exact staged task bodies/full failed log in containment/, then TERM only own remaining commit/hooks; commit143 and unfinished claim check are not PASS, HEAD unchanged. This producer deduplicates only new39/79 prose via unchanged canonical contract/REVIEW; accepted task bodies/statuses/requirements and limits stay unchanged. Capacity4.21 follows clean selection before Perl79.1; final book/Knowledge/index/reference scope/history/memory/diff and all normal hooks still required.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/call_spec_handler_subst/dump_parser_source/native/fresh36 retains17 failures/19 healthy.
  - [x] **ROOT CAUSE (WHY + WHERE)** — actual substitutions retain receiver DSL/free Hash copy; MethodLowering ordinary result roles omit pipelines; constructor rejects.
  - [x] **FIX** — unchanged36/contract/family79 owners frozen; current guidance corrected, no production edit.
  - [x] **ADDRESSED (verified)** — first readonly0/eleven denials; source/Git/modes/metadata/values/errors/warnings/absent fields/36 artifact pairs exact.
  - [x] **NO REGRESSION** — nineteen healthy/four needed errors; production/grammar/78 targets/formats unchanged.
  - [x] **LOCKSTEP** — book/helper spine/Knowledge/task/frontier/live/history/MEMORY aligned; normal hooks govern landing.
'''
overview.write_text(prefix + compact)
family = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.79`\n'
prefix_helpers, _ = old_helpers.split(family)
new_family = family + '''  Status: `pending` / independent ordinary pure-pipeline result guards
  Children: `.79.1`, `.79.2`, `.79.3`, `.79.4`, `.79.5`.
  Goal: Preserve seven ordinary pure-pipeline Array results through actual-kind consumers.
  Dependencies: Completed selection23.1.39; unchanged tests/fixtures/array_pipeline_result_guard_cases.json.
  Acceptance: Apply docs/checkpoints/type-operation-inventory/array-pipeline-result-guard-composition.md in full; its signatures, preservation, acquisition, exclusions and admission limits are normative. Original Perl36 has17 defects/19 healthy; no peer verdict. Own any observed source prerequisite before result repair.
  Backend proof contract: Independently acquire unchanged36 plus own initial Number/null/Hash, arities/source-delimiter-pattern errors/earlier-owner fences before production. Retain actual first source/grammar/instrument/artifact/full channels, every healthy observation and exact old/current loaded-owner SDK inverse/readonly recovery/corruptions when repaired. Keep producers, pure-versus-standalone semantics and all canonical exclusions unchanged. Healthy assessments need no speculative edit. Installed Lua: actual native products before load, no new chunk locals/unsafe full runner/declared5.4 inference. Full custody4.2/SESSION5/context/isolation/registration/23.4 separate.
  Focused execution: Smallest new/direct-dependent producer-pipeline-Array normals and changed syntax/format/exact runner include; book/Knowledge/history/task/memory/diff/normal hooks. No broad suite/matrix.
  Frontier: Capacity4.21 after clean selection, then independent Perl/Rust/Dart/Julia/installed Lua; each normal commit/brief0/clean handoff precedes the next.
'''
backends = [('Perl', 'native/full emitted-fresh plus descriptor/substitution/handler diagnostics'),
    ('Rust', 'native/restored CompiledSpec/generated-plan/compiled emitted-fresh'),
    ('Dart', 'native/restored SpecFile/generated-plan/full emitted-fresh'),
    ('Julia', 'native/restored SpecFile/generated-plan/full emitted-fresh'),
    ('installed Lua', 'each actual PUC/LuaJIT native/restored SpecFile/generated-plan/full emitted-fresh')]
for number, (backend, routes) in enumerate(backends, 1):
    new_family += f'''
- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.79.{number}`
  Status: `pending`
  Goal: Independently assess/repair {backend} ordinary pure-pipeline result guards.
  Dependencies: Frozen79/36; preceding clean owner; no peer policy inheritance.
  Acceptance: Parent79 contract in full on {routes}; own policies acquired before production.
  Planned verification: Parent79 focused execution.
  Planned canonical trigger: Parent79 full23.4/final push after coverage.
  Planned claim verification: none: Finite authored preservation/repair controls, no population/performance measurement.
'''
helpers.write_text(prefix_helpers + new_family)
assert overview.read_text().startswith(prefix) and helpers.read_text().startswith(prefix_helpers)
assert contract.read_bytes() == contract_body
for before, after in ((old_overview, overview.read_text()), (old_helpers, helpers.read_text())):
    ids = lambda body: re.findall(r'^- ID: `([^`]+)`$', body, re.M)
    assert ids(before) == ids(after)
    states = lambda body: re.findall(r'^  Status: `([^`]+)`', body, re.M)
    assert states(before) == states(after)
result = dict(overview_saved=len(old_overview.encode()) - overview.stat().st_size,
    helpers_saved=len(old_helpers.encode()) - helpers.stat().st_size,
    unchanged_contract_sha256=hashlib.sha256(contract_body).hexdigest(),
    preservation='All prefixes before new39/79, stable IDs/statuses and complete canonical79 contract unchanged; exact pre-edit bodies retained.')
(BASE / 'compaction-result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))

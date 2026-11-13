"""Publish the verified field boundary and the director-requested clean handoff."""
import copy
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.28'
ACTIVATION = 'e0a1bb47571b75b800546c3d4522e0d2ca5f778c'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
OUT = BASE / 'publication'
OUT.mkdir()
BOOK = Path('docs/linkedspec-book/src/appendix/runtime-semantics.md')
REFERENCE = Path('docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md')
CARDS = [Path('docs/knowledge') / (name + '.md') for name in ('lua-runtime-structured-diagnostics',
    'lua-callable-pipeline-result-guards', 'lua-callable-array-transform-result-guards', 'lua-callable-key-count-preservation')]
documents = [BOOK, REFERENCE] + CARDS + [Path(name) for name in ('MEMORY.md', 'CHANGES.md',
    'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md')]
buffers = {path: path.read_text() for path in documents}
originals = dict(buffers)


def freeze(paths, name):
    rows = {}
    with tarfile.open(OUT / (name + '.tar.gz'), 'x:gz') as archive:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            member = tarfile.TarInfo(str(path))
            member.size, member.mode = len(body), rows[str(path)]['mode']
            archive.addfile(member, io.BytesIO(body))
    with tarfile.open(OUT / (name + '.tar.gz')) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read()
            assert dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode) == rows[member.name]
    (OUT / (name + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


inputs = documents + [BASE / name for name in ('publish.py', 'book-section.md', 'fact-card.md',
    'REVIEW.md', 'CUSTODY.md', 'analysis/result.json', 'normal/result.json', 'sealed-identities.json',
    'proofs/historical-review/exit.txt', 'proofs/historical-review/stdout.gz', 'proofs/historical-review/stderr.gz',
    'publication-inputs/result.json', 'publication-inputs/input-identities.json', 'publication-inputs/inputs-before-query.tar.gz',
    'index-publication-inputs/result.json', 'index-publication-inputs/input-identities.json',
    'index-publication-inputs/inputs-before-query.tar.gz', 'intake/input-identities.json', 'intake/inputs-before-use.tar.gz')]
freeze(inputs, 'inputs-before-use')
assert json.loads((BASE / 'publication-inputs/result.json').read_bytes())['live_intersections'] == []
assert json.loads((BASE / 'index-publication-inputs/result.json').read_bytes())['live_intersections'] == []
assert (BASE / 'proofs/historical-review/exit.txt').read_text() == '0\n'

insertion = (BASE / 'book-section.md').read_text()
assert buffers[BOOK].count('### 10.3 Input Validation') == 1
buffers[BOOK] = buffers[BOOK].replace('### 10.3 Input Validation', insertion + '\n### 10.3 Input Validation')
old_phrase = 'with raw-table4.28/declared5.4/full admission separate.'
assert buffers[REFERENCE].count(old_phrase) == 1
buffers[REFERENCE] = buffers[REFERENCE].replace(old_phrase,
    'with selected raw-field4.28 focused coverage and broader native4.2/declared5.4/full admission separate.')
for card in CARDS:
    buffers[card] += '\n\nNovember13 selected-field qualification: [[lua-raw-error-observation-scope]] records the eight-case/four-route old-current companion and the original scopes of eight function-grammar result-guard normals. Earlier counts/observations remain dated; no all-native-field, retrospective custody or fresh-process credit is added. Selected normal128 per installed host and specific legacyRED1/rawGREEN0 pass; broader native4.2/SESSION5 and current discovery4.1 remain separate.\n'
runtime_card = CARDS[0]
old_reverify = 'reverify: "bash tools/run_lua_local.sh && rg -n \'RuntimeDiagnostic|runtime_diagnostic|runtime-structured-diagnostics\' lua/src lua/test/run.lua"'
assert buffers[runtime_card].count(old_reverify) == 1
buffers[runtime_card] = buffers[runtime_card].replace(old_reverify,
    'reverify: "bash tools/run_lua_project_data.sh puc lua/test/raw_error_observation_test.lua; bash tools/run_lua_project_data.sh luajit lua/test/raw_error_observation_test.lua; bash tools/run_python_project_data.sh docs/checkpoints/lua-raw-error-observation-2026-11-13/review.py"')
buffers[runtime_card] += '\nThe original126-suite result above remains dated history. The current focused recipe avoids the known unsafe full Lua formatter path, still owned by LUA-STARTUP-READING.2.3; declared5.4 remains separately owned.\n'
new_card = Path('docs/knowledge/lua-raw-error-observation-scope.md')
assert not new_card.exists()
buffers[new_card] = (BASE / 'fact-card.md').read_text()

summary = 'Lua selected raw-error coverage is focused-checked: eight source questions/two installed hosts/four routes/old-current128 records;2896 field controls with384 named native misses in the older projection. Each new standalone normal128PASS, specific legacyRED1/rawGREEN0 and first historical recovery0/ten controls pass. Complete source census204 identifies eight function-grammar guard normals: three full public-JSON helpers and five older partial named-field observers. Native/restored and generated envelopes keep distinct contracts. No SDK/serializer or old observation/hash changes; native/source/preparation-origin4.2/SESSION5 and declared5.4/full admission remain separate.'
frontier = 'November13 current fluent frontier: Bounded family80 outcomes remain focused. Resource14 landed at e0a1bb475 with exact canonical0/all10/post-pointer/clean proof. ' + summary + ' Director requested stop at the next clean checkpoint: finish raw28 normal commit and remeasure, then stop. On explicit resume, remeasure current HEAD, complete current discovery4.1 including the new standalone normal, and prepare canonical clean publication30.2. The e0/cached-origin4683555e pack is1,415,327,104 bytes/108 ahead, excluding28; preparation due and1.5GB overrides cadence. No before-push owner is waived. Evidence: ' + str(BASE / 'REVIEW.md') + '.'
for path in (Path('ROADMAP.md'), Path('ROADMAP_V2.md')):
    buffers[path], count = re.subn(r'^November\d+ current fluent frontier:.*$', lambda match: frontier,
        buffers[path], count=1, flags=re.M)
    assert count == 1

def prepend(path, text):
    position = re.search(r'^## ', buffers[path], re.M).start()
    buffers[path] = buffers[path][:position] + text.rstrip() + '\n\n' + buffers[path][position:]

prepend(Path('CHANGES.md'), '## 2026-11-13 — ' + OWNER + ': selected Lua raw error fields\n\n' + summary +
    ' Book examples and canonical field scopes now distinguish native tables from generated envelopes. The stale global task-index row is repaired after a separate213-record/nine-historical/zero-live query and injected-live RED. Source-only preparation-origin limits remain explicit; successful producers are not replayed. Stop after this focused clean handoff; discovery4.1 and all publication prerequisites remain. Evidence: ' + str(BASE / 'REVIEW.md') + '.')
prepend(Path('DEVELOPMENT_NOTES.md'), '## 2026-11-13 — ' + OWNER + ': JSON equality is projection-specific\n\n'
    'Lua fail stores native fields and with_runtime_diagnostic copies them, but to_json publishes message/diagnostic. Generated execution deliberately wraps display text in its own envelope. The shared observer therefore misses identifier/kind or duplicated function attribution changes while public JSON stays equal. The new test-only field observer and old per-host baseline add exact selected-field regression without changing those public formats. Eight-case old/current proof, actual legacyRED/rawGREEN and independent source/mutation/historical controls pass. Five older inline normals remain explicitly partial; three later helpers add published JSON. The global task-index next-slice cell was stale and is corrected under the same handoff. Preparation-source/channel limits are preserved under4.2, not retroactively repaired. Full CI belongs to current discovery/publication; this leaf is focused. Evidence: ' + str(BASE / 'REVIEW.md') + '.')

live = Path('LIVE_ACHIEVEMENT_STATUS.md')
for heading, text in (
    ('Current Activity', 'Director-requested stop at the next handoff-ready checkpoint. Raw28 focused implementation/evidence/docs complete; normal clean landing and final size check govern the stop. Full current discovery/publication remains pending.'),
    ('Latest Completed Slice', OWNER + '. ' + summary),
    ('Next Action', 'Await explicit resume; remeasure current committed outgoing bytes, then current discovery4.1 including the new raw-error normal and early publication30.2 after all before-push owners. Prepare near1.4GB and publish around1.5GB regardless cadence, with fresh remote/exact-HEAD canonical proof/normal hooks/clean tree.')):
    pattern = r'(## ' + re.escape(heading) + r'\n\n).*?(?=\n## |\Z)'
    buffers[live], count = re.subn(pattern, lambda match: match[1] + text + '\n', buffers[live], count=1, flags=re.S)
    assert count == 1
match = re.search(r'(## Recent Completions\n\n)(.*?)(?=\n## History)', buffers[live], re.S)
assert match
old_rows = [line for line in match[2].splitlines() if line.startswith('- ')]
assert len(old_rows) == 16
new_row = '- ' + OWNER + ' — selected old/current128 records/2896 controls/384 named native blind mutations; each normal128PASS/legacyRED1/rawGREEN0; source204/eight scoped consumers/readonly10; stop after clean commit, discovery/publication remain.'
buffers[live] = buffers[live][:match.start(2)] + '\n'.join([new_row] + old_rows[:15]) + '\n\n' + buffers[live][match.end(2):]
(OUT / 'retired-recent-rows.json').write_text(json.dumps(old_rows[15:], indent=2) + '\n')

tree = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
pattern = r'(^- ID: `' + re.escape(OWNER) + r'`\n.*?)(?=^- ID: |\Z)'
match = re.search(pattern, buffers[tree], re.M | re.S)
assert match
block = match[1].replace('Status: `active` / bounded native-error observation prerequisite for early publication',
    'Status: `completed` / focused selected-field proof; full discovery/admission separate')
block += '\n  Outcome: ' + summary + ' Evidence: ' + str(BASE / 'REVIEW.md') + '. All original used sources/sealed core/failed legacy controls remain unchanged; ten historical corruptions reject. Actual source-bound normal/oracle inputs and modes precede use. The new normal awaits4.1 explicit registration. Director stop is the clean next boundary; no new feature or discovery activation follows this commit.\n\n  Acceptance Checklist\n  - [x] **REPRODUCE / ISSUE** — Native raw changes can leave JSON/named flags equal; each host legacy oracle1 specifically misses expected_kind.\n  - [x] **ROOT CAUSE (WHY + WHERE)** — to_json is a projection; generated_source_execution_failed creates a separate envelope. Eight source-derived consumers split three published/five partial observers.\n  - [x] **FIX** — Add test-only full selected-field observation, per-host old-baseline fixtures and standalone normal; qualify historical scope without SDK/serializer changes.\n  - [x] **ADDRESSED (verified)** —128 old/current route records/2896 controls/384 named misses; each new normal128PASS/raw oracle0; independent eight/four controls and first historical0/ten controls.\n  - [x] **NO REGRESSION** — Old/current observations and each host recurring old baseline exact; old captures/hash/modes retained. Physical/native and preparation-origin gaps remain4.2/SESSION5; no unsafe full runner/declared5.4/all-error admission.\n  - [x] **LOCKSTEP** — Book/Knowledge/roadmaps/live/global task index/resume align; current discovery4.1 and before-push owners stay pending.\n  Commit: `' + OWNER + ' - cover selected Lua native error fields`.\n\n'
buffers[tree] = buffers[tree][:match.start(1)] + block + buffers[tree][match.end(1):]
buffers[tree] = buffers[tree].replace('- Last updated: `2026-11-12`', '- Last updated: `2026-11-13`', 1)
root_tree = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
buffers[root_tree] = buffers[root_tree].replace(
    '| 1 | `' + OWNER + '` | `active` | Pack1.415GB: bounded raw-field observation before final current discovery4.1 and early clean canonical publication. |',
    '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1` | `pending` | Director-requested stop after raw28; on resume remeasure, register current normals and prepare exact canonical early publication. |')
buffers[root_tree] = buffers[root_tree].replace(
    '| 3 | `TYPE-REFERENCE-BOOK.1.2.23.1.41` | `completed` | Original44/qualified45 and exact qualification retained; frozen78.6 with independent backend owners. |',
    '| 3 | `' + OWNER + '` | `completed` | Selected route-specific raw fields/normal128 per host/legacyRED1/rawGREEN0; historical scope qualified, full admission separate. |')
buffers[root_tree] = buffers[root_tree].replace(
    'resource14 shares validated RAM preflight and exact historical source/CI stages with focused/native/recovery proof; canonical receipt required; fresh size then raw-error4.28/final discovery4.1 before push;',
    'resource14 canonical e0 landed; raw28 selected-field companion is focused-checked with explicit original scopes; director stop after clean raw28, then on resume current size/discovery4.1 and canonical publication before new features;')
index = Path('docs/TASK_TREE.md')
rows = buffers[index].splitlines()
matches = [number for number, line in enumerate(rows) if line.startswith('| `TYPE-REFERENCE-BOOK` |')]
assert len(matches) == 1
parts = rows[matches[0]].split('|')
parts[4] = ' Raw28 selected Lua fields are focused-checked; director stop at the clean handoff. On resume remeasure current size, complete discovery4.1 and early canonical publication30.2; broader admission owners remain. '
rows[matches[0]] = '|'.join(parts)
buffers[index] = '\n'.join(rows) + '\n'

buffers[Path('MEMORY.md')] = f'''# MEMORY

- activation_commit: `{ACTIVATION}` — clean raw-error4.28 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — selected Lua error-field companion and historical observer scope.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: Stopped at the director-requested handoff-ready checkpoint; do not resume PNT without an explicit request.
- session_health: Long session; recover from this committed pointer and bounded current-discovery leaf before larger work.
- next_action: Await explicit resume, remeasure current HEAD with docs/checkpoints/publication-size-monitor-2026-11-12/measure.py, then current discovery4.1 including the new standalone raw-error normal and early publication30.2. Preparation due; no new feature lane and no before-push owner waived.
- in_flight_uncommitted: none; selected field evidence/tests/docs committed; no required background job.
- evidence: {BASE}/REVIEW.md; default review.py is readonly historical recovery. Old/current eight cases/four routes/two hosts yield128 matching records;2896 field controls include384 named native misses in the old observer. Each new normal128PASS, specific legacyRED1/rawGREEN0; first historical0/ten corruptions and source/field analysis0/eight+four controls.
- source_scope: Complete204 activation Lua-file inventory identifies eight explicit-function-grammar guard normals: three full published JSON plus named flags, five older partial named flags. Native/restored and generated envelopes differ. No all-error/table-identity/metatable/native closure or SDK/serializer change; old observations/hashes stay exact.
- custody: Direct inputs/actual parsed-emitted artifacts/opaque native products/modes precede selected SDK use. {BASE}/CUSTODY.md preserves preparation channel/late-image limits. Full physical/native/cache/toolchain/OS/source-resolution/origin gaps remain4.2/SESSION5; source-shadowing/isolation owners stay separate.
- canonical_boundary: Resource14 at e0a1bb475 has exact canonical0/all10/post-pointer/brief0/clean proof. Raw28 is focused; current discovery4.1 must register the new normal and produce a fresh exact receipt before push. Declared5.4/formatter/full23.4/source/context/historical/launcher/SESSION7/literal/excluded/shadowing owners are not closed.
- publication: Director1,500,000,000-byte trigger overrides cadence; advisory1,400,000,000. Actual e0/cached origin4683555e pack0 is1,415,327,104 bytes/108 ahead/47,344 objects/84,672,896 trigger margin, excluding28; preparation due. Metadata/source/channels retained in intake; raw pack ignored/protected. Current-independent30/native4.2 gaps remain. Remeasure after clean landing; no remote freshness/wire/future-size promise.
- locality: Same-volume serial jobs/shared24GiB/current90-percent rising-trend policy; only this repo writable, submodules black boxes. Cleanup2026-11-12T15:32:21.895461+00:00 remains current. No native PID/PGID inference from denied pgrep.
'''

with tarfile.open(BASE / 'publication-inputs/inputs-before-query.tar.gz') as archive:
    prior = json.loads(archive.extractfile('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.14.json').read())
operational = copy.deepcopy(prior['claims'][0])
operational['statement'] = 'At committed HEAD' + ACTIVATION + ' excluding cached origin/main4683555ec51f04b8977812ce4e984c5cc6e6f42c, the explicit no-sparse one-worker non-thin estimate is1415327104 bytes/108 outgoing commits/47344 objects. The1500000000-byte trigger has84672896 bytes remaining and preparation is due. All uncommitted raw28 work is excluded; no negotiated upload size is claimed.'
operational['scope'] = 'One actual e0 committed-range operational measurement; exact producer/policy/refs/config/metadata/channels are recovered from this checkpoint intake. Raw pack remains ignored, current artifact falsification30/native custody4.2 explicit.'
operational['rederive']['result'] = 'Actual monitor0 at e0a1bb47571b75b800546c3d4522e0d2ca5f778c/base4683555ec51f04b8977812ce4e984c5cc6e6f42c:1415327104 bytes/108 commits/47344 logical-header objects,84672896 trigger margin. Stream/stat/PACK/footer/empty32/source/config/ref guards0; preparation true/trigger false. Retained exact metadata/channels are in intake/inputs-before-use.tar.gz.'
operational['falsify']['reason'] = 'Prior native verification and twelve REDs at102ec3446 do not independently qualify this actual e0 raw pack. Parent30 owns actual-file falsification before publication; no old result is refreshed.'
claim = dict(name='selected-lua-error-fields-and-observer-scope', statement=summary,
    scope='Eight authored binding/fixed-minimum-arity cases on recorded PUC5.5.1/LuaJIT, four route-specific channels and old/current SDKs.204 activation Lua files/eight explicitly selected guard consumers; this is not all tests/errors/native state or fresh-process coverage. The new normal awaits4.1 registration.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'review.py'),
        granularity='Each retained selected raw field/value/absence, actual before-use input/body/mode, corresponding old/current record, consumer source and recurring/oracle channel.',
        result='Actual capture0/empty SDK stderr, independent analysis0 with eight evidence/four source corruptions, each-host normal128PASS/specific legacyRED1/rawGREEN0, first historical recovery0/ten effective controls.128 records/2896 field controls/384 named native blind changes; native/restored and generated envelopes remain distinct.'),
    falsify=dict(status='checked', hypothesis='Equal published JSON and selected flags already distinguish every selected raw native field change, or new coverage retroactively expands older observers.',
        oracle='Change/remove only native binding/function metadata while keeping public message/diagnostic equal; compare old projection with exact field snapshot. Independent source-derived schemas, complete selected Git membership and separate actual per-host old/current/recurring observations distinguish the alternatives.',
        red_control='oracles/puc/legacy/oracle-exit.txt and luajit counterpart are1 specifically on projection misses expected_kind; raw counterparts0 distinguish binding and function attribution. Actual2896 controls show384 named native omissions plus128 separate unknown-field additions. Eight analysis/four source/ten historical corruptions reject for their specified reasons.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Direct SDK/observer/normal/oracle source, actual parsed-emitted inputs, full channels and opaque native body/mode archives precede those loads. Complete physical/native/cache/interpreter/toolchain/OS and wider module-source closure are not proved. Source-only initial preparation outer channels and late query-preparer self image receive no original first-use credit; CUSTODY.md and4.2/SESSION5 own these named origin gaps.'))
record = Path('docs/claims') / (OWNER + '.json')
assert not record.exists()
buffers[record] = json.dumps(dict(version=1, owner=OWNER, claims=[operational, claim]), indent=2) + '\n'
for path, original in originals.items():
    assert path.read_text() == original, 'document changed during publication: ' + str(path)
for path, text in buffers.items():
    path.write_text(text)
freeze(list(buffers) + [OUT / 'retired-recent-rows.json'], 'outputs-after-use')
print(json.dumps(dict(publication='PASS', documents=len(buffers), new_claims=2, director_stop=True,
    next_on_resume='Fresh size/current discovery4.1/all before-push owners/early canonical publication30.2')))

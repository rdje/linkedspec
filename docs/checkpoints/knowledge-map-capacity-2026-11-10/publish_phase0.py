"""Publish bounded Phase0 source/channel proof with explicit native custody gap."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
PATH = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
before = PATH.read_bytes()
record = json.loads(before)
assert len(record['claims']) == 9
retained = HERE / 'implementation-pre-phase0-claim.json.gz'
assert not retained.exists()
retained.write_bytes(gzip.compress(before, mtime=0))
result_raw = (ROOT / '.linkedspec-data/phase0-final-review.stdout.log').read_bytes()
result = json.loads(result_raw)
assert result['result'] == 'PASS' and result['selected']['after']['assertions'] == 140
assert (ROOT / '.linkedspec-data/phase0-final-review.stderr.log').read_bytes() == b''
(HERE / 'phase0-final-review-result.json').write_bytes(result_raw)
names = ['tests/language-readiness/verify_objectives.py', 'tests/language-readiness/phase0-value-calibration.json.gz',
         't/phase0_regression.t', 'tools/historical_objective_images.py',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
local = ('phase0_review.py', 'phase0_value_capture.py', 'phase0_value_probe.pl',
         'phase0_oracle_cases.py', 'phase0-oracle-cases.json', 'phase0-before.t.gz',
         'phase0-values-qualified.json.gz', 'phase0_selected.pl', 'phase0-selected-names.json',
         'phase0-selected-channels.json', 'phase0-final-review-result.json',
         'calibrate_phase0_values.py', 'package_phase0.py', 'publish_phase0.py',
         'factory-boundary-after.json.gz', 'objective-current-recovery.stdout.log.gz',
         'objective-image-intake.json.gz', 'objective-frontier-intake.json.gz',
         'implementation-pre-phase0-claim.json.gz', 'phase0-oracle-cases.json.initial.gz',
         'phase0_oracle_cases.py.initial.gz')
names += [str((HERE / name).relative_to(ROOT)) for name in local]
channels = json.loads((HERE / 'phase0-selected-channels.json').read_bytes())
names += [item['path'] for row in channels['commands'].values() for item in row['channels'].values()]
# Current image/helper inputs and all frozen complete SDK members retain their
# existing physical bodies; the companion epoch bundle gates the earlier reader.
names += ['tests/language-readiness/' + name for name in
          ('current-source-images.json.gz', 'current-source-successors.json.gz',
           'additional-source-images.json.gz', 'phase0-fixture-calibration.json.gz')]
inputs = [dict(path=name, sha256=hashlib.sha256((ROOT / name).read_bytes()).hexdigest(),
               role='producer' if name.endswith(('.py', '.pl', '.sh', '.t')) else 'input') for name in sorted(set(names))]
source = dict(name='phase0-value-oracle-and-exact-historical-stage-repair',
    statement='Twenty failing source-layout assertions are replaced by independent finite value/effect oracles. The exact inverse preserves every healthy assertion, original plan/helper and prior Phase0 image stage. The retained original/current lowerings and finite values agree; all11 original fixture denials and19 image denials remain, plus12 new exact-stage denials.',
    scope='Source/diagnostic artifact interpretation for the exact seven groups from failed ninth canonical (1035 groups,7 failed). Twenty source assertions fail in current-only selected replay while120 remain healthy. Authored finite values precede activation/current observations. A title-placement error in the initial replacement template is corrected before any test edit; both initial template bodies remain. The entire prior nine-claim declaration,231 inline input bodies and nested unit source remain replayable in the companion frozen logical artifact epoch; no fictional Git capture/hash refresh. No runtime source changes follow from this calibration. Native execution is separately qualified below.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/phase0_review.py',
        granularity='All20 exact assertion replacements/inverse anchors, original source plans and helper; complete retained activation/current source/diagnostic records; every11 prior/12 new fixture denial and19 current image denial; both exact selected command channels.',
        result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Source nesting alone defines behavior, or fixture calibration permits unrelated drift and discarded historical stages/results.',
        oracle='Pre-authored finite operation values, preserved source aggregates, diagnostic sink and mutation snapshots; unchanged committed7289836f protected test plus every older exact image/calibration and original full command channels.',
        red_control='Original selected20 source assertions fail; actual activation/current finite values agree, while40 executed wrong-value/warning controls distinguish failures. Original11 fixture controls remain exact; new12 source/table/owner/path/revision/hash/hunk controls reject, all19 image mutations reject. Wrong-exit/missing-command channel controls reject; healthy inverse/recovery images and selected140 channels pass.'),
    durability=dict(status='checked', mode='live', inputs=inputs))
native = copy.deepcopy(source)
native.update(name='phase0-seven-selected-groups-with-native-custody-gap',
    statement='The seven selected Phase0 groups pass all140 nested assertions, with complete8-result TAP including shared discovery and empty stderr, after only20 assertion calibrations. Exact activation/current lowered values agree on all20 finite fixtures.',
    scope='Actual current-only selected exit7/20 failures of140 before and exit0/140 passing after. All seven names are seen exactly once, no selected skips/todos; the full1035-group ninth run remains failed and no canonical receipt is inferred. This is a finite diagnostic/test repair, not whole-feature admission or complete native input closure.')
native['rederive']['granularity'] = 'Each selected name/argv/exit/raw channel and all140 nested assertions; retained finite20 value/effect observations, rather than recreation of the original complete native epoch.'
native['durability'] = dict(status='gap', reason='Companion source claim retains complete project producer/input bodies and exact diagnostic channels. Shared Perl/native runtime, cache, OS/toolchain and transitive first-use closure are not acquired; post-exit packaging cannot supply that missing native leg.', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2')
record['claims'] += [source, native]
assert record['claims'][:9] == json.loads(before)['claims']
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 131072
PATH.write_bytes(raw)
print(json.dumps(dict(result='PASS', claims=len(record['claims']), bytes=len(raw), prior_claim_objects_preserved=9), sort_keys=True))

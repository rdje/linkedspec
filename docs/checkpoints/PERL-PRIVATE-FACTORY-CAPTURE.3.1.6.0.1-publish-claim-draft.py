"""Publish once, or reconstruct readonly, bounded legacy hash callback claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '770cffcccea44df8d0e578ed68ad6f9a4b5e0b0e'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-book-repair/publish-claim.py'
CARDS = {'docs/knowledge/perl-legacy-hash-kind-callback.md',
         'docs/knowledge/perl-match-alias-writability.md',
         'docs/knowledge/perl-scalar-bound-receiver-copy.md'}
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


for tail in ('review.py', 'evidence.py', 'compatibility/run.py'):
    checked = subprocess.run(['python3', PREFIX + tail], cwd=ROOT,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    assert checked.returncode == 0 and not checked.stderr, ('readonly proof', tail, checked.stderr)
runtime, evidence, freeze = [record(t) for t in ('review', 'evidence', 'freeze')]
expected = {'preserved_bindings': 546, 'native_cases': 35, 'native_controls': 23,
            'repair_cases': 12, 'assertions': 487, 'original_red': 48, 'original_controls': 439,
            'supplied_suites': 61, 'supplied_inputs': 187, 'supplied_assertions': 11664,
            'faults': 5, 'pure_perl_oracle_cases': 4, 'draft_assertions': 408,
            'draft_red': 33, 'book_sources': 89, 'book_controls': 3}
assert runtime['result'] == evidence['result'] == 'PASS'
assert all(runtime[key] == value for key, value in expected.items())
assert runtime['perl_version'] == 'v5.34.1' and len(evidence['controls']) == 6
paths = set(runtime['input_metadata']) | set(evidence['inputs']) | CARDS
for candidate in (ROOT / 'docs/checkpoints').glob(LEAF + '-*'):
    if candidate.is_file():
        paths.add(candidate.relative_to(ROOT).as_posix())
    elif candidate.is_dir():
        paths.update(p.relative_to(ROOT).as_posix() for p in candidate.rglob('*') if p.is_file())
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for path in sorted(paths)]
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
old = json.loads(before)
bindings = [entry for claim in old['claims'] if claim['durability'].get('mode') == 'live'
            for entry in claim['durability']['inputs']]
assert len(bindings) == 546 and freeze['verified_bindings'] == 546
historical = [
    {'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
    {'path': OLD_PRODUCER,
     'sha256': digest(subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)),
     'role': 'producer'},
]
statement = ('Legacy hash normalization selects its injected CODE kind callback once before trim; '
             'missing/non-CODE means unknown. First-native35 cases retain23 complete controls and12 '
             'intended repairs, plus two cold rows. Paired487 TAP has48 original semantic REDs/439 '
             'controls/all487 current GREEN. Actual callback/map identity, scalar context, match alias '
             'write rejection, effects/errors/fatal identity and separate opaque/known capture are preserved. '
             'Five syntax-valid source faults fail48/3/9/5/3 assertions. Supplied61 suites/187 inputs/11664 '
             'assertions, six evidence RED/restorations and full book89/three controls pass. '
             'The independent four-case Perl5.34.1 oracle distinguishes readonly flags0/1/0/0 '
             'from actual lexical/literal/match/copied-match writability.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'legacy-hash-kind-selection-and-capture', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; independently review.py and evidence.py under that wrapper. Defaults readonly; capture/freezer/correction writers are one-shot.',
                  'granularity': 'Every35 native/current row, two cold rows, all487 paired TAP names and exact48 original failures, all186 native/current and187 supplied inputs, five complete syntax-valid mutants, four independent Perl rows, six evidence interventions/restorations, both byte-exact correction replays and all89 book/include inputs/three controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Package state can substitute for the caller map, default to hash, select after trim, copy a match alias, or donate child publication; a clear readonly flag proves writability; altered observations or original bindings can be accepted.',
                 'oracle': 'Immutable first-native selected-callback controls and independent pure-Perl slot-identity/write attempts; exact before/current TAP names, actual publication probes and source reconstruction. All23 native controls stay exact. Full copies include actual changed artifacts and complete channels; both bounded instrument corrections replay byte-identically.',
                 'red_control': 'Original helper fails48 selection/default/authority assertions. Removing binding/raw callback/copied argument/hash default/late selection produces48/3/9/5/3 named failures in complete487 plans. Six artifact corruptions deny the actual semantic reason, positive exit, missing/extra diagnostic, false match flag and original binding before restored PASS. Missing SUMMARY fails; removed prose disappears from rendered HTML; omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-scalar-copy-boundary-preservation',
     'statement': 'All546 predecessor live input hashes and every original claim/proof field remain exact. Only its live durability mode/revision changes to historical at770cffcc; the older historical regex preservation remains exact.',
     'scope': 'Complete accepted scalar-copy claim at770cffcc, every546 original live binding and actual composed publisher. Original runtime/CI/book observations are not refreshed and replay requires the accepted Git inputs.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately evidence.py under that wrapper.',
                  'granularity': 'Complete original Git claim, all546 Git-bound hashes and exact before/after JSON with one permitted mode/revision conversion.',
                  'result': 'All546 accepted identities and original fields preserved; actual first-binding corruption rejects and original bytes restore to PASS.'},
     'falsify': {'status': 'checked',
                 'hypothesis': 'A historical label can conceal refreshed or corrupted original proof/input identities.',
                 'oracle': 'Accepted Git blobs plus retained before-copy, one-shot freezer and current reviewer exact mode/revision-only comparison.',
                 'red_control': 'An all-zero first original SHA fails with frozen original claim fields; exact original bytes restore before actual PASS.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}},
]}
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'legacy hash publication drift'
print('Legacy hash kind publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original546 preserved; supplemental public Phase0 1035')

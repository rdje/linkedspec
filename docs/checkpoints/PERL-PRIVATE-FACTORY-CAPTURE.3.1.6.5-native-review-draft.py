"""Readonly review of preserved native observations and the diagnostic-only correction."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '557a7d9e533710c6aae211f905ca2f231a8aedae'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
PROBE = 't/actionir_hash_index_required_probe.pl'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
channel = lambda row, name: base64.b64decode(row[name + '_base64'], validate=True)
read = lambda tail: (ROOT / (PREFIX + tail)).read_bytes()
assert sys.argv[1:] in ([], ['--capture'])
native_raw = read('native.json')
native = json.loads(native_raw)
correction_raw = read('native-correction.json')
correction = json.loads(correction_raw)
draft = read('native-draft-probe.pl')
corrected = (ROOT / PROBE).read_bytes()
assert native['returncode'] == correction['returncode'] == 0
assert native['unchanged'] and correction['unchanged']
assert channel(native, 'stderr') == b'Scalar value @_[0] better written as $_[0] at ./t/actionir_hash_index_required_probe.pl line 107.\n'
assert not channel(correction, 'stderr')
assert sha(draft) == native['inputs'][PROBE] == correction['original_probe_sha256']
assert draft.count(b'map {encoded($_)} @_[0]') == 1
assert corrected == draft.replace(b'map {encoded($_)} @_[0]', b'encoded($_[0])'), 'sole diagnostic spelling change'
assert correction['original_capture_sha256'] == sha(native_raw)
assert correction['corrected_probe_sha256'] == sha(corrected)
assert correction['producer_sha256'] == sha(read('native-correction.py'))
assert native['producer_sha256'] == sha(read('capture.py'))
assert correction['command'] == native['command'] == ['perl', '-Iperl', './' + PROBE, 'observe']
seed = json.loads(subprocess.check_output(['git', 'show', BASE + ':' + native['seed']], cwd=ROOT))
expected = dict(seed['inputs'])
for path in (PROBE, 't/actionir_hash_index_required_cold_probe.pl'):
    expected[path] = sha(draft if path == PROBE else (ROOT / path).read_bytes())
assert native['inputs'] == expected and len(expected) == 205
assert correction['inputs'] == dict(expected, **{PROBE: sha(corrected)})
for path, digest in expected.items():
    data = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT) if path == MODULE else draft if path == PROBE else (ROOT / path).read_bytes()
    assert sha(data) == digest, 'complete original native input'
original = json.loads(channel(native, 'stdout'))
current = json.loads(channel(correction, 'stdout'))
assert [len(original[k]) for k in ('callbacks', 'branches', 'authority', 'public')] == [12, 96, 6, 3]
assert len({r['name'] for r in original['branches']}) == 96


def normalized(observations):
    value = copy.deepcopy(observations)
    locations = []
    addresses = []
    for row in value['branches']:
        if row['name'].split('-', 1)[1].startswith(('missing-', 'noncode-')):
            error = row['error']
            match = re.fullmatch(r"(\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '[^']+' at )[^\n]+?(/perl/LinkedSpec/ActionIR/MethodLowering\.pm line (7974|8064), <GEN0> line 1\.\n)", error)
            assert match, 'exact native diagnostic stem/location'
            row['error'] = match[1] + match[2][1:]
            locations.append(row['name'])
        if row['name'] in ('lowerer-key_result-reference', 'lowerer-payload_result-reference'):
            pattern = (r'SET\(meta,HASH\(0x[0-9a-f]+\),VALUE\(value\)\)'
                       if row['name'] == 'lowerer-key_result-reference'
                       else r'SET\(meta,KEY\(key\),HASH\(0x[0-9a-f]+\)\)')
            assert re.fullmatch(pattern, row['value']), 'exact native reference representation'
            row['value'] = re.sub(r'0x[0-9a-f]+', '<actual-address>', row['value'])
            addresses.append(row['name'])
    assert len(locations) == 10 and len(addresses) == 2
    return value, locations, addresses


left, locations, addresses = normalized(original)
right, current_locations, current_addresses = normalized(current)
assert locations == current_locations and addresses == current_addresses
assert left == right, 'complete original native observations beyond exact host representations'
assert channel(native, 'stdout') != channel(correction, 'stdout'), 'original failed byte-equality boundary remains explicit'
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'original_capture_sha256': sha(native_raw), 'corrected_capture_sha256': sha(correction_raw),
          'inputs': expected, 'locations': locations, 'reference_representations': addresses,
          'scope': 'Original native capture and failed byte-equality producer/result remain exact. Sole scalar spelling correction removes one warning. Only ten exact diagnostic temporary prefixes and two actual HASH address strings normalize; every other native observation, stem/line, alias/context/map/result/error/identity and full channel stays retained. No original capture is refreshed; corrected runtime precedes assertions and production edits.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Hash-index native review PASS: first205 inputs/12 callbacks/96 branches/6 authority/3 public/4 cold; exact diagnostic correction, ten paths/two addresses only')

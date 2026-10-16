"""Retain the first reader rejection and reproduce its historical-claim overlay cause."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/'
BASE = 'a4a9e5c503460a8bd7db06e57b827dd053724d00'
TARGET = ROOT / (PREFIX + 'first-review-failure.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists()
preservation = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
owned = set(preservation['owned_bound_paths'])
changed = {}
for entry in preservation['selected']:
    original = json.loads((ROOT / entry['before']).read_bytes())
    for claim in original['claims']:
        for item in claim['durability']['inputs']:
            if item['path'] not in owned:
                actual = (ROOT / item['path']).read_bytes()
                if sha(actual) != item['sha256']:
                    changed[item['path']] = {'original_sha256': item['sha256'], 'current_sha256': sha(actual)}
callback = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json'
assert set(changed) == {callback}
original = json.loads((ROOT / (PREFIX + 'before-PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json')).read_bytes())
expected = copy.deepcopy(original)
expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
assert json.loads((ROOT / callback).read_bytes()) == expected
command = ['python3', PREFIX + 'review.py', '--preflight']
p = subprocess.run(command, cwd=ROOT, capture_output=True)
r = {'producer_sha256': sha(Path(__file__).read_bytes()),
     'original_reader_sha256': sha((ROOT / (PREFIX + 'review.py')).read_bytes()),
     'first_outer_session': 53072, 'first_outer_returncode': 1,
     'changed_unowned_inputs': changed, 'only_historical_mode_revision': True,
     'replay': {'command': command, 'returncode': p.returncode,
                'stdout_base64': base64.b64encode(p.stdout).decode(),
                'stderr_base64': base64.b64encode(p.stderr).decode()},
     'scope': 'The first tool-reported reader rejection was unchanged unowned predecessor input at line91; '
              'its original separate streams are unavailable. This distinct readonly replay retains fresh '
              'complete separate channels and reproduces that cause. The only such changed input is the '
              'callback claim bound by the historical hygiene publication; only its durability mode/revision '
              'changed, and both whole original records/all478 bindings remain recoverable at accepted Git. '
              'No original reader, producer, runtime observation, fixture, source fault or result is refreshed.'}
with TARGET.open('x') as output:
    output.write(json.dumps(r, indent=2) + '\n')
assert p.returncode == 1 and b'AssertionError: unchanged unowned predecessor input' in p.stderr
print('First reader cause retained: historical callback claim overlay; exact mode/revision-only change; actual readonly RED')

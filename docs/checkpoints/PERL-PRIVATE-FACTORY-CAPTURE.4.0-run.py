"""One-shot per-stage complete paired TAP and source/input custody."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '81b356cef997ea2bb65a8fb120c77506fed9241e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
MODULE = 'perl/LinkedSpec/ActionIR/FlowExpr.pm'
FIXTURE = 't/actionir_flow_required_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in (['before'], ['after'])
stage = sys.argv[1]
target = ROOT / (PREFIX + stage + '.json')
assert not target.exists(), 'one-shot stage'
native_capsule = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
if stage == 'before':
    assert (ROOT / MODULE).read_bytes() == subprocess.check_output(
        ['git', 'show', BASE + ':' + MODULE], cwd=ROOT), 'original accepted production'
else:
    before = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
    assert before['stage'] == 'before' and before['result'] == 'RED'
for path, item in native_capsule.items():
    if stage == 'after' and path == MODULE:
        continue
    assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged original native input', path)

first_log = ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.4.0-first-red.log'
first = {'command': 'bash tools/project_data_run.sh env PERL5LIB= prove -Iperl ' + FIXTURE,
         'actual_outer_session': 55712, 'actual_outer_returncode': 1,
         'merged_log_base64': base64.b64encode(first_log.read_bytes()).decode(),
         'scope': 'Initial normal prove command, unchanged fixture/production. The wrapper suppresses passing TAP; separate outer channels were not captured. Full raw paired TAP is captured below without changing fixture, oracle or observations.'}
first_path = ROOT / (PREFIX + 'first-red.json.gz')
if stage == 'before':
    with first_path.open('xb') as output:
        output.write(gzip.compress(json.dumps(first, sort_keys=True).encode(), mtime=0))
else:
    assert json.loads(gzip.decompress(first_path.read_bytes())) == first

paths = set(native_capsule)
paths.update((FIXTURE, PREFIX + 'run.py', PREFIX + 'before-native.json',
              PREFIX + 'before-native-data.json.gz', PREFIX + 'before-native-inputs.json.gz',
              PREFIX + 'first-red.json.gz'))
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    raw = source.read_bytes()
    capsule[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}
environment = dict(os.environ, PERL5LIB='')
observations = []
for command in (['perl', '-c', '-Iperl', FIXTURE], ['perl', '-Iperl', FIXTURE]):
    process = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
    observations.append({'command': command, 'returncode': process.returncode,
                         'stdout_base64': base64.b64encode(process.stdout).decode(),
                         'stderr_base64': base64.b64encode(process.stderr).decode()})
capsule_path = ROOT / (PREFIX + stage + '-inputs.json.gz')
channels_path = ROOT / (PREFIX + stage + '-channels.json.gz')
for path, value in ((capsule_path, capsule), (channels_path, observations)):
    with path.open('xb') as output:
        output.write(gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
stdout = base64.b64decode(observations[1]['stdout_base64']).decode()
stderr = base64.b64decode(observations[1]['stderr_base64']).decode()
matches = re.findall(r'^(not )?ok (\d+) - (.*)$', stdout, re.M)
plans = re.findall(r'^1\.\.(\d+)$', stdout, re.M)
failed = [{'number': int(number), 'name': name} for not_ok, number, name in matches if not_ok]
result = {'stage': stage, 'result': 'RED' if stage == 'before' else 'GREEN',
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'inputs': {path: {'sha256': item['sha256'], 'mode': item['mode']} for path, item in capsule.items()},
          'capsule_sha256': sha(capsule_path.read_bytes()),
          'channels_sha256': sha(channels_path.read_bytes()),
          'commands': [{'command': item['command'], 'returncode': item['returncode']} for item in observations],
          'plan': int(plans[0]) if len(plans) == 1 else None,
          'assertions': len(matches), 'failures': failed,
          'controls': len(matches) - len(failed),
          'scope': 'Identical source-bound paired fixture; every native row/context/argument/map/value/effect/error and independent actual-callback/publication property is checked. Full coherent TAP and separate raw channels are retained. Initial prove observation remains separate and exact; no runtime/native oracle is refreshed.'}
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
assert observations[0]['returncode'] == 0
assert base64.b64decode(observations[0]['stderr_base64']) == (FIXTURE + ' syntax OK\n').encode()
assert not base64.b64decode(observations[0]['stdout_base64'])
assert len(plans) == 1 and int(plans[0]) == len(matches)
assert [int(number) for _, number, _ in matches] == list(range(1, len(matches) + 1))
assert not re.search(r'^Bail out!|^Dubious', stdout, re.M)
if stage == 'before':
    assert observations[1]['returncode'] != 0 and failed, 'actual distinguishing RED'
    families = (
        'captures each actual callback independently with only its own registration',
        'cannot lend a dependency publication to its enclosing callback',
        "retains only an actually registered matching child's own packet",
    )
    assert all(any(item['name'].endswith(tail) for tail in families) for item in failed)
    first_failed = re.findall(r"^#   Failed test '(.*)'$", first_log.read_text(), re.M)
    assert first_failed == [item['name'] for item in failed], 'same exact first prove RED names/order'
else:
    assert observations[1]['returncode'] == 0 and not failed and not stderr
for path, item in capsule.items():
    assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged executed input', path)
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
print('FlowExpr paired', result['result'] + ':', result['assertions'], 'complete assertions;',
      len(failed), 'failures;', result['controls'], 'controls;', len(paths), 'supplied inputs')

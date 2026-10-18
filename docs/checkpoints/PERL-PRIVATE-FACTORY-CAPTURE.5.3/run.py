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

ROOT = Path(__file__).resolve().parents[3]
BASE = '09000223f2dac822b2c0d75c69dce587f2b5b2c0'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
FIXTURE = 't/actionir_control_switch_capture.t'
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


paths = set(native_capsule)
paths.update((FIXTURE, PREFIX + 'run.py', PREFIX + 'before-native.json',
              PREFIX + 'before-native-data.json.gz', PREFIX + 'before-native-inputs.json.gz'))
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    raw = source.read_bytes()
    capsule[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
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
          'scope': 'Identical source-bound paired fixture; every complete native row/context/argument/slot/returned reference/map/value/effect/error and independent parser/normalizer callback/publication property is checked. These ordinary reference-valued roles do not retain scalar packets; The original333/297 native population stays frozen. Full coherent TAP and separate raw channels are retained. The first complete paired RED is retained directly; no runtime/native oracle is refreshed.'}
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
        'uses actual scalar callback frames with own registration',
        'cannot lend a dependency publication to its enclosing callback',
        'leaves reference-valued dependencies without an ordinary scalar packet',
    )
    assert all(any(item['name'].endswith(tail) for tail in families) for item in failed)

else:
    assert observations[1]['returncode'] == 0 and not failed and not stderr
for path, item in capsule.items():
    assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged executed input', path)
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
print('ControlFlow switch paired', result['result'] + ':', result['assertions'], 'complete assertions;',
      len(failed), 'failures;', result['controls'], 'controls;', len(paths), 'supplied inputs')

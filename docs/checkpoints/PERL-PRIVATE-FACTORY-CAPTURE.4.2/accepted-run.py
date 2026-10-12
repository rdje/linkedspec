"""One-shot per-stage complete paired TAP and source/input custody."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import sys
import stat
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '708c1afa04bb10aeacbdaf0a8133a95f380df434'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
MODULE = 'perl/LinkedSpec/ActionIR/FlowExpr.pm'
FIXTURE = 't/actionir_flow_kind_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] == ['after']
stage = sys.argv[1]
target = ROOT / (PREFIX + 'accepted-after.json')
assert not target.exists(), 'one-shot stage'
native_capsule = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
if stage == 'after':
    before = json.loads((ROOT / (PREFIX + 'final-before.json')).read_bytes())
    assert before['stage'] == 'before' and before['result'] == 'RED'
original = subprocess.check_output(['git', 'show', BASE + ':' + MODULE], cwd=ROOT)
assert sha(original) == native_capsule[MODULE]['sha256'], 'original accepted source'
for path, item in native_capsule.items():
    if path == MODULE:
        continue
    assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged original native input', path)

paths = set(native_capsule)
paths.update((FIXTURE, PREFIX + 'accepted-run.py', PREFIX + 'before-native.json',
              PREFIX + 'before-native-data.json.gz', PREFIX + 'before-native-inputs.json.gz'))
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    raw = original if stage == 'before' and path == MODULE else source.read_bytes()
    capsule[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}
environment = dict(os.environ, PERL5LIB='')
observations = []
with tempfile.TemporaryDirectory(prefix='flow-kind-paired-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, item in capsule.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(base64.b64decode(item['bytes_base64']))
        destination.chmod(item['mode'])
    for command in (['perl', '-c', '-Iperl', FIXTURE], ['perl', '-Iperl', FIXTURE]):
        process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
        observations.append({'command': command, 'returncode': process.returncode,
                             'stdout_base64': base64.b64encode(process.stdout).decode(),
                             'stderr_base64': base64.b64encode(process.stderr).decode()})
    actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
              for path in supplied.rglob('*') if path.is_file()}
    assert actual == {path: item['sha256'] for path, item in capsule.items()}
    assert all(stat.S_IMODE((supplied / path).stat().st_mode) == item['mode']
               for path, item in capsule.items())
capsule_path = ROOT / (PREFIX + 'accepted-after-inputs.json.gz')
channels_path = ROOT / (PREFIX + 'accepted-after-channels.json.gz')
for path, value in ((capsule_path, capsule), (channels_path, observations)):
    with path.open('xb') as output:
        output.write(gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
stdout = base64.b64decode(observations[1]['stdout_base64']).decode()
stderr = base64.b64decode(observations[1]['stderr_base64']).decode()
matches = re.findall(r'^(not )?ok (\d+) - (.*)$', stdout, re.M)
plans = re.findall(r'^1\.\.(\d+)$', stdout, re.M)
failed = [{'number': int(number), 'name': name} for not_ok, number, name in matches if not_ok]
result = {'stage': stage, 'result': 'RED' if failed else 'GREEN',
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'inputs': {path: {'sha256': item['sha256'], 'mode': item['mode']} for path, item in capsule.items()},
          'capsule_sha256': sha(capsule_path.read_bytes()),
          'channels_sha256': sha(channels_path.read_bytes()),
          'commands': [{'command': item['command'], 'returncode': item['returncode']} for item in observations],
          'plan': int(plans[0]) if len(plans) == 1 else None,
          'assertions': len(matches), 'failures': failed,
          'controls': len(matches) - len(failed),
          'scope': 'Identical final source-bound paired fixture in complete project-volume supplied roots; only Unicode test-name display differs from the original fixture. Original accepted source is supplied for before, current source for after; every native row/context/argument/map/value/effect/error and independent actual-callback/publication property is checked. Full coherent TAP and separate raw channels are retained. The first complete raw TAP is the original RED; no runtime/native oracle is refreshed.'}
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
else:
    assert observations[1]['returncode'] == 0 and not failed and not stderr
for path, item in capsule.items():
    if stage == 'before' and path == MODULE:
        continue
    assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged executed input', path)
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
print('Accepted optional FlowExpr paired', result['result'] + ':', result['assertions'], 'complete assertions;',
      len(failed), 'failures;', result['controls'], 'controls;', len(paths), 'supplied inputs')

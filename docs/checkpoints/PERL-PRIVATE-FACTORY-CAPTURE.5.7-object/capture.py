"""Capture native-builder/object effects before and after the target-guard repair."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
INSTRUMENT = 't/actionir_default_object_native.pl'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in (['before'], ['after'])
stage = sys.argv[1]
target = ROOT / (PREFIX + stage + '.json')
assert not target.exists(), 'one-shot stage'
paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines())
paths.update((INSTRUMENT, PREFIX + 'capture.py', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh'))
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    value = source.read_bytes()
    capsule[path] = dict(sha256=sha(value), mode=source.stat().st_mode & 0o7777, bytes_base64=encode(value))
environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
commands = [['perl', '-c', '-Iperl', INSTRUMENT]] + [
    ['perl', '-Iperl', INSTRUMENT] + extra for extra in ([], [], ['cold'], ['cold'])]
rows = []
for command in commands:
    result = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
    row = dict(command=command, returncode=result.returncode,
        stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))
    if '-c' not in command:
        row['observation'] = json.loads(result.stdout)
    rows.append(row)
for name, value in (('inputs', capsule), ('data', rows)):
    with (ROOT / (PREFIX + stage + '-' + name + '.json.gz')).open('xb') as output:
        output.write(gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
differences = []
for index in (1, 3):
    observed = rows[index]['observation']
    grouped = {}
    for row in observed['rows']:
        key = (row['owner'], row['variant'], row['context'])
        grouped.setdefault(key, {})[row['stage']] = row
    for key, pair in grouped.items():
        left, right = pair['native-builder']['ordinary'], pair['current-factory']['ordinary']
        changed = sorted(k for k in left if left[k] != right[k])
        if changed:
            differences.append(dict(mode=observed['mode'], owner=key[0], variant=key[1], context=key[2], changed=changed))
report = dict(stage=stage, producer_sha256=sha(Path(__file__).read_bytes()),
    instrument_sha256=sha((ROOT / INSTRUMENT).read_bytes()),
    inputs={p: {k: x[k] for k in ('sha256', 'mode')} for p, x in capsule.items()},
    capsule_sha256=sha((ROOT / (PREFIX + stage + '-inputs.json.gz')).read_bytes()),
    data_sha256=sha((ROOT / (PREFIX + stage + '-data.json.gz')).read_bytes()),
    ordinary_differences=differences,
    scope='Actual default factories versus the published OwnerDispatch builder with each owner\'s captured actual dependency specification and existing construction context. MethodLowering builds scalar under every owner context; FlowExpr/ControlFlow forward. This is a native pre-selection builder oracle, not a claimed full historical factory replay. All three actual factories receive package objects with native inherited callback definitions and controlled string/equality/fatal/error effects. Complete sources/modes/raw channels/recurrences are retained; private selection is separate from ordinary behavior.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert all(r['returncode'] == 0 for r in rows)
assert not decode(rows[0]['stdout_base64']) and decode(rows[0]['stderr_base64']) == (INSTRUMENT + ' syntax OK\n').encode()
assert rows[1] == rows[2] and rows[3] == rows[4], 'exact fresh-process recurrences'
for index in (1, 3):
    observed = rows[index]['observation']
    assert not decode(rows[index]['stderr_base64'])
    assert len(observed['rows']) == 108
    assert set(observed['loaded_project_modules']) <= paths
    assert observed['source_emissions_loaded'] == (1 if index == 1 else 0) and observed['trace_loaded'] == 0
assert bool(differences) == (stage == 'before')
assert all(sha((ROOT / p).read_bytes()) == x['sha256'] for p, x in capsule.items())
print('Default package-object capture', stage + ':', len(differences), 'ordinary differing rows;108 warm/108 cold rows with exact recurrences')

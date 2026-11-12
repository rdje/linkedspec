"""Acquire four canonical-two bad-signature controls through the exact original owner."""
import copy
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'signature_oracle'
OUT.mkdir()
assert not (BASE / 'signature_oracle_observer.pl').exists()
cases = json.loads((BASE / 'cases.json').read_bytes())
keys = ['own80_signature_' + signature + '_free_' + tail for signature in ('fixed_missing', 'rest_missing') for tail in ('terminal', 'composed')]
selected = []
fragment = ',{order=cat(order,"U");["end"]}'
for key in keys:
    row = copy.deepcopy(next(case for case in cases if case['id'] == key))
    assert row['body'].count(fragment) == row['source'].count(fragment) == 1
    row['id'] = 'oracle_' + key
    row['body'] = row['body'].replace(fragment, '')
    row['source'] = row['source'].replace(fragment, '')
    selected.append(row)
(OUT / 'cases.json').write_text(json.dumps(selected, indent=2) + '\n')
owner = OUT / 'MethodLowering.pm'
body = subprocess.check_output(['git', 'show', 'b15ca562e8044d9a8a369e613926bf016598f708:perl/LinkedSpec/ActionIR/MethodLowering.pm'])
assert gzip.decompress((BASE / 'owner-before.pm.gz').read_bytes()) == body
owner.write_bytes(body)
owner.chmod(Path('perl/LinkedSpec/ActionIR/MethodLowering.pm').stat().st_mode & 0o777)
observer = BASE / 'signature_oracle_observer.pl'
source = (BASE / 'observer.pl').read_text()
old = "'" + str(BASE / 'cases.json') + "'"
assert source.count(old) == 1
observer.write_text(source.replace(old, "'" + str(OUT / 'cases.json') + "'"))
runner = BASE / 'signature_oracle_runner.pl'
assert runner.is_file()
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [owner, observer, runner, OUT / 'cases.json', BASE / 'signature_oracle.py', BASE / 'owner-before.pm.gz',
    Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh')]
identities = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        identities[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        row = identities[member.name]; raw = archive.extractfile(member).read()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(runner), str(owner), str(observer), str(OUT / 'cases.json'), str(OUT)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr.startswith(b'SIGNATURE_ORACLE_OWNER ')
assert len(result.stderr.decode().splitlines()) == 1
loaded = json.loads(result.stderr.decode().split(' ', 1)[1])
assert loaded['path'] == str(owner) and loaded['sha256'] == identities[str(owner)]['sha256']
records = {}
for line in result.stdout.decode().splitlines():
    if line.startswith('ARRAY_CONCAT_PERL '):
        _, key, raw = line.split(' ', 2)
        assert key not in records
        records[key] = json.loads(raw)
assert list(records) == [row['id'] for row in selected]
for case in selected:
    row = records[case['id']]
    helper = 'pair' if case['signature'] == 'fixed_missing' else 'keep'
    assert row['metadata'] == dict(language_agnostic_action_ir_ready=0, raw_perl_dependency_count=0,
        canonical_action_ir_fallback_count=0, unresolved_helper_count=1, unresolved_helpers=[helper])
    expected = [['tail'], 'T'] if case['tail'] == 'terminal' else [None, 'T']
    assert row['native'] == row['fresh'] == expected and row['native_error'] is row['fresh_error'] is None and not row['warnings']
for name, row in identities.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256'] and Path(name).stat().st_mode & 0o777 == row['mode']
assert len(list(OUT.glob('*.pm.gz'))) == len(list(OUT.glob('*.handler.pl.gz'))) == 4
(OUT / 'result.json').write_text(json.dumps(dict(programs=4, original_loaded_owner=loaded,
    canonical_two_rejected_signature_oracle='PASS', observed=records,
    scope='Exact original owner already preserves bad-function unresolved markers/T in canonical-two compositions. This is rejected-request compatibility, not admitted functions or new input authority. Original after2 stays retained; no original SDK epoch is replayed.'), indent=2, sort_keys=True) + '\n')
owner.unlink()
(OUT / 'complete.txt').write_text('Four exact-original-owner canonical-two rejected-request controls verified; archived overlay retired.\n')
print('Original canonical-two bad-signature controls4PASS: unready pair/keep, producer T retained, rejected tail skipped')

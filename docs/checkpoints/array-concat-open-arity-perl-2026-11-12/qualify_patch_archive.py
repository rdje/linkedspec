"""Preserve the exact raw unified diff through archive/use/retire; never replay SDK."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'patch_archive'
OUT.mkdir()
original = BASE / 'source-and-profile.diff'
raw = original.read_bytes()
mode = original.stat().st_mode & 0o777
assert raw.splitlines()[5] == b' '
archived = OUT / 'source-and-profile.diff.gz'
archived.write_bytes(gzip.compress(raw, mtime=0))
archived.chmod(mode)
assert gzip.decompress(archived.read_bytes()) == raw and archived.stat().st_mode & 0o777 == mode
(OUT / 'identity.json').write_text(json.dumps(dict(original=str(original), archive=str(archived),
    bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=mode), indent=2) + '\n')
(OUT / 'original-staging-failure.json').write_text(json.dumps(dict(
    source='Recovered exec_command session82450 combined staging/check result; not a fabricated new execution',
    failed_command=['git', 'diff', '--cached', '--check'], actual_exit=2,
    combined_output='docs/checkpoints/array-concat-open-arity-perl-2026-11-12/source-and-profile.diff:6: trailing whitespace.\n+ \n',
    cause='The required single-space blank context line in a retained unified diff triggers Git whitespace checking. Production source has no whitespace defect.',
    remedy='Preserve exact original bytes/mode as gzip, qualify only its physical reader location, verify actual use, then retire the plain duplicate.'), indent=2) + '\n')

reader = (BASE / 'review.py').read_text()
anchor = 'def read(name):\n'
assert reader.count(anchor) == 1
branch = '''    if name == str(BASE / 'source-and-profile.diff'):
        row = json.loads((ROOT / BASE / 'patch_archive/identity.json').read_bytes())
        target = ROOT / BASE / 'patch_archive/source-and-profile.diff.gz'
        assert target.is_file() and not target.is_symlink()
        body = gzip.decompress(target.read_bytes())
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert target.stat().st_mode & 0o777 == row['mode']
        return body
'''
reader = reader.replace(anchor, anchor + branch)
anchor = 'def main():\n'
assert reader.count(anchor) == 1
closure = '''    qualification_rows = json.loads(read(str(BASE / 'patch_archive/input-identities.json')))
    qualification_inputs = unpack_rows(BASE / 'patch_archive/inputs-before-reader.tar.gz', qualification_rows)
    for name, body in qualification_inputs.items():
        equal(read(name), body)
        if name != str(BASE / 'source-and-profile.diff'):
            assert (ROOT / name).stat().st_mode & 0o777 == qualification_rows[name]['mode']
'''
reader = reader.replace(anchor, anchor + closure)
qualified = BASE / 'review_qualified.py'
assert not qualified.exists()
compile(reader, str(qualified), 'exec')
qualified.write_text(reader)

current = (BASE / 'check_current.py').read_text()
assert current.count('import hashlib\n') == current.count('    path = Path(name)\n') == current.count('    body = path.read_bytes()\n') == 1
current = current.replace('import hashlib\n', 'import gzip\nimport hashlib\n')
current = current.replace('    path = Path(name)\n', "    path = BASE / 'patch_archive/source-and-profile.diff.gz' if name == str(BASE / 'source-and-profile.diff') else Path(name)\n")
current = current.replace('    body = path.read_bytes()\n', "    body = path.read_bytes()\n    if name == str(BASE / 'source-and-profile.diff'):\n        body = gzip.decompress(body)\n")
qualified_current = BASE / 'check_current_qualified.py'
assert not qualified_current.exists()
compile(current, str(qualified_current), 'exec')
qualified_current.write_text(current)
capture = (BASE / 'capture_current.py').read_text()
assert capture.count("OUT = BASE / 'current'") == 1 and capture.count('check_current.py') == 2
capture = capture.replace("OUT = BASE / 'current'", "OUT = BASE / 'current_qualified'").replace('check_current.py', 'check_current_qualified.py')
target = BASE / 'capture_current_qualified.py'
assert not target.exists()
target.write_text(capture)

paths = [original, archived, OUT / 'identity.json', BASE / 'qualify_patch_archive.py', qualified,
    qualified_current, target, BASE / 'review.py', BASE / 'check_current.py', BASE / 'capture_current.py',
    Path('tools/project_data_env.sh'), Path('tools/project_data_run.sh')]
rows = {}
with tarfile.open(OUT / 'inputs-before-reader.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'inputs-before-reader.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        body = archive.extractfile(member).read(); row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(qualified)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b''
first = gzip.decompress((BASE / 'launches/readonly/stdout.log.gz').read_bytes())
assert json.dumps(json.loads(first), sort_keys=True) == json.dumps(json.loads(result.stdout), sort_keys=True)
for name, row in rows.items():
    body = Path(name).read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and Path(name).stat().st_mode & 0o777 == row['mode']
assert original.read_bytes() == raw and gzip.decompress(archived.read_bytes()) == raw
original.unlink()
assert not original.exists() and not list(BASE.glob('source-and-profile.diff'))
(OUT / 'complete.txt').write_text('Exact archived patch used by qualified reader0/25 controls before plain-duplicate retirement; residue absent.\n')
print('Exact patch archive/qualified historical reader0 verified before plain retirement; original first reader0/source/seal remain')

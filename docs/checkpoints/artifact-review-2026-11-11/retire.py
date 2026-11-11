"""Archive four completed, owned combined logs; verify actual use before unlinking."""
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.26'
LOGS = {
    'callable-pipeline-dart-commit-qualified.log': 'c97b864fe9e9de16eaff5bcc840e46e97afe1699',
    'task-headroom-rust-commit.log': '580fe233a7d0299d177ecbd442ad8ba027bbe6da',
    'callable-pipeline-julia-commit.log': '9a6b229ce3f944ef3822e71935b1c40c109f74b9',
    'callable-pipeline-lua-commit.log': 'e5f2cb78ab99192974178ea04177b6cabf283e1e',
}


def identity(path):
    info = path.lstat()
    assert stat.S_ISREG(info.st_mode) and info.st_dev == ROOT.stat().st_dev
    assert info.st_nlink == 1 and not info.st_mode & 0o111, 'plain single-link log only'
    return dict(device=info.st_dev, inode=info.st_ino, bytes=info.st_size,
        mode=info.st_mode & 0o777, mtime_ns=info.st_mtime_ns, links=info.st_nlink)


assert not (HERE / 'archive-manifest.json').exists(), 'one-shot archival'
root_info = (ROOT / '.linkedspec-data').lstat()
assert stat.S_ISDIR(root_info.st_mode) and root_info.st_dev == ROOT.stat().st_dev
tracked_raw = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT)
tracked = set(tracked_raw.decode().split('\0'))
(HERE / 'tracked-before.gz').write_bytes(gzip.compress(tracked_raw, mtime=0))
reference_command = ['git', 'grep', '-n', '-F']
for name in LOGS:
    reference_command += ['-e', name]
reference_command += ['--', 'docs/claims', 'docs/checkpoints', 'docs/knowledge']
(HERE / 'references-command.json').write_text(json.dumps(dict(argv=reference_command, cwd='.'), indent=2) + '\n')
references = subprocess.run(reference_command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (HERE / ('references-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(references, channel), mtime=0))
(HERE / 'references-exit.txt').write_text(str(references.returncode) + '\n')
assert references.returncode == 1 and references.stdout == references.stderr == b'', 'existing tracked proof reference blocks retirement'
archive = HERE / 'combined-logs'
archive.mkdir()
records = []
for name, commit in LOGS.items():
    relative = '.linkedspec-data/' + name
    assert relative not in tracked
    path = ROOT / relative
    before = identity(path)
    raw = path.read_bytes()
    assert identity(path) == before and len(raw) == before['bytes']
    target = archive / (name + '.gz')
    target.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(target.read_bytes()) == raw, 'copy readback differs'
    assert path.read_bytes() == raw and identity(path) == before, 'log still changing'
    git = subprocess.check_output(['git', 'show', '-s', '--format=%H%n%P%n%s', commit], cwd=ROOT).decode()
    records.append(dict(path=relative, archive=target.relative_to(ROOT).as_posix(),
        sha256=hashlib.sha256(raw).hexdigest(), metadata=before, commit=commit, git=git))
manifest = dict(owner=OWNER, activation_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
    at_utc=datetime.now(timezone.utc).isoformat(), records=records,
    scope='Four exact combined logs from completed commands owned by this session. Original channel separation is unavailable; no global process-liveness or disk-free-space claim. All other files, caches, native products and historical proof remain retained.')
(HERE / 'archive-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'review.py'), '--before-delete']
(HERE / 'predelete-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
checked = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (HERE / ('predelete-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(checked, channel), mtime=0))
(HERE / 'predelete-exit.txt').write_text(str(checked.returncode) + '\n')
assert checked.returncode == 0 and checked.stderr == b'', 'independent archive use must pass before deletion'
assert json.loads(checked.stdout)['result'] == 'PASS'
for row in records:
    path = ROOT / row['path']
    assert identity(path) == row['metadata']
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
    assert gzip.decompress((ROOT / row['archive']).read_bytes()) == path.read_bytes()
    path.unlink()
assert all(not (ROOT / row['path']).exists() for row in records)
result = dict(result='PASS', at_utc=datetime.now(timezone.utc).isoformat(), removed_plain_files=len(records),
    archived_content_bytes=sum(row['metadata']['bytes'] for row in records),
    absent=[row['path'] for row in records], predelete_actual_exit=checked.returncode,
    limits='Exact duplicate retirement after verified compressed recovery and independent use; allocated/free-space reclamation is not measured.')
(HERE / 'retirement.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, sort_keys=True))

"""Freeze a named-reference census from already retained activation Git objects."""
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)


def command(label, argv, allowed=(0,)):
    folder = BASE / 'commands'
    folder.mkdir(exist_ok=True)
    with (folder / (label + '.json')).open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (folder / (label + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in allowed and not result.stderr, (label, result.returncode, result.stderr)
    return result.stdout


def main():
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    assert not (BASE / 'instruments.tar.gz').exists(), 'one-shot capture'
    instruments = {}
    with tarfile.open(BASE / 'instruments.tar.gz', 'x:gz') as archive:
        for leaf in ('plan.json', 'capture.py', 'review.py', 'probes.py'):
            path = BASE / leaf
            body = path.read_bytes()
            instruments[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=str(path), recursive=False)
    (BASE / 'instrument-identities.json').write_text(json.dumps(instruments, indent=2, sort_keys=True) + '\n')
    listing = command('tree', ['git', 'ls-tree', '-rz', plan['activation'], '--', *plan['roots']])
    entries, boundaries = [], []
    for cell in listing.split(b'\0'):
        if not cell:
            continue
        metadata, raw_name = cell.split(b'\t', 1)
        mode, kind, oid = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            boundaries.append(dict(path=raw_name.decode(), mode=mode.decode(), kind=kind.decode(), oid=oid.decode()))
            continue
        entries.append(dict(path=raw_name.decode(), mode=int(mode, 8) & 0o777, oid=oid.decode()))
    argv = ['git', 'grep', '-l', '-z', '-F']
    for name in plan['candidates']:
        argv.extend(['-e', Path(name).name])
    argv.extend([plan['activation'], '--', *plan['roots']])
    grep = command('named-reference-files', argv, allowed=(0, 1))
    expected = sorted(cell.decode().removeprefix(plan['activation'] + ':') for cell in grep.split(b'\0') if cell)
    assert len(expected) == len(set(expected))
    matched, reads = {}, []
    needles = [Path(name).name.encode() for name in plan['candidates']]
    for entry in entries:
        # Logical input bytes already live in the named clean Git revision. Save
        # their identities and small command record; no new full-source duplicate.
        argv = ['git', 'cat-file', 'blob', entry['oid']]
        result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        assert result.returncode == 0 and not result.stderr
        body = result.stdout
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == entry['oid']
        row = dict(entry, bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), exit=0, stderr_hex='')
        reads.append(row)
        if any(needle in body for needle in needles):
            matched[entry['path']] = body
    assert sorted(matched) == expected, 'independent byte scan versus Git literal census'
    fixed = set(plan['candidates']) | set(plan['fixed_inputs']) | set(matched)
    all_tree = command('fixed-tree', ['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(fixed)])
    fixed_entries = {}
    for cell in all_tree.split(b'\0'):
        if cell:
            metadata, raw_name = cell.split(b'\t', 1)
            mode, kind, oid = metadata.split()
            assert kind == b'blob' and mode in (b'100644', b'100755')
            fixed_entries[raw_name.decode()] = dict(mode=int(mode, 8) & 0o777, oid=oid.decode())
    assert set(fixed_entries) == fixed
    identities = {}
    with tarfile.open(BASE / 'sources.tar.gz', 'x:gz') as archive:
        for name in sorted(fixed):
            path = Path(name)
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            oid = hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest()
            assert oid == fixed_entries[name]['oid'] and stat.S_IMODE(path.stat().st_mode) == fixed_entries[name]['mode']
            identities[name] = dict(fixed_entries[name], bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'source-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    (BASE / 'census.json').write_text(json.dumps(dict(activation=plan['activation'], roots=plan['roots'],
        blob_reads=reads, boundaries=boundaries, matching_files=expected, cat_file_command=['git', 'cat-file', 'blob', '${oid}'],
        limits='Exact literal basenames in six named root-owned Git subtrees only; no computed names, documentation-generated callers, other roots or actual execution inference. Source bytes are retained in activation Git; selected matching/context bodies are separately archived. Native/per-read/source-origin/physical closure remains4.2/SESSION5.'), indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', scoped_blobs=len(reads), matching_files=expected, archived_sources=len(identities)), sort_keys=True))


if __name__ == '__main__':
    main()

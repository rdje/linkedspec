"""Measure committed outgoing Git data; diagnostic packs stay on this volume outside Git."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import tarfile
from datetime import datetime, timezone

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
POLICY = json.loads((BASE / 'policy.json').read_bytes())
stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
OUT = Path('.linkedspec-data/push-monitor') / stamp
OUT.mkdir(parents=True)
assert OUT.stat().st_dev == ROOT.stat().st_dev
ENVIRONMENT = dict(GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1', LC_ALL='C')
ENV = dict(os.environ, **ENVIRONMENT)


def run(tag, command, data=None, accepted=(0,)):
    record = dict(argv=command, cwd='.', environment=ENVIRONMENT)
    if data is not None:
        (OUT / (tag + '-stdin.gz')).write_bytes(gzip.compress(data, mtime=0))
        record['stdin'] = tag + '-stdin.gz'
    (OUT / (tag + '-command.json')).write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')
    result = subprocess.run(command, input=data, cwd=ROOT, env=ENV, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode in accepted, 'Actual measurement failure retained:' + tag
    return result.stdout


paths = [Path(__file__).relative_to(ROOT), BASE / 'policy.json']
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh')]
identities = {}
with tarfile.open(OUT / 'producer-inputs.tar.gz', 'x:gz') as packed:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        packed.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'producer-inputs.tar.gz') as packed:
    assert set(packed.getnames()) == identities.keys()
    for member in packed:
        body = packed.extractfile(member).read(); row = identities[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'producer-input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
memory = run('memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'])
free = re.search(rb'System-wide memory free percentage: (\d+)%', memory)
assert free and int(free[1]) >= POLICY['minimum_free_memory_percent'], 'Need conservative headroom before the single pack worker'
head = run('head', ['git', 'rev-parse', 'HEAD']).decode().strip()
base = run('base', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip()
assert re.fullmatch(r'[0-9a-f]{40,64}', head) and re.fullmatch(r'[0-9a-f]{40,64}', base)
ahead = int(run('ahead', ['git', 'rev-list', '--count', base + '..' + head]))
run('git-version', ['git', '--version'])
algorithm = run('object-format', ['git', 'rev-parse', '--show-object-format']).decode().strip()
assert algorithm in ('sha1', 'sha256')
config_command = ['git', 'config', '--get-regexp', r'^(core\.compression|pack\.(window|depth|compression|usesparse|reusedeltas|reuseobjects|windowmemory|threads))$']
config = run('pack-config', config_command, accepted=(0, 1))
revisions = (head + '\n^' + base + '\n').encode()
(OUT / 'revisions.txt').write_bytes(revisions)
objects = run('objects', ['git', 'rev-list', '--objects', '--no-object-names', head, '^' + base])
metadata = run('object-metadata', ['git', 'cat-file', '--batch-check=%(objectname) %(objecttype) %(objectsize)'], objects)
rows = [line.split() for line in metadata.decode().splitlines()]
assert all(len(row) == 3 and row[1] in ('commit', 'tree', 'blob', 'tag') for row in rows)
blobs = [(int(row[2]), row[0]) for row in rows if row[1] == 'blob']
command = ['git', 'pack-objects', '--revs', '--stdout', '--delta-base-offset', '--no-sparse',
    '--threads=' + str(POLICY['threads']), '--window-memory=' + POLICY['window_memory'], '--progress']
(OUT / 'pack-command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT,
    stdin='revisions.txt', scope='Non-thin serialized committed range estimate with explicit no-sparse walking; actual negotiated upload can differ.'), indent=2, sort_keys=True) + '\n')
pack = OUT / 'outgoing-estimate.pack'
with (OUT / 'pack-stderr.log').open('xb') as errors, pack.open('xb') as destination:
    process = subprocess.Popen(command, cwd=ROOT, env=ENV, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=errors)
    process.stdin.write(revisions); process.stdin.close()
    count, hasher = 0, hashlib.sha256()
    while chunk := process.stdout.read(1024 * 1024):
        destination.write(chunk); count += len(chunk); hasher.update(chunk)
    code = process.wait()
(OUT / 'pack-exit.txt').write_text(str(code) + '\n')
(OUT / 'pack-stderr.gz').write_bytes(gzip.compress((OUT / 'pack-stderr.log').read_bytes(), mtime=0))
assert code == 0 and count == pack.stat().st_size, 'actual producer/stat byte count'
digest_size = hashlib.new(algorithm).digest_size
with pack.open('rb') as stream:
    header = stream.read(12); magic, version, packed_objects = struct.unpack('>4sII', header)
    assert magic == b'PACK' and version in (2, 3)
    stream.seek(0); remaining, checksum = count - digest_size, hashlib.new(algorithm)
    while remaining:
        chunk = stream.read(min(1024 * 1024, remaining)); assert chunk
        checksum.update(chunk); remaining -= len(chunk)
    footer = stream.read()
    assert footer == checksum.digest(), 'pack footer checksum'
empty = run('empty-range', command[:-1], (head + '\n^' + head + '\n').encode())
assert struct.unpack('>4sII', empty[:12])[2] == 0 and len(empty) == 12 + digest_size
assert run('head-after', ['git', 'rev-parse', 'HEAD']).decode().strip() == head
assert run('base-after', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip() == base
assert run('pack-config-after', config_command, accepted=(0, 1)) == config
for name, row in identities.items():
    path = Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
result = dict(head=head, cached_origin_main=base, ahead=ahead, estimated_non_thin_pack_bytes=count,
    decimal_gb=count / 1_000_000_000, gib=count / (1024 ** 3), packed_objects=packed_objects,
    pack_sha256=hasher.hexdigest(), pack_footer=footer.hex(), object_format=algorithm,
    object_rows=len(rows), unique_object_ids=len({row[0] for row in rows}),
    largest_outgoing_blob_bytes=max(blobs, default=(0, ''))[0], largest_outgoing_blob_oid=max(blobs, default=(0, ''))[1],
    early_push_trigger_bytes=POLICY['early_push_trigger_bytes'], trigger_reached=count >= POLICY['early_push_trigger_bytes'],
    preparation_threshold_bytes=POLICY['preparation_threshold_bytes'], preparation_due=count >= POLICY['preparation_threshold_bytes'],
    remaining_to_trigger_bytes=POLICY['early_push_trigger_bytes'] - count, evidence=str(OUT),
    limits='Committed HEAD against cached origin/main only; all uncommitted changes excluded. No network remote refresh or negotiated wire/server/future-size promise. Source/policy/config/ref/command and logical-object metadata retained before pack use; native/physical Git/cache/compressor/toolchain/OS closure remains4.2/SESSION5. Raw diagnostic pack remains ignored on this volume. Preparation100MB is advisory, not a bound on future work or CI receipt growth.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))

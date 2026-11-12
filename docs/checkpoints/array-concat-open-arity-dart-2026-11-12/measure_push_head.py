"""Operational committed-HEAD pack estimate; keep diagnostic packs outside Git."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
from datetime import datetime, timezone

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
OUT = Path('.linkedspec-data/push-monitor') / stamp
OUT.mkdir(parents=True)
ENV = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1')


def run(tag, command, data=None):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, input=data, cwd=ROOT, env=ENV, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Actual operational sizing failure retained:' + tag
    return result.stdout


memory = run('memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'])
free = re.search(rb'System-wide memory free percentage: (\d+)%', memory)
assert free and int(free[1]) >= 45, 'Need conservative headroom for one bounded pack worker'
head = run('head', ['git', 'rev-parse', 'HEAD']).decode().strip()
base = run('base', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip()
ahead = int(run('ahead', ['git', 'rev-list', '--count', base + '..' + head]))
run('git-version', ['git', '--version'])
algorithm = run('object-format', ['git', 'rev-parse', '--show-object-format']).decode().strip()
assert algorithm in ('sha1', 'sha256')
revisions = (head + '\n^' + base + '\n').encode()
(OUT / 'revisions.txt').write_bytes(revisions)
objects = run('objects', ['git', 'rev-list', '--objects', '--no-object-names', head, '^' + base])
metadata = run('object-metadata', ['git', 'cat-file', '--batch-check=%(objectname) %(objecttype) %(objectsize)'], objects)
rows = [line.split() for line in metadata.decode().splitlines()]
assert all(len(row) == 3 and row[1] in ('commit', 'tree', 'blob', 'tag') for row in rows)
blobs = [(int(row[2]), row[0]) for row in rows if row[1] == 'blob']
command = ['git', 'pack-objects', '--revs', '--stdout', '--delta-base-offset', '--threads=1', '--window-memory=64m', '--progress']
(OUT / 'pack-command.json').write_text(json.dumps(dict(argv=command, cwd='.',
    stdin='revisions.txt', scope='Conservative non-thin serialized range estimate; actual negotiated push may differ.'), indent=2) + '\n')
pack = OUT / 'outgoing-estimate.pack'
with (OUT / 'pack-stderr.log').open('xb') as errors, pack.open('xb') as destination:
    process = subprocess.Popen(command, cwd=ROOT, env=ENV, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=errors)
    process.stdin.write(revisions); process.stdin.close()
    count, hasher = 0, hashlib.sha256()
    while chunk := process.stdout.read(1024 * 1024):
        destination.write(chunk); count += len(chunk); hasher.update(chunk)
    code = process.wait()
(OUT / 'pack-exit.txt').write_text(str(code) + '\n')
assert code == 0 and count == pack.stat().st_size, 'actual producer/stat count'
digest_size = hashlib.new(algorithm).digest_size
with pack.open('rb') as stream:
    header = stream.read(12); magic, version, packed_objects = struct.unpack('>4sII', header)
    assert magic == b'PACK' and version in (2, 3)
    stream.seek(0); remaining, checksum = count - digest_size, hashlib.new(algorithm)
    while remaining:
        chunk = stream.read(min(1024 * 1024, remaining)); assert chunk
        checksum.update(chunk); remaining -= len(chunk)
    assert stream.read() == checksum.digest(), 'pack checksum'
# A different revision population must produce an empty standalone pack. This
# distinguishes outgoing-range sizing from the whole local object-store size.
empty = run('empty-range', command[:-1], (head + '\n^' + head + '\n').encode())
assert struct.unpack('>4sII', empty[:12])[2] == 0 and len(empty) == 12 + digest_size
assert run('head-after', ['git', 'rev-parse', 'HEAD']).decode().strip() == head
assert run('base-after', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip() == base
result = dict(head=head, cached_origin_main=base, ahead=ahead, estimated_non_thin_pack_bytes=count,
    decimal_gb=count / 1_000_000_000, gib=count / (1024 ** 3), packed_objects=packed_objects,
    pack_sha256=hasher.hexdigest(), object_rows=len(rows), unique_object_ids=len({row[0] for row in rows}),
    largest_outgoing_blob_bytes=max(blobs, default=(0, ''))[0],
    largest_outgoing_blob_oid=max(blobs, default=(0, ''))[1],
    early_push_trigger_bytes=1_500_000_000, trigger_reached=count >= 1_500_000_000,
    remaining_to_trigger_bytes=1_500_000_000-count, evidence=str(OUT),
    limits='Operational snapshot of committed HEAD against cached origin/main, excluding uncommitted Dart work. Logical bodies remain Git-addressed; raw pack stays ignored on the repository volume. Not actual wire/server storage or a future-size promise. Physical pack/cache/Git toolchain/remote negotiation closure remains unassessed; formal guard/publication owner23.4.30.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))

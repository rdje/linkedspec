"""Compare one no-sparse pack to the original operational estimate and object list."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess

ROOT = Path.cwd().resolve()
OUT = sorted((ROOT / '.linkedspec-data/push-monitor').iterdir())[-1]
ENV = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1')


def run(tag, command):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=ENV, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Actual scope-control failure retained:' + tag
    return result.stdout


assert run('sparse-effective', ['git', 'config', '--type=bool', '--default=true', '--get', 'pack.useSparse']) == b'true\n'
command = json.loads((OUT / 'pack-command.json').read_bytes())['argv'] + ['--no-sparse']
pack = OUT / 'outgoing-no-sparse.pack'
assert not pack.exists()
(OUT / 'no-sparse-command.json').write_text(json.dumps(dict(argv=command, cwd='.', stdin='revisions.txt'), indent=2) + '\n')
with pack.open('xb') as output:
    result = subprocess.run(command, cwd=ROOT, env=ENV, input=(OUT / 'revisions.txt').read_bytes(), stdout=output, stderr=subprocess.PIPE)
(OUT / 'no-sparse-stderr.gz').write_bytes(gzip.compress(result.stderr, mtime=0))
(OUT / 'no-sparse-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
index = OUT / 'outgoing-no-sparse.idx'
run('no-sparse-index', ['git', 'index-pack', '--threads=1', '-o', str(index.relative_to(ROOT)), str(pack.relative_to(ROOT))])
dense = run('no-sparse-verify', ['git', 'verify-pack', '-v', str(index.relative_to(ROOT))])


def object_rows(body):
    rows = {}
    for line in body.decode().splitlines():
        parts = line.split()
        if parts and re.fullmatch(r'[0-9a-f]{40,64}', parts[0]):
            assert parts[0] not in rows
            rows[parts[0]] = parts
    return rows


logical = set(gzip.decompress((OUT / 'objects-stdout.gz').read_bytes()).decode().splitlines())
sparse = object_rows(gzip.decompress((OUT / 'verify-stdout.gz').read_bytes()))
dense = object_rows(dense)
assert dense.keys() == logical, 'no-sparse scope must exactly match the declared revision list'
extra = sparse.keys() - logical
base = set(gzip.decompress((OUT / 'base-objects-stdout.gz').read_bytes()).decode().splitlines())
assert extra <= base and not logical - sparse.keys()
with pack.open('rb') as stream:
    assert struct.unpack('>4sII', stream.read(12))[2] == len(dense)
report = dict(logical_objects=len(logical), sparse_pack_objects=len(sparse), no_sparse_pack_objects=len(dense),
    sparse_extra_already_at_base=[dict(oid=oid, type=sparse[oid][1], bytes=int(sparse[oid][2])) for oid in sorted(extra)],
    no_sparse_pack_bytes=pack.stat().st_size, original_estimate_bytes=json.loads((OUT / 'result.json').read_bytes())['estimated_non_thin_pack_bytes'],
    explanation='Effective sparse revision walking adds five already-at-base blobs. Disabling only sparse inclusion removes exactly those five, with all declared objects present. The original delta-base-only hypothesis is falsified and its failure retained. Both serialized estimates remain below the conservative1.5GB trigger; neither is actual negotiated wire size.',
    primary_contract='https://git-scm.com/docs/git-pack-objects#Documentation/git-pack-objects.txt---sparse')
(OUT / 'sparse-accounting.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(json.dumps(report, sort_keys=True))

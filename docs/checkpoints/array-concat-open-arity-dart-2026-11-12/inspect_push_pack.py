"""Explain the conservative pack/object-list boundary using opaque Git metadata."""
import gzip
import json
import os
from pathlib import Path
import re
import struct
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
OUT = sorted((ROOT / '.linkedspec-data/push-monitor').iterdir())[-1]
report = json.loads((OUT / 'result.json').read_bytes())
pack = OUT / 'outgoing-estimate.pack'
index = OUT / 'outgoing-estimate.idx'
assert not index.exists()
environment = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1')


def run(tag, command):
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, 'Actual accounting failure retained:' + tag
    return result.stdout


run('index', ['git', 'index-pack', '--threads=1', '-o', str(index.relative_to(ROOT)), str(pack.relative_to(ROOT))])
body = run('verify', ['git', 'verify-pack', '-v', str(index.relative_to(ROOT))]).decode()
rows = {}
for line in body.splitlines():
    parts = line.split()
    if parts and re.fullmatch(r'[0-9a-f]{40,64}', parts[0]):
        assert parts[0] not in rows
        rows[parts[0]] = parts
logical = set(gzip.decompress((OUT / 'objects-stdout.gz').read_bytes()).decode().splitlines())
with pack.open('rb') as stream:
    assert len(rows) == struct.unpack('>4sII', stream.read(12))[2]
extra, missing = rows.keys() - logical, logical - rows.keys()
base = set(run('base-objects', ['git', 'rev-list', '--objects', '--no-object-names', report['cached_origin_main']]).decode().splitlines())
assert not missing, 'all declared range objects must be covered'
assert extra <= base, 'classify unexpected extra objects before publication'
used_as_base = {oid: [row[0] for row in rows.values() if len(row) == 7 and row[-1] == oid] for oid in extra}
assert all(used_as_base.values()), 'explain every extra object through actual delta edges'
result = dict(logical_range_objects=len(logical), conservative_pack_objects=len(rows), missing=[],
    extra_objects=[dict(oid=oid, type=rows[oid][1], bytes=int(rows[oid][2]),
        already_reachable_at_base=True, actual_delta_children=used_as_base[oid]) for oid in sorted(extra)],
    conclusion='The non-thin estimate includes additional already-at-base delta bases; they close actual serialized delta edges. All revision-list objects are covered. These populations are not interchangeable and the byte estimate remains conservative, not negotiated wire size.')
(OUT / 'accounting.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))

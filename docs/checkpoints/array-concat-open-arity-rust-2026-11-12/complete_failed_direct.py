"""Retain completed first-direct snapshots without replaying its successful normal."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
OUT = BASE / 'direct-completion'
OUT.mkdir()
assert (BASE / 'direct/normal-exit.txt').read_text() == '0\n'
assert (BASE / 'direct/array_transform_result_guard_composition-exit.txt').read_text() == '101\n'
stderr = gzip.decompress((BASE / 'direct/normal-stderr.log.gz').read_bytes()).decode()
custody = []
for tag, folder, frame, field in (
    ('normal-parsed', 'normal-parsed', 'ARRAY_CONCAT_RUST_NORMAL_PARSED_INPUT', 'parsed'),
    ('normal-serialized', 'normal-inputs', 'ARRAY_CONCAT_RUST_NORMAL_INPUT', 'compiled'),
):
    frames = {}
    for key, raw in re.findall(r'^' + frame + r' (\w+) (\{.*\})$', stderr, re.M):
        assert key not in frames
        frames[key] = json.loads(raw)[field].encode()
    paths = sorted((BASE / 'direct' / folder).glob('*.json'))
    assert len(paths) == len(frames) == 504
    rows = {}
    target = OUT / (tag + '-inputs.tar.gz')
    with tarfile.open(target, 'x:gz') as archive:
        for path in paths:
            body = path.read_bytes(); assert body == frames[path.stem]
            name = str(path.relative_to(ROOT))
            rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=name, recursive=False)
    with tarfile.open(target) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    custody.append(dict(archive=str(target.relative_to(ROOT)), files=rows))
(OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')
(OUT / 'scope.txt').write_text('Original completed504 normal snapshots persist before first use in the original instrument; these archive copies are recovered after the controller failed on ordinary expectations. Original direct actual1/ordinary101 and its custody/channels remain unchanged. No SDK replay or new native/cache/transitive closure.\n')
print('Recovered1008 exact original normal snapshots after the failed controller; completed504 normal was not replayed')

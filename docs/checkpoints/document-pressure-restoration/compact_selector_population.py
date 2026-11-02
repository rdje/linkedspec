"""Remove duplicate binary packets while preserving the exact captured archive."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import os

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),
                sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    if hashlib.sha256(raw).hexdigest() != row['sha256']:
        raise ValueError('selector population packet identity')
    return raw


def reconstruct(envelope, read):
    if envelope['schema_version'] != 2:
        raise ValueError('unsupported selector population representation')
    record = copy.deepcopy(envelope['record'])
    for name, row in record['inputs'].items():
        if 'artifact_path' not in row:
            continue
        if row['artifact_path'] != name or row['disposition'] != 'binary':
            raise ValueError('invalid selector binary reference')
        if not (name.startswith('docs/checkpoints/document-pressure-restoration/')
                or name == 'tests/language-readiness/current-source-images.json.gz'):
            raise ValueError('foreign selector binary reference')
        raw = read(name)
        if hashlib.sha256(raw).hexdigest() != row['sha256']:
            raise ValueError('selector binary reference drift: '+name)
        row.pop('artifact_path')
        row['payload'] = packet(raw)
    raw = gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0)
    if (len(raw) != envelope['original_bytes']
            or hashlib.sha256(raw).hexdigest() != envelope['original_sha256']):
        raise ValueError('selector population reconstruction differs')
    return record


def compact():
    path = HERE / 'selector-source-population.json.gz'
    original = path.read_bytes()
    record = json.loads(gzip.decompress(original))
    if record['schema_version'] != 1:
        raise ValueError('selector population was already compacted')
    count = 0
    for name, row in record['inputs'].items():
        if row.get('disposition') != 'binary' or 'payload' not in row:
            continue
        if not (name.startswith('docs/checkpoints/document-pressure-restoration/')
                or name == 'tests/language-readiness/current-source-images.json.gz'):
            continue
        if (ROOT/name).read_bytes() != decode(row['payload']):
            raise ValueError('selector primary artifact differs: '+name)
        row.pop('payload')
        row['artifact_path'] = name
        count += 1
    envelope = dict(schema_version=2, record=record,
                    original_bytes=len(original),
                    original_sha256=hashlib.sha256(original).hexdigest(),
                    producer=packet(Path(__file__).read_bytes()))
    reconstruct(envelope, lambda name: (ROOT/name).read_bytes())
    backup = ROOT / '.linkedspec-data/normal-hook-restoration/selector-source-population-original.json.gz'
    if backup.exists():
        raise ValueError('selector original backup already exists')
    backup.write_bytes(original)
    if backup.read_bytes() != original:
        raise ValueError('selector original backup verification failed')
    temporary = path.with_suffix('.staging')
    if temporary.exists():
        raise ValueError('selector staging path already exists')
    temporary.write_bytes(gzip.compress(json.dumps(envelope, sort_keys=True).encode(), mtime=0))
    os.replace(temporary, path)
    print('selector population: exact original archive reconstructs;',count,'binary packets use verified primary artifact references')


if __name__ == '__main__':
    compact()

"""Readonly recovery of the original logical patch input and both recorded reviews."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-transform-source-perl-2026-11-07')


def validate(mapping, packed):
    assert mapping['logical_path'] == str(BASE / 'source.patch'), 'logical-path'
    assert mapping['storage_path'] == str(BASE / 'source.patch.gz') and mapping['encoding'] == 'gzip'
    raw = gzip.decompress(packed)
    assert len(raw) == mapping['bytes'] and hashlib.sha256(raw).hexdigest() == mapping['sha256'], 'patch-identity'
    assert raw.startswith(b'--- perl/LinkedSpec/ActionIR/MethodLowering.pm\n+++ ')
    return raw


def main():
    mapping = json.loads((ROOT / BASE / 'patch-storage.json').read_bytes())
    packed = (ROOT / mapping['storage_path']).read_bytes()
    raw = validate(mapping, packed)
    assert not (ROOT / mapping['logical_path']).exists(), 'uncompressed-residue'
    for name in ('readonly_review', 'result_preservation_review'):
        records = json.loads((ROOT / BASE / name / 'input-identities.json').read_bytes())
        for path, record in records.items():
            body = raw if path == mapping['logical_path'] else (ROOT / path).read_bytes()
            assert len(body) == record['bytes'] and hashlib.sha256(body).hexdigest() == record['sha256'], 'original-review-input'
        assert (ROOT / BASE / name / 'exit.txt').read_text() == '0\n'
        assert gzip.decompress((ROOT / BASE / name / 'stderr.log.gz').read_bytes()) == b''
    denials = []
    for field, value, reason in (('logical_path', str(BASE / 'wrong.patch'), 'logical-path'), ('sha256', '0' * 64, 'patch-identity')):
        changed = copy.deepcopy(mapping)
        changed[field] = value
        try:
            validate(changed, packed)
        except AssertionError as error:
            assert str(error) == reason
            denials.append(reason)
        else:
            raise AssertionError('ineffective-storage-control')
    print(json.dumps(dict(result='PASS', boundary='both original review input manifests recover byte-exactly; original logical diff bytes preserved in gzip; no uncompressed residue', controls=denials), indent=2))


if __name__ == '__main__':
    main()

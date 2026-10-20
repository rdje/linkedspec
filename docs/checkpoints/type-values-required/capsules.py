"""Recover exact large measurement capsules through hash-checked existing input bytes."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'


def read_version(path, wanted):
    target = ROOT / path
    if target.is_file():
        item = c.read(path)
        if all(item[key] == wanted[key] for key in ('sha256', 'mode')):
            return item
    reference = target.with_name(target.name + '.ref.gz')
    if reference.is_file():
        packed = json.loads(gzip.decompress(reference.read_bytes()))
        value = packed['body']
        value['inputs'] = {name: read_version(name, identity)
                           for name, identity in packed['inputs'].items()}
        raw = gzip.compress((json.dumps(value, sort_keys=True) + '\n').encode(), mtime=0)
        item = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=packed['original_mode'])
        assert all(item[key] == wanted[key] for key in ('sha256', 'mode')), path
        return item
    retained = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
    item = retained['before'].get(path)
    if not item:
        correction = ROOT / (P + 'warning-proposals.json.gz')
        if correction.is_file():
            item = json.loads(gzip.decompress(correction.read_bytes()))['before'].get(path)
    assert item and all(item[key] == wanted[key] for key in ('sha256', 'mode')), path
    return item


def load(name):
    target = ROOT / (P + name)
    if target.is_file():
        raw = target.read_bytes()
    else:
        reference = json.loads(gzip.decompress(target.with_name(target.name + '.ref.gz').read_bytes()))
        raw = c.decode(read_version(P + name, dict(
            sha256=reference['original_sha256'], mode=reference['original_mode']))['base64'])
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)

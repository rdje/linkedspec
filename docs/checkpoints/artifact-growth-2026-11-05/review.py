"""Bounded artifact-growth observation; default is read-only, --capture one-shot.

Uses public Git metadata and one opaque blob body, never dependency internals.
Physical pack bodies/server state and complete native tool closure are unassessed.
"""
import argparse
import base64
import copy
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
ARTIFACT = 'docs/checkpoints/signed-array-contract-admission/import-epoch-before.json.gz'
OLD = 'docs/checkpoints/artifact-review-2026-11-04/observation.json.gz'
ANCHOR = 'eda3c81fe6ca9264f0ba96f3f90525d96d79626c'
OUTPUT = HERE / 'observation.json'


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT).decode().strip()


def fields(raw):
    return {key: int(value) for key, value in
            (line.split(': ', 1) for line in raw.splitlines())}


def object_oracle():
    oid = git('rev-parse', ANCHOR + ':' + ARTIFACT)
    size = int(git('cat-file', '-s', oid))
    assert git('cat-file', '-t', oid) == 'blob'
    process = subprocess.Popen(['git', 'cat-file', 'blob', oid], cwd=ROOT,
                               stdout=subprocess.PIPE)
    digest = hashlib.sha256()
    address = hashlib.sha1(b'blob ' + str(size).encode() + b'\0')
    body_size = 0
    while block := process.stdout.read(1024 * 1024):
        body_size += len(block)
        digest.update(block)
        address.update(block)
    assert process.wait() == 0
    assert body_size == size and address.hexdigest() == oid
    return {'oid': oid, 'bytes': size, 'body_bytes': body_size,
            'sha256': digest.hexdigest()}


def warning():
    packet = json.loads(gzip.decompress((ROOT / OLD).read_bytes()))['messages'][
        '.linkedspec-data/logs/push-batch-10-01.txt']
    raw = base64.b64decode(packet['base64'])
    assert hashlib.sha256(raw).hexdigest() == packet['sha256']
    lines = [line for line in raw.decode().splitlines() if ARTIFACT in line]
    assert len(lines) == 1 and '50.86 MB' in lines[0], lines
    return {'source': OLD, 'packet_sha256': packet['sha256'],
            'line': lines[0]}


def validate(report, oracle, original_warning):
    assert report['anchor'] == ANCHOR
    assert report['object'] == oracle, 'named blob metadata/body mismatch'
    assert report['warning'] == original_warning, 'actual warning changed'
    assert report['classification'] == {
        'blob_above_50_MiB': True, 'blob_below_100_MiB': True,
        'local_scope': 'root local object database only',
        'server_disk_bytes': None,
        'wire_bytes': None,
        'historical_thin_pack_is_server_size': False,
        'splitting_payload_bounds_lifetime_history': False,
    }, 'scope/threshold conflation'
    assert 50 * 1024**2 < oracle['bytes'] < 100 * 1024**2
    local = report['local']
    assert fields(local['raw']) == local['fields'], 'local packet/fields mismatch'
    assert local['raw'] == local['repeat_raw'], 'unstable local snapshot'
    assert local['pack_unit'] == 'KiB' and local['scope'] == 'local', 'unit/scope'
    assert local['pack_bytes_from_KiB'] == local['fields']['size-pack'] * 1024


def controls(report, oracle, original_warning):
    rejected = []
    for name in ('wrong-object-size', 'warning-rewrite', 'server-conflation',
                 'decimal-pack-unit', 'split-history-bound'):
        changed = copy.deepcopy(report)
        if name == 'wrong-object-size': changed['object']['bytes'] -= 1
        elif name == 'warning-rewrite': changed['warning']['line'] += ' rejected'
        elif name == 'server-conflation': changed['classification']['server_disk_bytes'] = changed['local']['pack_bytes_from_KiB']
        elif name == 'decimal-pack-unit': changed['local']['pack_bytes_from_KiB'] = changed['local']['fields']['size-pack'] * 1000
        else: changed['classification']['splitting_payload_bounds_lifetime_history'] = True
        try:
            validate(changed, oracle, original_warning)
        except AssertionError:
            rejected.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)
    return rejected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    oracle, original_warning = object_oracle(), warning()
    if args.capture:
        assert not OUTPUT.exists(), 'capture is one-shot'
        assert git('rev-parse', 'HEAD') == ANCHOR
        raw = git('count-objects', '-v')
        report = {
            'date': datetime.now(timezone.utc).isoformat(), 'anchor': ANCHOR,
            'git_version': git('--version'), 'object': oracle,
            'warning': original_warning,
            'local': {'raw': raw, 'repeat_raw': git('count-objects', '-v'),
                      'fields': fields(raw), 'pack_unit': 'KiB', 'scope': 'local',
                      'pack_bytes_from_KiB': fields(raw)['size-pack'] * 1024},
            'classification': {
                'blob_above_50_MiB': True, 'blob_below_100_MiB': True,
                'local_scope': 'root local object database only',
                'server_disk_bytes': None, 'wire_bytes': None,
                'historical_thin_pack_is_server_size': False,
                'splitting_payload_bounds_lifetime_history': False,
            },
            'limits': 'One named blob and a dated local metadata observation. No whole-object census, physical pack reconstruction, remote size/supportability, wire bytes, new publication, custody completion or payload deletion.'
        }
        validate(report, oracle, original_warning)
        report['rejected_controls'] = controls(report, oracle, original_warning)
        OUTPUT.write_text(json.dumps(report, indent=2) + '\n')
    report = json.loads(OUTPUT.read_text())
    validate(report, oracle, original_warning)
    rejected = controls(report, oracle, original_warning)
    assert rejected == report['rejected_controls']
    print(json.dumps({'result': 'PASS', 'object_bytes': oracle['bytes'],
                      'local_pack_KiB_at_capture': report['local']['fields']['size-pack'],
                      'rejected_controls': rejected}, sort_keys=True))


if __name__ == '__main__':
    main()

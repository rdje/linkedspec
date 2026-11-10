"""Preserve the accepted checkpoint's physical bindings before shared prose moves."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
REVISION = '41ba410bbb03fe8e7e4dc1412331d069e258d70b'
RECORD = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
BEFORE = HERE / 'prior-18.1-claim.json.gz'
AFTER = HERE / 'preserved-18.1-claim.json.gz'
QUALIFICATION = (' Physical declared inputs are preserved at actual accepted Git capture '
    + REVISION + '; original statements, results, input hashes/roles and logical artifact epochs '
    'remain unchanged. This preserves the physical bundle/producer boundary without relabeling '
    'an earlier uncommitted logical epoch as a Git capture or acquiring native custody.')


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def inputs(record, live=False):
    entries = {}
    for row in git('ls-tree', '-r', '-z', REVISION).split(b'\0'):
        if row:
            header, name = row.split(b'\t', 1)
            entries[name.decode()] = header.decode().split()
    blobs = {}
    checked = rows = 0
    for claim in record['claims']:
        durability = claim['durability']
        if durability['status'] != 'checked':
            continue
        checked += 1
        for item in durability['inputs']:
            mode, kind, blob = entries[item['path']]
            assert mode in ('100644', '100755') and kind == 'blob'
            if blob not in blobs:
                blobs[blob] = git('cat-file', 'blob', blob)
            raw = blobs[blob]
            assert hashlib.sha256(raw).hexdigest() == item['sha256']
            if live:
                assert (ROOT / item['path']).read_bytes() == raw
            rows += 1
    assert checked == 8
    return rows


def review():
    before = json.loads(gzip.decompress(BEFORE.read_bytes()))
    after = json.loads(gzip.decompress(AFTER.read_bytes()))
    assert before['owner'] == after['owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
    assert len(before['claims']) == len(after['claims']) == 11
    expected = json.loads(json.dumps(before))
    for claim in expected['claims']:
        if claim['durability']['status'] == 'checked':
            assert claim['durability']['mode'] == 'live'
            claim['durability'].update(mode='historical', revision=REVISION)
            claim['scope'] += QUALIFICATION
    assert after == expected, 'only mode/revision/capture qualification may change'
    assert gzip.decompress(BEFORE.read_bytes()) == git('show', REVISION + ':' + RECORD)
    return dict(result='PASS', checked_claims=8, native_gaps_unchanged=3,
                verified_input_rows=inputs(before), accepted_capture=REVISION,
                scope='Exact accepted physical input identities; original logical epochs/results unchanged.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--preserve', action='store_true')
    args = parser.parse_args()
    if args.preserve:
        assert not BEFORE.exists() and not AFTER.exists(), 'one-shot accepted capture preservation'
        raw = (ROOT / RECORD).read_bytes()
        assert raw == git('show', REVISION + ':' + RECORD)
        original = json.loads(raw)
        inputs(original, live=True)
        updated = json.loads(raw)
        for claim in updated['claims']:
            if claim['durability']['status'] == 'checked':
                claim['durability'].update(mode='historical', revision=REVISION)
                claim['scope'] += QUALIFICATION
        qualified = (json.dumps(updated, indent=2) + '\n').encode()
        assert len(qualified) <= 131072
        BEFORE.write_bytes(gzip.compress(raw, mtime=0))
        AFTER.write_bytes(gzip.compress(qualified, mtime=0))
        (ROOT / RECORD).write_bytes(qualified)
    print(json.dumps(review(), sort_keys=True))

"""Mode/revision-only qualification; default replay never rereads future book text."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
REVISION = '2286c6606a9fb86290801e1c8a0053e59d342a1f'
RECORD = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.8.json'
NAME = 'intersecting-claim-mode-only-preservation'
BOOK = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))


def expected_record():
    raw = subprocess.check_output(['git', 'show', REVISION + ':' + RECORD], cwd=ROOT)
    original = json.loads(raw)
    expected = copy.deepcopy(original)
    selected = [c for c in expected['claims'] if c['name'] == NAME]
    assert len(selected) == 1
    leg = selected[0]['durability']
    assert leg['status'] == 'checked' and leg['mode'] == 'live' and 'revision' not in leg
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    verified = []
    try:
        for row in leg['inputs']:
            process.stdin.write((REVISION + ':' + row['path'] + '\n').encode())
            process.stdin.flush()
            header = process.stdout.readline().split()
            assert len(header) == 3 and header[1] == b'blob'
            remaining = size = int(header[2])
            digest = hashlib.sha256()
            while remaining:
                block = process.stdout.read(min(remaining, 1024 * 1024))
                assert block
                digest.update(block)
                remaining -= len(block)
            assert process.stdout.read(1) == b'\n' and digest.hexdigest() == row['sha256'], row['path']
            verified.append(dict(path=row['path'], oid=header[0].decode(), bytes=size, sha256=digest.hexdigest()))
    finally:
        process.stdin.close()
        assert process.wait() == 0
    leg.update(mode='historical', revision=REVISION)
    return raw, expected, verified


def validate(candidate, expected):
    assert canonical(candidate) == canonical(expected), 'mode/revision-only preservation'


def controls(expected):
    rejected = []
    index = next(i for i, c in enumerate(expected['claims']) if c['name'] == NAME)
    for name in ('original-statement', 'original-input-hash', 'wrong-revision', 'omitted-input', 'unselected-claim', 'bool-version'):
        value = copy.deepcopy(expected)
        target = value['claims'][index]
        if name == 'original-statement': target['statement'] += ' LOST'
        elif name == 'original-input-hash': target['durability']['inputs'][0]['sha256'] = '0' * 64
        elif name == 'wrong-revision': target['durability']['revision'] = '0' * 40
        elif name == 'omitted-input': target['durability']['inputs'].pop()
        elif name == 'bool-version': value['version'] = True
        else: value['claims'][next(i for i in range(len(value['claims'])) if i != index)]['statement'] += ' LOST'
        try:
            validate(value, expected)
        except AssertionError as error:
            assert str(error) == 'mode/revision-only preservation'
            rejected.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)
    return rejected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    original, expected, verified = expected_record()
    report_path = BASE / 'advisory-preservation-result.json'
    target = ROOT / RECORD
    if args.apply:
        assert target.read_bytes() == original and not report_path.exists()
        edited = (ROOT / BOOK).read_bytes()
        old_book = next(row for row in verified if row['path'] == BOOK)
        assert hashlib.sha256(edited).hexdigest() != old_book['sha256'], 'actual stale-book RED required'
        (BASE / 'advisory-original-claim.json.gz').write_bytes(gzip.compress(original, mtime=0))
        (BASE / 'advisory-edited-book.md.gz').write_bytes(gzip.compress(edited, mtime=0))
        (BASE / 'advisory-preserver-source.py.gz').write_bytes(gzip.compress(Path(__file__).read_bytes(), mtime=0))
        report = dict(revision=REVISION, record=RECORD, selected_claim=NAME, verified_inputs=verified,
                      changed_fields=['durability.mode', 'durability.revision'],
                      edited_book_sha256=hashlib.sha256(edited).hexdigest(), original_book_sha256=old_book['sha256'],
                      original_live_book_binding_rejects_edit=True, rejected_controls=controls(expected))
        target.write_text(json.dumps(expected, indent=2) + '\n')
        report_path.write_text(json.dumps(report, indent=2) + '\n')
    report = json.loads(report_path.read_bytes())
    validate(json.loads(target.read_bytes()), expected)
    assert gzip.decompress((BASE / 'advisory-original-claim.json.gz').read_bytes()) == original
    assert gzip.decompress((BASE / 'advisory-preserver-source.py.gz').read_bytes()) == Path(__file__).read_bytes()
    edited = gzip.decompress((BASE / 'advisory-edited-book.md.gz').read_bytes())
    old_book = next(row for row in verified if row['path'] == BOOK)
    assert report == dict(revision=REVISION, record=RECORD, selected_claim=NAME, verified_inputs=verified,
        changed_fields=['durability.mode', 'durability.revision'], edited_book_sha256=hashlib.sha256(edited).hexdigest(),
        original_book_sha256=old_book['sha256'], original_live_book_binding_rejects_edit=True,
        rejected_controls=controls(expected))
    assert report['edited_book_sha256'] != report['original_book_sha256']
    print(json.dumps(dict(result='PASS', original_input_count=len(verified), only_mode_revision_changed=True,
                          stale_live_book_red=True, rejected_controls=report['rejected_controls']), indent=2))


if __name__ == '__main__':
    main()

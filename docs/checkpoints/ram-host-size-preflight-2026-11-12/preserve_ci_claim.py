"""Preserve the one accepted live CI binding; default is historical review."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
REVISION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
RECORD = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'
NAME = 'backend-task-evidence-path-scope'


def expected():
    raw = subprocess.check_output(['git', 'show', REVISION + ':' + RECORD])
    original = json.loads(raw)
    result = copy.deepcopy(original)
    matches = [row for row in result['claims'] if row['name'] == NAME]
    assert len(matches) == 1
    leg = matches[0]['durability']
    assert leg['status'] == 'checked' and leg['mode'] == 'live' and 'revision' not in leg
    verified = []
    for row in leg['inputs']:
        body = subprocess.check_output(['git', 'show', REVISION + ':' + row['path']])
        assert hashlib.sha256(body).hexdigest() == row['sha256'], row['path']
        verified.append(dict(path=row['path'], bytes=len(body), sha256=row['sha256']))
    leg.update(mode='historical', revision=REVISION)
    return raw, result, verified


def validate(candidate, wanted):
    assert json.dumps(candidate, sort_keys=True) == json.dumps(wanted, sort_keys=True), 'mode/revision-only preservation'


def controls(wanted):
    names = ['statement', 'input-hash', 'omitted-input', 'wrong-revision', 'unselected-claim', 'boolean-version']
    index = next(i for i, row in enumerate(wanted['claims']) if row['name'] == NAME)
    for name in names:
        bad = copy.deepcopy(wanted)
        selected = bad['claims'][index]
        if name == 'statement':
            selected['statement'] += ' changed'
        elif name == 'input-hash':
            selected['durability']['inputs'][0]['sha256'] = '0' * 64
        elif name == 'omitted-input':
            selected['durability']['inputs'].pop()
        elif name == 'wrong-revision':
            selected['durability']['revision'] = '0' * 40
        elif name == 'unselected-claim':
            next(row for row in bad['claims'] if row['name'] != NAME)['statement'] += ' changed'
        else:
            bad['version'] = True
        try:
            validate(bad, wanted)
        except AssertionError as error:
            assert str(error) == 'mode/revision-only preservation'
        else:
            raise AssertionError('ineffective control: ' + name)
    return names


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    original, wanted, verified = expected()
    out = BASE / 'claim-preservation'
    if args.apply:
        assert Path(RECORD).read_bytes() == original
        out.mkdir()
        (out / 'original-claim.json.gz').write_bytes(gzip.compress(original, mtime=0))
        (out / 'producer.py.gz').write_bytes(gzip.compress(Path(__file__).read_bytes(), mtime=0))
        Path(RECORD).write_text(json.dumps(wanted, indent=2) + '\n')
        (out / 'result.json').write_text(json.dumps(dict(revision=REVISION, record=RECORD, selected_claim=NAME,
            changed_fields=['durability.mode', 'durability.revision'], verified_inputs=verified,
            rejected_controls=controls(wanted)), indent=2, sort_keys=True) + '\n')
    validate(json.loads(Path(RECORD).read_bytes()), wanted)
    report = json.loads((out / 'result.json').read_bytes())
    assert report == dict(revision=REVISION, record=RECORD, selected_claim=NAME,
        changed_fields=['durability.mode', 'durability.revision'], verified_inputs=verified,
        rejected_controls=controls(wanted))
    assert gzip.decompress((out / 'original-claim.json.gz').read_bytes()) == original
    assert gzip.decompress((out / 'producer.py.gz').read_bytes()) == Path(__file__).read_bytes()
    print(json.dumps(dict(result='PASS', original_inputs=len(verified), changed_fields=report['changed_fields'],
                          rejected_controls=report['rejected_controls'])))


if __name__ == '__main__':
    main()

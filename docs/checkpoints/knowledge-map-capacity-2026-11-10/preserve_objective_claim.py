"""Preserve the intersecting live audit observation before its loader evolves."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = 'f6295bc8fc76e7c6049f28397049f527fe8133d7'
NAME = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'
ARCHIVE = HERE / 'objective-original-claim.json.gz'
QUALIFICATION = (' Historical audit-producer capture is preserved at ' + BASE +
                 '; its original commands require that accepted input epoch. Later exact successor-image admission '
                 'belongs to TYPE-REFERENCE-BOOK.1.2.23.4.18.1. Original statements, results and input hashes are unchanged.')


def expected():
    original = gzip.decompress(ARCHIVE.read_bytes())
    assert subprocess.check_output(['git', 'show', BASE + ':' + NAME], cwd=ROOT) == original
    record = json.loads(original)
    result = copy.deepcopy(record)
    selected = []
    for index, claim in enumerate(record['claims']):
        leg = claim['durability']
        if leg.get('mode') != 'live' or not any(row['path'] == 'tests/language-readiness/verify_objectives.py' for row in leg.get('inputs', [])):
            continue
        for row in leg['inputs']:
            raw = subprocess.check_output(['git', 'show', BASE + ':' + row['path']], cwd=ROOT)
            assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'original input missing from accepted capture'
        result['claims'][index]['durability'].update(mode='historical', revision=BASE)
        result['claims'][index]['scope'] += QUALIFICATION
        selected.append(claim['name'])
    assert selected
    return result, selected


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    if args.write:
        assert not ARCHIVE.exists(), 'one-shot preservation'
        ARCHIVE.write_bytes(gzip.compress((ROOT / NAME).read_bytes(), mtime=0))
    record, selected = expected()
    if args.write:
        (ROOT / NAME).write_text(json.dumps(record, indent=2) + '\n')
    assert json.loads((ROOT / NAME).read_bytes()) == record
    print(json.dumps(dict(result='PASS', revision=BASE, qualified_claims=selected,
                          preservation='only selected durability mode/revision and explicit capture scope change'), sort_keys=True))

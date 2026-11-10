"""Preserve the older epoch observation before changing its live test producer."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = '5801970b4d311e97b5764d16a2573a4094144e49'
NAME = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.20.2.json'
ARCHIVE = HERE / 'epoch-fixture-original-claim.json.gz'
QUALIFICATION = ' Historical producer/input capture is preserved at ' + BASE + '; original commands require that accepted source epoch. The later catalogue-aware test-fixture repair belongs to TYPE-REFERENCE-BOOK.1.2.23.4.18.1; original statements, results and input hashes are unchanged.'


def expected():
    original = gzip.decompress(ARCHIVE.read_bytes())
    assert subprocess.check_output(['git', 'show', BASE + ':' + NAME], cwd=ROOT) == original
    record = json.loads(original)
    result = copy.deepcopy(record)
    selected = []
    for index, claim in enumerate(record['claims']):
        leg = claim['durability']
        if leg.get('mode') != 'live' or not any(row['path'] == 'tools/test_task_narrative.py' for row in leg.get('inputs', [])):
            continue
        for row in leg['inputs']:
            raw = subprocess.check_output(['git', 'show', BASE + ':' + row['path']], cwd=ROOT)
            assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'original declared input not in accepted capture'
        result['claims'][index]['durability'].update(mode='historical', revision=BASE)
        result['claims'][index]['scope'] += QUALIFICATION
        selected.append(claim['name'])
    assert selected, 'no live epoch test producer binding'
    return result, selected


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    if args.write:
        assert not ARCHIVE.exists(), 'one-shot original claim retention already exists'
        ARCHIVE.write_bytes(gzip.compress((ROOT / NAME).read_bytes(), mtime=0))
    record, selected = expected()
    if args.write:
        (ROOT / NAME).write_text(json.dumps(record, indent=2) + '\n')
    assert json.loads((ROOT / NAME).read_text()) == record
    print(json.dumps({'result': 'PASS', 'historical_revision': BASE, 'qualified_claims': selected,
                      'preservation': 'only selected durability mode/revision and explicit capture scope change'}, sort_keys=True))

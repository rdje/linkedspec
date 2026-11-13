"""Compare intake membership with the actual complete recovery population."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE=Path(__file__).resolve().parent
sealed=json.loads((BASE/'sealed-identities.json').read_bytes())
for name in ('intake/source-inventory.json','intake/inputs-before-use.tar.gz',
             'isolated-recovery/stdout.gz','isolated-recovery/inputs-before-use.tar.gz'):
    raw=(BASE/name).read_bytes()
    assert hashlib.sha256(raw).hexdigest()==sealed[name]['sha256']
intake=json.loads((BASE/'intake/source-inventory.json').read_bytes())
actual=json.loads(gzip.decompress((BASE/'isolated-recovery/stdout.gz').read_bytes()))


def population(candidate):
    rows=candidate['historical_sources']
    expected=actual['audit_report']['latest_source_inputs']
    assert len(rows)==len({row['path'] for row in rows}) and {row['path'] for row in rows}==set(expected),'exact source membership'
    assert all(row['historical_sha256']==expected[row['path']]['sha256'] for row in rows),'exact historical identity'


population(intake)
with tarfile.open(BASE/'intake/inputs-before-use.tar.gz') as archive:
    before={member.name:archive.extractfile(member).read() for member in archive}
with tarfile.open(BASE/'isolated-recovery/inputs-before-use.tar.gz') as archive:
    after={member.name:archive.extractfile(member).read() for member in archive}
protected=['tests/language-readiness/'+name for name in (
    'current-source-images.json.gz','current-source-successors.json.gz','additional-source-images.json.gz')]+['t/phase0_regression.t']
assert all(before[name]==after[name] for name in protected),'original tables and protected fixture'
selected=[row['path'] for row in intake['historical_sources'] if row['classification']=='changed-image']
assert all(before[name]==after[name] for name in selected),'admitted runtime bodies unchanged by this repair'
rejected=[]
for label in ('omitted-source','duplicated-source','wrong-historical-hash'):
    changed=copy.deepcopy(intake)
    if label=='omitted-source':changed['historical_sources'].pop()
    elif label=='duplicated-source':changed['historical_sources'].append(copy.deepcopy(changed['historical_sources'][0]))
    else:changed['historical_sources'][0]['historical_sha256']='0'*64
    try:population(changed)
    except AssertionError as error:
        assert str(error) in ('exact source membership','exact historical identity')
        rejected.append(label)
    else:raise AssertionError('ineffective population control: '+label)
print(json.dumps(dict(result='PASS',complete_source_population=len(intake['historical_sources']),
    preserved_original_tables_and_phase0=True,selected_runtime_bodies_unchanged=True,
    rejected_controls=rejected,scope='Complete named historical source set and exact byte preservation; no fresh runtime/feature admission.')))

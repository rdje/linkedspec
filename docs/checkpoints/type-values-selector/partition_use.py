"""Use the unchanged retained reviewer through the narrow logical-artifact resolver."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import required_records
import review_required
import partition_storage as storage

P = storage.P
storage.install_legacy(c, required_records.capsules)
assert storage.load('partition-copy.json')['result'] == 'PASS'
baseline = storage.load('baseline.json')
paths = set(baseline['inputs'])
paths.update(str(path.relative_to(ROOT)) for path in (ROOT / P).rglob('*') if path.is_file())
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'partition-use-inputs.json', dict(inputs=inputs,
    producer=c.read(P + 'partition_use.py'),
    scope='Original837 logical inputs plus every new partition, index and instrument '
          'are identified with modes before retained-review execution.'))
actual = review_required.review(fresh=False)
expected = json.loads((ROOT / (c.PREFIX + 'publication-required-final.json')).read_bytes())['review']
assert actual == expected
logical = 'docs/checkpoints/type-values-admission/canonical1-candidate.patch.gz'
assert storage.READS.get(logical, 0) > 0
assert all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode'))
           for path, item in inputs.items())
c.write_new(P + 'partition-use.json', dict(result='PASS', exact_prior_review=actual,
    logical_reads=dict(storage.READS), producer=c.read(P + 'partition_use.py'),
    reader=c.read(P + 'partition_storage.py'), inputs_bytes_modes_unchanged=True,
    scope='The unchanged retained reviewer checks its original observations and logical '
          'input bytes through the two-path resolver. Its entire parsed result equals the '
          'prior receipt. This is a new storage-use proof, distinct from the genuine '
          'unmodified default837 baseline captured before migration.'))
print('Retained whole review PASS through exact partitions; original result unchanged')

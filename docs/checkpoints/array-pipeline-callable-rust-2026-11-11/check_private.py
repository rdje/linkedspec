"""Compare the same-path private runtime with its matching public route image."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('phase', choices=('private-old', 'private-fixed'))
phase = parser.parse_args().phase
BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
red = phase == 'private-old'
public = 'intake' if red else 'after'


def records(body, tag):
    result = {}
    for key, row in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', body, re.M):
        assert key not in result
        result[key] = json.loads(row)
    return result


def text(folder, name):
    return gzip.decompress((BASE / folder / name).read_bytes()).decode()


actual = records(text(phase, 'normal-stderr.log.gz'), 'CALLABLE_PIPELINE_RUST_NORMAL')
expected = records(text(public, 'native-stdout.log.gz'), 'CALLABLE_PIPELINE_RUST')
assert len(actual) == len(expected) == 194
encoded = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
assert encoded(actual) == encoded(expected)
baseline = json.loads((BASE / 'baseline.json').read_bytes())
failed = set(re.findall(r'^test (\w+) \.\.\. FAILED$', text(phase, 'normal-stdout.log.gz'), re.M))
assert failed == (set(baseline['supported_targets']) | set(baseline['compatibility']) if red else set())
assert (BASE / phase / 'normal-exit.txt').read_text() == ('101\n' if red else '0\n')
inputs = records(text(phase, 'normal-stderr.log.gz'), 'CALLABLE_PIPELINE_RUST_NORMAL_INPUT')
assert inputs.keys() == actual.keys()
for key, row in inputs.items():
    assert (BASE / phase / 'normal-inputs' / (key + '.json')).read_bytes() == row['compiled'].encode()
owner = str(REL / 'control-owner/rust/linkedspec-runtime/src/engine.rs')
root = json.loads((BASE / phase / 'custody.json').read_bytes())[0]['files']
image = gzip.decompress((BASE / ('owner-before.rs.gz' if red else 'repair-run/owner-after.rs.gz')).read_bytes())
assert root[owner]['sha256'] == hashlib.sha256(image).hexdigest()
print(json.dumps(dict(private_image=phase, matching_public=public, complete_records=194,
    serialized_inputs=194, failures=len(failed), same_control_path=owner,
    owner_sha256=hashlib.sha256(image).hexdigest()), indent=2))

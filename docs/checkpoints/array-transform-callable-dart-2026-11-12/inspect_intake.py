"""Recover complete cold Dart error wires and source-bound observation pairs."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)

def frames(stream, tag, decoded=True):
    raw = gzip.decompress((BASE / 'intake' / stream).read_bytes()).decode()
    result = {}
    for key, body in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', raw, re.M):
        assert key not in result
        result[key] = json.loads(body) if decoded else body.encode()
    return result

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

assert (BASE / 'launches/intake/exit.txt').read_text() == '0\n'
cases = json.loads((BASE / 'cases.json').read_bytes())
assert cases == json.loads((BASE / 'intake/cases.json').read_bytes())
native = frames('native-stdout.log.gz', 'CALLABLE_TRANSFORM_DART')
fresh = frames('fresh-stdout.log.gz', 'CALLABLE_TRANSFORM_DART_FRESH')
inputs = frames('native-stdout.log.gz', 'CALLABLE_TRANSFORM_DART_INPUT', False)
assert len(cases) == len(native) == len(fresh) == len(inputs) == 312
observed = {}
for case in cases:
    key = case['id']
    assert set(native[key]) == {'native', 'restored', 'plan'}, key
    observed[key] = dict(native[key], fresh=fresh[key])
packet = next(row for row in json.loads((BASE / 'intake/custody.json').read_bytes()) if row['tag'] == 'emitted')
members = {}
with tarfile.open(ROOT / packet['archive']) as archive:
    assert set(archive.getnames()) == packet['files'].keys()
    for member in archive:
        raw = archive.extractfile(member).read()
        row = packet['files'][member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
        members[member.name] = raw
for index, case in enumerate(cases):
    assert members[str(REL / 'intake/fresh/inputs' / ('case_' + str(index) + '.json'))] == inputs[case['id']]
    assert str(REL / 'intake/fresh/lib' / ('case_' + str(index) + '.dart')) in members
healthy, differences, profiles = [], {}, {}
for case in cases[:45]:
    key = case['id']
    if case.get('profile_only'):
        profiles[key] = observed[key]
    elif 'expected' in case:
        ok = all(encoded(row) == encoded({'value': case['expected']}) for row in observed[key].values())
        if ok:
            healthy.append(key)
        else:
            differences[key] = observed[key]
    else:
        assert 'expected_error' in case
        ok = all(case['expected_error'] in row.get('error', '') for row in observed[key].values())
        if ok:
            healthy.append(key)
        else:
            differences[key] = observed[key]
groups = {}
for case in cases[45:]:
    groups.setdefault(case['question'], {})[case['id']] = observed[case['id']]
report = dict(programs=312, parsed_module_pairs=312, shared_healthy=healthy,
    shared_differences=differences, shared_profiles=profiles, own_groups=groups,
    observed=observed, limits='Own policies remain questions until contract and terminal contrasts establish targets. Complete available error_json/class/string fields are retained; no peer verdict or portable initial-input authority follows.')
target = BASE / 'intake-assessment.json'
assert not target.exists()
target.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(programs=312, parsed_module_pairs=312, shared_healthy=len(healthy),
    shared_differences=list(differences), shared_profiles=len(profiles),
    own_questions=sum(map(len, groups.values())), limits=report['limits']), indent=2))

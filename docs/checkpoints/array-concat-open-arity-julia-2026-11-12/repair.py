"""Apply the own reproduced result-arity repair and exact legacy profile transfers."""
import copy
import difflib
import gzip
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '952f8a022c59a478614ba1413e0e36e49e7e14e8'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert (BASE / 'launches/before/exit.txt').read_text() == '0\n'
assert (BASE / 'before/normal-exit.txt').read_text() == '1\n'
out = BASE / 'repair-run'
out.mkdir()
owner = Path('julia/src/runtime/Interpreter.jl')
runner = Path('julia/test/runtests.jl')
legacy = Path('tests/fixtures/array_transform_callable_result_guard_julia_profiles.json')
ordinary = Path('tests/fixtures/array_transform_result_guard_julia_profiles.json')
paths = (owner, runner, legacy, ordinary)
before = {}
for path in paths:
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    before[path] = body
old = b'    return helper == "concat_arrays" && count == 2\n'
new = b'    return helper == "concat_arrays" && count >= 1\n'
assert before[owner].count(old) == 1
include = b'include("array_transform_callable_result_guard_composition_test.jl")\n'
addition = b'include("array_concat_open_arity_result_guard_composition_test.jl")\n'
assert before[runner].count(include) == 1 and addition not in before[runner]
after = {owner: before[owner].replace(old, new, 1), runner: before[runner].replace(include, include + addition, 1)}
profiles = {row['id']: row['expected'] for row in json.loads(Path('tests/fixtures/array_concat_open_arity_result_guard_julia_profiles.json').read_bytes())}
baseline = json.loads((BASE / 'baseline.json').read_bytes())
assert set(baseline['legacy_operand_compatibility']) == {
    'own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver',
    'ordinary_legacy_extra_concat_arrays_free_composed', 'ordinary_legacy_extra_concat_arrays_receiver_composed'}
previous_legacy = json.loads(before[legacy])
next_legacy = copy.deepcopy(previous_legacy)
transferred = set()
for row in next_legacy:
    key = row['id']
    if key in ('own_extra_concat_arrays_free', 'own_extra_concat_arrays_receiver'):
        assert row['expected'] == baseline['observed'][key]
        row['expected'] = profiles[key]
        transferred.add(key)
assert len(transferred) == 2
for prior, current in zip(previous_legacy, next_legacy):
    comparison = copy.deepcopy(current)
    if current['id'] in transferred:
        comparison['expected'] = prior['expected']
    assert comparison == prior, 'all other legacy metadata/objects stay exact'
previous_ordinary = json.loads(before[ordinary])
next_ordinary = copy.deepcopy(previous_ordinary)
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    question = 'ordinary_legacy_' + key + '_composed'
    assert {route: next_ordinary[key][route] for route in profiles[question]} == baseline['observed'][question]
    next_ordinary[key].update(profiles[question])
    comparison = copy.deepcopy(next_ordinary[key])
    comparison.update({route: previous_ordinary[key][route] for route in profiles[question]})
    assert comparison == previous_ordinary[key], 'ordinary source/metadata unchanged'
assert {key: row for key, row in next_ordinary.items() if key not in ('extra_concat_arrays_free', 'extra_concat_arrays_receiver')} == {
    key: row for key, row in previous_ordinary.items() if key not in ('extra_concat_arrays_free', 'extra_concat_arrays_receiver')}
after[legacy] = (json.dumps(next_legacy, indent=2) + '\n').encode()
after[ordinary] = (json.dumps(next_ordinary, indent=2, sort_keys=True) + '\n').encode()

for tag, images in (('before', before), ('after', after)):
    rows = {}
    with tarfile.open(out / (tag + '.tar.gz'), 'x:gz') as archive:
        for path, body in images.items():
            member = tarfile.TarInfo(str(path))
            member.size = len(body)
            member.mode = path.stat().st_mode & 0o777
            archive.addfile(member, io.BytesIO(body))
            rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode)
    with tarfile.open(out / (tag + '.tar.gz')) as archive:
        assert len(archive.getnames()) == len(rows) and set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read()
            assert len(body) == rows[member.name]['bytes'] and hashlib.sha256(body).hexdigest() == rows[member.name]['sha256']
            assert member.mode & 0o777 == rows[member.name]['mode']
    (out / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(BASE / 'owner-after.jl.gz').write_bytes(gzip.compress(after[owner], mtime=0))
(BASE / 'runner-after.jl.gz').write_bytes(gzip.compress(after[runner], mtime=0))
patch = ''.join(''.join(difflib.unified_diff(before[path].decode().splitlines(True), after[path].decode().splitlines(True),
    fromfile=str(path), tofile=str(path))) for path in (owner, runner))
(BASE / 'source.diff').write_text(patch)
for path in paths:
    assert path.read_bytes() == before[path]
    mode = path.stat().st_mode & 0o777
    path.write_bytes(after[path])
    assert path.read_bytes() == after[path] and path.stat().st_mode & 0o777 == mode
(out / 'result.json').write_text(json.dumps(dict(owner_lines='one existing-signature selector line',
    runner_includes=1, legacy_expected_objects=2, ordinary_route_objects=2,
    limits='Only four separately acquired compatibility route projections transfer. Terminal scalar elements, source/metadata and all other profiles remain; no new scalar-input authority, producer/signature/format change.'), indent=2) + '\n')
print('Applied one concat result guard line/one runner include and exact four legacy continuation profile transfers')

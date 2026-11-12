"""Preserve the unexecuted first proposal and prepare qualified partial-run recovery."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
source = (BASE / 'review.py').read_text()
assert not (BASE / 'review_qualified.py').exists()
(BASE / 'review-unexecuted-proposal.py.gz').write_bytes(gzip.compress(source.encode(), mtime=0))
source = source.replace('import tarfile\n', 'import tarfile\nimport sys\nimport review_ordinary_qualified\n')
# -P deliberately excludes the script directory; explicitly add only this owned
# retained helper directory before importing the independent recovery helper.
source = source.replace('import review_ordinary_qualified\n', '')
anchor = 'REL = BASE.relative_to(ROOT)\n'
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + 'sys.path.insert(0, str(BASE))\nimport review_ordinary_qualified\n', 1)
anchor = 'selected = {OWNER, NORMAL, CASES, PROFILE, OLD_PROFILE}'
assert source.count(anchor) == 1
source = source.replace(anchor, anchor[:-1] + ", 'tests/fixtures/array_transform_result_guard_rust_profiles.json', 'tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json'}", 1)
anchor = '    data = {phase: recover(phase) for phase in phases}\n'
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + "    data['direct'].update(recover('direct-completion'))\n", 1)
anchor = "expected_exit = '101\\n' if tag == 'normal' and phase in ('before', 'private-old') else '0\\n'"
assert source.count(anchor) == 1
source = source.replace(anchor, "expected_exit = '101\\n' if (tag == 'normal' and phase in ('before', 'private-old')) or (phase == 'direct' and tag == 'array_transform_result_guard_composition') else '0\\n'", 1)
start = source.index("    for test, count in (('array_transform_result_guard_composition'")
end = source.index('    controls = []', start)
source = source[:start] + '    ordinary_old, ordinary_final, ordinary_expected = review_ordinary_qualified.review(sys.modules[__name__], data, original_root, fixed_root)\n' + source[end:]
anchor = "    print(json.dumps(dict(readonly='PASS'"
assert source.count(anchor) == 1
extra = '''    bad = copy.deepcopy(ordinary_final)
    key = next(key for key in bad if key not in ('extra_concat_arrays_free', 'extra_concat_arrays_receiver'))
    bad[key]['native'] = {'value': None}
    reject('ordinary unrelated transfer', lambda: same(bad, ordinary_expected, 'ordinary profile transfer'), 'ordinary profile transfer')
'''
source = source.replace(anchor, extra + anchor, 1)
source = source.replace('private_current=504, direct=1205,', 'private_current=504, direct=1205, original_direct_exit=1, original_ordinary_passed=193, qualified_ordinary=2, qualified_missing_checks=508,')
compile(source, 'review_qualified.py', 'exec')
(BASE / 'review_qualified.py').write_text(source)
current = (BASE / 'check_current.py').read_text()
current = current.replace("BASE / 'direct/custody.json'", "BASE / 'qualified-direct/custody.json'")
(BASE / 'check_current_qualified.py').write_text(current)
print('Qualified reader preserves original direct1/ordinary193+2 and completed504 snapshots, then requires only missing508 checks; original proposal never executed')

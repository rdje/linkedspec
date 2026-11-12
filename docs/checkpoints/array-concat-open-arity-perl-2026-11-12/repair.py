"""Rehearse/apply the existing-signature result role and exact legacy profile transfer."""
import difflib
import gzip
import json
import os
from pathlib import Path
import stat
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
LEGACY = Path('tests/fixtures/array_transform_callable_result_guard_perl_cases.json')
LEGACY_NORMAL = Path('t/array_transform_callable_result_guard_composition.t')
assert sys.argv[1:] in (['--rehearse'], ['--apply'])
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'b15ca562e8044d9a8a369e613926bf016598f708'
check = json.loads((BASE / 'before-check.json').read_bytes())
assert check['full_wire_records'] == 'PASS' and check['old_failed_groups'] == 28
old = b'''# Ordinary Array transforms retain their existing producers and optional arities.
'''
new = b'''# Ordinary Array transforms retain their existing producers and accepted arities.
'''
old_bounds = b''' my $minimum = ($method eq 'slice' || $method eq 'concat_arrays') ? 2 : 1;
 my $maximum = $method eq 'slice' ? 3 : ($method eq 'sorted' || $method eq 'reversed') ? 1 : 2;
 return 0 if $count < $minimum || $count > $maximum;
'''
new_bounds = b''' my $minimum = $method eq 'slice' ? 2 : 1;
 my $maximum = $method eq 'concat_arrays' ? undef
  : $method eq 'slice' ? 3 : ($method eq 'sorted' || $method eq 'reversed') ? 1 : 2;
 return 0 if $count < $minimum || (defined($maximum) && $count > $maximum);
'''
before = subprocess.check_output(['git', 'show', 'b15ca562e8044d9a8a369e613926bf016598f708:' + str(OWNER)])
assert before.count(old) == before.count(old_bounds) == 1
after = before.replace(old, new).replace(old_bounds, new_bounds)
changes = {
    OWNER: (before, after),
    LEGACY: tuple(gzip.decompress((BASE / ('legacy-fixture-' + phase + '.json.gz')).read_bytes()) for phase in ('before', 'after')),
    LEGACY_NORMAL: tuple(gzip.decompress((BASE / ('legacy-normal-' + phase + '.t.gz')).read_bytes()) for phase in ('before', 'after')),
}
for path, (original, desired) in changes.items():
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    assert path.read_bytes() == original
    assert original != desired
if sys.argv[1] == '--rehearse':
    for phase, body in (('before', before), ('after', after)):
        target = BASE / ('owner-' + phase + '.pm.gz')
        assert not target.exists()
        target.write_bytes(gzip.compress(body, mtime=0))
        assert gzip.decompress(target.read_bytes()) == body
    diff = ''.join(''.join(difflib.unified_diff(original.decode().splitlines(True), desired.decode().splitlines(True),
        fromfile=str(path), tofile=str(path))) for path, (original, desired) in changes.items())
    (BASE / 'source-and-profile.diff').write_text(diff)
    print('Rehearsed only concat result-role bounds and exact two-profile transfer/diagnostic label; root unchanged')
else:
    assert gzip.decompress((BASE / 'owner-before.pm.gz').read_bytes()) == before
    assert gzip.decompress((BASE / 'owner-after.pm.gz').read_bytes()) == after
    prepared = []
    for path, (original, desired) in changes.items():
        temporary = path.with_name(path.name + '.concat-new')
        assert not temporary.exists() and not temporary.is_symlink()
        mode = stat.S_IMODE(path.stat().st_mode)
        with temporary.open('xb') as stream:
            stream.write(desired)
        temporary.chmod(mode)
        assert temporary.read_bytes() == desired
        prepared.append((temporary, path, mode, desired))
    for temporary, path, mode, desired in prepared:
        os.replace(temporary, path)
        assert path.read_bytes() == desired and stat.S_IMODE(path.stat().st_mode) == mode
    print('Applied existing-signature concat result-role bounds/two disclosed profiles/diagnostic label; producers unchanged')

"""Prepare a separate reader for retained original and qualified proof epochs."""
import ast
from pathlib import Path

BASE = Path(__file__).resolve().parent
target = BASE / 'review_qualified.py'
assert not target.exists()
source = (BASE / 'review.py').read_text()

def change(old, new):
    global source
    assert source.count(old) == 1, old[:100]
    source = source.replace(old, new, 1)

anchor = 'def main():\n'
warning = '''def warning_channels(native_before, native_after, fresh_before, fresh_after):
    assert native_before == native_after == b'', 'native warning channel'
    notice = b'tools/project_data_run.sh: child setpgid (43473 to 43473): Operation not permitted\\n'
    assert fresh_before == notice and fresh_after == b'', 'launcher warning channel'

'''
change(anchor, warning + anchor)
change('''            for name in (NORMAL, CASES, PROFILE):
                assert root['bodies'][name] == candidate['bodies'][name]
''', '''            for name in (NORMAL, CASES):
                assert root['bodies'][name] == candidate['bodies'][name]
            expected_profile = data['direct']['root']['bodies'][PROFILE] if phase in ('private-old', 'private-fixed', 'direct') else candidate['bodies'][PROFILE]
            assert root['bodies'][PROFILE] == expected_profile
''')
change("cases, profiles = json.loads(candidate['bodies'][CASES]), json.loads(candidate['bodies'][PROFILE])", "cases, profiles = json.loads(candidate['bodies'][CASES]), json.loads(data['direct']['root']['bodies'][PROFILE])")
change("    assert len(red) == 20 and len(preserved) == 292 and red | preserved == profiles.keys()\n", '''    compatibility = {key for key, row in profiles.items() if row['role'] == 'initial-source-compatibility'}
    all_red = red | compatibility
    assert len(red) == 20 and len(compatibility) == 3 and len(preserved) == 289
    assert all_red | preserved == profiles.keys()
    assert compatibility == {'initial_' + kind + '_composed' for kind in ('number', 'null', 'hash')}
    original_profile = json.loads(candidate['bodies'][PROFILE])
    assert candidate['bodies'][PROFILE] == raw('profiles-original.json.gz')
    assert sum(row['role'] == 'supported-target' for row in original_profile.values()) == 20
    assert sum(row['role'] == 'preservation' for row in original_profile.values()) == 292
    corrected = copy.deepcopy(original_profile)
    for key in compatibility:
        assert corrected[key]['role'] == 'preservation'
        corrected[key]['role'] = 'initial-source-compatibility'
        for route in ROUTES:
            assert corrected[key][route] == {'value': ['ran', 'KVW']}
            corrected[key][route] = {'value': [None, '']}
    same(corrected, profiles)
    qualified_baseline = json.loads((BASE / 'baseline-qualified.json').read_bytes())
    assert set(qualified_baseline['initial_source_compatibility']) == compatibility and qualified_baseline['preserved'] == 289
    initial_ids = [case['id'] for case in cases if case.get('question') in ('initial-terminal', 'initial-first-with')]
    assert len(initial_ids) == 96 and all(encoded(before[key]) == encoded(after[key]) for key in initial_ids)
    qualification = BASE / 'initial-qualification'
    identities = json.loads((qualification / 'input-identities.json').read_bytes())
    with tarfile.open(qualification / 'inputs-before-use.tar.gz') as archive:
        assert set(archive.getnames()) == identities.keys()
        for member in archive:
            body, row = archive.extractfile(member).read(), identities[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256'] and member.mode & 0o777 == row['mode']
            if member.name == PROFILE:
                assert body == candidate['bodies'][PROFILE]
            elif member.name == OWNER:
                assert body == current
            elif member.name == NORMAL:
                assert body == candidate['bodies'][NORMAL]
    for tag in ('check-after', 'diagnose-initial', 'check-after-qualified'):
        assert (BASE / 'launches' / tag / 'exit.txt').read_text() == '1\\n'
        assert raw('launches/' + tag + '/stdout.log.gz') == b''
        assert b'AssertionError' in raw('launches/' + tag + '/stderr.log.gz')
    for tag in ('diagnose-initial-qualified', 'qualify-initial', 'check-after-qualified2'):
        assert (BASE / 'launches' / tag / 'exit.txt').read_text() == '0\\n'
        assert raw('launches/' + tag + '/stderr.log.gz') == b''
    assert b'initial_hash_composed' in raw('launches/check-after/stderr.log.gz')
    diagnosis = json.loads((BASE / 'initial-policy-diagnosis-qualified.json').read_bytes())
    assert diagnosis['initial_policies_exact'] == 96 and set(diagnosis['unexpected_three']) == compatibility
''')
change("== (key in red)\n", "== (key in all_red)\n")
change('''    for channel in ('native-stderr.log.gz', 'fresh-stderr.log.gz'):
        assert raw('intake/' + channel) == raw('after/' + channel)
''', '''    warning_channels(raw('intake/native-stderr.log.gz'), raw('after/native-stderr.log.gz'),
        raw('intake/fresh-stderr.log.gz'), raw('after/fresh-stderr.log.gz'))
''')
change("('private-old', before, red), ('private-fixed', after, set())", "('private-old', before, all_red), ('private-fixed', after, set())")
change("        ('late with executes', 'take_later_with', {'value': ['ran', 'KVW']}),", "        ('late with executes', 'take_later_with', {'value': ['ran', 'KVW']}),\n        ('initial compatibility continuation revived', 'initial_hash_composed', {'value': ['ran', 'KVW']}),")
anchor = "    return dict(recovery='PASS', programs=312, routes=4, supported_targets=20, preserved=292,\n"
addition = '''    notice = raw('intake/fresh-stderr.log.gz')
    reject('original launcher notice silently dropped', lambda: warning_channels(b'', b'', b'', b''), 'launcher warning channel')
    reject('extra fresh runtime stderr hidden', lambda: warning_channels(b'', b'', notice + b'new runtime warning\\n', b''), 'launcher warning channel')
    reject('native warning hidden', lambda: warning_channels(b'new runtime warning\\n', b'', notice, b''), 'native warning channel')
'''
change(anchor, addition + "    return dict(recovery='PASS', programs=312, routes=4, supported_targets=20, separate_initial_compatibility=3, preserved=289,\n")
change("limits='Finite authored semantic/source-order proof.", "limits='Original normal20RED/292PASS and comparison1/diagnostic1/first qualified comparison1 remain retained. Qualified inverse23RED includes20 targets plus three off-contract initial continuation changes;96 initial producer/first-with records stay exact. Original exact83-byte known wrapper notice and repaired empty stderr are guarded without suppression; original PGID unobserved/SESSION7 open. Finite authored semantic/source-order proof.")
ast.parse(source, filename=str(target))
target.write_text(source)
print('Prepared separate qualified historical reader; original proposed reader remains unexecuted and unchanged')

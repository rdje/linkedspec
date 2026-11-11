"""Prepare the new readonly transform reader before its first execution."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
source = gzip.decompress((BASE / 'template-11.gz').read_bytes()).decode()
source = source.replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform')
source = source.replace('9ed018787cac456a0e0bf95942bcdb735f5e4e6c', '5ac1fac5eb7126cd8f952858f8df194914884830')
source = source.replace("'+175 -19: Some tests failed.'", "'+281 -31: Some tests failed.'")
source = source.replace("'+383: All tests passed!'", "'+647: All tests passed!'")
source = source.replace("'+194: All tests passed!'", "'+312: All tests passed!'")
source = source.replace('== 194', '== 312').replace('cases[:37]', 'cases[:45]')
source = source.replace('pattern-compatibility', 'initial-source-compatibility')
source = source.replace("'supported-target': 16", "'supported-target': 28").replace("'preservation': 175", "'preservation': 281")
source = source.replace("baseline['compatibility']", "baseline['initial_source_compatibility']")
source = source.replace('assert len(traced) == 7', 'assert len(traced) == 9')
start = source.index('    for name in (NORMAL, PROFILE, PROBE, OBS, GRAMMAR,')
end = source.index('    old_private =', start)
source = source[:start] + '''    for name in (NORMAL, PROFILE, PROBE, OBS, GRAMMAR, str(REL / 'cases.json'),
        'dart/test/array_transform_result_guard_composition_test.dart',
        'docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json',
        'tests/fixtures/array_transform_result_guard_dart_profiles.json',
        'dart/test/array_pipeline_callable_result_guard_composition_test.dart',
        'docs/checkpoints/array-pipeline-callable-dart-2026-11-11/cases.json',
        'tests/fixtures/array_pipeline_callable_result_guard_dart_profiles.json'):
        assert name in data['direct']['root'], 'direct fixture closure'
''' + source[end:]
start = source.index('    legacy = json.loads(')
end = source.index('    controls = []', start)
source = source[:start] + '''    initial = [case['id'] for case in cases if case.get('question') in (
        'initial-terminal', 'initial-first-with', 'additional-source-kind', 'additional-source-kind-first-with')]
    assert len(initial) == 104 and all(same(before[key], after[key]) for key in initial)
    assert after['own_scalar_bool_receiver_with']['native'] == {'value': [None, '']}
    assert after['own_scalar_bool_free_with']['native'] == {'value': [0, 'W']}
    for phase in ('intake', 'before', 'after', 'direct'):
        grammar = json.loads((BASE / phase / 'default-grammar-resolution.json').read_bytes())
        assert grammar['nearer_candidate_exists'] is False and grammar['selected'] == GRAMMAR
        assert grammar['selected_sha256'] == hashlib.sha256(original[GRAMMAR]).hexdigest()

    # Gate every actual launcher input and producer, including analysis/repair
    # and evidence-generating scripts, rather than just the final runtime body.
    for folder in sorted((BASE / 'launches').iterdir()):
        rows = json.loads((folder / 'identities.json').read_bytes())
        recovered = recover_archive(folder / 'inputs.tar.gz', rows)
        record = json.loads((folder / 'command.json').read_bytes())
        assert record['cwd'] == '.' and record['environment'] == {}
        producers = [name for name in record['argv'] if name.endswith('.py')]
        assert producers and all(name in recovered for name in producers)
        for name in producers:
            assert recovered[name] == (ROOT / name).read_bytes(), 'actual producer changed'
        assert (folder / 'exit.txt').read_text() == '0\\n'
        stderr = gzip.decompress((folder / 'stderr.log.gz').read_bytes())
        if folder.name == 'check-after':
            notice = json.loads((BASE / 'launcher-notice.json').read_bytes())
            check_notice(stderr, notice)
        else:
            assert stderr == b'', 'unexpected actual outer stderr'
    assert (BASE / 'remaining/complete.txt').is_file()
    for phase in ('private-old', 'private-fixed', 'direct'):
        for suffix in ('', '-memory'):
            assert (BASE / 'remaining' / (phase + suffix + '-exit.txt')).read_text() == '0\\n'
            assert raw('remaining/' + phase + suffix + '-stderr.log.gz') == b''
    retired = json.loads((BASE / 'retired-live-copies.json').read_bytes())
    assert len(retired) == 642
    for row in retired:
        assert not (ROOT / row['path']).exists()
        packet = next(p for p in json.loads((BASE / row['phase'] / 'custody.json').read_bytes()) if p['tag'] == row['tag'])
        assert row['identity'] == packet['files'][row['path']]
        assert row['archive'] == packet['archive']

''' + source[end:]
start = source.index('    for label, key, result in (')
end = source.index('    changed = copy.deepcopy(after)\n    changed[', start)
source = source[:start] + '''    for label, key, result in (
        ('receiver Hash operands execute', 'take_receiver_hash_guard', {'value': [None, 'KV']}),
        ('later with evaluates', 'take_later_with', {'value': ['ran', 'W']}),
        ('source S is lost', 'own_source_before_rejection', {'value': [None, '']}),
        ('count N is lost', 'positive_take_receiver_terminal', {'value': [[], 'S']}),
        ('slice C is lost', 'positive_slice_receiver_terminal', {'value': [[], 'SN']}),
        ('concat T is lost', 'positive_concat_arrays_receiver_terminal', {'value': [[], 'S']}),
        ('valid empty Array skips first with', 'initial_number_take_receiver_with', {'value': [None, '']}),
        ('Boolean receiver adopts free empty policy', 'own_scalar_bool_receiver_with', {'value': [0, 'W']}),
        ('excluded free X evaluated', 'extra_sorted_free', {'value': ['ran', 'SXKVW']}),
        ('function signature error masked', 'own_signature_fixed_missing_composed', {'value': [None, '']}),
        ('needed source error masked', 'own_needed_source_take_receiver', {'value': 'masked'}),
        ('Boolean becomes Number', 'nested_scalar_kinds', {'value': [[0, None, ''], [False, 0, None, '0', '']]}),
    ):
        changed = copy.deepcopy(after); assert key in changed
        changed[key] = {route: result for route in ROUTES}
        reject(label, lambda: validate(changed, profiles))
''' + source[end:]
source = source.replace("needed_source_trim_each_receiver", "own_needed_source_take_receiver")
source = source.replace("    reject('historical restore-before-persist promoted', lambda: retained_first(sources[0]))\n", '''    late = original[PROBE].replace(b'inputFile.readAsStringSync()', b'inputFile.readAsStringSync_REPLACED()', 1)
    reject('parsed snapshot readback removed', lambda: retained_first(late))
    changed = copy.deepcopy(after)
    del changed['own_needed_source_take_receiver']['plan']['error_json']['stage']
    reject('available error field dropped', lambda: validate(changed, profiles))
    changed = copy.deepcopy(after)
    changed['own_needed_source_take_receiver']['native']['error_json']['invented'] = True
    reject('absent error field invented', lambda: validate(changed, profiles))
    reject('outer launcher notice suppressed', lambda: check_notice(b'', notice))
    reject('actual Dart stderr hidden', lambda: require_same(raw('after/native-stderr.log.gz') + b'warning', b''))
''')
start = source.index('    return dict(recovery=')
end = source.index("\n\n\nif __name__", start)
source = source[:start] + '''    return dict(recovery='PASS', programs=len(cases), routes=4, supported_targets=28,
        separate_initial_compatibility=3, preserved=281, initial_policies=104,
        parsed_module_pairs=2 * len(cases), normal_parsed_inputs=4 * len(cases),
        traced_parsed_inputs=len(traced), direct_groups=647, effective_corruptions=controls,
        limits='Finite authored full-wire controls only. Three initial-source continuations are separate compatibility; Boolean receiver-null/free-empty stays exact. Actual outer launcher83-byte notice retained under SESSION7, final PGID uncaptured. No full native/VM/cache/transitive/toolchain/OS4.2/SESSION5, historical4.24, context/isolation/registration/declared5.4/full23.4 admission.')
''' + source[end:]
helpers = '''
def recover_archive(path, identities):
    recovered = {}
    with tarfile.open(path) as archive:
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in recovered
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            recovered[member.name] = body
    assert recovered.keys() == identities.keys()
    return recovered


def check_notice(stderr, row):
    assert len(stderr) == row['bytes'] == 83 and hashlib.sha256(stderr).hexdigest() == row['sha256']
    pid = row['observed_child_pid']
    assert stderr == f'tools/project_data_run.sh: child setpgid ({pid} to {pid}): Operation not permitted\\n'.encode()
    assert row['original_final_pgid'] == 'uncaptured' and row['actual_comparator_exit'] == 0

'''
source = source.replace('\ndef main():', helpers + '\ndef main():', 1)
# Git stores only the executable class. Full filesystem permissions have their
# own archived field; never substitute Git's normalized 644/755 for that field.
source = source.replace('                git_names.add(member.name)', '''                row = next(p for p in json.loads((BASE / 'intake/custody.json').read_bytes()) if p['tag'] == 'root')['files'][member.name]
                assert bool(row['mode'] & 0o111) == bool(member.mode & 0o111)
                git_names.add(member.name)''')
target = BASE / 'review.py'
assert not target.exists()
target.write_text(source)
current = BASE / 'check_current.py'
current.write_text(current.read_text().replace('trace_callable_array_pipeline_results', 'trace_callable_array_transform_results'))
print('Prepared independent transform reader and activation-only current identity reader; neither executed')

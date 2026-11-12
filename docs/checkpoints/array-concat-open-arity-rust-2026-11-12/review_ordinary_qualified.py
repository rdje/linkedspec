"""Independent exact ordinary qualification and missing-check recovery helpers."""
import copy
import gzip
import json
from pathlib import Path
import re


def review(core, data, original_root, fixed_root):
    base, rel = core.BASE, core.REL
    ordinary = 'tests/fixtures/array_transform_result_guard_rust_profiles.json'
    pipeline = 'tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json'
    old_profile = json.loads(original_root['bodies'][ordinary])
    qualified = core.recover('qualified-direct'); root = qualified['root']
    final_profile = json.loads(root['bodies'][ordinary])
    expected = copy.deepcopy(old_profile)
    for form in ('free', 'receiver'):
        for route in core.ROUTES:
            expected['extra_concat_arrays_' + form][route] = {'value': [None, 'SX']}
    core.same(final_profile, expected, 'ordinary profile transfer')
    observations = {}
    phases = ('ordinary-old', 'ordinary-fixed')
    probes = {phase: core.recover(phase) for phase in phases}
    for phase in phases:
        observations[phase] = core.routes(phase)
        assert len(observations[phase]) == 4, 'ordinary probe census'
        stdout = core.raw(phase + '/native-stdout.log.gz')
        for directory, tag, field in (
            ('parsed-inputs', 'ARRAY_CONCAT_RUST_PARSED_INPUT', 'parsed'),
            ('inputs', 'ARRAY_CONCAT_RUST_INPUT', 'compiled'),
        ):
            rows = core.frames(stdout, tag)
            assert rows.keys() == observations[phase].keys(), 'ordinary snapshot census'
            for key, row in rows.items():
                assert probes[phase]['fresh-source']['bodies'][str(rel / phase / 'fresh' / directory / (key + '.json'))] == row[field].encode(), 'ordinary public snapshot'
        for path in (base / phase).glob('*-command.json'):
            tag = path.name.removesuffix('-command.json')
            assert path.with_name(tag + '-exit.txt').read_text() == '0\n', 'ordinary probe exit'
            if tag in ('native', 'fresh'):
                assert core.raw(phase + '/' + tag + '-stderr.log.gz') == b'', 'ordinary SDK stderr'
                executable = str(rel / phase / (tag + '-exec'))
                command = json.loads(path.read_bytes())
                assert command['argv'][:3] == ['bash', 'tools/project_data_run.sh', executable]
                assert executable in probes[phase][tag + '-product']['files'], 'ordinary executed product'
    tail = '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")}'
    cases = json.loads((base / 'ordinary-cases.json').read_bytes())
    for form in ('free', 'receiver'):
        key = 'extra_concat_arrays_' + form
        for kind in ('terminal', 'composed'):
            row, = [row for row in cases if row['id'] == key + '_' + kind]
            assert old_profile[key]['source'].count(tail) == 1
            assert row['source'] == (old_profile[key]['source'].replace(tail, '', 1) if kind == 'terminal' else old_profile[key]['source']), 'ordinary exact source'
            assert row['input'] == old_profile[key]['input'] and row['rule'] == 'Value'
            for folder, suffix in (('parsed-inputs', '.json'), ('inputs', '.json'), ('src/generated', '.rs')):
                left = str(rel / 'ordinary-old/fresh' / folder / (row['id'] + suffix))
                right = str(rel / 'ordinary-fixed/fresh' / folder / (row['id'] + suffix))
                core.pair(probes['ordinary-old']['fresh-source']['bodies'][left], probes['ordinary-fixed']['fresh-source']['bodies'][right])
        terminal = {route: {'value': [['b', 'a', 'z', 1], 'SX']} for route in core.ROUTES}
        core.same(observations['ordinary-old'][key + '_terminal'], terminal, 'ordinary original terminal')
        core.same(observations['ordinary-fixed'][key + '_terminal'], terminal, 'ordinary current terminal')
        core.same(observations['ordinary-old'][key + '_composed'], {route: old_profile[key][route] for route in core.ROUTES}, 'ordinary original composed')
        core.same(observations['ordinary-fixed'][key + '_composed'], {route: expected[key][route] for route in core.ROUTES}, 'ordinary current composed')
    prefix = str(rel / 'ordinary-qualification-owner') + '/'
    old, fixed = probes['ordinary-old']['root'], probes['ordinary-fixed']['root']
    names = {name for name in old['files'] if name.startswith(prefix)}
    assert names == {name for name in fixed['files'] if name.startswith(prefix)}, 'ordinary same-path census'
    for name in names:
        if name == prefix + core.OWNER:
            assert old['bodies'][name] == original_root['bodies'][core.OWNER]
            assert fixed['bodies'][name] == fixed_root['bodies'][core.OWNER]
        else:
            core.same(old['files'][name], fixed['files'][name], 'ordinary same-path input')
    retired = json.loads((base / 'retired-qualified.json').read_bytes())
    targets = [str(rel / 'direct' / name) for name in ('normal-exec', 'array_transform_result_guard_composition-exec')]
    targets += [str(rel / phase / name) for phase in phases for name in ('native', 'fresh', 'native-exec', 'fresh-exec')]
    targets += [str(rel / 'ordinary-qualification-owner')]
    assert retired['targets'] == targets, 'qualified retirement targets'
    archived = {}
    for collection in (data['direct'], probes['ordinary-old'], probes['ordinary-fixed']):
        for packet in collection.values():
            archived.update(packet['files'])
    selected = {name: row for name, row in archived.items() if any(name == target or name.startswith(target + '/') for target in targets)}
    core.same(retired['files'], selected, 'qualified retirement coverage')
    # The original failed ordinary normal reached all195; its two failures are kept.
    test = 'array_transform_result_guard_composition'
    stdout = core.raw('direct/' + test + '-stdout.log.gz')
    failed = {key.decode() for key in re.findall(rb'^test (\w+) \.\.\. FAILED$', stdout, re.M)}
    assert failed == {'extra_concat_arrays_free', 'extra_concat_arrays_receiver'} and b'193 passed; 2 failed' in stdout, 'original ordinary RED'
    normal = core.frames(core.raw('direct/' + test + '-stderr.log.gz'), 'ARRAY_TRANSFORM_RUST_NORMAL')
    assert len(normal) == 195, 'original ordinary normal census'
    for key, profile in old_profile.items():
        expected_row = {route: (expected[key][route] if key in failed else profile[route]) for route in core.ROUTES[:-1]}
        core.same(normal[key], expected_row, 'original ordinary full record')
    # Only the ordinary profile moves after the failed direct root; SDK/cases stay exact.
    for name in original_root['files']:
        if not name.startswith(('rust/', 'tests/', 'specs/', 'cli_conformance/')) or name == ordinary:
            continue
        source = fixed_root if name == core.OWNER else data['direct']['root'] if name == core.OLD_PROFILE else original_root
        core.same(root['files'][name], source['files'][name], 'qualified root identity')
    for name in (core.NORMAL, core.CASES, core.PROFILE):
        core.same(root['files'][name], fixed_root['files'][name], 'qualified new normal identity')
    assert (base / 'qualified-direct/activation.txt').read_text() == core.ACTIVATION + '\n'
    environment = dict(CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1', LINKEDSPEC_ARRAY_CONCAT_RUST_CAPTURE=str(rel / 'qualified-direct'))
    for path in (base / 'qualified-direct').glob('*-command.json'):
        tag = path.name.removesuffix('-command.json'); command = json.loads(path.read_bytes())
        core.same(command['environment'], environment, 'qualified command environment')
        assert command['cwd'] == '.' and path.with_name(tag + '-exit.txt').read_text() == '0\n', 'qualified command exit'
        product = test if tag in ('ordinary-free', 'ordinary-receiver') else tag
        if tag in ('ordinary-free', 'ordinary-receiver', 'array_transform_callable_result_guard_composition', 'array_pipeline_callable_result_guard_composition'):
            executable = str(rel / 'qualified-direct' / (product + '-exec'))
            assert executable in qualified[product + '-product']['files'], 'qualified executed product'
            assert command['argv'][:3] == ['bash', 'tools/project_data_run.sh', executable]
    for form in ('free', 'receiver'):
        tag = 'ordinary-' + form; key = 'extra_concat_arrays_' + form
        assert b'1 passed; 0 failed' in core.raw('qualified-direct/' + tag + '-stdout.log.gz')
        row = core.frames(core.raw('qualified-direct/' + tag + '-stderr.log.gz'), 'ARRAY_TRANSFORM_RUST_NORMAL')
        core.same(row, {key: {route: expected[key][route] for route in core.ROUTES[:-1]}}, 'qualified ordinary normal')
    for name, count, tag, profile_path in (
        ('array_transform_callable_result_guard_composition', 312, 'CALLABLE_TRANSFORM_RUST_NORMAL', core.OLD_PROFILE),
        ('array_pipeline_callable_result_guard_composition', 194, 'CALLABLE_PIPELINE_RUST_NORMAL', pipeline),
    ):
        assert f'{count} passed; 0 failed'.encode() in core.raw('qualified-direct/' + name + '-stdout.log.gz'), 'qualified dependent totals'
        rows = core.frames(core.raw('qualified-direct/' + name + '-stderr.log.gz'), tag)
        profiles = json.loads(root['bodies'][profile_path])
        assert len(rows) == len(profiles) == count, 'qualified dependent census'
        for key, profile in profiles.items():
            core.same(rows[key], {route: profile[route] for route in core.ROUTES[:-1]}, 'qualified dependent full record')
    return old_profile, final_profile, expected

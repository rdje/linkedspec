"""Independently grade immutable membership inputs, complete channels and original oracles."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import stat
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = '864b1a93934ab7fd4b059b0a7cb9d4b417e33c66'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1-'
PUBLIC = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'
LITERALS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
FIXTURE = 't/actionir_compiler_source_membership.t'
TESTS = ['t/' + name + '.t' for name in (
    'actionir_executable_source_membership', 'actionir_helper_source_provenance',
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_pipeline_regex_source_provenance', 'actionir_pipeline_statement_source_provenance',
    'actionir_statement_source_frames', 'actionir_method_argument_source_frames',
    'actionir_nested_block_source_spans', 'trace_emit_context_bridge',
    'actionir_raw_dependency_metadata', 'actionir_raw_dependency_provenance',
    'actionir_raw_dependency_compatibility', 'generated_source_contract', 'phase0_regression')]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete channel identity'
    return raw


def committed(path):
    return subprocess.check_output(['git', 'show', REVISION + ':' + path], cwd=ROOT)


def check_inputs(manifest):
    assert manifest['revision'] == REVISION and manifest['overlays'] == [], 'committed input boundary'
    entries = {e['path']: e for e in manifest['entries']}
    assert len(entries) == len(manifest['entries']) == manifest['regular_git_inputs'], 'unique complete inputs'
    expected, excluded = {}, []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            expected[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
    assert set(entries) == set(expected) and manifest['excluded_metadata'] == excluded, 'complete Git input population'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, identity in expected.items():
            entry = entries[path]
            assert set(entry) == {'path', 'mode', 'oid', 'bytes', 'sha256'}, 'no replaced or overlay input'
            assert (entry['mode'], entry['oid'], entry['bytes']) == identity, 'exact committed input identity'
            process.stdin.write((identity[1] + '\n').encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [identity[1].encode(), b'blob', str(identity[2]).encode()]
            raw = process.stdout.read(identity[2])
            assert process.stdout.read(1) == b'\n' and sha(raw) == entry['sha256'], 'exact committed input bytes'
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0
    # The acceptance does not change any original production owner or fixture.
    for path in entries:
        if path.startswith(('perl/', 't/')):
            assert sha((ROOT / path).read_bytes()) == entries[path]['sha256'], 'unchanged production and tests'
            assert stat.S_IMODE((ROOT / path).stat().st_mode) == int(entries[path]['mode'][-3:], 8), 'unchanged production and test modes'
    return len(entries)


def tap(text, names=None):
    assert not re.search(r'^\s*not ok ', text, re.M), 'all nested and top-level TAP passes'
    groups = re.findall(r'^ok (\d+) - (.+)$', text, re.M)
    plans = [int(n) for n in re.findall(r'^1\.\.(\d+)$', text, re.M)]
    assert plans and len(groups) == sum(plans), 'complete TAP reach'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual TAP success'
    if names is not None:
        assert groups == [(str(i), name) for i, name in enumerate(names, 1)], 'original ordered compiler groups'
        assert plans == [len(names)], 'exact compiler plan'
    return {'groups': len(groups), 'plans': plans}


def check_report(report, count):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete immutable capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture instrument'
    assert report['stream_instrument_sha256'] == sha(committed(STREAM)), 'original input/channel instrument'
    tree = Path(report['input_tree'])
    assert not tree.is_absolute() and '..' not in tree.parts, 'portable input tree'
    assert tree.as_posix().startswith('.linkedspec-data/scratch/committed-membership-acceptance/committed-'), 'local immutable input tree'
    cases = json.loads(committed(PUBLIC + 'cases.json'))
    literals = json.loads(committed(LITERALS))
    names = [c['id'] for c in literals] + [
        'compiler bridge preserves callback and caller error contracts',
        'numeric slash newline preserves following host quotes',
        'native and independently loaded generated parsers preserve quoted data']
    population = [('compiler-tap', seed) for seed in (0, 1, 42)]
    population += [('public:' + c['id'], seed) for seed in (0, 1, 42) for c in cases]
    population += [('consumers', 0)]
    assert [(r['kind'], r['seed']) for r in report['runs']] == population, 'complete ordered command population'
    previous = json.loads(committed(PREVIOUS + 'final-after-observations.json'))
    previous_public = {r['kind']: json.loads(decode(r['stdout']))
                       for r in previous['runs'] if r['kind'].startswith('public:')}
    consumer_before = next(r for r in previous['runs'] if r['kind'] == 'consumers')
    original_consumer_text = decode(consumer_before['stdout']).decode()
    original_plans = tap(original_consumer_text)['plans']
    original_groups = re.findall(r'^ok (\d+) - (.+)$', original_consumer_text, re.M)
    public_count, oracle_count, compiler = 0, 0, None
    for row in report['runs']:
        assert row['exit'] == 0 and decode(row['stderr']) == b'', 'actual quiet command completion'
        assert row['inputs_before'] == row['inputs_after'] == count, 'complete unchanged input guards'
        stdout = decode(row['stdout'])
        if row['kind'] == 'compiler-tap':
            tail = ['prove', '-v', '-Iperl', FIXTURE]
            compiler = tap(stdout.decode(), names)
        elif row['kind'] == 'consumers':
            tail = ['prove', '-v', '-Iperl'] + TESTS
            consumers = tap(stdout.decode())
            assert consumers['plans'] == original_plans, 'original complete direct consumer plans'
            assert re.findall(r'^ok (\d+) - (.+)$', stdout.decode(), re.M) == original_groups, 'original direct consumer group order'
            headers = re.findall(r'^(t/\S+\.t) \.*\s*$', stdout.decode(), re.M)
            assert headers == TESTS, 'exact ordered direct consumer files'
        else:
            name = row['kind'].removeprefix('public:')
            tail = ['perl', '-Iperl', PUBLIC + 'probe.pl', name]
            doc = json.loads(stdout)
            case = next(c for c in cases if c['id'] == name)
            assert doc['id'] == name and doc['source'] == case['source'] and doc['action'] == case['action'], 'original public source'
            assert doc['source_sha256'] == sha(case['source'].encode()), 'original public source hash'
            assert doc['seed'] == str(row['seed']) and doc['perturb'] == '2', 'actual public controlled seed'
            original = previous_public[row['kind']]
            # Compare every public channel, not just the successful returned value.
            for key in original:
                if key != 'seed':
                    assert doc[key] == original[key], 'original complete public channel: ' + name + '/' + key
            if 'expected' in case:
                for route in ('native', 'fresh'):
                    assert doc[route]['value'] == case['expected'] and doc[route]['exception'] is None, 'original native/fresh value oracle'
                oracle_count += 1
            else:
                assert name in ('unsupported_nested', 'raw_operand') and case['role'] in ('unsupported', 'raw'), 'explicit unassessed original value scope'
            public_count += 1
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'exact original command routing'
    return {'complete': True, 'revision': REVISION, 'regular_git_inputs': count,
            'overlays': [], 'commands': len(population), 'controlled_seeds': [0, 1, 42],
            'compiler_groups': compiler['groups'], 'public_cases': len(cases),
            'public_seed_observations': public_count, 'authored_value_pairs': oracle_count,
            'authored_route_values': oracle_count * 2,
            'no_original_value_oracle': ['unsupported_nested', 'raw_operand'],
            'direct_consumers': consumers}


def historical_red():
    spec = importlib.util.spec_from_file_location('original_membership_reviewer', ROOT / (PREVIOUS + 'review.py'))
    previous = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(previous)
    observations = json.loads(committed(PREVIOUS + 'before-observations.json'))
    inputs = json.loads(committed(PREVIOUS + 'before-inputs.json'))
    result = previous.check_report(observations, inputs, 'before')
    return [{'seed': seed, 'groups': result[('compiler-tap', seed)]['groups'],
             'failures': result[('compiler-tap', seed)]['failures']} for seed in (0, 1, 42)]


def main():
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    count = check_inputs(manifest)
    summary = check_report(report, count)
    summary['historical_compiler_red'] = historical_red()
    controls = []
    variants = [
        ('incomplete capture', lambda r: r.update(complete=False)),
        ('missing public command', lambda r: r['runs'].pop(3)),
        ('reordered commands', lambda r: r['runs'].reverse()),
        ('nonzero exit', lambda r: r['runs'][0].update(exit=1)),
        ('lost input guard', lambda r: r['runs'][0].update(inputs_after=0)),
        ('forged channel', lambda r: r['runs'][0]['stdout'].update(sha256='0' * 64)),
        ('forged producer', lambda r: r.update(instrument_sha256='0' * 64)),
        ('nested TAP failure', lambda r: r['runs'][0].update(stdout=envelope(
            decode(r['runs'][0]['stdout']).replace(b'    ok 1 - ', b'    not ok 1 - ', 1)))),
        ('lost original literal', lambda r: change_public(r, 'source', 'changed source')),
        ('lost original AST', lambda r: change_public(r, 'ast', {})),
        ('forged native value', lambda r: change_public(r, 'native', {'value': 'forged'})),
        ('lost generated source', lambda r: change_public(r, 'emitted', 'changed emitted source')),
        ('lost metadata', lambda r: change_public(r, 'metadata', {})),
        ('renamed consumer group', lambda r: r['runs'][-1].update(stdout=envelope(
            decode(r['runs'][-1]['stdout']).replace(b'ok 1 - ', b'ok 1 - forged group ', 1)))),
    ]
    for name, mutate in variants:
        candidate = copy.deepcopy(report)
        mutate(candidate)
        assert candidate != report, 'effective evidence control'
        try:
            check_report(candidate, count)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected evidence control: ' + name)
    for name, mutate in [
        ('missing immutable input', lambda m: m['entries'].pop()),
        ('replaced immutable input', lambda m: m['entries'][0].update(replacement=True)),
        ('forged immutable hash', lambda m: m['entries'][0].update(sha256='0' * 64)),
    ]:
        candidate = copy.deepcopy(manifest)
        mutate(candidate)
        assert candidate != manifest, 'effective immutable input control'
        try:
            check_inputs(candidate)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected immutable input control: ' + name)
    summary['controls'] = controls
    summary['instrument_sha256'] = sha(Path(__file__).read_bytes())
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def change_public(report, key, value):
    row = next(r for r in report['runs'] if r['kind'] == 'public:quoted_set')
    doc = json.loads(decode(row['stdout']))
    doc[key] = value
    row['stdout'] = envelope(json.dumps(doc).encode())


if __name__ == '__main__':
    main()

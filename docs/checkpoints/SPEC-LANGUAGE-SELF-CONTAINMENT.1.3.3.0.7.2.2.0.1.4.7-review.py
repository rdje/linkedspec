"""Independently accept all committed Legacy producers and original literal oracles."""
from pathlib import Path
from collections import Counter
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = '65304aded7d1a096c701b768b076b29c4eb893b2'
LEGACY = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6-'
ORIGINAL = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
TESTS = ['t/nested_boundary_quoted_labels.t', 't/capture_boundary_quoted_labels.t',
         't/typed_source_location_perl_contract.t', 't/actionir_helper_source_provenance.t',
         't/actionir_statement_source_frames.t', 't/actionir_ast_parser.t',
         't/canonical_event_occurrence_order.t', 't/actionir_nested_block_source_spans.t',
         't/trace_actionir_method_lowering.t', 't/complete_named_mark_contract.t',
         't/generated_source_contract.t', 't/phase0_regression.t']
PLANS = [28, 18, 4, 128, 28, 23, 15, 20, 4, 3, 12, 1035]
FAMILIES = {'call-return-push': 8, 'anonymous-capture': 26, 'named-capture': 17,
            'mark-control': 14, 'cursor-input': 15, 'entry-match': 32}
spec = importlib.util.spec_from_file_location('original_legacy_literal_oracle', ROOT / (LEGACY + 'oracle.py'))
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'complete channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'complete channel bytes'
    return raw


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def check_cases(cases):
    literal = json.loads((ROOT / (ORIGINAL + 'cases.json')).read_bytes())
    literal[-1]['expected_events'][0]['args']['boundaries'] = ['a,b', 'end']
    assert cases == literal, 'only established boundary correction changes original literal oracle'
    inventory = json.loads((ROOT / (ORIGINAL + 'inventory.json')).read_bytes())
    expected = [(row['contract'], row['family']) for row in inventory['contracts']]
    actual = [(case['contracts'][0], case['family']) for case in cases[:112]]
    assert actual == expected and len(set(actual)) == 112, 'complete original dispatcher population'
    assert dict(Counter(family for _, family in actual)) == FAMILIES, 'exact six original families'


def check_inputs(manifest):
    assert manifest['revision'] == REVISION and manifest['overlays'] == [], 'immutable boundary without overlays'
    expected, excluded = {}, []
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        meta, path = row.split(b'\t', 1)
        mode, kind, oid, size = meta.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            expected[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
    entries = {entry['path']: entry for entry in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and entries.keys() == expected.keys(), 'complete unique immutable Git population'
    assert manifest['excluded_metadata'] == excluded, 'exact black-box metadata exclusions'
    proc = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in expected.items():
            entry = entries[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'exact original object and mode'
            proc.stdin.write((oid + '\n').encode())
            proc.stdin.flush()
            assert proc.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'exact original blob header'
            raw = proc.stdout.read(size)
            assert proc.stdout.read(1) == b'\n', 'exact original blob framing'
            assert entry['sha256'] == sha(raw), 'exact immutable Git bytes'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged current production and fixtures'
    finally:
        proc.stdin.close()
        proc.stdout.close()
        assert proc.wait() == 0


def check_report(report, manifest, cases):
    assert report['complete'] and report['revision'] == REVISION, 'complete fresh capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / STREAM).read_bytes()), 'actual stream producer'
    population = [('fixtures', 0)] + [('legacy', seed) for seed in (0, 1, 42)]
    assert [(row['kind'], row['seed']) for row in report['runs']] == population, 'complete command population'
    previous = json.loads((ROOT / (LEGACY + 'after-observations.json')).read_bytes())
    channels = []
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else ['perl', '-Iperl', LEGACY + 'probe.pl']
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual committed producer command'
        assert row['exit'] == 0 and row['inputs_before'] == row.get('inputs_after') == len(manifest['entries']), 'complete runtime guards'
        assert decode(row['stderr']) == b'', 'empty actual stderr'
        raw = decode(row['stdout'])
        if row['kind'] == 'legacy':
            oracle.check(json.loads(raw), cases, 'after')
            old = next(old for old in previous['runs'] if old['kind'] == 'legacy' and old['seed'] == row['seed'])
            assert raw == decode(old['stdout']), 'complete prior compiler callback and origin recurrence'
            channels.append(raw)
        else:
            text = raw.decode()
            assert not re.search(r'^\s*not ok\b', text, re.M), 'no nested fixture failure'
            sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
            assert sections[1::2] == TESTS, 'complete ordered fixture population'
            for body, plan in zip(sections[2::2], PLANS, strict=True):
                assert re.findall(r'^1\.\.(\d+)\s*$', body, re.M) == [str(plan)], 'complete fixture plan'
                assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, plan + 1)), 'complete ordered positive TAP reach'
            assert 'All tests successful.' in text and 'Result: PASS' in text, 'complete fixture success'
    assert channels[0] == channels[1] == channels[2], 'complete three-seed channel equality'


def main():
    cases = json.loads((ROOT / (LEGACY + 'cases.json')).read_bytes())
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    check_cases(cases)
    check_inputs(manifest)
    check_report(report, manifest, cases)
    rows = json.loads(decode(report['runs'][1]['stdout']))
    controls = []

    def reject(name, target, mutation, validator, reason):
        changed = copy.deepcopy(target)
        mutation(changed)
        assert changed != target, 'ineffective control: ' + name
        try:
            validator(changed)
        except (AssertionError, KeyError, ValueError, IndexError) as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': str(error)})
        else:
            raise AssertionError('accepted control: ' + name)

    literal_check = lambda data: oracle.check(data, cases, 'after')
    report_check = lambda data: check_report(data, manifest, cases)
    for index, case in enumerate(cases[:112]):
        reject(case['id'] + ' omitted event', rows, lambda data, i=index: data[i]['rows'][0]['public_events'].pop(), literal_check, 'literal original events and arguments')
    for index, case in enumerate(cases):
        reject(case['id'] + ' missing origin', rows, lambda data, i=index: data[i]['rows'][0]['private_result']['source_origins'].pop(), literal_check, 'exact original source origin population')
    for family in FAMILIES:
        index = next(index for index, case in enumerate(cases[:112]) if case['family'] == family)
        for key in ('origin_event', 'constructed_event', 'constructed_args'):
            reject(family + ' forged ' + key, rows, lambda data, i=index, k=key: data[i]['rows'][0]['identity'][0].update({k: False}), literal_check, 'actual returned constructor argument references')
        reject(family + ' false repeated interval', rows, lambda data, i=index: data[i]['rows'][0]['private_result']['source_origins'][1]['source_span'].update(start=0), literal_check, 'exact original source origin population')
    reject('lost callback effects', rows, lambda data: data[3]['rows'][0]['private_calls'].clear(), literal_check, 'exact default callback sequence and results')
    for key in ('substitution', 'diagnostics', 'dump'):
        def change_compiler(data, field=key):
            observed = json.loads(decode(data['runs'][1]['stdout']))
            observed[0][field] = 'changed'
            data['runs'][1]['stdout'] = envelope(json.dumps(observed).encode())
        reject('changed ' + key + ' compiler channel', report, change_compiler, report_check, 'complete prior compiler callback and origin recurrence')
    for name, mutation, reason in [
        ('lost command', lambda data: data['runs'].pop(), 'complete command population'),
        ('wrong command', lambda data: data['runs'][1]['command'].append('unexpected'), 'actual committed producer command'),
        ('lost runtime guard', lambda data: data['runs'][1].pop('inputs_after'), 'complete runtime guards'),
        ('false successful exit', lambda data: data['runs'][0].update(exit=1), 'complete runtime guards'),
        ('forged capture producer', lambda data: data.update(instrument_sha256='0' * 64), 'actual capture producer'),
        ('forged stream producer', lambda data: data.update(stream_instrument_sha256='0' * 64), 'actual stream producer'),
        ('forged complete channel', lambda data: data['runs'][1]['stdout'].update(sha256='0' * 64), 'complete channel bytes'),
        ('unexpected stderr', lambda data: data['runs'][0].update(stderr=envelope(b'wrapper startup warning\n')), 'empty actual stderr'),
        ('missing fixture', lambda data: data['runs'][0].update(stdout=envelope(decode(data['runs'][0]['stdout']).replace((TESTS[0] + ' ..').encode(), b'fixture removed ..', 1))), 'complete ordered fixture population'),
        ('lost positive reach', lambda data: data['runs'][0].update(stdout=envelope(re.sub(rb'^ok 1[^\n]*\n', b'', decode(data['runs'][0]['stdout']), count=1, flags=re.M))), 'complete ordered positive TAP reach'),
        ('hidden nested failure', lambda data: data['runs'][0].update(stdout=envelope(b'    not ok 1 - false success\n' + decode(data['runs'][0]['stdout']))), 'no nested fixture failure'),
    ]:
        reject(name, report, mutation, report_check, reason)
    reject('lost committed Git input', manifest, lambda data: data['entries'].pop(), check_inputs, 'complete unique immutable Git population')
    reject('invented runtime overlay', manifest, lambda data: data['overlays'].append({'path': 'invented'}), check_inputs, 'immutable boundary without overlays')
    reject('changed original literal oracle', cases, lambda data: data[0].update(action='different'), check_cases, 'only established boundary correction changes original literal oracle')
    result = {
        'complete': True, 'revision': REVISION, 'regular_inputs': len(manifest['entries']),
        'overlays': 0, 'commands': len(report['runs']), 'contracts': 112, 'cases': len(cases),
        'families': FAMILIES, 'seeds': 3, 'source_origins': 227, 'events_per_seed': 227,
        'complete_compiler_pairs': sum(case['toolbox'] for case in cases) * 3,
        'fixture_suites': len(TESTS), 'fixture_groups': sum(PLANS),
        'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
    }
    Path(PREFIX + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'controls'}))
    print(str(len(controls)) + ' effective reason-specific evidence controls RED')


if __name__ == '__main__':
    main()

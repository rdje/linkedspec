"""Independent literal/reference oracles, complete channels and input falsification."""
from pathlib import Path
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
REVISION = '5f700625ef4bce962285ece583b088c457f2dd63'
OWNER = 'perl/LinkedSpec/ActionIR/SourceMembership.pm'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value)
    return value


oracle = module('authored_membership_oracle', Path(PREFIX + 'oracle.py'))
capture = module('declared_membership_capture', Path(PREFIX + 'capture.py'))
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'retained channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'retained complete channel identity'
    return raw


RED = [
    'interleaved_original_mapper', 'double_quote', 'single_quote', 'escaped_double_quote',
    'escaped_single_quote', 'unicode_scalar_crlf', 'quoted_comment_data',
    'backtick_payload_only_scanned', 'q_pipe', 'qq_pipe', 'q_braces', 'qr_slash',
    'm_slash', 'q_angle', 'host_substitution_segments', 'host_translation_segments',
    'helper_pattern', 'grouped_helper_pattern', 'bare_regex_operand',
    'malformed matching-source authority rejects']
GUARDS = ['empty and opaque results retain identity and caller error',
          'missing and foreign origins cannot invent membership authority',
          'malformed matching-source authority rejects',
          'copied origin event cannot authorize an equal raw event',
          'active classification restores caller error after lexical helper work']
PLANS = [191, 23, 15, 13, 16, 28, 15, 20]


def check_manifest(manifest, mode):
    assert manifest['revision'] == REVISION and manifest['mode'] == mode, 'exact immutable activation'
    expected, excluded = {}, []
    for row in filter(None, subprocess.check_output(
            ['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        git_mode, kind, oid, size = metadata.split()
        if kind == b'blob' and git_mode in (b'100644', b'100755'):
            expected[path.decode()] = (git_mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': git_mode.decode(), 'kind': kind.decode()})
    overlays = capture.AUTHORED + ([OWNER] if mode == 'after' else [])
    entries = {entry['path']: entry for entry in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and set(entries) == set(expected) | set(overlays), 'complete unique supplied inputs'
    assert manifest['overlays'] == overlays and manifest['regular_git_inputs'] == len(expected), 'exact declared authored overlays'
    assert manifest['excluded_metadata'] == excluded, 'exact nonregular black-box exclusions'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (git_mode, oid, size) in expected.items():
            entry = entries[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (git_mode, oid, size), 'immutable input object and mode'
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'immutable input framing'
            raw = process.stdout.read(size); assert process.stdout.read(1) == b'\n'
            assert sha(raw) == entry['sha256'] and not entry.get('declared_authored_overlay'), 'immutable input content'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged existing production and fixtures'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    for path in overlays:
        entry, raw = entries[path], (ROOT / path).read_bytes()
        assert entry['mode'] == '100644' and entry['bytes'] == len(raw) and entry['sha256'] == sha(raw), 'exact new authored input bytes'
        assert entry['declared_authored_overlay'] is True and entry['artifact'] == path and 'oid' not in entry, 'explicit new authored input'


def check_probe(document, mode, authored):
    assert document['mode'] == mode, 'declared actual producer mode'
    assert [row['id'] for row in document['cases']] == [case['id'] for case in authored], 'complete ordered case population'
    for row, case in zip(document['cases'], authored, strict=True):
        assert row['source'] == case['source'], 'exact authored source'
        original, selected = row['original_scan'], row['selected_scan']
        assert row['original_untouched'] == row['source_untouched'] == 1, 'original source and scan untouched'
        assert len(original['events']) == len(original['source_origins']), 'complete actual producer origins'
        for event, origin in zip(original['events'], original['source_origins'], strict=True):
            start, end = (origin['source_span'][key] for key in ('start', 'end'))
            assert origin['source'] == case['source'] and origin['event'] == event, 'original producer source and event'
            assert type(start) is int and type(end) is int and 0 <= start <= end <= len(case['source']), 'actual scalar coordinates'
            assert case['source'][start:end] == event['raw'], 'original scalar raw slice'
        if mode == 'before':
            assert selected == original and row['selected_indices'] == list(range(len(original['events']))), 'original syntactic before adapter'
            expected_count = len(original['events'])
        else:
            measured = [{'raw': origin['event']['raw'], 'args': origin['event']['args'],
                         'source_span': origin['source_span']} for origin in selected['source_origins']]
            assert measured == case['events'], 'independent selected interval argument and order oracle'
            expected_indices = []
            for expected in case['events']:
                matches = [index for index, origin in enumerate(original['source_origins'])
                           if {'raw': origin['event']['raw'], 'args': origin['event']['args'],
                               'source_span': origin['source_span']} == expected]
                assert len(matches) == 1, 'unique authored original occurrence'
                expected_indices.append(matches[0])
            assert row['selected_indices'] == expected_indices, 'actual selected original event references'
            assert selected['events'] == [original['events'][index] for index in expected_indices], 'complete original selected event fields'
            expected_count = len(case['events'])
        assert len(selected['events']) == len(selected['source_origins']) == expected_count, 'exact selected population'
        assert row['original_argument_references'] == [1] * expected_count, 'actual original event and argument references'
        assert row['unchanged_result_reference'] == int(expected_count == len(original['events'])), 'unchanged result identity'


def check_reports(reports, manifests, authored):
    channels = {}
    for mode in ('before', 'after'):
        report, manifest = reports[mode], manifests[mode]
        assert report['complete'] is True and report['revision'] == REVISION and report['mode'] == mode, 'complete declared capture'
        assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer identity'
        assert report['stream_instrument_sha256'] == sha((ROOT / capture.STREAM).read_bytes()), 'actual stream guard producer identity'
        tree = report['input_tree']
        assert isinstance(tree, str) and tree.startswith('.linkedspec-data/scratch/executable-source-membership/' + mode + '-'), 'repository-local input tree'
        assert not Path(tree).is_absolute() and all(part not in ('.', '..') for part in Path(tree).parts), 'portable input tree'
        expected = [('authored-oracle', 0, ['python3', capture.REL + 'oracle.py'])]
        expected += [('membership-tap', seed, ['prove', '-v', '-Iperl', capture.FIXTURE]) for seed in (0, 1, 42)]
        expected += [('membership-probe', seed, ['perl', '-Iperl', capture.REL + 'probe.pl', mode]) for seed in (0, 1, 42)]
        expected += [('public-intake', seed, ['perl', '-Iperl', capture.REL + 'intake.pl']) for seed in (0, 1, 42)]
        expected += [('consumers', 0, ['prove', '-v', '-Iperl'] + capture.TESTS)]
        assert [(row['kind'], row['seed']) for row in report['runs']] == [(kind, seed) for kind, seed, _ in expected], 'complete actual command population'
        for row, (kind, seed, tail) in zip(report['runs'], expected, strict=True):
            assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'exact declared actual command'
            assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries']), 'complete runtime input guards'
            raw, error = decode(row['stdout']), decode(row['stderr'])
            wanted_exit = int(mode == 'before' and kind == 'membership-tap')
            assert row['exit'] == wanted_exit, 'complete declared actual exit'
            if kind == 'membership-tap':
                text = raw.decode()
                top = re.findall(r'^(?:not )?ok (\d+) - (.+)$', text, re.M)
                assert [int(number) for number, _ in top] == list(range(1, 42)), 'complete membership TAP reach'
                assert [name for _, name in top] == [case['id'] for case in authored] + GUARDS, 'exact ordered membership TAP groups'
                assert re.findall(r'^1\.\.(\d+)$', text, re.M) == ['41'], 'complete membership TAP plan'
                failures = re.findall(r'^not ok \d+ - (.+)$', text, re.M)
                assert failures == (RED if mode == 'before' else []), 'exact original RED or repaired GREEN'
                if mode == 'after':
                    assert not re.search(r'^\s*not ok ', text, re.M) and error == b'', 'no nested GREEN failures or warnings'
            else:
                assert error == b'', 'empty actual command stderr'
            if kind == 'membership-probe':
                document = json.loads(raw); check_probe(document, mode, authored)
                channels[(mode, seed, kind)] = document
            if kind == 'public-intake':
                channels[(mode, seed, kind)] = raw
                assert raw == Path(PREFIX + 'intake.json').read_bytes(), 'complete unchanged public intake'
            if kind == 'consumers':
                text = raw.decode()
                assert not re.search(r'^\s*not ok ', text, re.M), 'no nested unchanged consumer failures'
                assert [int(value) for value in re.findall(r'^1\.\.(\d+)$', text, re.M)] == PLANS, 'complete ordered direct consumer plans'
                assert 'Tests=321,' in text and 'Result: PASS' in text, 'complete unchanged direct consumer result'
    for seed in (0, 1, 42):
        before = channels[('before', seed, 'membership-probe')]
        after = channels[('after', seed, 'membership-probe')]
        assert [row['original_scan'] for row in before['cases']] == [row['original_scan'] for row in after['cases']], 'complete original producer channel equality'
    for mode in ('before', 'after'):
        assert all(channels[(mode, seed, 'membership-probe')] == channels[(mode, 0, 'membership-probe')]
                   for seed in (1, 42)), 'complete three-seed private channel equality'
    return {'cases': len(authored), 'original_events_per_seed': sum(len(row['original_scan']['events'])
            for row in channels[('before', 0, 'membership-probe')]['cases']),
            'selected_events_per_seed': sum(len(case['events']) for case in authored),
            'membership_groups': 41, 'original_red_groups': len(RED), 'direct_consumer_groups': sum(PLANS)}


def main():
    authored = json.loads(Path(PREFIX + 'cases.json').read_bytes())
    assert authored == oracle.author(), 'independently authored literal case corpus'
    manifests = {mode: json.loads(Path(PREFIX + mode + '-inputs.json').read_bytes()) for mode in ('before', 'after')}
    reports = {mode: json.loads(Path(PREFIX + mode + '-observations.json').read_bytes()) for mode in ('before', 'after')}
    for mode in manifests:
        check_manifest(manifests[mode], mode)
    metrics = check_reports(reports, manifests, authored)
    controls = []

    def reject(name, reason, bad_reports=None, bad_manifests=None):
        assert bad_reports is not None or bad_manifests is not None
        assert bad_reports != reports or bad_manifests != manifests, 'effective evidence change'
        try:
            if bad_manifests:
                for mode in bad_manifests:
                    check_manifest(bad_manifests[mode], mode)
            else:
                check_reports(bad_reports, manifests, authored)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
        else:
            raise AssertionError('accepted corrupt evidence: ' + name)
        controls.append({'control': name, 'expected_reason': reason, 'observed': 'RED'})

    for name, key, value, reason in [
        ('hidden_exit', 'exit', 0, 'complete declared actual exit'),
        ('lost_guard', 'inputs_after', 0, 'complete runtime input guards'),
        ('wrong_command', 'command', [], 'exact declared actual command')]:
        bad = copy.deepcopy(reports); bad['before']['runs'][1][key] = value
        reject(name, reason, bad_reports=bad)
    bad = copy.deepcopy(reports); bad['after']['runs'].pop()
    reject('omitted_command', 'complete actual command population', bad_reports=bad)
    bad = copy.deepcopy(reports); bad['after']['instrument_sha256'] = '0' * 64
    reject('stale_producer', 'actual capture producer identity', bad_reports=bad)
    for name, mutation, reason in [
        ('changed_source', lambda row: row.update(source='other'), 'exact authored source'),
        ('hidden_side_effect', lambda row: row.update(original_untouched=0), 'original source and scan untouched'),
        ('lost_selected_reference', lambda row: row.update(selected_indices=[0, 2]), 'actual selected original event references'),
        ('copied_arguments', lambda row: row.update(original_argument_references=[0, 1]), 'actual original event and argument references'),
        ('copied_unchanged_result', lambda row: row.update(unchanged_result_reference=1), 'unchanged result identity'),
        ('changed_argument', lambda row: row['selected_scan']['source_origins'][0]['event']['args'].update(source='99'),
         'independent selected interval argument and order oracle')]:
        bad = copy.deepcopy(reports)
        run = next(row for row in bad['after']['runs'] if row['kind'] == 'membership-probe' and row['seed'] == 0)
        document = json.loads(decode(run['stdout'])); mutation(document['cases'][0])
        run['stdout'] = capture.streams.envelope(json.dumps(document, ensure_ascii=False, sort_keys=True).encode())
        reject(name, reason, bad_reports=bad)
    for name, mutation, reason in [
        ('omitted_input', lambda value: value['entries'].pop(), 'complete unique supplied inputs'),
        ('wrong_object', lambda value: value['entries'][0].update(oid='0' * 40), 'immutable input object and mode'),
        ('wrong_mode', lambda value: value['entries'][0].update(mode='100755'), 'immutable input object and mode'),
        ('changed_input_bytes', lambda value: value['entries'][0].update(sha256='0' * 64), 'immutable input content'),
        ('lost_overlay', lambda value: value['overlays'].pop(), 'exact declared authored overlays'),
        ('hidden_authored_delta', lambda value: value['entries'][-1].update(sha256='0' * 64), 'exact new authored input bytes')]:
        bad = copy.deepcopy(manifests); mutation(bad['after'])
        reject(name, reason, bad_manifests=bad)
    verification = {'revision': REVISION, 'complete': True, 'metrics': metrics,
                    'evidence_controls': controls, 'measured_scope': 'Private selector only; original source/scanner/facade substitution unchanged. No compiler integration, runtime execution, grammar/backend admission or quoted/comment/marker parent closeout.'}
    Path(PREFIX + 'verification.json').write_text(json.dumps(verification, indent=2) + '\n')
    print(json.dumps({'metrics': metrics, 'effective_red_controls': len(controls)}))


if __name__ == '__main__':
    main()

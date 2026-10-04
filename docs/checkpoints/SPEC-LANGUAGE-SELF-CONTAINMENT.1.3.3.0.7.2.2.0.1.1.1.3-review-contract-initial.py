"""Independently accept the fresh eleven-contract composition and its input boundary."""
from pathlib import Path
import copy
import base64
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = 'ab2c0b9357007aab31302e01c9f4a73aaf2fc5c8'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
spec = importlib.util.spec_from_file_location('statement_oracle', ROOT / (PREVIOUS + 'review.py'))
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)
sha, decode = oracle.author.digest, oracle.author.decode
TESTS = ['t/actionir_statement_source_frames.t', 't/actionir_basic_statement_source_provenance.t',
         't/actionir_basic_regex_source_provenance.t', 't/actionir_helper_source_provenance.t']


def check_inputs(manifest):
    assert manifest['revision'] == REVISION, 'exact activation input revision'
    actual, excluded = {}, []
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            actual[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
    entries = {e['path']: e for e in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and entries.keys() == actual.keys(), 'complete unique Git membership'
    assert manifest['excluded_metadata'] == excluded, 'black-box metadata exclusion'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in actual.items():
            entry = entries[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'original Git member identity'
            process.stdin.write((oid + '\n').encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'Git blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'Git blob framing'
            assert sha(raw) == entry['sha256'], 'original Git member bytes'
            assert hashlib.sha1(b'blob ' + str(size).encode() + b'\0' + raw).hexdigest() == oid, 'Git object content'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged current production and tests'
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0
    return len(entries)


def check_fixtures(row):
    text = decode(row['stdout']).decode()
    sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
    assert sections[1::2] == TESTS, 'complete selected suite population'
    for body, count in zip(sections[2::2], (28, 29, 10, 13)):
        assert re.findall(r'^1\.\.(\d+)\s*$', body, re.M) == [str(count)], 'complete selected suite plan'
        assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, count + 1)), 'complete ordered positive fixture reach'
        assert not re.search(r'^\s*not ok\b', body, re.M), 'no nested fixture failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual fixture success'


def check_report(report, manifest):
    assert report['revision'] == REVISION and report['complete'] is True, 'complete exact-source recurrence'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual recurrence producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / (oracle.PREVIOUS + 'capture.py')).read_bytes()), 'actual channel producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('fixtures', 0)] + [(kind, seed) for kind in ('toolbox', 'foreign-source') for seed in (0, 1, 42)], 'complete actual run population'
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else ['perl', '-Iperl', PREVIOUS + ('probe.pl' if row['kind'] == 'toolbox' else 'guard-probe.pl')]
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual recurrence command'
        assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries']), 'actual complete input guards'
        assert row['exit'] == 0, 'actual successful exit'
        decode(row['stdout'])
        assert decode(row['stderr']) == b'', 'actual empty outer stderr'
    check_fixtures(report['runs'][0])


def check_foreign(data):
    event = {'raw': 'my $other', 'args': {'declaration_type': 'scalar', 'names': ['other'], 'scope': 'my'}}
    assert data == {'source': 'my $input;', 'public': [event], 'private': {'events': [event], 'source_origins': []}}, 'literal foreign-source boundary'


def main():
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    count = check_inputs(manifest)
    check_report(report, manifest)
    expected = oracle.author.author_cases()
    oracle.author.check_spans(expected)
    contracts = sorted({c['contract'] for c in expected})
    assert contracts == sorted(['return_bare', 'exit_bare', 'linecount_prefix_newline_matches', 'print_capture_substr', 'my_declare_bare', 'assign_match_my', 'destructure_imatch_list_my', 'regex_subst_assignment', 'next_bare', 'ref_field_assign', 'position_tracking']), 'exact eleven-contract population'
    historical = json.loads((ROOT / (PREVIOUS + 'after.json')).read_bytes())
    for row, old in zip(report['runs'][1:4], historical['runs'][1:]):
        data = json.loads(decode(row['stdout']))
        oracle.frame_check(data, expected, True)
        assert decode(row['stdout']) == decode(old['stdout']), 'exact prior guarded compiler recurrence'
    for row in report['runs'][4:]:
        check_foreign(json.loads(decode(row['stdout'])))
    assert len({decode(r['stdout']) for r in report['runs'][1:4]}) == len({decode(r['stdout']) for r in report['runs'][4:]}) == 1, 'exact cross-seed channels'
    initial = json.loads(Path(PREFIX + 'review-initial-result.json').read_bytes())
    assert initial['exit'] == 1 and initial['instrument_sha256'] == sha(Path(PREFIX + 'review-initial-capture.py').read_bytes()), 'retained initial reviewer execution'
    for entry in initial['inputs']:
        assert entry['sha256'] == sha((ROOT / entry['path']).read_bytes()), 'retained initial reviewer inputs'
    assert decode(initial['stdout']) == b'' and b'complete selected suite population' in decode(initial['stderr']), 'retained initial reviewer failure'
    controls = []

    def reject(name, subject, change, check, reason):
        candidate = copy.deepcopy(subject)
        change(candidate)
        try:
            check(candidate)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else:
            raise AssertionError('accepted corruption: ' + name)

    data = json.loads(decode(report['runs'][1]['stdout']))
    framed = lambda d: oracle.frame_check(d, expected, True)
    reject('drop original event occurrence', data, lambda d: d['rows'][0]['private_result']['source_origins'].pop(), framed, 'authored event source origins')
    reject('reuse equal earlier occurrence', data, lambda d: d['rows'][0]['private_result']['source_origins'].__setitem__(1, d['rows'][0]['private_result']['source_origins'][0]), framed, 'authored event source origins')
    reject('forge event reference identity', data, lambda d: d['rows'][0]['private_event_identity'].__setitem__(0, False), framed, 'exact original event identities')
    reject('drop splitter frame', data, lambda d: d['rows'][0]['statement_frames'].pop(), framed, 'authored original scalar frames')
    reject('invent foreign origin', json.loads(decode(report['runs'][4]['stdout'])), lambda d: d['private']['source_origins'].append({}), check_foreign, 'literal foreign-source boundary')
    reject('omit supplied input', manifest, lambda d: d['entries'].pop(0), check_inputs, 'complete unique Git membership')
    reject('forge source bytes', manifest, lambda d: d['entries'][0].update(sha256='0' * 64), check_inputs, 'original Git member bytes')
    check = lambda d: check_report(d, manifest)
    reject('promote partial recurrence', report, lambda d: d.update(complete=False), check, 'complete exact-source recurrence')
    reject('forge executing producer', report, lambda d: d.update(instrument_sha256='0' * 64), check, 'actual recurrence producer')
    reject('erase command guard', report, lambda d: d['runs'][0].update(inputs_after=0), check, 'actual complete input guards')
    reject('promote unsuccessful exit', report, lambda d: d['runs'][0].update(exit=1), check, 'actual successful exit')
    reject('forge retained channel', report, lambda d: d['runs'][0]['stdout'].update(sha256='0' * 64), check, 'channel bytes')
    def changed_tap(change):
        candidate = copy.deepcopy(report['runs'][0])
        raw = change(decode(candidate['stdout']).decode()).encode()
        candidate['stdout'] = {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
                               'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}
        return candidate

    omitted = changed_tap(lambda text: text.replace(TESTS[0], 'omitted.t', 1))
    reject('omit actual suite', omitted, lambda d: None, check_fixtures, 'complete selected suite population')
    partial = changed_tap(lambda text: re.sub(r'^1\.\.28$', '1..27', text, count=1, flags=re.M))
    reject('shorten actual plan', partial, lambda d: None, check_fixtures, 'complete selected suite plan')
    nested = changed_tap(lambda text: text.replace('    ok 1 -', '    not ok 1 -', 1))
    reject('conceal nested failure', nested, lambda d: None, check_fixtures, 'no nested fixture failure')
    result = {'revision': REVISION, 'git_inputs': count, 'overlays': 0, 'contracts': contracts,
              'fixture_suites': 4, 'fixture_groups': 80, 'toolbox_inspections': 66,
              'frames': 177, 'event_origins': 111, 'foreign_source_probes': 3,
              'exact_previous_guarded_compiler_recurrence': True, 'controls': controls,
              'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(str(count) + ' immutable regular Git inputs;80 fixture groups/66 compiler inspections/111 origins/177 frames;15 observed RED controls')


if __name__ == '__main__':
    main()

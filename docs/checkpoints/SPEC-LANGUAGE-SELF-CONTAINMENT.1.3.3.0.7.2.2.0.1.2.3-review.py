"""Independently accept the committed mixed pipeline recurrence and exact inputs."""
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
REVISION = 'e0a09bf474db1cec13b7169e7a3e2a33f97aaed4'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
TESTS = ['t/actionir_statement_source_frames.t', 't/actionir_helper_source_provenance.t', 't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t', 't/uniform_binding_contract.t', 't/codeblock_push_composition_perl.t', 't/trace_actionir_pipeline.t', 't/actionir_pipeline_regex_source_provenance.t', 't/actionir_pipeline_split_source_metadata.t', 't/actionir_basic_statement_source_provenance.t', 't/actionir_pipeline_statement_source_provenance.t', 't/actionir_basic_regex_source_provenance.t', 't/actionir_raw_dependency_provenance.t', 't/actionir_nested_block_source_spans.t']
PLANS = [28,13,23,15,12,605,5,13,8,29,16,10,6,20]
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2-'
PROBE = PREVIOUS + 'probe.pl'
CASE_PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-'
REVIEW_INPUTS = [PREVIOUS+name for name in ('review.py','capture.py','probe.pl','identity-probe.pl','after-observations.json')]
REVIEW_INPUTS += [CASE_PREFIX+name for name in ('oracle.py','cases.json','split-probe.pl','verification.json')]
REVIEW_INPUTS += [DIAGNOSIS+'capture.py',GUARD+'guard-probe.pl']

spec = importlib.util.spec_from_file_location('mixed_original_review', ROOT / (PREVIOUS + 'review.py'))
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
oracle = original.oracle


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'channel bytes'
    return raw


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
            if path.startswith(('perl/', 'specs/', 't/')) or path in REVIEW_INPUTS:
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
    for body, count in zip(sections[2::2], PLANS, strict=True):
        assert re.findall(r'^1\.\.(\d+)\s*$', body, re.M) == [str(count)], 'complete selected suite plan'
        assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, count + 1)), 'complete ordered positive fixture reach'
        assert not re.search(r'^\s*not ok\b', body, re.M), 'no nested fixture failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual fixture success'


def check_report(report, manifest):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete exact-source capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / (DIAGNOSIS + 'capture.py')).read_bytes()), 'actual channel producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('fixtures', 0)] + [(kind, seed) for kind in ('toolbox', 'foreign-source') for seed in (0, 1, 42)] + [('split-toolbox',0),('identity-control',0)], 'complete actual run population'
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else ['perl', '-Iperl', PROBE if row['kind'] == 'toolbox' else CASE_PREFIX+'split-probe.pl' if row['kind']=='split-toolbox' else PREVIOUS+'identity-probe.pl' if row['kind']=='identity-control' else GUARD + 'guard-probe.pl']
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual capture command'
        assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries']), 'actual complete input guards'
        assert row['exit'] == 0, 'actual successful exit'
        decode(row['stdout']); assert decode(row['stderr']) == b'', 'actual empty outer stderr'
    check_fixtures(report['runs'][0])


def check_mixed(data):
    original.check_mixed(data,'after')


def check_foreign(data):
    event = {'raw': 'my $other', 'args': {'declaration_type': 'scalar', 'names': ['other'], 'scope': 'my'}}
    assert data == {'source': 'my $input;', 'public': [event], 'private': {'events': [event], 'source_origins': []}}, 'literal foreign-source boundary'


def main():
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    regular, overlays = check_inputs(manifest), 0
    assert json.loads((ROOT / (CASE_PREFIX + 'cases.json')).read_bytes()) == oracle.author(), 'independent literal authored fixture'
    check_report(report, manifest)
    for row in report['runs'][1:4]:
        check_mixed(json.loads(decode(row['stdout'])))
    for row in report['runs'][4:7]:
        check_foreign(json.loads(decode(row['stdout'])))
    assert len({decode(r['stdout']) for r in report['runs'][1:4]}) == len({decode(r['stdout']) for r in report['runs'][4:7]}) == 1, 'exact cross-seed channels'
    original.check_split(json.loads(decode(report['runs'][7]['stdout'])))
    original.check_identity(json.loads(decode(report['runs'][8]['stdout'])))
    previous = json.loads((ROOT / (PREVIOUS + 'after-observations.json')).read_bytes())
    def exact_prior(candidate):
        assert decode(candidate['stdout']) == decode(previous['runs'][1 + (0, 1, 42).index(candidate['seed'])]['stdout']), 'exact prior complete Toolbox recurrence'
    for row in report['runs'][1:4]:
        exact_prior(row)
    for index in (7,8):
        assert decode(report['runs'][index]['stdout'])==decode(previous['runs'][index]['stdout']), 'exact prior split and returned-copy controls'
    controls = []

    def reject(name, subject, change, verifier, reason):
        candidate = copy.deepcopy(subject); change(candidate)
        try:
            verifier(candidate)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else:
            raise AssertionError('accepted corruption: ' + name)

    data = json.loads(decode(report['runs'][1]['stdout']))
    reject('erase contract', data, lambda d: d['rows'].pop(), check_mixed, 'exact nineteen-contract population and order')
    reject('change original argument', data, lambda d: d['rows'][0]['public_events'][0]['args'].update(value='Wrong'), check_mixed, 'authored exact public arguments and occurrences')
    reject('erase original event', data, lambda d: d['rows'][0]['public_events'].pop(), check_mixed, 'authored exact public arguments and occurrences')
    reject('reuse equal raw occurrence', data, lambda d: d['rows'][0]['private_result']['source_origins'].__setitem__(1, d['rows'][0]['private_result']['source_origins'][0]), check_mixed, 'exact before/after authored pipeline origins')
    reject('forge argument reference', data, lambda d: d['rows'][0]['identity'][0].update(constructed_args=False), check_mixed, 'original returned event and argument reference identities')
    reject('forge original event reference', data, lambda d: d['rows'][9]['identity'][0].update(constructed_event=False), check_mixed, 'original returned event and argument reference identities')
    reject('erase callback effect', data, lambda d: d['rows'][11]['private_calls'].pop(), check_mixed, 'unchanged original callback sequence arguments and results')
    reject('erase ignored statement frame', data, lambda d: d['statement_frames'].pop(0), check_mixed, 'authored mixed statement frames')
    reject('promote private public schema', data, lambda d: d['rows'][0]['private_result']['events'][0].update(source_span={}), check_mixed, 'unchanged private public events')
    reject('forge compiler success', data, lambda d: d.update(failure='failed'), check_mixed, 'complete clean Toolbox inspection')
    reject('invent foreign origin', json.loads(decode(report['runs'][4]['stdout'])), lambda d: d['private']['source_origins'].append({}), check_foreign, 'literal foreign-source boundary')
    reject('erase supplied input', manifest, lambda d: d['entries'].pop(0), check_inputs, 'complete unique Git membership')
    reject('forge supplied source bytes', manifest, lambda d: d['entries'][0].update(sha256='0' * 64), check_inputs, 'original Git member bytes')
    reject('alter prior compiler stream', report['runs'][1], lambda d: d.update(stdout=envelope(b'{}')), exact_prior, 'exact prior complete Toolbox recurrence')
    verify = lambda d: check_report(d, manifest)
    reject('promote incomplete run', report, lambda d: d.update(complete=False), verify, 'complete exact-source capture')
    reject('forge actual producer', report, lambda d: d.update(instrument_sha256='0' * 64), verify, 'actual capture producer')
    reject('promote failed actual command', report, lambda d: d['runs'][1].update(exit=1), verify, 'actual successful exit')
    reject('forge actual channel', report, lambda d: d['runs'][1]['stdout'].update(sha256='0' * 64), verify, 'channel bytes')
    fixture = report['runs'][0]
    text = decode(fixture['stdout']).decode()
    reject('shorten actual TAP plan', fixture, lambda d: d.update(stdout=envelope(text.replace('\n1..28\n', '\n1..27\n', 1).encode())), check_fixtures, 'complete selected suite plan')
    reject('promote nested TAP failure', fixture, lambda d: d.update(stdout=envelope(text.replace('    ok 1 -', '    not ok 1 -', 1).encode())), check_fixtures, 'no nested fixture failure')
    reject('erase nested hash origin',data,lambda d:d['rows'][16]['private_result']['source_origins'].pop(),check_mixed,'exact before/after authored pipeline origins')
    reject('erase literal receiver origin',data,lambda d:d['rows'][18]['private_result']['source_origins'].pop(),check_mixed,'exact before/after authored pipeline origins')
    reject('forge actual returned identity',data,lambda d:d['rows'][11]['identity'][0].update(origin_event=False),check_mixed,'original returned event and argument reference identities')
    reject('promote tautological copied-return flag',json.loads(decode(report['runs'][8]['stdout'])),lambda d:d.update(required_return_relationship=True),original.check_identity,'actual equal-valued copied-return distinguisher')
    expected = oracle.author()
    summary = {'complete': True, 'revision': REVISION, 'regular_inputs': regular, 'overlays': overlays,
               'contracts': len(expected['contracts']), 'regex_contracts':11, 'statement_contracts':8,'seeds': 3, 'actual_commands':len(report['runs']),
               'authored_statement_frames': len(expected['statements']) * 3,
               'authored_event_origins': sum(len(c['events']) for c in expected['contracts']) * 3,
               'fixture_suites': len(TESTS), 'fixture_groups': sum(PLANS), 'foreign_probes': 3,
               'exact_prior_complete_toolbox_recurrence': True,'normalized_split_preserved':True,'actual_returned_copy_distinguisher':True, 'controls': controls,
               'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='controls'}))


if __name__ == '__main__':
    main()

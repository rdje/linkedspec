"""Review mixed source, arguments, identities, full channels and immutable inputs."""
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
REVISION = 'a2f6d61815a551bf578dbce0e4b453f0f8ce8513'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
TESTS = ['t/actionir_statement_source_frames.t', 't/actionir_helper_source_provenance.t',
         't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t',
         't/uniform_binding_contract.t', 't/codeblock_push_composition_perl.t',
         't/trace_actionir_pipeline.t']
OVERLAYS = [Path(PREFIX + name).relative_to(ROOT).as_posix() for name in ('oracle.py', 'cases.json', 'probe.pl', 'split-probe.pl')]
spec = importlib.util.spec_from_file_location('mixed_oracle', PREFIX + 'oracle.py')
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)


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
    supplied = {p: e for p, e in entries.items() if not e.get('overlay')}
    assert len(entries) == len(manifest['entries']) and supplied.keys() == actual.keys(), 'complete unique Git membership'
    assert manifest['excluded_metadata'] == excluded, 'black-box metadata exclusion'
    overlays = {p: e for p, e in entries.items() if e.get('overlay')}
    assert set(overlays) == set(OVERLAYS), 'exact authored overlay membership'
    for path, entry in overlays.items():
        raw = (ROOT / path).read_bytes()
        assert entry['mode'] == '100644' and len(raw) == entry['bytes'] and sha(raw) == entry['sha256'], 'authored overlay bytes'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in actual.items():
            entry = supplied[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'original Git member identity'
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'Git blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'Git blob framing'
            assert sha(raw) == entry['sha256'], 'original Git member bytes'
            assert hashlib.sha1(b'blob ' + str(size).encode() + b'\0' + raw).hexdigest() == oid, 'Git object content'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged current production and tests'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    return len(supplied), len(overlays)


def check_fixtures(row):
    text = decode(row['stdout']).decode()
    sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
    assert sections[1::2] == TESTS, 'complete selected suite population'
    counts = []
    for body in sections[2::2]:
        plans = re.findall(r'^1\.\.(\d+)\s*$', body, re.M)
        assert len(plans) == 1 and int(plans[0]) > 0, 'complete selected suite plan'
        count = int(plans[0]); counts.append(count)
        assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, count + 1)), 'complete ordered positive fixture reach'
        assert not re.search(r'^\s*not ok\b', body, re.M), 'no nested fixture failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual fixture success'
    return counts


def check_report(report, manifest):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete exact-source capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / (DIAGNOSIS + 'capture.py')).read_bytes()), 'actual channel producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('fixtures', 0)] + [(kind, seed) for kind in ('toolbox', 'foreign-source') for seed in (0, 1, 42)] + [('split-toolbox', 0)], 'complete actual run population'
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else ['perl', '-Iperl', OVERLAYS[2] if row['kind'] == 'toolbox' else OVERLAYS[3] if row['kind'] == 'split-toolbox' else GUARD + 'guard-probe.pl']
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual capture command'
        assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries']), 'actual complete input guards'
        assert row['exit'] == 0, 'actual successful exit'
        decode(row['stdout']); assert decode(row['stderr']) == b'', 'actual empty outer stderr'
    check_fixtures(report['runs'][0])


def check_mixed(data):
    expected = oracle.author()
    assert data['action'] == expected['action'], 'exact mixed authored source'
    assert data['dependency_keys'] == sorted(['build_array_pipeline_plan_from_expr', 'normalize_method_args_with_optional_scope', 'parse_method_function_expr', 'split_action_ir_statements', 'trim_action_ir_value']), 'original five callbacks'
    assert data['failure'] is None and data['internal_stdout'] == data['internal_stderr'] == '', 'complete clean Toolbox inspection'
    assert isinstance(data['substitution'], str) and isinstance(data['diagnostics'], dict) and data['dump'].startswith('# LinkedSpec generated parser source.'), 'complete Toolbox outputs'
    frames = [{'source': expected['action'], **frame} for frame in expected['statements']]
    assert data['statement_frames'] == frames, 'authored mixed statement frames'
    assert [r['contract'] for r in data['rows']] == [c['id'] for c in expected['contracts']], 'exact nineteen-contract population and order'
    for row, contract in zip(data['rows'], expected['contracts'], strict=True):
        events = [{'raw': e['raw'], 'args': e['args']} for e in contract['events']]
        assert row['public_events'] == events, 'authored exact public arguments and occurrences'
        assert row['private_result']['events'] == events, 'unchanged private public events'
        origins = [{'event': event, 'source': expected['action'], 'source_span': authored['source_span']}
                   for event, authored in zip(events, contract['events'], strict=True)] if contract['id'] == 'set_value' else []
        assert row['private_result']['source_origins'] == origins, 'only existing set_value has original origins'
        assert len(row['identity']) == len(origins) and all(
            set(identity) == {'origin_event', 'constructed_event', 'constructed_args'}
            and all(value is True for value in identity.values())
            for identity in row['identity']), 'original set_value event and argument reference identities'
        assert row['private_calls'] == row['public_calls'], 'unchanged original callback sequence arguments and results'
        if contract['family'] == 'statement':
            assert row['public_calls'][0] == {'callback': 'split_action_ir_statements', 'args': [expected['action']], 'result': [f['raw'] for f in expected['statements']]}, 'original statement split invocation and result'
        plans = [c for c in row['public_calls'] if c['callback'] == 'build_array_pipeline_plan_from_expr']
        if contract['id'] in {r[0] for r in oracle.REGEX[3:]}:
            assert len(plans) == 3 and all(c['args'] == [contract['events'][0]['raw']] for c in plans), 'exact original plan expression inputs'
            name = contract['id']
            op = {'op': 'split', 'source_expr': '$input', 'delimiter_expr': '/\\,/'} if name == 'split_array' else {'op': 'split_each', 'delimiter_expr': '/\\,/'} if name == 'split_each' else {'op': 'filter_match', 'pattern_expr': '/a/'} if name == 'filter_match' else {'op': 'uniq' if name == 'uniq_array' else name}
            plan = {'binding_target': 1, 'target_symbol': 'items', 'ops': [op]}
            assert all(c['result'] == plan for c in plans), 'independent literal original pipeline plans'
        else:
            assert plans == [], 'unrelated contracts never request array plans'
        for event in contract['events']:
            span = event['source_span']
            assert all(type(v) is int for v in span.values()), 'authored scalar coordinate types'
            assert expected['action'][span['start']:span['end']] == event['raw'], 'authored source slice'


def check_split(data):
    expr = "split(items, input, ',')"
    assert data['expr'] == expr and data['failure'] is None and data['internal_stdout'] == data['internal_stderr'] == '', 'complete split Toolbox diagnosis'
    assert data['plan'] == {'binding_target': 1, 'target_symbol': 'items', 'ops': [{'op': 'split', 'source_expr': '$input', 'delimiter_expr': '/\\,/'}]}, 'independent split planner input expression'
    event = {'raw': expr, 'args': {'target': 'items', 'source': None, 'delimiter': '/\\,/'}}
    assert data['events'] == [event], 'retained original null source defect'
    assert data['substitution'] == 'do { require LinkedSpec::BindingRuntime; $items = LinkedSpec::BindingRuntime::split_value($items, "items", $input, qr/\\,/); $items }', 'original lowering retains input expression'
    helper = [e for e in data['diagnostics']['helper_action_ir_events'] if e['contract_id'] == 'split_array']
    assert len(helper) == 1 and helper[0]['args'] == event['args'], 'Toolbox descriptor repeats scanner metadata'
    assert data['dump'].startswith('# LinkedSpec generated parser source.'), 'split generated source retained'


def check_foreign(data):
    event = {'raw': 'my $other', 'args': {'declaration_type': 'scalar', 'names': ['other'], 'scope': 'my'}}
    assert data == {'source': 'my $input;', 'public': [event], 'private': {'events': [event], 'source_origins': []}}, 'literal foreign-source boundary'


def main():
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    regular, overlays = check_inputs(manifest)
    assert json.loads(Path(PREFIX + 'cases.json').read_bytes()) == oracle.author(), 'independent literal authored fixture'
    check_report(report, manifest)
    for row in report['runs'][1:4]:
        check_mixed(json.loads(decode(row['stdout'])))
    for row in report['runs'][4:7]:
        check_foreign(json.loads(decode(row['stdout'])))
    check_split(json.loads(decode(report['runs'][7]['stdout'])))
    assert len({decode(r['stdout']) for r in report['runs'][1:4]}) == len({decode(r['stdout']) for r in report['runs'][4:7]}) == 1, 'exact cross-seed channels'
    controls = []
    def reject(name, subject, change, verifier, reason):
        candidate = copy.deepcopy(subject); change(candidate)
        try: verifier(candidate)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else: raise AssertionError('accepted corruption: ' + name)
    data = json.loads(decode(report['runs'][1]['stdout']))
    reject('erase contract', data, lambda d:d['rows'].pop(), check_mixed, 'exact nineteen-contract population and order')
    reject('change original argument', data, lambda d:d['rows'][0]['public_events'][0]['args'].update(value='Wrong'), check_mixed, 'authored exact public arguments and occurrences')
    reject('erase original event', data, lambda d:d['rows'][0]['public_events'].pop(), check_mixed, 'authored exact public arguments and occurrences')
    reject('reuse equal raw set occurrence', data, lambda d:d['rows'][1]['private_result']['source_origins'].__setitem__(1,d['rows'][1]['private_result']['source_origins'][0]), check_mixed, 'only existing set_value has original origins')
    reject('invent uninstrumented origin', data, lambda d:d['rows'][0]['private_result']['source_origins'].append({}), check_mixed, 'only existing set_value has original origins')
    reject('forge argument identity', data, lambda d:d['rows'][1]['identity'][0].update(constructed_args=False), check_mixed, 'original set_value event and argument reference identities')
    reject('erase callback result', data, lambda d:d['rows'][0]['private_calls'][0].update(result=None), check_mixed, 'unchanged original callback sequence arguments and results')
    reject('erase ignored frame', data, lambda d:d['statement_frames'].pop(0), check_mixed, 'authored mixed statement frames')
    reject('promote public schema', data, lambda d:d['rows'][0]['private_result']['events'][0].update(source_span={}), check_mixed, 'unchanged private public events')
    reject('forge compiler success', data, lambda d:d.update(failure='failed'), check_mixed, 'complete clean Toolbox inspection')
    reject('invent foreign origin', json.loads(decode(report['runs'][4]['stdout'])), lambda d:d['private']['source_origins'].append({}), check_foreign, 'literal foreign-source boundary')
    reject('erase supplied input', manifest, lambda d:d['entries'].pop(0), check_inputs, 'complete unique Git membership')
    reject('forge supplied bytes', manifest, lambda d:d['entries'][0].update(sha256='0'*64), check_inputs, 'original Git member bytes')
    reject('erase overlay', manifest, lambda d:d['entries'].pop(), check_inputs, 'exact authored overlay membership')
    verify = lambda d:check_report(d,manifest)
    reject('promote incomplete capture', report, lambda d:d.update(complete=False), verify, 'complete exact-source capture')
    reject('forge producer', report, lambda d:d.update(instrument_sha256='0'*64), verify, 'actual capture producer')
    reject('promote failed command', report, lambda d:d['runs'][1].update(exit=1), verify, 'actual successful exit')
    reject('forge channel', report, lambda d:d['runs'][1]['stdout'].update(sha256='0'*64), verify, 'channel bytes')
    fixture=report['runs'][0];text=decode(fixture['stdout']).decode()
    reject('shorten TAP plan', fixture, lambda d:d.update(stdout=envelope(text.replace('\n1..28\n','\n1..27\n',1).encode())), check_fixtures, 'complete ordered positive fixture reach')
    reject('promote nested TAP failure', fixture, lambda d:d.update(stdout=envelope(text.replace('    ok 1 -','    not ok 1 -',1).encode())), check_fixtures, 'no nested fixture failure')
    split=json.loads(decode(report['runs'][7]['stdout']))
    reject('hide original metadata defect',split,lambda d:d['events'][0]['args'].update(source='$input'),check_split,'retained original null source defect')
    reject('drop planner input expression',split,lambda d:d['plan']['ops'][0].pop('source_expr'),check_split,'independent split planner input expression')
    counts=check_fixtures(fixture); expected=oracle.author()
    summary={'complete':True,'revision':REVISION,'regular_inputs':regular,'overlays':overlays,'contracts':len(expected['contracts']),'seeds':3,
             'authored_statement_frames':len(expected['statements'])*3,'selected_events':sum(len(c['events']) for c in expected['contracts'])*3,
             'existing_origins':9,'contracts_without_origins':18,'fixture_suites':len(TESTS),'fixture_plans':counts,'fixture_groups':sum(counts),
             'foreign_probes':3,'split_source_defect_reproduced':True,'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='controls'}))

if __name__ == '__main__':main()

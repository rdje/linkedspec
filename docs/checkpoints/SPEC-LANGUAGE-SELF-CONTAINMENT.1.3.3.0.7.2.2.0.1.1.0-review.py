"""Review the nine-contract proof and execute distinguishing evidence corruptions."""
from pathlib import Path
import copy
import hashlib
import html as html_module
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
BASE = '80ecf47f258a7f23a59598a1c5500a34fe662a7c'
spec = importlib.util.spec_from_file_location('streams', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)


def check(condition, message):
    if not condition:
        raise ValueError(message)


def historical(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def digest(data):
    return hashlib.sha256(data).hexdigest()


names = ('cases', 'before', 'after', 'tests-before', 'tests-after', 'consumers', 'book')
evidence = {name: json.loads((ROOT / (PREFIX + name + '.json')).read_bytes()) for name in names}
for mode in ('before', 'after'):
    for row in evidence[mode]['cases']:
        row['decoded'] = json.loads(streams.unpack(row['stdout']))


def verify(data):
    contracts = ['assign_call_my', 'assign_call', 'push_child_call_indexed_builtin',
                 'push_child_call_builtin', 'return_call', 'entry_slot', 'gap_span', 'gap_text', 'gap_kind']
    cases = data['cases']
    check([case['contract'] for case in cases] == contracts, 'exact nine-contract source population')
    check([case['starts'] for case in cases] == [[8, 32, 52], [8, 29, 46], [8, 38, 64],
          [8, 33, 54], [8, 31, 50], [8, 27, 42], [8, 24, 36], [8, 25, 38], [8, 24, 36]],
          'independent positions for the nine named authored inputs')
    population = [(case['id'], seed) for case in cases for seed in (0, 1, 2)]
    for mode in ('before', 'after'):
        rows = data[mode]['cases']
        check([(row['id'], row['seed']) for row in rows] == population, 'complete named source/seed population')
        for row in rows:
            result = row['decoded']
            check(json.loads(streams.unpack(row['stdout'])) == result, 'lossless original probe envelope')
            check(row['exit'] == 0 and not streams.unpack(row['stderr']), 'original external process channels')
            check(not result['failure'] and not result['internal_stdout'] and not result['internal_stderr'], 'successful compiler probe and clean internal channels')
            check(result['dump'] and result['emitted'] and isinstance(result['diagnostics'], dict), 'concrete inspected compiler outputs')
            case = next(case for case in cases if case['id'] == row['id'])
            check(result['action'] == case['action'] and result['source'] == case['source'], 'exact authored input')
            check(result['source_sha256'] == digest(case['source'].encode()), 'original UTF-8 source digest')
            check(result['seed'] == str(row['seed']) and result['perturb'] == '2', 'observed seed environment')
            check(result['provenance_available'] == 1, 'private entry already exists at activation')
            events = result['public_events']
            check([event['raw'] for event in events] == case['raws'], 'independent authored raw occurrence list')
            check(all(set(event) == {'raw', 'args'} for event in events), 'unchanged public event schema')
            private = result['private_result']
            check(private['events'] == events, 'unchanged original arguments and events')
            origins = private['source_origins']
            if mode == 'before':
                check(origins == [], 'actual absent basic producer origins')
            else:
                check(len(origins) == len(case['starts']), 'one origin per selected event')
                for index, origin in enumerate(origins):
                    raw = case['raws'][index]
                    span = {'start': case['starts'][index], 'end': case['starts'][index] + len(raw)}
                    check(origin['source'] == case['action'], 'original full-source frame')
                    check(origin['source_span'] == span, 'independently authored scalar positions')
                    check(all(type(value) is int for value in origin['source_span'].values()), 'scalar coordinate types')
                    check(case['action'][span['start']:span['end']] == raw, 'original unmasked source slice')
                    check(origin['event'] == events[index], 'exact event/argument correlation')
    public_fields = ('id', 'source', 'source_sha256', 'action', 'seed', 'perturb', 'public_events',
                     'substitution', 'diagnostics', 'dump', 'emitted', 'failure', 'internal_stdout', 'internal_stderr')
    for old, new in zip(data['before']['cases'], data['after']['cases'], strict=True):
        for field in public_fields:
            check(old['decoded'][field] == new['decoded'][field], 'unchanged public ' + field)
    test_digest = digest((ROOT / 't/actionir_basic_regex_source_provenance.t').read_bytes())
    for mode in ('before', 'after'):
        run = data['tests-' + mode]
        text = streams.unpack(run['stdout']).decode()
        check(run['test_sha256'] == test_digest, 'same permanent test input')
        check(re.findall(r'^1\.\.(\d+)$', text, re.M) == ['10'], 'complete permanent test plan')
        failed = [int(value) for value in re.findall(r'^not ok (\d+) -', text, re.M)]
        if mode == 'before':
            check(run['exit'] == 1 and failed == list(range(1, 10)), 'actual nine-group producer RED')
            check(re.search(r'^ok 10 -', text, re.M), 'empty owned-result guard remains GREEN before')
        else:
            check(run['exit'] == 0 and not failed and not streams.unpack(run['stderr']), 'complete permanent GREEN')
            check(len(re.findall(r'^ok \d+ -', text, re.M)) == 10, 'all ten GREEN groups reached')
    expected_suites = ['t/phase0_regression.t', 't/actionir_helper_source_provenance.t',
                       't/inter_match_gap_capture_perl_contract.t', 't/actionir_ast_parser.t',
                       't/trace_actionir_pipeline.t', 't/canonical_event_occurrence_order.t',
                       't/actionir_raw_dependency_metadata.t', 't/actionir_raw_dependency_provenance.t',
                       't/actionir_raw_dependency_compatibility.t', 't/actionir_nested_block_source_spans.t',
                       't/noncurrent_helper_metadata.t', 't/generated_source_contract.t', 't/codeblock_matches_perl.t']
    check([row['test'] for row in data['consumers']['rows']] == expected_suites, 'unchanged direct-consumer population')
    tests = 0
    for row in data['consumers']['rows']:
        text = streams.unpack(row['stdout']).decode()
        streams.unpack(row['stderr'])
        plans = re.findall(r'^1\.\.(\d+)$', text, re.M)
        check(row['exit'] == 0 and len(plans) == 1 and not re.search(r'^not ok ', text, re.M), 'complete GREEN ' + row['test'])
        count = int(plans[0])
        check(count > 0 and len(re.findall(r'^ok \d+ -', text, re.M)) == count, 'all planned assertions reached ' + row['test'])
        tests += count
    book = data['book']
    check(book['exit'] == 0, 'actual mdBook render')
    streams.unpack(book['stdout'])
    streams.unpack(book['stderr'])
    check(b'Nine basic regex contracts also retain' in streams.unpack(book['html']), 'rendered bounded private coverage')
    check([row['source'] for row in book['source_examples']] == [cases[index]['source'] for index in (0, 7)], 'source-identical rendered examples')
    rendered_blocks = [html_module.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n') for block in
                       re.findall(r'<code class="language-spec">(.*?)</code>', streams.unpack(book['html']).decode(), re.S)]
    check(all(example['source'].replace('\r\n', '\n').rstrip('\n') in rendered_blocks
              for example in book['source_examples']), 'actual rendered example bytes after explicit newline normalization')
    return tests


initial_capture = (ROOT / (PREFIX + 'capture-initial.py')).read_text()
check((ROOT / (PREFIX + 'capture.py')).read_text() == initial_capture.replace('Capture six exact sources over seeds0/1/2', 'Capture exact authored sources over seeds0/1/2'), 'retained executed capture bytes; only header wording corrected')
owner_path = 'perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm'
check((ROOT / (PREFIX + 'before-PrimitiveBasicRules.pm')).read_bytes() == historical(owner_path), 'exact frozen original owner')
tracked = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs', 't', 'tools/run_ci_local.sh',
                                   'tests/language-readiness/verify_objectives.py'], cwd=ROOT).decode().split('\0')
for path in filter(None, tracked):
    file = ROOT / path
    if path != owner_path and path != 't/actionir_basic_regex_source_provenance.t' and file.is_file() and not file.is_symlink():
        check(file.read_bytes() == historical(path), 'activation-exact direct owner ' + path)
prior_path = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0.json'
prior = json.loads((ROOT / prior_path).read_bytes())['claims'][0]['durability']
check(prior['mode'] == 'historical' and prior['revision'] == BASE, 'prior live claim is historically frozen')
check(prior['inputs'] == json.loads(historical(prior_path))['claims'][0]['durability']['inputs'], 'unchanged prior artifact identities')
tests = verify(evidence)
controls = []


def reject(name, mutation):
    changed = copy.deepcopy(evidence)
    mutation(changed)
    for mode in ('before', 'after'):
        for row in changed[mode]['cases']:
            row['stdout'] = streams.envelope(json.dumps(row['decoded']).encode())
    try:
        verify(changed)
    except (ValueError, AssertionError, KeyError) as error:
        controls.append({'name': name, 'rejected': True, 'reason': str(error)})
    else:
        raise ValueError('unrejected evidence corruption ' + name)


reject('move_real_match_to_quoted_twin', lambda x: x['after']['cases'][0]['decoded']['private_result']['source_origins'][1]['source_span'].update(start=8))
reject('lose_repeated_origin', lambda x: x['after']['cases'][3]['decoded']['private_result']['source_origins'].pop())
reject('public_source_field', lambda x: x['after']['cases'][0]['decoded']['public_events'][0].update(source_span={'start': 0, 'end': 1}))
reject('alter_original_arguments', lambda x: x['after']['cases'][0]['decoded']['private_result']['events'][0]['args'].update(callee='Changed'))
reject('substitution_drift', lambda x: x['after']['cases'][0]['decoded'].update(substitution='changed'))
reject('diagnostics_drift', lambda x: x['after']['cases'][0]['decoded'].update(diagnostics={'changed': True}))
reject('emission_drift', lambda x: x['after']['cases'][0]['decoded'].update(emitted='changed'))
reject('source_frame_drift', lambda x: x['after']['cases'][0]['decoded']['private_result']['source_origins'][0].update(source='changed'))
reject('missing_seed', lambda x: x['after']['cases'].pop())
reject('hide_before_RED', lambda x: x['tests-before'].update(stdout=streams.envelope(streams.unpack(x['tests-before']['stdout']).replace(b'not ok 1 -', b'ok 1 -'))))
reject('fail_after_guard', lambda x: x['tests-after'].update(stdout=streams.envelope(streams.unpack(x['tests-after']['stdout']).replace(b'ok 10 -', b'not ok 10 -'))))
reject('book_example_drift', lambda x: x['book']['source_examples'][0].update(source='changed'))
report = {'owner': OWNER, 'activation': BASE, 'sources': len(evidence['cases']),
          'before_after_pairs': len(evidence['after']['cases']),
          'private_origins': sum(len(row['decoded']['private_result']['source_origins']) for row in evidence['after']['cases']),
          'red_groups': 10, 'failed_groups': 9, 'green_groups': 10, 'consumer_tests': tests,
          'suites': [{'path': row['test']} for row in evidence['consumers']['rows']], 'book_examples': 2,
          'rejected_evidence_controls': controls}
(ROOT / (PREFIX + 'verification.json')).write_text(json.dumps(report, indent=2) + '\n')
print(f"PASS {report['before_after_pairs']} public identities, {report['private_origins']} origins, {tests} unchanged tests, {len(controls)} evidence controls")

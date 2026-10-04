"""Read-only source-bound review; mutations alter in-memory evidence only."""
from pathlib import Path
import copy
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-'
BASE = 'ea45d933d6af8776bb4205514f423e3b7627af0d'
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)

def load(name):
    return json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())

def check(condition, message):
    if not condition:
        raise ValueError(message)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def git_bytes(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)

evidence = {name: load(name) for name in ['mapping-cases', 'mapping', 'inventory',
                                        'tests-before', 'replay-red', 'consumers', 'book']}
evidence['probe'] = json.loads(capture.unpack(evidence['mapping']['stdout']))

def verify(data):
    cases = data['mapping-cases']
    rows = data['probe']['cases']
    check(len(cases) == len(rows) == 2, 'mapping population')
    check(data['mapping']['exit'] == 0 and not capture.unpack(data['mapping']['stderr']), 'probe process channels')
    check(data['probe']['seed'] == '0' and data['probe']['perturb'] == '2', 'observed seed')
    check(json.loads(capture.unpack(data['mapping']['stdout'])) == data['probe'], 'complete probe envelope')
    fixed = [
        ('''return('return("x")'); return("x")''', [0,23],
         ['''return('return("x")')''', 'return("x")']),
        ('text="set(counter,1)"; set(counter,2); set(counter,1); return(counter)', [23,39],
         ['set(counter,2)', 'set(counter,1)']),
    ]
    for case, row, (action, starts, raws) in zip(cases, rows, fixed, strict=True):
        check(case['action'] == row['action'] == action, 'authored action')
        check(case['source'] == row['source'] == 'Top:: I { '+action+' }', 'authored source')
        check(row['source_sha256'] == sha(row['source'].encode()), 'source digest')
        check(case['real_starts'] == starts and case['real_raws'] == raws, 'independent real occurrence list')
        ast = row['ast']
        check(ast['source'] == action and ast['source_span'] == {'start':0, 'end':len(action)}, 'typed source frame')
        selected = ast['statements'][:2] if case['id'] == 'suppressed_quoted_return' else ast['statements'][1:3]
        check([stmt['source_span']['start'] for stmt in selected] == starts, 'typed real call spans')
        check([stmt['expr']['source'] for stmt in selected] == raws, 'typed real calls')
        literal = ast['statements'][0]['expr']['args'][0] if case['id'] == 'suppressed_quoted_return' else ast['statements'][0]['expr']['value']
        check(literal['kind'] == 'string' and literal['value'] == case['quoted_raw'], 'typed quoted data')
        events = [event for event in row['diagnostics']['helper_action_ir_events'] if event['contract_id'] == case['contract']]
        expected_raws = raws if case['id'] == 'suppressed_quoted_return' else [raws[1],raws[0],raws[1]]
        check([event['raw'] for event in events] == expected_raws, 'measured scan occurrence stream')
        check(all(set(event) == {'ir_node','contract_id','raw','args','exclusive_statement'} for event in events), 'public event projection')
    simulations = data['mapping']['candidate_simulations']
    check(len(simulations) == 2, 'candidate population')
    check(simulations[0]['actual_kept'] == [{'raw':fixed[0][2][0], 'start':0}], 'candidate false drop')
    check(simulations[1]['actual_kept'] == [{'raw':'set(counter,1)', 'start':39}, {'raw':'set(counter,2)', 'start':23}], 'candidate wrong order')
    check([d['mapped_start'] for d in simulations[0]['decisions']] == [0,8], 'candidate quoted twin match')
    check([d['mapped_start'] for d in simulations[1]['decisions']] == [39,23,-1], 'candidate twin exhaustion')
    for index, simulation in enumerate(simulations):
        expected = [{'raw':raw, 'start':start} for raw,start in zip(fixed[index][2],fixed[index][1],strict=True)]
        check(simulation['expected'] == expected and simulation['actual_kept'] != expected and simulation['oracle_matches'] is False, 'candidate RED oracle')
    for name in ['tests-before','replay-red']:
        run = data[name]
        text = capture.unpack(run['stdout']).decode()
        capture.unpack(run['stderr'])
        check(run['exit'] == 1 and re.search(r'^1\.\.13$',text,re.M), 'complete RED plan')
        check([int(n) for n in re.findall(r'^not ok (\d+) -',text,re.M)] == list(range(1,12)), 'eleven actual RED groups')
        check(re.search(r'^ok 12 -',text,re.M) and re.search(r'^ok 13 -',text,re.M), 'true unsupported and opaque guards')
        check(run['test_sha256'] == sha((ROOT / (PREFIX+'red-fixture.t')).read_bytes()), 'exact preserved fixture bytes')
    check(not (ROOT / 't/actionir_quoted_source_ownership.t').exists(), 'no failing recurring test installed')
    families = data['inventory']['families']
    suffixes = ['StagedParseJob','ProgressiveSpanDispatch','Scanner/RecognitionTransactionRules',
                'Scanner/PrimitiveBasicRules','Scanner/PrimitivePipelineRules','Scanner/FlowRules','Scanner/LegacyRules']
    check([row['path'] for row in families] == ['perl/LinkedSpec/ActionIR/'+s+'.pm' for s in suffixes], 'exact seven scanner families')
    check(data['inventory']['core_sha256'] == sha(git_bytes(data['inventory']['core_path'])), 'core inventory binding')
    for family in families:
        check(family['sha256'] == sha(git_bytes(family['path'])), 'family inventory binding')
        source = git_bytes(family['path']).decode().splitlines()
        for function in family['event_producer_functions']:
            check(source[function['line']-1].startswith('sub '+function['name']+' {'), 'producer source location')
    calls = [call for function in families[5]['event_producer_functions'] for call in function['nested_or_composed_event_calls']]
    check(len(calls) == 6, 'nested and composed source frames')
    suites = data['consumers']
    check([row['path'] for row in suites] == ['t/canonical_event_occurrence_order.t','t/actionir_ast_parser.t','t/noncurrent_helper_metadata.t','t/trace_actionir_pipeline.t'], 'consumer population')
    counts = []
    for suite in suites:
        text = capture.unpack(suite['stdout']).decode()
        capture.unpack(suite['stderr'])
        plans = re.findall(r'^1\.\.(\d+)$',text,re.M)
        check(suite['exit'] == 0 and len(plans) == 1 and not re.search(r'^not ok ',text,re.M), 'consumer complete GREEN')
        counts.append(int(plans[0]))
    check(counts == [15,23,2,5], 'unchanged consumer test plans')
    book = data['book']
    check(book['exit'] == 0, 'render process')
    capture.unpack(book['stdout']); capture.unpack(book['stderr'])
    html = capture.unpack(book['html'])
    check(b'Both candidate mappings were executed' in html and b'eleven of thirteen' in html, 'actual rendered explanation')
    check([row['source'] for row in book['source_examples']] == [case['source'] for case in cases], 'render example identity')
    return counts

# Current diagnosis publishes no production, standard-test, CI or spec changes.
paths = subprocess.check_output(['git','ls-files','-z','--','perl','specs','t','tools/run_ci_local.sh','tests/language-readiness/verify_objectives.py'],cwd=ROOT).decode().split('\0')
for path in filter(None,paths):
    file = ROOT / path
    if file.is_file() and not file.is_symlink():
        check(file.read_bytes() == git_bytes(path), 'unchanged production/standard owner: '+path)
for name in ['MethodExpr','ScannerCore','RewritePipeline']:
    check((ROOT/(PREFIX+'before-'+name+'.pm')).read_bytes() == git_bytes('perl/LinkedSpec/ActionIR/'+name+'.pm'), 'frozen original module: '+name)
initial = load('cases-initial')
corrected = load('cases')
row = next(case for case in initial if case['id'] == 'regex_call_spelling')
check(row['expected'] == 1, 'preserved initial regex oracle')
row['expected'] = 0
check(initial == corrected, 'only pre-runtime regex expected value corrected')
prior_path = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1.json'
prior = json.loads((ROOT/prior_path).read_bytes())['claims'][0]['durability']
check(prior['mode'] == 'historical' and prior['revision'] == BASE, 'prior diagnosis historical freeze')
check(prior['inputs'] == json.loads(git_bytes(prior_path))['claims'][0]['durability']['inputs'], 'prior input manifest unchanged')
counts = verify(evidence)
controls = []

def reject(name, mutation):
    changed = copy.deepcopy(evidence)
    mutation(changed)
    # Keep a complete, internally hashed envelope when changing parsed probe evidence.
    changed['mapping']['stdout'] = capture.envelope(json.dumps(changed['probe']).encode())
    try:
        verify(changed)
    except (ValueError, AssertionError, KeyError) as error:
        controls.append({'name':name, 'rejected':True, 'reason':str(error)})
    else:
        raise ValueError('unrejected evidence control: '+name)

def hide_quoted_set(data):
    events = data['probe']['cases'][1]['diagnostics']['helper_action_ir_events']
    index = next(i for i,event in enumerate(events) if event['contract_id'] == 'set_value')
    del events[index]

reject('hide_real_return', lambda x: x['probe']['cases'][0]['diagnostics']['helper_action_ir_events'].pop())
reject('hide_quoted_set', hide_quoted_set)
reject('erase_typed_string', lambda x: x['probe']['cases'][0]['ast']['statements'][0]['expr']['args'][0].update(kind='raw'))
reject('move_independent_real_occurrence', lambda x: x['mapping-cases'][0]['real_starts'].__setitem__(1,8))
reject('hide_candidate_false_drop', lambda x: x['mapping']['candidate_simulations'][0].update(actual_kept=x['mapping']['candidate_simulations'][0]['expected']))
reject('hide_candidate_wrong_order', lambda x: x['mapping']['candidate_simulations'][1].update(actual_kept=x['mapping']['candidate_simulations'][1]['expected']))
reject('truncate_red_plan', lambda x: x['replay-red'].update(stdout=capture.envelope(capture.unpack(x['replay-red']['stdout']).replace(b'1..13\n',b'1..12\n'))))
reject('hide_red_group', lambda x: x['replay-red'].update(stdout=capture.envelope(capture.unpack(x['replay-red']['stdout']).replace(b'not ok 11 -',b'ok 11 -'))))
reject('hide_true_guard_failure', lambda x: x['replay-red'].update(stdout=capture.envelope(capture.unpack(x['replay-red']['stdout']).replace(b'ok 12 -',b'not ok 12 -'))))
reject('omit_scanner_family', lambda x: x['inventory']['families'].pop())
reject('drift_family_source', lambda x: x['inventory']['families'][0].update(sha256='0'*64))
reject('change_rendered_source_example', lambda x: x['book']['source_examples'][0].update(source='Top:: I { return("wrong") }'))
report = {'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0','activation':BASE,
          'public_probe_sources':2, 'candidate_mapper_failures':2, 'red_groups':13, 'failed_groups':11,
          'green_guard_groups':2, 'suites':[{'path':row['path'],'tests':count} for row,count in zip(evidence['consumers'],counts,strict=True)],
          'consumer_tests':sum(counts), 'scanner_families':7, 'book_examples':2,
          'rejected_evidence_controls':controls}
(ROOT/(PREFIX+'verification.json')).write_text(json.dumps(report,indent=2)+'\n')
print(f'PASS source-bound diagnosis; {len(controls)} evidence controls reject; {sum(counts)} unchanged consumer tests')

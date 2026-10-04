"""Review immutable observations against independent source/span/public oracles."""
from pathlib import Path
import copy
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0-'
BASE = '8d71b3b5cbea894416c14a9fade10968a73a8a5f'
spec = importlib.util.spec_from_file_location('streams', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)

def load(name):
    return json.loads((ROOT/(PREFIX+name+'.json')).read_bytes())

def check(condition,message):
    if not condition:
        raise ValueError(message)

def digest(data):
    return hashlib.sha256(data).hexdigest()

def historical(path):
    return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)

evidence = {name:load(name) for name in ['cases','before','after','tests-before','tests-after','consumers','book']}
for mode in ['before','after']:
    for row in evidence[mode]['cases']:
        row['decoded'] = json.loads(streams.unpack(row['stdout']))

def verify(data):
    cases = data['cases']
    check(len(cases)==6 and len({case['id'] for case in cases})==6,'six exact source inputs')
    expected_starts = [[0,23],[6,23,39],[8,20],[11,32],[0,29],[0,39]]
    check([case['starts'] for case in cases]==expected_starts,'independent source positions')
    expected_population = [(case['id'],seed) for case in cases for seed in (0,1,2)]
    for mode in ['before','after']:
        rows = data[mode]['cases']
        check([(row['id'],row['seed']) for row in rows]==expected_population,'complete named source/seed population')
        for row in rows:
            result = row['decoded']
            check(json.loads(streams.unpack(row['stdout']))==result,'complete probe envelope')
            check(row['exit']==0 and not streams.unpack(row['stderr']),'external probe channels')
            check(not result['failure'] and not result['internal_stdout'] and not result['internal_stderr'],'internal compiler channels')
            case = next(case for case in cases if case['id']==row['id'])
            check(result['action']==case['action'] and result['source']==case['source'],'original source/action')
            check(case['source']=='Top:: I { '+case['action']+' }','source framing')
            check(result['source_sha256']==digest(case['source'].encode()),'UTF-8 source digest')
            check(result['seed']==str(row['seed']) and result['perturb']=='2','observed seeded environment')
            check(result['provenance_available']==(mode=='after'),'private availability is explicit')
            check([event['raw'] for event in result['public_events']]==case['raws'],'independent scanner raw list')
            check(all(set(event)=={'raw','args'} for event in result['public_events']),'unchanged public event fields')
            check(result['private_result']['events']==result['public_events'],'private event/argument preservation')
            origins = result['private_result']['source_origins']
            if mode=='before':
                check(origins==[],'before feature absence; no invented spans')
            else:
                check(len(origins)==len(case['starts']),'one origin for each actual selected match')
                for index,origin in enumerate(origins):
                    raw = case['raws'][index]
                    expected = {'start':case['starts'][index],'end':case['starts'][index]+len(raw)}
                    check(origin['source']==case['action'],'complete original source frame')
                    check(origin['source_span']==expected and all(type(value) is int for value in origin['source_span'].values()),'independent scalar source span')
                    check(case['action'][expected['start']:expected['end']]==raw,'original source slice')
                    check(origin['event']==result['private_result']['events'][index],'origin/event correlation')
            check(result['dump'] and result['emitted'] and isinstance(result['diagnostics'],dict),'concrete public compiler outputs')
    fields = ['id','source','source_sha256','action','seed','perturb','public_events','substitution',
              'diagnostics','dump','emitted','failure','internal_stdout','internal_stderr']
    for old,new in zip(data['before']['cases'],data['after']['cases'],strict=True):
        for field in fields:
            check(old['decoded'][field]==new['decoded'][field],'unchanged public '+field)
    test_digest = digest((ROOT/'t/actionir_helper_source_provenance.t').read_bytes())
    for mode in ['before','after']:
        run = data['tests-'+mode]
        text = streams.unpack(run['stdout']).decode()
        error = streams.unpack(run['stderr'])
        check(run['test_sha256']==test_digest,'same permanent test bytes')
        check(re.findall(r'^1\.\.(\d+)$',text,re.M)==['13'],'complete permanent test plan')
        failed = [int(value) for value in re.findall(r'^not ok (\d+) -',text,re.M)]
        if mode=='before':
            check(run['exit']==1 and failed==[1,2,3,4,5,6,7,10,11,12,13],'actual provenance RED groups')
            check(re.search(r'^ok 8 -',text,re.M) and re.search(r'^ok 9 -',text,re.M),'before empty/opaque/caller-error guards')
        else:
            check(run['exit']==0 and not failed and not error,'actual complete provenance GREEN')
            check(len(re.findall(r'^ok \d+ -',text,re.M))==13,'all thirteen GREEN groups reached')
    expected_suites = [
        ('t/phase0_regression.t',1034),('t/actionir_ast_parser.t',23),('t/trace_actionir_pipeline.t',5),
        ('t/canonical_event_occurrence_order.t',15),('t/actionir_raw_dependency_metadata.t',16),
        ('t/actionir_raw_dependency_provenance.t',6),('t/actionir_raw_dependency_compatibility.t',27),
        ('t/actionir_nested_block_source_spans.t',20),('t/noncurrent_helper_metadata.t',2),
        ('t/generated_source_contract.t',12),('t/codeblock_matches_perl.t',39),
    ]
    rows = data['consumers']['rows']
    check([row['test'] for row in rows]==[path for path,_ in expected_suites],'unchanged consumer population')
    for row,(path,count) in zip(rows,expected_suites,strict=True):
        text = streams.unpack(row['stdout']).decode()
        streams.unpack(row['stderr'])
        check(row['exit']==0 and re.findall(r'^1\.\.(\d+)$',text,re.M)==[str(count)] and not re.search(r'^not ok ',text,re.M),'complete GREEN consumer '+path)
    book = data['book']
    check(book['exit']==0,'actual book render')
    streams.unpack(book['stdout']); streams.unpack(book['stderr'])
    html = streams.unpack(book['html'])
    check(b'The first provenance step now records' in html and b'original event object and arguments' in html,'rendered current private scope')
    check([row['source'] for row in book['source_examples']]==[case['source'] for case in cases[:2]],'exact rendered source examples')
    return sum(count for _,count in expected_suites)

owners = {'ScannerCore':'perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'LegacyRules':'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm',
          'PrimitivePipelineRules':'perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm',
          'FlowRules':'perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm'}
for name,path in owners.items():
    check((ROOT/(PREFIX+'before-'+name+'.pm')).read_bytes()==historical(path),'exact original owner '+name)
tracked = subprocess.check_output(['git','ls-files','-z','--','perl','specs','t','tools/run_ci_local.sh','tests/language-readiness/verify_objectives.py'],cwd=ROOT).decode().split('\0')
for path in filter(None,tracked):
    file = ROOT/path
    if path not in owners.values() and path != 't/actionir_helper_source_provenance.t' and file.is_file() and not file.is_symlink():
        check(file.read_bytes()==historical(path),'unchanged direct production/test/CI owner '+path)
prior_path = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0.json'
prior = json.loads((ROOT/prior_path).read_bytes())['claims'][0]['durability']
check(prior['mode']=='historical' and prior['revision']==BASE,'prior claim historical freeze')
check(prior['inputs']==json.loads(historical(prior_path))['claims'][0]['durability']['inputs'],'unchanged prior claim manifest')
tests = verify(evidence)
controls = []

def reject(name,mutation):
    changed = copy.deepcopy(evidence)
    mutation(changed)
    for mode in ['before','after']:
        for row in changed[mode]['cases']:
            row['stdout'] = streams.envelope(json.dumps(row['decoded']).encode())
    try:
        verify(changed)
    except (ValueError,AssertionError,KeyError) as error:
        controls.append({'name':name,'rejected':True,'reason':str(error)})
    else:
        raise ValueError('unrejected evidence control: '+name)

def move_return_to_quoted_twin(data):
    data['after']['cases'][0]['decoded']['private_result']['source_origins'][1]['source_span'] = {'start':8,'end':19}

def hide_real_set_origin(data):
    data['after']['cases'][3]['decoded']['private_result']['source_origins'].pop()

reject('map_real_return_to_quoted_twin',move_return_to_quoted_twin)
reject('lose_real_set_origin',hide_real_set_origin)
reject('public_source_field_leak',lambda x:x['after']['cases'][0]['decoded']['public_events'][0].update(source_span={'start':0,'end':21}))
reject('masked_literal_argument',lambda x:x['after']['cases'][0]['decoded']['private_result']['events'][0]['args'].update(payload='blank'))
reject('public_substitution_drift',lambda x:x['after']['cases'][0]['decoded'].update(substitution='return "changed"'))
reject('public_diagnostics_drift',lambda x:x['after']['cases'][0]['decoded']['diagnostics'].update(canonical_action_ir_count=-1))
reject('emitted_source_drift',lambda x:x['after']['cases'][0]['decoded'].update(emitted=x['after']['cases'][0]['decoded']['emitted']+'\n#changed'))
reject('unicode_source_frame_drift',lambda x:x['after']['cases'][9]['decoded']['private_result']['source_origins'][0].update(source='changed snow frame'))
reject('missing_seeded_process',lambda x:x['after']['cases'].pop())
reject('hide_before_red_group',lambda x:x['tests-before'].update(stdout=streams.envelope(streams.unpack(x['tests-before']['stdout']).replace(b'not ok 2 -',b'ok 2 -'))))
reject('hide_after_guard_failure',lambda x:x['tests-after'].update(stdout=streams.envelope(streams.unpack(x['tests-after']['stdout']).replace(b'ok 9 -',b'not ok 9 -'))))
reject('rendered_source_example_drift',lambda x:x['book']['source_examples'][0].update(source='changed example'))
report = {'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0','activation':BASE,
          'sources':6,'before_after_pairs':18,'private_origins':sum(len(row['decoded']['private_result']['source_origins']) for row in evidence['after']['cases']),
          'private_contracts':['return_general','set_value','if_flow'],'red_groups':13,'failed_groups':11,'green_groups':13,
          'consumer_tests':tests,'suites':[{'path':row['test']} for row in evidence['consumers']['rows']],
          'book_examples':2,'rejected_evidence_controls':controls}
(ROOT/(PREFIX+'verification.json')).write_text(json.dumps(report,indent=2)+'\n')
print(f'PASS18 exact public before/after pairs,39 private origins,13 GREEN groups,{tests} unchanged tests,{len(controls)} rejected controls')

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
REVISION = '95e6a02935155b9ab7b5c30f79a3275529b803da'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
TESTS = ['t/actionir_statement_source_frames.t', 't/actionir_helper_source_provenance.t',
         't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t',
         't/uniform_binding_contract.t', 't/codeblock_push_composition_perl.t',
         't/trace_actionir_pipeline.t']
PRIOR = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-'
OWNER = 'perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm'
FIXTURE = 't/actionir_pipeline_split_source_metadata.t'
REGEX_FIXTURE = 't/actionir_pipeline_regex_source_provenance.t'
COMMON = [FIXTURE]+[Path(PREFIX+n).relative_to(ROOT).as_posix() for n in ('before-PrimitivePipelineRules.pm','oracle.py','cases.json','probe.pl')]
PLANS = [28,13,23,15,12,605,5]
REVIEW_INPUTS = [PRIOR+n for n in ('oracle.py','cases.json','probe.pl','split-probe.pl','verification.json')]
spec = importlib.util.spec_from_file_location('mixed_oracle', ROOT / (PRIOR + 'oracle.py'))
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)
meta_spec=importlib.util.spec_from_file_location('metadata_oracle',PREFIX+'oracle.py')
metadata_oracle=importlib.util.module_from_spec(meta_spec);meta_spec.loader.exec_module(metadata_oracle)


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
    epoch=manifest['epoch'];assert epoch in ('before','after'), 'exact before/after epoch'
    overlays_expected=COMMON+([OWNER,REGEX_FIXTURE] if epoch=='after' else [])
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
    assert len(entries) == len(manifest['entries']) and supplied.keys() == actual.keys()-({OWNER,REGEX_FIXTURE} if epoch=='after' else set()), 'complete unique Git membership'
    assert manifest['excluded_metadata'] == excluded, 'black-box metadata exclusion'
    overlays = {p: e for p, e in entries.items() if e.get('overlay')}
    assert set(overlays) == set(overlays_expected), 'exact authored overlay membership'
    for path, entry in overlays.items():
        raw = (ROOT / path).read_bytes()
        assert entry['mode'] == '100644' and len(raw) == entry['bytes'] and sha(raw) == entry['sha256'], 'authored overlay bytes'
    replacements={e['path']:e for e in manifest['replaced_git_members']}
    assert len(replacements)==len(manifest['replaced_git_members']) and set(replacements)==({OWNER,REGEX_FIXTURE} if epoch=='after' else set()), 'only declared owner and fixture replace Git members'
    assert (ROOT/COMMON[1]).read_bytes()==subprocess.check_output(['git','show',REVISION+':'+OWNER],cwd=ROOT), 'exact immutable original producer'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in actual.items():
            entry = replacements[path] if path in {OWNER,REGEX_FIXTURE} and epoch=='after' else supplied[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'original Git member identity'
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'Git blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'Git blob framing'
            assert sha(raw) == entry['sha256'], 'original Git member bytes'
            assert hashlib.sha1(b'blob ' + str(size).encode() + b'\0' + raw).hexdigest() == oid, 'Git object content'
            if (path.startswith(('perl/', 'specs/', 't/')) or path in REVIEW_INPUTS) and path not in {OWNER,REGEX_FIXTURE}:
                assert raw == (ROOT / path).read_bytes(), 'unchanged current production and tests'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    return len(actual),len(supplied),len(overlays)


def check_fixtures(row):
    text = decode(row['stdout']).decode()
    sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
    assert sections[1::2] == TESTS, 'complete selected suite population'
    counts = []
    for body, expected_count in zip(sections[2::2], PLANS, strict=True):
        plans = re.findall(r'^1\.\.(\d+)\s*$', body, re.M)
        assert plans == [str(expected_count)], 'complete selected suite plan'
        count = int(plans[0]); counts.append(count)
        assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, count + 1)), 'complete ordered positive fixture reach'
        assert not re.search(r'^\s*not ok\b', body, re.M), 'no nested fixture failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual fixture success'
    return counts


def check_tap(row, count, failed=()):
    text=decode(row['stdout']).decode()
    assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==[str(count)], 'complete exact TAP plan'
    top=re.findall(r'^(not ok|ok) (\d+)\b',text,re.M)
    assert top==[('not ok' if i in failed else 'ok',str(i)) for i in range(1,count+1)], 'complete original RED/current GREEN TAP reach'
    if failed:
        assert row['exit']==1 and 'Result: FAIL' in text and 'Failed 5/8 subtests' in text, 'actual original metadata RED'
        assert b'Looks like you failed 5 tests of 8' in decode(row['stderr']), 'original metadata failure channel'
    else:
        assert row['exit']==0 and 'Result: PASS' in text and 'All tests successful.' in text, 'actual complete TAP GREEN'
        assert not re.search(r'^\s*not ok\b',text,re.M), 'no nested TAP failure'
        assert decode(row['stderr'])==b'', 'actual clean TAP stderr'


def check_report(report,manifest):
    epoch=manifest['epoch']
    assert report['complete'] is True and report['revision']==REVISION and report['epoch']==epoch, 'complete exact-source capture'
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256']==sha((ROOT/(DIAGNOSIS+'capture.py')).read_bytes()), 'actual channel producer'
    kinds=[('regression',0),('regex-guard',0)]+[(kind,seed) for kind in ('metadata-toolbox','mixed-toolbox','foreign-source') for seed in (0,1,42)]
    if epoch=='after':kinds+=[('fixtures',0)]
    assert [(r['kind'],r['seed']) for r in report['runs']]==kinds, 'complete actual run population'
    for row in report['runs']:
        kind=row['kind']
        tail=['prove','-v','-Iperl']+TESTS if kind=='fixtures' else ['prove','-v','-Iperl',FIXTURE] if kind=='regression' else ['prove','-v','-Iperl',REGEX_FIXTURE] if kind=='regex-guard' else ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix() if kind=='metadata-toolbox' else PRIOR+'probe.pl' if kind=='mixed-toolbox' else GUARD+'guard-probe.pl']
        assert row['command']==['bash','tools/project_data_run.sh']+tail, 'actual capture command'
        assert row['inputs_before']==row['inputs_after']==len(manifest['entries']), 'actual complete input guards'
        baseline=epoch=='before' and kind=='regression'
        assert row['baseline_environment']==('1' if baseline else '0'), 'exact original-owner override environment'
        assert row['exit']==(1 if baseline else 0), 'actual expected command exit'
        decode(row['stdout']);decode(row['stderr'])
        if not baseline:assert decode(row['stderr'])==b'', 'actual empty outer stderr'
    check_tap(report['runs'][0],8,(1,2,3,5,6) if epoch=='before' else ())
    check_tap(report['runs'][1],13)
    if epoch=='after':check_fixtures(report['runs'][11])


def check_mixed(data,epoch):
    expected = oracle.author()
    assert data['action'] == expected['action'], 'exact mixed authored source'
    assert data['dependency_keys'] == sorted(['build_array_pipeline_plan_from_expr', 'normalize_method_args_with_optional_scope', 'parse_method_function_expr', 'split_action_ir_statements', 'trim_action_ir_value']), 'original five callbacks'
    assert data['failure'] is None and data['internal_stdout'] == data['internal_stderr'] == '', 'complete clean Toolbox inspection'
    assert isinstance(data['substitution'], str) and isinstance(data['diagnostics'], dict) and data['dump'].startswith('# LinkedSpec generated parser source.'), 'complete Toolbox outputs'
    frames = [{'source': expected['action'], **frame} for frame in expected['statements']]
    assert data['statement_frames'] == frames, 'authored mixed statement frames'
    assert [r['contract'] for r in data['rows']] == [c['id'] for c in expected['contracts']], 'exact nineteen-contract population and order'
    for row, contract in zip(data['rows'], expected['contracts'], strict=True):
        events = [{'raw': e['raw'], 'args': copy.deepcopy(e['args'])} for e in contract['events']]
        if epoch=='after' and contract['id']=='split_array':
            for event in events:event['args']['source']='$input'
        assert row['public_events'] == events, 'authored exact public arguments and occurrences'
        assert row['private_result']['events'] == events, 'unchanged private public events'
        origins = [{'event': event, 'source': expected['action'], 'source_span': authored['source_span']}
                   for event, authored in zip(events, contract['events'], strict=True)] if contract['family']=='regex' else []
        assert row['private_result']['source_origins'] == origins, 'exact before/after authored regex origins'
        assert len(row['identity']) == len(origins) and all(
            set(identity) == {'origin_event', 'constructed_event', 'constructed_args'}
            and all(value is True for value in identity.values())
            for identity in row['identity']), 'original regex event and argument reference identities'
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


def normalize_diagnostics(data,expr,source,count):
    result=copy.deepcopy(data)
    for key in ('helper_action_ir_events','canonical_action_ir_events'):
        entries=[e for e in result[key] if e.get('contract_id')=='split_array']
        assert len(entries)==count and all(e['raw']==expr and e['args']['source']==source for e in entries), 'exact helper and canonical source metadata'
        for event in entries:event['args']['source']=None
    return result


def check_metadata(data,epoch):
    cases=metadata_oracle.author()
    assert [r['id'] for r in data['rows']]==[c['id'] for c in cases], 'exact eight metadata case population'
    assert data['dependency_keys']==sorted(['build_array_pipeline_plan_from_expr','normalize_method_args_with_optional_scope','parse_method_function_expr','split_action_ir_statements','trim_action_ir_value']), 'original five metadata callbacks'
    for row,case in zip(data['rows'],cases,strict=True):
        source=case['source_'+epoch]
        event={'raw':case['expr'],'args':{'target':'items','delimiter':'/\\,/','source':source}}
        events=[event,event,event]
        assert row['public_events']==events and row['private_result']['events']==events, 'authored normalized or legacy source metadata'
        origins=[{'event':event,'source':case['action'],'source_span':span} for span in case['spans']]
        assert row['private_result']['source_origins']==origins, 'authored original metadata source origins'
        assert len(row['identity'])==3 and all(set(i)=={'origin_event','constructed_event','constructed_args'} and all(v is True for v in i.values()) for i in row['identity']), 'original metadata event and argument references'
        calls=[{'callback':'build_array_pipeline_plan_from_expr','args':[case['expr']],'result':case['plan']}]*3
        assert row['public_calls']==row['private_calls']==calls, 'independent original metadata callback plans'
        for span in case['spans']:assert case['action'][span['start']:span['end']]==case['expr'], 'authored metadata scalar slices'
        toolbox=row['toolbox']
        if case['custom_plan']:
            assert toolbox is None, 'legacy callback scope excludes default compiler claims'
        else:
            assert toolbox['failure'] is None and toolbox['internal_stdout']==toolbox['internal_stderr']=='', 'complete clean metadata Toolbox records'
            assert isinstance(toolbox['substitution'],str) and toolbox['dump'].startswith('# LinkedSpec generated parser source.'), 'complete metadata generated outputs'
            normalize_diagnostics(toolbox['diagnostics'],case['expr'],source,1)


def compare_toolbox(before,after,expr,source,count):
    assert all(before[k]==after[k] for k in ('substitution','dump','failure','internal_stdout','internal_stderr')), 'unchanged complete executable Toolbox channels'
    assert normalize_diagnostics(before['diagnostics'],expr,None,count)==normalize_diagnostics(after['diagnostics'],expr,source,count), 'only declared helper and canonical diagnostic value changes'


def normalize_mixed(data,epoch):
    result=copy.deepcopy(data)
    for row in result['rows']:
        if row['contract']!='split_array':continue
        source='$input' if epoch=='after' else None
        for event in row['public_events']+row['private_result']['events']:
            assert event['args']['source']==source, 'exact mixed source correction'
            event['args']['source']=None
        for origin in row['private_result']['source_origins']:
            assert origin['event']['args']['source']==source, 'exact mixed origin source correction'
            origin['event']['args']['source']=None
    result['diagnostics']=normalize_diagnostics(result['diagnostics'],"split(items, input, ',')",'$input' if epoch=='after' else None,3)
    return result


def main():
    manifests={e:json.loads(Path(PREFIX+e+'-inputs.json').read_bytes()) for e in ('before','after')}
    reports={e:json.loads(Path(PREFIX+e+'-observations.json').read_bytes()) for e in ('before','after')}
    assert json.loads(Path(PREFIX+'cases.json').read_bytes())==metadata_oracle.author(), 'independent literal metadata oracle'
    assert json.loads((ROOT/(PRIOR+'verification.json')).read_bytes())['fixture_plans']==PLANS, 'immutable prior direct-consumer plan oracle'
    populations={}
    for epoch in ('before','after'):
        manifest,report=manifests[epoch],reports[epoch]
        populations[epoch]=check_inputs(manifest);check_report(report,manifest)
        for row in report['runs'][2:5]:check_metadata(json.loads(decode(row['stdout'])),epoch)
        for row in report['runs'][5:8]:check_mixed(json.loads(decode(row['stdout'])),epoch)
        for row in report['runs'][8:11]:check_foreign(json.loads(decode(row['stdout'])))
        for start,end in ((2,5),(5,8),(8,11)):
            assert len({decode(r['stdout']) for r in report['runs'][start:end]})==1, 'exact metadata mixed and foreign cross-seed channels'
    for index in range(2,5):
        before,after=[json.loads(decode(reports[e]['runs'][index]['stdout'])) for e in ('before','after')]
        for b,a,c in zip(before['rows'],after['rows'],metadata_oracle.author(),strict=True):
            assert b['public_calls']==a['public_calls'] and b['private_calls']==a['private_calls'] and b['identity']==a['identity'], 'unchanged metadata callbacks and identity observations'
            if not c['custom_plan']:compare_toolbox(b['toolbox'],a['toolbox'],c['expr'],c['source_after'],1)
    for index in range(5,8):
        before,after=[json.loads(decode(reports[e]['runs'][index]['stdout'])) for e in ('before','after')]
        assert normalize_mixed(before,'before')==normalize_mixed(after,'after'), 'only declared mixed source values change'
    before={e['path']:e for e in manifests['before']['entries']};after={e['path']:e for e in manifests['after']['entries']}
    assert before.keys()==after.keys() and {p for p in before if before[p]!=after[p]}=={OWNER,REGEX_FIXTURE}, 'only actual owner and expectation fixture change'
    controls=[]
    def reject(name,subject,change,verifier,reason):
        candidate=copy.deepcopy(subject);change(candidate)
        try:verifier(candidate)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason);controls.append({'name':name,'observed':'RED','reason':reason})
        else:raise AssertionError('accepted corruption: '+name)
    data=json.loads(decode(reports['after']['runs'][2]['stdout']));verify=lambda d:check_metadata(d,'after')
    reject('erase metadata case',data,lambda d:d['rows'].pop(),verify,'exact eight metadata case population')
    reject('retain original null default source',data,lambda d:d['rows'][0]['public_events'][0]['args'].update(source=None),verify,'authored normalized or legacy source metadata')
    reject('drop legacy fallback',data,lambda d:d['rows'][3]['public_events'][0]['args'].update(source=None),verify,'authored normalized or legacy source metadata')
    reject('prefer legacy over canonical source',data,lambda d:d['rows'][4]['public_events'][0]['args'].update(source='legacy'),verify,'authored normalized or legacy source metadata')
    reject('treat zero expression as false',data,lambda d:d['rows'][5]['public_events'][0]['args'].update(source='legacy'),verify,'authored normalized or legacy source metadata')
    reject('reuse equal raw origin',data,lambda d:d['rows'][0]['private_result']['source_origins'].__setitem__(1,d['rows'][0]['private_result']['source_origins'][0]),verify,'authored original metadata source origins')
    reject('forge event identity',data,lambda d:d['rows'][0]['identity'][0].update(constructed_event=False),verify,'original metadata event and argument references')
    reject('erase callback plan',data,lambda d:d['rows'][0]['private_calls'].pop(),verify,'independent original metadata callback plans')
    reject('erase descriptor correction',data,lambda d:d['rows'][0]['toolbox']['diagnostics']['helper_action_ir_events'][0]['args'].update(source=None),verify,'exact helper and canonical source metadata')
    reject('forge compiler success',data,lambda d:d['rows'][0]['toolbox'].update(failure='failed'),verify,'complete clean metadata Toolbox records')
    report=reports['after'];manifest=manifests['after']
    reject('erase supplied input',manifest,lambda d:d['entries'].pop(0),check_inputs,'complete unique Git membership')
    reject('forge immutable bytes',manifest,lambda d:d['entries'][0].update(sha256='0'*64),check_inputs,'original Git member bytes')
    reject('erase corrected fixture overlay',manifest,lambda d:d['entries'].pop(),check_inputs,'exact authored overlay membership')
    reject('replace foreign Git member',manifest,lambda d:d['replaced_git_members'].append(d['entries'][0]),check_inputs,'only declared owner and fixture replace Git members')
    check=lambda d:check_report(d,manifest)
    reject('promote incomplete capture',report,lambda d:d.update(complete=False),check,'complete exact-source capture')
    reject('forge producer',report,lambda d:d.update(instrument_sha256='0'*64),check,'actual capture producer')
    reject('hide failed command',report,lambda d:d['runs'][2].update(exit=1),check,'actual expected command exit')
    reject('forge channel',report,lambda d:d['runs'][2]['stdout'].update(sha256='0'*64),check,'channel bytes')
    reject('hide original-owner override',reports['before'],lambda d:d['runs'][0].update(baseline_environment='0'),lambda d:check_report(d,manifests['before']),'exact original-owner override environment')
    row=report['runs'][0];text=decode(row['stdout']).decode()
    reject('shorten metadata TAP plan',row,lambda d:d.update(stdout=envelope(text.replace('\n1..8\n','\n1..7\n',1).encode())),lambda d:check_tap(d,8),'complete exact TAP plan')
    row=report['runs'][11];text=decode(row['stdout']).decode()
    reject('shorten direct-consumer TAP plan',row,lambda d:d.update(stdout=envelope(text.replace('\n1..28\n','\n1..27\n',1).encode())),check_fixtures,'complete selected suite plan')
    reject('hide nested consumer failure',row,lambda d:d.update(stdout=envelope(text.replace('    ok 1 -','    not ok 1 -',1).encode())),check_fixtures,'no nested fixture failure')
    before_box=json.loads(decode(reports['before']['runs'][2]['stdout']))['rows'][0]['toolbox']
    after_box=data['rows'][0]['toolbox']
    check_box=lambda d:compare_toolbox(before_box,d,"split(items, input, ',')",'$input',1)
    reject('alter generated parser source',after_box,lambda d:d.update(dump='changed'),check_box,'unchanged complete executable Toolbox channels')
    reject('hide unrelated diagnostic change',after_box,lambda d:d['diagnostics'].update(canonical_action_ir_count=-1),check_box,'only declared helper and canonical diagnostic value changes')
    mixed=json.loads(decode(report['runs'][5]['stdout']))
    reject('erase regex origin',mixed,lambda d:d['rows'][0]['private_result']['source_origins'].pop(),lambda d:check_mixed(d,'after'),'exact before/after authored regex origins')
    counts=check_fixtures(report['runs'][11])
    summary={'complete':True,'revision':REVISION,'populations':populations,'actual_commands':23,'metadata_cases':8,'metadata_selected_events_per_epoch':72,'metadata_origins_per_epoch':72,'default_toolbox_records_per_epoch':9,'mixed_contracts':19,'mixed_events_per_epoch':207,'mixed_frames_per_epoch':135,'mixed_regex_origins_per_epoch':99,'seeds':3,'metadata_regression_groups':8,'original_failed_groups':5,'regex_guard_groups':13,'consumer_groups':sum(counts),'consumer_plans':counts,'total_green_groups':8+13+sum(counts),'unchanged_complete_substitution_and_dump':True,'only_source_metadata_changes':True,'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='controls'}))

if __name__=='__main__':main()

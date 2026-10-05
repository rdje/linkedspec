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
REVISION = 'a076218e9d5591b7e0cbf796774476dd1fc90f61'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
TESTS = ['t/actionir_statement_source_frames.t', 't/actionir_helper_source_provenance.t',
         't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t',
         't/uniform_binding_contract.t', 't/codeblock_push_composition_perl.t',
         't/trace_actionir_pipeline.t','t/actionir_pipeline_regex_source_provenance.t',
         't/actionir_pipeline_split_source_metadata.t','t/actionir_basic_statement_source_provenance.t']
PRIOR = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-'
OWNER = 'perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm'
FIXTURE = 't/actionir_pipeline_statement_source_provenance.t'
COMMON = [FIXTURE] + [Path(PREFIX+name).relative_to(ROOT).as_posix() for name in ('before-PrimitivePipelineRules.pm','probe.pl','identity-probe.pl')]
PLANS = [28,13,23,15,12,605,5,13,8,29]
REVIEW_INPUTS = [PRIOR+n for n in ('oracle.py','cases.json','probe.pl','split-probe.pl','verification.json')]
spec = importlib.util.spec_from_file_location('mixed_oracle', ROOT / (PRIOR + 'oracle.py'))
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
    epoch=manifest['epoch'];assert epoch in ('before','after'), 'exact before/after epoch'
    overlays_expected=COMMON+([OWNER] if epoch=='after' else [])
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
    assert len(entries) == len(manifest['entries']) and supplied.keys() == actual.keys()-({OWNER} if epoch=='after' else set()), 'complete unique Git membership'
    assert manifest['excluded_metadata'] == excluded, 'black-box metadata exclusion'
    overlays = {p: e for p, e in entries.items() if e.get('overlay')}
    assert set(overlays) == set(overlays_expected), 'exact authored overlay membership'
    for path, entry in overlays.items():
        raw = (ROOT / path).read_bytes()
        assert entry['mode'] == '100644' and len(raw) == entry['bytes'] and sha(raw) == entry['sha256'], 'authored overlay bytes'
    replacements={e['path']:e for e in manifest['replaced_git_members']}
    assert len(replacements)==len(manifest['replaced_git_members']) and set(replacements)==({OWNER} if epoch=='after' else set()), 'only candidate owner replaces a Git member'
    assert (ROOT/COMMON[1]).read_bytes()==subprocess.check_output(['git','show',REVISION+':'+OWNER],cwd=ROOT), 'exact immutable original producer'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in actual.items():
            entry = replacements[path] if path==OWNER and epoch=='after' else supplied[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'original Git member identity'
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'Git blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'Git blob framing'
            assert sha(raw) == entry['sha256'], 'original Git member bytes'
            assert hashlib.sha1(b'blob ' + str(size).encode() + b'\0' + raw).hexdigest() == oid, 'Git object content'
            if (path.startswith(('perl/', 'specs/', 't/')) or path in REVIEW_INPUTS) and path!=OWNER:
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


def check_regression(row,epoch):
    text=decode(row['stdout']).decode()
    count=16
    assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==[str(count)], 'complete regression plan'
    top=re.findall(r'^(not ok|ok) (\d+)\b',text,re.M)
    expected=[('ok' if epoch=='after' or i in (9,10,11,13,14,15) else 'not ok',str(i)) for i in range(1,count+1)]
    assert top==expected, 'original-owner RED/current GREEN regression reach'
    if epoch=='after':
        assert not re.search(r'^\s*not ok\b',text,re.M), 'no nested regression failure'
        assert 'Result: PASS' in text and row['exit']==0, 'actual regression GREEN'
        assert decode(row['stderr'])==b'', 'actual clean regression stderr'
    else:
        assert row['exit']==1 and 'Result: FAIL' in text and 'Failed 10/16 subtests' in text, 'actual original-owner RED'
        assert b'Looks like you failed 10 tests of 16' in decode(row['stderr']), 'original failure channel retained'
    return count


def check_phase0(row):
    text=decode(row['stdout']).decode()
    assert row['exit']==0 and 'Result: PASS' in text and 'All tests successful.' in text, 'actual Phase0 success'
    assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==['1034'], 'complete Phase0 plan'
    assert [int(n) for n in re.findall(r'^ok (\d+)\b',text,re.M)]==list(range(1,1035)), 'complete Phase0 positive reach'
    assert not re.search(r'^\s*not ok\b',text,re.M), 'no nested Phase0 failure'
    assert decode(row['stderr'])==b'', 'actual clean Phase0 stderr'


def check_report(report,manifest):
    epoch=manifest['epoch']
    assert report['complete'] is True and report['revision']==REVISION and report['epoch']==epoch, 'complete exact-source capture'
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256']==sha((ROOT/(DIAGNOSIS+'capture.py')).read_bytes()), 'actual channel producer'
    kinds=[('regression',0)]+[(kind,seed) for kind in ('toolbox','foreign-source') for seed in (0,1,42)]+[('split-toolbox',0),('identity-control',0)]
    if epoch=='after':kinds+=[('fixtures',0),('phase0',0)]
    assert [(r['kind'],r['seed']) for r in report['runs']]==kinds, 'complete actual run population'
    for row in report['runs']:
        kind=row['kind']
        tail=['prove','-v','-Iperl']+TESTS if kind=='fixtures' else ['prove','-v','-Iperl',FIXTURE] if kind=='regression' else ['prove','-v','-Iperl','t/phase0_regression.t'] if kind=='phase0' else ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix() if kind=='toolbox' else PRIOR+'split-probe.pl' if kind=='split-toolbox' else Path(PREFIX+'identity-probe.pl').relative_to(ROOT).as_posix() if kind=='identity-control' else GUARD+'guard-probe.pl']
        assert row['command']==['bash','tools/project_data_run.sh']+tail, 'actual capture command'
        assert row['inputs_before']==row['inputs_after']==len(manifest['entries']), 'actual complete input guards'
        baseline=epoch=='before' and kind=='regression'
        assert row['baseline_environment']==('1' if baseline else '0'), 'exact original-owner override environment'
        assert row['exit']==(1 if baseline else 0), 'actual expected command exit'
        decode(row['stdout']);decode(row['stderr'])
        if kind!='regression':assert decode(row['stderr'])==b'', 'actual empty outer stderr'
    check_regression(report['runs'][0],epoch)
    if epoch=='after':check_fixtures(report['runs'][9]);check_phase0(report['runs'][10])


def check_mixed(data,epoch):
    expected = oracle.author()
    for contract in expected['contracts']:
        if contract['id']=='split_array':
            for event in contract['events']:event['args']['source']='$input'
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
                   for event, authored in zip(events, contract['events'], strict=True)] if contract['family']=='regex' or epoch=='after' else []
        assert row['private_result']['source_origins'] == origins, 'exact before/after authored pipeline origins'
        assert len(row['identity']) == len(origins) and all(
            set(identity) == {'origin_event', 'constructed_event', 'constructed_args'}
            and all(value is True for value in identity.values())
            for identity in row['identity']), 'original returned event and argument reference identities'
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
    event = {'raw': expr, 'args': {'target': 'items', 'source': '$input', 'delimiter': '/\\,/'}}
    assert data['events'] == [event], 'unchanged normalized split source metadata'
    assert data['substitution'] == 'do { require LinkedSpec::BindingRuntime; $items = LinkedSpec::BindingRuntime::split_value($items, "items", $input, qr/\\,/); $items }', 'original lowering retains input expression'
    helper = [e for e in data['diagnostics']['helper_action_ir_events'] if e['contract_id'] == 'split_array']
    assert len(helper) == 1 and helper[0]['args'] == event['args'], 'Toolbox descriptor repeats scanner metadata'
    assert data['dump'].startswith('# LinkedSpec generated parser source.'), 'split generated source retained'


def check_identity(data):
    event={'raw':"push(items, '雪')",'args':{'target':'items','value':"'雪'"}}
    assert data=={'source':"push(items, '雪');",'origin_event':event,'returned_event':event,
        'original_relation':True,'old_self_comparison':True,'required_return_relationship':False}, 'actual equal-valued copied-return distinguisher'


def check_foreign(data):
    event = {'raw': 'my $other', 'args': {'declaration_type': 'scalar', 'names': ['other'], 'scope': 'my'}}
    assert data == {'source': 'my $input;', 'public': [event], 'private': {'events': [event], 'source_origins': []}}, 'literal foreign-source boundary'


def compare(before,after):
    assert before['action']==after['action'] and before['dependency_keys']==after['dependency_keys'] and before['statement_frames']==after['statement_frames'], 'unchanged source splitter and dependency contract'
    for b,a in zip(before['rows'],after['rows'],strict=True):
        assert b['contract']==a['contract'] and b['public_events']==a['public_events'] and b['private_result']['events']==a['private_result']['events'], 'unchanged complete original event arguments'
        assert b['public_calls']==a['public_calls'] and b['private_calls']==a['private_calls'], 'unchanged complete callback inputs results and sequence'
    assert all(before[k]==after[k] for k in ('substitution','diagnostics','dump','failure','internal_stdout','internal_stderr')), 'unchanged complete Toolbox channels'


def main():
    manifests={e:json.loads(Path(PREFIX+e+'-inputs.json').read_bytes()) for e in ('before','after')}
    reports={e:json.loads(Path(PREFIX+e+'-observations.json').read_bytes()) for e in ('before','after')}
    populations={}
    assert json.loads((ROOT/(PRIOR+'verification.json')).read_bytes())['fixture_plans']==PLANS[:7], 'immutable prior direct-consumer plan oracle'
    for epoch in ('before','after'):
        manifest,report=manifests[epoch],reports[epoch]
        populations[epoch]=check_inputs(manifest);check_report(report,manifest)
        for row in report['runs'][1:4]:check_mixed(json.loads(decode(row['stdout'])),epoch)
        for row in report['runs'][4:7]:check_foreign(json.loads(decode(row['stdout'])))
        check_split(json.loads(decode(report['runs'][7]['stdout'])))
        check_identity(json.loads(decode(report['runs'][8]['stdout'])))
        assert len({decode(r['stdout']) for r in report['runs'][1:4]})==len({decode(r['stdout']) for r in report['runs'][4:7]})==1, 'exact cross-seed channels'
    for index in range(1,4):compare(*[json.loads(decode(reports[e]['runs'][index]['stdout'])) for e in ('before','after')])
    assert decode(reports['before']['runs'][7]['stdout'])==decode(reports['after']['runs'][7]['stdout']), 'unchanged complete normalized split diagnosis'
    assert decode(reports['before']['runs'][8]['stdout'])==decode(reports['after']['runs'][8]['stdout']), 'unchanged actual returned-reference copy control'
    before={e['path']:e for e in manifests['before']['entries']};after={e['path']:e for e in manifests['after']['entries']}
    assert before.keys()==after.keys() and [p for p in before if before[p]!=after[p]]==[OWNER], 'only actual owner input changes'
    controls=[]
    def reject(name,subject,change,verifier,reason):
        candidate=copy.deepcopy(subject);change(candidate)
        try:verifier(candidate)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason);controls.append({'name':name,'observed':'RED','reason':reason})
        else:raise AssertionError('accepted corruption: '+name)
    data=json.loads(decode(reports['after']['runs'][1]['stdout']));verify=lambda d:check_mixed(d,'after')
    reject('erase contract',data,lambda d:d['rows'].pop(),verify,'exact nineteen-contract population and order')
    reject('change original argument',data,lambda d:d['rows'][0]['public_events'][0]['args'].update(value='Wrong'),verify,'authored exact public arguments and occurrences')
    reject('reuse equal raw origin',data,lambda d:d['rows'][0]['private_result']['source_origins'].__setitem__(1,d['rows'][0]['private_result']['source_origins'][0]),verify,'exact before/after authored pipeline origins')
    reject('erase new statement origin',data,lambda d:d['rows'][11]['private_result']['source_origins'].pop(),verify,'exact before/after authored pipeline origins')
    reject('forge argument identity',data,lambda d:d['rows'][0]['identity'][0].update(constructed_args=False),verify,'original returned event and argument reference identities')
    reject('erase callback effect',data,lambda d:d['rows'][0]['private_calls'].pop(),verify,'unchanged original callback sequence arguments and results')
    reject('erase ignored frame',data,lambda d:d['statement_frames'].pop(0),verify,'authored mixed statement frames')
    reject('extend public schema',data,lambda d:d['rows'][0]['private_result']['events'][0].update(source_span={}),verify,'unchanged private public events')
    reject('forge Toolbox success',data,lambda d:d.update(failure='failed'),verify,'complete clean Toolbox inspection')
    reject('erase nested assignment constructor origin',data,lambda d:d['rows'][16]['private_result']['source_origins'].pop(),verify,'exact before/after authored pipeline origins')
    reject('erase literal receiver constructor origin',data,lambda d:d['rows'][18]['private_result']['source_origins'].pop(),verify,'exact before/after authored pipeline origins')
    control=json.loads(decode(reports['after']['runs'][8]['stdout']))
    reject('promote tautological reference flag',control,lambda d:d.update(required_return_relationship=True),check_identity,'actual equal-valued copied-return distinguisher')
    manifest=manifests['after'];report=reports['after']
    reject('erase supplied input',manifest,lambda d:d['entries'].pop(0),check_inputs,'complete unique Git membership')
    reject('forge immutable bytes',manifest,lambda d:d['entries'][0].update(sha256='0'*64),check_inputs,'original Git member bytes')
    reject('erase candidate overlay',manifest,lambda d:d['entries'].pop(),check_inputs,'exact authored overlay membership')
    reject('replace foreign owner',manifest,lambda d:d['replaced_git_members'].append(d['entries'][0]),check_inputs,'only candidate owner replaces a Git member')
    check=lambda d:check_report(d,manifest)
    reject('promote incomplete capture',report,lambda d:d.update(complete=False),check,'complete exact-source capture')
    reject('forge producer',report,lambda d:d.update(instrument_sha256='0'*64),check,'actual capture producer')
    reject('hide failed command',report,lambda d:d['runs'][1].update(exit=1),check,'actual expected command exit')
    reject('forge channel',report,lambda d:d['runs'][1]['stdout'].update(sha256='0'*64),check,'channel bytes')
    reject('hide original-owner override',reports['before'],lambda d:d['runs'][0].update(baseline_environment='0'),lambda d:check_report(d,manifests['before']),'exact original-owner override environment')
    row=report['runs'][0];text=decode(row['stdout']).decode()
    reject('shorten regression plan',row,lambda d:d.update(stdout=envelope(text.replace('\n1..16\n','\n1..15\n',1).encode())),lambda d:check_regression(d,'after'),'complete regression plan')
    row=report['runs'][9];text=decode(row['stdout']).decode()
    reject('shorten direct-consumer plan',row,lambda d:d.update(stdout=envelope(text.replace('\n1..28\n','\n1..27\n',1).encode())),check_fixtures,'complete selected suite plan')
    row=report['runs'][10];text=decode(row['stdout']).decode()
    reject('shorten Phase0 plan',row,lambda d:d.update(stdout=envelope(text.replace('\n1..1034\n','\n1..1033\n',1).encode())),check_phase0,'complete Phase0 plan')
    reject('hide nested Phase0 failure',row,lambda d:d.update(stdout=envelope(text.replace('    ok 1 -','    not ok 1 -',1).encode())),check_phase0,'no nested Phase0 failure')
    original=json.loads(decode(reports['before']['runs'][1]['stdout']))
    reject('change original lowering',data,lambda d:d.update(substitution='changed'),lambda d:compare(original,d),'unchanged complete Toolbox channels')
    counts=check_fixtures(report['runs'][9]);expected=oracle.author()
    summary={'complete':True,'revision':REVISION,'populations':populations,'actual_commands':20,'contracts':19,'regex_contracts':11,'statement_contracts':8,'new_constructors':10,'seeds':3,'selected_events_per_epoch':207,'authored_frames_per_epoch':135,'origins_before':99,'origins_after':207,'regression_groups':16,'original_failed_groups':10,'consumer_groups':sum(counts),'consumer_plans':counts,'phase0_groups':1034,'total_green_groups':16+sum(counts)+1034,'unchanged_complete_toolbox':True,'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='controls'}))

if __name__=='__main__':main()

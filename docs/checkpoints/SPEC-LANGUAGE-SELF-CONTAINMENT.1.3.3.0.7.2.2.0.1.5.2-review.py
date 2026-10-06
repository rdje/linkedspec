"""Review the single progressive repair against retained complete original channels."""
from pathlib import Path
import copy, importlib.util, json, re, subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
ORIGINAL='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
REVISION='ef2dd019bae121674a6e37a2b14d223bf6c7088c'
OWNER='perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm'
FIXTURE='t/actionir_helper_source_provenance.t'
spec=importlib.util.spec_from_file_location('original_dedicated_review',ROOT/(ORIGINAL+'review.py'))
old=importlib.util.module_from_spec(spec); spec.loader.exec_module(old)
sha,decode,envelope=old.sha,old.decode,old.envelope
TESTS=old.TESTS[:2]+['t/progressive_span_dispatch_perl_authority.t']+old.TESTS[2:]+['t/phase0_regression.t']
PLANS=[143,129,9,51,7,148,28,23,15,20,1035]
FAILED=[139,141,142,143,148]

def check_inputs(manifest,epoch):
    assert manifest['revision']==REVISION and manifest['epoch']==epoch, 'exact input boundary'
    assert manifest['overlays']==[], 'no extra runtime overlays'
    original,excluded={},[]
    for row in filter(None,subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')):
        metadata,path=row.split(b'\t',1);mode,kind,oid,size=metadata.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):
            original[path.decode()]=(mode.decode(),oid.decode(),int(size))
        else: excluded.append({'path':path.decode(),'mode':mode.decode(),'kind':kind.decode()})
    entries={e['path']:e for e in manifest['entries']}
    assert len(entries)==len(manifest['entries']) and entries.keys()==original.keys(), 'complete unique original Git population'
    assert manifest['excluded_metadata']==excluded, 'black-box metadata exclusion'
    assert [e['path'] for e in manifest['entries'] if e.get('declared_fixture_overlay')]==[FIXTURE], 'one declared fixture overlay'
    assert [e['path'] for e in manifest['entries'] if e.get('declared_owner_delta')]==([OWNER] if epoch=='after' else []), 'one declared progressive owner delta'
    process=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,identity in original.items():
            entry=entries[path]
            delta=path==FIXTURE or (epoch=='after' and path==OWNER)
            actual_size=entry['baseline_bytes'] if delta else entry['bytes']
            assert (entry['mode'],entry['oid'],actual_size)==identity, 'original Git metadata'
            process.stdin.write((entry['oid']+'\n').encode());process.stdin.flush()
            assert process.stdout.readline().split()==[entry['oid'].encode(),b'blob',str(identity[2]).encode()], 'original blob framing'
            raw=process.stdout.read(identity[2]);assert process.stdout.read(1)==b'\n', 'original blob termination'
            assert sha(raw)==(entry['baseline_sha256'] if delta else entry['sha256']), 'original input bytes'
            if delta:
                current=(ROOT/path).read_bytes()
                assert entry['bytes']==len(current) and entry['sha256']==sha(current), 'declared replacement bytes'
            elif path.startswith(('perl/','specs/','t/')) and not (epoch=='before' and path==OWNER):
                assert raw==(ROOT/path).read_bytes(), 'unchanged other production and fixtures'
    finally:
        process.stdin.close();process.stdout.close();assert process.wait()==0


def check_document(document,authored,epoch):
    normalized=copy.deepcopy(document)
    origins=0
    for actual,case in zip(document['cases'],authored['cases']):
        for row,expected in zip(actual['rows'],case['rows']):
            wanted=[]
            if expected['contract']=='staged_parse_job' or (epoch=='after' and expected['contract']=='progressive_span_dispatch'):
                wanted=[{'event':event,'source':case['action'],'source_span':{'start':start,'end':end}}
                        for event,(start,end) in zip(expected['expected_events'],expected['original_spans'])]
            assert row['private']['result']['source_origins']==wanted, 'exact selected annotation source origins' if expected['contract'] in ('staged_parse_job','progressive_span_dispatch') else 'unchanged other producer origin gaps'
            origins+=len(wanted)
    for case in normalized['cases']:
        for row in case['rows']: row['private']['result']['source_origins']=[]
    measured=old.check_document(normalized,authored)
    measured['source_origins']=origins
    return normalized,measured


def check_report(report,manifest,authored,epoch):
    assert report['complete'] is True and report['revision']==REVISION and report['epoch']==epoch, 'complete capture boundary'
    assert report['instrument_sha256']==sha(Path(PREFIX+('before-capture.py' if epoch=='before' else 'capture.py')).read_bytes()), 'actual capture producer'
    stream='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256']==sha((ROOT/stream).read_bytes()), 'actual stream producer'
    population=([('regression',0)] if epoch=='before' else [('fixtures',0),('syntax_main',0),('syntax_phase',0)])+[('dedicated',seed) for seed in (0,1,42)]
    assert [(r['kind'],r['seed']) for r in report['runs']]==population, 'complete command population'
    channels=[]
    for run in report['runs']:
        kind=run['kind']
        tail={'regression':['prove','-v','-Iperl',FIXTURE], 'fixtures':['prove','-v','-Iperl']+TESTS,
              'syntax_main':['perl','-c','perl/LinkedSpec.pm'], 'syntax_phase':['perl','-c','-Iperl','t/phase0_regression.t'],
              'dedicated':['perl','-Iperl',ORIGINAL+'probe.pl']}[kind]
        assert run['command']==['bash','tools/project_data_run.sh']+tail, 'actual command identity'
        expected_exit=1 if kind=='regression' else 0
        assert run['exit']==expected_exit and run.get('inputs_before')==run.get('inputs_after')==len(manifest['entries']), 'complete runtime guards and actual exit'
        raw,stderr=decode(run['stdout']),decode(run['stderr'])
        if kind=='dedicated':
            assert stderr==b'', 'empty outer stderr'
            check_document(json.loads(raw),authored,epoch); channels.append(raw)
        elif kind.startswith('syntax_'):
            filename='perl/LinkedSpec.pm' if kind=='syntax_main' else 't/phase0_regression.t'
            assert raw==b'' and stderr==(filename+' syntax OK\n').encode(), 'complete syntax channels'
        else:
            text=raw.decode(); tests=[FIXTURE] if kind=='regression' else TESTS
            plans=[148] if kind=='regression' else PLANS
            assert re.findall(r'^(t/\S+\.t) \.\.',text,re.M)==tests, 'complete ordered fixture population'
            assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==[str(plan) for plan in plans], 'complete fixture plans'
            if kind=='regression':
                assert [int(n) for n in re.findall(r'^not ok (\d+)\b',text,re.M)]==FAILED, 'original five progressive RED groups'
                assert re.findall(r'^ok (\d+)\b',text,re.M)==[str(i) for i in range(1,149) if i not in FAILED], 'all other original fixture groups pass'
                assert 'Result: FAIL' in text and b'Progressive original producer:' in stderr and b'Progressive nested real scans' in stderr, 'complete actual regression failure'
            else:
                assert stderr==b'', 'empty outer stderr'
                assert not re.search(r'^\s*not ok\b',text,re.M), 'all nested fixture assertions pass'
                for test,plan in zip(tests,plans):
                    part=text.split(test+' ..',1)[1].split('\n1..'+str(plan),1)[0]
                    assert re.findall(r'^ok (\d+)\b',part,re.M)==[str(i) for i in range(1,plan+1)], 'complete ordered positive fixture reach'
                assert 'All tests successful.' in text and 'Result: PASS' in text, 'complete successful fixture summary'
    assert channels[0]==channels[1]==channels[2], 'complete channels identical across seeds'
    return channels


def check_component(report,inputs,baseline):
    assert report['complete'] is True and report['revision']==REVISION and report['exit']==0, 'complete healthy component gate'
    assert report['command']==['bash','tools/run_python_project_data.sh','tools/check_progressive_span_dispatch_contract.py'], 'actual component command'
    assert report['instrument_sha256']==sha(Path(PREFIX+'component.py').read_bytes()), 'actual component producer'
    assert report['input_manifest_sha256']==sha(Path(PREFIX+'component-inputs.json').read_bytes()), 'actual component input manifest'
    original={e['path']:e for e in baseline['entries']}
    actual={e['path']:e for e in inputs['entries']}
    assert len(actual)==len(inputs['entries']) and actual.keys()==original.keys() and inputs['revision']==REVISION, 'complete component original Git population'
    assert report.get('inputs_before')==report.get('inputs_after')==len(actual), 'complete component input guards'
    for path,item in actual.items():
        base=original[path]
        expected=(base['mode'],base['oid'],base.get('baseline_bytes',base['bytes']),base.get('baseline_sha256',base['sha256']))
        assert (item['mode'],item['oid'],item['original_bytes'],item['original_sha256'])==expected, 'original component Git identity'
        assert type(item['filesystem_mode']) is int and 0<=item['filesystem_mode']<=0o777, 'actual component filesystem mode'
        if item['sha256']==item['original_sha256']:
            assert 'actual_root_delta' not in item and item['bytes']==item['original_bytes'], 'unchanged component source identity'
        else:
            assert 'actual_root_delta' in item, 'retained actual-root byte delta'
            raw=decode(item['actual_root_delta'])
            assert len(raw)==item['bytes'] and sha(raw)==item['sha256'], 'actual-root delta identity'
        if path.startswith(('perl/','specs/','t/','tools/','capability_conformance/')):
            assert item['sha256']==sha((ROOT/path).read_bytes()), 'current component executable inputs'
    assert decode(report['stderr'])==b'', 'quiet component stderr'
    stdout=decode(report['stdout'])
    assert stdout.startswith(b'progressive-span-dispatch-contract: OK (') and stdout.endswith(b'public 6 documents/12 forbidden/10 outward/60 mutations)\n'), 'complete component success channel'


def main():
    authored=json.loads((ROOT/(ORIGINAL+'cases.json')).read_bytes())
    manifests={e:json.loads(Path(PREFIX+e+'-inputs.json').read_bytes()) for e in ('before','after')}
    reports={e:json.loads(Path(PREFIX+e+'-observations.json').read_bytes()) for e in ('before','after')}
    channels={}
    for epoch in ('before','after'):
        check_inputs(manifests[epoch],epoch)
        channels[epoch]=check_report(reports[epoch],manifests[epoch],authored,epoch)
    previous=json.loads((ROOT/'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1-after-observations.json').read_bytes())
    assert channels['before']==[decode(r['stdout']) for r in previous['runs'] if r['kind']=='dedicated'], 'complete original diagnosis channels retained'
    before=json.loads(channels['before'][0]);after=json.loads(channels['after'][0])
    normalized,measured=check_document(after,authored,'after')
    kept=copy.deepcopy(after)
    for case in kept['cases']:
        for row in case['rows']:
            if row['contract']=='progressive_span_dispatch': row['private']['result']['source_origins']=[]
    assert kept==before, 'all complete prior staged and original public callback/compiler channels preserved'
    assert measured=={'events':42,'statement_frames':63,'source_origins':16,'cases':22,'compiler_cases':4}, 'original population and staged-only origins'
    changed=subprocess.check_output(['git','diff','--name-only',REVISION,'--','perl','specs','t'],cwd=ROOT).decode().splitlines()
    assert changed==[OWNER,FIXTURE], 'bounded one producer and one fixture change'
    component_inputs=json.loads(Path(PREFIX+'component-inputs.json').read_bytes())
    component=json.loads(Path(PREFIX+'component.json').read_bytes())
    check_component(component,component_inputs,manifests['before'])
    controls=[]
    def reject(name,target,mutation,validator,reason):
        bad=copy.deepcopy(target);mutation(bad);assert bad!=target,'effective changed control: '+name
        try: validator(bad)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'observed':'RED','reason':reason});return
        raise AssertionError('accepted corruption: '+name)
    validate=lambda value:check_document(value,authored,'after')
    for i,case in enumerate(authored['cases']):
        for j,row in enumerate(case['rows']):
            if not row['expected_events']: continue
            reject(case['id']+'/'+row['contract']+' omitted event',after,
                lambda v,i=i,j=j:v['cases'][i]['rows'][j]['public']['result'].pop(),validate,'literal original events and arguments')
            if row['contract'] in ('staged_parse_job','progressive_span_dispatch'):
                for name,change in [
                    ('lost original origin',lambda origins:origins.pop()),
                    ('wrong repeated interval',lambda origins:origins[1].update(source_span=origins[0]['source_span'])),
                    ('changed origin argument',lambda origins:origins[0]['event']['args'].update(target='forged')),
                    ('foreign source',lambda origins:origins[0].update(source='foreign'))]:
                    reject(case['id']+'/'+name,after,
                        lambda v,i=i,j=j,change=change:change(v['cases'][i]['rows'][j]['private']['result']['source_origins']),validate,'exact selected annotation source origins')
    for i,contract in enumerate(authored['contracts']):
        index=i*2
        for channel in ('public','private'):
            for identity in ('event','args'):
                reject(contract+'/'+channel+' forged '+identity,after,
                    lambda v,i=index,c=channel,k=identity:v['cases'][i]['rows'][0][c]['identity'][0].update({k:False}),validate,'actual dispatcher event and argument identities')
            reject(contract+'/'+channel+' cloned array',after,
                lambda v,i=index,c=channel:v['cases'][i]['rows'][0][c].update(returned_array=False),validate,'actual dispatcher returned-array identity')
        reject(contract+' lost callback',after,
            lambda v,i=index:v['cases'][i]['rows'][0]['private']['calls'].pop(),validate,'exact original callback channels')
        if contract not in ('staged_parse_job','progressive_span_dispatch'):
            reject(contract+' invented source origin',after,
                lambda v,i=index:v['cases'][i]['rows'][0]['private']['result']['source_origins'].append({}),validate,'unchanged other producer origin gaps')
    for i,row in enumerate(after['toolbox']):
        node,spelling=old.MARKERS[row['id']]
        reject(row['id']+' lost node',after,lambda v,i=i,n=node:v['toolbox'][i]['descriptor']['canonical_action_ir_nodes'].remove(n),validate,'dedicated compiler node')
        for channel,reason in [('substitution','dedicated substitution constructor'),('dump','dedicated emitted constructor')]:
            reject(row['id']+' changed '+channel,after,lambda v,i=i,c=channel,s=spelling:v['toolbox'][i].update({c:v['toolbox'][i][c].replace(s,'omitted_constructor')}),validate,reason)
    for epoch in ('before','after'):
        report=reports[epoch]; manifest=manifests[epoch]
        validator=lambda v,e=epoch,m=manifest:check_report(v,m,authored,e)
        for name,mutation,reason in [
            ('lost command',lambda v:v['runs'].pop(),'complete command population'),
            ('lost guard',lambda v:v['runs'][-1].pop('inputs_after'),'complete runtime guards and actual exit'),
            ('wrong actual exit',lambda v:v['runs'][-1].update(exit=1),'complete runtime guards and actual exit'),
            ('forged command',lambda v:v['runs'][-1]['command'].append('--invented'),'actual command identity'),
            ('forged channel',lambda v:v['runs'][-1]['stdout'].update(sha256='0'*64),'complete channel bytes'),
            ('forged capture',lambda v:v.update(instrument_sha256='0'*64),'actual capture producer'),
            ('forged stream',lambda v:v.update(stream_instrument_sha256='0'*64),'actual stream producer'),
            ('incomplete capture',lambda v:v.update(complete=False),'complete capture boundary')]:
            reject(epoch+'/'+name,report,mutation,validator,reason)
    report=reports['after'];validator=lambda v:check_report(v,manifests['after'],authored,'after')
    tap=decode(report['runs'][0]['stdout'])
    reject('shortened positive TAP reach',report,lambda v:v['runs'][0].update(stdout=envelope(tap.replace(b'ok 143 - ',b'ok 144 - ',1))),validator,'complete ordered positive fixture reach')
    reject('hidden nested TAP failure',report,lambda v:v['runs'][0].update(stdout=envelope(tap.replace(b'    ok 1 - ',b'    not ok 1 - ',1))),validator,'all nested fixture assertions pass')
    report=reports['before'];validator=lambda v:check_report(v,manifests['before'],authored,'before')
    tap=decode(report['runs'][0]['stdout'])
    reject('hidden original progressive RED',report,lambda v:v['runs'][0].update(stdout=envelope(tap.replace(b'not ok 139 - ',b'ok 139 - ',1))),validator,'original five progressive RED groups')
    for epoch in ('before','after'):
        manifest=manifests[epoch];validator=lambda v,e=epoch:check_inputs(v,e)
        reject(epoch+' lost original input',manifest,lambda v:v['entries'].pop(),validator,'complete unique original Git population')
        reject(epoch+' extra runtime overlay',manifest,lambda v:v['overlays'].append({}),validator,'no extra runtime overlays')
        reject(epoch+' lost fixture declaration',manifest,lambda v:next(e for e in v['entries'] if e['path']==FIXTURE).pop('declared_fixture_overlay'),validator,'one declared fixture overlay')
    reject('lost progressive owner declaration',manifests['after'],lambda v:next(e for e in v['entries'] if e['path']==OWNER).pop('declared_owner_delta'),lambda v:check_inputs(v,'after'),'one declared progressive owner delta')
    component_validator=lambda v:check_component(v,component_inputs,manifests['before'])
    for name,mutation,reason in [
        ('failed component',lambda v:v.update(exit=1),'complete healthy component gate'),
        ('lost component guard',lambda v:v.pop('inputs_after'),'complete component input guards'),
        ('forged component producer',lambda v:v.update(instrument_sha256='0'*64),'actual component producer'),
        ('forged component manifest',lambda v:v.update(input_manifest_sha256='0'*64),'actual component input manifest'),
        ('truncated component success',lambda v:v.update(stdout=envelope(decode(v['stdout']).split(b'; public ',1)[0]+b')\n')),'complete component success channel')]:
        reject(name,component,mutation,component_validator,reason)
    input_validator=lambda v:check_component(component,v,manifests['before'])
    reject('lost component Git input',component_inputs,lambda v:v['entries'].pop(),input_validator,'complete component original Git population')
    selected=next(i for i,e in enumerate(component_inputs['entries']) if 'actual_root_delta' in e)
    reject('lost actual-root byte delta',component_inputs,lambda v:v['entries'][selected].pop('actual_root_delta'),input_validator,'retained actual-root byte delta')
    reject('forged actual-root byte delta',component_inputs,lambda v:v['entries'][selected]['actual_root_delta'].update(sha256='0'*64),input_validator,'complete channel bytes')
    result={'complete':True,'revision':REVISION,'regular_inputs':len(manifests['before']['entries']),'runtime_overlays':0,
            'fixture_replacements':1,'owner_deltas':1,'commands':sum(len(r['runs']) for r in reports.values()),'component_commands':1,'component_inputs':len(component_inputs['entries']),'component_deltas':sum('actual_root_delta' in e for e in component_inputs['entries']),'seeds':3,
            'contracts':len(authored['contracts']),**measured,'original_red_groups':FAILED,'fixture_suites':len(TESTS),
            'fixture_groups':sum(PLANS),'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes()),
            'scope':'One progressive producer; preserves all preceding staged origins; all seven original dedicated contracts and complete original channels remain retained. Constructor identity and unsupported/nested/error callback behavior are recurring fixture assertions; probe identities are at actual dispatcher return. No parser execution beyond selected consumers, membership, admission or separate runtime-defect closure.'}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='controls'})); print(str(len(controls))+' effective reason-specific evidence controls RED')
if __name__=='__main__': main()

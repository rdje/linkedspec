"""Review the single staged repair against retained complete original channels."""
from pathlib import Path
import copy, importlib.util, json, re, subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
ORIGINAL='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
REVISION='8a64493d96795ef7398926b508e07595d01ef26c'
OWNER='perl/LinkedSpec/ActionIR/StagedParseJob.pm'
FIXTURE='t/actionir_helper_source_provenance.t'
spec=importlib.util.spec_from_file_location('original_dedicated_review',ROOT/(ORIGINAL+'review.py'))
old=importlib.util.module_from_spec(spec); spec.loader.exec_module(old)
sha,decode,envelope=old.sha,old.decode,old.envelope
TESTS=old.TESTS+['t/phase0_regression.t']
PLANS=[143,129,51,7,138,28,23,15,20,1035]
FAILED=[129,131,132,133,138]

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
    assert [e['path'] for e in manifest['entries'] if e.get('declared_owner_delta')]==([OWNER] if epoch=='after' else []), 'one declared staged owner delta'
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
            if epoch=='after' and expected['contract']=='staged_parse_job':
                wanted=[{'event':event,'source':case['action'],'source_span':{'start':start,'end':end}}
                        for event,(start,end) in zip(expected['expected_events'],expected['original_spans'])]
            assert row['private']['result']['source_origins']==wanted, 'exact selected staged source origins' if expected['contract']=='staged_parse_job' else 'unchanged other producer origin gaps'
            origins+=len(wanted)
    for case in normalized['cases']:
        for row in case['rows']: row['private']['result']['source_origins']=[]
    measured=old.check_document(normalized,authored)
    measured['source_origins']=origins
    return normalized,measured


def check_report(report,manifest,authored,epoch):
    assert report['complete'] is True and report['revision']==REVISION and report['epoch']==epoch, 'complete capture boundary'
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
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
            plans=[138] if kind=='regression' else PLANS
            assert re.findall(r'^(t/\S+\.t) \.\.',text,re.M)==tests, 'complete ordered fixture population'
            assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==[str(plan) for plan in plans], 'complete fixture plans'
            if kind=='regression':
                assert [int(n) for n in re.findall(r'^not ok (\d+)\b',text,re.M)]==FAILED, 'original five staged RED groups'
                assert re.findall(r'^ok (\d+)\b',text,re.M)==[str(i) for i in range(1,139) if i not in FAILED], 'all other original fixture groups pass'
                assert 'Result: FAIL' in text and b'Staged original producer:' in stderr and b'Staged nested real scans' in stderr, 'complete actual regression failure'
            else:
                assert stderr==b'', 'empty outer stderr'
                assert not re.search(r'^\s*not ok\b',text,re.M), 'all nested fixture assertions pass'
                for test,plan in zip(tests,plans):
                    part=text.split(test+' ..',1)[1].split('\n1..'+str(plan),1)[0]
                    assert re.findall(r'^ok (\d+)\b',part,re.M)==[str(i) for i in range(1,plan+1)], 'complete ordered positive fixture reach'
                assert 'All tests successful.' in text and 'Result: PASS' in text, 'complete successful fixture summary'
    assert channels[0]==channels[1]==channels[2], 'complete channels identical across seeds'
    return channels


def main():
    authored=json.loads((ROOT/(ORIGINAL+'cases.json')).read_bytes())
    manifests={e:json.loads(Path(PREFIX+e+'-inputs.json').read_bytes()) for e in ('before','after')}
    reports={e:json.loads(Path(PREFIX+e+'-observations.json').read_bytes()) for e in ('before','after')}
    channels={}
    for epoch in ('before','after'):
        check_inputs(manifests[epoch],epoch)
        channels[epoch]=check_report(reports[epoch],manifests[epoch],authored,epoch)
    previous=json.loads((ROOT/(ORIGINAL+'observations.json')).read_bytes())
    assert channels['before']==[decode(r['stdout']) for r in previous['runs'] if r['kind']=='dedicated'], 'complete original diagnosis channels retained'
    before=json.loads(channels['before'][0]);after=json.loads(channels['after'][0])
    normalized,measured=check_document(after,authored,'after')
    assert normalized==before, 'all complete original public callback and compiler channels preserved'
    assert measured=={'events':42,'statement_frames':63,'source_origins':8,'cases':22,'compiler_cases':4}, 'original population and staged-only origins'
    changed=subprocess.check_output(['git','diff','--name-only',REVISION,'--','perl','specs','t'],cwd=ROOT).decode().splitlines()
    assert changed==[OWNER,FIXTURE], 'bounded one producer and one fixture change'
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
            if row['contract']=='staged_parse_job':
                for name,change in [
                    ('lost original origin',lambda origins:origins.pop()),
                    ('wrong repeated interval',lambda origins:origins[1].update(source_span=origins[0]['source_span'])),
                    ('changed origin argument',lambda origins:origins[0]['event']['args'].update(target='forged')),
                    ('foreign source',lambda origins:origins[0].update(source='foreign'))]:
                    reject(case['id']+'/'+name,after,
                        lambda v,i=i,j=j,change=change:change(v['cases'][i]['rows'][j]['private']['result']['source_origins']),validate,'exact selected staged source origins')
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
        if contract!='staged_parse_job':
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
    reject('hidden original staged RED',report,lambda v:v['runs'][0].update(stdout=envelope(tap.replace(b'not ok 129 - ',b'ok 129 - ',1))),validator,'original five staged RED groups')
    for epoch in ('before','after'):
        manifest=manifests[epoch];validator=lambda v,e=epoch:check_inputs(v,e)
        reject(epoch+' lost original input',manifest,lambda v:v['entries'].pop(),validator,'complete unique original Git population')
        reject(epoch+' extra runtime overlay',manifest,lambda v:v['overlays'].append({}),validator,'no extra runtime overlays')
        reject(epoch+' lost fixture declaration',manifest,lambda v:next(e for e in v['entries'] if e['path']==FIXTURE).pop('declared_fixture_overlay'),validator,'one declared fixture overlay')
    reject('lost staged owner declaration',manifests['after'],lambda v:next(e for e in v['entries'] if e['path']==OWNER).pop('declared_owner_delta'),lambda v:check_inputs(v,'after'),'one declared staged owner delta')
    result={'complete':True,'revision':REVISION,'regular_inputs':len(manifests['before']['entries']),'runtime_overlays':0,
            'fixture_replacements':1,'owner_deltas':1,'commands':sum(len(r['runs']) for r in reports.values()),'seeds':3,
            'contracts':len(authored['contracts']),**measured,'original_red_groups':FAILED,'fixture_suites':len(TESTS),
            'fixture_groups':sum(PLANS),'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes()),
            'scope':'One staged producer; all seven original dedicated contracts and complete original channels remain retained. Constructor identity and unsupported/nested/error callback behavior are recurring fixture assertions; probe identities are at actual dispatcher return. No parser execution beyond selected consumers, membership, admission or separate runtime-defect closure.'}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='controls'})); print(str(len(controls))+' effective reason-specific evidence controls RED')
if __name__=='__main__': main()

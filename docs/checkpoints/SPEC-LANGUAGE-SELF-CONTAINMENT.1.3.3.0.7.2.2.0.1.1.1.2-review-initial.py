"""Independent fixed-source, full-compiler and statement-event RED/GREEN oracle."""
from pathlib import Path
import copy
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
REVISION='aef9e551c7e563985c79c53fcba574ee5df8d509'
PREVIOUS='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
spec=importlib.util.spec_from_file_location('author',ROOT/(PREVIOUS+'review.py'))
author=importlib.util.module_from_spec(spec);spec.loader.exec_module(author)
SOURCES=['perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm','perl/LinkedSpec/ActionIR/ScannerCore.pm']
TEST='t/actionir_basic_statement_source_provenance.t'
PROBE=Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()


def manifest_check(manifest):
    assert manifest['revision']==REVISION, 'exact input revision'
    mode=manifest['mode'];assert mode in ('before','after'), 'input mode'
    actual={};excluded=[]
    listing=subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT)
    for raw in filter(None,listing.split(b'\0')):
        meta,path=raw.split(b'\t',1);m,kind,oid,size=meta.split();path=path.decode()
        if kind==b'blob' and m in (b'100644',b'100755'):
            actual[path]=(m.decode(),oid.decode(),int(size))
        else:excluded.append({'path':path,'mode':m.decode(),'kind':kind.decode()})
    entries=manifest['entries'];assert len({e['path'] for e in entries})==len(entries), 'unique input members'
    supplied={e['path']:e for e in entries if not e.get('overlay')}
    originals=dict(supplied)
    overlay={e['path']:e for e in entries if e.get('overlay')}
    assert set(overlay)=={TEST,PROBE}|(set(SOURCES) if mode=='after' else set()), 'exact overlay membership'
    if mode=='after':
        for path in SOURCES: originals[path]=overlay[path]['original_git_input']
    assert originals.keys()==actual.keys(), 'complete immutable Git membership'
    assert manifest['excluded_metadata']==excluded, 'black-box metadata exclusions'
    process=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,(m,oid,size) in actual.items():
            entry=originals[path]
            assert (entry['mode'],entry['oid'],entry['bytes'])==(m,oid,size), 'original Git identity'
            process.stdin.write((oid+'\n').encode());process.stdin.flush()
            assert process.stdout.readline().split()==[oid.encode(),b'blob',str(size).encode()], 'Git blob header'
            raw=process.stdout.read(size);assert process.stdout.read(1)==b'\n', 'Git blob framing'
            assert author.digest(raw)==entry['sha256'], 'original Git bytes'
            assert hashlib.sha1(b'blob '+str(size).encode()+b'\0'+raw).hexdigest()==oid, 'original Git object content'
    finally:
        process.stdin.close();process.stdout.close();assert process.wait()==0
    for path,entry in overlay.items():
        current=ROOT/path
        raw=current.read_bytes()
        assert entry['mode']=='100644' and len(raw)==entry['bytes'] and author.digest(raw)==entry['sha256'], 'actual overlay bytes'
    return len(actual)


def tap(row,green):
    text=author.decode(row['stdout']).decode();author.decode(row['stderr'])
    plans=re.findall(r'^1\.\.(\d+)\s*$',text,re.M)
    assert plans==['28'], 'complete fixture plan'
    reached=[int(n) for n in re.findall(r'^(?:not )?ok (\d+)\b',text,re.M)]
    assert reached==list(range(1,29)), 'complete ordered fixture reach'
    failed=[(int(n),name) for n,name in re.findall(r'^not ok (\d+) - (.*)$',text,re.M)]
    expected=[1]+list(range(3,18))+list(range(19,23))+[26]
    assert [n for n,_ in failed]==([] if green else expected), 'actual distinguishing failed groups'
    assert row['exit']==(0 if green else 1), 'actual fixture exit'
    if green:
        assert 'All tests successful.' in text and 'Result: PASS' in text and not re.search(r'^\s*not ok\b',text,re.M), 'complete positive fixture'
    else:
        assert 'Result: FAIL' in text, 'preserved actual fixture RED'
    return failed


def report_check(report,manifest):
    assert report['revision']==REVISION and report['mode']==manifest['mode'] and report['complete'] is True, 'complete exact-source report'
    assert report['instrument_sha256']==author.digest(Path(PREFIX+'capture.py').read_bytes()), 'actual capture instrument'
    assert report['stream_instrument_sha256']==author.digest((ROOT/(PREVIOUS+'capture.py')).read_bytes()), 'actual stream instrument'
    assert [(r['kind'],r['seed']) for r in report['runs']]==[('fixture',0),('toolbox',0),('toolbox',1),('toolbox',42)], 'complete run population'
    for row in report['runs']:
        tail=['prove','-v','-Iperl',TEST] if row['kind']=='fixture' else ['perl','-Iperl',PROBE]
        assert row['command']==['bash','tools/project_data_run.sh']+tail, 'actual command'
        assert row['inputs_before']==row['inputs_after']==len(manifest['entries']), 'actual input boundary guards'
        if row['kind']=='fixture':tap(row,manifest['mode']=='after')
        else:
            assert row['exit']==0 and author.decode(row['stderr'])==b'', 'complete Toolbox exit/channels'
    return True


def frame_check(data,expected,green):
    observed=copy.deepcopy(data)
    for row in observed['rows']:row['private_result']['source_origins']=[]
    author.check_rows(observed,expected)
    for row,case in zip(data['rows'],expected):
        wanted=[{'source':case['action'],'raw':s['raw'],'source_span':{'start':s['start'],'end':s['end']}} for s in case['statements']]
        assert row['statement_frames']==wanted, 'authored original scalar frames'
        selected=[case['statements'][i] for i in case['event_indices']]
        origins=[{'event':event,'source':case['action'],'source_span':{'start':statement['start'],'end':statement['end']}}
                 for event,statement in zip(row['public_events'],selected)]
        assert row['private_result']['source_origins']==(origins if green else []), 'authored event source origins'
        assert row['private_event_identity']==([True]*len(origins) if green else []), 'exact original event identities'


def compare_compiler(before,after):
    b=copy.deepcopy(before);a=copy.deepcopy(after)
    for data in (b,a):
        for row in data['rows']:
            row['private_result']['source_origins']=[]
            row.pop('private_event_identity')
    assert b==a, 'complete before-after public compiler identity'


def main():
    expected=author.author_cases();author.check_spans(expected)
    manifests={m:json.loads(Path(PREFIX+m+'-inputs.json').read_bytes()) for m in ('before','after')}
    reports={m:json.loads(Path(PREFIX+m+'.json').read_bytes()) for m in ('before','after')}
    git_count=0
    for mode in ('before','after'):
        git_count=manifest_check(manifests[mode]);report_check(reports[mode],manifests[mode])
    before={e['path']:e for e in manifests['before']['entries']};after={e['path']:e for e in manifests['after']['entries']}
    assert before.keys()==after.keys(), 'same supplied-input membership'
    assert [p for p in sorted(before) if before[p]['sha256']!=after[p]['sha256']]==sorted(SOURCES), 'only changed production input'
    assert all(before[p]['mode']==after[p]['mode'] for p in before), 'same supplied-input modes'
    for mode in ('before','after'):
        previous=None
        for row in reports[mode]['runs'][1:]:
            raw=author.decode(row['stdout']);data=json.loads(raw);frame_check(data,expected,mode=='after')
            assert previous is None or previous==raw, 'exact cross-seed streams'
            previous=raw
    for b,a in zip(reports['before']['runs'][1:],reports['after']['runs'][1:]):
        bd=json.loads(author.decode(b['stdout']));ad=json.loads(author.decode(a['stdout']))
        compare_compiler(bd,ad)
    controls=[]
    def reject(name,subject,change,check,reason):
        candidate=copy.deepcopy(subject);change(candidate)
        try:check(candidate)
        except (AssertionError,KeyError) as error:
            assert error.args[0]==reason,(name,error.args,reason)
            controls.append({'name':name,'rejected':True,'reason':reason})
        else:raise AssertionError('accepted corruption: '+name)
    data=json.loads(author.decode(reports['after']['runs'][1]['stdout']))
    baseline=json.loads(author.decode(reports['before']['runs'][1]['stdout']))
    reject('alter public compiler output',data,lambda d:d['rows'][0].update(dump='changed parser output'),lambda d:compare_compiler(baseline,d),'complete before-after public compiler identity')
    reject('drop produced event origin',data,lambda d:d['rows'][0]['private_result']['source_origins'].pop(),lambda d:frame_check(d,expected,True),'authored event source origins')
    reject('reuse duplicate occurrence',data,lambda d:d['rows'][0]['private_result']['source_origins'].__setitem__(1,d['rows'][0]['private_result']['source_origins'][0]),lambda d:frame_check(d,expected,True),'authored event source origins')
    reject('Unicode byte offset',data,lambda d:d['rows'][4]['private_result']['source_origins'][0]['source_span'].update(start=8),lambda d:frame_check(d,expected,True),'authored event source origins')
    reject('quoted equal text mapping',data,lambda d:d['rows'][3]['private_result']['source_origins'][0]['source_span'].update(start=6,end=11),lambda d:frame_check(d,expected,True),'authored event source origins')
    reject('invent origin for unrecognized comment',data,lambda d:d['rows'][1]['private_result']['source_origins'].append({}),lambda d:frame_check(d,expected,True),'authored event source origins')
    reject('forge original event identity',data,lambda d:d['rows'][0]['private_event_identity'].__setitem__(0,False),lambda d:frame_check(d,expected,True),'exact original event identities')
    reject('drop original statement frame',data,lambda d:d['rows'][0]['statement_frames'].pop(),lambda d:frame_check(d,expected,True),'authored original scalar frames')
    reject('drop canonical input',manifests['after'],lambda d:d['entries'].pop(0),manifest_check,'complete immutable Git membership')
    reject('forge canonical bytes',manifests['after'],lambda d:d['entries'][0].update(sha256='0'*64),manifest_check,'original Git bytes')
    reject('drop actual producer overlay',manifests['after'],lambda d:d['entries'].__setitem__(slice(None),[e for e in d['entries'] if e['path']!=SOURCES[0]]),manifest_check,'exact overlay membership')
    reject('promote partial run',reports['after'],lambda d:d.update(complete=False),lambda d:report_check(d,manifests['after']),'complete exact-source report')
    reject('forge executing producer',reports['after'],lambda d:d.update(instrument_sha256='0'*64),lambda d:report_check(d,manifests['after']),'actual capture instrument')
    reject('erase input boundary guard',reports['after'],lambda d:d['runs'][0].update(inputs_after=0),lambda d:report_check(d,manifests['after']),'actual input boundary guards')
    reject('erase actual fixture RED',reports['before'],lambda d:d['runs'][0].update(exit=0),lambda d:report_check(d,manifests['before']),'actual fixture exit')
    reject('forge stdout identity',reports['after'],lambda d:d['runs'][0]['stdout'].update(sha256='0'*64),lambda d:report_check(d,manifests['after']),'channel bytes')
    result={'revision':REVISION,'git_inputs':git_count,'supplied_inputs':len(before),'compiler_pairs':66,'frames':sum(len(c['statements']) for c in expected)*3,'fixture_groups':28,'before_failed_groups':21,'after_failed_groups':0,'controls':controls,'instrument_sha256':author.digest(Path(__file__).read_bytes()),'event_origins':sum(len(c['event_indices']) for c in expected)*3}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n');print({k:v for k,v in result.items() if k!='controls'});print(str(len(controls))+' reason-checked RED controls')


if __name__=='__main__':main()

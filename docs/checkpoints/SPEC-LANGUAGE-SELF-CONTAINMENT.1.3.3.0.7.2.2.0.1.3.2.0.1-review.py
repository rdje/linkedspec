"""Verify one declared MethodExpr owner delta and exact original public effects."""
from pathlib import Path
import copy
import base64
import gzip
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
REVISION='2fd4e499e68f19d6a481662f46c4e24a1c0896a1'
OWNER='perl/LinkedSpec/ActionIR/MethodExpr.pm'
ORIGINAL='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-'
spec=importlib.util.spec_from_file_location('original_flow_review',ROOT/(ORIGINAL+'review.py'))
original=importlib.util.module_from_spec(spec);spec.loader.exec_module(original)
sha=original.guards.sha;decode=original.guards.decode
CASES=original.oracle.author()
TESTS=['t/actionir_method_argument_source_frames.t','t/actionir_flow_direct_source_provenance.t','t/phase0_regression.t','t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t']
PLANS=[15,21,1034,13,28,23,15,20,4]


def envelope(raw):
    return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}

def check_inputs(m,epoch):
    assert m['revision']==REVISION and m['epoch']==epoch,'exact epoch activation'
    expected={};excluded=[]
    for row in filter(None,subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')):
        metadata,path=row.split(b'\t',1);mode,kind,oid,size=metadata.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):expected[path.decode()]=(mode.decode(),oid.decode(),int(size))
        else:excluded.append({'path':path.decode(),'mode':mode.decode(),'kind':kind.decode()})
    entries={e['path']:e for e in m['entries']}
    assert len(entries)==len(m['entries']) and entries.keys()==expected.keys(),'complete unique Git membership'
    assert m['excluded_metadata']==excluded,'nonregular metadata exclusion'
    proc=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,(mode,oid,size) in expected.items():
            e=entries[path]
            assert (e['mode'],e['oid'])==(mode,oid),'original object and mode'
            proc.stdin.write((oid+'\n').encode());proc.stdin.flush()
            assert proc.stdout.readline().split()==[oid.encode(),b'blob',str(size).encode()],'original blob header'
            raw=proc.stdout.read(size);assert proc.stdout.read(1)==b'\n','original blob framing'
            if path==OWNER and epoch=='after':
                assert e.get('declared_owner_delta') is True and e['baseline_sha256']==sha(raw) and e['baseline_bytes']==size,'sole declared owner baseline'
                current=Path(PREFIX+'after-MethodExpr.pm').read_bytes()
                assert e['sha256']==sha(current) and e['bytes']==len(current) and current==(ROOT/OWNER).read_bytes(),'exact selected owner delta'
            else:
                assert not e.get('declared_owner_delta') and e['bytes']==size and e['sha256']==sha(raw),'unchanged original Git bytes'
                if path.startswith(('perl/','specs/','t/')) and path!=OWNER:assert raw==(ROOT/path).read_bytes(),'unchanged other production and tests'
            if path==OWNER:assert raw==Path(PREFIX+'before-MethodExpr.pm').read_bytes(),'exact retained original owner'
    finally:
        proc.stdin.close();proc.stdout.close();assert proc.wait()==0
    overlays=[Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix(),'t/actionir_method_argument_source_frames.t']
    assert [e['path'] for e in m['overlays']]==overlays,'complete authored overlay population'
    for e in m['overlays']:
        raw=(ROOT/e['path']).read_bytes()
        assert e['mode']=='100644' and e['bytes']==len(raw) and e['sha256']==sha(raw),'exact authored overlay bytes'


def check_tap(row,epoch):
    text=decode(row['stdout']).decode()
    sections=re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n',text,flags=re.M)
    tests=TESTS if epoch=='after' else TESTS[:1]
    assert sections[1::2]==tests,'complete selected fixture population'
    for body,count in zip(sections[2::2],PLANS if epoch=='after' else PLANS[:1],strict=True):
        assert re.findall(r'^1\.\.(\d+)\s*$',body,re.M)==[str(count)],'complete fixture plan'
        if epoch=='after':
            assert [int(n) for n in re.findall(r'^ok (\d+)\b',body,re.M)]==list(range(1,count+1)),'complete positive fixture reach'
            assert not re.search(r'^\s*not ok\b',body,re.M),'no nested fixture failure'
        else:
            assert [int(n) for n in re.findall(r'^not ok (\d+)\b',body,re.M)]==[1,2,3,4,5,6,9,10,12,13],'original exact missing-origin RED'
    assert ('Result: PASS' if epoch=='after' else 'Result: FAIL') in text,'actual fixture outcome'


def check_report(report, manifest, epoch):
    assert report['complete'] and report['revision'] == REVISION and report['epoch'] == epoch, 'complete exact epoch capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture instrument'
    stream = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256'] == sha((ROOT/stream).read_bytes()), 'actual stream instrument'
    assert [(r['kind'],r['seed']) for r in report['runs']] == [('fixtures' if epoch == 'after' else 'regression',0)]+[('toolbox',s) for s in (0,1,42)], 'complete guarded command population'
    for row in report['runs']:
        tail = ['prove','-v','-Iperl']+(TESTS if epoch == 'after' else TESTS[:1]) if row['kind'] != 'toolbox' else ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]
        assert row['command'] == ['bash','tools/project_data_run.sh']+tail, 'exact actual command'
        assert row['exit'] == (1 if epoch == 'before' and row['kind'] == 'regression' else 0), 'actual RED or GREEN exit'
        assert row['inputs_before'] == row['inputs_after'] == len(manifest['entries'])+len(manifest['overlays']), 'complete runtime input guards'
        stderr = decode(row['stderr']).decode()
        if epoch == 'before' and row['kind'] == 'regression':
            assert all(re.fullmatch(r'\s*(?:#.*)?',line) for line in stderr.splitlines()), 'only expected RED harness diagnostics'
            expected = ['independent original expression scalar frames','independent original payload scalar frames']*8
            expected += ['unchanged CSV neighbor retains original occurrence','unchanged parser neighbor retains original occurrence','transformed entry denied with exact neighbor retained','inner original scalar frame','outer restored after nested collection']
            assert re.findall(r"^    #   Failed test '(.+)'$",stderr,re.M) == expected, 'exact original missing-frame RED diagnostics'
        else:
            assert stderr == '', 'empty outer stderr'
    check_tap(report['runs'][0],epoch)
    for row in report['runs'][1:]:
        original.check_data(json.loads(decode(row['stdout'])), CASES)
    assert len({decode(r['stdout']) for r in report['runs'][1:]}) == 1, 'exact full callback compiler seed recurrence'


def check_frames(data, epoch):
    assert [r['id'] for r in data] == [c['id'] for c in CASES], 'complete frame case population'
    for row, case in zip(data,CASES,strict=True):
        expected = {'method':case['method'],'source_method':case['method'],'source':case['trimmed'],
                    'args':[a['raw'] for a in case['arguments']]}
        assert row['result']['call'] == expected and row['csv']['arguments'] == expected['args'], 'original private callback values'
        assert row['calls'] == row['split_calls'] == 1, 'exact private callback counts'
        assert row['call_same'] is row['args_same'] is row['csv_same'] is True, 'actual private returned references'
        frames = [{'source':case['source'],'raw':a['raw'],'source_span':{'start':a['start'],'end':a['end']}}
                  for a in case['arguments']] if epoch == 'after' else []
        csv = [{'source':case['payload'],'raw':a['raw'],'source_span':{'start':a['start']-case['payload_start'],
                'end':a['end']-case['payload_start']}} for a in case['arguments']] if epoch == 'after' else []
        assert row['result']['source_frames'] == frames, 'literal original parser scalar frames'
        assert row['csv']['source_frames'] == csv, 'literal original CSV scalar frames'


def main():
    reports, manifests, frame_reports = {}, {}, {}
    for epoch in ('before','after'):
        manifest=json.loads(Path(PREFIX+epoch+'-inputs.json').read_bytes())
        report=json.loads(Path(PREFIX+epoch+'-observations.json').read_bytes())
        check_inputs(manifest,epoch);check_report(report,manifest,epoch)
        reports[epoch]=report;manifests[epoch]=manifest
        fm=json.loads(Path(PREFIX+epoch+'-frames-inputs.json').read_bytes())
        fr=json.loads(Path(PREFIX+epoch+'-frames-observations.json').read_bytes())
        # Reuse complete Git/object/mode/delta proof while checking the actual
        # separate one-overlay runtime population explicitly.
        assert fm['entries']==manifest['entries'] and fm['excluded_metadata']==manifest['excluded_metadata'], 'same immutable frame input baseline'
        assert fm['overlays']==[{'path':Path(PREFIX+'frames-probe.pl').relative_to(ROOT).as_posix(),'mode':'100644',
            'bytes':len(Path(PREFIX+'frames-probe.pl').read_bytes()),'sha256':sha(Path(PREFIX+'frames-probe.pl').read_bytes())}], 'exact frame overlay'
        assert fr['complete'] and fr['revision']==REVISION and fr['epoch']==epoch, 'complete frame capture'
        assert fr['instrument_sha256']==sha(Path(PREFIX+'frames-capture.py').read_bytes()) and fr['stream_instrument_sha256']==report['stream_instrument_sha256'], 'actual frame capture producers'
        assert [(r['kind'],r['seed']) for r in fr['runs']]==[('frames',s) for s in (0,1,42)], 'complete frame command population'
        for row in fr['runs']:
            assert row['command']==['bash','tools/project_data_run.sh','perl','-Iperl',Path(PREFIX+'frames-probe.pl').relative_to(ROOT).as_posix()], 'exact frame command'
            assert row['exit']==0 and row['inputs_before']==row['inputs_after']==len(fm['entries'])+1, 'complete frame runtime guards'
            assert decode(row['stderr'])==b'', 'empty frame stderr'
            check_frames(json.loads(decode(row['stdout'])),epoch)
        assert len({decode(r['stdout']) for r in fr['runs']})==1, 'full frame seed recurrence'
        frame_reports[epoch]=fr
    for before,after in zip(reports['before']['runs'][1:],reports['after']['runs'][1:],strict=True):
        assert decode(before['stdout'])==decode(after['stdout']), 'complete original callback compiler channels unchanged'
    controls=[]
    def reject(name,fn,reason):
        try:fn()
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'observed':'RED','reason':reason})
        else:raise AssertionError('accepted corruption: '+name)
    data=json.loads(decode(frame_reports['after']['runs'][0]['stdout']))
    for index,case in enumerate(CASES):
        if not case['arguments']:continue
        for field,reason in [('result','literal original parser scalar frames'),('csv','literal original CSV scalar frames')]:
            x=copy.deepcopy(data);x[index][field]['source_frames'].pop()
            reject(case['id']+' missing '+field,lambda:check_frames(x,'after'),reason)
    for field in ('call_same','args_same','csv_same'):
        x=copy.deepcopy(data);x[0][field]=False
        reject(field,lambda:check_frames(x,'after'),'actual private returned references')
    x=copy.deepcopy(data);x[0]['result']['source_frames'][0]['source_span']['start']+=1
    reject('wrong scalar',lambda:check_frames(x,'after'),'literal original parser scalar frames')
    x=copy.deepcopy(reports['after']);x['runs'].pop()
    reject('lost run',lambda:check_report(x,manifests['after'],'after'),'complete guarded command population')
    x=copy.deepcopy(manifests['after']);x['entries'].pop()
    reject('lost Git input',lambda:check_inputs(x,'after'),'complete unique Git membership')
    x=copy.deepcopy(reports['before']);x['runs'][0]['stderr']=envelope(decode(x['runs'][0]['stderr'])+b'Unexpected failure\n')
    reject('unrelated RED stderr',lambda:check_report(x,manifests['before'],'before'),'only expected RED harness diagnostics')
    count=sum(len(r['result']['source_frames'])+len(r['csv']['source_frames']) for run in frame_reports['after']['runs'] for r in json.loads(decode(run['stdout'])))
    assert count==138, 'complete observed frame population'
    result={'complete':True,'revision':REVISION,'regular_inputs':len(manifests['before']['entries']),
        'compatibility_overlays':2,'frame_overlays':1,'commands':14,'cases':10,'arguments':23,'seeds':3,
        'before_red_groups':10,'after_green_groups':15,'fixture_suites':len(TESTS),'fixture_groups':sum(PLANS),
        'observed_frames':count,'complete_compiler_pairs':3,'controls':controls,
        'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='controls'}));print(str(len(controls))+' reason-specific RED controls')


if __name__=='__main__':main()

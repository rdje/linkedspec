"""Independently accept the committed sixteen-contract Flow source recurrence."""
from pathlib import Path
import copy
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
REVISION='1d450522afb79aa87e579db148224ad6ed2c11e0'
FLOW='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1-'
METHOD='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1-'
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,ROOT/path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
flow=module('accepted_flow_oracle',FLOW+'review.py')
method=module('accepted_method_oracle',METHOD+'review.py')
sha=flow.sha;decode=flow.decode;envelope=flow.envelope
TESTS=['t/actionir_flow_recursive_source_provenance.t','t/actionir_flow_direct_source_provenance.t','t/actionir_method_argument_source_frames.t','t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t','t/actionir_raw_dependency_provenance.t','t/actionir_pipeline_regex_source_provenance.t','t/actionir_pipeline_statement_source_provenance.t','t/actionir_basic_regex_source_provenance.t','t/actionir_basic_statement_source_provenance.t','t/uniform_binding_contract.t','t/codeblock_push_composition_perl.t']
PLANS=[7,21,15,13,28,23,15,20,4,6,13,16,10,29,12,605]


def check_inputs(manifest):
    assert manifest['revision']==REVISION and manifest['overlays']==[], 'fresh immutable boundary without overlays'
    expected={};excluded=[]
    for row in filter(None,subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')):
        meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):
            expected[path.decode()]=(mode.decode(),oid.decode(),int(size))
        else:excluded.append({'path':path.decode(),'mode':mode.decode(),'kind':kind.decode()})
    entries={e['path']:e for e in manifest['entries']}
    assert len(entries)==len(manifest['entries']) and entries.keys()==expected.keys(), 'complete unique immutable Git population'
    assert manifest['excluded_metadata']==excluded, 'exact black-box metadata exclusions'
    proc=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,(mode,oid,size) in expected.items():
            e=entries[path]
            assert (e['mode'],e['oid'],e['bytes'])==(mode,oid,size), 'exact original object and mode'
            proc.stdin.write((oid+'\n').encode());proc.stdin.flush()
            assert proc.stdout.readline().split()==[oid.encode(),b'blob',str(size).encode()], 'exact original blob header'
            raw=proc.stdout.read(size);assert proc.stdout.read(1)==b'\n', 'exact original blob framing'
            assert e['sha256']==sha(raw), 'exact immutable Git bytes'
            if path.startswith(('perl/','specs/','t/')):
                assert raw==(ROOT/path).read_bytes(), 'unchanged current production and tests'
    finally:
        proc.stdin.close();proc.stdout.close();assert proc.wait()==0


def check_authority(row):
    text=decode(row['stdout']).decode()
    assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==['3'], 'complete authority fixture plan'
    assert re.findall(r'^ok (\d+)\b',text,re.M)==['1','2','3'] and not re.search(r'^\s*not ok\b',text,re.M), 'positive authority fixture reach'
    assert 'Result: PASS' in text, 'complete authority fixture success'


def check_report(report,manifest):
    assert report['complete'] and report['revision']==REVISION, 'complete fresh capture'
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()), 'actual acceptance capture producer'
    stream='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256']==sha((ROOT/stream).read_bytes()), 'actual acceptance stream producer'
    population=[('fixtures',0)]+[(kind,seed) for seed in (0,1,42) for kind in ('flow','method-frames','authority')]
    assert [(r['kind'],r['seed']) for r in report['runs']]==population, 'complete acceptance commands'
    for row in report['runs']:
        command=['prove','-v','-Iperl']+TESTS if row['kind']=='fixtures' else {
            'flow':['perl','-Iperl',FLOW+'probe.pl'],
            'method-frames':['perl','-Iperl',METHOD+'frames-probe.pl'],
            'authority':['prove','-v','-Iperl',FLOW+'authority.t']}[row['kind']]
        assert row['command']==['bash','tools/project_data_run.sh']+command, 'actual committed producer command'
        assert row['exit']==0 and row['inputs_before']==row['inputs_after']==len(manifest['entries']), 'complete acceptance runtime guards'
        assert decode(row['stderr'])==b'', 'empty acceptance stderr'
        if row['kind']=='flow':flow.check_data(json.loads(decode(row['stdout'])),'after')
        elif row['kind']=='method-frames':method.check_frames(json.loads(decode(row['stdout'])),'after')
        elif row['kind']=='authority':check_authority(row)
    text=decode(report['runs'][0]['stdout']).decode()
    sections=re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n',text,flags=re.M)
    assert sections[1::2]==TESTS, 'complete selected suite population'
    for body,plan in zip(sections[2::2],PLANS,strict=True):
        assert re.findall(r'^1\.\.(\d+)\s*$',body,re.M)==[str(plan)], 'complete selected suite plan'
        assert [int(n) for n in re.findall(r'^ok (\d+)\b',body,re.M)]==list(range(1,plan+1)), 'positive selected suite reach'
        assert not re.search(r'^\s*not ok\b',body,re.M), 'no nested selected suite failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'complete selected suite success'
    for kind in ('flow','method-frames'):
        assert len({decode(r['stdout']) for r in report['runs'] if r['kind']==kind})==1, 'exact full acceptance seed recurrence'
    previous=json.loads((ROOT/(FLOW+'after-observations.json')).read_bytes())
    for seed in (0,1,42):
        fresh=next(r for r in report['runs'] if r['kind']=='flow' and r['seed']==seed)
        old=next(r for r in previous['runs'] if r['kind']=='toolbox' and r['seed']==seed)
        assert decode(fresh['stdout'])==decode(old['stdout']), 'complete prior Flow compiler recurrence'
    previous=json.loads((ROOT/(METHOD+'after-frames-observations.json')).read_bytes())
    for seed in (0,1,42):
        fresh=next(r for r in report['runs'] if r['kind']=='method-frames' and r['seed']==seed)
        old=next(r for r in previous['runs'] if r['seed']==seed)
        assert decode(fresh['stdout'])==decode(old['stdout']), 'complete prior method frame recurrence'


def main():
    manifest=json.loads(Path(PREFIX+'inputs.json').read_bytes())
    report=json.loads(Path(PREFIX+'observations.json').read_bytes())
    check_inputs(manifest);check_report(report,manifest)
    controls=[]
    def reject(name,fn,reason):
        try:fn()
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'observed':'RED','reason':reason})
        else:raise AssertionError('accepted corruption: '+name)
    data=json.loads(decode(next(r for r in report['runs'] if r['kind']=='flow')['stdout']))
    for index,case in enumerate(flow.CASES):
        for row_index,row in enumerate(data[index]['rows']):
            if not row['private_result']['source_origins']:continue
            x=copy.deepcopy(data);x[index]['rows'][row_index]['private_result']['source_origins'].pop()
            reject(case['id']+' '+row['contract']+' omitted origin',lambda:flow.check_data(x,'after'),
                'original hook population' if row['contract']=='if_flow' else 'literal direct original scalar origins')
    for field in ('origin_event','constructed_event','constructed_args'):
        x=copy.deepcopy(data);x[-1]['rows'][0]['identity'][0][field]=False
        reject('recursive '+field,lambda:flow.check_data(x,'after'),'actual returned constructor argument identities')
    x=copy.deepcopy(data);x[-1]['rows'][0]['private_result']['source_origins'][0]['source_span']['start']+=1
    reject('wrong recursive scalar',lambda:flow.check_data(x,'after'),'literal direct original scalar origins')
    frames=json.loads(decode(next(r for r in report['runs'] if r['kind']=='method-frames')['stdout']))
    x=copy.deepcopy(frames);x[0]['result']['source_frames'].pop()
    reject('lost method frame',lambda:method.check_frames(x,'after'),'literal original parser scalar frames')
    x=copy.deepcopy(frames);x[0]['csv_same']=False
    reject('forged CSV reference',lambda:method.check_frames(x,'after'),'actual private returned references')
    x=copy.deepcopy(report);x['runs'].pop()
    reject('lost acceptance run',lambda:check_report(x,manifest),'complete acceptance commands')
    x=copy.deepcopy(report);x['runs'][0]['inputs_after']=0
    reject('lost acceptance guard',lambda:check_report(x,manifest),'complete acceptance runtime guards')
    x=copy.deepcopy(manifest);x['entries'].pop()
    reject('lost Git input',lambda:check_inputs(x),'complete unique immutable Git population')
    x=copy.deepcopy(report);x['runs'][0]['stdout']['sha256']='0'*64
    reject('forged channel',lambda:check_report(x,manifest),'complete channel bytes')
    x=copy.deepcopy(report);x['instrument_sha256']='0'*64
    reject('forged producer',lambda:check_report(x,manifest),'actual acceptance capture producer')
    row=copy.deepcopy(next(r for r in report['runs'] if r['kind']=='authority'))
    row['stdout']=envelope(decode(row['stdout']).replace(b'    ok 3 - unchanged nested original argument retains exact source authority',b'    not ok 3 - unchanged nested original argument retains exact source authority'))
    reject('failed authority assertion',lambda:check_authority(row),'positive authority fixture reach')
    origins=sum(len(row['private_result']['source_origins']) for run in report['runs'] if run['kind']=='flow'
        for case in json.loads(decode(run['stdout'])) for row in case['rows'])
    frames=sum(len(row['result']['source_frames'])+len(row['csv']['source_frames']) for run in report['runs']
        if run['kind']=='method-frames' for row in json.loads(decode(run['stdout'])))
    assert (origins,frames)==(147,138), 'complete fresh source populations'
    result={'complete':True,'revision':REVISION,'regular_inputs':len(manifest['entries']),'overlays':0,
        'commands':len(report['runs']),'contracts':16,'seeds':3,'source_origins':origins,'method_frames':frames,
        'complete_compiler_pairs':48,'fixture_suites':len(TESTS),'fixture_groups':sum(PLANS),
        'authority_groups':3,'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes()),
        'scope':'Fresh unchanged committed whole-family recurrence. Canonical staged receipt remains required before acceptance closure; source membership and global audits remain separate.'}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('controls','scope')}));print(str(len(controls))+' reason-specific evidence controls RED')


if __name__=='__main__':main()

"""Review original Flow effects against authored intervals and immutable Git bytes."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
REVISION='b73f1f59aab5c248fded038ec53399a5ddd3bb60'
TESTS=['t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t']
PLANS=[13,28,23,15,20,4]
spec=importlib.util.spec_from_file_location('flow_literal_oracle',PREFIX+'review-oracle.py')
oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)


def sha(raw):return hashlib.sha256(raw).hexdigest()


def decode(e):
    assert e['encoding']=='gzip-base64','channel encoding'
    raw=gzip.decompress(base64.b64decode(e['data'],validate=True))
    assert len(raw)==e['bytes'] and sha(raw)==e['sha256'],'complete channel bytes'
    return raw


def check_inputs(m):
    assert m['revision']==REVISION,'activation revision'
    rows=subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')
    original={};excluded=[]
    for row in filter(None,rows):
        meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):
            original[path.decode()]=(mode.decode(),oid.decode(),int(size))
        else:excluded.append({'path':path.decode(),'mode':mode.decode(),'kind':kind.decode()})
    entries={e['path']:e for e in m['entries']}
    assert len(entries)==len(m['entries']) and entries.keys()==original.keys(),'complete unique original Git population'
    assert m['excluded_metadata']==excluded,'black-box metadata exclusion'
    proc=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,identity in original.items():
            e=entries[path];assert (e['mode'],e['oid'],e['bytes'])==identity,'Git metadata'
            proc.stdin.write((e['oid']+'\n').encode());proc.stdin.flush()
            assert proc.stdout.readline().split()==[e['oid'].encode(),b'blob',str(e['bytes']).encode()],'blob header'
            raw=proc.stdout.read(e['bytes']);assert proc.stdout.read(1)==b'\n','blob framing'
            assert sha(raw)==e['sha256'],'original input bytes'
            if path.startswith(('perl/','specs/','t/')):assert raw==(ROOT/path).read_bytes(),'unchanged production and fixtures'
    finally:
        proc.stdin.close();proc.stdout.close();assert proc.wait()==0
    expected=[Path(PREFIX+n).relative_to(ROOT).as_posix() for n in ('cases.json','probe.pl','oracle.py')]
    assert [e['path'] for e in m['overlays']]==expected,'exact overlay population'
    for e in m['overlays']:
        raw=(ROOT/e['path']).read_bytes()
        assert e['mode']=='100644' and e['bytes']==len(raw) and e['sha256']==sha(raw),'authored overlay bytes'


def check_case(data,case):
    for events in case['expected'].values():
        for event in events:
            assert 0<=event['start']<event['end']<=len(case['action']) and case['action'][event['start']:event['end']]==event['raw'],'independent authored scalar occurrence'
    assert data['id']==case['id'] and data['action']==case['action'],'exact source case'
    assert data['dependency_keys']==['build_array_pipeline_plan_from_expr','normalize_method_args_with_optional_scope','parse_method_function_expr','split_action_ir_statements','trim_action_ir_value'],'complete default dependency population'
    assert data['failure'] is None and data['internal_stdout']==data['internal_stderr']=='','successful Toolbox channels'
    assert [r['contract'] for r in data['rows']]==case['contracts'],'complete ordered contract population'
    for row in data['rows']:
        expected=case['expected'].get(row['contract'],[])
        events=[{k:e[k] for k in ('raw','args')} for e in expected]
        assert row['public_events']==row['private_result']['events']==events,'literal original event arguments and composite order'
        assert row['public_calls']==row['private_calls'],'unchanged exact callback effects'
        assert all(c['callback'] in data['dependency_keys'] and 'args' in c and 'result' in c for c in row['private_calls']),'complete callback effect records'
        origins=row['private_result']['source_origins']
        authored=expected if row['contract']=='if_flow' else []
        assert len(origins)==len(authored),'original hook population'
        for origin,e in zip(origins,authored,strict=True):
            assert origin=={'event':{'raw':e['raw'],'args':e['args']},'source':case['action'],'source_span':{'start':e['start'],'end':e['end']}},'original scalar source identity'
        assert row['identity']==[{'origin_event':True,'constructed_event':True,'constructed_args':True} for _ in authored],'actual returned constructor argument references'
    assert isinstance(data['substitution'],str) and isinstance(data['diagnostics'],dict) and isinstance(data['dump'],str),'complete public compiler channels'


def check_report(report,manifest,cases):
    assert report['complete'] is True and report['revision']==REVISION,'complete diagnosis boundary'
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()),'actual capture producer'
    stream='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256']==sha((ROOT/stream).read_bytes()),'actual stream producer'
    population=[('fixtures',0)]+[(c['id'],s) for s in (0,1,42) for c in cases]
    assert [(r['kind'],r['seed']) for r in report['runs']]==population,'complete command population'
    total=len(manifest['entries'])+len(manifest['overlays'])
    for row in report['runs']:
        tail=['prove','-v','-Iperl']+TESTS if row['kind']=='fixtures' else ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix(),row['kind']]
        assert row['command']==['bash','tools/project_data_run.sh']+tail,'actual command identity'
        assert row['exit']==0 and row['inputs_before']==row['inputs_after']==total,'complete immutable runtime guards'
        assert decode(row['stderr'])==b'','empty outer stderr'
        decode(row['stdout'])
    text=decode(report['runs'][0]['stdout']).decode()
    sections=re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n',text,flags=re.M)
    assert sections[1::2]==TESTS,'complete suite population'
    for body,count in zip(sections[2::2],PLANS,strict=True):
        assert re.findall(r'^1\.\.(\d+)\s*$',body,re.M)==[str(count)],'complete fixture plan'
        assert [int(n) for n in re.findall(r'^ok (\d+)\b',body,re.M)]==list(range(1,count+1)),'positive fixture reach'
        assert not re.search(r'^\s*not ok\b',body,re.M),'no nested fixture failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text,'actual fixture success'
    for case in cases:
        rows=[r for r in report['runs'][1:] if r['kind']==case['id']]
        for row in rows:check_case(json.loads(decode(row['stdout'])),case)
        assert len({decode(r['stdout']) for r in rows})==1,'complete compiler callback source seed recurrence'


def main():
    runtime_cases=json.loads(Path(PREFIX+'cases.json').read_bytes())
    original_spec=importlib.util.spec_from_file_location('original_flow_author',PREFIX+'oracle.py')
    original=importlib.util.module_from_spec(original_spec);original_spec.loader.exec_module(original)
    assert runtime_cases==original.author(),'exact original authored runtime input'
    cases=oracle.author()
    assert [{k:c[k] for k in ('id','action','contracts')} for c in cases]==[{k:c[k] for k in ('id','action','contracts')} for c in runtime_cases],'same actual source and dispatch after review correction'
    m=json.loads(Path(PREFIX+'inputs.json').read_bytes());r=json.loads(Path(PREFIX+'observations.json').read_bytes())
    check_inputs(m);check_report(r,m,cases)
    controls=[]
    def reject(name,fn,reason):
        try:fn()
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'observed':'RED','reason':str(error)});return
        raise AssertionError('control accepted: '+name)
    def changed_report(name,edit,reason):
        x=copy.deepcopy(r);edit(x);reject(name,lambda:check_report(x,m,cases),reason)
    changed_report('omitted command',lambda x:x['runs'].pop(),'complete command population')
    changed_report('lost guard',lambda x:x['runs'][0].update(inputs_after=0),'complete immutable runtime guards')
    changed_report('truncated channel',lambda x:x['runs'][0]['stdout'].update(bytes=1),'complete channel bytes')
    for case in cases:
        data=json.loads(decode(next(row for row in r['runs'] if row['kind']==case['id'])['stdout']))
        x=copy.deepcopy(data);next(row for row in x['rows'] if row['public_events'])['public_events'].pop()
        reject(case['id']+' omitted occurrence',lambda:check_case(x,case),'literal original event arguments and composite order')
    case=next(c for c in cases if c['id']=='recursive');data=json.loads(decode(next(row for row in r['runs'] if row['kind']=='recursive')['stdout']))
    x=copy.deepcopy(data);row=next(a for a in x['rows'] if a['contract']=='case_flow');row['public_events'].sort(key=lambda e:e['raw'])
    reject('global sort',lambda:check_case(x,case),'literal original event arguments and composite order')
    x=copy.deepcopy(data);x['rows'][0]['private_calls'].append({'callback':'trim_action_ir_value','args':[],'result':'changed'})
    reject('changed callback',lambda:check_case(x,case),'unchanged exact callback effects')
    case=cases[0];data=json.loads(decode(r['runs'][1]['stdout']))
    for field in ('origin_event','constructed_event','constructed_args'):
        x=copy.deepcopy(data);x['rows'][0]['identity'][0][field]=False
        reject(field,lambda:check_case(x,case),'actual returned constructor argument references')
    x=copy.deepcopy(data);x['rows'][0]['private_result']['source_origins'][0]['source_span']['start']+=1
    reject('wrong scalar span',lambda:check_case(x,case),'original scalar source identity')
    x=copy.deepcopy(m);x['entries'].pop();reject('omitted Git input',lambda:check_inputs(x),'complete unique original Git population')
    summary={'complete':True,'revision':REVISION,'regular_inputs':len(m['entries']),'overlays':len(m['overlays']),
             'contracts':len(oracle.IDS),'cases':len(cases),'seeds':3,'actual_commands':len(r['runs']),
             'fixture_suites':len(TESTS),'fixture_groups':sum(PLANS),'controls':controls,
             'events_per_seed':sum(len(e) for c in cases for e in c['expected'].values()),
             'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='controls'}));print(str(len(controls))+' distinguishing controls RED')


if __name__=='__main__':main()

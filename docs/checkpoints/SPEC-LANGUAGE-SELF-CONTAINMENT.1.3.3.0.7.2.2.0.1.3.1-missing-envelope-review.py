"""Verify one declared Flow owner delta and exact original public effects."""
from pathlib import Path
import copy
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
REVISION='f3f87ce110db89fca0e3db4debd4d9948df0b8df'
OWNER='perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm'
ORIGINAL='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-'
spec=importlib.util.spec_from_file_location('original_flow_review',ROOT/(ORIGINAL+'review.py'))
original=importlib.util.module_from_spec(spec);spec.loader.exec_module(original)
sha=original.sha;decode=original.decode
CASES=original.oracle.author()
TESTS=['t/actionir_flow_direct_source_provenance.t','t/phase0_regression.t','t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t']
PLANS=[21,1034,13,28,23,15,20,4]


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
                current=Path(PREFIX+'after-FlowRules.pm').read_bytes()
                assert e['sha256']==sha(current) and e['bytes']==len(current) and current==(ROOT/OWNER).read_bytes(),'exact selected owner delta'
            else:
                assert not e.get('declared_owner_delta') and e['bytes']==size and e['sha256']==sha(raw),'unchanged original Git bytes'
                if path.startswith(('perl/','specs/','t/')) and path!=OWNER:assert raw==(ROOT/path).read_bytes(),'unchanged other production and tests'
            if path==OWNER:assert raw==Path(PREFIX+'before-FlowRules.pm').read_bytes(),'exact retained original owner'
    finally:
        proc.stdin.close();proc.stdout.close();assert proc.wait()==0
    overlays=[Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix(),'t/actionir_flow_direct_source_provenance.t']
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
            assert [int(n) for n in re.findall(r'^not ok (\d+)\b',body,re.M)]==list(range(2,15))+[16,18,21],'original exact missing-origin RED'
    assert ('Result: PASS' if epoch=='after' else 'Result: FAIL') in text,'actual fixture outcome'


def check_data(data,epoch):
    assert len(data)==len(CASES),'complete original source population'
    for result,case in zip(data,CASES,strict=True):
        expected_only_original=copy.deepcopy(result)
        if epoch=='after':
            for row in expected_only_original['rows']:
                if row['contract']!='if_flow':row['private_result']['source_origins']=[];row['identity']=[]
        original.check_case(expected_only_original,case)
        for row in result['rows']:
            events=case['expected'].get(row['contract'],[])
            hooked=row['contract']!='case_flow' and row['contract']!='default_flow' and (epoch=='after' or row['contract']=='if_flow')
            expected=events if hooked else []
            assert row['private_result']['source_origins']==[{'event':{'raw':e['raw'],'args':e['args']},'source':case['action'],'source_span':{'start':e['start'],'end':e['end']}} for e in expected],'literal direct original scalar origins'
            assert row['identity']==[{'origin_event':True,'constructed_event':True,'constructed_args':True} for e in expected],'actual returned constructor argument identities'


def check_report(r,m,epoch):
    assert r['complete'] is True and r['revision']==REVISION and r['epoch']==epoch,'complete exact epoch capture'
    assert r['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()),'actual capture instrument'
    stream='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert r['stream_instrument_sha256']==sha((ROOT/stream).read_bytes()),'actual stream instrument'
    assert [(x['kind'],x['seed']) for x in r['runs']]==[('fixtures' if epoch=='after' else 'regression',0)]+[('toolbox',s) for s in (0,1,42)],'complete guarded command population'
    for row in r['runs']:
        tail=['prove','-v','-Iperl']+(TESTS if epoch=='after' else TESTS[:1]) if row['kind']!='toolbox' else ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]
        assert row['command']==['bash','tools/project_data_run.sh']+tail,'exact actual command'
        assert row['exit']==(1 if epoch=='before' and row['kind']=='regression' else 0),'actual RED or GREEN exit'
        assert row['inputs_before']==row['inputs_after']==len(m['entries'])+len(m['overlays']),'complete runtime input guards'
        decode(row['stdout'])
        stderr=decode(row['stderr']).decode()
        if epoch=='before' and row['kind']=='regression':
            expected=['each original direct occurrence has an origin','literal Unicode scalar intervals preserve CRLF and repeated twins','all original constructors reach the source hook']*13
            expected+=['changed first entry declines authority; unchanged second occurrence retains its own frame','origin belongs to actual second returned event','outer occurrence frames restored']+['authored alias span']*7
            assert all(re.fullmatch(r'\s*(?:#.*)?',line) for line in stderr.splitlines()),'only expected RED harness diagnostics'
            assert re.findall(r"^    #   Failed test '(.+)'$",stderr,re.M)==expected,'exact original missing-origin RED diagnostics'
        else:assert stderr=='','empty outer stderr'
    check_tap(r['runs'][0],epoch)
    for row in r['runs'][1:]:check_data(json.loads(decode(row['stdout'])),epoch)
    assert len({decode(row['stdout']) for row in r['runs'][1:]})==1,'exact full source callback compiler seed recurrence'


def check_pair(before,after):
    for b,a in zip(before['runs'][1:],after['runs'][1:],strict=True):
        old=json.loads(decode(b['stdout']));new=json.loads(decode(a['stdout']))
        assert len(old)==len(new),'complete compiler recurrence population'
        for old_case,new_case in zip(old,new,strict=True):
            for old_row,new_row in zip(old_case['rows'],new_case['rows'],strict=True):
                new_row['private_result']['source_origins']=old_row['private_result']['source_origins']
                new_row['identity']=old_row['identity']
        assert new==old,'complete original public callback compiler channels unchanged'


def main():
    reports={};manifests={}
    for epoch in ('before','after'):
        m=json.loads(Path(PREFIX+epoch+'-inputs.json').read_bytes());r=json.loads(Path(PREFIX+epoch+'-observations.json').read_bytes())
        check_inputs(m,epoch);check_report(r,m,epoch);reports[epoch]=r;manifests[epoch]=m
    check_pair(reports['before'],reports['after'])
    controls=[]
    def reject(name,fn,reason):
        try:fn()
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'observed':'RED','reason':str(error)});return
        raise AssertionError('accepted control: '+name)
    data=json.loads(decode(reports['after']['runs'][1]['stdout']))
    for index,case in enumerate(CASES[:14]):
        x=copy.deepcopy(data);x[index]['rows'][0]['private_result']['source_origins'].pop()
        reject(case['id']+' missing origin',lambda:check_data(x,'after'),'literal direct original scalar origins' if case['id']!='if_flow' else 'original hook population')
    for field in ('origin_event','constructed_event','constructed_args'):
        x=copy.deepcopy(data);x[1]['rows'][0]['identity'][0][field]=False
        reject(field,lambda:check_data(x,'after'),'actual returned constructor argument identities')
    x=copy.deepcopy(data);x[1]['rows'][0]['private_result']['source_origins'][0]['source_span']['start']+=1
    reject('wrong scalar interval',lambda:check_data(x,'after'),'literal direct original scalar origins')
    x=copy.deepcopy(data);x[1]['rows'][0]['private_calls'].pop()
    reject('lost callback',lambda:check_data(x,'after'),'unchanged exact callback effects')
    x=copy.deepcopy(reports['after']);x['runs'].pop();reject('lost actual run',lambda:check_report(x,manifests['after'],'after'),'complete guarded command population')
    x=copy.deepcopy(manifests['after']);x['entries'].pop();reject('lost Git input',lambda:check_inputs(x,'after'),'complete unique Git membership')
    counts={}
    for epoch,r in reports.items():
        counts[epoch]=sum(len(row['private_result']['source_origins']) for run in r['runs'][1:] for case in json.loads(decode(run['stdout'])) for row in case['rows'])
    assert counts=={'before':6,'after':87},'complete observed original origin population'
    x=copy.deepcopy(reports['before']);x['runs'][0]['stderr']=original.envelope(decode(x['runs'][0]['stderr'])+b'Unexpected runtime failure\n')
    reject('unrelated RED stderr',lambda:check_report(x,manifests['before'],'before'),'only expected RED harness diagnostics')
    summary={'complete':True,'revision':REVISION,'regular_inputs':len(manifests['before']['entries']),'overlays':len(manifests['before']['overlays']),
             'direct_contracts':14,'new_regex_hooks':12,'new_statement_hooks':1,'seeds':3,'actual_commands':8,'before_red_groups':16,'after_green_groups':21,
             'fixture_suites':len(TESTS),'fixture_groups':sum(PLANS),'before_origins':counts['before'],'after_origins':counts['after'],'complete_compiler_pairs':48,
             'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='controls'}));print(str(len(controls))+' reason-specific evidence controls RED')


if __name__=='__main__':main()

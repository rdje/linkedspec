"""Review original Legacy effects against authored intervals and immutable Git bytes."""
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
REVISION='0083dc7af44fe64f329339da6b764d0806cf1717'
TESTS=['t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t','t/phase0_regression.t']
PLANS=[23,28,23,15,20,4,1034]
OWNER="perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm"
FIXTURE="t/actionir_helper_source_provenance.t"
spec=importlib.util.spec_from_file_location('flow_literal_oracle',PREFIX+'oracle.py')
oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)


def sha(raw):return hashlib.sha256(raw).hexdigest()


def decode(e):
    assert e['encoding']=='gzip-base64','channel encoding'
    raw=gzip.decompress(base64.b64decode(e['data'],validate=True))
    assert len(raw)==e['bytes'] and sha(raw)==e['sha256'],'complete channel bytes'
    return raw


def envelope(raw):
    return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}

def alter_fixture_channel(report, transform):
    report['runs'][0]['stdout']=envelope(transform(decode(report['runs'][0]['stdout'])))

def check_inputs(m):
    epoch=m["epoch"];assert epoch in ("before","after"), "input epoch"
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
            e=entries[path];assert (e['mode'],e['oid'],e.get('baseline_bytes',e['bytes']))==identity,'Git metadata'
            proc.stdin.write((e['oid']+'\n').encode());proc.stdin.flush()
            assert proc.stdout.readline().split()==[e['oid'].encode(),b'blob',str(identity[2]).encode()],'blob header'
            raw=proc.stdout.read(identity[2]);assert proc.stdout.read(1)==b'\n','blob framing'
            assert sha(raw)==e.get('baseline_sha256',e['sha256']),'original input bytes'
            replaced = path == FIXTURE or (epoch == 'after' and path == OWNER)
            assert bool(e.get('declared_fixture_overlay')) == (path == FIXTURE), 'exact fixture replacement'
            assert bool(e.get('declared_owner_delta')) == (epoch == 'after' and path == OWNER), 'exact owner replacement'
            if replaced:
                actual=(ROOT/path).read_bytes()
                assert e['bytes']==len(actual) and e['sha256']==sha(actual),'declared replacement bytes'
            elif path.startswith(('perl/','specs/','t/')) and path not in (OWNER,FIXTURE):
                assert raw==(ROOT/path).read_bytes(),'unchanged production and fixtures'
    finally:
        proc.stdin.close();proc.stdout.close();assert proc.wait()==0
    expected=[Path(PREFIX+n).relative_to(ROOT).as_posix() for n in ('cases.json','probe.pl','oracle.py')]
    assert [e['path'] for e in m['overlays']]==expected,'exact overlay population'
    for e in m['overlays']:
        raw=(ROOT/e['path']).read_bytes()
        assert e['mode']=='100644' and e['bytes']==len(raw) and e['sha256']==sha(raw),'authored overlay bytes'

def check_report(report, manifest, cases):
    epoch=manifest["epoch"];assert report["epoch"]==epoch,"report epoch"
    assert report['complete'] is True and report['revision'] == REVISION, 'complete diagnosis boundary'
    assert report['instrument_sha256'] == sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
    stream = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256'] == sha((ROOT/stream).read_bytes()), 'actual stream producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('regression' if epoch=='before' else 'fixtures', 0), ('legacy', 0), ('legacy', 1), ('legacy', 42)], 'complete command population'
    total = len(manifest['entries']) + len(manifest['overlays'])
    channels = []
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + ([FIXTURE] if epoch=='before' else TESTS) if row['kind'] != 'legacy' else ['perl', '-Iperl', Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual command identity'
        assert row['exit'] == (1 if epoch=='before' and row['kind']=='regression' else 0) and row['inputs_before'] == row.get('inputs_after') == total, 'complete runtime guards'
        stderr=decode(row['stderr'])
        if row['kind']!='regression':assert stderr==b'','empty outer stderr'
        raw = decode(row['stdout'])
        if row['kind'] == 'legacy':
            oracle.check(json.loads(raw), cases, epoch)
            channels.append(raw)
        else:
            text=raw.decode()
            if epoch=='before':
                assert re.findall(r'^not ok (\d+)\b',text,re.M)==['14','15','16','17','18','19','21','22','23'], 'actual nine original RED groups'
                assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==['23'], 'complete original RED plan'
                assert re.findall(r'^ok (\d+)\b',text,re.M)==[str(i) for i in range(1,24) if i not in (14,15,16,17,18,19,21,22,23)], 'complete unchanged positive groups'
            else:
                assert not re.search(r'^\s*not ok\b',text,re.M),'all nested fixture assertions pass'
                for test,plan in zip(TESTS,PLANS):
                    part=text.split(test+' ..',1)[1].split('\n1..'+str(plan),1)[0]
                    assert re.findall(r'^ok (\d+)\b',part,re.M)==[str(i) for i in range(1,plan+1)],'complete ordered positive fixture reach'
                assert re.findall(r'^1\.\.(\d+)\s*$',text,re.M)==[str(n) for n in PLANS],'complete fixture plans'
    assert channels[0] == channels[1] == channels[2], 'full original channels identical across seeds'

def check_source_delta(original, current):
    """The unchanged Git file is an independent byte oracle for all seven hooks."""
    names = ('call', 'push_single_arg', 'push_indexed_arg', 'push_target_arg',
             'push_target_indexed_arg', 'push_scope_target_arg', 'return')
    restored = current
    for name in names:
        pattern = rb'^sub _scan_contract_' + name.encode() + rb' \{.*?(?=^sub |\Z)'
        match = re.search(pattern, restored, re.M | re.S)
        assert match, 'complete source producer population'
        block = match.group()
        coordinate = b' my ($start, $end) = ($-[0], $+[0]);\n'
        assert block.count(coordinate) == 1, 'one source snapshot per producer'
        assert re.search(rb'^while[^\n]*\n' + re.escape(coordinate), block, re.M), 'source snapshot precedes checks and callbacks'
        block = block.replace(coordinate, b'')
        wrapper = rb' push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event\(\n  (\{raw => [^\n]*\}),\n  \$code, \$start, \$end,\n \);'
        block, count = re.subn(wrapper, lambda m: b' push @events, ' + m[1] + b';', block)
        assert count == 1, 'one original event wrapper per producer'
        restored = restored[:match.start()] + block + restored[match.end():]
    assert restored == original, 'only seven source snapshots and original event wrappers change'

def main():
    cases=json.loads(Path(PREFIX+'cases.json').read_bytes());reports={};manifests={}
    for epoch in ('before','after'):
        m=json.loads(Path(PREFIX+epoch+'-inputs.json').read_bytes());r=json.loads(Path(PREFIX+epoch+'-observations.json').read_bytes())
        check_inputs(m);check_report(r,m,cases);manifests[epoch]=m;reports[epoch]=r
    before=json.loads(decode(reports['before']['runs'][1]['stdout']));after=json.loads(decode(reports['after']['runs'][1]['stdout']))
    compare_compatibility(before, after)
    assert manifests['before']['overlays']==manifests['after']['overlays'],'identical authored overlays'
    b={e['path']:e for e in manifests['before']['entries']};a={e['path']:e for e in manifests['after']['entries']}
    assert a.keys()==b.keys(),'same original input population'
    assert [p for p in a if a[p]!=b[p]]==[OWNER],'one declared production change'
    original_source=subprocess.check_output(['git','show',REVISION+':'+OWNER],cwd=ROOT)
    assert (ROOT/OWNER).read_bytes().count(b'_record_scanned_source_event(')-original_source.count(b'_record_scanned_source_event(')==7,'seven new original producer hooks'
    assert Path(PREFIX+'cases.json').read_bytes()==(ROOT/'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json').read_bytes(),'original independent literal fixture identity'
    controls=[]
    def reject(name,target,mutation,validator,reason):
        bad=copy.deepcopy(target);mutation(bad)
        try:validator(bad)
        except (AssertionError,KeyError,ValueError,IndexError) as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'observed':'RED','reason':str(error)})
        else:raise AssertionError('accepted corruption: '+name)
    for index,case in enumerate(cases[:112]):
        reject(case['id']+' omitted event',after,lambda x,i=index:x[i]['rows'][0]['public_events'].pop(),lambda x:oracle.check(x,cases,'after'),'literal original events and arguments')
    for index,case in enumerate(cases[:8]):
        reject(case['id']+' missing source origin',after,lambda x,i=index:x[i]['rows'][0]['private_result']['source_origins'].pop(),lambda x:oracle.check(x,cases,'after'),'exact original source origin population')
    for key in ('origin_event','constructed_event','constructed_args'):
        reject('forged '+key,after,lambda x,k=key:x[0]['rows'][0]['identity'][0].update({k:False}),lambda x:oracle.check(x,cases,'after'),'actual returned constructor argument references')
    reject('wrong repeated source interval',after,lambda x:x[0]['rows'][0]['private_result']['source_origins'][1]['source_span'].update(start=3),lambda x:oracle.check(x,cases,'after'),'exact original source origin population')
    reject('lost callback effects',after,lambda x:x[3]['rows'][0]['private_calls'].clear(),lambda x:oracle.check(x,cases,'after'),'exact default callback sequence and results')
    reject('changed compiler dump',after,lambda x:x[0].update(dump='changed'),lambda x: compare_compatibility(before,x),'all original public callback compiler channels unchanged')
    reject('lost command',reports['after'],lambda x:x['runs'].pop(),lambda x:check_report(x,manifests['after'],cases),'complete command population')
    reject('lost guard',reports['after'],lambda x:x['runs'][1].pop('inputs_after'),lambda x:check_report(x,manifests['after'],cases),'complete runtime guards')
    reject('forged channel',reports['after'],lambda x:x['runs'][1]['stdout'].update(sha256='0'*64),lambda x:check_report(x,manifests['after'],cases),'complete channel bytes')
    reject('forged producer',reports['after'],lambda x:x.update(instrument_sha256='0'*64),lambda x:check_report(x,manifests['after'],cases),'actual capture producer')
    reject('lost Git input',manifests['after'],lambda x:x['entries'].pop(),check_inputs,'complete unique original Git population')
    reject('lost overlay',manifests['after'],lambda x:x['overlays'].pop(),check_inputs,'exact overlay population')
    reject('forged successful fixture exit',reports['after'],lambda x:x['runs'][0].update(exit=1),lambda x:check_report(x,manifests['after'],cases),'complete runtime guards')
    reject('lost ordered TAP reach',reports['after'],lambda x:alter_fixture_channel(x,lambda raw:re.sub(rb'^ok 1[^\n]*\n',b'',raw,count=1,flags=re.M)),lambda x:check_report(x,manifests['after'],cases),'complete ordered positive fixture reach')
    reject('hidden nested failure',reports['after'],lambda x:alter_fixture_channel(x,lambda raw:b'    not ok 1 - forged nested failure\n'+raw),lambda x:check_report(x,manifests['after'],cases),'all nested fixture assertions pass')
    for index in (112,113):
        reject(cases[index]['id']+' invented excluded origin',after,lambda x,i=index:x[i]['rows'][0]['private_result']['source_origins'].append({'event':{}}),lambda x:oracle.check(x,cases,'after'),'exact original source origin population')
    reject('invented uninstrumented capture origin',after,lambda x:x[8]['rows'][0]['private_result']['source_origins'].append({'event':{}}),lambda x:oracle.check(x,cases,'after'),'exact original source origin population')
    source = {'source': (ROOT/OWNER).read_bytes()}
    reject('changed original call regex', source, lambda x: x.update(source=x['source'].replace(rb'\bcall\s*', rb'\bxcall\s*', 1)), lambda x: check_source_delta(original_source, x['source']), 'only seven source snapshots and original event wrappers change')
    reject('lost producer coordinate snapshot', source, lambda x: x.update(source=x['source'].replace(b' my ($start, $end) = ($-[0], $+[0]);\n', b'', 1)), lambda x: check_source_delta(original_source, x['source']), 'one source snapshot per producer')
    result={'complete':True,'revision':REVISION,'regular_inputs':len(a),'overlays':3,'fixture_replacement':FIXTURE,'production_delta':OWNER,'contracts':112,'cases':115,'commands':8,'seeds':3,'before_origins':2,'after_origins':18,'events_per_seed':227,'before_red_groups':9,'after_green_groups':23,'fixture_suites':len(TESTS),'fixture_groups':sum(PLANS),'compiler_cases_per_seed':sum(c['toolbox'] for c in cases),'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k!='controls'}));print(str(len(controls))+' reason-specific controls RED')

def compare_compatibility(before,after):
    before,after=copy.deepcopy(before),copy.deepcopy(after)
    for rows in (before,after):
        for row in rows:
            for result in row['rows']:
                result['private_result'].pop('source_origins');result.pop('identity')
    assert before==after,'all original public callback compiler channels unchanged'

if __name__=='__main__':main()

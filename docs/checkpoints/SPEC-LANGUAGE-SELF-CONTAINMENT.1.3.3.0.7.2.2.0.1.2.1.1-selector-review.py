"""Independently reconstruct exact scanner inputs and falsify historical exemptions."""
from pathlib import Path
import base64,copy,gzip,hashlib,importlib.util,io,json,re,subprocess,tarfile,tempfile,types
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('selector-review.py')
REVISION='95e6a02935155b9ab7b5c30f79a3275529b803da'
TARGET='tools/check_executable_aggregate_selector_sources.py'
OLD=Path(PREFIX+'before-check_executable_aggregate_selector_sources.py').relative_to(ROOT).as_posix()
PRIOR='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-'
EXPECTED={PRIOR+'claim.py':'52a83a6bb01129e7f0c96f594a6e85bb2f25cedfbd86d91853a3e620b92bb90e',PRIOR+'split-probe-initial.pl':'1f96bcb1dd60201a602282b576074b0ab3abfd77fcf006ab16417bc25d8627c3'}
def sha(raw):return hashlib.sha256(raw).hexdigest()
def decode(channel):
    assert channel['encoding']=='gzip-base64','channel encoding'
    raw=gzip.decompress(base64.b64decode(channel['data'],validate=True))
    assert len(raw)==channel['bytes'] and sha(raw)==channel['sha256'],'complete channel bytes'
    return raw

def recover(report):
    raw=Path(PREFIX+'selector-inputs.tar.gz').read_bytes()
    assert sha(raw)==report['capsule_sha256'],'capsule identity'
    overlays={}
    with tarfile.open(fileobj=io.BytesIO(gzip.decompress(raw)),mode='r:') as tar:
        for item in tar:
            assert item.isfile() and item.name not in overlays and not Path(item.name).is_absolute() and '..' not in Path(item.name).parts,'unique regular relative member'
            overlays[item.name]=(tar.extractfile(item).read(),item.mode)
    entries={e['path']:e for e in report['entries']}
    assert len(entries)==len(report['entries']),'unique input population'
    assert set(overlays)=={p for p,e in entries.items() if e['source']=='capsule'},'exact authored overlay membership'
    inventory=report['inventory'];excluded=report['excluded']
    assert inventory==sorted(set(inventory)) and len({e['path'] for e in excluded})==len(excluded),'unique inventory/exclusions'
    assert set(entries).isdisjoint(e['path'] for e in excluded) and set(entries)|{e['path'] for e in excluded}==set(inventory),'complete supplied input census'
    actual={};nonregular={}
    for row in filter(None,subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')):
        meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):actual[path.decode()]=(int(mode[-3:],8),oid.decode(),int(size))
        else:nonregular[path.decode()]=(mode.decode(),kind.decode())
    assert all(e['reason']=='nonregular metadata; no payload read' and e['path'] in nonregular for e in excluded),'exact black-box exclusion'
    assert set(actual)<=set(entries),'all immutable regular parent inputs supplied'
    files={};process=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,e in entries.items():
            source=e['source']
            if source=='git':
                assert e['revision']==REVISION and (e['mode'],e['oid'],e['bytes'])==actual[path],'original Git member identity'
                process.stdin.write((e['oid']+'\n').encode());process.stdin.flush()
                assert process.stdout.readline().split()==[e['oid'].encode(),b'blob',str(e['bytes']).encode()],'Git blob framing'
                raw=process.stdout.read(e['bytes']);assert process.stdout.read(1)==b'\n','complete Git blob'
                assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==e['oid'],'Git content identity'
                mode=e['mode']
            elif source=='capsule':raw,mode=overlays[path]
            elif source=='retained-artifact':
                assert path==Path(PREFIX+'selector-first-inputs.tar.gz').relative_to(ROOT).as_posix(),'only explicitly retained artifact reference'
                raw=(ROOT/path).read_bytes();mode=(ROOT/path).stat().st_mode&0o777
            else:raise AssertionError('known recovery source')
            assert len(raw)==e['bytes'] and sha(raw)==e['sha256'] and mode==e['mode'],'complete input bytes and mode'
            files[path]=raw
    finally:
        process.stdin.close();process.stdout.close();assert process.wait()==0
    assert files[OLD]==subprocess.check_output(['git','show',REVISION+':'+TARGET],cwd=ROOT),'exact original executed classifier'
    assert files[TARGET]==(ROOT/TARGET).read_bytes(),'exact current classifier producer'
    for path,digest in EXPECTED.items():
        assert sha(files[path])==digest and files[path]==subprocess.check_output(['git','show',REVISION+':'+path],cwd=ROOT),'unchanged historical artifact'
    assert files[Path(PREFIX+'selector-capture.py').relative_to(ROOT).as_posix()]==Path(PREFIX+'selector-capture.py').read_bytes(),'actual capture source'
    assert files[Path(PREFIX+'selector-probe.py').relative_to(ROOT).as_posix()]==Path(PREFIX+'selector-probe.py').read_bytes(),'actual invocation source'
    return files

def load(raw,root):
    module=types.ModuleType('bound_scanner');module.__file__=str(ROOT/TARGET)
    exec(compile(raw,str(ROOT/TARGET),'exec'),module.__dict__)
    module.ROOT=root
    return module

def check(report,files):
    assert report['complete'] is True and report['instrument_sha256']==sha(Path(PREFIX+'selector-capture.py').read_bytes()),'complete actual capture producer'
    assert [r['epoch'] for r in report['runs']]==['before','after','composed'],'exact executed population'
    for row in report['runs']:
        epoch=row['epoch']
        command=['bash','tools/run_python_project_data.sh','tools/check_public_aggregate_selector_surface.py'] if epoch=='composed' else ['bash','tools/project_data_run.sh','python3',Path(PREFIX+'selector-probe.py').relative_to(ROOT).as_posix(),'--epoch',epoch]
        assert row['command']==command and row['exit']==(1 if epoch=='before' else 0),'actual command and expected exit'
        assert row['inputs_before']==row['inputs_after']==len(files),'complete before/after guards'
        decode(row['stdout']);decode(row['stderr'])
    scratch=ROOT/'.linkedspec-data/scratch/selector-classification-review';scratch.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=scratch) as folder:
        root=Path(folder);assert root.stat().st_dev==ROOT.stat().st_dev
        for path,raw in files.items():
            # Reconstruct every regular supplied input; no Git repository or submodule.
            target=root/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw)
        baseline=load(files[OLD],root);candidate=load(files[TARGET],root)
        assert candidate.HISTORICAL_DIAGNOSTIC_INPUTS==EXPECTED,'exact two path/content classifications'
        positive,before_count=baseline.scan_files(report['inventory'])
        assert {line.split(':',1)[0] for line in positive}==set(EXPECTED) and len(positive)==2,'two original distinguishing positives'
        assert decode(report['runs'][0]['stdout'])==b'' and decode(report['runs'][0]['stderr'])==('executable-aggregate-selector-scan: positive selector source remains\n'+'\n'.join(positive)+'\n').encode(),'exact original RED channels'
        after,after_count=candidate.scan_files(report['inventory'])
        assert after==[] and after_count==before_count+2,'only two historical occurrences change classification'
        expected=('executable-aggregate-selector-scan: OK (0 positive; '+str(after_count)+' classified implementation/recognition occurrences; serialized tracked+untracked discovery self-test passed)\n').encode()
        assert decode(report['runs'][1]['stdout'])==expected and decode(report['runs'][1]['stderr'])==b'','actual GREEN channels'
        composed=decode(report['runs'][2]['stdout']).decode()
        assert decode(report['runs'][2]['stderr'])==b'' and '3 staggered concurrent scans serialized; repository-root probes cleaned' in composed and '70 public files; 36 classified removed/history references; 0 current examples; 5 migration contrasts; 11 contrast mutations; capability admitted' in composed,'complete composed admission/concurrency outcome'
        controls=[]
        for index,(path,digest) in enumerate(EXPECTED.items()):
            original=files[path];target=root/path
            for label,raw in [('changed historical bytes',original+b'\n# changed bytes\n'),('added positive selector',original+b'\n'+('my $new = '+ 'array'+'(items);\n').encode())]:
                target.write_bytes(raw);matches,_=candidate.scan_files([path]);assert matches,'changed input remains positive'
                controls.append({'name':str(index)+' '+label,'observed':'RED','reason':'full historical content identity changed; positive candidate rejected'})
            target.write_bytes(original)
            copied='copied-historical-'+str(index)+Path(path).suffix; (root/copied).write_bytes(original)
            matches,_=candidate.scan_files([copied]);assert matches,'copy remains positive'
            controls.append({'name':str(index)+' copied historical path','observed':'RED','reason':'unrecognized path cannot borrow a content classification'})
            for label,value in [('missing classification',None),('wrong digest','0'*64)]:
                candidate.HISTORICAL_DIAGNOSTIC_INPUTS=dict(EXPECTED)
                if value is None:del candidate.HISTORICAL_DIAGNOSTIC_INPUTS[path]
                else:candidate.HISTORICAL_DIAGNOSTIC_INPUTS[path]=value
                matches,_=candidate.scan_files([path]);assert matches,'missing or wrong classification rejected'
                controls.append({'name':str(index)+' '+label,'observed':'RED','reason':'exact expected path/digest authorization is required'})
        candidate.HISTORICAL_DIAGNOSTIC_INPUTS=dict(EXPECTED)
    return controls,before_count,after_count

def main():
    report=json.loads(Path(PREFIX+'selector-actual.json').read_bytes());files=recover(report)
    controls,before,after=check(report,files)
    # Channel/completeness controls are checked against actual recovered producer inputs.
    for name,alter in [('incomplete capture',lambda r:r.update(complete=False)),('wrong producer',lambda r:r.update(instrument_sha256='0'*64)),('missing command',lambda r:r['runs'].pop()),('wrong original exit',lambda r:r['runs'][0].update(exit=0)),('short input guard',lambda r:r['runs'][1].update(inputs_after=0)),('corrupt output hash',lambda r:r['runs'][1]['stdout'].update(sha256='0'*64))]:
        changed=copy.deepcopy(report);alter(changed)
        try:check(changed,files)
        except AssertionError as error:controls.append({'name':name,'observed':'RED','reason':str(error)})
        else:raise AssertionError('evidence corruption accepted: '+name)
    # Independent complete census guards reject missing or duplicate artifact members.
    for name,alter in [('missing input',lambda r:r['entries'].pop()),('duplicate input',lambda r:r['entries'].append(r['entries'][0]))]:
        changed=copy.deepcopy(report);alter(changed)
        try:recover(changed)
        except AssertionError as error:controls.append({'name':name,'observed':'RED','reason':str(error)})
        else:raise AssertionError('input corruption accepted: '+name)
    result={'complete':True,'regular_inputs':len(files),'actual_commands':3,'historical_classifications':2,'original_positive_occurrences':2,'current_positive_occurrences':0,'classified_before':before,'classified_after':after,'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes()),'scope':'Exact fixed candidate snapshot supplies every regular Git inventory input. Immutable Git95 objects recover unchanged members; declared overlays recover from capsule and the separately retained first capsule. Actual original/current/composed command channels, source identity and guards are independently checked. Ten classification and eight evidence/input RED controls preserve positive discovery. No full canonical pass is inferred.'}
    Path(PREFIX+'selector-verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print('Historical selector classification PASS; '+str(len(files))+' closed regular inputs, 3 actual commands, 2 RED-to-classified occurrences, '+str(len(controls))+' distinguishing controls')
if __name__=='__main__':main()

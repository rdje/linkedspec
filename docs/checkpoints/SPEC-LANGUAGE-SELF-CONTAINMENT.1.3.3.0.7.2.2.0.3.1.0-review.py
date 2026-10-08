"""Independently recover complete inputs and compare original/current private handoff evidence."""
from pathlib import Path
import base64, copy, datetime, gzip, hashlib, json, re, subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
BASE='32169d1282effa083a431b17b11c436fdd862771'
PUBLIC='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-'
OWNERS=['perl/LinkedSpec/ActionIR/'+name+'.pm' for name in ['SourceOrigins','Scanner','Diagnostics','CanonicalEvents','CanonicalEvents/Core','RewritePipeline']]
def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT/path).read_bytes()
def data(suffix): return json.loads(Path(PREFIX+suffix+'.json').read_bytes())
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)
def unpack(envelope):
    assert envelope['encoding']=='gzip-base64'
    raw=gzip.decompress(base64.b64decode(envelope['data'],validate=True))
    assert len(raw)==envelope['bytes'] and sha(raw)==envelope['sha256'],'complete exact channel'
    return raw

def original_inputs():
    entries={}
    for row in filter(None,git('ls-tree','-rlz',BASE).split(b'\0')):
        meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):
            entries[path.decode()]={'mode':mode.decode(),'oid':oid.decode(),'bytes':int(size)}
    process=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,item in entries.items():
            process.stdin.write((item['oid']+'\n').encode());process.stdin.flush()
            assert process.stdout.readline().split()==[item['oid'].encode(),b'blob',str(item['bytes']).encode()]
            raw=process.stdout.read(item['bytes']);assert len(raw)==item['bytes'] and process.stdout.read(1)==b'\n'
            item['sha256']=sha(raw)
    finally:
        process.stdin.close();process.stdout.close();assert process.wait()==0
    return entries

BASE_INPUTS=original_inputs()
FIXTURE=str(Path(PREFIX+'origin-fixture.t').relative_to(ROOT))

def verify_graph(manifest,epoch):
    assert manifest['revision']==BASE and manifest['regular_git_inputs']==len(BASE_INPUTS)
    overlays=[FIXTURE]+(OWNERS if epoch in ('after','after-initial') else [])
    assert manifest['overlays']==overlays,'exact declared overlays'
    entries={item['path']:item for item in manifest['entries']}
    assert len(entries)==len(manifest['entries']) and set(entries)==set(BASE_INPUTS)|set(overlays),'complete regular graph'
    for path,item in entries.items():
        if path not in overlays:
            assert item==BASE_INPUTS[path],'original Git metadata/hash '+path
        else:
            current=path
            if path==FIXTURE and epoch=='before': current=str(Path(PREFIX+'origin-fixture-initial.t').relative_to(ROOT))
            if path==OWNERS[4] and epoch=='after-initial': current=str(Path(PREFIX+'core-import-initial.pm').relative_to(ROOT))
            raw=read(current)
            assert item=={'path':path,'mode':BASE_INPUTS.get(path,{}).get('mode','100644'),'bytes':len(raw),'sha256':sha(raw),'overlay':True},'recoverable declared overlay '+path
    return len(entries)

# Original metadata values omit path; manifests carry it on every original entry.
for path,item in BASE_INPUTS.items(): item['path']=path

cases=json.loads(read(PUBLIC+'cases.json'))
EXPECTED={("public:"+case['id'],seed) for case in cases for seed in (0,1,42)}|{('private-origin-tap',0),('consumers',0)}

def normalize(packet,tree,epoch):
    packet=copy.deepcopy(packet)
    for lookup in packet['lookups']:
        expected=str(ROOT/tree/'perl/LinkedSpec/ActionIR/RewritePipeline.pm')
        assert lookup['caller']==expected,'actual reached owner source locator'
        lookup['caller']='perl/LinkedSpec/ActionIR/RewritePipeline.pm'
        line=lookup['line']
        assert line in ((402,469) if epoch=='before' else (403,470)),'unchanged original/rewrite source call sites'
        owner=git('show',BASE+':'+lookup['caller']).decode() if epoch=='before' else read(lookup['caller']).decode()
        assert '_find_source_stmt_span(' in owner.splitlines()[line-1],'actual source line still calls exact lookup'
        if epoch=='after': lookup['line']-=1
    # Only dated trace-line prefixes vary; error text/body remains exact.
    packet['native']['stdout']=re.sub(r'^\[(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)\]',
        lambda match: '[<clock>]' if datetime.datetime.strptime(match[1],'%Y-%m-%d %H:%M:%S') else '',
        packet['native']['stdout'],flags=re.M)
    return packet

def verify_runs(report,manifest,epoch):
    assert report['complete'] and report['revision']==BASE
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes())
    stream='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256']==sha(read(stream))
    rows={(r['kind'],r['seed']):r for r in report['runs']}
    assert len(rows)==len(report['runs']) and set(rows)==EXPECTED,'complete declared command population'
    for key,row in rows.items():
        assert row['inputs_before']==len(manifest['entries'])==row['inputs_after'],'unchanged complete supplied tree'
        out,err=unpack(row['stdout']),unpack(row['stderr'])
        if key[0].startswith('public:'):
            assert row['command']==['bash','tools/project_data_run.sh','perl','-Iperl',PUBLIC+'probe.pl',key[0][7:]] and row['exit']==0
            assert not err,'complete independent outer error channel'
        elif key[0]=='private-origin-tap':
            assert row['command']==['bash','tools/project_data_run.sh','prove','-v','-Iperl',FIXTURE]
            assert row['exit']==(1 if epoch=='before' else 0) and b'1..10\n' in out
            assert (b'Failed tests:  1-3, 5-7, 10' in out) if epoch=='before' else (b'Tests=10' in out and b'Result: PASS' in out)
        else:
            tests=['t/'+name+'.t' for name in ['actionir_ast_parser','canonical_event_occurrence_order','actionir_nested_block_source_spans','actionir_compiler_source_membership','actionir_executable_source_membership','trace_emit_context_bridge']]
            assert row['command']==['bash','tools/project_data_run.sh','prove','-v','-Iperl']+tests
            assert row['exit']==0 and b'Files=6, Tests=144' in out and b'Result: PASS' in out
    return rows

before_manifest=data('before-inputs');after_manifest=data('after-inputs')
before=data('before-observations');after=data('after-observations')
verify_graph(before_manifest,'before');verify_graph(after_manifest,'after')
verify_graph(data('before-corrected-inputs'),'before-corrected')
verify_graph(data('after-initial-inputs'),'after-initial')
assert not data('after-initial-observations')['complete'],'interrupted after capture is never final acceptance'
br=verify_runs(before,before_manifest,'before');ar=verify_runs(after,after_manifest,'after')

def compare_public(left,right):
    for key in sorted(EXPECTED):
        if key[0].startswith('public:'):
            a=json.loads(unpack(left[key]['stdout']));b=json.loads(unpack(right[key]['stdout']))
            assert normalize(a,before['input_tree'],'before')==normalize(b,after['input_tree'],'after'),'source/value/error/effect/reference/argument/diagnostic preservation '+str(key)
compare_public(br,ar)

# Independently prove that neither original lookup nor replacement body changes.
pipeline=OWNERS[-1];old=git('show',BASE+':'+pipeline).decode();new=read(pipeline).decode()
new=new.replace('use LinkedSpec::ActionIR::SourceOrigins ();\n','',1)
seam=' return LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($code, sub {\n'
assert new.count(seam)==1
start=new.index(seam);body=start+len(seam);end=new.index('\n })\n}',body)
assert all(not line.strip() or line.startswith(' ') for line in new[body:end].splitlines())
unwrapped='\n'.join(line[1:] if line.strip() else line for line in new[body:end].split('\n'))
restored=new[:start]+unwrapped+new[end+len('\n })'):]
assert restored==old,'exact original pipeline after removal of private scope/import only'

initial=read(str(Path(PREFIX+'origin-fixture-initial.t').relative_to(ROOT)))
corrected=read(FIXTURE)
assert initial.replace(b"['copied', sub { [@{$split->($_[0])}] }, [0]],",b"['copied', sub { [@{$split->($_[0])}] }, [0,0]],")==corrected,'one authored expectation correction only'
correction=data('fixture-correction');assert correction['initial_sha256']==sha(initial) and correction['corrected_sha256']==sha(corrected)
for suffix in ('before-tap','before-corrected-tap'):
    tap=data(suffix);assert tap['complete'] and tap['exit']==1
    producer='tap-probe.py' if suffix=='before-tap' else 'tap-probe-corrected.py'
    inputs='before-inputs' if suffix=='before-tap' else 'before-corrected-inputs'
    assert tap['producer_sha256']==sha(Path(PREFIX+producer).read_bytes())
    assert tap['capture_sha256']==sha(Path(PREFIX+'capture.py').read_bytes())
    assert tap['inputs_manifest_sha256']==sha(Path(PREFIX+inputs+'.json').read_bytes())
    assert b'Failed tests:  1-3, 5-7, 10' in unpack(tap['stdout']) and unpack(tap['stderr'])
core=data('core-import-correction');assert core['complete'] and core['red']['exit']!=0 and core['green']['exit']==0
assert b"Can't locate LinkedSpec/ActionIR/SourceOrigins.pm" in unpack(core['red']['stderr'])
assert b'syntax OK' in unpack(core['green']['stderr']);unpack(core['red']['stdout']);unpack(core['green']['stdout']);unpack(core['interrupted_capture_log'])
old_core=read(str(Path(PREFIX+'core-import-initial.pm').relative_to(ROOT)))
assert old_core.replace(b'my $canonical_events_dir = File::Basename::dirname($module_dir);',b'my $canonical_events_dir = $module_dir;')==read(OWNERS[4]),'sole standalone import repair'

inverse=data('inverse');assert inverse['complete'] and len(inverse['controls'])==11
assert inverse['producer_sha256']==sha(Path(PREFIX+'inverse.py').read_bytes())
assert inverse['inputs_manifest_sha256']==sha(Path(PREFIX+'after-inputs.json').read_bytes())
assert inverse['baseline']['exit']==0 and b'Result: PASS' in unpack(inverse['baseline']['stdout']);unpack(inverse['baseline']['stderr'])
for control in inverse['controls']:
    raw=read(control['path']);assert sha(raw)==control['original_sha256']
    old_text,new_text=control['mutation']['old'],control['mutation']['new'];assert raw.decode().count(old_text)==1
    assert sha(raw.decode().replace(old_text,new_text).encode())==control['mutated_sha256']
    assert control['exit']!=0 and control['inputs_before']==len(after_manifest['entries'])==control['inputs_after']
    assert b'1..10\n' in unpack(control['stdout'])
    assert ("Failed test '"+control['oracle']+"'").encode() in unpack(control['stderr'])

activation=data('activation');prior=activation['prior_path'];frozen=json.loads(read(prior));original=json.loads(git('show',BASE+':'+prior))
assert activation['inputs_verified']==81 and activation['original_sha256']==sha(git('show',BASE+':'+prior))
assert activation['frozen_sha256']==sha(read(prior))
def verify_prior(candidate):
    restored=copy.deepcopy(candidate);d=restored['claims'][0]['durability']
    assert d['mode']=='historical' and d['revision']==BASE,'exact original committed boundary'
    d['mode']='live';del d['revision']
    assert restored==original,'exact prior record mode/revision only'
verify_prior(frozen)
for item in original['claims'][0]['durability']['inputs']:assert sha(git('show',BASE+':'+item['path']))==item['sha256']

# Corruptions target semantic comparison and exact input history, with each actual
# rejection retained; checksums alone do not establish the compatibility oracle.
controls=[]
def reject(name,callback):
    try:callback()
    except (AssertionError,KeyError,ValueError) as error:controls.append({'name':name,'observed':'RED','reason':str(error)});return
    raise AssertionError('ineffective evidence control '+name)
lost=copy.deepcopy(after_manifest);lost['entries'].pop();reject('lost-original-graph-entry',lambda:verify_graph(lost,'after'))
forged=copy.deepcopy(after_manifest);next(e for e in forged['entries'] if e['path']==OWNERS[0])['sha256']='0'*64
reject('forged-current-origin-producer',lambda:verify_graph(forged,'after'))
partial=copy.deepcopy(after);partial['runs'].pop();reject('omitted-consumer-result',lambda:verify_runs(partial,after_manifest,'after'))
channel=copy.deepcopy(ar[next(key for key in ar if key[0].startswith('public:'))]['stdout']);channel['sha256']='0'*64
reject('forged-complete-channel',lambda:unpack(channel))
changed=copy.deepcopy(ar);key=('public:quoted_after',0);packet=json.loads(unpack(changed[key]['stdout']));packet['native']['value']=['changed',0]
raw=(json.dumps(packet)+'\n').encode();changed[key]['stdout']={'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
reject('changed-public-value-with-valid-channel-hash',lambda:compare_public(br,changed))
changed=copy.deepcopy(ar);packet=json.loads(unpack(changed[key]['stdout']));packet['lookups'][0]['line']+=1
raw=(json.dumps(packet)+'\n').encode();changed[key]['stdout']={'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
reject('forged-source-location-normalization',lambda:compare_public(br,changed))
wrong=copy.deepcopy(frozen);wrong['claims'][0]['durability']['revision']=git('rev-parse',BASE+'^1').decode().strip()
reject('wrong-prior-claim-boundary',lambda:verify_prior(wrong))
wrong=copy.deepcopy(frozen);wrong['claims'][0]['durability']['inputs'][0]['sha256']='0'*64
reject('refreshed-original-claim-input',lambda:verify_prior(wrong))
result={'complete':True,'revision':BASE,'producer_sha256':sha(Path(__file__).read_bytes()),'original_regular_inputs':len(BASE_INPUTS),'public_pairs':42,'consumer_groups_each_epoch':144,'corrected_original_red_groups':7,'private_green_groups':10,'source_inverse_controls':11,'original_guard_inputs_verified':81,'evidence_controls':controls,'scope':'Four complete regular supplied graphs recover independently from exact Git object metadata/bytes and explicit epoch overlays, including interrupted initial after and corrected original fixture. Complete original/current public packets preserve AST, selected/copy reference relationships, args, source/generated code, diagnostics, native/fresh values/errors/effects. Only independently validated exact owner source locator, one-line import offset at two unchanged lookup sites and dated trace-prefix clocks normalize; raw channels remain complete. Original replacement body is byte-exact after removing only new invocation/import wrapping. Ten-group actual fixture GREEN; corrected original RED7; eleven effective named production inverse controls;81 prior hashes/mode-revision-only qualification. No replacement/readiness fix, other backend claim, recurring CI admission, minimal-IO assertion or completed interrupted capture.'}
Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))

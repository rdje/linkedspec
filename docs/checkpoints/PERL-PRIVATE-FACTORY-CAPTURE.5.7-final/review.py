"""Readonly corrected five-owner composition; --capture freezes its report once."""
import base64
import copy
import gzip
import hashlib
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
INITIAL = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
OBJECT = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
CONTROL = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
FACADE = 'perl/LinkedSpec/RuleIR/EmitContext.pm'
VALUE = 'perl/LinkedSpec/ActionIR/ValueExpr.pm'
OWNERS = {CONTROL,FACADE,VALUE,'perl/LinkedSpec/ActionIR/FlowExpr.pm','perl/LinkedSpec/ActionIR/MethodLowering.pm'}
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
inputs = set()
assert sys.argv[1:] in ([], ['--capture'])
def raw(path):
    inputs.add(path)
    return (ROOT / path).read_bytes()
def load(name):
    return json.loads(raw(PREFIX + name))
def packed(name):
    return json.loads(gzip.decompress(raw(PREFIX + name)))
def old(path):
    return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
def capsule(name, record=None, historical=False):
    data=packed(name)
    if record:
        assert record['capsule_sha256']==sha(raw(PREFIX+name))
        assert record['inputs']=={p:{k:v[k] for k in ('sha256','mode')} for p,v in data.items()}
    for path,item in data.items():
        value=decode(item['bytes_base64']);assert sha(value)==item['sha256']
        assert value==(old(path) if historical and path in OWNERS else raw(path)), ('supplied bytes',name,path)
    return data
def tap(row, count):
    text=decode(row['stdout_base64']).decode()
    tests=re.findall(r'^(not )?ok (\d+) - (.*)$',text,re.M)
    assert re.findall(r'^1\.\.(\d+)$',text,re.M)==[str(count)] and len(tests)==count
    assert [int(n) for _,n,_ in tests]==list(range(1,count+1))
    assert not re.search(r'^Bail out!',text,re.M)
    return [dict(number=int(n),name=title) for bad,n,title in tests if bad]

# The original draft is an immutable supplied snapshot, never a fake Git revision.
preservation=json.loads(raw(OBJECT+'preservation.json'))
assert preservation['result']=='PASS' and preservation['kind']=='uncommitted-logical-draft' and preservation['git_revision'] is None
assert preservation['producer_sha256']==sha(raw(OBJECT+'preserve-initial.py'))
initial_claim=raw(OBJECT+'initial-claim.json')
assert len(initial_claim)==127929 and sha(initial_claim)==preservation['claim_sha256'], 'whole logical publication custody'
assert len(json.loads(initial_claim)['claims'][0]['durability']['inputs'])==546
archive_raw=raw(OBJECT+'initial-inputs.tar.gz')
assert sha(archive_raw)==preservation['archive_sha256']
frozen,modes={},{}
with tarfile.open(fileobj=io.BytesIO(archive_raw)) as stream:
    for item in stream:
        assert item.isfile() and item.name not in frozen
        frozen[item.name]=stream.extractfile(item).read();modes[item.name]=item.mode
assert set(frozen)==set(preservation['inputs'])|{preservation['claim_path']}
assert frozen[preservation['claim_path']]==initial_claim, 'whole logical publication custody'
for path,item in preservation['inputs'].items():
    assert sha(frozen[path])==item['sha256'] and modes[path]==item['mode']
baseline=json.loads(raw(OBJECT+'baseline.json'))
assert baseline==preservation['baseline'] and baseline['returncode']==0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64'])==b'Mixed-default publication PASS: 546 live inputs; 127929 bytes\n'
replay=json.loads(raw(OBJECT+'replay.json'))
assert replay['producer_sha256']==sha(raw(OBJECT+'replay-initial.py'))
assert replay['result']=='PASS' and replay['returncode']==0 and replay['unchanged'] and not decode(replay['stderr_base64'])
assert replay['archive_sha256']==sha(archive_raw)
assert decode(replay['stdout_base64'])==decode(baseline['stdout_base64'])
scan=json.loads(gzip.decompress(frozen[INITIAL+'knowledge-inputs.json.gz']))['current']
supplied={p:dict(sha256=sha(v),mode=modes[p]) for p,v in frozen.items()}
for path,item in scan.items():
    identity=dict(sha256=item['sha256'],mode=item['mode'])
    if path in supplied:assert supplied[path]==identity
    supplied[path]=identity
assert replay['inputs']==supplied and len(supplied)==replay['supplied_count']==2020
assert raw('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.6.json')==frozen['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.6.json']
additional=json.loads(raw(OBJECT+'additional-census.json'))
assert additional['result']=='PASS' and additional['producer_sha256']==sha(raw(OBJECT+'additional-census.py'))
assert additional['selected']==['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json']

# Every original committed production byte remains, except the declared factory/guard lines.
legacy_guard=b"if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'"
guard=b"if (defined($pkg) && !ref($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'"
for path in ('perl/LinkedSpec/ActionIR/FlowExpr.pm','perl/LinkedSpec/ActionIR/MethodLowering.pm'):
    assert old(path).count(legacy_guard)==1 and raw(path)==old(path).replace(legacy_guard,guard,1)
prefix=old(CONTROL).removesuffix(b'1;\n')
expected=prefix.replace(b'return LinkedSpec::OwnerDispatch::build_dep_map(',b'return _with_default_emission_selection($pkg, sub { return LinkedSpec::OwnerDispatch::build_dep_map(',1)
expected=expected.replace(b'\n )\n}\n',b'\n ) });\n}\n',1)
assert raw(CONTROL).startswith(expected) and expected.count(b'\n')==prefix.count(b'\n')
for path in (FACADE,VALUE):assert raw(path).startswith(old(path).removesuffix(b'1;\n'))
assert raw('perl/LinkedSpec/ActionIR/SourceEmissions.pm')==old('perl/LinkedSpec/ActionIR/SourceEmissions.pm')

def ordinary(value):
    if isinstance(value,dict):return {k:ordinary(v) for k,v in value.items() if k!='authority'}
    if isinstance(value,list):return [ordinary(v) for v in value]
    return value
native_record=load('after-native.json')
capsule('after-native-inputs.json.gz',native_record)
native=packed('after-native-data.json.gz')
before=json.loads(gzip.decompress(frozen[INITIAL+'before-native-data.json.gz']))
assert native_record['producer_sha256']==sha(raw(PREFIX+'observe-after.py'))
assert native_record['data_sha256']==sha(raw(PREFIX+'after-native-data.json.gz'))
assert native_record['warm_raw_recurrence']==(native[1]==native[2]) and native_record['cold_raw_recurrence']==(native[3]==native[4])
for first,second in ((1,2),(3,4)):
    observed=native[first]['observation']
    assert ordinary(observed)==ordinary(before[first]['observation']), 'complete native ordinary ledger'
    assert ordinary(observed)==ordinary(native[second]['observation'])
    left,right=copy.deepcopy(observed),copy.deepcopy(native[second]['observation'])
    for value in (left,right):
        for row in value['rows']:row['authority']['registrations'].sort()
    assert left==right and len(observed['rows'])==26
    assert observed['source_emissions_loaded']==int(first==1) and observed['trace_loaded']==0
for i in range(1,5):
    assert native[i]['returncode']==0 and not decode(native[i]['stderr_base64'])
    assert json.loads(decode(native[i]['stdout_base64']))==native[i]['observation']
    observed=native[i]['observation'];warm=i<3
    assert len({(r['label'],r['context']) for r in observed['rows']})==26
    for row in observed['rows']:
        authority=row['authority'];state=int(warm and row['label']!='outside')
        assert set(authority)=={'values','registrations','native_selected'}
        assert len(authority['values'])==len(row['values']), 'complete selection observation population'
        assert authority['native_selected']==[state]*8
        attempts=[]
        for index in range(len(row['values'])):
            callbacks=row['values'][index].get('callbacks',[])
            expected=[dict(key=v['key'],selected=int(bool(state and v['actual_native']))) for v in callbacks]
            assert authority['values'][index]==expected, 'actual native callback selection'
            if state:
                attempts.extend(v['identity'] for v in callbacks if v['actual_native'] and (v['key']=='extract_array_symbol_name' or row['target']=='LinkedSpec::RuleIR::EmitContext'))
        assert sorted(authority['registrations'])==sorted(attempts), 'observed in-scope provider registration attempts'

for stage,count in (('before',53),('after',0)):
    record=load('complete-'+stage+'.json')
    capsule('complete-'+stage+'-inputs.json.gz',record,stage=='before')
    channels=packed('complete-'+stage+'-channels.json.gz')
    assert record['producer_sha256']==sha(raw(PREFIX+'run-mixed.py'))
    assert record['channels_sha256']==sha(raw(PREFIX+'complete-'+stage+'-channels.json.gz'))
    assert record['assertions']==record['plan']==445 and len(record['failures'])==count
    assert tap(channels[1],445)==record['failures'] and bool(channels[1]['returncode'])==bool(count)
faults=load('faults.json');variants=packed('faults-data.json.gz')
assert faults['result']=='PASS' and faults['producer_sha256']==sha(raw(PREFIX+'faults.py'))
assert faults['data_sha256']==sha(raw(PREFIX+'faults-data.json.gz'))
assert [len(r['failures']) for r in variants]==[53,31,14,1,17,35,5,14,2,153,67,21,45,4,44,6,1,55]
for row in variants:
    assert row['unchanged'] and all(v['returncode']==0 for v in row['channels'][:-1])
    assert row['channels'][-1]['returncode']!=0 and tap(row['channels'][-1],445)==row['failures']
    assert all(sha(decode(v['bytes_base64']))==v['sha256'] for v in row['sources'].values())
assert variants[0]['failures']==load('complete-before.json')['failures']

for stage in ('before','after'):
    record=load(stage+'-diagnostics.json');files=packed(stage+'-diagnostics-inputs.json.gz');channels=packed(stage+'-diagnostics-channels.json.gz')
    assert record['producer_sha256']==sha(raw(PREFIX+'diagnostics.py'))
    assert record['inputs_sha256']==sha(raw(PREFIX+stage+'-diagnostics-inputs.json.gz')) and len(files)==358
    assert record['channels_sha256']==sha(raw(PREFIX+stage+'-diagnostics-channels.json.gz'))
    assert record['returncode']==channels['returncode']==0 and not decode(channels['stderr_base64'])
    assert b'Files=1, Tests=16' in decode(channels['stdout_base64'])
    for path,item in files.items():
        value=decode(item['bytes_base64']);assert sha(value)==item['sha256']
        assert value==(old(path) if stage=='before' and path in OWNERS else raw(path))

knowledge=load('knowledge-final.json');data=packed('knowledge-final-inputs.json.gz')
assert knowledge['returncode']==0 and knowledge['markdown']==1486 and len(knowledge['changed_cards'])==13
assert knowledge['producer_sha256']==sha(raw(PREFIX+'knowledge-final.py')) and knowledge['capsule_sha256']==sha(raw(PREFIX+'knowledge-final-inputs.json.gz'))
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    originals={x.name:dict(bytes_base64=base64.b64encode(stream.extractfile(x).read()).decode(),mode=x.mode) for x in stream if x.isfile() and x.name.endswith('.md')}
assert data['original']==originals
paths=sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge','docs/decisions') for p in (ROOT/d).rglob('*.md') if p.is_file())
assert paths==sorted(originals)
for path,item in data['current'].items():
    assert sha(decode(item['bytes_base64']))==item['sha256']==sha((ROOT/path).read_bytes())
    if path not in originals or path in knowledge['changed_cards']:raw(path)
assert knowledge['changed_cards']==sorted(p for p in paths if data['current'][p]['bytes_base64']!=originals[p]['bytes_base64'])
bodies={'docs/knowledge/'+x+'.md' for x in ('perl-factory-capture-framework','perl-emitcontext-callback-capture','perl-method-default-capture','project-root-evidence-filesystem-modes')}
for path in knowledge['changed_cards']:
    if path not in bodies:assert decode(data['current'][path]['bytes_base64']).split(b'\n---\n',1)[1]==decode(originals[path]['bytes_base64']).split(b'\n---\n',1)[1]
assert sum(bool(re.search(rb'^id:\s+\S+',decode(data['current'][p]['bytes_base64']).split(b'\n---\n',1)[0],re.M)) for p in paths)==1349
knowledge_bytes=sum((ROOT/p).stat().st_size for p in paths if p.startswith('docs/knowledge/'))
assert knowledge_bytes==8388255<=8388608

for path in (OBJECT+'review.py',PREFIX+'consumer-review.py',PREFIX+'book-review.py',PREFIX+'public-validation.py'):
    result=subprocess.run(['python3',path],cwd=ROOT,capture_output=True)
    assert result.returncode==0 and not result.stderr, ('readonly component',path,result.stderr)
    raw(path)
for path in (OBJECT+'review.json',PREFIX+'consumer-review.json'):
    for source,identity in json.loads(raw(path))['inputs'].items():assert sha(raw(source))==identity
book=load('book-review.json')
assert book['source_count']==89 and book['actual_controls']==4
for path,identity in (book['source_inputs']|book['oracle_inputs']).items():assert sha(raw(path))==identity
for path,identity in load('public-validation.json')['sources'].items():assert sha(raw(path))==identity
compat=load('compat.json')
assert compat['result']=='PASS' and len(compat['rows'])==8 and all(r['returncode']==0 for r in compat['rows'])
assert compat['producer_sha256']==sha(raw(PREFIX+'compat.py'))
assert b'Files=1, Tests=1035' in decode(compat['rows'][-1]['stdout_base64']) and b'Result: PASS' in decode(compat['rows'][-1]['stdout_base64'])
EVIDENCE_FILES=['after-diagnostics-channels.json.gz', 'after-diagnostics-inputs.json.gz', 'after-diagnostics.json', 'after-native-data.json.gz', 'after-native-inputs.json.gz', 'after-native.json', 'before-diagnostics-channels.json.gz', 'before-diagnostics-inputs.json.gz', 'before-diagnostics.json', 'book-review.json', 'book-review.py', 'book.json', 'book.py', 'compat.json', 'compat.py', 'complete-after-channels.json.gz', 'complete-after-inputs.json.gz', 'complete-after.json', 'complete-before-channels.json.gz', 'complete-before-inputs.json.gz', 'complete-before.json', 'consumer-review.json', 'consumer-review.py', 'consumers-channels.json.gz', 'consumers-inputs.json.gz', 'consumers.json', 'consumers.py', 'diagnostics.py', 'faults-data.json.gz', 'faults-reached.json.gz', 'faults.json', 'faults.py', 'knowledge-inputs.json.gz', 'knowledge-preparation.json', 'knowledge.json', 'knowledge.py', 'observe-after.py', 'preparation-run.json', 'prepare-knowledge-over-budget.py', 'prepare-knowledge-run.py', 'prepare-knowledge.py', 'public-validation.json', 'public-validation.py', 'run-mixed.py']
EVIDENCE_FILES += ['knowledge-final.py','knowledge-final.json','knowledge-final-inputs.json.gz','correct-knowledge-chronology.py','knowledge-chronology.json']
for name in EVIDENCE_FILES:raw(PREFIX+name)
for name in ('preserve-initial.py','baseline.json','initial-claim.json','preservation.json','initial-inputs.tar.gz','additional-census.py','additional-census.json','replay-initial.py','replay.json'):
    raw(OBJECT+name)
raw(PREFIX+'review.py')
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'review.py')),
    population=dict(mixed_assertions=445,mixed_red=53,mixed_controls=392,mixed_faults=18,
        object_assertions=444,object_red=100,object_controls=344,object_faults=10,
        mixed_warm_rows=26,mixed_cold_rows=26,object_warm_rows=108,object_cold_rows=108,
        consumer_suites=91,consumer_inputs=363,consumer_assertions=30394,diagnostic_inputs=358,
        diagnostic_assertions=16,knowledge_bytes=knowledge_bytes,book_sources=89,book_controls=4,
        initial_bindings=546,initial_claim_bytes=127929,initial_replay_inputs=2020),
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Corrected five-owner private default selection and native target effects. Complete initial uncommitted publication/data/producers remain byte/mode frozen and actually replayed; no fake revision. Original mixed445/53 and object444/100 pairs have full current-source GREEN, independent builder/native ledgers and28 effective source variants. Complete consumers, diagnostics, Knowledge/book and supplemental guards/standard commands pass. Current shape/card/factory behavior does not imply fixture/pipeline/private/parent/canonical admission. System tools are read-only dependencies without immutable toolchain claims.')
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Corrected default review PASS:',len(inputs),'inputs;445/53 and444/100;28 source faults;91 supplied suites')

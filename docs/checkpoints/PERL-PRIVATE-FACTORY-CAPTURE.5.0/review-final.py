"""Readonly evidence review of native ControlFlow foundation callback boundaries."""
import base64, copy, gzip, hashlib, io, json, re, subprocess, sys, tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='aa88233432976a019b41d05578f8e6a5f6e3c082'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.0/'
MODULE='perl/LinkedSpec/ActionIR/ControlFlow.pm'
FIXTURE='t/actionir_control_foundation_capture.t'
INSTRUMENT='t/actionir_control_foundation_native.pl'
sha=lambda b:hashlib.sha256(b).hexdigest()
raw=lambda p:(ROOT/p).read_bytes()
load=lambda n:json.loads(raw(PREFIX+n))
packed=lambda n:json.loads(gzip.decompress(raw(PREFIX+n)))
old=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
assert sys.argv[1:] in ([],['--capture'],['--preflight'],['--inventory'])
preflight=sys.argv[1:] in (['--preflight'],['--inventory'])

def command(script):
    p=subprocess.run(['bash','tools/run_python_project_data.sh',PREFIX+script],cwd=ROOT,capture_output=True)
    assert p.returncode==0 and not p.stderr, ('readonly component rejection',script,p.stdout.decode(errors='replace'),p.stderr.decode(errors='replace'))
    return {'script':script,'returncode':p.returncode,'stdout_base64':base64.b64encode(p.stdout).decode()}

def capsule(name,record=None,live=True):
    value=packed(name)
    for path,item in value.items():
        payload=base64.b64decode(item['bytes_base64'],validate=True)
        assert sha(payload)==item['sha256'], ('capsule byte hash',name,path)
        if live and path!=MODULE:
            assert raw(path)==payload and (ROOT/path).stat().st_mode&0o7777==item['mode'], ('actual complete runtime input',name,path)
    if record:
        assert record['inputs']=={p:{'sha256':x['sha256'],'mode':x['mode']} for p,x in value.items()}
        assert record['capsule_sha256']==sha(raw(PREFIX+name))
    return value

def tap(ch,plan):
    text=base64.b64decode(ch['stdout_base64'],validate=True).decode()
    rows=re.findall(r'^(not )?ok (\d+) - (.*)$',text,re.M)
    assert re.findall(r'^1\.\.(\d+)$',text,re.M)==[str(plan)]
    assert len(rows)==plan and [int(n) for _,n,_ in rows]==list(range(1,plan+1))
    assert not re.search(r'^Bail out!',text,re.M)
    return [{'number':int(n),'name':title} for bad,n,title in rows if bad]

# The original Git namespace, full publication and every original binding are
# checked before trusting later explanatory records or durability headers.
preservation=load('preservation.json')
assert preservation['base']==BASE and preservation['result']=='PASS'
assert preservation['producer_sha256']==sha(raw(PREFIX+'preserve.py'))
claim_paths=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
census=[];selected=[]
owned=set(preservation['owned_bound_paths'])
for path in sorted(claim_paths):
    original=old(path);record=json.loads(original);hits=[]
    for index,claim in enumerate(record['claims']):
        d=claim['durability']
        if d.get('mode')!='live':continue
        intersection=sorted(owned & {x['path'] for x in d['inputs']})
        if intersection:
            for x in d['inputs']:
                assert sha(old(x['path']))==x['sha256'], ('original accepted Git input custody',x['path'])
            hits.append({'claim_index':index,'paths':intersection,'bindings':len(d['inputs'])})
    census.append({'path':path,'sha256':sha(original),'intersections':hits})
    if hits:selected.append((path,original,hits))
assert census==preservation['census'] and len(selected)==1
prior_path,prior_raw,hits=selected[0]
assert prior_path=='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.1.json'
prior=preservation['selected'][0]
assert raw(prior['before'])==prior_raw, 'whole accepted publication custody'
assert prior['sha256']==sha(prior_raw) and prior['bytes']==len(prior_raw)==106177
assert sum(x['bindings'] for x in hits)==449
historical=json.loads(prior_raw)
for hit in hits:
    historical['claims'][hit['claim_index']]['durability'].update(mode='historical',revision=BASE)
assert json.loads(raw(prior_path))==historical, 'historical mode/revision only'
baseline=load('baseline.json')
assert baseline['returncode']==0 and not base64.b64decode(baseline['stderr_base64'])
assert base64.b64decode(baseline['stdout_base64'])==b'FlowExpr defaults publication PASS: 449 live inputs; 106177 bytes\n'
assert sha(raw(PREFIX+'baseline.json'))==preservation['baseline_sha256']

components=[command('book-review.py')]
parent_paths=set(subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','perl'],cwd=ROOT,text=True).splitlines())
original_source=old(MODULE);source=raw(MODULE)
helper_marker=b'# Forward original argument aliases and native context without eager loading.\n'
helper_start=source.index(helper_marker)
helpers=('_lower_control_flow_value_expr','_lower_switch_case_value_expr','_normalize_bare_zero_arg_flow_marker_expr')
expected=original_source
for name in helpers:
    start=expected.index(('sub '+name+' {\n').encode());end=expected.index(b'\nsub ',start+1)
    part=expected[start:end];assert part.count(b'return $cb;')==1
    expected=expected[:start]+part.replace(b'return $cb;',b'return _bind_emission_dependency($cb);',1)+expected[end:]
assert source[:helper_start]==expected[:-len(b'1;\n')], 'only three original validator returns change'
assert source[helper_start:].endswith(b'\n1;\n')
assert source.count(b'return _bind_emission_dependency($cb);')==3
assert source.count(b'return $cb;')==original_source.count(b'return $cb;')-3==19
required={}
for name in helpers:
    start=original_source.index(('sub '+name+' {\n').encode());end=original_source.index(b'\nsub ',start+1)
    required[name]=re.findall(rb"\$require_dep->\('([a-z_]+)'\)",original_source[start:end])
assert [len(x) for x in required.values()]==[3,3,1], 'exact native required role population'
assert b"return {mode => 'eq', expr => $normalize_method_tag_expr->($trimmed)}" in original_source

# Recover every original/current native source and raw command channel. The
# first instrument predates behavioral assertions and source edits.
native_epochs={}
for stage,producer in [('before','observe.py'),('after','observe-after.py')]:
    record=load(stage+'-native.json');cap=capsule(stage+'-native-inputs.json.gz',record)
    expected_paths=parent_paths|{INSTRUMENT,PREFIX+producer,'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh','.knowledge_map.conf'}
    assert set(cap)==expected_paths and len(cap)==100, 'complete native runtime namespace'
    assert base64.b64decode(cap[MODULE]['bytes_base64'])==(original_source if stage=='before' else source)
    assert record['producer_sha256']==sha(raw(PREFIX+producer)) and record['instrument_sha256']==sha(raw(INSTRUMENT))
    data=packed(stage+'-native-data.json.gz');assert record['data_sha256']==sha(raw(PREFIX+stage+'-native-data.json.gz'))
    assert len(data)==5 and all(x['returncode']==0 for x in data)
    assert base64.b64decode(data[0]['stderr_base64'])==(INSTRUMENT+' syntax OK\n').encode()
    assert not base64.b64decode(data[0]['stdout_base64'])
    for index in range(1,5):
        assert not base64.b64decode(data[index]['stderr_base64'])
        assert json.loads(base64.b64decode(data[index]['stdout_base64']))==data[index]['observation']
        obs=data[index]['observation'];assert set(obs['loaded_project_modules'])<=set(cap)
        assert obs['trace_loaded']==0 and obs['emission_loaded']==(1 if index<3 else 0)
        labels=[r['label'] for r in obs['rows']];assert len(set(labels))==len(labels)==(176 if index<3 else 132)
        for row in obs['rows']:
            for call in row['native']['calls']:
                assert call['context']==('list' if call['key']=='normalize_method_tag_expr' else 'scalar'), 'native tag list context'
    assert data[1]==data[2] and data[3]==data[4], 'exact actual fresh-process native recurrence'
    native_epochs[stage]=(record,cap,data)
for index in (1,3):
    before_rows=native_epochs['before'][2][index]['observation']['rows']
    after_rows=native_epochs['after'][2][index]['observation']['rows']
    assert [r['native'] for r in before_rows]==[r['native'] for r in after_rows], 'every original ordinary native row'
    assert [r['label'] for r in before_rows]==[r['label'] for r in after_rows]
    if index==1:
        for row in after_rows:
            options=row['options'];contexts={(c['key'],c['number']):c['context'] for c in row['native']['calls']}
            expected_calls=[{'key':c['key'],'number':c['number'],
                'actual_callback':1 if contexts[c['key'],c['number']]=='scalar' else 0,
                'eligible':1 if contexts[c['key'],c['number']]=='scalar' and options.get('known') and c['key']==options.get('key') else 0}
                for c in row['authority']['calls']]
            assert row['authority']['calls']==expected_calls, 'actual scalar identity/list disabled authority'
            assert row['authority']['parent_packet']==0, 'no enclosing packet donation'
            assert row['authority']['child_packets']==(1 if row['label']=='retained-child/1' else 0), 'only own scalar matching child packet'

pairs={}
for stage in ('before','after'):
    rec=load(stage+'.json');cap=capsule(stage+'-inputs.json.gz',rec);ch=packed(stage+'-channels.json.gz')
    assert set(cap)==set(native_epochs['before'][1])|{FIXTURE,PREFIX+'run.py',PREFIX+'before-native.json',PREFIX+'before-native-data.json.gz',PREFIX+'before-native-inputs.json.gz'}
    assert len(cap)==105 and rec['producer_sha256']==sha(raw(PREFIX+'run.py'))
    assert base64.b64decode(cap[MODULE]['bytes_base64'])==(original_source if stage=='before' else source)
    assert rec['channels_sha256']==sha(raw(PREFIX+stage+'-channels.json.gz'))
    assert len(ch)==2 and ch[0]['returncode']==0 and base64.b64decode(ch[0]['stderr_base64'])==(FIXTURE+' syntax OK\n').encode()
    failures=tap(ch[1],848);assert failures==rec['failures'] and rec['plan']==rec['assertions']==848
    assert len(failures)==(198 if stage=='before' else 0) and (ch[1]['returncode']!=0)==bool(failures)
    assert rec['controls']==848-len(failures)
    if stage=='after':assert not base64.b64decode(ch[1]['stderr_base64'])
    pairs[stage]=(rec,cap,ch)
assert pairs['before'][1][FIXTURE]==pairs['after'][1][FIXTURE], 'same paired behavioral fixture bytes/mode'

# Reconstruct all complete syntax-valid source faults from the accepted original
# and current definitions; do not trust producer verdicts or shortened summaries.
start=source.index(b'sub _bind_emission_dependency {\n');end=source.index(b'\n1;',start);helper=source[start:end]
expected_faults={'inverse':original_source}
for name in helpers:
    a=source.index(('sub '+name+' {\n').encode());b=source.index(b'\nsub ',a+1)
    expected_faults['bypass-'+name]=source[:a]+source[a:b].replace(b'return _bind_emission_dependency($cb);',b'return $cb;',1)+source[b:]
def hf(name,value):expected_faults[name]=source[:start]+value+source[end:]
hf('opaque-wrapper-identity',helper.replace(b'_invoke_emission_dependency($callback, @_)',b'_invoke_emission_dependency(sub { return $callback->(@_) }, @_)',1))
hf('copied-argument-slots',helper.replace(b'return sub {\n',b'return sub {\n  my @args = @_;\n',1).replace(b'($callback, @_)',b'($callback, @args)').replace(b'$callback->(@_)',b'$callback->(@args)'))
hf('localized-error-effects',helper.replace(b'return sub {\n',b'return sub {\n  local $@;\n',1))
hf('twice-only-effects',helper.replace(b'return sub {\n',b'return sub {\n  $callback->(@_);\n',1))
hf('eager-emission-loading',helper.replace(b'return sub {\n',b'return sub {\n  require LinkedSpec::ActionIR::SourceEmissions;\n',1))
hf('forced-scalar-context',helper.replace(b'return LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)',b'return scalar LinkedSpec::ActionIR::SourceEmissions::_invoke_emission_dependency($callback, @_)',1))
expected_faults['delayed-map-selection']=source.replace(b'return _bind_emission_dependency($cb);',b'return sub { return _bind_emission_dependency($deps->{$name})->(@_) };')
expected_faults['public-map-rebinding']=source.replace(b'return _bind_emission_dependency($cb);',b'return $deps->{$name} = _bind_emission_dependency($cb);')
expected_faults['disabled-required-validation']=source.replace(b"unless ref($cb) eq 'CODE';",b'if 0;')
assert len(expected_faults)==13
faults=load('faults.json');rows=packed('faults-data.json.gz')
assert faults['producer_sha256']==sha(raw(PREFIX+'faults.py')) and faults['positive_capsule_sha256']==sha(raw(PREFIX+'after-inputs.json.gz'))
assert faults['data_sha256']==sha(raw(PREFIX+'faults-data.json.gz'))
assert packed('faults-data.json.gz')==packed('faults-reached.json.gz'), 'complete reached/final records, distinct exact gzip identities'
assert [x['name'] for x in rows]==list(expected_faults), 'complete declared source-fault population'
for row in rows:
    variant=base64.b64decode(row['module_base64'],validate=True)
    assert variant==expected_faults[row['name']] and row['module_sha256']==sha(variant), 'actual full semantic variant'
    ch=row['channels'];assert len(ch)==2 and ch[0]['returncode']==0 and row['unchanged'] is True
    failures=tap(ch[1],848);assert failures==row['failures'] and failures and ch[1]['returncode']!=0
    assert row['assertions']==848 and row['plan']==['848']
    if row['name']=='inverse':assert failures==pairs['before'][0]['failures'], 'exact inverse original198'
assert faults['variants']==[{'name':r['name'],'assertions':848,'failures':len(r['failures']),'module_sha256':r['module_sha256']} for r in rows]

seed_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/final-consumers.json'
seed_channels_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/final-consumers-channels.json.gz'
assert raw(seed_path)==old(seed_path) and raw(seed_channels_path)==old(seed_channels_path)
seed=json.loads(raw(seed_path));seed_channel=json.loads(gzip.decompress(raw(seed_channels_path)))
def suite_plans(channel,expected):
    text=base64.b64decode(channel['stdout_base64'],validate=True).decode()
    headers=list(re.finditer(r'^(\S+\.t) \.+\s*$',text,re.M))
    assert [h.group(1) for h in headers]==expected, 'complete accepted consumer command/header population'
    plans=[]
    for i,h in enumerate(headers):
        part=text[h.end():headers[i+1].start() if i+1<len(headers) else len(text)]
        p=re.findall(r'^1\.\.(\d+)$',part,re.M);m=re.findall(r'^(not )?ok (\d+)(?: - (.*))?$',part,re.M)
        assert len(p)==1 and int(p[0])==len(m) and [int(n) for _,n,_ in m]==list(range(1,len(m)+1))
        plans.append((h.group(1),len(m),[{'number':int(n),'name':title} for bad,n,title in m if bad]))
    return plans
seed_plans=suite_plans(seed_channel,seed['command'][3:]);assert sum(n for _,n,_ in seed_plans)==20634
consumer=load('consumers.json');cc=capsule('consumers-inputs.json.gz');channel=packed('consumers-channels.json.gz')
assert consumer['producer_sha256']==sha(raw(PREFIX+'consumers.py')) and consumer['capsule_sha256']==sha(raw(PREFIX+'consumers-inputs.json.gz'))
assert consumer['channels_sha256']==sha(raw(PREFIX+'consumers-channels.json.gz'))
assert consumer['inputs']=={p:x['sha256'] for p,x in cc.items()} and consumer['modes']=={p:x['mode'] for p,x in cc.items()}
expected_consumer_paths=set(seed['inputs'])|set(native_epochs['before'][1])|{FIXTURE,PREFIX+'before-native-data.json.gz',seed_path,seed_channels_path,PREFIX+'consumers.py'}
assert set(cc)==expected_consumer_paths and len(cc)==277, 'complete supplied consumer population'
assert consumer['command']==channel['command']==seed['command']+[FIXTURE]
assert consumer['unchanged'] and consumer['returncode']==channel['returncode']==0
assert base64.b64decode(cc[MODULE]['bytes_base64'])==source
for path,digest in seed['inputs'].items():
    if path!=MODULE:assert cc[path]['sha256']==digest, 'unchanged accepted seed input'
plans=suite_plans(channel,consumer['command'][3:]);assert plans[:-1]==seed_plans and plans[-1][1]==848 and not plans[-1][2]
assert len(plans)==80 and sum(n for _,n,_ in plans)==21482
assert channel['stderr_base64']==seed_channel['stderr_base64'] and b'Result: PASS' in base64.b64decode(channel['stdout_base64'])
# Complete dated Knowledge custody, nine live overlays and current derived map.
k=load('knowledge.json');kc=packed('knowledge-inputs.json.gz')
assert k['base']==BASE and k['producer_sha256']==sha(raw(PREFIX+'knowledge.py')) and k['capsule_sha256']==sha(raw(PREFIX+'knowledge-inputs.json.gz'))
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source:
    original={x.name:{'bytes_base64':base64.b64encode(source.extractfile(x).read()).decode(),'mode':x.mode} for x in source if x.isfile() and x.name.endswith('.md')}
assert original==kc['original'] and len(original)==1485, 'complete accepted original Knowledge body/header custody'
current=kc['current'];assert k['inputs']=={p:{'sha256':x['sha256'],'mode':x['mode']} for p,x in current.items()}
changed=[];facts=0;knowledge_bytes=0
for p,x in current.items():
    payload=base64.b64decode(x['bytes_base64'],validate=True);assert sha(payload)==x['sha256']
    if p in original:
        if payload!=base64.b64decode(original[p]['bytes_base64']):changed.append(p)
        if payload.startswith(b'---\n') and re.search(rb'^id: ',payload,re.M):facts+=1
        if p.startswith('docs/knowledge/'):knowledge_bytes+=len(payload)
    if p not in original or p in k['changed_cards']:assert raw(p)==payload and (ROOT/p).stat().st_mode&0o7777==x['mode']
assert sorted(changed)==k['changed_cards'] and len(changed)==9 and facts==1349
body_changes=[]
for p in changed:
    before=base64.b64decode(original[p]['bytes_base64']);after=base64.b64decode(current[p]['bytes_base64'])
    assert before.startswith(b'---\n') and after.startswith(b'---\n') and b'\n---\n' in before and b'\n---\n' in after
    assert (PREFIX+'publish.py').encode() in after.split(b'\n---\n',1)[0]
    if before.split(b'\n---\n',1)[1]!=after.split(b'\n---\n',1)[1]:body_changes.append(p)
assert sorted(body_changes)==['docs/knowledge/perl-factory-capture-framework.md']
assert knowledge_bytes<=8388608, 'unchanged Knowledge pressure limit'
assert k['returncode']==0 and not base64.b64decode(k['stdout_base64']) and base64.b64decode(k['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
book=load('book-review.json');assert book['source_count']==89 and book['actual_controls']==4
assert all(sha(raw(p))==v for p,v in book['source_inputs'].items())
assert raw('doctrine/readme_stability/routes.jsonl')==old('doctrine/readme_stability/routes.jsonl'), 'no pressure-policy change'

# The retired first reader's only adjudication correction is JSON envelope
# equivalence. Its executed source and exact actual failure remain retained.
first_reader=raw(PREFIX+'review.py')
failure=load('first-review-failure.json')
assert failure['original_reader_sha256']==sha(first_reader) and failure['outer_returncode']==1 and failure['outer_session']==76649
assert failure['faults_data_sha256']==sha(raw(PREFIX+'faults-data.json.gz')) and failure['faults_reached_sha256']==sha(raw(PREFIX+'faults-reached.json.gz'))
assert b'faults-data.json.gz' in base64.b64decode(failure['reported_merged_channel_base64'])

# The preflight and its supplied roots never read mutable compat.json. Standard
# proof is required for final admission; its completed bytes are bound separately
# by publication. This prevents an in-flight supplemental report entering a
# frozen artifact inventory.
inputs=set(parent_paths)|{FIXTURE,INSTRUMENT,prior_path,seed_path,seed_channels_path,'KNOWLEDGE_MAP.md','doctrine/readme_stability/routes.jsonl'}|set(changed)|set(book['source_inputs'])|set(consumer['inputs'])
inputs|={p for p in current if p not in original}
inputs|={p.relative_to(ROOT).as_posix() for p in (ROOT/PREFIX).iterdir() if p.is_file() and p.name not in ('review.json','review-final.json','compat.json') and not p.name.startswith(('evidence','publish'))}
assert all((ROOT/p).is_file() and not (ROOT/p).is_symlink() for p in inputs)
if sys.argv[1:]==['--inventory']:
    print(json.dumps(sorted(inputs)));raise SystemExit(0)
if preflight:
    print('ControlFlow foundation preflight PASS: original449/full106177; native100/176/132; three validators/seven roles;848/198 RED;13 faults;80/277/21482; Knowledge1485/1349/nine overlays; book89/four controls')
    raise SystemExit(0)
standard=load('compat.json');assert standard['result']=='PASS' and len(standard['rows'])==5
assert standard['producer_sha256']==sha(raw(PREFIX+'compat.py')) and all(r['returncode']==0 for r in standard['rows'])
assert b'Tests=1035' in base64.b64decode(standard['rows'][-1]['stdout_base64']) and b'Result: PASS' in base64.b64decode(standard['rows'][-1]['stdout_base64'])
components.append(command('validation.py'))
result={'result':'PASS','base':BASE,'producer_sha256':sha(raw(PREFIX+'review-final.py')),'inputs':{p:{'sha256':sha(raw(p)),'mode':(ROOT/p).stat().st_mode&0o7777} for p in sorted(inputs)},'components':components,'population':{'original_bindings':449,'original_publication_bytes':106177,'native_inputs':100,'warm_rows':176,'cold_rows':132,'required_validators':3,'required_roles':7,'paired_assertions':848,'original_red':198,'passing_controls':650,'source_faults':13,'consumer_suites':80,'consumer_inputs':277,'consumer_assertions':21482,'knowledge_markdown':1485,'knowledge_facts':1349,'live_card_overlays':9,'knowledge_bytes':knowledge_bytes,'book_inputs':89,'book_controls':4},'limits':'Original/current complete ordinary native rows and fresh-process recurrence are exact. Native switch tag normalization is list context with publication disabled; other selected calls are scalar with their own actual CODE identity. Knowledge is the complete dated supplied snapshot at BASE plus nine live overlays/map; no new card or pressure increase. Standard syntax/public Phase01035 and composed guard are supplemental without full transitive toolchain/input capsules. Later ControlFlow families/defaults, pipeline activation, output composition and independent helper/private/parent/canonical admissions remain open.'}
value=(json.dumps(result,indent=2)+'\n').encode();target=ROOT/(PREFIX+'review-final.json')
if sys.argv[1:]==['--capture']:
    with target.open('xb') as out:out.write(value)
else:assert target.read_bytes()==value, 'exact independent full review'
print('ControlFlow foundation independent review PASS: native308;848/198 RED/all GREEN;13 faults;80/277/21482 consumers; complete original publication, Knowledge and book custody')

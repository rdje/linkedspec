"""Readonly evidence review of native ControlFlow expansion callback boundaries."""
import base64, copy, gzip, hashlib, io, json, re, subprocess, sys, tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='9f9b47973f0d0be2ee5e048dd71a28f91e8016ed'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
MODULE='perl/LinkedSpec/ActionIR/ControlFlow.pm'
FIXTURE='t/actionir_control_expansion_capture.t'
INSTRUMENT='t/actionir_control_expansion_native.pl'
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
assert prior_path=='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.0.json'
prior=preservation['selected'][0]
assert raw(prior['before'])==prior_raw, 'whole accepted publication custody'
assert prior['sha256']==sha(prior_raw) and prior['bytes']==len(prior_raw)==100775
assert sum(x['bindings'] for x in hits)==428
historical=json.loads(prior_raw)
for hit in hits:
    historical['claims'][hit['claim_index']]['durability'].update(mode='historical',revision=BASE)
assert json.loads(raw(prior_path))==historical, 'historical mode/revision only'
baseline=load('baseline.json')
assert baseline['returncode']==0 and not base64.b64decode(baseline['stderr_base64'])
assert base64.b64decode(baseline['stdout_base64'])==b'ControlFlow foundation publication PASS: 428 live inputs; 100775 bytes\n'
assert sha(raw(PREFIX+'baseline.json'))==preservation['baseline_sha256']

components=[command('book-review-final.py')]
parent_paths=set(subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','perl'],cwd=ROOT,text=True).splitlines())
original_source=old(MODULE);source=raw(MODULE)
helper_marker=b'# Forward original argument aliases and native context without eager loading.\n'
helper_start=source.index(helper_marker)
helpers=('_expand_flow_branch_action_exprs',)
start=original_source.index(b'sub _expand_flow_branch_action_exprs {\n')
end=original_source.index(b'\nsub ',start+1)
part=original_source[start:end];assert part.count(b'return $cb;')==1
expected=original_source[:start]+part.replace(b'return $cb;',b'return _bind_emission_dependency($cb);',1)+original_source[end:]
assert source==expected, 'only one original expansion validator return changes'
assert source[helper_start:]==original_source[original_source.index(helper_marker):], 'existing private helper remains exact'
assert source.count(b'return _bind_emission_dependency($cb);')==4
assert source.count(b'return $cb;')==original_source.count(b'return $cb;')-1==18
required=re.findall(rb"\$require_dep->\('([a-z_]+)'\)",part)
assert required==[b'trim_action_ir_value',b'split_action_ir_statements'], 'exact native required role population'
assert b'$split_action_ir_statements->($+{body})' in part

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
        labels=[r['label'] for r in obs['rows']];assert len(set(labels))==len(labels)==(74 if index<3 else 60)
        for row in obs['rows']:
            for call in row['native']['calls']:
                assert call['context']=='scalar', 'native expansion callback contexts'
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
            assert row['authority']['calls']==expected_calls, 'actual scalar callback authority'
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
    failures=tap(ch[1],368);assert failures==rec['failures'] and rec['plan']==rec['assertions']==368
    assert len(failures)==(82 if stage=='before' else 0) and (ch[1]['returncode']!=0)==bool(failures)
    assert rec['controls']==368-len(failures)
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
a=source.index(b'sub _expand_flow_branch_action_exprs {\n');b=source.index(b'\nsub ',a+1);body=source[a:b]
expected_faults['delayed-map-selection']=source[:a]+body.replace(b'return _bind_emission_dependency($cb);',b'return sub { return _bind_emission_dependency($deps->{$name})->(@_) };')+source[b:]
expected_faults['public-map-rebinding']=source[:a]+body.replace(b'return _bind_emission_dependency($cb);',b'return $deps->{$name} = _bind_emission_dependency($cb);')+source[b:]
expected_faults['disabled-required-validation']=source[:a]+body.replace(b"unless ref($cb) eq 'CODE';",b'if 0;')+source[b:]
assert len(expected_faults)==10
faults=load('faults.json');rows=packed('faults-data.json.gz')
assert faults['producer_sha256']==sha(raw(PREFIX+'faults.py')) and faults['positive_capsule_sha256']==sha(raw(PREFIX+'after-inputs.json.gz'))
assert faults['data_sha256']==sha(raw(PREFIX+'faults-data.json.gz'))
assert packed('faults-data.json.gz')==packed('faults-reached.json.gz'), 'complete reached/final records, distinct exact gzip identities'
assert [x['name'] for x in rows]==list(expected_faults), 'complete declared source-fault population'
for row in rows:
    variant=base64.b64decode(row['module_base64'],validate=True)
    assert variant==expected_faults[row['name']] and row['module_sha256']==sha(variant), 'actual full semantic variant'
    ch=row['channels'];assert len(ch)==2 and ch[0]['returncode']==0 and row['unchanged'] is True
    failures=tap(ch[1],368);assert failures==row['failures'] and failures and ch[1]['returncode']!=0
    assert row['assertions']==368 and row['plan']==['368']
    if row['name']=='inverse':assert failures==pairs['before'][0]['failures'], 'exact inverse original82'
assert faults['variants']==[{'name':r['name'],'assertions':368,'failures':len(r['failures']),'module_sha256':r['module_sha256']} for r in rows]

seed_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.0/consumers.json'
seed_channels_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.0/consumers-channels.json.gz'
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
seed_plans=suite_plans(seed_channel,seed['command'][3:]);assert sum(n for _,n,_ in seed_plans)==21482
consumer=load('consumers.json');cc=capsule('consumers-inputs.json.gz');channel=packed('consumers-channels.json.gz')
assert consumer['producer_sha256']==sha(raw(PREFIX+'consumers.py')) and consumer['capsule_sha256']==sha(raw(PREFIX+'consumers-inputs.json.gz'))
assert consumer['channels_sha256']==sha(raw(PREFIX+'consumers-channels.json.gz'))
assert consumer['inputs']=={p:x['sha256'] for p,x in cc.items()} and consumer['modes']=={p:x['mode'] for p,x in cc.items()}
expected_consumer_paths=set(seed['inputs'])|set(native_epochs['before'][1])|{FIXTURE,PREFIX+'before-native-data.json.gz',seed_path,seed_channels_path,PREFIX+'consumers.py'}
assert set(cc)==expected_consumer_paths and len(cc)==284, 'complete supplied consumer population'
assert consumer['command']==channel['command']==seed['command']+[FIXTURE]
assert consumer['unchanged'] and consumer['returncode']==channel['returncode']==0
assert base64.b64decode(cc[MODULE]['bytes_base64'])==source
for path,digest in seed['inputs'].items():
    if path!=MODULE:assert cc[path]['sha256']==digest, 'unchanged accepted seed input'
plans=suite_plans(channel,consumer['command'][3:]);assert plans[:-1]==seed_plans and plans[-1][1]==368 and not plans[-1][2]
assert len(plans)==81 and sum(n for _,n,_ in plans)==21850
assert channel['stderr_base64']==seed_channel['stderr_base64'] and b'Result: PASS' in base64.b64decode(channel['stdout_base64'])
# Complete dated Knowledge custody, ten live overlays and current derived map.
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
assert sorted(changed)==k['changed_cards'] and len(changed)==10 and facts==1349
body_changes=[]
for p in changed:
    before=base64.b64decode(original[p]['bytes_base64']);after=base64.b64decode(current[p]['bytes_base64'])
    assert before.startswith(b'---\n') and after.startswith(b'---\n') and b'\n---\n' in before and b'\n---\n' in after
    assert (PREFIX+'publish.py').encode() in after.split(b'\n---\n',1)[0]
    if before.split(b'\n---\n',1)[1]!=after.split(b'\n---\n',1)[1]:body_changes.append(p)
assert sorted(body_changes)==['docs/knowledge/perl-factory-capture-framework.md','docs/knowledge/perl-match-alias-writability.md']
assert knowledge_bytes<=8388608, 'unchanged Knowledge pressure limit'
assert k['returncode']==0 and not base64.b64decode(k['stdout_base64']) and base64.b64decode(k['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
book=load('book-review-final.json');assert book['source_count']==89 and book['actual_controls']==4
assert all(sha(raw(p))==v for p,v in book['source_inputs'].items())
assert raw('doctrine/readme_stability/routes.jsonl')==old('doctrine/readme_stability/routes.jsonl'), 'no pressure-policy change'

# Reuse the original independent four-case oracle without replaying its writer.
ALIAS='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-match-alias'
alias_paths={ALIAS+'.py',ALIAS+'.json','t/perl_match_alias_writability_probe.pl'}
for p in alias_paths:assert raw(p)==old(p), 'accepted independent alias oracle custody'
alias=json.loads(raw(ALIAS+'.json'))
assert alias['producer_sha256']==sha(raw(ALIAS+'.py'))
assert alias['inputs']=={'t/perl_match_alias_writability_probe.pl':sha(raw('t/perl_match_alias_writability_probe.pl'))}
assert alias['command']==['perl','t/perl_match_alias_writability_probe.pl'] and alias['returncode']==0 and alias['unchanged']
assert not base64.b64decode(alias['stderr_base64'])
oracle=json.loads(base64.b64decode(alias['stdout_base64']))
assert oracle['perl_version']=='v5.34.1'
assert [r['name'] for r in oracle['rows']]==['lexical','literal','match','copied-match']
assert [r['readonly_flag'] for r in oracle['rows']]==[0,1,0,0]
assert [r['actual_slot'] for r in oracle['rows']]==[1,0,1,1]
for r in oracle['rows']:
    if r['name'] in ('literal','match'):
        assert 'Modification of a read-only value attempted' in r['error'] and 'after' not in r
    else:assert r['after']=='meta!' and r['result']=='completed' and 'error' not in r
label='effect/expand/split_action_ir_statements/mutate'
for stage in native_epochs:
    for index in (1,3):
        row=next(r for r in native_epochs[stage][2][index]['observation']['rows'] if r['label']==label)['native']
        assert row['calls'][-1]['first_readonly']==0
        assert row['fatal']=='Modification of a read-only value attempted at t/actionir_control_expansion_native.pl line 104.\n'
copy_fault=next(r for r in rows if r['name']=='copied-argument-slots')
assert {r['name'] for r in copy_fault['failures']}=={
 'warm/'+label+' preserves complete native arguments/context/maps/values/effects/errors',
 'cold/'+label+' preserves complete native arguments/context/maps/values/effects/errors'}, 'copied match argument loses actual write constraint'

# Preserve the complete first documentation candidate and its unchanged replay.
repair=load('repair01/capture.json');rc=packed('repair01/inputs.json.gz')
assert repair['producer_sha256']==sha(raw(PREFIX+'repair01/capture.py'))
assert repair['capsule_sha256']==sha(raw(PREFIX+'repair01/inputs.json.gz'))
assert repair['returncode']==0 and repair['unchanged'] and not base64.b64decode(repair['stderr_base64'])
assert repair['command']==['python3',PREFIX+'review.py','--preflight']
assert len(rc)==436 and repair['inputs']=={p:{'sha256':x['sha256'],'mode':x['mode']} for p,x in rc.items()}
for p,x in rc.items():assert sha(base64.b64decode(x['bytes_base64'],validate=True))==x['sha256']
first_evidence=json.loads(base64.b64decode(rc[PREFIX+'evidence.json']['bytes_base64']))
for p,x in first_evidence['inputs'].items():assert rc[p]['sha256']==x['sha256'] and rc[p]['mode']==x['mode']
assert base64.b64decode(rc[PREFIX+'review.py']['bytes_base64'])==raw(PREFIX+'review.py')
chapter='docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
first_chapter=base64.b64decode(rc[chapter]['bytes_base64'])
expected_chapter=first_chapter.replace(b'| Undefined, empty or whitespace input | Undefined |',b'| Undefined input, or undefined/empty trim result | Undefined |',1)
expected_chapter=expected_chapter.replace(b"Trim receives the helper's local scalar copy. The splitter receives the original\n",b"Whitespace handling belongs to the trim callback. The standard trim removes it;\nan injected identity trim keeps spaces as one plain-text element. Expansion itself\nchecks the callback's result for definedness and length.\n\nTrim receives the helper's local scalar copy. The splitter receives the original\n",1)
assert raw(chapter)==expected_chapter, 'only exact native trim-result wording correction'
for stage in native_epochs:
    row=next(r for r in native_epochs[stage][2][1]['observation']['rows'] if r['label']=='ordinary/whitespace_input/scalar')
    assert row['native']['result']['items']==['   '], 'native identity trim preserves whitespace'

# Keep the first successful full capture and its failed exact-repeat attempt.
repair2=load('repair02/capture.json');r2c=packed('repair02/inputs.json.gz')
assert repair2['producer_sha256']==sha(raw(PREFIX+'repair02/capture.py'))
assert repair2['capsule_sha256']==sha(raw(PREFIX+'repair02/inputs.json.gz'))
assert len(r2c)==445 and repair2['inputs']=={p:{'sha256':x['sha256'],'mode':x['mode']} for p,x in r2c.items()}
for p,x in r2c.items():assert sha(base64.b64decode(x['bytes_base64'],validate=True))==x['sha256']
assert repair2['returncode']==1 and repair2['unchanged']
assert b'FileNotFoundError' in base64.b64decode(repair2['stderr_base64'])
first_full=json.loads(base64.b64decode(r2c[PREFIX+'review-final.json']['bytes_base64']))
assert raw(PREFIX+'review-final.json')==base64.b64decode(r2c[PREFIX+'review-final.json']['bytes_base64'])
assert first_full['producer_sha256']==sha(raw(PREFIX+'review-final.py')) and first_full['result']=='PASS'
for p,x in first_full['inputs'].items():assert sha(raw(p))==x['sha256'] and (ROOT/p).stat().st_mode&0o7777==x['mode']
assert repair2['self_census_added']==[PREFIX+'review-final.json']
complete=load('repair02/replay-complete.json');r2complete=packed('repair02/replay-inputs.json.gz')
assert complete['producer_sha256']==sha(raw(PREFIX+'repair02/replay-complete.py'))
assert complete['capsule_sha256']==sha(raw(PREFIX+'repair02/replay-inputs.json.gz'))
assert complete['original_capsule_sha256']==sha(raw(PREFIX+'repair02/inputs.json.gz'))
assert complete['inputs']=={p:{'sha256':x['sha256'],'mode':x['mode']} for p,x in r2complete.items()} and len(r2complete)==450
for p,x in r2complete.items():assert sha(base64.b64decode(x['bytes_base64'],validate=True))==x['sha256']
assert all(r2complete[p]==x for p,x in r2c.items()), 'all first445 supplied bytes/modes exact'
assert complete['returncode']==1 and complete['unchanged']
assert b'AssertionError: exact independent full review' in base64.b64decode(complete['stderr_base64'])
validation=load('validation.json')
assert set(complete['added_supplemental_sources'])==set(validation['sources'])-set(r2c)
assert len(complete['added_supplemental_sources'])==4
for p,digest in validation['sources'].items():assert sha(raw(p))==digest==r2complete[p]['sha256']
outer=load('repair02/first-publication-failure.json')
assert outer['outer_session']==97918 and outer['outer_returncode']==1
assert outer['original_publisher_sha256']==r2c[PREFIX+'publish.py']['sha256']
assert b'AssertionError: exact independent full review' in base64.b64decode(outer['reported_merged_channel_base64'])

# The preflight and its supplied roots never read mutable compat.json. Standard
# proof is required for final admission; its completed bytes are bound separately
# by publication. This prevents an in-flight supplemental report entering a
# frozen artifact inventory.
inputs={PREFIX+'repair02/'+n for n in ('capture.py','capture.json','inputs.json.gz','replay-complete.py','replay-complete.json','replay-inputs.json.gz','first-publication-failure.json')}|set(validation['sources'])|{PREFIX+'review-final.json'}|{PREFIX+'repair01/'+n for n in ('capture.py','capture.json','inputs.json.gz')}|set(alias_paths)|set(parent_paths)|{FIXTURE,INSTRUMENT,prior_path,seed_path,seed_channels_path,'KNOWLEDGE_MAP.md','doctrine/readme_stability/routes.jsonl'}|set(changed)|set(book['source_inputs'])|set(consumer['inputs'])
inputs|={p for p in current if p not in original}
inputs|={p.relative_to(ROOT).as_posix() for p in (ROOT/PREFIX).iterdir() if p.is_file() and p.name not in ('review.json','review-accepted.json','compat.json') and not p.name.startswith(('evidence','publish'))}
assert all((ROOT/p).is_file() and not (ROOT/p).is_symlink() for p in inputs)
if sys.argv[1:]==['--inventory']:
    print(json.dumps(sorted(inputs)));raise SystemExit(0)
if preflight:
    print('ControlFlow expansion preflight PASS: original428/full100775; native100/74/60; one validator/two roles;368/82 RED;10 faults;81/284/21850; Knowledge1485/1349/ten overlays; book89/four controls')
    raise SystemExit(0)
standard=load('compat.json');assert standard['result']=='PASS' and len(standard['rows'])==5
assert standard['producer_sha256']==sha(raw(PREFIX+'compat.py')) and all(r['returncode']==0 for r in standard['rows'])
assert b'Tests=1035' in base64.b64decode(standard['rows'][-1]['stdout_base64']) and b'Result: PASS' in base64.b64decode(standard['rows'][-1]['stdout_base64'])
components.append(command('validation.py'))
result={'result':'PASS','base':BASE,'producer_sha256':sha(raw(PREFIX+'review-accepted.py')),'inputs':{p:{'sha256':sha(raw(p)),'mode':(ROOT/p).stat().st_mode&0o7777} for p in sorted(inputs)},'components':components,'population':{'original_bindings':428,'original_publication_bytes':100775,'native_inputs':100,'warm_rows':74,'cold_rows':60,'required_validators':1,'required_roles':2,'paired_assertions':368,'original_red':82,'passing_controls':286,'source_faults':10,'consumer_suites':81,'consumer_inputs':284,'consumer_assertions':21850,'knowledge_markdown':1485,'knowledge_facts':1349,'live_card_overlays':10,'knowledge_bytes':knowledge_bytes,'book_inputs':89,'book_controls':4},'limits':'Original/current complete ordinary native rows and fresh-process recurrence are exact. Both expansion callbacks stay scalar with their own actual CODE identity. The original independent four-case oracle and new full-source argument-copy fault distinguish native match-slot write rejection from its clear flag. Knowledge is the complete dated supplied snapshot at BASE plus ten live overlays/map; no new card or pressure increase. Standard syntax/public Phase01035 and composed guard are supplemental without full transitive toolchain/input capsules. Later ControlFlow families/defaults, pipeline activation, output composition and independent helper/private/parent/canonical admissions remain open.'}
value=(json.dumps(result,indent=2)+'\n').encode();target=ROOT/(PREFIX+'review-accepted.json')
if sys.argv[1:]==['--capture']:
    with target.open('xb') as out:out.write(value)
else:assert target.read_bytes()==value, 'exact independent full review'
print('ControlFlow expansion independent review PASS: native134;368/82 RED/all GREEN;10 faults;81/284/21850 consumers; complete original publication, Knowledge and book custody')

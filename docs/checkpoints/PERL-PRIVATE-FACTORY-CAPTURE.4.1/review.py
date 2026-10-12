"""Independent readonly admission of exact FlowExpr default-selection evidence."""
import base64, copy, gzip, hashlib, io, json, re, subprocess, sys, tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='98f8d5d7fabdc9b1ac074ca0d8f3c53d218c8ccb'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/'
FLOW='perl/LinkedSpec/ActionIR/FlowExpr.pm';EMIT='perl/LinkedSpec/RuleIR/EmitContext.pm';FIXTURE='t/actionir_flow_default_capture.t'
sha=lambda b:hashlib.sha256(b).hexdigest()
raw=lambda p:(ROOT/p).read_bytes()
load=lambda n:json.loads(raw(PREFIX+n))
packed=lambda n:json.loads(gzip.decompress(raw(PREFIX+n)))
old=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
assert sys.argv[1:] in ([],['--capture'],['--preflight'],['--inventory'])
preflight=sys.argv[1:]==['--preflight']

def command(script):
    p=subprocess.run(['bash','tools/run_python_project_data.sh',PREFIX+script],cwd=ROOT,capture_output=True)
    assert p.returncode==0 and not p.stderr, ('readonly component rejection',script,p.stdout.decode(errors='replace'),p.stderr.decode(errors='replace'))
    return {'script':script,'returncode':p.returncode,'stdout_base64':base64.b64encode(p.stdout).decode()}

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
assert prior_path=='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.2.json'
prior=preservation['selected'][0]
assert raw(prior['before'])==prior_raw, 'whole accepted publication custody'
assert prior['sha256']==sha(prior_raw) and prior['bytes']==len(prior_raw)==99413
assert sum(x['bindings'] for x in hits)==426
historical=json.loads(prior_raw)
for hit in hits:
    historical['claims'][hit['claim_index']]['durability'].update(mode='historical',revision=BASE)
assert json.loads(raw(prior_path))==historical, 'historical mode/revision only'
baseline=load('baseline.json')
assert baseline['returncode']==0 and not base64.b64decode(baseline['stderr_base64'])
assert base64.b64decode(baseline['stdout_base64'])==b'Optional FlowExpr publication PASS: 426 live inputs; 99413 bytes\n'
assert sha(raw(PREFIX+'baseline.json'))==preservation['baseline_sha256']

components=[command('native-review.py'),command('current-native-review.py'),command('book-review.py')]
native=packed('before-native-inputs.json.gz')
parent_paths={p for p in subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','perl'],cwd=ROOT,text=True).splitlines()}
expected_native=parent_paths|{'t/actionir_flow_default_native.pl',PREFIX+'observe.py','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh','.knowledge_map.conf'}
assert set(native)==expected_native and len(native)==100, 'complete original native namespace'
for p,i in native.items():
    assert sha(base64.b64decode(i['bytes_base64'],validate=True))==i['sha256']
    if p not in (FLOW,EMIT):assert sha(raw(p))==i['sha256'], ('unchanged native producer/instrument/input',p)

# The production footprint preserves every original line except the two factory
# delimiters; new private helpers are appended. The facade gains one separate set.
f=raw(FLOW);e=raw(EMIT);of=old(FLOW);oe=old(EMIT)
expected=of.replace(b' return LinkedSpec::OwnerDispatch::build_dep_map(\n',b' return _with_default_emission_selection($pkg, sub { return LinkedSpec::OwnerDispatch::build_dep_map(\n',1).replace(b' )\n',b' ) });\n',1)
marker=b'# Keep the public factory\'s native context and every actual returned reference.'
a=f.index(marker)
assert f[:a]==expected[:-len(b'1;\n')], 'only original factory delimiters change before appended helpers'
assert f[a:].endswith(b'\n1;\n')
keys=re.findall(rb"'([a-z_]+)'",of[of.index(b'sub default_deps_for_package'):of.index(b'# Function: _looks_like_array_value_expr')])
assert len(keys)==9
start=e.index(b'# FlowExpr has its own exact default population.')
end=e.index(b'\n1;\n',start)
section=e[start:end]
assert e[:start]+e[end+1:]==oe, 'only new facade catalogue/selector inserted'
assert re.findall(rb'^ \\&_([a-z_]+),$',section,re.M)==keys, 'exact definition-owned nine population'
assert section.count(b'_same_reference($callback, $builtin)')==1

# Reconstruct all three executed fixture identities; earlier sources and failed
# outcomes are retained, never relabeled as the accepted producer.
pairs={}
for name,producer,stage,plan in [('before','run.py','before',402),('after','run.py','after',403),('final-before','final-run.py','before',402),('final-after','final-run.py','after',402),('environment-before','environment-run.py','before',402),('environment-after','environment-run.py','after',402)]:
    record=load(name+'.json');capsule=packed(name+'-inputs.json.gz');channels=packed(name+'-channels.json.gz')
    assert record['producer_sha256']==sha(raw(PREFIX+producer))
    assert record['capsule_sha256']==sha(raw(PREFIX+name+'-inputs.json.gz'))
    assert record['channels_sha256']==sha(raw(PREFIX+name+'-channels.json.gz'))
    assert record['inputs']=={p:{'sha256':x['sha256'],'mode':x['mode']} for p,x in capsule.items()}
    expected_paths=set(native)|{FIXTURE,PREFIX+producer,PREFIX+'before-native.json',PREFIX+'before-native-data.json.gz',PREFIX+'before-native-inputs.json.gz'}
    assert set(capsule)==expected_paths, 'complete supplied pair population'
    for p,x in capsule.items():
        payload=base64.b64decode(x['bytes_base64'],validate=True);assert sha(payload)==x['sha256']
        if p in (FLOW,EMIT):assert payload==(old(p) if stage=='before' else raw(p)), ('actual paired production source',name,p)
        elif p!=FIXTURE:assert payload==raw(p), ('unchanged paired non-fixture input',name,p)
    assert len(channels)==2 and channels[0]['returncode']==0
    assert base64.b64decode(channels[0]['stderr_base64'])==(FIXTURE+' syntax OK\n').encode()
    text=base64.b64decode(channels[1]['stdout_base64'],validate=True).decode()
    rows=re.findall(r'^(not )?ok (\d+) - (.*)$',text,re.M);plans=re.findall(r'^1\.\.(\d+)$',text,re.M)
    failures=[{'number':int(n),'name':title} for bad,n,title in rows if bad]
    assert plans==[str(plan)] and len(rows)==plan and [int(n) for _,n,_ in rows]==list(range(1,plan+1))
    assert failures==record['failures'] and record['plan']==record['assertions']==plan
    assert record['controls']==plan-len(failures) and not re.search(r'^Bail out!',text,re.M)
    expected_failures=47 if stage=='before' else 9 if name=='after' else 0
    assert len(failures)==expected_failures and (channels[1]['returncode']!=0)==bool(failures), ('actual paired result',name)
    pairs[name]=(record,capsule,channels)
assert pairs['before'][0]['failures']==pairs['final-before'][0]['failures']==pairs['environment-before'][0]['failures'], 'identical original47 failure names/numbers'
first=base64.b64decode(pairs['before'][1][FIXTURE]['bytes_base64'])
second=base64.b64decode(pairs['final-before'][1][FIXTURE]['bytes_base64'])
corrected=first.replace(b'sort keys %LinkedSpec::RuleIR::EmitContext::;',b"sort grep {$_ ne '_register_builtin_flow_emission_callback'} keys %LinkedSpec::RuleIR::EmitContext::;",1).replace(b"scope(sub { producers(sub {\n defaults('LinkedSpec::RuleIR::EmitContext');\n $outer_scope",b"scope(sub { producers(sub {\n my $outer_defaults = defaults('LinkedSpec::RuleIR::EmitContext');\n $outer_scope",1).replace(b"   defaults('LinkedSpec::RuleIR::EmitContext');\n   die $fatal",b"   my $nested_defaults = defaults('LinkedSpec::RuleIR::EmitContext');\n   die $fatal",1)
assert second==corrected, 'exact two first-fixture repairs'
third=second.replace(b' my $error_pipe = gensym;',b" local $ENV{PERL5LIB} = '';\n local $ENV{PERL5OPT} = '';\n my $error_pipe = gensym;",1)
assert raw(FIXTURE)==third==base64.b64decode(pairs['environment-after'][1][FIXTURE]['bytes_base64']), 'exact child environment repair only'
for a,b in [('before','after'),('final-before','final-after'),('environment-before','environment-after')]:
    assert pairs[a][1][FIXTURE]==pairs[b][1][FIXTURE], 'identical fixture within each pair'

# Re-derive source faults independently from the actual current definitions.
expected_faults={'inverse':{FLOW:of,EMIT:oe}}
flow_section=e[e.index(b'my @builtin_flow_emission_callbacks = ('):end]
sa=e.index(b'my @builtin_flow_emission_callbacks = (')
for key in keys:
    expected_faults['missing-'+key.decode()]={FLOW:f,EMIT:e[:sa]+flow_section.replace(b' \\&_'+key+b',\n',b'',1)+e[end:]}
def ff(name,new):expected_faults[name]={FLOW:new,EMIT:e}
def ef(name,new):expected_faults[name]={FLOW:f,EMIT:e[:sa]+new+e[end:]}
ff('custom-target-authority',f.replace(b" if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'\n",b' if (1\n',1))
ef('copied-name-authority',flow_section.replace(b'LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin)',b'Sub::Util::subname($callback) eq Sub::Util::subname($builtin)',1))
for name,key in [('method-union','split_declare_symbol_names'),('contract-union','bare_symbol_kind')]:ef(name,flow_section.replace(b'\n);',b'\n \\&_'+key.encode()+b',\n);',1))
ff('copied-public-map',f.replace(b' return $deps\n',b' return { %$deps }\n',1))
ff('wrapped-public-callbacks',f.replace(b' return $deps\n',b' return {map {my $callback = $deps->{$_}; $_ => sub {$callback->(@_)}} keys %$deps}\n',1))
ff('scalar-list-build',f.replace(b'  my @deps = $build->();',b'  my @deps = scalar $build->();',1))
ff('scalar-void-build',f.replace(b'if (!defined wantarray) { $build->(); return }',b'if (!defined wantarray) { scalar $build->(); return }',1))
for name,extra in [('localized-error-effect',b' local $@;'),('twice-only-build',b' $build->();'),('eager-emission-loading',b' require LinkedSpec::ActionIR::SourceEmissions;')]:ff(name,f.replace(b' my ($pkg, $build) = @_;',b' my ($pkg, $build) = @_;'+extra,1))
ef('method-catalogue-borrow',flow_section.replace(b'for my $builtin (@builtin_flow_emission_callbacks)',b'for my $builtin (@builtin_method_emission_callbacks)',1))
assert len(expected_faults)==22
fault_epochs=[]
for prefix,producer,capsule_name in [('','faults.py','final-after-inputs.json.gz'),('environment-','environment-faults.py','environment-after-inputs.json.gz')]:
    record=load(prefix+'faults.json');rows=packed(prefix+'faults-data.json.gz')
    assert record['producer_sha256']==sha(raw(PREFIX+producer)) and record['capsule_sha256']==sha(raw(PREFIX+capsule_name))
    assert record['data_sha256']==sha(raw(PREFIX+prefix+'faults-data.json.gz'))
    assert raw(PREFIX+prefix+'faults-data.json.gz')==raw(PREFIX+prefix+'faults-reached.json.gz')
    assert [r['name'] for r in rows]==list(expected_faults), 'complete source-fault population'
    controls=[]
    for row in rows:
        sources={p:base64.b64decode(x['bytes_base64'],validate=True) for p,x in row['sources'].items()}
        assert sources==expected_faults[row['name']], ('actual complete semantic source',row['name'])
        assert all(sha(sources[p])==x['sha256'] for p,x in row['sources'].items())
        ch=row['channels'];assert len(ch)==3 and row['unchanged'] is True and all(x['returncode']==0 for x in ch[:2])
        text=base64.b64decode(ch[2]['stdout_base64'],validate=True).decode();matches=re.findall(r'^(not )?ok (\d+) - (.*)$',text,re.M)
        failures=[{'number':int(n),'name':title} for bad,n,title in matches if bad]
        assert len(matches)==402 and re.findall(r'^1\.\.(\d+)$',text,re.M)==['402']
        assert [int(n) for _,n,_ in matches]==list(range(1,403)) and failures==row['failures']
        assert ch[2]['returncode']!=0 and failures, 'observed effective source RED'
        if row['name']=='inverse':assert failures==pairs['before'][0]['failures'], 'exact inverse original47'
        controls.append({'name':row['name'],'failures':len(failures),'assertions':402})
    assert controls==record['controls'];fault_epochs.append(rows)
assert [r['failures'] for r in fault_epochs[0]]==[r['failures'] for r in fault_epochs[1]], 'environment correction changes no fault adjudication'

# Full supplied consumer commands, headers and ordered plans, including failed
# first diagnostics and the actual corrected final79/20634 result.
seed_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/consumers.json'
seed_channels_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/consumers-channels.json.gz'
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
seed_plans=suite_plans(seed_channel,seed['command'][3:]);assert sum(n for _,n,_ in seed_plans)==20232
consumer_records=[]
for prefix,producer,positive in [('','consumers.py','final-after'),('final-','final-consumers.py','environment-after')]:
    record=load(prefix+'consumers.json');caps=packed(prefix+'consumers-inputs.json.gz');ch=packed(prefix+'consumers-channels.json.gz')
    assert record['producer_sha256']==sha(raw(PREFIX+producer)) and record['capsule_sha256']==sha(raw(PREFIX+prefix+'consumers-inputs.json.gz'))
    assert record['channels_sha256']==sha(raw(PREFIX+prefix+'consumers-channels.json.gz'))
    assert record['inputs']=={p:x['sha256'] for p,x in caps.items()} and record['modes']=={p:x['mode'] for p,x in caps.items()}
    assert record['command']==ch['command']==seed['command']+[FIXTURE] and record['unchanged'] is True
    for p,x in caps.items():
        payload=base64.b64decode(x['bytes_base64'],validate=True);assert sha(payload)==x['sha256']
        expected=pairs[positive][1][FIXTURE]['bytes_base64'] if p==FIXTURE else None
        assert payload==(base64.b64decode(expected) if expected else raw(p)), ('consumer actual supplied input',p,prefix)
    assert set(seed['inputs'])<=set(caps) and len(caps)==270
    for p,digest in seed['inputs'].items():
        if p not in (FLOW,EMIT):assert caps[p]['sha256']==digest, ('unchanged fixed seed input',p)
    plans=suite_plans(ch,record['command'][3:]);assert plans[:-1]==seed_plans and sum(n for _,n,_ in plans)==20634
    failures=plans[-1][2]
    if not prefix:assert [x['number'] for x in failures]==[351,384] and record['returncode']==ch['returncode']==1
    else:
        assert not failures and record['returncode']==ch['returncode']==0 and b'Result: PASS' in base64.b64decode(ch['stdout_base64'])
        assert ch['stderr_base64']==seed_channel['stderr_base64'], 'complete accepted consumer stderr preserved'
    consumer_records.append(record)

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
assert sorted(body_changes)==['docs/knowledge/perl-emitcontext-callback-capture.md','docs/knowledge/perl-factory-capture-framework.md']
assert knowledge_bytes==8385408 and knowledge_bytes<=8388608, 'unchanged Knowledge pressure limit'
assert k['returncode']==0 and not base64.b64decode(k['stdout_base64']) and base64.b64decode(k['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
book=load('book-review.json');assert book['source_count']==89 and book['actual_controls']==4
assert all(sha(raw(p))==v for p,v in book['source_inputs'].items())
assert raw('doctrine/readme_stability/routes.jsonl')==old('doctrine/readme_stability/routes.jsonl'), 'no pressure-policy change'

if not preflight:
    standard=load('compat.json');assert standard['result']=='PASS' and len(standard['rows'])==5
    assert standard['producer_sha256']==sha(raw(PREFIX+'compat.py')) and all(r['returncode']==0 for r in standard['rows'])
    assert b'Tests=1035' in base64.b64decode(standard['rows'][-1]['stdout_base64']) and b'Result: PASS' in base64.b64decode(standard['rows'][-1]['stdout_base64'])
    components.append(command('validation.py'))
if preflight:
    print('FlowExpr default complete preflight PASS: original426/full99413; native100/27/27; three fixture identities; exact nine refs; paired402/47; 22 final faults;79/270/20634; Knowledge1485/1349/nine overlays; book89/four controls')
    raise SystemExit(0)

# Explicit inventory is stable after later evidence/publication creation. The
# large unchanged Knowledge population is recoverable in the capsule at BASE;
# only its nine live overlays and derived map are current live dependencies.
inputs=set(parent_paths)|{FIXTURE,'t/actionir_flow_default_native.pl',prior_path,seed_path,seed_channels_path,'KNOWLEDGE_MAP.md','doctrine/readme_stability/routes.jsonl'}|set(changed)|set(book['source_inputs'])|set(consumer_records[-1]['inputs'])
inputs|={p for p in current if p not in original}
inputs|={p.relative_to(ROOT).as_posix() for p in (ROOT/PREFIX).iterdir() if p.is_file() and p.name!='review.json' and not p.name.startswith(('evidence','publish'))}
inputs.discard(PREFIX+'knowledge-inputs.json.gz');inputs.add(PREFIX+'knowledge-inputs.json.gz')
assert all((ROOT/p).is_file() and not (ROOT/p).is_symlink() for p in inputs)
if sys.argv[1:]==['--inventory']:
    print(json.dumps(sorted(inputs)));raise SystemExit(0)
result={'result':'PASS','base':BASE,'producer_sha256':sha(raw(PREFIX+'review.py')),'inputs':{p:{'sha256':sha(raw(p)),'mode':(ROOT/p).stat().st_mode&0o7777} for p in sorted(inputs)},'components':components,'population':{'original_bindings':426,'original_publication_bytes':99413,'native_inputs':100,'warm_rows':27,'cold_rows':27,'default_callbacks':9,'paired_assertions':402,'original_red':47,'passing_controls':355,'final_source_faults':22,'consumer_suites':79,'consumer_inputs':270,'consumer_assertions':20634,'knowledge_markdown':1485,'knowledge_facts':1349,'live_card_overlays':9,'knowledge_bytes':knowledge_bytes,'book_inputs':89,'book_controls':4},'limits':'Native/current ordinary behavior and complete retained sources/contexts are checked; warm registration events are unordered and no raw ordered recurrence is claimed. Three fixture identities, two inventory/recurrence writer refusals and first79-suite failure remain original. Knowledge is the complete dated supplied snapshot at BASE plus nine live overlays/map. Standard syntax/public Phase01035 and composed public guard are supplemental without full transitive toolchain/input capsules. No automatic output composition, ControlFlow/pipeline, full helper/private/parent/canonical admission.'}
value=(json.dumps(result,indent=2)+'\n').encode();target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]==['--capture']:
    with target.open('xb') as out:out.write(value)
else:assert target.read_bytes()==value, 'exact independent full review'
print('FlowExpr defaults independent review PASS: exact nine callbacks;402/47 RED/all GREEN;22 faults;79/270/20634 consumers; complete original publication, Knowledge and book custody')

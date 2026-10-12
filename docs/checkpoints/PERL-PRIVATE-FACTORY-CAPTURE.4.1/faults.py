"""One-shot complete-source controls for exact FlowExpr default selection."""
import base64, gzip, hashlib, json, os, re, stat, subprocess, tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/'
FLOW='perl/LinkedSpec/ActionIR/FlowExpr.pm';EMIT='perl/LinkedSpec/RuleIR/EmitContext.pm';FIXTURE='t/actionir_flow_default_capture.t'
sha=lambda b:hashlib.sha256(b).hexdigest()
target=ROOT/(PREFIX+'faults.json');assert not target.exists()
packed=lambda n:json.loads(gzip.decompress((ROOT/(PREFIX+n)).read_bytes()))
c=packed('final-after-inputs.json.gz');old=packed('final-before-inputs.json.gz')
files={p:base64.b64decode(i['bytes_base64']) for p,i in c.items()};modes={p:i['mode'] for p,i in c.items()}
assert all(sha(files[p])==i['sha256'] and (ROOT/p).read_bytes()==files[p] for p,i in c.items())
f=files[FLOW];e=files[EMIT]
variants=[('inverse',{p:base64.b64decode(old[p]['bytes_base64']) for p in [FLOW,EMIT]})]
a=e.index(b'my @builtin_flow_emission_callbacks = (');b=e.index(b'\n1;',a);section=e[a:b]
keys=re.findall(rb'^ \\&_([a-z_]+),$',section,re.M);assert len(keys)==9
for key in keys:
    line=b' \\&_'+key+b',\n';assert section.count(line)==1
    variants.append(('missing-'+key.decode(),{EMIT:e[:a]+section.replace(line,b'',1)+e[b:]}))
def flow(name,source):
    assert source!=f;variants.append((name,{FLOW:source}))
def emit(name,source):
    assert source!=section;variants.append((name,{EMIT:e[:a]+source+e[b:]}))
flow('custom-target-authority',f.replace(b" if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'\n",b' if (1\n',1))
emit('copied-name-authority',section.replace(b'LinkedSpec::ActionIR::SourceEmissions::_same_reference($callback, $builtin)',b'Sub::Util::subname($callback) eq Sub::Util::subname($builtin)',1))
for label,key in [('method-union','split_declare_symbol_names'),('contract-union','bare_symbol_kind')]:
    emit(label,section.replace(b'\n);',b'\n \\&_'+key.encode()+b',\n);',1))
flow('copied-public-map',f.replace(b' return $deps\n',b' return { %$deps }\n',1))
flow('wrapped-public-callbacks',f.replace(b' return $deps\n',b' return {map {my $callback = $deps->{$_}; $_ => sub {$callback->(@_)}} keys %$deps}\n',1))
flow('scalar-list-build',f.replace(b'  my @deps = $build->();',b'  my @deps = scalar $build->();',1))
flow('scalar-void-build',f.replace(b'if (!defined wantarray) { $build->(); return }',b'if (!defined wantarray) { scalar $build->(); return }',1))
flow('localized-error-effect',f.replace(b' my ($pkg, $build) = @_;',b' my ($pkg, $build) = @_; local $@;',1))
flow('twice-only-build',f.replace(b' my ($pkg, $build) = @_;',b' my ($pkg, $build) = @_; $build->();',1))
flow('eager-emission-loading',f.replace(b' my ($pkg, $build) = @_;',b' my ($pkg, $build) = @_; require LinkedSpec::ActionIR::SourceEmissions;',1))
emit('method-catalogue-borrow',section.replace(b'for my $builtin (@builtin_flow_emission_callbacks)',b'for my $builtin (@builtin_method_emission_callbacks)',1))
assert len(variants)==22 and len({n for n,_ in variants})==22
rows=[];env=dict(os.environ,PERL5LIB='',PERL5OPT='');env.pop('LINKEDSPEC_TRACE_LEVEL',None)
for name,changed in variants:
    supplied_files=dict(files);supplied_files.update(changed)
    with tempfile.TemporaryDirectory(prefix='flow-default-fault-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory);assert root.stat().st_dev==ROOT.stat().st_dev
        for p,raw in supplied_files.items():
            dest=root/p;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(raw);dest.chmod(modes[p])
        channels=[]
        for command in [['perl','-c','-Iperl',FLOW],['perl','-c','-Iperl',EMIT],['perl','-Iperl',FIXTURE]]:
            process=subprocess.run(command,cwd=root,env=env,capture_output=True)
            channels.append({'command':command,'returncode':process.returncode,'stdout_base64':base64.b64encode(process.stdout).decode(),'stderr_base64':base64.b64encode(process.stderr).decode()})
        actual={p.relative_to(root).as_posix():sha(p.read_bytes()) for p in root.rglob('*') if p.is_file()}
        actual_modes={p:stat.S_IMODE((root/p).stat().st_mode) for p in actual}
    text=base64.b64decode(channels[-1]['stdout_base64']).decode()
    matches=re.findall(r'^(not )?ok (\d+) - (.*)$',text,re.M);plans=re.findall(r'^1\.\.(\d+)$',text,re.M)
    failures=[{'number':int(n),'name':title} for bad,n,title in matches if bad]
    row={'name':name,'sources':{p:{'sha256':sha(supplied_files[p]),'bytes_base64':base64.b64encode(supplied_files[p]).decode()} for p in [FLOW,EMIT]},'channels':channels,'assertions':len(matches),'plan':plans,'failures':failures,'unchanged':actual=={p:sha(raw) for p,raw in supplied_files.items()} and actual_modes==modes}
    rows.append(row);(ROOT/(PREFIX+'faults-reached.json.gz')).write_bytes(gzip.compress(json.dumps(rows,sort_keys=True).encode(),mtime=0))
    assert row['unchanged'] and all(x['returncode']==0 for x in channels[:2]),('valid complete-source fault',name)
    assert channels[-1]['returncode']!=0 and failures and plans==['402'] and len(matches)==402,('complete semantic RED',name)
    if name=='inverse':
        original=json.loads((ROOT/(PREFIX+'before.json')).read_bytes())
        final=json.loads((ROOT/(PREFIX+'final-before.json')).read_bytes())
        assert failures==original['failures']==final['failures']
data_path=ROOT/(PREFIX+'faults-data.json.gz');data_path.write_bytes(gzip.compress(json.dumps(rows,sort_keys=True).encode(),mtime=0))
result={'result':'PASS','producer_sha256':sha(Path(__file__).read_bytes()),'capsule_sha256':sha((ROOT/(PREFIX+'final-after-inputs.json.gz')).read_bytes()),'data_sha256':sha(data_path.read_bytes()),'controls':[{'name':r['name'],'failures':len(r['failures']),'assertions':r['assertions']} for r in rows],'scope':'Twenty-two full two-module source variants, complete unchanged supplied input bytes/modes and separate raw syntax/TAP channels. Every semantic control reaches all402 assertions; full inverse reproduces original47 failure names/numbers. Live production remains unchanged; no private/parent/canonical admission.'}
with target.open('x') as out:out.write(json.dumps(result,indent=2)+'\n')
print('FlowExpr defaults source controls PASS:',len(rows),'full variants; inverse47; complete402 TAP each')

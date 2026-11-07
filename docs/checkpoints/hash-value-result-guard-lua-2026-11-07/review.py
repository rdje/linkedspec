"""Readonly finite Lua Hash-result proof with actual pre-use native products."""
import copy,difflib,gzip,hashlib,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/hash-value-result-guard-lua-2026-11-07')
ACTIVATION='015b076112bb7c9c44e03f8425969def5bcad676'
OWNER='lua/src/linkedspec/interpreter.lua';RUNNER='lua/test/run.lua'
NORMAL='lua/test/hash_value_result_guard_composition_test.lua'
COMMON='tests/fixtures/hash_value_result_guard_cases.json';FIXTURE='tests/fixtures/hash_value_result_guard_lua_cases.json'
PROFILE='tests/fixtures/hash_value_result_guard_lua_profiles.json';GRAMMAR='specs/user_function_definition.spec'
HOSTS=('puc','luajit');PHASES=('intake','before','after','direct','inverse','restored')
RED={helper+'_'+form+'_array_guard' for helper in ('merge_hash','set_key','rename_key','drop_keys','pick_keys') for form in ('free','receiver')}
RED|={'merge_later_with','set_copy_later_with','rename_logical_later_with'}

def digest(body):return hashlib.sha256(body).hexdigest()
def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
    if type(a) is not type(b):return False
    if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b

def raw(phase,host,tag='normal',channel='stdout'):
    return gzip.decompress((ROOT/BASE/phase/host/(tag+'-'+channel+'.log.gz')).read_bytes())
def frames(body,tag='HASH_VALUE_LUA_NORMAL'):
    out={}
    for line in body.decode().splitlines():
        if line.startswith(tag+' '):
            _,key,value=line.split(' ',2);assert key not in out;out[key]=json.loads(value)
    return out

def recover(directory,stem='input'):
    names={'input':'inputs-before-first-run.tar.gz','artifact':'actual-emitted-parsed.tar.gz','native':'native-before-first-run.tar.gz'}
    expected=json.loads((ROOT/BASE/directory/(stem+'-identities.json')).read_bytes());out={}
    with tarfile.open(ROOT/BASE/directory/names[stem]) as archive:
        for member in archive:
            path=PurePosixPath(member.name);assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in out
            body=archive.extractfile(member).read();row=expected[member.name]
            assert len(body)==row['bytes'] and digest(body)==row['sha256'] and member.mode&0o777==row['mode']
            out[member.name]=body
    assert out.keys()==expected.keys();return out

def validate(rows,cases,profiles,before=False):
    assert list(rows)==[r['id'] for r in cases]
    for case in cases:
        key=case['id'];actual=rows[key];assert set(actual)=={'native','restored','plan','fresh'}
        for route,value in actual.items():
            if before and key in RED:
                expected=[[],'A'] if key.endswith('_array_guard') else ['ran','ADW' if key=='rename_logical_later_with' else 'AW']
                assert same(value,{'value':expected})
            elif key in profiles:
                assert profiles[key]['source']==case['source'] and profiles[key]['input']==case['input']
                assert same(value,profiles[key][route])
            else:assert same(value,{'value':case['expected']})
        assert same(actual['native'],actual['restored']) and same(actual['plan'],actual['fresh'])
        if case.get('expected_error'):
            assert all(case['expected_error'] in value['error'] for value in actual.values())
            for route in ('native','restored'):
                assert actual[route]['runtime'] is True and actual[route]['generated'] is False
                assert actual[route]['code']=='binding_kind_mismatch' and actual[route]['diagnostic_stage']=='runtime_execution'
            for route in ('plan','fresh'):
                assert actual[route]['generated'] is True and actual[route]['runtime'] is False
                assert actual[route]['code']=='generated_execution_failed'

def historical(paths):
    r=subprocess.run(['git','cat-file','--batch'],cwd=ROOT,input=''.join(ACTIVATION+':'+p+'\n' for p in paths).encode(),stdout=subprocess.PIPE,check=True)
    body=r.stdout;position=0;out={}
    for p in paths:
        end=body.index(b'\n',position);header=body[position:end].split();assert header[1]==b'blob'
        size=int(header[2]);position=end+1;out[p]=body[position:position+size];position+=size+1
    assert position==len(body);return out

def patch(old,new,path):return ''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile='a/'+path,tofile='b/'+path)).encode()
def section(body,start,end):return body[body.index(start):body.index(end,body.index(start))]
def equal(a,b):assert a==b

def main():
    for path,row in json.loads((ROOT/BASE/'sealed-identities.json').read_bytes()).items():
        name=PurePosixPath(path);assert not name.is_absolute() and '..' not in name.parts
        body=(ROOT/name).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    inputs={phase:recover(phase) for phase in PHASES}
    cases=json.loads(inputs['intake'][FIXTURE]);profiles=json.loads(inputs['before'][PROFILE]);assert len(cases)==89
    assert cases[:28]==json.loads(inputs['intake'][COMMON]) and cases[28:]==json.loads(inputs['intake'][str(BASE/'profile-sources.json')])
    assert set(profiles)==set(HOSTS) and all(len(profiles[h])==65 for h in HOSTS)
    paths=sorted(p for p in inputs['intake'] if p.startswith('lua/') and p!=NORMAL)
    old=historical(paths+[GRAMMAR,COMMON]);original=inputs['intake'][OWNER];changed=inputs['after'][OWNER]
    assert original==old[OWNER] and original!=changed
    runner=inputs['after'][RUNNER];normal=inputs['intake'][NORMAL]
    needle=b'test("Hash-view Array result guards", function()\n  dofile("lua/test/hash_view_result_guard_composition_test.lua")\nend)'
    addition=b'\ntest("Pure Hash-helper result guards", function()\n  dofile("lua/test/hash_value_result_guard_composition_test.lua")\nend)'
    assert runner==old[RUNNER].replace(needle,needle+addition,1)
    assert runner.count(b'dofile("lua/test/hash_value_result_guard_composition_test.lua")')==1
    assert gzip.decompress((ROOT/BASE/'producer-change.patch.gz').read_bytes())==patch(original,changed,OWNER)
    assert gzip.decompress((ROOT/BASE/'runner-registration.patch.gz').read_bytes())==patch(old[RUNNER],runner,RUNNER)
    assert section(original,b'local function evaluate_hash_helper',b'local function evaluate_hash_values')==section(changed,b'local function evaluate_hash_helper',b'local function evaluate_hash_values')
    assert section(original,b'    if scalar_result and not (preserve_initial_count_source',b'function typed_source.receiver_mutation.failure')==section(changed,b'    if scalar_result and not (preserve_initial_count_source',b'function typed_source.receiver_mutation.failure')
    assert [line for line in original.splitlines() if line.startswith(b'local ')]==[line for line in changed.splitlines() if line.startswith(b'local ')]
    assert [line for line in original.splitlines() if b'scalar_result =' in line]==[line for line in changed.splitlines() if b'scalar_result =' in line]
    observations={};pairs={};versions={};native_products={}
    for phase in PHASES:
        files=inputs[phase];before=phase in ('intake','before')
        assert files[GRAMMAR]==old[GRAMMAR] and files[COMMON]==old[COMMON] and json.loads(files[FIXTURE])==cases and files[NORMAL]==normal
        for p in paths:
            expected=(original if before else changed) if p==OWNER else (old[RUNNER] if before else runner) if p==RUNNER else old[p]
            assert files[p]==expected,p
        if phase!='intake':assert json.loads(files[PROFILE])==profiles
        for name in ('prepare.py','capture.py','proof_io.py','freeze_profiles.py','observer.lua','profile-sources.json','cases.json'):
            assert files[str(BASE/name)]==inputs['intake'][str(BASE/name)]
        assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
        assert (ROOT/BASE/phase/'complete.txt').read_text()=='Both installed host epochs complete; actual source inputs unchanged.\n'
        prefix=str(BASE/'control-owner')+'/' if phase in ('inverse','restored') else ''
        if prefix:
            for p in paths:
                expected=original if phase=='inverse' and p==OWNER else changed if p==OWNER else runner if p==RUNNER else old[p]
                assert files[prefix+p]==expected,p
            assert files[prefix+NORMAL]==normal and files[prefix+GRAMMAR]==old[GRAMMAR]
            assert json.loads(files[prefix+FIXTURE])==cases and json.loads(files[prefix+PROFILE])==profiles
        observations[phase]={};pairs[phase]={};native_products[phase]={}
        for host in HOSTS:
            directory=phase+'/'+host;body=raw(phase,host);tag='HASH_VALUE_LUA' if phase=='intake' else 'HASH_VALUE_LUA_NORMAL'
            rows=frames(body,tag);validate(rows,cases,profiles[host],phase in ('intake','before','inverse'));observations[phase][host]=rows
            assert (ROOT/BASE/directory/'normal-exit.txt').read_text()==('1\n' if phase in ('before','inverse') else '0\n')
            assert ('HASH_VALUE_LUA_OWNER @'+prefix+OWNER+'\n').encode() in body
            if phase!='intake':assert b'HASH_VALUE_LUA_SUMMARY 510 checks '+(b'52' if phase in ('before','inverse') else b'0')+b' failures\n' in body
            grammar_tag='HASH_VALUE_LUA_GRAMMAR' if phase=='intake' else 'HASH_VALUE_LUA_NORMAL_GRAMMAR'
            grammars=[json.loads(line.split(' ',1)[1]) for line in body.decode().splitlines() if line.startswith(grammar_tag+' ')]
            assert grammars==[dict(path=GRAMMAR,source=old[GRAMMAR].decode())]
            assert body.index(grammar_tag.encode())<body.index((('HASH_VALUE_LUA_INPUT ' if phase=='intake' else 'HASH_VALUE_LUA_NORMAL ')).encode())
            command=json.loads((ROOT/BASE/directory/'normal-command.json').read_bytes())
            assert command['argv'][:2]==['bash','tools/project_data_run.sh']
            assert command['environment']['LUA_PATH']==prefix+'lua/src/?.lua;'+prefix+'lua/src/?/init.lua;;'
            assert command['environment']['LUA_CPATH']==str(BASE/directory/'native/?.so')+';;'
            assert command['environment']['LINKEDSPEC_HASH_VALUE_INPUT_ROOT']==prefix
            assert command['environment']['LINKEDSPEC_HASH_VALUE_CAPTURE']==str(BASE/directory)
            if prefix:
                golden='before' if phase=='inverse' else 'after'
                assert files[str(BASE/golden/host/'normal-stdout.log.gz')]==(ROOT/BASE/golden/host/'normal-stdout.log.gz').read_bytes()
                assert same(rows,observations[golden][host])
            version=raw(phase,host,'version')+raw(phase,host,'version','stderr')
            assert (ROOT/BASE/directory/'version-exit.txt').read_text()=='0\n'
            if phase=='intake':versions[host]=version
            else:assert version==versions[host]
            assert version.strip() and version.startswith(b'Lua ' if host=='puc' else b'LuaJIT ')
            native=recover(directory,'native');assert len(native)==3
            expected_native={str(BASE/directory/'native'/name) for name in ('linkedspec_regex_pcre2.so','linkedspec_filesystem_native.so','linkedspec_mcp_system.so')}
            assert native.keys()==expected_native;native_products[phase][host]=len(native)
            assert (ROOT/BASE/directory/'build-exit.txt').read_text()=='0\n'
            build=json.loads((ROOT/BASE/directory/'build-command.json').read_bytes())
            assert build['argv']==['bash','tools/build_lua_native.sh',host,str(BASE/directory/'native')]
            assert raw(phase,host,'build','stderr')==b''
            actual=recover(directory,'artifact');assert len(actual)==178;pairs[phase][host]={}
            supplied=frames(raw('intake',host),'HASH_VALUE_LUA_INPUT');assert list(supplied)==[case['id'] for case in cases]
            for case in cases:
                key=case['id'];module=actual[str(BASE/directory/'emitted'/(key+'.lua'))];parsed=actual[str(BASE/directory/'parsed'/(key+'.json'))]
                assert same(json.loads(parsed),supplied[key]);pairs[phase][host][key]=(module,parsed)
            if phase!='intake':assert pairs[phase][host]==pairs['intake'][host]
            if phase in ('intake','after','direct','restored'):assert raw(phase,host,channel='stderr')==b''
            else:assert b'merge_hash_free_array_guard native' in raw(phase,host,channel='stderr')
    for host in HOSTS:
        assert same(observations['intake'][host],observations['before'][host])
        assert same(observations['after'][host],observations['direct'][host])
        direct=raw('direct',host)
        for marker in (b'HASH_VALUE_LUA_SUMMARY 510 checks 0 failures',b'HASH_VIEW_LUA_SUMMARY 184 checks 0 failures',b'CONSTRUCTOR_SUMMARY 116 checks 0 failures',b'value copy checks passed',b'receiver copy arity checks passed'):
            assert marker in direct
        assert len([line for line in direct.splitlines() if line.startswith(b'COPY_OBSERVATION ')])==12
        asts=frames(raw('intake',host),'HASH_VALUE_LUA_COMPILED_ACTION')
        assert set(asts)=={'merge_later_with','set_copy_later_with','rename_logical_later_with'}
        for ast in asts.values():
            kinds=[]
            def visit(x):
                if isinstance(x,dict):
                    if x.get('method')=='with':kinds.extend(arg['kind'] for arg in x['args'])
                    for child in x.values():visit(child)
                elif isinstance(x,list):
                    for child in x:visit(child)
            visit(ast);assert kinds==['block_value']
    projector=section(old['lua/src/linkedspec/action_ast.lua'],b'project = function(value)',b'function M.to_json')
    assert b'result[key] = project(item)' in projector and b'"block_value"' not in projector
    rejected=[]
    def reject(name,operation):
        try:operation()
        except (AssertionError,KeyError):rejected.append(name)
        else:raise AssertionError('ineffective corruption '+name)
    def mutate(host,key,route,value,before=False):
        rows=copy.deepcopy(observations['before' if before else 'after'][host]);rows[key][route]=value
        validate(rows,cases,profiles[host],before)
    reject('hidden original PUC RED',lambda:mutate('puc','merge_hash_free_array_guard','native',{'value':[None,'']},True))
    reject('LuaJIT later body still runs',lambda:mutate('luajit','merge_later_with','native',{'value':['ran','AW']}))
    reject('masked PUC required error',lambda:mutate('puc','needed_source_error_composed','plan',{'value':None}))
    reject('normalized LuaJIT initial source',lambda:mutate('luajit','initial_number_set_key_free','native',{'value':None}))
    def normalize(x):
        if isinstance(x,bool):return int(x)
        if isinstance(x,list):return [normalize(y) for y in x]
        if isinstance(x,dict):return {k:normalize(v) for k,v in x.items()}
        return x
    reject('PUC Bool normalized to Number',lambda:mutate('puc','nested_kinds_and_source','native',normalize(observations['after']['puc']['nested_kinds_and_source']['native'])))
    missing=copy.deepcopy(observations['after']['luajit']);missing.pop('extra_merge_hash_free')
    reject('missing LuaJIT preservation member',lambda:validate(missing,cases,profiles['luajit']))
    drift=copy.deepcopy(profiles['puc']);drift['extra_merge_hash_free']['source']+=' '
    reject('PUC profile source drift',lambda:validate(observations['after']['puc'],cases,drift))
    reject('actual LuaJIT module drift',lambda:equal(digest(pairs['intake']['luajit']['merge_hash_compatible'][0]+b'\n'),digest(pairs['after']['luajit']['merge_hash_compatible'][0])))
    return dict(per_host={host:dict(version=versions[host].decode().strip(),programs=89,shared=28,own_source_controls=61,profiles=65,original_failures=13,healthy_preserved=76,normal_checks=510,normal_failures_before=52,normal_failures_after=0,direct_counted_checks=810,value_copy_observations=12,receiver_copy_arity='passing',private_original=dict(frames=89,RED=13),private_restored=dict(frames=89,PASS=89),actual_module_parsed_pairs_unchanged=89) for host in HOSTS},native_products_recovered_before_sdk_use=native_products,recovery_corruptions=rejected,scope='finite declared own direct sources/grammar/actual native products/artifacts; fresh modules share runtime/process; full toolchain/native/transitive custody4.2/SESSION5, general contexts/isolation, declared Lua5.4, registration and23.4 remain separate')
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))

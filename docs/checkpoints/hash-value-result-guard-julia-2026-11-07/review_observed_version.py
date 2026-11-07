"""Readonly historical Julia Hash-result proof; partial and complete epochs stay distinct."""
import copy,difflib,gzip,hashlib,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/hash-value-result-guard-julia-2026-11-07')
ACTIVATION='ff30df54c64b18eec1c150e6aeb7cd5136dcc33f'
OWNER='julia/src/runtime/Interpreter.jl';RUNNER='julia/test/runtests.jl'
NORMAL='julia/test/hash_value_result_guard_composition_test.jl'
COMMON='tests/fixtures/hash_value_result_guard_cases.json'
FIXTURE='tests/fixtures/hash_value_result_guard_julia_cases.json'
PROFILE='tests/fixtures/hash_value_result_guard_julia_profiles.json'
GRAMMAR='specs/user_function_definition.spec'
PHASES=('intake','before','after','after-complete','direct')
PRIVATE=('private-inverse','private-restored')
LATER={'merge_later_with','set_copy_later_with','rename_logical_later_with'}
RED={helper+'_'+form+'_array_guard' for helper in ('merge_hash','set_key','rename_key','drop_keys','pick_keys') for form in ('free','receiver')}|LATER

def digest(body):return hashlib.sha256(body).hexdigest()
def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
    if type(a) is not type(b):return False
    if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b

def raw(phase,channel='stdout',tag='normal'):
    return gzip.decompress((ROOT/BASE/phase/(tag+'-'+channel+'.log.gz')).read_bytes())
def frames(body,tag='HASH_VALUE_JULIA_NORMAL'):
    out={}
    for line in body.decode().splitlines():
        if line.startswith(tag+' '):
            _,key,value=line.split(' ',2);assert key not in out;out[key]=json.loads(value)
    return out

def recover(phase,artifact=False):
    stem='artifact' if artifact else 'input';name='actual-emitted-parsed.tar.gz' if artifact else 'inputs-before-first-run.tar.gz'
    expected=json.loads((ROOT/BASE/phase/(stem+'-identities.json')).read_bytes());files={}
    with tarfile.open(ROOT/BASE/phase/name) as archive:
        for member in archive:
            p=PurePosixPath(member.name)
            assert member.isfile() and not p.is_absolute() and '..' not in p.parts and member.name not in files
            body=archive.extractfile(member).read();row=expected[member.name]
            assert len(body)==row['bytes'] and digest(body)==row['sha256'] and member.mode&0o777==row['mode']
            files[member.name]=body
    assert files.keys()==expected.keys();return files

def grammar(phase,expected):
    body=raw(phase);tag='HASH_VALUE_JULIA_GRAMMAR' if phase=='intake' else 'HASH_VALUE_JULIA_NORMAL_GRAMMAR'
    rows=[json.loads(line.split(' ',1)[1]) for line in body.decode().splitlines() if line.startswith(tag+' ')]
    assert rows==[dict(path=GRAMMAR,source=expected.decode())]
    after=b'HASH_VALUE_JULIA_INPUT ' if phase=='intake' else b'HASH_VALUE_JULIA_NORMAL '
    assert body.index((tag+' ').encode())<body.index(after)

def validate(rows,cases,profiles,red=frozenset()):
    assert list(rows)==[row['id'] for row in cases]
    for case in cases:
        key=case['id'];actual=rows[key];assert set(actual)=={'native','restored','plan','fresh'}
        for route,value in actual.items():
            if key in red:
                expected=[[],'A'] if key.endswith('_array_guard') else ['ran','ADW' if key=='rename_logical_later_with' else 'AW']
                assert same(value,{'value':expected})
            elif key in profiles:
                assert profiles[key]['source']==case['source'] and profiles[key]['input']==case['input']
                assert same(value,profiles[key][route])
            else:assert same(value,{'value':case['expected']})
        assert same(actual['native'],actual['restored']) and same(actual['plan'],actual['fresh'])
        if case.get('expected_error'):
            assert all(case['expected_error'] in value['error'] for value in actual.values())
            assert actual['native']['class']=='RuntimeInterpreterException' and actual['plan']['class']=='GeneratedSourceException'

def historical(paths):
    result=subprocess.run(['git','cat-file','--batch'],cwd=ROOT,input=''.join(ACTIVATION+':'+p+'\n' for p in paths).encode(),stdout=subprocess.PIPE,check=True)
    body=result.stdout;position=0;out={}
    for p in paths:
        end=body.index(b'\n',position);header=body[position:end].split();assert header[1]==b'blob'
        size=int(header[2]);position=end+1;out[p]=body[position:position+size];position+=size+1
    assert position==len(body);return out

def patch(old,new,path):
    return ''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile='a/'+path,tofile='b/'+path)).encode()
def section(body,start,end):return body[body.index(start):body.index(end,body.index(start))]
def equal(a,b):assert a==b

def main():
    for p,row in json.loads((ROOT/BASE/'sealed-identities.json').read_bytes()).items():
        path=PurePosixPath(p);assert not path.is_absolute() and '..' not in path.parts
        body=(ROOT/path).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    inputs={phase:recover(phase) for phase in PHASES+PRIVATE}
    artifacts={phase:recover(phase,True) for phase in PHASES+PRIVATE}
    cases=json.loads(inputs['intake'][FIXTURE]);profiles=json.loads(inputs['before'][PROFILE])
    assert len(cases)==89 and len(profiles)==65 and cases[:28]==json.loads(inputs['intake'][COMMON])
    assert cases[28:]==json.loads(inputs['intake'][str(BASE/'profile-sources.json')])
    assert len(RED)==13 and len(LATER)==3
    paths=sorted(p for p in inputs['intake'] if p.startswith('julia/'))
    old=historical(paths+[GRAMMAR,COMMON])
    original=inputs['intake'][OWNER];partial=inputs['after'][OWNER];complete=inputs['after-complete'][OWNER]
    assert original==old[OWNER] and original!=partial and partial!=complete
    normal=inputs['before'][NORMAL];runner=inputs['after-complete'][RUNNER]
    needle=b'include("hash_view_result_guard_composition_test.jl")'
    assert runner==old[RUNNER].replace(needle,needle+b'\ninclude("hash_value_result_guard_composition_test.jl")',1)
    assert runner.count(b'include("hash_value_result_guard_composition_test.jl")')==1
    assert gzip.decompress((ROOT/BASE/'producer-change.patch.gz').read_bytes())==patch(original,complete,OWNER)
    assert gzip.decompress((ROOT/BASE/'runner-registration.patch.gz').read_bytes())==patch(old[RUNNER],runner,RUNNER)
    for start,end in [(b'        if scalar_result &&',b'        # Scalar producers and defaults'),(b'        if helper_name in _RUNTIME_ARRAY_END_MUTATION_NAMES',b'        value = _evaluate_runtime_fluent_value_call!'),(b'function _call_runtime_hash_helper',b'function _runtime_hash_items')]:
        assert section(original,start,end)==section(complete,start,end)
    assert [x for x in original.splitlines() if b'scalar_result =' in x]==[x for x in complete.splitlines() if b'scalar_result =' in x]
    assert b'for (call_index, call) in enumerate(chain.calls)' in complete
    observations={};pairs={};supplied=frames(raw('intake'),'HASH_VALUE_JULIA_INPUT')
    assert list(supplied)==[case['id'] for case in cases]
    for phase in PHASES:
        files=inputs[phase]
        assert files[GRAMMAR]==old[GRAMMAR] and files[COMMON]==old[COMMON] and json.loads(files[FIXTURE])==cases
        for p in paths:
            expected=(original if phase in ('intake','before') else partial if phase=='after' else complete) if p==OWNER else (old[RUNNER] if phase in ('intake','before') else runner) if p==RUNNER else old[p]
            assert files[p]==expected,p
        if phase!='intake':assert files[NORMAL]==normal and json.loads(files[PROFILE])==profiles
        for name in ('prepare.py','proof_io.py','capture.py','observer.jl','freeze_profiles.py','private_control.py','cases.json','profile-sources.json'):
            assert files[str(BASE/name)]==inputs['intake'][str(BASE/name)]
        assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
        command=json.loads((ROOT/BASE/phase/'normal-command.json').read_bytes())
        assert command['argv'][:2]==['bash','tools/run_julia_project_data.sh'] and '--depwarn=error' in command['argv']
        assert command['environment']['JULIA_NUM_THREADS']==command['environment']['OPENBLAS_NUM_THREADS']=='1'
        grammar(phase,old[GRAMMAR])
        tag='HASH_VALUE_JULIA' if phase=='intake' else 'HASH_VALUE_JULIA_NORMAL'
        rows=frames(raw(phase),tag);red=RED if phase in ('intake','before') else LATER if phase=='after' else set()
        validate(rows,cases,profiles,red);observations[phase]=rows
        expected_exit='1\n' if phase in ('before','after') else '0\n'
        assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==expected_exit
        if phase!='intake':assert b'HASH_VALUE_JULIA_OWNER julia/src/LinkedSpecJulia.jl\n' in raw(phase)
        assert (ROOT/BASE/phase/'version-exit.txt').read_text()=='0\n' and raw(phase,tag='version')==raw('intake',tag='version') and re.fullmatch(rb'julia version [0-9]+\.[0-9]+\.[0-9]+\n',raw(phase,tag='version'))
    assert same(observations['intake'],observations['before']) and same(observations['after-complete'],observations['direct'])
    for phase,passed,failed in [('before',458,52),('after',498,12)]:
        assert re.search(rb'Julia pure Hash-helper result guards\s*\|\s*'+str(passed).encode()+rb'\s+'+str(failed).encode()+rb'\s+510\s',raw(phase))
        assert ('Some tests did not pass: '+str(passed)+' passed, '+str(failed)+' failed, 0 errored').encode() in raw(phase,'stderr')
    for phase in ('after-complete','direct'):
        assert re.search(rb'Julia pure Hash-helper result guards\s*\|\s*510\s+510\s',raw(phase))
    for title,count in [('Julia Hash-view result guards',184),('Julia retained constructor result guards',116),('Julia value-copy contract',12),('Receiver copy arity before effects',3)]:
        assert re.search(re.escape(title.encode())+rb'\s*\|\s*'+str(count).encode()+rb'\s+'+str(count).encode()+rb'\s',raw('direct'))
    assert raw('intake','stderr')==raw('direct','stderr')==b''
    assert b'ERROR:' not in raw('after-complete','stderr')
    for phase in PRIVATE:
        prefix=str(BASE/'control-owner')+'/'
        files=inputs[phase];inverse=phase=='private-inverse'
        assert files[prefix+OWNER]==(original if inverse else complete)
        assert files[prefix+NORMAL]==normal and files[prefix+GRAMMAR]==old[GRAMMAR]
        assert json.loads(files[prefix+FIXTURE])==cases and json.loads(files[prefix+PROFILE])==profiles
        for p in paths:
            if p not in (OWNER,RUNNER):assert files[prefix+p]==old[p]
        golden='before' if inverse else 'after-complete'
        assert files[str(BASE/golden/'normal-stdout.log.gz')]==(ROOT/BASE/golden/'normal-stdout.log.gz').read_bytes()
        rows=frames(raw(phase));validate(rows,cases,profiles,RED if inverse else set())
        assert same(rows,observations[golden]);observations[phase]=rows
        grammar(phase,old[GRAMMAR])
        assert ('HASH_VALUE_JULIA_OWNER '+prefix+'julia/src/LinkedSpecJulia.jl\n').encode() in raw(phase)
        assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==('1\n' if inverse else '0\n')
        assert len(rows)==89
        pattern=rb'458\s+52\s+510' if inverse else rb'510\s+510'
        assert re.search(rb'Julia pure Hash-helper result guards\s*\|\s*'+pattern+rb'\s',raw(phase))
        command=json.loads((ROOT/BASE/phase/'normal-command.json').read_bytes())
        assert '--compiled-modules=no' in command['argv'] and '--project='+prefix+'julia' in command['argv']
    for phase in PHASES+PRIVATE:
        assert len(artifacts[phase])==178;pairs[phase]={}
        for case in cases:
            key=case['id'];module=artifacts[phase][str(BASE/phase/'emitted'/(key+'.jl'))];parsed=artifacts[phase][str(BASE/phase/'parsed'/(key+'.json'))]
            assert same(json.loads(parsed),supplied[key]);pairs[phase][key]=(module,parsed)
        assert pairs[phase]==pairs['intake']
    for phase in ('with-diagnosis','with-diagnosis-compiled'):
        files=recover(phase);assert files[OWNER]==partial
        assert (ROOT/BASE/phase/'action-exit.txt').read_text()=='0\n' and raw(phase,'stderr','action')==b''
    parsed=frames(raw('with-diagnosis',tag='action'),'HASH_VALUE_JULIA_ACTION')
    compiled=frames(raw('with-diagnosis-compiled',tag='action'),'HASH_VALUE_JULIA_COMPILED_ACTION')
    assert set(parsed)==set(compiled)==LATER
    def with_args(value):
        found=[]
        def visit(x):
            if isinstance(x,dict):
                if x.get('method')=='with':found.append(x['args'])
                for y in x.values():visit(y)
            elif isinstance(x,list):
                for y in x:visit(y)
        visit(value);return found
    for key in LATER:
        assert [a[0]['kind'] for a in with_args(parsed[key])]==['block_value']
        assert [a[0]['kind'] for a in with_args(compiled[key])]==['codeblock_argument']
    final=observations['after-complete'];rejected=[]
    def reject(name,operation):
        try:operation()
        except (AssertionError,KeyError):rejected.append(name)
        else:raise AssertionError('ineffective corruption '+name)
    def mutate(key,route,value,red=frozenset(),original_rows=None):
        rows=copy.deepcopy(final if original_rows is None else original_rows);rows[key][route]=value;validate(rows,cases,profiles,red)
    reject('hidden original RED',lambda:mutate('merge_hash_free_array_guard','native',{'value':[None,'']},RED,observations['before']))
    reject('later body still runs',lambda:mutate('merge_later_with','native',{'value':['ran','AW']}))
    reject('masked required error',lambda:mutate('needed_source_error_composed','plan',{'value':None}))
    reject('normalized initial source',lambda:mutate('initial_number_set_key_free','native',{'value':None}))
    boolean=copy.deepcopy(final['nested_kinds_and_source']['native'])
    def normalize(x):
        if isinstance(x,bool):return int(x)
        if isinstance(x,list):return [normalize(y) for y in x]
        if isinstance(x,dict):return {k:normalize(v) for k,v in x.items()}
        return x
    reject('Bool normalized to Number',lambda:mutate('nested_kinds_and_source','native',normalize(boolean)))
    missing=copy.deepcopy(final);missing.pop('extra_merge_hash_free');reject('missing preservation member',lambda:validate(missing,cases,profiles))
    drift=copy.deepcopy(profiles);drift['extra_merge_hash_free']['source']+=' ';reject('profile source drift',lambda:validate(final,cases,drift))
    reject('actual module drift',lambda:equal(digest(pairs['intake']['merge_hash_compatible'][0]+b'\n'),digest(pairs['direct']['merge_hash_compatible'][0])))
    return dict(programs=89,shared=28,own_source_controls=61,profiles=65,original_failures=13,healthy_preserved=76,normal_before=dict(PASS=458,FAIL=52),partial_after=dict(PASS=498,FAIL=12),complete_normal=510,direct_assertions=825,private_old=dict(frames=89,RED=13),private_current=dict(frames=89,PASS=89),actual_module_parsed_pairs_unchanged=89,recovery_corruptions=rejected,scope='finite declared own direct source/grammar/artifact proof; fresh Modules share runtime/process; full native/cache/transitive custody4.2/SESSION5, contexts, general isolation, registration and23.4 remain separate')
if __name__=='__main__':
    for path,row in json.loads((ROOT/BASE/'observed-version-identities.json').read_bytes()).items():
        relative=PurePosixPath(path);assert not relative.is_absolute() and '..' not in relative.parts
        body=(ROOT/relative).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    assert (ROOT/BASE/'review-exit.txt').read_text()=='1\n'
    assert b'julia version 1.12.6' in gzip.decompress((ROOT/BASE/'review-stderr.log.gz').read_bytes())
    result=main()
    result['observed_julia_version']=raw('intake',tag='version').decode().strip()
    result['reader_qualification']='original reader exit1 on manifest-derived1.12.6 assumption; separate reader derives actual captured host bytes; original proof/seal/reader/channels unchanged'
    print(json.dumps(result,indent=2,sort_keys=True))

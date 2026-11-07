"""Readonly original Array-transform selection and precise input/artifact recovery."""
import copy,gzip,hashlib,json,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/array-transform-result-selection-2026-11-07')
ACTIVATION='5e3636279fb06d26fa81aac569ec21c419c56414'
FIXTURE='tests/fixtures/array_transform_result_guard_cases.json'
GRAMMARS=('specs/spec.spec','specs/user_function_definition.spec','specs/pplugin.spec')
HELPERS=('take','take_last','drop_front','drop_back','slice','sorted','reversed','concat_arrays')
RECEIVERS={name+'_receiver_hash_guard' for name in HELPERS}
FREE={name+'_free_hash_guard' for name in HELPERS}
LATER={'take_later_with','reverse_copy_later_with','sort_logical_later_with'}
RED=RECEIVERS|FREE|LATER
META=dict(language_agnostic_action_ir_ready=1,raw_perl_dependency_count=0,canonical_action_ir_fallback_count=0,unresolved_helper_count=0,unresolved_helpers=[])
def digest(body):return hashlib.sha256(body).hexdigest()
def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
    if type(a) is not type(b):return False
    if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b

def frames(body,tag):
    rows={}
    for line in body.decode().splitlines():
        if line.startswith(tag+' '):
            _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
    return rows

def validate(rows,cases):
    assert list(rows)==[case['id'] for case in cases]
    for case in cases:
        key=case['id'];row=rows[key];assert row['metadata']==META and row['native_callable']==1
        assert row['substitution_error'] is None and row['descriptor_error'] is None and row['emission_error'] is None and row['build_error'] is None
        if key in RED or case.get('expected_error'):
            assert isinstance(row.get('native_error'),dict)
            if key not in RECEIVERS:assert isinstance(row.get('fresh_error'),dict)
        if key in RECEIVERS:
            assert row['loaded']==0 and row['native_error']['stage']=='rule_handler_compile'
            assert 'fresh_error' not in row and 'fresh' not in row and row['native'] is None
            assert 'syntax error' in row['load_error'] and 'syntax error' in row['native_error']['detail']
            assert row['warnings'] and all('Unquoted string "order"' in warning for warning in row['warnings'])
            assert '.set_key({order=cat(order,"K");"k"}' in row['substitution']
        elif key in FREE|LATER:
            assert row['loaded']==1 and row['load_error'] is None and row['warnings']==[]
            assert row['native'] is None and row['fresh'] is None
            assert row['native_error']['stage']=='rule_handler_eval' and 'Not a HASH reference' in row['native_error']['detail']
            assert row['fresh_error']['code']=='generated_execution_failed' and row['fresh_error']['stage']=='execute_generated' and 'Not a HASH reference' in row['fresh_error']['detail']
            assert "ref($__ls_set_key_source) ne '' ? %{$__ls_set_key_source}" in row['substitution']
        elif case.get('expected_error'):
            assert row['loaded']==1 and row['load_error'] is None and row['warnings']==[]
            assert row['native_error']['stage']=='rule_handler_eval' and row['fresh_error']['stage']=='execute_generated'
            assert row['fresh_error']['code']=='generated_execution_failed'
            assert all(case['expected_error'] in row[route+'_error']['detail'] for route in ('native','fresh'))
            assert row['native_error']['detail']==row['fresh_error']['detail']
        else:
            assert row['loaded']==1 and row['load_error'] is None and row['warnings']==[]
            assert row['native_error'] is None and row['fresh_error'] is None
            assert same(row['native'],case['expected']) and same(row['fresh'],case['expected'])
        assert row['native_cursor']==0
        if row['loaded']:assert row['fresh_cursor']==0

def git_bodies(paths):
    result=subprocess.run(['git','cat-file','--batch'],cwd=ROOT,input=''.join(ACTIVATION+':'+p+'\n' for p in paths).encode(),stdout=subprocess.PIPE,check=True)
    body=result.stdout;position=0;out={}
    for path in paths:
        end=body.index(b'\n',position);header=body[position:end].split();assert header[1]==b'blob';size=int(header[2]);position=end+1
        out[path]=body[position:position+size];position+=size+1
    assert position==len(body);return out

def equal(a,b):assert a==b

def main():
    for name,row in json.loads((ROOT/BASE/'sealed-identities.json').read_bytes()).items():
        path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts
        body=(ROOT/path).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    records=json.loads((ROOT/BASE/'intake/input-identities.json').read_bytes());inputs={}
    with tarfile.open(ROOT/BASE/'intake/inputs-before-first-run.tar.gz') as archive:
        for member in archive:
            path=PurePosixPath(member.name);assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in inputs
            body=archive.extractfile(member).read();row=records[member.name]
            assert len(body)==row['bytes'] and digest(body)==row['sha256'] and member.mode&0o777==row['mode'];inputs[member.name]=body
    assert inputs.keys()==records.keys()
    paths=sorted(name for name in inputs if name.startswith('perl/') or name in GRAMMARS)
    assert {p:inputs[p] for p in paths}==git_bodies(paths)
    cases=json.loads(inputs[str(BASE/'cases.json')]);assert len(cases)==37 and len(RED)==19
    assert cases==json.loads((ROOT/FIXTURE).read_bytes())
    body=gzip.decompress((ROOT/BASE/'intake/stdout.log.gz').read_bytes())
    rows=frames(body,'ARRAY_TRANSFORM_PERL');supplied=frames(body,'ARRAY_TRANSFORM_INPUT')
    validate(rows,cases);assert list(rows)==list(supplied)
    assert (ROOT/BASE/'intake/exit.txt').read_text()=='0\n' and gzip.decompress((ROOT/BASE/'intake/stderr.log.gz').read_bytes())==b''
    assert (ROOT/BASE/'intake/activation.txt').read_text().strip()==ACTIVATION
    command=json.loads((ROOT/BASE/'intake/command.json').read_bytes());assert command['argv'][:7]==['bash','tools/project_data_run.sh','env','PERL5LIB=','perl','-Iperl',str(BASE/'observer.pl')]
    for case in cases:
        key=case['id'];assert supplied[key]['source']==case['source']
        for name,field in [('module_input','emitted'),('handler_input','handler')]:
            record=rows[key][name];path=PurePosixPath(record['path']);assert not path.is_absolute() and '..' not in path.parts and str(path).startswith(str(BASE/'intake')+'/')
            artifact=gzip.decompress((ROOT/path).read_bytes());assert len(artifact)==record['bytes'] and digest(artifact)==record['sha256'] and artifact==supplied[key][field].encode()
        assert rows[key]['module_input']['path'].endswith('/'+key+'.pm.gz') and rows[key]['handler_input']['path'].endswith('/'+key+'.handler.pl.gz')
    oracle=rows['constructor_array_guard']['substitution'];assert "ref($__ls_selected_default) eq 'HASH'" in oracle and '$__ls_free_default_rejected = 1' in oracle
    owner=inputs['perl/LinkedSpec/ActionIR/MethodLowering.pm']
    assert b'sub _ordinary_hash_value_result_call' in owner and b'my $ordinary_hash_view_result_chain' in owner
    assert b'my $ordinary_array_transform_result_chain' not in owner
    rejected=[]
    def reject(name,operation):
        try:operation()
        except (AssertionError,KeyError):rejected.append(name)
        else:raise AssertionError('ineffective corruption '+name)
    def mutate(key,field,value):
        changed=copy.deepcopy(rows);changed[key][field]=value;validate(changed,cases)
    reject('hidden original free runtime error',lambda:mutate('take_free_hash_guard','native_error',None))
    reject('receiver compilation failure normalized',lambda:mutate('take_receiver_hash_guard','loaded',1))
    reject('invented fresh execution after failed load',lambda:mutate('take_receiver_hash_guard','fresh_error',None))
    reject('masked needed producer error',lambda:mutate('needed_count_error_composed','fresh_error',None))
    def normalize(x):
        if isinstance(x,bool):return int(x)
        if isinstance(x,list):return [normalize(y) for y in x]
        if isinstance(x,dict):return {k:normalize(v) for k,v in x.items()}
        return x
    reject('Bool normalized to Number',lambda:mutate('nested_kinds_and_source','native',normalize(rows['nested_kinds_and_source']['native'])))
    reject('healthy Array order drift',lambda:mutate('reversed_compatible','fresh',[['head','tail'],['tail','head']]))
    lost=copy.deepcopy(rows);lost.pop('valid_empty_with');reject('missing healthy member',lambda:validate(lost,cases))
    changed_cases=copy.deepcopy(cases);changed_cases[0]['expected']=[['wrong'],['head']];reject('fixture target drift',lambda:validate(rows,changed_cases))
    module=supplied['take_compatible']['handler'].encode();reject('actual handler drift',lambda:equal(digest(module+b'\n'),rows['take_compatible']['handler_input']['sha256']))
    return dict(programs=37,eligible_ready=37,original_failures=19,free_or_later_runtime_errors=11,receiver_compile_errors=8,healthy_controls=18,actual_module_handler_pairs=37,recovery_corruptions=rejected,scope='finite original public Perl selection, unchanged targets; no production/peer verdict/full source-context/native-transitive custody/isolation/registration/23.4 admission')
if __name__=='__main__':
    for name,row in json.loads((ROOT/BASE/'typed-error-identities.json').read_bytes()).items():
        relative=PurePosixPath(name);assert not relative.is_absolute() and '..' not in relative.parts
        body=(ROOT/relative).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    assert (ROOT/BASE/'unloaded-review-exit.txt').read_text()=='1\n'
    assert b"TypeError: 'NoneType' object is not subscriptable" in gzip.decompress((ROOT/BASE/'unloaded-review-stderr.log.gz').read_bytes())
    for name,row in json.loads((ROOT/BASE/'unloaded-identities.json').read_bytes()).items():
        relative=PurePosixPath(name);assert not relative.is_absolute() and '..' not in relative.parts
        body=(ROOT/relative).read_bytes();assert len(body)==row['bytes'] and digest(body)==row['sha256']
    assert (ROOT/BASE/'review-exit.txt').read_text()=='1\n'
    assert b"KeyError: 'fresh_error'" in gzip.decompress((ROOT/BASE/'review-stderr.log.gz').read_bytes())
    result=main();result['reader_qualification']='original first reader assumed a fresh-execution field for unloaded modules; separate reader requires actual field absence; original producer/observations/targets/reader/seal unchanged'
    result['error_shape_qualification']='second reader halted at first corrupted None error record; separate reader explicitly validates error-record shapes; all earlier failures/observations/seals remain unchanged'
    print(json.dumps(result,indent=2,sort_keys=True))

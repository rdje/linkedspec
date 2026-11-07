"""Readonly finite Rust Hash-result recovery; historical inputs, never current SDK."""
import copy
import gzip
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/hash-value-result-guard-rust-2026-11-07')
ACTIVATION='4eeb2de5dbe3c6a602bd756a41eb51c0b457692d'
OWNER='rust/linkedspec-runtime/src/engine.rs'
NORMAL='rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs'
FIXTURE='tests/fixtures/hash_value_result_guard_cases.json'
PROFILE='tests/fixtures/hash_value_result_guard_rust_profiles.json'
RED={helper+'_'+form+'_array_guard' for helper in ('merge_hash','set_key','rename_key','drop_keys','pick_keys') for form in ('free','receiver')}
RED|={'merge_later_with','set_copy_later_with','rename_logical_later_with'}


def digest(body): return hashlib.sha256(body).hexdigest()


def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool): return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)): return a==b
    if type(a) is not type(b): return False
    if isinstance(a,list): return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict): return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b


def raw(path): return gzip.decompress((ROOT/path).read_bytes())


def recover(path,identities):
    safe=PurePosixPath(path)
    assert not safe.is_absolute() and '..' not in safe.parts
    result={}
    with tarfile.open(ROOT/path) as archive:
        for member in archive:
            name=PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert member.name not in result
            row=identities[member.name]
            body=archive.extractfile(member).read()
            assert digest(body)==row['sha256'] and len(body)==row['bytes']
            assert member.mode & 0o777==row['mode']
            result[member.name]=body
    assert result.keys()==identities.keys()
    return result


def custody(phase):
    result={}
    for row in json.loads((ROOT/BASE/phase/'custody.json').read_bytes()):
        assert row['archive'].startswith(str(BASE/phase)+'/')
        tag=Path(row['archive']).name.split('-before-first-run')[0]
        assert tag not in result
        result[tag]=recover(row['archive'],row['files'])
    return result


def tagged(body,prefix):
    result={}
    for line in body.decode().splitlines():
        if line.startswith(prefix+' '):
            _,key,value=line.split(' ',2)
            assert key not in result
            result[key]=json.loads(value)
    return result


def target(case,actual,route,profiles):
    if case['id'] in profiles:
        profile=profiles[case['id']]
        assert case['source']==profile['source'] and case['input']==profile['input']
        assert same(actual,profile[route])
        if case.get('expected_error'): assert case['expected_error'] in actual['error']
    else:
        assert same(actual,{'value':case['expected']})


def validate(native,fresh,cases,profiles,before=False):
    assert list(native)==list(fresh)==[c['id'] for c in cases]
    for case in cases:
        key=case['id']
        assert set(native[key])=={'native','restored','plan'}
        routes={**native[key],'fresh':fresh[key]}
        for route,actual in routes.items():
            if before and key in RED:
                if key.endswith('_free_array_guard'): value=[[],'A']
                elif key.endswith('_receiver_array_guard'): value=[None,'A']
                else: value=['ran','ADW' if key=='rename_logical_later_with' else 'AW']
                assert same(actual,{'value':value})
            else: target(case,actual,route,profiles)
        assert same(native[key]['native'],native[key]['restored'])
        if case.get('expected_error'):
            assert same(native[key]['plan'],fresh[key])
            assert fresh[key]['error']=='Generated Rust parser execution failed: '+native[key]['native']['error']
        else: assert all(same(native[key]['native'],row) for row in routes.values())


def route_rows(phase):
    for tag in ('cargo-version','rustc-version','native-lock','native','fresh-lock','fresh'):
        assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
        for channel in ('stdout','stderr'): raw(BASE/phase/(tag+'-'+channel+'.log.gz'))
    return (tagged(raw(BASE/phase/'native-stdout.log.gz'),'HASH_VALUE_RUST'),
            tagged(raw(BASE/phase/'fresh-stdout.log.gz'),'HASH_VALUE_RUST_FRESH'))


def artifacts(phase,recovered,cases):
    assert json.loads(recovered['native'][str(BASE/phase/'cases.json')])==cases
    assert recovered['native'][str(BASE/phase/'native/src/main.rs')]==recovered['root'][str(BASE/'observer.rs')]
    frames=tagged(raw(BASE/phase/'native-stdout.log.gz'),'HASH_VALUE_RUST_INPUT')
    assert list(frames)==[c['id'] for c in cases]
    fresh=recovered['fresh']
    modules={p:b for p,b in fresh.items() if '/src/generated/' in p}
    assert {Path(p).name for p in modules}=={c['id']+'.rs' for c in cases}
    result={}
    for case in cases:
        key=case['id']
        serialized=fresh[str(BASE/phase/'fresh/inputs'/(key+'.json'))]
        assert serialized.decode()==frames[key]['compiled']
        module=fresh[str(BASE/phase/'fresh/src/generated'/(key+'.rs'))]
        assert key+'.rs' in fresh[str(BASE/phase/'fresh/src/lib.rs')].decode()
        result[key]=dict(serialized=serialized,module=module)
    return result


def normal(phase,cases,expected,private=False,before=False,direct=False):
    if private:
        exit_path=BASE/phase/'exit.txt'; stdout=raw(BASE/phase/'stdout.log.gz'); stderr=raw(BASE/phase/'stderr.log.gz')
    else:
        exit_path=BASE/phase/'normal-exit.txt'; stdout=raw(BASE/phase/'normal-stdout.log.gz'); stderr=raw(BASE/phase/'normal-stderr.log.gz')
    assert (ROOT/exit_path).read_text()==('101\n' if before else '0\n')
    frames=tagged(stderr,'HASH_VALUE_RUST_NORMAL')
    assert set(frames)=={c['id'] for c in cases}
    assert same(frames,expected)
    failed=set(re.findall(r'^test (\w+) \.\.\. FAILED$',stdout.decode(),re.M))
    assert failed==(RED if before else set())
    counts=re.findall(r'test result: (?:ok|FAILED)\. (\d+) passed; (\d+) failed; (\d+) ignored; (\d+) measured; (\d+) filtered out;',stdout.decode())
    assert len(counts)==(4 if direct else 1)
    assert sum(int(row[0]) for row in counts)==(141 if direct else 76 if before else 89)
    assert all(row[2:]==('0','0','0') for row in counts)
    return frames


def equal(a,b): assert a==b


def main():
    sealed=json.loads((ROOT/BASE/'sealed-identities.json').read_bytes())
    for name,row in sealed.items():
        path=PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body=(ROOT/name).read_bytes()
        assert digest(body)==row['sha256'] and len(body)==row['bytes']
        if name.endswith('.gz'): gzip.decompress(body)
    phases=('intake','normal-before','normal-after','after-intake','direct','format')
    recovered={p:custody(p) for p in phases}
    roots={p:recovered[p]['root'] for p in phases}
    cases=json.loads(roots['intake'][str(BASE/'intake/cases.json')])
    shared=json.loads(roots['intake'][FIXTURE])
    authored=json.loads(roots['intake'][str(BASE/'profile-sources.json')])
    assert len(shared)==28 and len(authored)==61 and cases==shared+authored
    profiles=json.loads(roots['normal-before'][PROFILE])
    assert len(profiles)==65
    assert {k for k,v in profiles.items() if v['profile_only']}=={c['id'] for c in authored}
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git','archive','--format=tar',ACTIVATION,'rust']))) as archive:
        old={m.name:archive.extractfile(m).read() for m in archive if m.isfile()}
    for phase in phases:
        assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
        for grammar in ('spec.spec','user_function_definition.spec','pplugin.spec'):
            path='specs/'+grammar
            assert roots[phase][path]==subprocess.check_output(['git','show',ACTIVATION+':'+path])
        assert roots[phase][FIXTURE]==subprocess.check_output(['git','show',ACTIVATION+':'+FIXTURE])
        if phase in ('intake','normal-before'): assert all(roots[phase][p]==b for p,b in old.items())
        else:
            assert {p for p,b in old.items() if roots[phase][p]!=b}=={OWNER}
            assert roots[phase][OWNER]==roots['normal-after'][OWNER]
        if phase!='intake':
            assert roots[phase][NORMAL]==roots['normal-before'][NORMAL]
            assert roots[phase][PROFILE]==roots['normal-before'][PROFILE]
    before,fresh_before=route_rows('intake'); after,fresh_after=route_rows('after-intake')
    validate(before,fresh_before,cases,profiles,True)
    validate(after,fresh_after,cases,profiles)
    for case in cases:
        if case['id'] not in RED:
            assert same(before[case['id']],after[case['id']])
            assert same(fresh_before[case['id']],fresh_after[case['id']])
    old_artifacts=artifacts('intake',recovered['intake'],cases)
    new_artifacts=artifacts('after-intake',recovered['after-intake'],cases)
    assert old_artifacts==new_artifacts
    normal('normal-before',cases,before,before=True)
    normal('normal-after',cases,after)
    normal('direct',cases,after,direct=True)
    for phase,expected,inverse in (('private-inverse',before,True),('private-restored',after,False)):
        directory=ROOT/BASE/phase
        identities=json.loads((directory/'input-identities.json').read_bytes())
        snapshot=recover(BASE/phase/'inputs-before-first-run.tar.gz',identities)
        prefix=str(BASE/'control-owner')+'/'
        for path,body in snapshot.items():
            if not path.startswith(prefix): continue
            original=path[len(prefix):]
            if original==OWNER: assert body==(old[OWNER] if inverse else roots['normal-after'][OWNER])
            elif original=='rust/Cargo.toml':
                canonical=roots['normal-after'][original].decode()
                replacement='path = "'+os.path.relpath(ROOT/'rgx/rgx-core',ROOT/BASE/'control-owner/rust')+'"'
                assert body.decode()==canonical.replace('path = "../rgx/rgx-core"',replacement)
            else: assert body==roots['normal-after'][original]
        normal(phase,cases,expected,private=True,before=inverse)
    assert (ROOT/BASE/'format/format-exit.txt').read_text()=='0\n'
    assert raw(BASE/'format/format-stdout.log.gz')==raw(BASE/'format/format-stderr.log.gz')==b''
    controls=[]
    def reject(name,operation):
        try: operation()
        except (AssertionError,KeyError): controls.append(name)
        else: raise AssertionError('ineffective corruption '+name)
    changed=copy.deepcopy(before); changed['merge_hash_free_array_guard']=copy.deepcopy(after['merge_hash_free_array_guard'])
    reject('original failure hidden',lambda:validate(changed,fresh_before,cases,profiles,True))
    changed=copy.deepcopy(after); changed['merge_hash_free_array_guard']['native']={'value':[None,'A']}
    reject('consumer effect admitted',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(fresh_after); changed['merge_later_with']={'value':['ran','AW']}
    reject('later body admitted',lambda:validate(after,changed,cases,profiles))
    changed=copy.deepcopy(after); changed['needed_source_error_composed']['native']={'value':'masked'}
    reject('required error masked',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(after); changed['initial_number_set_key_free']['native']={'value':{}}
    reject('source fallback normalized',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(after); changed['nested_kinds_and_source']['native']['value'][0]=0
    reject('Bool changed to Number',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(after); del changed['extra_merge_hash_receiver']
    reject('profile omitted',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(new_artifacts); changed['merge_hash_compatible']['module']+=b'\n// drift\n'
    reject('actual module drift',lambda:equal(old_artifacts,changed))
    assert len(controls)==8
    print(json.dumps(dict(shared=28,own_controls=61,total=89,original_failures=13,preserved=76,four_routes='PASS',direct_tests=141,private_inverse=13,private_restored=89,artifacts=89,recovery='PASS',effective_corruptions=controls),indent=2))


if __name__=='__main__': main()

"""Readonly finite Dart Hash-result proof from actual historical inputs/channels."""
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path,PurePosixPath
import posixpath
import re
import subprocess
import tarfile
from urllib.parse import unquote,urlparse

ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/hash-value-result-guard-dart-2026-11-07')
ACTIVATION='a36f5893b6876865895ff653cd8342ed144bf593'
OWNER='dart/lib/src/runtime/interpreter.dart'
PROBE='dart/tool/probe_hash_value_results.dart'
NORMAL='dart/test/hash_value_result_guard_composition_test.dart'
PROFILE='tests/fixtures/hash_value_result_guard_dart_profiles.json'
COMMON='tests/fixtures/hash_value_result_guard_cases.json'
GRAMMAR='specs/user_function_definition.spec'
RED={helper+'_'+form+'_array_guard' for helper in ('merge_hash','set_key','rename_key','drop_keys','pick_keys') for form in ('free','receiver')}
RED|={'merge_later_with','set_copy_later_with','rename_logical_later_with'}
CANONICAL=('intake','before','after','after-intake','direct','format')


def digest(body): return hashlib.sha256(body).hexdigest()


def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool): return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)): return a==b
    if type(a) is not type(b): return False
    if isinstance(a,list): return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict): return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b


def raw(phase,tag,channel='stdout'): return gzip.decompress((ROOT/BASE/phase/(tag+'-'+channel+'.log.gz')).read_bytes())


def recover(phase):
    result={}
    for row in json.loads((ROOT/BASE/phase/'custody.json').read_bytes()):
        assert row['archive'].startswith(str(BASE/phase)+'/')
        assert row['tag'] not in result
        files={}
        with tarfile.open(ROOT/row['archive']) as archive:
            for member in archive:
                name=PurePosixPath(member.name)
                assert member.isfile() and not name.is_absolute() and '..' not in name.parts
                assert member.name not in files
                expected=row['files'][member.name]
                body=archive.extractfile(member).read()
                assert digest(body)==expected['sha256'] and len(body)==expected['bytes']
                assert member.mode & 0o777==expected['mode']
                files[member.name]=body
        assert files.keys()==row['files'].keys()
        result[row['tag']]=files
    return result


def frames(body,prefix):
    result={}
    for line in body.decode().splitlines():
        match=re.search(r'\b'+re.escape(prefix)+r' ([a-z0-9_]+) (\{.*)',line)
        if match:
            assert match[1] not in result
            result[match[1]]=json.loads(match[2])
    return result


def grammar(body,prefix,expected):
    rows=[json.loads(line.split(prefix+' ',1)[1]) for line in body.decode().splitlines() if prefix+' ' in line]
    assert len(rows)==1 and rows[0]==dict(path=GRAMMAR,source=expected.decode())
    assert body.index(prefix.encode())<body.index(b'HASH_VALUE_DART_INPUT' if prefix=='HASH_VALUE_DART_GRAMMAR' else b'HASH_VALUE_DART_NORMAL ')


def routing(files,config,expected):
    packages=json.loads(files[config])['packages']
    own=next(p for p in packages if p['name']=='linkedspec_dart')
    uri=urlparse(own['rootUri'])
    assert not uri.scheme and not uri.netloc and not uri.path.startswith('/')
    path=posixpath.normpath(str(PurePosixPath(config).parent/unquote(uri.path)))
    assert path==expected and own['packageUri']=='lib/'


def validate(native,fresh,cases,profiles,before=False):
    assert list(native)==list(fresh)==[case['id'] for case in cases]
    for case in cases:
        key=case['id'];assert set(native[key])=={'native','restored','plan'}
        rows={**native[key],'fresh':fresh[key]}
        for route,actual in rows.items():
            if before and key in RED:
                value=[[],'A'] if key.endswith('_array_guard') else ['ran','ADW' if key=='rename_logical_later_with' else 'AW']
                assert same(actual,{'value':value})
            elif key in profiles:
                profile=profiles[key]
                assert case['source']==profile['source'] and case['input']==profile['input']
                assert same(actual,profile[route])
            else: assert same(actual,{'value':case['expected']})
        assert same(rows['native'],rows['restored']) and same(rows['plan'],rows['fresh'])
        if case.get('expected_error'):
            assert all(case['expected_error'] in row['error'] for row in rows.values())
            assert rows['native']['class']=='RuntimeInterpreterException'
            assert rows['plan']['class']=='GeneratedSourceException'


def artifacts(phase,recovered,cases):
    emitted=recovered['emitted'];fresh=recovered['fresh']
    supplied=frames(raw(phase,'native'),'HASH_VALUE_DART_INPUT')
    assert list(supplied)==[case['id'] for case in cases]
    result={}
    for index,case in enumerate(cases):
        module=str(BASE/phase/'fresh/lib'/f'case_{index}.dart')
        parsed=str(BASE/phase/'fresh/inputs'/f'case_{index}.json')
        assert emitted[module]==fresh[module] and emitted[parsed]==fresh[parsed]
        assert json.loads(fresh[parsed])==supplied[case['id']]
        assert f'case_{index}.execute' in fresh[str(BASE/phase/'fresh/bin/main.dart')].decode()
        result[case['id']]=dict(module=fresh[module],parsed=fresh[parsed])
    assert len([p for p in fresh if re.search(r'/lib/case_\d+\.dart$',p)])==len(cases)
    routing(fresh,str(BASE/phase/'fresh/.dart_tool/package_config.json'),'dart')
    return result


def normal(phase,cases,expected,grammar_bytes,before=False,direct=False,body=None):
    assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==('1\n' if before else '0\n')
    if body is None: body=raw(phase,'normal')
    grammar(body,'HASH_VALUE_DART_NORMAL_GRAMMAR',grammar_bytes)
    found=frames(body,'HASH_VALUE_DART_NORMAL')
    assert set(found)=={case['id'] for case in cases}
    assert same(found,expected)
    failures=set(re.findall(r': ([a-z][a-z0-9_]*) \[E\]',body.decode()))
    assert failures==(RED if before else set())
    suffix=b'+76 -13: Some tests failed.' if before else ('+'+str(151 if direct else 89)+': All tests passed!').encode()
    assert suffix in body
    return found


def equal(a,b): assert a==b


def main():
    for name,row in json.loads((ROOT/BASE/'sealed-identities.json').read_bytes()).items():
        path=PurePosixPath(name);assert not path.is_absolute() and '..' not in path.parts
        body=(ROOT/name).read_bytes();assert digest(body)==row['sha256'] and len(body)==row['bytes']
        if name.endswith('.gz'): gzip.decompress(body)
    phases=CANONICAL+('private-inverse','private-restored')
    recovered={phase:recover(phase) for phase in phases}
    roots={phase:recovered[phase]['root'] for phase in phases}
    cases=json.loads(roots['intake'][str(BASE/'cases.json')])
    shared=json.loads(roots['intake'][COMMON])
    authored=json.loads(roots['intake'][str(BASE/'profile-sources.json')])
    profiles=json.loads(roots['before'][PROFILE])
    assert len(shared)==28 and len(authored)==61 and cases==shared+authored and len(profiles)==65
    assert {k for k,v in profiles.items() if v['profile_only']}=={r['id'] for r in authored}
    with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git','archive','--format=tar',ACTIVATION,'dart']))) as archive:
        old={m.name:archive.extractfile(m).read() for m in archive if m.isfile()}
    grammar_bytes=subprocess.check_output(['git','show',ACTIVATION+':'+GRAMMAR])
    shared_bytes=subprocess.check_output(['git','show',ACTIVATION+':'+COMMON])
    for phase in CANONICAL:
        root=roots[phase]
        assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
        assert root[GRAMMAR]==grammar_bytes and root[COMMON]==shared_bytes
        assert root[PROBE]==roots['intake'][PROBE]
        assert root[str(BASE/'capture.py')]==roots['intake'][str(BASE/'capture.py')]
        assert root[str(BASE/'cases.json')]==roots['intake'][str(BASE/'cases.json')]
        if phase in ('intake','before'): assert all(root[p]==body for p,body in old.items())
        else:
            assert {p for p,body in old.items() if root[p]!=body}=={OWNER}
            assert root[OWNER]==roots['after'][OWNER]
        if phase!='intake':
            assert root[NORMAL]==roots['before'][NORMAL] and root[PROFILE]==roots['before'][PROFILE]
        routing(recovered[phase]['resolved'],'dart/.dart_tool/package_config.json','dart')
        for tag in ('version','resolution'):
            assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
            raw(phase,tag);raw(phase,tag,'stderr')
        command=json.loads((ROOT/BASE/phase/'resolution-command.json').read_bytes())
        assert command['cwd']=='dart' and command['argv'][-3:]==['get','--offline','--enforce-lockfile']
    observations={};generated={}
    for phase in ('intake','after-intake'):
        for tag in ('analysis','native','fresh-resolution','fresh-analysis','fresh'):
            assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
            raw(phase,tag);raw(phase,tag,'stderr')
        grammar(raw(phase,'native'),'HASH_VALUE_DART_GRAMMAR',grammar_bytes)
        native=frames(raw(phase,'native'),'HASH_VALUE_DART');fresh=frames(raw(phase,'fresh'),'HASH_VALUE_DART_FRESH')
        validate(native,fresh,cases,profiles,phase=='intake')
        observations[phase]=(native,fresh)
        generated[phase]=artifacts(phase,recovered[phase],cases)
    assert generated['intake']==generated['after-intake']
    before,fresh_before=observations['intake'];after,fresh_after=observations['after-intake']
    for case in cases:
        if case['id'] not in RED:
            assert same(before[case['id']],after[case['id']])
            assert same(fresh_before[case['id']],fresh_after[case['id']])
    for phase,expected,red,direct in (('before',before,True,False),('after',after,False,False),('direct',after,False,True)):
        assert (ROOT/BASE/phase/'analysis-exit.txt').read_text()=='0\n'
        command=json.loads((ROOT/BASE/phase/'analysis-command.json').read_bytes())['argv']
        assert '--fatal-infos' in command and '--fatal-warnings' in command
        normal(phase,cases,expected,grammar_bytes,red,direct)
    prefix=str(BASE/'control-owner')+'/'
    for phase,expected,inverse in (('private-inverse',before,True),('private-restored',after,False)):
        root=roots[phase]
        assert root[OWNER]==roots['after'][OWNER]
        assert root[prefix+OWNER]==(old[OWNER] if inverse else roots['after'][OWNER])
        for name,body in root.items():
            if name.startswith(prefix):
                logical=name[len(prefix):]
                if logical!=OWNER: assert body==roots['after'][logical]
        for tag in ('version','resolution','analysis'): assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
        routing(recovered[phase]['resolved'],prefix+'dart/.dart_tool/package_config.json',str(BASE/'control-owner/dart'))
        command=json.loads((ROOT/BASE/phase/'normal-command.json').read_bytes())
        assert command['cwd']==str(BASE/'control-owner/dart')
        normal(phase,cases,expected,grammar_bytes,inverse)
    assert (ROOT/BASE/'format/format-exit.txt').read_text()=='0\n'
    assert b'(0 changed)' in raw('format','format')
    assert raw('format','format','stderr')==b''
    for tag in ('normal','probe'):
        original=gzip.decompress((ROOT/BASE/('candidate-'+tag+'-before-format.dart.gz')).read_bytes())
        assert original==roots['after'][NORMAL if tag=='normal' else PROBE]
    controls=[]
    def reject(name,operation):
        try: operation()
        except (AssertionError,KeyError): controls.append(name)
        else: raise AssertionError('ineffective corruption '+name)
    changed=copy.deepcopy(before);changed['merge_hash_free_array_guard']=copy.deepcopy(after['merge_hash_free_array_guard'])
    reject('original failure hidden',lambda:validate(changed,fresh_before,cases,profiles,True))
    changed=copy.deepcopy(after);changed['merge_hash_receiver_array_guard']['native']={'value':[None,'A']}
    reject('consumer effect admitted',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(fresh_after);changed['merge_later_with']={'value':['ran','AW']}
    reject('later body admitted',lambda:validate(after,changed,cases,profiles))
    changed=copy.deepcopy(after);changed['needed_source_error_composed']['native']={'value':'masked'}
    reject('required error masked',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(after);changed['initial_number_set_key_free']['native']={'value':{}}
    reject('source fallback normalized',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(after);changed['nested_kinds_and_source']['native']['value'][0]=0
    reject('Bool changed to Number',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(after);del changed['extra_merge_hash_receiver']
    reject('profile omitted',lambda:validate(changed,fresh_after,cases,profiles))
    changed=copy.deepcopy(generated['after-intake']);changed['merge_hash_compatible']['module']+=b'\n// drift\n'
    reject('actual module drift',lambda:equal(generated['intake'],changed))
    assert len(controls)==8
    print(json.dumps(dict(shared=28,own_controls=61,total=89,original_failures=13,preserved=76,four_routes='PASS',direct_tests=151,private_inverse=13,private_restored=89,artifacts=89,recovery='PASS',effective_corruptions=controls),indent=2))


if __name__=='__main__': main()

"""Read-only focused Rust CountKeys RED/GREEN and actual input recovery."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/key-count-guard-rust-2026-11-06')
OWNER='rust/linkedspec-runtime/src/engine.rs'
NORMAL='rust/linkedspec-runtime/tests/key_count_result_guard_composition.rs'
DOMAIN='tests/fixtures/key_count_result_guard_rust_domain.json'
FIXTURES=('tests/fixtures/key_count_result_guard_cases.json',)
ACTIVATION='89a84f415c5a31fc5ecda2b51bbde70d071632a2'
RED={'key_count_free_guard','key_count_receiver_guard','function_guard','copy_guard',
     'logical_guard','seeded_hash','count_contrast','free_keys_count','receiver_keys_count',
     'keys_count_with','keys_count_copy_logical','produced_zero_keys'}


def digest(body): return hashlib.sha256(body).hexdigest()


def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool): return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)): return a==b
    if type(a) is not type(b): return False
    if isinstance(a,list): return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict): return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b


def raw(path):
    path=ROOT/path
    return path.read_bytes() if path.exists() else gzip.decompress(Path(str(path)+'.gz').read_bytes())


def recover(path,expected):
    found={}
    with tarfile.open(ROOT/path) as archive:
        for member in archive.getmembers():
            name=PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert member.name not in found
            body=archive.extractfile(member).read(); item=expected[member.name]
            assert digest(body)==item['sha256'] and len(body)==item['bytes']
            assert member.mode & 0o777 == item['mode']
            found[member.name]=body
    assert found.keys()==expected.keys(), 'declared archive completeness'
    return found


def custody(phase):
    records=json.loads((ROOT/BASE/phase/'custody.json').read_text())
    return {Path(r['archive']).name.split('-before-first-run')[0]: recover(Path(r['archive']),r['files']) for r in records}


def frames(phase,tag,prefix):
    assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
    result={}
    for line in raw(BASE/phase/(tag+'-stdout.log')).decode().splitlines():
        if line.startswith(prefix+' '):
            _,name,body=line.split(' ',2)
            assert name not in result
            result[name]=json.loads(body)
    return result


def target(row,value,domain):
    if row.get('expected_error'):
        return set(value)=={'error'} and row['expected_error'] in value['error']
    expected=row.get('expected',domain['expected'])
    return set(value)=={'value'} and same(value['value'],expected)


def validate(native,fresh,cases,domain,require_targets):
    ids=[r['id'] for r in cases]
    assert list(native)==list(fresh)==ids, 'complete ordered observations'
    for row in cases:
        n=native[row['id']]; f=fresh[row['id']]
        assert set(n)=={'native','restored','plan'}
        routes=[n[k] for k in ('native','restored','plan')]+[f]
        if row.get('expected_error'):
            assert all(target(row,v,domain) for v in routes)
            assert same(routes[0],routes[1]) and same(routes[2],routes[3])
            assert routes[2]['error']=='Generated Rust parser execution failed: '+routes[0]['error'], 'error wrapper profile'
        else:
            assert all(same(routes[0],v) for v in routes), 'value route agreement'
        if require_targets:
            assert all(target(row,v,domain) for v in routes), 'target value/kind/effects'


def apply_patch(before, patch):
    lines = patch.decode().splitlines(keepends=True)
    assert lines[:4] == [f'diff --git a/{OWNER} b/{OWNER}\n', lines[1], f'--- a/{OWNER}\n', f'+++ b/{OWNER}\n']
    assert re.fullmatch(r'index [0-9a-f]{40}\.\.[0-9a-f]{40} 100644\n', lines[1])
    original = before.decode().splitlines(keepends=True)
    result = []
    cursor = 0
    index = 4
    while index < len(lines):
        match = re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@', lines[index])
        assert match, 'retained single-owner unified diff'
        start = int(match[1]) - 1
        assert cursor <= start
        result.extend(original[cursor:start]); cursor = start
        old_count = new_count = 0
        index += 1
        while index < len(lines) and not lines[index].startswith('@@ '):
            line = lines[index]; index += 1
            assert line[0] in ' +-'
            if line[0] in ' -':
                assert original[cursor] == line[1:]
                cursor += 1; old_count += 1
            if line[0] in ' +':
                result.append(line[1:]); new_count += 1
        assert old_count == int(match[2] or 1) and new_count == int(match[4] or 1)
    result.extend(original[cursor:])
    return ''.join(result).encode()


def source_boundary(before, after):
    assert before == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER]), 'actual historical Git source'
    assert apply_patch(before, (BASE / 'producer-change.patch').read_bytes()) == after



def check_modules(actual, expected):
    assert actual.keys()==expected.keys(), 'complete actual emitted modules'
    assert actual==expected, 'emitted module bodies are unchanged'


def main():
    phases=('probe-before','normal-before','probe-after','normal-after','nearest')
    recovered={phase:custody(phase) for phase in phases}
    before=recovered['normal-before']['root'];after=recovered['normal-after']['root']
    assert before.keys()==after.keys()
    assert [p for p in before if before[p]!=after[p]]==[OWNER]
    source_boundary(before[OWNER],after[OWNER])
    assert recovered['probe-before']['root'][OWNER]==before[OWNER]
    assert recovered['probe-after']['root'][OWNER]==after[OWNER]==recovered['nearest']['root'][OWNER]
    assert all(recovered[p]['root'][NORMAL]==before[NORMAL] for p in phases[1:])
    for phase in phases:
        assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
        for name in ('capture.py','observer.rs'):
            assert recovered[phase]['root'][str(BASE/name)]==(ROOT/BASE/name).read_bytes()
        for path in FIXTURES:
            assert recovered[phase]['root'][path]==before[path]
    assert before[FIXTURES[0]]==subprocess.check_output(['git','show',ACTIVATION+':'+FIXTURES[0]])
    cases=json.loads(before[FIXTURES[0]]);assert len(cases)==22
    domain=json.loads(before[DOMAIN]);assert domain['id']=='source_domain'
    assert domain['source']==next(r['source'] for r in cases if r['id']==domain['id'])
    assert domain['expected']==[0,0,0,0,0,0,2,0,0,0,0,0,0,2]
    for phase in phases[1:]:
        assert recovered[phase]['root'][DOMAIN]==before[DOMAIN]
    observations={};modules={};serialized={}
    for phase in ('probe-before','probe-after'):
        c=recovered[phase]
        assert json.loads(c['native'][str(BASE/phase/'cases.json')])==cases
        assert c['native'][str(BASE/phase/'native/src/main.rs')]==c['root'][str(BASE/'observer.rs')]
        n=frames(phase,'native','KEY_COUNT_RUST');f=frames(phase,'fresh','KEY_COUNT_RUST_FRESH')
        inputs=frames(phase,'native','KEY_COUNT_RUST_INPUT')
        validate(n,f,cases,domain,phase=='probe-after')
        assert list(inputs)==[r['id'] for r in cases]
        serialized[phase]={}
        for row in cases:
            body=c['fresh'][str(BASE/phase/'fresh/inputs'/(row['id']+'.json'))]
            assert body.decode()==inputs[row['id']]['compiled'], 'actual serialized input before native/restored/plan/module execution'
            serialized[phase][row['id']]=body
        modules[phase]={p.split('/src/generated/')[1]:body for p,body in c['fresh'].items() if '/src/generated/' in p}
        assert set(modules[phase])=={row['id']+'.rs' for row in cases}
        observations[phase]=(n,f)
    check_modules(modules['probe-after'],modules['probe-before'])
    assert serialized['probe-before']==serialized['probe-after']
    bn,bf=observations['probe-before'];an,af=observations['probe-after']
    assert {r['id'] for r in cases if not target(r,bn[r['id']]['native'],domain)}==RED
    assert same(bn[domain['id']]['native'],{'value':domain['expected']})
    for row in cases:
        if row['id'] not in RED:
            assert same(bn[row['id']],an[row['id']]) and same(bf[row['id']],af[row['id']]), 'healthy observations exact'
    for phase in ('normal-before','normal-after'):
        stdout=raw(BASE/phase/'normal-stdout.log').decode()
        tests=re.findall(r'^test (\w+) \.\.\. (ok|FAILED)$',stdout,re.M)
        assert len(tests)==22 and {name for name,_ in tests}=={r['id'] for r in cases}
        assert {name for name,state in tests if state=='FAILED'}==(RED if phase=='normal-before' else set())
        assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==('101\n' if phase=='normal-before' else '0\n')
    assert (ROOT/BASE/'nearest/normal-exit.txt').read_text()=='0\n'
    assert re.findall(r'test result: ok\. (\d+) passed; 0 failed;',raw(BASE/'nearest/normal-stdout.log').decode())==['1','19','24']
    for phase in ('normal-after','nearest'):
        assert not re.search(r'^warning: `linkedspec-(?:core|runtime)`.*generated',raw(BASE/phase/'normal-stderr.log').decode(),re.M)
    sealed=json.loads((ROOT/BASE/'raw-identities.json').read_text())
    assert len(sealed)==32
    for path,item in sealed.items():
        capsule=(ROOT/item['capsule']).read_bytes();body=gzip.decompress(capsule)
        assert digest(capsule)==item['capsule_sha256'] and digest(body)==item['sha256'] and len(body)==item['bytes']
        assert body==raw(Path(path))
    rejected=[]
    def rejects(name,operation):
        try:operation()
        except (AssertionError,KeyError,ValueError):rejected.append(name)
        else:raise AssertionError('ineffective control '+name)
    n=copy.deepcopy(an);n.pop('source_domain')
    rejects('missing-row',lambda:validate(n,af,cases,domain,True))
    n=copy.deepcopy(an);n['source_domain']['native']['value'][0]=False
    rejects('false-as-number',lambda:validate(n,af,cases,domain,True))
    n=copy.deepcopy(an);n['needed_source_error']['plan']['error']=n['needed_source_error']['native']['error']
    rejects('error-wrapper-drift',lambda:validate(n,af,cases,domain,True))
    n=copy.deepcopy(an);n['key_count_receiver_guard']['native']['value'][1]='SAW'
    rejects('post-rejection-effect',lambda:validate(n,af,cases,domain,True))
    changed=dict(modules['probe-after']);changed['source_domain.rs']+=b'\n'
    rejects('changed-module',lambda:check_modules(changed,modules['probe-before']))
    rejects('forged-source-boundary',lambda:source_boundary(before[OWNER]+b'\n',after[OWNER]))
    print(json.dumps(dict(before='10PASS/12RED',after='22PASS/four routes',healthy_exact=10,emitted_modules_unchanged=22,serialized_inputs_unchanged=22,nearest='44PASS; final66',rejected_controls=rejected,result='PASS'),sort_keys=True))


if __name__=='__main__':main()

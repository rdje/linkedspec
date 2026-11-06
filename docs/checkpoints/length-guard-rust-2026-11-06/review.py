"""Read-only focused Rust Length RED/GREEN and actual input recovery."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import tarfile

ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/length-guard-rust-2026-11-06')
OWNER='rust/linkedspec-runtime/src/engine.rs'
NORMAL='rust/linkedspec-runtime/tests/length_result_guard_composition.rs'
DOMAIN='tests/fixtures/length_result_guard_rust_domain.json'
FIXTURES=('tests/fixtures/length_result_guard_cases.json','tests/fixtures/length_count_source_ownership_cases.json')
RED={'length_free_guard','length_receiver_guard','function_guard','copy_guard','logical_guard',
     'seeded_hash','count_contrast','free_length_count','receiver_length_count','length_count_with',
     'length_count_copy_logical','produced_null_zero_count'}


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


def main():
    sealed=json.loads((ROOT/BASE/'raw-identities.json').read_text())
    for path,item in sealed.items():
        capsule=(ROOT/item['capsule']).read_bytes()
        assert digest(capsule)==item['capsule_sha256']
        body=gzip.decompress(capsule)
        assert digest(body)==item['sha256'] and len(body)==item['bytes']
        assert body==raw(Path(path))
    phases=('probe-before','normal-before','normal-after','probe-after')
    recovered={p:custody(p) for p in phases}
    final_ids=json.loads((ROOT/BASE/'final/input-identities.json').read_text())
    final=recover(BASE/'final/inputs-before-first-run.tar.gz',final_ids)
    before=recovered['normal-before']['root']; after=recovered['normal-after']['root']
    assert before.keys()==after.keys()
    assert [p for p in before if before[p]!=after[p]]==[OWNER], 'only engine changes during semantic proof'
    assert after[OWNER]==final[OWNER]==(ROOT/OWNER).read_bytes()
    assert after[NORMAL].count(b'use serde_json::{Value, json};')==1
    assert after[NORMAL].replace(b'use serde_json::{Value, json};',b'use serde_json::Value;')==final[NORMAL]==(ROOT/NORMAL).read_bytes(), 'only unused import removed'
    assert final[str(BASE/'cleanup.py')]==(ROOT/BASE/'cleanup.py').read_bytes()
    for phase in phases:
        assert recovered[phase]['root'][str(BASE/'capture.py')]==(ROOT/BASE/'capture.py').read_bytes()
        assert recovered[phase]['root'][str(BASE/'observer.rs')]==(ROOT/BASE/'observer.rs').read_bytes()
    cases=[]
    for path in FIXTURES:
        assert before[path]==after[path]==final[path]==(ROOT/path).read_bytes()
        cases.extend(json.loads(before[path]))
    assert before[DOMAIN]==after[DOMAIN]==final[DOMAIN]==(ROOT/DOMAIN).read_bytes()
    domain=json.loads(before[DOMAIN])
    named=next(r for r in cases if r['id']==domain['id'])
    assert domain['source']==named['source']
    observations={}; modules={}
    for phase in ('probe-before','probe-after'):
        c=recovered[phase]
        assert json.loads(c['native'][str(BASE/phase/'cases.json')])==cases
        assert c['native'][str(BASE/phase/'native/src/main.rs')]==c['root'][str(BASE/'observer.rs')]
        n=frames(phase,'native','LENGTH_RUST'); f=frames(phase,'fresh','LENGTH_RUST_FRESH')
        inputs=frames(phase,'native','LENGTH_RUST_INPUT')
        validate(n,f,cases,domain,phase=='probe-after')
        assert list(inputs)==[r['id'] for r in cases]
        for row in cases:
            actual=c['fresh'][str(BASE/phase/'fresh/inputs'/(row['id']+'.json'))]
            assert actual.decode()==inputs[row['id']]['compiled'], 'actual serialized IR input'
        modules[phase]={p.split('/src/generated/')[1]:body for p,body in c['fresh'].items() if '/src/generated/' in p}
        assert set(modules[phase])=={r['id']+'.rs' for r in cases}
        observations[phase]=(n,f)
    assert modules['probe-before']==modules['probe-after'], 'actual emitted module bodies unchanged'
    bn,bf=observations['probe-before']; an,af=observations['probe-after']
    assert {r['id'] for r in cases if not target(r,bn[r['id']]['native'],domain)}==RED
    assert same(bn[domain['id']]['native'],{'value':domain['expected']})
    for row in cases:
        if row['id'] not in RED:
            assert same(bn[row['id']],an[row['id']]) and same(bf[row['id']],af[row['id']]), 'healthy observation changed'
    for phase in ('normal-before','normal-after'):
        stdout=raw(BASE/phase/'normal-stdout.log').decode()
        tests=re.findall(r'^test (\w+) \.\.\. (ok|FAILED)$',stdout,re.M)
        assert len(tests)==24 and {t[0] for t in tests}=={r['id'] for r in cases}
        assert {name for name,state in tests if state=='FAILED'}==(RED if phase=='normal-before' else set())
        assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==('101\n' if phase=='normal-before' else '0\n')
    assert b'warning: unused import: `json`' in raw(BASE/'normal-after/normal-stderr.log')
    assert (ROOT/BASE/'final/exit.txt').read_text()=='0\n'
    stdout=raw(BASE/'final/stdout.log').decode(); stderr=raw(BASE/'final/stderr.log').decode()
    assert re.findall(r'test result: ok\. (\d+) passed; 0 failed;',stdout)==['1','19','24']
    assert not re.search(r'^warning: `linkedspec-(?:core|runtime)`.*generated',stderr,re.M)
    assert (ROOT/BASE/'format-final-exit.txt').read_text()=='0\n'
    assert raw(BASE/'format-final-stdout.log')==raw(BASE/'format-final-stderr.log')==b''
    rejected=[]
    for name in ('missing-row','false-as-number','error-wrapper-drift','missing-domain-input','changed-module'):
        n=copy.deepcopy(an)
        try:
            if name=='missing-row': n.pop(next(iter(n)))
            elif name=='false-as-number': n['logical_valid_null_zero']['native']['value'][0]=0
            elif name=='error-wrapper-drift': n['needed_source_error']['plan']['error']='extra:'+n['needed_source_error']['plan']['error']
            elif name=='missing-domain-input':
                broken=dict(final); broken.pop(DOMAIN)
                assert DOMAIN in broken, 'required direct fixture missing'
            else:
                module=next(iter(modules['probe-after'].values()))
                assert digest(module+b'changed')==digest(module), 'changed actual module'
            validate(n,af,cases,domain,True)
        except AssertionError: rejected.append(name)
        else: raise AssertionError('ineffective corruption '+name)
    print(json.dumps(dict(result='PASS',original='12PASS12RED',final='24PASS',unchanged_healthy=12,
        final_focused_groups=44,emitted_modules_identical=24,rejected_controls=rejected,
        limits='Finite authored native/restored/plan/compiled emitted controls. Final normal removes only one unused import; all first epochs and raw warning-bearing channels survive losslessly. Declared own/root/native/fresh Cargo inputs are recoverable; complete native/transitive closure, upstream warning census, general isolation, registration and full admission remain separately owned.'),sort_keys=True))


if __name__=='__main__': main()

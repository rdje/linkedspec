"""Read-only Dart Length RED/GREEN and declared actual input recovery."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import tarfile

ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/length-guard-dart-2026-11-06')
OWNER='dart/lib/src/runtime/interpreter.dart'
NORMAL='dart/test/length_result_guard_composition_test.dart'
PROBE='dart/tool/probe_length_result_guards.dart'
DOMAIN='tests/fixtures/length_result_guard_dart_domain.json'
FIXTURES=('tests/fixtures/length_result_guard_cases.json','tests/fixtures/length_count_source_ownership_cases.json')
RED={'length_free_guard','length_receiver_guard','function_guard','copy_guard','logical_guard','seeded_hash',
     'count_contrast','free_length_count','receiver_length_count','length_count_with',
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


def recover(record):
    found={}
    with tarfile.open(ROOT/record['archive']) as archive:
        for member in archive.getmembers():
            name=PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts
            assert member.name not in found
            body=archive.extractfile(member).read(); item=record['files'][member.name]
            assert digest(body)==item['sha256'] and len(body)==item['bytes']
            assert member.mode & 0o777 == item['mode']
            found[member.name]=body
    assert found.keys()==record['files'].keys(), 'complete declared input archive'
    return found


def custody(phase):
    records=json.loads((ROOT/BASE/phase/'custody.json').read_text())
    return {Path(r['archive']).name.split('-before-first-run')[0]:recover(r) for r in records}


def frames(phase,tag,prefix):
    rows={}
    for line in raw(BASE/phase/(tag+'-stdout.log')).decode().splitlines():
        if line.startswith(prefix+' '):
            _,identifier,body=line.split(' ',2)
            assert identifier not in rows
            rows[identifier]=json.loads(body)
    return rows


def target(row,value,domain):
    if row.get('expected_error'):
        return isinstance(value.get('error'),str) and row['expected_error'] in value['error']
    return set(value)=={'value'} and same(value['value'],row.get('expected',domain['expected']))


def validate(native,fresh,cases,domain,require_targets):
    assert list(native)==list(fresh)==[r['id'] for r in cases], 'complete ordered case observations'
    for row in cases:
        n=native[row['id']];f=fresh[row['id']]
        assert set(n)=={'native','restored','plan'}
        routes=[n[k] for k in ('native','restored','plan')]+[f]
        if row.get('expected_error'):
            assert all(target(row,v,domain) for v in routes)
            assert same(routes[0],routes[1]) and same(routes[2],routes[3]), 'error route profiles'
            assert routes[0]['class']=='RuntimeInterpreterException'
            assert routes[0]['diagnostic']['stage']=='runtime_execution'
            assert routes[2]['class']=='GeneratedSourceException'
            assert routes[2]['error']=='Generated Dart parser execution failed: '+routes[0]['error']
        else:
            assert all(same(routes[0],v) for v in routes), 'value/kind route agreement'
        if require_targets: assert all(target(row,v,domain) for v in routes), 'target value/kind/effects'


def normal_rows(phase):
    values=frames(phase,'normal','LENGTH_GUARD_DART_VALUE')
    errors=frames(phase,'normal','LENGTH_GUARD_DART_ERROR')
    assert not values.keys() & errors.keys()
    for identifier,routes in values.items():
        assert set(routes)=={'native','restored','plan'}
        for value in routes.values(): assert set(value)=={'ok'}, 'normal execution error'
        values[identifier]={route:{'value':value['ok']} for route,value in routes.items()}
    return {**values,**errors}


def main():
    sealed=json.loads((ROOT/BASE/'raw-identities.json').read_text())
    for path,item in sealed.items():
        capsule=(ROOT/item['capsule']).read_bytes();body=gzip.decompress(capsule)
        assert digest(capsule)==item['capsule_sha256']
        assert digest(body)==item['sha256'] and len(body)==item['bytes'] and body==raw(Path(path))
    phases=('probe-before','normal-before','normal-after','probe-after','final')
    recovered={p:custody(p) for p in phases}
    before=recovered['normal-before']['root'];after=recovered['normal-after']['root'];final=recovered['final']['root']
    assert before.keys()==after.keys()
    assert [p for p in before if before[p]!=after[p]]==[OWNER], 'only runtime owner changes'
    assert after[OWNER]==final[OWNER]==(ROOT/OWNER).read_bytes()
    assert before[NORMAL]==after[NORMAL]==final[NORMAL]==(ROOT/NORMAL).read_bytes()
    assert all(recovered[p]['root'][str(BASE/'capture.py')]==(ROOT/BASE/'capture.py').read_bytes() for p in phases)
    assert all(recovered[p]['root'][PROBE]==(ROOT/PROBE).read_bytes() for p in phases)
    source=after[OWNER].decode();start=source.index('  // Length keeps scalar/Array sources')
    end=source.index('  // Canonical index sources',start)
    retained=source[:start]+source[end:]
    line='            _isOrdinaryLengthResultChain(receiver, calls) ||\n'
    assert retained.count(line)==1
    assert retained.replace(line,'').encode()==before[OWNER], 'outside-member and source-admission bytes exact'
    cases=[]
    for path in FIXTURES:
        assert before[path]==after[path]==final[path]==(ROOT/path).read_bytes()
        cases.extend(json.loads(before[path]))
    assert before[DOMAIN]==after[DOMAIN]==final[DOMAIN]==(ROOT/DOMAIN).read_bytes()
    domain=json.loads(before[DOMAIN]);named=next(r for r in cases if r['id']==domain['id'])
    assert domain['source']==named['source']
    observations={};modules={}
    for phase in ('probe-before','probe-after'):
        root=recovered[phase]['root'];fresh_inputs=recovered[phase]['fresh']
        assert json.loads(root[str(BASE/phase/'cases.json')])==cases
        n=frames(phase,'native','LENGTH_DART');f=frames(phase,'fresh','LENGTH_DART_FRESH')
        inputs=frames(phase,'native','LENGTH_DART_INPUT')
        validate(n,f,cases,domain,phase=='probe-after')
        assert list(inputs)==[r['id'] for r in cases]
        for index,row in enumerate(cases):
            value=json.loads(fresh_inputs[str(BASE/phase/'fresh/inputs'/f'case_{index}.json')])
            assert same(value,inputs[row['id']]), 'actual serialized parsed input'
        modules[phase]={p.split('/fresh/lib/')[1]:body for p,body in fresh_inputs.items() if '/fresh/lib/' in p}
        assert set(modules[phase])=={f'case_{i}.dart' for i in range(24)}
        for tag in ('root-analysis','native','fresh-analysis','fresh'):
            assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
        observations[phase]=(n,f)
    assert modules['probe-before']==modules['probe-after'], 'actual module bodies unchanged'
    bn,bf=observations['probe-before'];an,af=observations['probe-after']
    assert {r['id'] for r in cases if not target(r,bn[r['id']]['native'],domain)}==RED
    assert same(bn[domain['id']]['native'],{'value':domain['expected']})
    for row in cases:
        if row['id'] not in RED:
            assert same(bn[row['id']],an[row['id']]) and same(bf[row['id']],af[row['id']]), 'healthy observation changed'
    for phase in ('normal-before','normal-after','final'):
        rows=normal_rows(phase)
        assert set(rows)=={r['id'] for r in cases}
        mismatch={r['id'] for r in cases if not all(target(r,v,domain) for v in rows[r['id']].values())}
        assert mismatch==(RED if phase=='normal-before' else set())
        assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==('1\n' if phase=='normal-before' else '0\n')
        assert (ROOT/BASE/phase/'root-analysis-exit.txt').read_text()=='0\n'
    assert '+45: All tests passed!' in raw(BASE/'final/normal-stdout.log').decode()
    assert (ROOT/BASE/'format-exit.txt').read_text()=='0\n'
    assert b'(0 changed)' in raw(BASE/'format-stdout.log') and raw(BASE/'format-stderr.log')==b''
    rejected=[]
    for control in ('missing-row','false-as-number','error-class-drift','missing-domain-input','changed-module'):
        n=copy.deepcopy(an)
        try:
            if control=='missing-row': n.pop(next(iter(n)))
            elif control=='false-as-number': n['logical_valid_null_zero']['native']['value'][0]=0
            elif control=='error-class-drift': n['needed_source_error']['plan']['class']='wrong'
            elif control=='missing-domain-input':
                broken=dict(final);broken.pop(DOMAIN)
                assert DOMAIN in broken, 'direct fixture omission'
            else:
                module=next(iter(modules['probe-after'].values()))
                assert digest(module+b'changed')==digest(module), 'actual module byte mutation'
            validate(n,af,cases,domain,True)
        except AssertionError: rejected.append(control)
        else: raise AssertionError('ineffective control '+control)
    print(json.dumps(dict(result='PASS',original='12PASS12RED',final='24PASS',unchanged_healthy=12,
        final_focused_groups=45,emitted_modules_identical=24,rejected_controls=rejected,
        limits='Finite authored native/restored/plan/fresh emitted controls and declared direct source/pub/lock/config/module/parsed-input recovery. Full native/transitive closure, general isolation, canonical selection, peers and full admission remain separately owned. Raw channels losslessly sealed without filtering.'),sort_keys=True))


if __name__=='__main__': main()

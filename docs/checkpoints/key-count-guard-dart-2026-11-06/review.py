"""Read-only Dart CountKeys RED/GREEN and declared actual input recovery."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/key-count-guard-dart-2026-11-06')
OWNER='dart/lib/src/runtime/interpreter.dart'
NORMAL='dart/test/key_count_result_guard_composition_test.dart'
PROBE='dart/tool/probe_key_count_result_guards.dart'
DOMAIN='tests/fixtures/key_count_result_guard_dart_domain.json'
FIXTURES=('tests/fixtures/key_count_result_guard_cases.json',)
ACTIVATION='f47bd4c35c7de86df044ea301d308c22c5f67a7f'
RED={'key_count_free_guard','key_count_receiver_guard','function_guard','copy_guard','logical_guard','seeded_hash',
     'count_contrast','free_keys_count','receiver_keys_count','keys_count_with',
     'keys_count_copy_logical','produced_zero_keys'}


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
    values=frames(phase,'normal','KEY_COUNT_GUARD_DART_VALUE')
    errors=frames(phase,'normal','KEY_COUNT_GUARD_DART_ERROR')
    assert not values.keys() & errors.keys()
    for identifier,routes in values.items():
        assert set(routes)=={'native','restored','plan'}
        for value in routes.values(): assert set(value)=={'ok'}, 'normal execution error'
        values[identifier]={route:{'value':value['ok']} for route,value in routes.items()}
    return {**values,**errors}


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


def check_modules(actual,expected):
    assert actual.keys()==expected.keys(), 'complete actual emitted module set'
    assert actual==expected, 'actual emitted module bodies unchanged'


def main():
    phases=('probe-before','normal-before','probe-after','normal-after','final')
    recovered={p:custody(p) for p in phases}
    before=recovered['normal-before']['root'];after=recovered['normal-after']['root'];final=recovered['final']['root']
    assert before.keys()==after.keys()
    assert [p for p in before if before[p]!=after[p]]==[OWNER]
    source_boundary(before[OWNER],after[OWNER])
    assert recovered['probe-before']['root'][OWNER]==before[OWNER]
    assert recovered['probe-after']['root'][OWNER]==after[OWNER]==final[OWNER]
    assert before[NORMAL]==after[NORMAL]==final[NORMAL]
    for phase in phases:
        root=recovered[phase]['root']
        assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
        assert root[str(BASE/'capture.py')]==(ROOT/BASE/'capture.py').read_bytes()
        assert root[PROBE]==before[PROBE]
        for name in FIXTURES:assert root[name]==before[name]
    assert before[FIXTURES[0]]==subprocess.check_output(['git','show',ACTIVATION+':'+FIXTURES[0]])
    cases=json.loads(before[FIXTURES[0]]);assert len(cases)==22
    domain=json.loads(before[DOMAIN]);assert domain['id']=='source_domain'
    assert domain['source']==next(r['source'] for r in cases if r['id']==domain['id'])
    assert same(domain['expected'],[0,0,0,0,0,0,2,0,0,None,0,0,0,2])
    for phase in phases[1:]:assert recovered[phase]['root'][DOMAIN]==before[DOMAIN]
    observations={};modules={};parsed={}
    for phase in ('probe-before','probe-after'):
        c=recovered[phase]
        assert json.loads(c['root'][str(BASE/phase/'cases.json')])==cases
        n=frames(phase,'native','KEY_COUNT_DART');f=frames(phase,'fresh','KEY_COUNT_DART_FRESH');inputs=frames(phase,'native','KEY_COUNT_DART_INPUT')
        validate(n,f,cases,domain,phase=='probe-after')
        assert list(inputs)==[r['id'] for r in cases]
        modules[phase]={};parsed[phase]={}
        for index,row in enumerate(cases):
            data=c['fresh'][str(BASE/phase/'fresh/inputs'/f'case_{index}.json')]
            assert same(json.loads(data),inputs[row['id']]), 'actual parsed input before execution'
            parsed[phase][row['id']]=data
            modules[phase][row['id']]=c['fresh'][str(BASE/phase/'fresh/lib'/f'case_{index}.dart')]
        observations[phase]=(n,f)
    check_modules(modules['probe-after'],modules['probe-before'])
    assert parsed['probe-before']==parsed['probe-after']
    bn,bf=observations['probe-before'];an,af=observations['probe-after']
    assert {r['id'] for r in cases if not target(r,bn[r['id']]['native'],domain)}==RED
    assert same(bn['source_domain']['native'],{'value':domain['expected']})
    for row in cases:
        if row['id'] not in RED:
            assert same(bn[row['id']],an[row['id']]) and same(bf[row['id']],af[row['id']]), 'healthy observation/diagnostic profile changed'
    for phase in ('normal-before','normal-after'):
        rows=normal_rows(phase)
        assert set(rows)=={r['id'] for r in cases}
        assert {r['id'] for r in cases if not all(target(r,value,domain) for value in rows[r['id']].values())}==(RED if phase=='normal-before' else set())
        assert (ROOT/BASE/phase/'normal-exit.txt').read_text()==('1\n' if phase=='normal-before' else '0\n')
    assert (ROOT/BASE/'final/normal-exit.txt').read_text()=='0\n'
    assert 'All tests passed!' in raw(BASE/'final/normal-stdout.log').decode()
    assert len(re.findall(r'^\d\d:\d\d \+\d+:',raw(BASE/'final/normal-stdout.log').decode(),re.M))>=67
    for phase in phases:
        for tag in (('root-analysis','fresh-analysis') if phase.startswith('probe-') else ('root-analysis',)):
            assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
    sealed=json.loads((ROOT/BASE/'raw-identities.json').read_text());assert len(sealed)==52
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
    n=copy.deepcopy(an);n['source_domain']['native']['value'][9]=0
    rejects('Boolean-receiver-normalization',lambda:validate(n,af,cases,domain,True))
    n=copy.deepcopy(an);n['needed_source_error']['plan']['error']=n['needed_source_error']['native']['error']
    rejects('error-wrapper-drift',lambda:validate(n,af,cases,domain,True))
    changed=dict(modules['probe-after']);changed['source_domain']+=b'\n'
    rejects('changed-module',lambda:check_modules(changed,modules['probe-before']))
    rejects('forged-source-boundary',lambda:source_boundary(before[OWNER]+b'\n',after[OWNER]))
    print(json.dumps(dict(before='10PASS/12RED',after='22PASS/four routes',healthy_exact=10,emitted_modules_unchanged=22,parsed_inputs_unchanged=22,final='67PASS',Boolean_receiver_profile='null preserved',rejected_controls=rejected,result='PASS'),sort_keys=True))


if __name__=='__main__':main()

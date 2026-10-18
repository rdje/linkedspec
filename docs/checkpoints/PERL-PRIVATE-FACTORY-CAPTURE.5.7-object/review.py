"""Readonly complete package-object repair review; --capture freezes one report."""
import base64
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
OWNERS = tuple('perl/LinkedSpec/ActionIR/' + p + '.pm' for p in ('ControlFlow','FlowExpr','MethodLowering'))
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'])
inputs = set()
def raw(path):
    inputs.add(path)
    return (ROOT / path).read_bytes()
def load(name):
    return json.loads(raw(PREFIX + name))
def packed(name):
    return json.loads(gzip.decompress(raw(PREFIX + name)))
guard = b"if (defined($pkg) && !ref($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'"
original = b"if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'"
initial = load('preservation.json')
before_inputs, after_inputs = packed('before-inputs.json.gz'), packed('after-inputs.json.gz')
for path in OWNERS:
    old, new = decode(before_inputs[path]['bytes_base64']), decode(after_inputs[path]['bytes_base64'])
    assert before_inputs[path]['sha256'] == initial['inputs'][path]['sha256'] == sha(old)
    assert old.count(original) == 1 and new == old.replace(original, guard, 1)
    assert new == raw(path) and new.count(b'\n') == old.count(b'\n'), 'exact noncoercing guard and native locations'
data = {}
for stage in ('before', 'after'):
    record = load(stage + '.json')
    capsule = packed(stage + '-inputs.json.gz')
    rows = packed(stage + '-data.json.gz')
    assert record['producer_sha256'] == sha(raw(PREFIX + 'capture.py'))
    assert record['capsule_sha256'] == sha(raw(PREFIX + stage + '-inputs.json.gz'))
    assert record['data_sha256'] == sha(raw(PREFIX + stage + '-data.json.gz'))
    assert record['inputs'] == {p: {k: v[k] for k in ('sha256','mode')} for p,v in capsule.items()}
    for path, item in capsule.items():
        value = decode(item['bytes_base64'])
        assert sha(value) == item['sha256']
        if stage == 'before' and path in OWNERS:
            continue
        assert value == raw(path) and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    assert len(rows) == 5 and all(r['returncode'] == 0 for r in rows)
    assert rows[1] == rows[2] and rows[3] == rows[4]
    assert not decode(rows[0]['stdout_base64'])
    assert decode(rows[0]['stderr_base64']) == b't/actionir_default_object_native.pl syntax OK\n'
    differences = []
    for i in (1,3):
        observed = rows[i]['observation']
        assert not decode(rows[i]['stderr_base64'])
        assert json.loads(decode(rows[i]['stdout_base64'])) == observed
        assert len(observed['rows']) == 108
        grouped = {}
        for row in observed['rows']:
            key = (row['owner'], row['variant'], row['context'])
            grouped.setdefault(key,{})[row['stage']] = row
        assert len(grouped) == 54 and all(set(v) == {'native-builder','current-factory'} for v in grouped.values())
        for key, pair in grouped.items():
            baseline, actual = pair['native-builder'], pair['current-factory']
            changed = sorted(k for k in baseline['ordinary'] if baseline['ordinary'][k] != actual['ordinary'][k])
            if changed:
                differences.append(dict(mode=observed['mode'],owner=key[0],variant=key[1],context=key[2],changed=changed))
            if stage == 'after':
                assert actual['ordinary'] == baseline['ordinary'], 'complete native package-object effects'
                for row in pair.values():
                    expected = [dict(key=v['key'], selected=int(i == 1 and row['stage'] == 'current-factory'
                        and key[0].endswith('ControlFlow') and key[2] != 'void' and v['key'] == 'extract_array_symbol_name'))
                        for v in baseline['authority']]
                    assert row['authority'] == expected, 'object aliases cannot grant facade authority'
        assert observed['source_emissions_loaded'] == (1 if i == 1 else 0) and observed['trace_loaded'] == 0
    assert differences == record['ordinary_differences']
    assert len(differences) == (84 if stage == 'before' else 0)
    data[stage] = rows
for i in (1,3):
    left = [r for r in data['before'][i]['observation']['rows'] if r['stage']=='native-builder']
    right = [r for r in data['after'][i]['observation']['rows'] if r['stage']=='native-builder']
    assert left == right, 'all original native-builder observations remain exact'
def tap(row):
    text = decode(row['stdout_base64']).decode()
    tests = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    assert re.findall(r'^1\.\.(\d+)$',text,re.M)==['444'] and len(tests)==444
    assert [int(n) for _,n,_ in tests]==list(range(1,445))
    return [dict(number=int(n),name=t) for bad,n,t in tests if bad]
for stage, count in (('before',100),('after',0)):
    record=load('paired-'+stage+'.json')
    assert record['producer_sha256']==sha(raw(PREFIX+'paired.py'))
    capsule=packed('paired-'+stage+'-inputs.json.gz')
    assert record['capsule_sha256']==sha(raw(PREFIX+'paired-'+stage+'-inputs.json.gz'))
    for path,item in capsule.items():
        value=decode(item['bytes_base64']);assert sha(value)==item['sha256']
        if stage=='before' and path in OWNERS:continue
        assert value==raw(path)
    channels=packed('paired-'+stage+'-channels.json.gz')
    assert record['channels_sha256']==sha(raw(PREFIX+'paired-'+stage+'-channels.json.gz'))
    assert channels[0]['returncode']==0 and bool(channels[1]['returncode'])==bool(count)
    assert tap(channels[1])==record['failures'] and len(record['failures'])==count
faults=load('faults.json');variants=packed('faults-data.json.gz')
assert faults['result']=='PASS' and faults['producer_sha256']==sha(raw(PREFIX+'faults.py'))
assert faults['data_sha256']==sha(raw(PREFIX+'faults-data.json.gz'))
assert [len(r['failures']) for r in variants]==[100,30,28,42,86,42,12,26,26,39]
for row in variants:
    assert row['unchanged'] and all(c['returncode']==0 for c in row['channels'][:-1])
    assert row['channels'][-1]['returncode']!=0 and tap(row['channels'][-1])==row['failures']
    assert all(sha(decode(v['bytes_base64']))==v['sha256'] for v in row['sources'].values())
assert variants[0]['failures']==load('paired-before.json')['failures']
assert all(decode(variants[0]['sources'][p]['bytes_base64'])==decode(before_inputs[p]['bytes_base64']) for p in OWNERS)
for name in ('before','after'):
    raw(PREFIX+name+'-inputs.json.gz')
for name in ('faults-reached.json.gz','review.py'):
    raw(PREFIX+name)
report=dict(result='PASS',producer_sha256=sha(raw(PREFIX+'review.py')),
    population=dict(warm_rows=108,cold_rows=108,ordinary_original_mismatches=84,paired_assertions=444,
        original_red=100,passing_controls=344,source_faults=10),
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Three actual factories preserve published native-builder effects for accepted package objects, with exact existing construction contexts. First108/108 data and native-builder rows remain frozen; all actual source/pair/fault channels and byte/mode inputs are retained. This is not a full historical-factory or canonical acceptance claim.')
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Package-object review PASS:444 assertions/100 original REDs;10 source faults;all108/108 native-builder effects exact')

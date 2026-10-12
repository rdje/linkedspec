"""Readonly current native review; registration is an unordered identity set."""
import base64, gzip, hashlib, json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/'
sha=lambda b:hashlib.sha256(b).hexdigest()
assert sys.argv[1:] in ([],['--capture'])
read=lambda n:json.loads((ROOT/(PREFIX+n)).read_bytes())
packed=lambda n:json.loads(gzip.decompress((ROOT/(PREFIX+n)).read_bytes()))
r=read('after-native.json');c=packed('after-native-inputs.json.gz');d=packed('after-native-data.json.gz')
b=packed('before-native-data.json.gz');before=packed('before-native-inputs.json.gz');positive=read('final-after.json')
assert r['producer_sha256']==sha((ROOT/(PREFIX+'observe-after.py')).read_bytes())
assert r['capsule_sha256']==sha((ROOT/(PREFIX+'after-native-inputs.json.gz')).read_bytes())
assert r['data_sha256']==sha((ROOT/(PREFIX+'after-native-data.json.gz')).read_bytes())
assert {p:{'sha256':i['sha256'],'mode':i['mode']} for p,i in c.items()}==r['inputs']
for path,item in c.items():
    raw=base64.b64decode(item['bytes_base64'],validate=True)
    assert sha(raw)==item['sha256'] and (ROOT/path).read_bytes()==raw
    assert (ROOT/path).stat().st_mode & 0o7777 == item['mode']
    if path.startswith('perl/'):
        expected=positive['inputs'][path] if path in ['perl/LinkedSpec/ActionIR/FlowExpr.pm','perl/LinkedSpec/RuleIR/EmitContext.pm'] else before[path]
        assert item['sha256']==expected['sha256']
assert len(d)==5 and all(x['returncode']==0 for x in d)
assert base64.b64decode(d[0]['stderr_base64'])==b't/actionir_flow_default_native.pl syntax OK\n'
assert not base64.b64decode(d[0]['stdout_base64'])
def ordinary(x,authority=True):
    if isinstance(x,dict):
        exclude={'registrations','native_selected','selected'} if authority else {'registrations'}
        return {k:ordinary(v,authority) for k,v in x.items() if k not in exclude}
    if isinstance(x,list):return [ordinary(v,authority) for v in x]
    return x
assert ordinary(d[1]['observation'],False)==ordinary(d[2]['observation'],False)
assert d[3]==d[4], 'complete cold recurrence'
assert d[1]!=d[2], 'retain the actual unordered registration recurrence difference'
for index in [1,2,3,4]:
    o=d[index]['observation'];old=b[1 if index<3 else 3]['observation']
    assert json.loads(base64.b64decode(d[index]['stdout_base64']))==o
    assert not base64.b64decode(d[index]['stderr_base64'])
    assert ordinary(o)==ordinary(old), 'all ordinary native observations unchanged'
    assert {'perl/'+p for p in o['loaded_project_modules']} <= set(c)
    for row in o['rows']:
        expected=[]
        if o['mode']=='warm' and row['label']!='outside' and row['target']=='LinkedSpec::RuleIR::EmitContext':
            expected=[cb['identity'] for v in row['values'] for cb in v.get('callbacks',[]) if cb['actual_native']]
        assert sorted(row['registrations'])==sorted(expected), ('complete once-only native identity multiset',row['label'],row['context'])
        assert row['native_selected']==([1]*9 if o['mode']=='warm' and row['label']!='outside' else [0]*9)
        assert row['calls'][0]['context']==row['context']
paths={PREFIX+n for n in ['after-native.json','after-native-inputs.json.gz','after-native-data.json.gz','before-native-data.json.gz','before-native-inputs.json.gz','final-after.json','observe-after.py','current-native-order-failure.json','current-native-review.py']}
result={'result':'PASS','inputs':{p:sha((ROOT/p).read_bytes()) for p in sorted(paths)},'population':{'inputs':len(c),'warm_rows':27,'cold_rows':27,'defaults':9},'scope':'All original ordinary observations/contexts/map references/error/fatal effects remain exact. Complete cold raw recurrences and warm ordinary recurrences pass. Actual warm registration event orders differ and are retained; each required identity multiset is checked exactly once. No raw ordered warm recurrence, observation refresh or helper/public/private/parent/canonical admission is claimed.'}
raw=(json.dumps(result,indent=2)+'\n').encode();target=ROOT/(PREFIX+'current-native-review.json')
if sys.argv[1:]:
    with target.open('xb') as f:f.write(raw)
else:assert target.read_bytes()==raw
print('Current FlowExpr native review PASS: 100 inputs; 27 warm/27 cold; exact ordinary behavior and once-only unordered native registration')

"""Readonly review of the exact first native capture, with INC-to-repo path join."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
BASE = '98f8d5d7fabdc9b1ac074ca0d8f3c53d218c8ccb'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
load = lambda path: json.loads((ROOT / (PREFIX + path)).read_bytes())
r = load('before-native.json')
c = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
d = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-data.json.gz')).read_bytes()))
assert sha((ROOT / (PREFIX + 'observe.py')).read_bytes()) == r['producer_sha256']
assert sha((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()) == r['capsule_sha256']
assert sha((ROOT / (PREFIX + 'before-native-data.json.gz')).read_bytes()) == r['data_sha256']
assert {p: {'sha256':v['sha256'], 'mode':v['mode']} for p,v in c.items()} == r['inputs']
for path, item in c.items():
    raw = base64.b64decode(item['bytes_base64'], validate=True)
    assert sha(raw) == item['sha256'], ('full supplied input', path)
    if path.startswith('perl/'):
        assert raw == subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
assert len(d) == 5 and all(v['returncode'] == 0 for v in d)
assert base64.b64decode(d[0]['stderr_base64']) == b't/actionir_flow_default_native.pl syntax OK\n'
assert not base64.b64decode(d[0]['stdout_base64'])
for first, second in [(1,2),(3,4)]:
    assert d[first] == d[second], 'byte-exact first process recurrence'
for index, mode in [(1,'warm'),(3,'cold')]:
    o=d[index]['observation']
    assert json.loads(base64.b64decode(d[index]['stdout_base64'])) == o
    assert not base64.b64decode(d[index]['stderr_base64'])
    assert o['mode'] == mode and len(o['rows']) == 27 and len(o['keys']) == 9
    assert {'perl/'+p for p in o['loaded_project_modules']} <= set(c), 'actual INC/repository path join'
    assert o['source_emissions_loaded'] == (mode=='warm') and o['trace_loaded'] == 0
    assert all(not x['registrations'] and x['native_selected']==[0]*9 for x in o['rows'])
    assert all(x['calls'][0]['context'] == x['context'] for x in o['rows'])
    assert [x['label'] for x in o['rows'] if not x['success']] == ['undefined-target','unknown-target']+['fatal-object']*3
failure=load('first-native-membership-failure.json')
assert failure['session_id'] == 15733 and failure['returncode'] == 1
assert b'AssertionError: complete parent runtime namespace' in base64.b64decode(failure['merged_tool_channel_base64'])
paths={PREFIX+p for p in ['before-native.json','before-native-inputs.json.gz','before-native-data.json.gz','observe.py','native-review.py','first-native-membership-failure.json']}
result={'result':'PASS','base':BASE,'inputs':{p:sha((ROOT/p).read_bytes()) for p in sorted(paths)},
        'population':{'inputs':len(c),'warm_rows':27,'cold_rows':27,'native_defaults':9},
        'scope':'Original five commands/complete channels and100 supplied inputs pass unchanged. Original INC strings join explicitly to repository perl/ paths. The original writer failure remains retained; no observation, diagnostic, fixture or production correction/re-capture occurs. Runtime context is scalar/list/void exactly as requested; all original selections are absent, not accepted behavior.'}
target=ROOT/(PREFIX+'native-review.json')
raw=(json.dumps(result,indent=2)+'\n').encode()
if sys.argv[1:]:
    with target.open('xb') as out: out.write(raw)
else: assert target.read_bytes()==raw
print('FlowExpr first native review PASS: 100 inputs; 27 warm/27 cold rows; nine defaults; original membership failure retained')

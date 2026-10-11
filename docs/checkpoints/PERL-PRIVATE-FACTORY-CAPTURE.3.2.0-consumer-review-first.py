"""Readonly consumer census from every actual command path and complete prove summary."""
import base64
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-'
TARGET=ROOT/(PREFIX+'consumer-review.json')
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()
raw=(ROOT/(PREFIX+'consumers.json')).read_bytes()
consumer=json.loads(raw)
seed_raw=(ROOT/consumer['seed']).read_bytes()
seed=json.loads(seed_raw)
assert digest(seed_raw)==consumer['seed_sha256']
assert consumer['returncode']==0 and consumer['unchanged'],'actual consumer command failed'
assert consumer['command']==seed['command']+['t/actionir_package_flow_capture.t']
assert consumer['producer_sha256']==digest((ROOT/(PREFIX+'capture.py')).read_bytes())
assert len(consumer['inputs'])==211
assert all(digest((ROOT/path).read_bytes())==sha for path,sha in consumer['inputs'].items())
stdout=base64.b64decode(consumer['stdout_base64'],validate=True)
stderr=base64.b64decode(consumer['stderr_base64'],validate=True)
assert stderr==base64.b64decode(seed['stderr_base64'],validate=True),'consumer diagnostic drift'
command=consumer['command']
assert command[:3]==['prove','-v','-Iperl']
paths=command[3:]
assert len(paths)==len(set(paths))==67 and all(path in consumer['inputs'] for path in paths)
headers=re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$',stdout,re.MULTILINE)
assert headers==[path.encode() for path in paths],'complete actual supplied suite headers'
summary=re.findall(rb'^Files=(\d+), Tests=(\d+),',stdout,re.MULTILINE)
assert summary==[(b'67',b'13670')],'complete consumer summary'
assert len(re.findall(rb'^1\.\.\d+$',stdout,re.MULTILINE))==67,'complete suite TAP plans'
assert not re.search(rb'^not ok ',stdout,re.MULTILINE) and stdout.endswith(b'Result: PASS\n')
assert b'All tests successful.\n' in stdout
producer=(ROOT/(PREFIX+'capture.py')).read_text()
assert "every ordered supplied command path/header" in producer, 'path-complete capture guard'
result={'result':'PASS','producer_sha256':digest(Path(__file__).read_bytes()),
 'consumer_sha256':digest(raw),'original_capture_sha256':digest(producer.encode()),
 'supplied_inputs':consumer['inputs'],'command':command,'suite_paths':paths,'suites':67,'assertions':13670,
 'diagnostics_match_predecessor':True,
 'original_outer_boundary':'Current producer retains and checks actual ordered command paths/headers, all plans and exact predecessor diagnostic bytes. The first native observations and all accepted predecessor diagnostics remain unchanged.',
 'scope':'Readonly reconstruction validates all67 actual command paths and ordered headers,67 complete TAP plans, full success summary,211 actual current input identities and exact predecessor diagnostic bytes. The current capture checks all actual headers, including the accepted checkpoint suite.'}
if sys.argv[1:]:
    assert not TARGET.exists(),'one-shot consumer review already retained'
    TARGET.write_text(json.dumps(result,indent=2)+'\n')
else:
    assert json.loads(TARGET.read_bytes())==result,'consumer review drift'
print('Package-flow consumer review PASS67 actual suite paths/plans,211 inputs,13670 assertions; path-complete capture')

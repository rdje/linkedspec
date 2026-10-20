"""Check historical-fragment compiler advisories through the public parser routes."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
cases = [dict(id='public-single-key-drop', input='x', spec=
    'Top: /x/\n I { meta = { "kind": "node", "debug": 1 }; return(drop_keys(meta,"debug")) }\n')]
source = json.loads(gzip.decompress((ROOT / (c.PREFIX + 'final-inputs.json.gz')).read_bytes()))['inputs']
runtime = {path: item for path, item in source.items() if path.startswith('perl/')}
assert c.unchanged(runtime)
c.write_new(P + 'warning-public-inputs.json.gz', dict(cases=cases, producer=c.read(P + 'warning-public.py'),
    actor=c.read(c.PREFIX + 'probe.pl'),
    runtime_identities={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in runtime.items()},
    scope='Public descriptor/Get/fresh-generated diagnostic; actual warnings are retained. '
          'No assumption that standalone historical-fragment warnings are public is made.'), packed=True)
run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(cases).encode())
c.write_new(P + 'warning-public-run.json.gz', dict(run=run, runtime_inputs_unchanged=c.unchanged(runtime)), packed=True)
assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
raw = c.decode(run['stdout_base64'])
assert raw.count(b'\nSOURCE_TYPE_MODEL_JSON ') == 1
prelude, value = raw.split(b'\nSOURCE_TYPE_MODEL_JSON ')
assert not prelude
data = json.loads(value)
row = data['rows'][0]
assert all(row[route]['ok'] for route in ('descriptor', 'live', 'generated'))
assert row['live']['value'] == row['generated']['value']['value'] == {'kind': 'node'}
print(json.dumps(dict(result='PASS', value=row['live']['value'], warnings=row['warnings']), sort_keys=True))

"""Attribute the actual public compiler advisory and test a caller fatal profile."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
original = json.loads(gzip.decompress((ROOT / (P + 'warning-public-inputs.json.gz')).read_bytes()))
source = json.loads(gzip.decompress((ROOT / (c.PREFIX + 'final-inputs.json.gz')).read_bytes()))['inputs']
runtime = {path: item for path, item in source.items() if path.startswith('perl/')}
assert c.unchanged(runtime)
plan = dict(cases=original['cases'], producer=c.read(P + 'warning_routes.py'),
    actor=c.read(P + 'warning_routes.pl'), original_public_probe=c.read(P + 'warning-public-run.json.gz'),
    runtime_identities={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in runtime.items()},
    scope='Actual public descriptor/Get/generated warnings are attributed by route. A separate '
          'generated package tests only the caller lexical FATAL syntax profile; no project '
          'warning setting or gate is changed. Original observations remain exact.')
c.write_new(P + 'warning-routes-inputs.json.gz', plan, packed=True)
run = c.run(['perl', '-Iperl', P + 'warning_routes.pl'], input=json.dumps(plan['cases']).encode())
c.write_new(P + 'warning-routes-run.json.gz', dict(run=run, runtime_inputs_unchanged=c.unchanged(runtime)), packed=True)
assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
raw = c.decode(run['stdout_base64'])
assert raw.count(b'\nSOURCE_TYPE_MODEL_JSON ') == 1
prelude, value = raw.split(b'\nSOURCE_TYPE_MODEL_JSON ')
assert not prelude
row = json.loads(value)['rows'][0]
assert all(row[route]['ok'] for route in ('descriptor', 'live', 'generated'))
assert row['live']['value'] == row['generated']['value']['value'] == {'kind': 'node'}
print(json.dumps(dict(result='PASS', warning_routes=row['warning_routes'],
    fatal_ok=row['generated_fatal']['ok'], fatal_error=row['generated_fatal'].get('error')), sort_keys=True))

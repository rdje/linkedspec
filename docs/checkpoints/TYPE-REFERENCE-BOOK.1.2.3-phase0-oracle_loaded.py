"""Correct only the source-runtime package loader; retain the failed actor exactly."""
import gzip
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
spec = importlib.util.spec_from_file_location('phase0_oracle_definition', ROOT / (P + 'oracle_final.py'))
definition = importlib.util.module_from_spec(spec)
spec.loader.exec_module(definition)
plan = definition.prepare()
source = json.loads(gzip.decompress((ROOT / (c.PREFIX + 'final-inputs.json.gz')).read_bytes()))['inputs']
runtime = {path: item for path, item in source.items() if path.startswith('perl/')}
assert c.unchanged(runtime)
plan.update(producer=c.read(P + 'oracle_loaded.py'), definition=c.read(P + 'oracle_final.py'),
    actor=c.read(P + 'oracle_loaded.pl'), declarative_draft=c.read(P + 'align.py'),
    original_run=c.read(P + 'original-run.json'),
    rejected_actor=c.read(P + 'oracle_final.pl'), rejected_run=c.read(P + 'oracle-final-run.json.gz'),
    runtime_identities={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in runtime.items()},
    source_loader_basis='The retained native public probe INC names LinkedSpec/SourceLocation.pm. '
        'SourceLocation::Runtime is a package in the published module, not a file to require. '
        'The original compile2 is a loader error, never a behavioral RED.',
    scope='130 finite compatibility values:106 literal accepted historical source expectations '
        'and24 independent manual regex-case expectations. Candidate lowering never derives goldens. '
        'The immutable original source and both rejected preparation/loader epochs stay retained.')
c.write_new(P + 'oracle-loaded-inputs.json.gz', plan, packed=True)
syntax = c.run(['perl', '-c', '-Iperl', P + 'oracle_loaded.pl'])
run = c.run(['perl', '-Iperl', P + 'oracle_loaded.pl'], input=json.dumps(plan).encode()) if syntax['returncode'] == 0 else None
c.write_new(P + 'oracle-loaded-run.json.gz', dict(syntax=syntax, run=run, runtime_inputs_unchanged=c.unchanged(runtime)), packed=True)
assert syntax['returncode'] == 0 and run is not None
assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), ('see retained actor channels', run['returncode'])
rows = json.loads(c.decode(run['stdout_base64']))['rows']
assert len(rows) == 130 and all(row['error'] is None for row in rows)
print('Historical/manual finite value oracles PASS:', len(rows))

"""Freeze only the actual eligible unchanged37 source/target projection."""
import gzip,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
cases=json.loads((BASE/'cases.json').read_bytes());summary=json.loads((BASE/'first-summary.json').read_bytes())
assert summary['programs']==37 and len(summary['failed_targets'])==19 and len(summary['healthy_targets'])==18
rows={}
for line in gzip.decompress((BASE/'intake/stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_PERL '):
        _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
assert list(rows)==[case['id'] for case in cases]
expected=dict(language_agnostic_action_ir_ready=1,raw_perl_dependency_count=0,canonical_action_ir_fallback_count=0,unresolved_helper_count=0,unresolved_helpers=[])
assert all(row['metadata']==expected for row in rows.values())
out=Path('tests/fixtures/array_transform_result_guard_cases.json');assert not out.exists()
out.write_text(json.dumps(cases,indent=2)+'\n')
print('exact eligible unchanged37 fixture frozen; no failure re-blessed or peer verdict')

"""Compact the claim declaration around its complete retained input bundle."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
owner = 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
destination = ROOT / 'docs/claims' / (owner + '.json')
original = gzip.decompress((HERE / 'implementation-overbound-claim.json.gz').read_bytes())
assert destination.read_bytes() == original, 'one-shot bounded publication already applied'
record = json.loads(original)
claim = record['claims'][0]
source_paths = {row['path'] for row in json.loads((HERE / 'current-generation.json').read_text())['inputs']}
keep_sources = {'.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
                'knowledge-map/scripts/gen_knowledge_map.sh', 'tools/project_data_env.sh',
                'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
inputs = [item for item in claim['durability']['inputs']
          if item['path'] not in source_paths or item['path'] in keep_sources]
additional = (
    'input-epoch.json.gz', 'input-retention-result.json', 'freeze_inputs.py',
    'bundle_review.py', 'bundle-result.json', 'implementation-overbound-claim.json.gz',
    'canonical-second.log.gz', 'bound_record.py', 'record_review.py',
)
for name in additional:
    path = HERE / name
    inputs.append({'path': path.relative_to(ROOT).as_posix(),
                   'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                   'role': 'producer' if name.endswith('.py') else 'input'})
claim['durability']['inputs'] = inputs
claim['scope'] += ' Source bodies belong to the exact qualified November10 epoch and are retained completely in input-epoch.json.gz, with matching acquired membership/SHA256 rows. A frozen rendering replay rederives them; later card-body currency is not claimed. The overbound inline declaration and actual rejected CI log remain retained; no record limit or gate changes.'
claim['rederive']['command'] = 'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/implementation.py && bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/bundle_review.py'
claim['rederive']['granularity'] = 'Every original question/retained-record byte; every raw source body and acquired member/SHA256 in the qualified epoch; exact archived renderer replay with separately retained production-generation observations.'
claim['falsify']['red_control'] += ' Frozen input omission and altered renderer bytes reject; the unchanged strict JSON reader rejects the original inline claim at its existing bound.'
raw = json.dumps(record, indent=2).encode() + b'\n'
assert len(raw) <= 131072, 'bounded declaration still exceeds the unchanged contract'
assert record['claims'][1] == json.loads(original)['claims'][1]
destination.write_bytes(raw)
print(json.dumps({'result': 'PASS', 'claim_declaration': 'bounded; complete source bodies retained separately'}, sort_keys=True))

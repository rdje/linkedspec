"""Publish the bounded compaction claim and all current generator input identities."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
destination = ROOT / 'docs/claims' / (OWNER + '.json')
assert not destination.exists(), 'one-shot publication already exists'
result = json.loads((HERE / 'implementation-result.json').read_text())
source = json.loads((HERE / 'current-generation.json').read_text())
paths = {row['path'] for row in source['inputs']}
for name in ('review.py', 'baseline.json.gz', 'implementation.py',
             'before-generation.json', 'after-generation.json', 'implementation-result.json',
             'acquire.py', 'current-generation.json', 'acquisition-result.json',
             'routing.py', 'routing-result.json', 'projection-result.json',
             'VALIDATION.md', 'publish_implementation.py'):
    paths.add((HERE / name).relative_to(ROOT).as_posix())
paths.update(('KNOWLEDGE_MAP.md', 'tools/test_knowledge_map_projection.py',
              'tools/test_knowledge_map_atomic_output.py', 't/knowledge_map_header_lists.t',
              'tools/test_tool_project_data_storage.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
              'docs/linkedspec-book/src/development/local-ci-and-regression.md'))
inputs = []
for name in sorted(paths):
    path = ROOT / name
    inputs.append({'path': name, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                   'role': 'producer' if name.endswith(('.py', '.sh', '.t')) else 'input'})
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'bounded-knowledge-duplicate-display-compaction',
    'statement': 'The actual 1710-fact/12237-key projection removes1710 duplicate display lines/746324 bytes, reaching20789 lines/7125905 bytes; its complete Questions prefix and all remaining fact records are byte-identical.',
    'scope': 'Frozen6cd8e784 map compared with actual current public generation; complete current source population bound across a separate qualified acquisition. Initial generator-image/output packets do not receive retroactive full input-capture credit. Finite capacity only; line rollover pressure remains owned by18.2. No cap increase, healthy/lifetime-growth, broad workflow sweep, native/transitive custody, runtime/peer or whole-feature admission claim.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/implementation.py && bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/acquire.py',
                 'granularity': 'Every original question/retained record byte and complete current generator source membership/bytes; separately captured exact public-generator output, with actual old output as RED.',
                 'result': json.dumps(result, sort_keys=True)},
    'falsify': {'status': 'checked',
                'hypothesis': 'Removing a question, changing retained metadata/anchors, or restoring the old duplicate display can pass the capacity-preservation oracle.',
                'oracle': 'Frozen original-line walk independent of AWK emission; current complete source population unchanged across actual generation; independent authored projection fixture plus strict legacy ordering/repetition comparison.',
                'red_control': 'Actual before-generator output and restored-duplicate, question, source and anchor corruptions reject. Retained planning review rejects seven metadata/key deletions; current fixture rejects seven corruptions and legacy answer order/repetition changes. Healthy readonly implementation/acquisition/generator-only outside-cwd observations pass.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}]}
destination.write_text(json.dumps(record, indent=2) + '\n')

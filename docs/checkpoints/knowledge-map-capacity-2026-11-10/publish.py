"""Publish the bounded planning claim from retained inputs; run once."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.18.0'
destination = ROOT / 'docs/claims' / (OWNER + '.json')
assert not destination.exists(), 'one-shot publication already exists'
result = json.loads((HERE / 'result.json').read_text())
claim = {
    'version': 1, 'owner': OWNER, 'claims': [{
        'name': 'frozen-knowledge-projection-capacity-plan',
        'statement': 'The frozen 1710-fact/12237-key map uses22499 lines/7872229 bytes; removing only redundant per-fact answer displays projects20789 lines/7125905 bytes with exact remaining content.',
        'scope': 'Exact activation6cd8e784 map and prospective display only. No production generator change, source-card mutation, recovered production capacity, canonical receipt or whole-feature admission.',
        'rederive': {'status': 'checked',
                     'command': 'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/review.py',
                     'granularity': 'Whole frozen map bytes, every question row and fact identity; header counts independently compared with parsed rows.',
                     'result': json.dumps(result, sort_keys=True)},
        'falsify': {'status': 'checked',
                    'hypothesis': 'A missing question, anchor or retained metadata value can pass a prospective duplicate-display trim.',
                    'oracle': 'Independent original-line walk permits deletion only of the duplicate answers field; exact full question prefix and retained record sequence remain the oracle.',
                    'red_control': 'Seven actual question/anchor/title/date/source/evidence/reverify deletions raise the preservation error; healthy prospective projection and separate readonly replay pass.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': []},
    }]}
for name in ('review.py', 'publish.py', 'baseline.json.gz', 'result.json', 'PLAN.md'):
    path = HERE / name
    claim['claims'][0]['durability']['inputs'].append({
        'path': path.relative_to(ROOT).as_posix(),
        'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'role': 'producer' if name.endswith('.py') else 'input'})
destination.write_text(json.dumps(claim, indent=2) + '\n')

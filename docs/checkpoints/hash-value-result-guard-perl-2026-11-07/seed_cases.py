"""Unchanged ten scalar-source fences for localized host-name isolation."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = json.loads((BASE / 'cases.json').read_bytes())
selected = [c for c in cases if c['id'].startswith('initial_number_')]
assert len(selected) == 10
target = BASE / 'seed-cases.json'
assert not target.exists(), 'one-shot source subset'
target.write_text(json.dumps(selected, indent=2) + '\n')
print('Ten unchanged scalar-source controls; no host isolation verdict')

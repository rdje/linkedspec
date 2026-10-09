"""Actual reviewer REDs for forged or incomplete admission evidence."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6-'
plan_path = ROOT / (PREFIX + 'plan.json')
original = plan_path.read_bytes()
plan = json.loads(original)
outputs = {suffix: (ROOT / (PREFIX + suffix + '.json')).read_bytes()
           for suffix in ('verification', 'controls', 'control-command')}
channel = lambda raw: {'base64': base64.b64encode(raw).decode(),
                       'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)}
rows = []
try:
    for name in ('missing_history_member', 'forged_original_history_hash', 'forged_registry_hash'):
        mutant = copy.deepcopy(plan)
        history = 'docs/history/development-notes/manifest.jsonl'
        if name == 'missing_history_member':
            del mutant['preserved'][history]
            reason = b'complete prior immutable population'
        elif name == 'forged_original_history_hash':
            mutant['preserved'][history] = '0' * 64
            reason = history.encode()
        else:
            mutant['new_registry_sha256'] = '0' * 64
            reason = b'retained new registry identity'
        raw = (json.dumps(mutant, indent=2) + '\n').encode()
        plan_path.write_bytes(raw)
        args = ['python3', PREFIX + 'capacity.py', 'review']
        result = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        assert result.returncode != 0 and reason in result.stderr, name
        assert plan_path.read_bytes() == raw
        rows.append({'name': name, 'observed': 'RED', 'reason': reason.decode(),
                     'args': args, 'exit_code': result.returncode, 'mutant_plan': channel(raw),
                     'stdout': channel(result.stdout), 'stderr': channel(result.stderr)})
finally:
    plan_path.write_bytes(original)
for suffix, raw in outputs.items():
    assert (ROOT / (PREFIX + suffix + '.json')).read_bytes() == raw, suffix
assert plan_path.read_bytes() == original
record = {'result': 'PASS', 'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
          'plan_sha256': hashlib.sha256(original).hexdigest(), 'rows': rows,
          'scope': 'Only mutable plan evidence is temporarily replaced and restored; no immutable history, registry, decision, producer or successful proof output is edited.'}
(ROOT / (PREFIX + 'evidence.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Three actual reviewer evidence REDs pass; original plan and successful proof outputs restored exactly.')

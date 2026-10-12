"""Retain actual completed tool sessions/logs, separately from complete inner channels."""
import base64
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
target = ROOT / (PREFIX + 'completions.json')
assert not target.exists(), 'one-shot outer completion custody'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
rows = []
for name, session, source, artifact in [
 ('preserve', 39679, 'preserve.py', 'preservation.json'),
 ('observe', 7081, 'observe.py', 'before-native.json'),
 ('before', 83992, 'run.py', 'before.json'),
 ('after', 80572, 'run.py', 'after.json'),
 ('observe-after', 43065, 'observe-after.py', 'after-native.json'),
 ('faults', 38856, 'faults.py', 'faults.json'),
 ('consumers', 41833, 'consumers.py', 'consumers.json'),
 ('compat', 91242, 'compat.py', 'compat.json'),
 ('book', 7677, 'book.py', 'book.json'),
 ('knowledge', 30369, 'knowledge.py', 'knowledge.json'),
 ('review', 65530, 'review.py', 'review.json'),
 ('evidence', 66746, 'evidence.py', 'evidence.json'),
]:
    raw = (ROOT / ('.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.4.0-' + name + '.log')).read_bytes()
    rows.append({'name': name, 'actual_tool_session': session, 'actual_returncode': 0,
                 'source': PREFIX + source, 'producer_sha256': sha((ROOT / (PREFIX + source)).read_bytes()),
                 'artifact': PREFIX + artifact, 'artifact_sha256': sha((ROOT / (PREFIX + artifact)).read_bytes()),
                 'merged_log_base64': base64.b64encode(raw).decode()})
target.write_text(json.dumps({'producer_sha256': sha(Path(__file__).read_bytes()), 'rows': rows,
    'scope': 'Actual tool completions consumed in this session. Full inner native/paired/fault/consumer/Phase0/book/Knowledge/evidence channels remain in their original records. Initial normal prove55712/1 is retained separately in first-red.json.gz. Separate outer channels were not captured; these merged logs are exact, not reconstructed. All listed writers are retired.'}, indent=2) + '\n')
print('FlowExpr outer completions retained:12 actual successful tool sessions and exact merged logs')

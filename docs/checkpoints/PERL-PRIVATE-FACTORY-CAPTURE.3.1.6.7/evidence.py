"""Actual encoding/preservation counterfactuals; readonly default, --capture once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
channel = lambda raw: {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': sha(raw)}
args = ['python3', DIR + 'review.py']
FILES = [PREFIX + 'book-correction.json', DIR + 'original-inputs.json', DIR + 'retention.json']
original = {p: read(p) for p in FILES}
assert sys.argv[1:] in ([], ['--capture'])

def command():
    result = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return {'args': args, 'exit_code': result.returncode,
            'stdout': channel(result.stdout), 'stderr': channel(result.stderr)}

def changed(name):
    result = dict(original)
    if name == 'changed_encoded_diagnostic':
        data = json.loads(original[FILES[0]])
        raw = base64.b64decode(data['observed_tool_return']['output_base64']) + b'changed'
        data['observed_tool_return'].update(output_base64=base64.b64encode(raw).decode(),
            output_bytes=len(raw), output_sha256=sha(raw))
        result[FILES[0]] = (json.dumps(data, indent=2) + '\n').encode()
        reason = 'sole encoded diagnostic repair'
    else:
        assert name == 'changed_retained_original_beyond_metadata'
        data = json.loads(original[FILES[1]])
        item = data['docs/knowledge/guarded-ast-change-history-capacity.md']
        raw = base64.b64decode(item['base64']) + b'changed'
        item.update(base64=base64.b64encode(raw).decode(), bytes=len(raw), sha256=sha(raw))
        result[FILES[1]] = (json.dumps(data, indent=2) + '\n').encode()
        metadata = json.loads(original[FILES[2]])
        metadata['original_inputs_sha256'] = sha(result[FILES[1]])
        result[FILES[2]] = (json.dumps(metadata, indent=2) + '\n').encode()
        reason = 'original369 input hash'
    return result, reason

target = ROOT / (DIR + 'evidence.json')
reached = ROOT / (DIR + 'evidence-reached.json')
names = ['changed_encoded_diagnostic', 'changed_retained_original_beyond_metadata']
if sys.argv[1:]:
    assert not target.exists() and not reached.exists()
    healthy = command()
    rows = []
    reached.write_text(json.dumps({'healthy': healthy, 'rows': rows}, indent=2) + '\n')
    assert healthy['exit_code'] == 0
    try:
        for name in names:
            altered, reason = changed(name)
            for p, raw in altered.items(): (ROOT / p).write_bytes(raw)
            observed = command()
            rows.append({'name': name, 'reason': reason, 'mutant_inputs': {p: channel(raw) for p,raw in altered.items()},
                         'observed': observed})
            reached.write_text(json.dumps({'healthy': healthy, 'rows': rows}, indent=2) + '\n')
            assert observed['exit_code'] != 0 and reason.encode() in base64.b64decode(observed['stderr']['base64'])
            for p, raw in original.items(): (ROOT / p).write_bytes(raw)
            rows[-1]['restored'] = command()
            reached.write_text(json.dumps({'healthy': healthy, 'rows': rows}, indent=2) + '\n')
            assert rows[-1]['restored'] == healthy
    finally:
        for p, raw in original.items(): (ROOT / p).write_bytes(raw)
    target.write_text(json.dumps({'producer_sha256': sha(Path(__file__).read_bytes()),
        'original_inputs': {p: sha(raw) for p,raw in original.items()}, 'healthy': healthy, 'rows': rows}, indent=2) + '\n')
data = json.loads(target.read_bytes())
assert data['producer_sha256'] == sha(Path(__file__).read_bytes())
assert data['original_inputs'] == {p: sha(raw) for p,raw in original.items()}
assert json.loads(reached.read_bytes()) == {k: data[k] for k in ('healthy', 'rows')}
assert data['healthy'] == command()
assert [r['name'] for r in data['rows']] == names
for row in data['rows']:
    altered, reason = changed(row['name'])
    assert row['reason'] == reason and row['mutant_inputs'] == {p: channel(raw) for p,raw in altered.items()}
    assert row['restored'] == data['healthy']
    assert row['observed']['exit_code'] != 0 and reason.encode() in base64.b64decode(row['observed']['stderr']['base64'])
    for key in ('stdout', 'stderr'):
        assert channel(base64.b64decode(row['observed'][key]['base64'])) == row['observed'][key]
print('Portable diagnostic evidence PASS: two actual named REDs/beyond updated metadata; exact restoration')

"""Correct only the new denial loop's shadowed governance row; retain the failed actor."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
proposals = json.loads(gzip.decompress((ROOT / (P + 'proposals.json.gz')).read_bytes()))
failed = json.loads(gzip.decompress((ROOT / (P + 'historical-run.json.gz')).read_bytes()))
assert failed['run']['returncode'] == 1
assert b"KeyError: 'historical'" in c.decode(failed['run']['stderr_base64'])
before = c.read(AUDITOR)
assert before == proposals['after'][AUDITOR]
source = c.decode(before['base64']).decode()
old = '            for row in inverse_table["hunks"]:\n                fragment = row["after"].encode()\n'
new = '            for fragment_record in inverse_table["hunks"]:\n                fragment = fragment_record["after"].encode()\n'
assert source.count(old) == 1
source = source.replace(old, new, 1)
ast.parse(source, filename=AUDITOR)
raw = source.encode()
after = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before['mode'])
c.write_new(P + 'control-fix.json.gz', dict(before={AUDITOR: before}, after={AUDITOR: after},
    producer=c.read(P + 'fix_control.py'),
    scope='The first actual isolated proof reaches falsify, where the new fragment loop '
          'shadows the original governance row. The existing row[historical] then raises '
          'KeyError. Rename only the two new variable references; all old controls, '
          'table bytes, historical hashes and other source bytes remain identical. '
          'This instrument failure is retained and is not behavioral RED.'), packed=True)
(ROOT / AUDITOR).write_bytes(raw)
(ROOT / AUDITOR).chmod(after['mode'])
assert c.read(AUDITOR) == after
capture = (ROOT / (P + 'capture.py')).read_text()
anchor = "assert all(c.read(path) == item for path, item in proposals['after'].items())"
replacement = """fix = json.loads(gzip.decompress((ROOT / (P + 'control-fix.json.gz')).read_bytes()))
assert fix['before'][AUDITOR] == proposals['after'][AUDITOR]
proposals = dict(proposals, after=dict(proposals['after'], **fix['after']))
assert all(c.read(path) == item for path, item in proposals['after'].items())"""
assert capture.count(anchor) == 1
capture = capture.replace(anchor, replacement, 1)
capture = capture.replace("P + 'capture.py'", "P + 'capture_corrected.py'")
capture = capture.replace('historical-inputs.json', 'historical-final-inputs.json')
capture = capture.replace('historical-run.json.gz', 'historical-final-run.json.gz')
capture = capture.replace('historical-review.json', 'historical-final-review.json')
capture = capture.replace('table-control.json', 'table-final-control.json')
anchor = "inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}"
replacement = """paths.update(P + name for name in ('capture.py', 'historical-inputs.json',
    'historical-run.json.gz', 'fix_control.py', 'control-fix.json.gz'))
""" + anchor
assert capture.count(anchor) == 1
capture = capture.replace(anchor, replacement, 1)
ast.parse(capture, filename=P + 'capture_corrected.py')
with (ROOT / (P + 'capture_corrected.py')).open('x') as output:
    output.write(capture)
print('Retained the first KeyError and corrected only the two new shadowing references')

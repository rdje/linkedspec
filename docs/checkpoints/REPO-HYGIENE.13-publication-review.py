"""Check exact clean chronology preservation and the observed rejected preamble."""
import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '60e8ef2ab571bab5d951e0d6f701daf1752df36e'
PREFIX = 'docs/checkpoints/REPO-HYGIENE.13-'
error = json.loads((ROOT / (PREFIX + 'publication-initial-error.json')).read_bytes())
assert error['exit'] != 0
assert b'preamble omits its history manifest' in base64.b64decode(error['stderr_base64'], validate=True)
assert hashlib.sha256((ROOT / (PREFIX + 'publish-initial.py')).read_bytes()).hexdigest() == error['original_publisher_sha256']
for path, sha in error['inputs'].items():
    assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == sha
results = []
for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    original = subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT)
    offset = re.search(rb'^## ', original, re.MULTILINE).start()
    current = (ROOT / name).read_bytes()
    assert current.startswith(original[:offset]), name + ' original preamble'
    assert current.endswith(original[offset:]), name + ' original records'
    inserted = current[offset:len(current) - len(original[offset:])]
    assert len(re.findall(rb'^## ', inserted, re.MULTILINE)) == 1
    assert b'REPO-HYGIENE.13' in inserted
    results.append({'path': name, 'original_sha256': hashlib.sha256(original).hexdigest(),
                    'current_sha256': hashlib.sha256(current).hexdigest(),
                    'preamble_and_prior_records_exact': True})
(ROOT / (PREFIX + 'publication-verification.json')).write_text(json.dumps({
    'complete': True, 'revision': BASE, 'results': results,
    'original_preamble_red_retained': True,
    'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}, indent=2) + '\n')
print('Publication PASS: exact original preambles/records and one new heading per chronology.')

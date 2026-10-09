"""Assess exact finite historical consumer manifests without re-labeling their reads."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '42e00f840059db5bd4e602aee7a3b5d1e366b97b'
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
STEM = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.'
EPOCHS = {
 '2.0.1': '5fae1476f3fbd69c70b598a2f7f56d3088ea5156',
 '2.1.1': '0d52a407c4c508cfb00d45765471f741a10de616',
 '2.1.2.0': 'e0ebc8d24e6b473c74ad246873402ba9dcd7a3e3',
 '2.1.2.4': '8f0cdaec69b80ce5a8f4edfd783199693498bae1',
}
ARTIFACTS = [
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-cases.json',
]
def digest(raw):
    return hashlib.sha256(raw).hexdigest()
def blob(revision, path):
    return subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)

assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
rows = []
for suffix, epoch in EPOCHS.items():
    leaf = STEM + suffix
    path = 'docs/claims/' + leaf + '.json'
    original = blob(BASE, path)
    record = json.loads(original)
    before = PREFIX + 'before-' + Path(path).name
    (ROOT / before).write_bytes(original)
    checked = []
    for claim in record['claims']:
        durability = claim['durability']
        revision = durability.get('revision', BASE)
        for entry in durability['inputs']:
            assert digest(blob(revision, entry['path'])) == entry['sha256'], entry['path']
            checked.append(entry)
    capture_path = 'docs/checkpoints/' + leaf + '-consumers.json'
    capture_raw = blob(epoch, capture_path)
    capture = json.loads(capture_raw)
    assert capture['returncode'] == 0 and b'Result: PASS' in base64.b64decode(capture['stdout_base64'])
    same, different = [], []
    for source, h in capture['inputs'].items():
        observed = digest(blob(epoch, source))
        (same if observed == h else different).append({'path': source, 'recorded_sha256': h, 'epoch_sha256': observed})
    missing = [p for p in ARTIFACTS if p not in capture['inputs']]
    artifact_epoch_inputs = {p: digest(blob(epoch, p)) for p in ARTIFACTS}
    rows.append({'owner': leaf, 'epoch': epoch, 'claim_path': path, 'before': before,
                 'original_claim_sha256': digest(original), 'verified_claim_bindings': len(checked),
                 'capture_path': capture_path, 'capture_sha256': digest(capture_raw),
                 'tests': capture['command'][3:], 'recorded_inputs': len(capture['inputs']),
                 'missing_selected_json': missing, 'epoch_json_inputs': artifact_epoch_inputs,
                 'recorded_epoch_matches': same, 'recorded_epoch_mismatches': different,
                 'limits': 'Epoch JSON hashes locate recoverable source bytes only. A missing original hash is not repaired by adding this epoch hash; original per-read bytes were not separately guarded.'})
    print(suffix, 'recorded', len(capture['inputs']), 'missing JSON', len(missing), 'epoch mismatches', len(different))
report = {'base': BASE, 'rows': rows, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'scope': 'Finite four-record historical input audit. Original passing channels and original claims retained; no current or complete Phase0 runtime admission.'}
(ROOT / (PREFIX + 'audit.json')).write_text(json.dumps(report, indent=2) + '\n')

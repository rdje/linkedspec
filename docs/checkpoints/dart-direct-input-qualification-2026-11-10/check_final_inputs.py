"""Check final current inputs and append-only original explanation publication."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
metadata_paths = [BASE / 'qualified/source-identities.json', BASE / 'qualified/resolved-identities.json']
for index, metadata in enumerate(metadata_paths):
    for name, row in json.loads(metadata.read_bytes()).items():
        if index == 0 and name == 'dart/.dart_tool/package_config.json':
            continue
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
        assert path.stat().st_mode & 0o777 == row['mode'], name
old_base = 'docs/checkpoints/array-transform-result-guard-dart-2026-11-10'
document = old_base + '/REVIEW.md'
revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
assert revision == 'daa081db0de3ce0d761f1ee389f7d9a4500bbccb'
prior = subprocess.check_output(['git', 'show', revision + ':' + document])
current = Path(document).read_bytes()
assert current.startswith(prior)
assert subprocess.check_output(['git', 'diff', '--name-only', '--', old_base], text=True).splitlines() == [document]
target = BASE / 'final-input-result.json'
assert not target.exists()
result = dict(current_inputs='PASS', original_explanation='append-only', base_revision=revision,
              input_metadata=[str(path.relative_to(ROOT)) for path in metadata_paths],
              original_explanation_path=document, explanation_sha256=hashlib.sha256(current).hexdigest(),
              producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))

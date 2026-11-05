#!/usr/bin/env bash
# Freeze original Dart observations and preserve unrelated emitter bytes verbatim.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
git diff --quiet HEAD -- dart/lib/src/runtime/interpreter.dart
bash tools/project_data_run.sh python3 - <<'PY'
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

out = Path('docs/checkpoints/count-guard-dart-2026-11-05')
record = out / 'frozen-observations.json'
assert not record.exists(), 'refusing to refresh historical observations'
lines = (out / 'baseline-native.log').read_text().splitlines()
def observation(marker):
    found = [json.loads(line.split(marker, 1)[1]) for line in lines if marker in line]
    assert len(found) == 1, marker
    return found[0]
routes = observation('COUNT_GUARD_DART_VALUE source_domain_diagnostic ')
domain = routes['native']['ok']
assert all(row == {'ok': domain} for row in routes.values())
shapes = observation('COUNT_GUARD_DART_SHAPES ')
ast_path = Path('tests/fixtures/count_result_guard_dart_ast.json')
domain_path = Path('tests/fixtures/count_result_guard_dart_domain.json')
assert json.loads(ast_path.read_text()) is None
ast_path.write_text(json.dumps(shapes, ensure_ascii=False, sort_keys=True, indent=2) + '\n')
domain_path.write_text(json.dumps(domain) + '\n')
emitter_path = Path('dart/test/source_emitter_test.dart')
marker = '\nvoid _countGuardSourceTests() {'
with tarfile.open(out / 'baseline-inputs.tar.gz') as archive:
    baseline = archive.extractfile(str(emitter_path)).read().decode()
suffix = emitter_path.read_text().split(marker, 1)[1]
assert suffix == baseline.split(marker, 1)[1], 'new observer body changed'
original = subprocess.check_output(['git', 'show', 'HEAD:' + str(emitter_path)], text=True)
assert '_countGuardSourceTests();' not in original
restored = original.replace('void main() {\n', 'void main() {\n  _countGuardSourceTests();\n', 1)
emitter_path.write_text(restored + marker + suffix)
inputs = [out / 'freeze.sh', out / 'baseline-native.log', out / 'baseline-inputs.tar.gz', out / 'baseline-head.txt']
result = {
    'baseline_head': (out / 'baseline-head.txt').read_text().strip(),
    'interpreter_blob': subprocess.check_output(['git', 'rev-parse', 'HEAD:dart/lib/src/runtime/interpreter.dart'], text=True).strip(),
    'original_emitter_blob': subprocess.check_output(['git', 'rev-parse', 'HEAD:' + str(emitter_path)], text=True).strip(),
    'new_emitter_member_unchanged_sha256': hashlib.sha256(suffix.encode()).hexdigest(),
    'domain': domain,
    'inputs': {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs},
    'outputs': {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in [ast_path, domain_path, emitter_path]},
}
record.write_text(json.dumps(result, sort_keys=True, indent=2) + '\n')
print('Frozen unchanged Dart domain:', json.dumps(domain))
PY

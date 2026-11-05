#!/usr/bin/env bash
# Bootstrap observational fences only from the retained unchanged Rust baseline.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
git diff --quiet HEAD -- rust/linkedspec-runtime/src/engine.rs
bash tools/project_data_run.sh python3 - <<'PY'
import hashlib
import json
from pathlib import Path
import subprocess

out = Path('docs/checkpoints/count-guard-rust-2026-11-05')
record = out / 'frozen-observations.json'
assert not record.exists(), 'refusing to refresh historical observations'
lines = (out / 'baseline-native.log').read_text().splitlines()
def observation(marker):
    values = [json.loads(line.split(marker, 1)[1]) for line in lines if marker in line]
    assert len(values) == 1, marker
    return values[0]
domain_routes = observation('COUNT_GUARD_DOMAIN ')
domain = domain_routes[0]['Ok']
assert all(row == {'Ok': domain} for row in domain_routes)
shapes = observation('COUNT_GUARD_SHAPES ')
ast_path = Path('tests/fixtures/count_result_guard_rust_ast.json')
assert json.loads(ast_path.read_text()) is None, 'only bootstrap the new source fence'
domain_path = Path('tests/fixtures/count_result_guard_rust_domain.json')
ast_path.write_text(json.dumps(shapes, ensure_ascii=False, sort_keys=True, indent=2) + '\n')
domain_path.write_text(json.dumps(domain) + '\n')
inputs = [out / 'freeze.sh', out / 'baseline-native.log', out / 'baseline-head.txt']
result = {
    'baseline_head': (out / 'baseline-head.txt').read_text().strip(),
    'engine_blob': subprocess.check_output(['git', 'rev-parse', 'HEAD:rust/linkedspec-runtime/src/engine.rs'], text=True).strip(),
    'domain': domain,
    'source_fence': str(ast_path),
    'inputs': {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs},
    'outputs': {str(path): hashlib.sha256(path.read_bytes()).hexdigest() for path in [ast_path, domain_path]},
}
record.write_text(json.dumps(result, sort_keys=True, indent=2) + '\n')
print('Frozen unchanged Rust Count domain:', json.dumps(domain))
PY

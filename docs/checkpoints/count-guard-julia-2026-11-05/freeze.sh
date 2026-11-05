#!/usr/bin/env bash
# Freeze public pre-edit observations and qualify route-specific error wrappers.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
git diff --quiet HEAD -- julia/src/runtime/Interpreter.jl julia/src/source/SourceEmitter.jl
bash tools/project_data_run.sh python3 - <<'PY'
import hashlib, json, subprocess
from pathlib import Path
out=Path('docs/checkpoints/count-guard-julia-2026-11-05')
record=out/'frozen-observations.json'
assert not record.exists(), 'historical freeze is one-shot'
lines=(out/'baseline-stdout.log').read_text().splitlines()
def observed(marker):
 rows=[json.loads(line.split(marker,1)[1]) for line in lines if line.startswith(marker)]
 assert len(rows)==1, marker
 return rows[0]
domain=observed('COUNT_GUARD_JULIA_VALUE source_domain_diagnostic ')
assert all(row==domain['native'] for row in domain.values())
shapes=observed('COUNT_GUARD_JULIA_SHAPES ')
errors=observed('COUNT_GUARD_JULIA_ERROR needed_source_error ')
assert len(shapes)==18
assert all('binding_kind_mismatch' in row['error'] for row in errors.values())
outputs={
 'tests/fixtures/count_result_guard_julia_ast.json': shapes,
 'tests/fixtures/count_result_guard_julia_domain.json': domain['native']['ok'],
 'tests/fixtures/count_result_guard_julia_errors.json': {'needed_source_error':errors},
}
for name,value in outputs.items():
 p=Path(name)
 assert not p.exists() or json.loads(p.read_text()) is None, name
 p.write_text(json.dumps(value,ensure_ascii=False,sort_keys=True,indent=2)+'\n')
p=Path('julia/test/count_result_guard_composition_test.jl');s=p.read_text().replace('label == "free_rejected_with"','label == "free_guard_before_with"')
s=s.replace('    cases = Any[]\n','    error_fences = JSON3.read(read(joinpath(fixture_root, "tests", "fixtures", "count_result_guard_julia_errors.json"), String), Any)\n    cases = Any[]\n',1)
s=s.replace('                @test get(value, "class", "") == "RuntimeInterpreterException"\n                @test get(get(value, "diagnostic", Dict()), "code", "") == row["expected_error"]\n','')
s=s.replace('        else\n            check(row["id"]', '            @test strict_equal(actual, error_fences[row["id"]])\n        else\n            check(row["id"]',1)
p.write_text(s)
inputs=[out/'freeze.sh',out/'baseline-stdout.log',out/'baseline-stderr.log',out/'baseline-inputs.tar.gz',out/'baseline-head.txt']
result={'activation_commit':(out/'baseline-head.txt').read_text().strip(),
 'production_blobs':{p:subprocess.check_output(['git','rev-parse','HEAD:'+p],text=True).strip() for p in ['julia/src/runtime/Interpreter.jl','julia/src/source/SourceEmitter.jl']},
 'inputs':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs},
 'outputs':{p:hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in [*outputs,str(Path('julia/test/count_result_guard_composition_test.jl'))]},
 'qualification':'Uniform error class/code expectations and a nonmatching trace label were observer setup assumptions. Native/restored use RuntimeInterpreterException with optional generic diagnostic; plan/fresh preserve existing GeneratedSourceException execution wrappers. Domain/AST placeholders are bootstrap only. No production change or product RED credit for these assumptions.'}
record.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print('Frozen unchanged Julia domain:',domain['native']['ok'])
PY

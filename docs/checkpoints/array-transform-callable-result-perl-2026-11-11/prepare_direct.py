"""Adapt a retained public API artifact recorder; run the two original normals."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
source = Path('docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/direct_runner_qualified.pl')
raw = source.read_bytes()
assert raw == subprocess.check_output(['git', 'show', '09bad87aa19304486f836cf6dff44b499a8ea5ec:' + str(source)])
assert not (BASE / 'direct_runner.pl').exists()
(BASE / 'direct-template.pl.gz').write_bytes(gzip.compress(raw, mtime=0))
text = raw.decode()
changes = [
    ("($test eq 't/array_pipeline_value_contract.t' || $test eq 't/variadic_user_function_contract.t' || $test eq 't/array_pipeline_result_guard_composition.t' || $test eq 't/array_pipeline_callable_arity.t')", "($test eq 't/array_transform_result_guard_composition.t' || $test eq 't/array_pipeline_callable_result_guard_composition.t')"),
    ('LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE', 'LINKEDSPEC_CALLABLE_TRANSFORM_DIRECT_CAPTURE'),
    ('docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/direct_qualified', str(REL / 'direct')),
    ('CALLABLE_PIPELINE_RESULT_DIRECT_ARTIFACT', 'CALLABLE_ARRAY_TRANSFORM_DIRECT_ARTIFACT'),
]
for old, new in changes:
    assert text.count(old) == 1, old
    text = text.replace(old, new)
(BASE / 'direct_runner.pl').write_text(text)
(BASE / 'direct-template.json').write_text(json.dumps(dict(source=str(source), sha256=hashlib.sha256(raw).hexdigest(), changes=changes), indent=2) + '\n')
print('Prepared API recorder for two exact original dependent normals; no SDK executed.')

"""Adapt the retained API artifact harness to the four direct dependents."""
import gzip
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
source = Path('docs/checkpoints/array-pipeline-callable-arity-perl-2026-11-11/direct_runner.pl')
raw = source.read_bytes()
assert raw == subprocess.check_output(['git', 'show', 'HEAD:' + str(source)])
assert not (BASE / 'direct_runner.pl').exists()
(BASE / 'direct-template.pl.gz').write_bytes(gzip.compress(raw, mtime=0))
text = raw.decode()
replacements = [
    ("($test eq 't/array_pipeline_value_contract.t' || $test eq 't/variadic_user_function_contract.t')",
     "($test eq 't/array_pipeline_value_contract.t' || $test eq 't/variadic_user_function_contract.t' || $test eq 't/array_pipeline_result_guard_composition.t' || $test eq 't/array_pipeline_callable_arity.t')"),
    ('LINKEDSPEC_CALLABLE_PIPELINE_ARITY_CAPTURE', 'LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE'),
    ('docs/checkpoints/array-pipeline-callable-arity-perl-2026-11-11/direct',
     'docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/direct'),
    ('CALLABLE_PIPELINE_ARITY_DIRECT_ARTIFACT', 'CALLABLE_PIPELINE_RESULT_DIRECT_ARTIFACT'),
]
for old, new in replacements:
    assert text.count(old) == 1, old
    text = text.replace(old, new)
(BASE / 'direct_runner.pl').write_text(text)
print('Direct API artifact harness retains correct FindBin and missing-plan handling')

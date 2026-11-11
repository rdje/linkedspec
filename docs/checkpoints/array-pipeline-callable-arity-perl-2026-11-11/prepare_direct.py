"""Retain and adapt the published public-API direct artifact harness."""
import gzip
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
source = Path('docs/checkpoints/array-pipeline-composition-perl-2026-11-10/direct_runner.pl')
raw = source.read_bytes()
assert raw == subprocess.check_output(['git', 'show', 'HEAD:' + str(source)])
assert not (BASE / 'direct_runner.pl').exists()
(BASE / 'direct-template.pl.gz').write_bytes(gzip.compress(raw, mtime=0))
text = raw.decode()
replacements = [
    ("($test eq 't/array_pipeline_value_contract.t' || $test eq 't/array_pipeline_source_isolation.t' || $test eq 't/array_transform_result_guard_composition.t')",
     "($test eq 't/array_pipeline_value_contract.t' || $test eq 't/variadic_user_function_contract.t')"),
    ('LINKEDSPEC_ARRAY_PIPELINE_COMPOSITION_CAPTURE', 'LINKEDSPEC_CALLABLE_PIPELINE_ARITY_CAPTURE'),
    (r'docs/checkpoints/array-pipeline-composition-perl-2026-11-10/direct(?:_qualified)?',
     'docs/checkpoints/array-pipeline-callable-arity-perl-2026-11-11/direct'),
    ('ARRAY_PIPELINE_DIRECT_ARTIFACT', 'CALLABLE_PIPELINE_ARITY_DIRECT_ARTIFACT'),
    ('do "./$test";', '''# A do-loaded test must retain its normal t/ FindBin context.
require FindBin;
require Cwd;
no warnings 'once';
local $FindBin::Bin = Cwd::abs_path('t');
do "./$test";'''),
]
for old, new in replacements:
    assert text.count(old) == 1, old
    text = text.replace(old, new)
(BASE / 'direct_runner.pl').write_text(text)
print('Direct public-API harness authored; normal FindBin context and missing-plan fallback retained')

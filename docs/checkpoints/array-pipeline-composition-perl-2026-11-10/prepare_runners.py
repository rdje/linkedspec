"""Retain known source-proof runners and freeze this slice's SDK instruments."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
PRIOR = Path('docs/checkpoints/array-pipeline-source-perl-2026-11-10')
records = {}
for name in ('capture.py', 'private_runner.pl', 'direct_runner.pl', 'set_private_image.py'):
    raw = (PRIOR / name).read_bytes()
    target = BASE / ('runner-template-' + name + '.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(raw, mtime=0))
    records[str(PRIOR / name)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), retained=target.name)
    text = raw.decode()
    if name == 'capture.py':
        text = text.replace("('before', 'after', 'private_inverse', 'private_restored', 'private_restored_qualified', 'preservation', 'direct', 'direct_qualified')",
                            "('before', 'after', 'private_inverse', 'private_restored', 'direct')")
        text = text.replace("'array_pipeline_source_isolation.t', 'array_pipeline_value_contract.t', 'array_transform_source_isolation.t'",
                            "'array_pipeline_result_guard_composition.t', 'array_pipeline_source_isolation.t', 'array_pipeline_value_contract.t', 'array_transform_result_guard_composition.t'")
        text = text.replace('tests/fixtures/array_pipeline_source_isolation_perl_cases.json', 'tests/fixtures/array_pipeline_result_guard_perl_cases.json')
        text = text.replace("['t/array_pipeline_value_contract.t', 't/array_transform_source_isolation.t']",
                            "['t/array_pipeline_value_contract.t', 't/array_pipeline_source_isolation.t', 't/array_transform_result_guard_composition.t']")
        text = text.replace("else ['t/array_pipeline_source_isolation.t']", "else ['t/array_pipeline_result_guard_composition.t']")
    if name == 'private_runner.pl':
        text = text.replace('t/array_pipeline_source_isolation.t', 't/array_pipeline_result_guard_composition.t')
    if name == 'direct_runner.pl':
        text = text.replace("$test eq 't/array_transform_source_isolation.t'",
                            "$test eq 't/array_pipeline_source_isolation.t' || $test eq 't/array_transform_result_guard_composition.t'")
    text = text.replace('array-pipeline-source-perl-2026-11-10', 'array-pipeline-composition-perl-2026-11-10')
    text = text.replace('array-pipeline-source-perl/owner.pm', 'array-pipeline-composition-perl/owner.pm')
    text = text.replace('LINKEDSPEC_ARRAY_PIPELINE_SOURCE_CAPTURE', 'LINKEDSPEC_ARRAY_PIPELINE_COMPOSITION_CAPTURE')
    text = text.replace('ARRAY_PIPELINE_SOURCE_OWNER_IMAGE', 'ARRAY_PIPELINE_COMPOSITION_OWNER_IMAGE')
    target = BASE / name
    assert not target.exists()
    target.write_text(text)
(BASE / 'runner-template-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('SDK runners frozen; selected direct normals have384 groups and plan-aware artifact capture')

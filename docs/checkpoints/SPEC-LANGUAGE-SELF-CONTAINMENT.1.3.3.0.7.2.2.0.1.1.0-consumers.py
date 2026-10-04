"""Execute unchanged direct consumers; retain full TAP and channels losslessly."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-'
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
tests = ['t/phase0_regression.t', 't/actionir_helper_source_provenance.t', 't/inter_match_gap_capture_perl_contract.t', 't/actionir_ast_parser.t', 't/trace_actionir_pipeline.t',
         't/canonical_event_occurrence_order.t', 't/actionir_raw_dependency_metadata.t',
         't/actionir_raw_dependency_provenance.t', 't/actionir_raw_dependency_compatibility.t',
         't/actionir_nested_block_source_spans.t', 't/noncurrent_helper_metadata.t',
         't/generated_source_contract.t', 't/codeblock_matches_perl.t']
rows = []
for test in tests:
    command = ['prove', '-v', '-Iperl', test]
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PERL5LIB='', PERL_HASH_SEED='0', PERL_PERTURB_KEYS='2'), capture_output=True)
    rows.append({'test': test, 'command': command, 'exit': result.returncode,
                 'stdout': capture.envelope(result.stdout), 'stderr': capture.envelope(result.stderr)})
    print(test, result.returncode, flush=True)
(ROOT / (PREFIX + 'consumers.json')).write_text(json.dumps({'rows': rows}, indent=2) + '\n')
raise SystemExit(any(row['exit'] for row in rows))

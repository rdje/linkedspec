"""Retain complete unchanged direct-consumer TAP streams."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-'
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
suites = ['t/canonical_event_occurrence_order.t', 't/actionir_ast_parser.t',
          't/noncurrent_helper_metadata.t', 't/trace_actionir_pipeline.t']
rows = []
for path in suites:
    command = ['prove', '-v', '-Iperl', path]
    result = subprocess.run(command, cwd=ROOT, capture_output=True,
                            env=dict(os.environ, PERL5LIB='', PERL_HASH_SEED='0', PERL_PERTURB_KEYS='2'))
    rows.append({'path': path, 'command': command, 'exit': result.returncode,
                 'stdout': capture.envelope(result.stdout), 'stderr': capture.envelope(result.stderr)})
(ROOT / (PREFIX + 'consumers.json')).write_text(json.dumps(rows, indent=2) + '\n')
assert all(row['exit'] == 0 for row in rows)
print('PASS four unchanged direct-consumer suites')

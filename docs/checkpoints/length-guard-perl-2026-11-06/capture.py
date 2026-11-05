"""One-shot per-phase runner; preserve actual declared inputs before execution."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path('docs/checkpoints/length-guard-perl-2026-11-06')
phase = sys.argv[1]
assert phase in ('before', 'after', 'nearest')
output = ROOT / HERE / phase
output.mkdir()
(output / 'modules').mkdir()
paths = subprocess.check_output(['git', 'ls-files', 'perl', 'specs',
    'tests/fixtures', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
    't/count_length_receiver_contract.t', 't/count_result_guard_composition.t',
    't/count_logical_source_composition.t'], cwd=ROOT, text=True).splitlines()
paths += ['t/length_result_guard_composition.t', str(HERE / 'capture.py')]
paths = sorted(set(paths))
identities = {}
with tarfile.open(output / 'inputs-before.tar.gz', 'w:gz') as archive:
    for path in paths:
        identities[path] = hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
        archive.add(ROOT / path, arcname=path, recursive=False)
(output / 'input-identities.json').write_text(json.dumps(identities, indent=2)+'\n')
normal = ['t/length_result_guard_composition.t']
nearest = ['t/count_length_receiver_contract.t', 't/count_result_guard_composition.t',
           't/count_logical_source_composition.t']
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
        'LINKEDSPEC_LENGTH_MODULE_DIR='+str(HERE / phase / 'modules'),
        'prove', '-v', '-Iperl', *(nearest if phase == 'nearest' else normal)]
(output / 'command.json').write_text(json.dumps(argv, indent=2)+'\n')
result = subprocess.run(argv, cwd=ROOT, capture_output=True)
(output / 'stdout.log.gz').write_bytes(gzip.compress(result.stdout, mtime=0))
(output / 'stderr.log.gz').write_bytes(gzip.compress(result.stderr, mtime=0))
(output / 'exit.txt').write_text(str(result.returncode)+'\n')
assert all(hashlib.sha256((ROOT / p).read_bytes()).hexdigest() == digest
           for p, digest in identities.items()), 'input changed during proof'
print(json.dumps(dict(phase=phase, exit=result.returncode,
    tail=result.stdout.decode().splitlines()[-10:], declared_inputs=len(paths))))

"""Capture complete declared direct inputs, then run actual isolated recovery."""
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'isolated-recovery'
OUT.mkdir()
OLD = Path('docs/checkpoints/knowledge-map-capacity-2026-11-10/objective-current-recovery.stdout.log.gz')
CONSUMER = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    def retain(name):
        path = Path(name)
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        if str(path) not in rows:
            rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
        else:
            assert hashlib.sha256(raw).hexdigest() == rows[str(path)]['sha256']
        return raw
    retain(Path(__file__).relative_to(ROOT))
    previous = json.loads(gzip.decompress(retain(OLD)))
    retain('tests/language-readiness/verify_objectives.py')
    spec = importlib.util.spec_from_file_location('resource_isolated_inputs', ROOT / 'tests/language-readiness/verify_objectives.py')
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    names = set(previous['tracked_inputs']) | set(audit.IMAGE_EVOLUTION_INPUTS)
    names.update((CONSUMER, 'tests/language-readiness/recover_objective_audit_inputs.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py',
        audit.PHASE0_VALUE_TABLE, audit.PHASE0_FIXTURE_TABLE, audit.EVALUATED_VALUES_TABLE,
        audit.SCALAR_NUMERIC_TABLE, audit.DROP_GENERATED_TABLE, audit.COUNT_FIRST_TABLE,
        'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
        'tools/test_historical_objective_images.py'))
    for name in sorted(names):
        retain(name)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        raw = archive.extractfile(member).read()
        assert len(raw) == rows[member.name]['bytes'] and hashlib.sha256(raw).hexdigest() == rows[member.name]['sha256']
        assert member.mode & 0o777 == rows[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', CONSUMER]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment={}), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, env=os.environ.copy(), capture_output=True)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
for name, row in rows.items():
    path = Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
if result.returncode == 0:
    report = json.loads(result.stdout)
    assert set(report['tracked_inputs']) <= rows.keys(), 'actual declared input omitted from before-use capture'
    assert all(rows[name]['sha256'] == value for name, value in report['tracked_inputs'].items())
    assert set(report['observed_artifact_inputs']) <= set(report['tracked_inputs'])
print(json.dumps(dict(actual_exit=result.returncode, captured_direct_inputs=len(rows),
    stdout_bytes=len(result.stdout), stderr_bytes=len(result.stderr),
    scope='Actual isolated historical recovery; native executable/OS closure remains4.2/SESSION5.')))
sys.exit(result.returncode)

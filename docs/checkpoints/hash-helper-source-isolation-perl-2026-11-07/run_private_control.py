"""Exact old/fixed producer bodies at one private path; checkout stays fixed."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
PRIVATE = BASE / 'control-owner.pm'
assert not PRIVATE.exists(), 'one-shot private source control'


def recover(phase):
    with tarfile.open(BASE / phase / 'inputs-before-first-run.tar.gz') as archive:
        return {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}


before, after = recover('before'), recover('qualified_after')
fixed = OWNER.read_bytes()
assert fixed == after[str(OWNER)] and fixed != before[str(OWNER)]
assert all(before[p] == raw == Path(p).read_bytes() for p, raw in after.items()
           if p.startswith('perl/') and p != str(OWNER))
assert before['t/hash_helper_source_isolation.t'] == after['t/hash_helper_source_isolation.t']
for phase, body in (('private_inverse', before[str(OWNER)]), ('private_restored', fixed)):
    PRIVATE.write_bytes(body)
    assert OWNER.read_bytes() == fixed and PRIVATE.read_bytes() == body
    command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'capture_private.py'), phase]
    (BASE / (phase + '-wrapper-command.json')).write_text(json.dumps(dict(argv=command), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for name, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
        (BASE / (phase + '-wrapper-' + name + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
    (BASE / (phase + '-wrapper-exit.txt')).write_text(str(result.returncode) + '\n')
    print(phase, 'wrapper exit', result.returncode, 'owner', hashlib.sha256(body).hexdigest(), flush=True)
    assert result.returncode == 0 and OWNER.read_bytes() == fixed
    with tarfile.open(BASE / phase / 'inputs-before-first-run.tar.gz') as archive:
        assert archive.extractfile(str(PRIVATE)).read() == body
assert PRIVATE.read_bytes() == fixed and OWNER.read_bytes() == fixed
PRIVATE.unlink()  # Exact images survive in both verified before-use archives.
print('Both exact private source images retained; checkout owner never replaced')

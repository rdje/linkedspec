"""One-time landing check; historical recovery does not freeze mutable sources."""
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
assert not (BASE / 'candidate-check-result.json').exists(), 'one-shot candidate check'
with tarfile.open(BASE / 'direct/inputs-before-first-run.tar.gz') as archive:
    compared = []
    for member in archive:
        if member.isfile() and member.name.startswith(('perl/', 'specs/', 't/', 'tests/fixtures/')):
            assert Path(member.name).read_bytes() == archive.extractfile(member).read(), member.name
            assert Path(member.name).stat().st_mode & 0o777 == member.mode & 0o777
            compared.append(member.name)
(BASE / 'candidate-check-result.json').write_text(json.dumps(dict(result='PASS',
    compared_to='direct/inputs-before-first-run.tar.gz', paths=compared), indent=2) + '\n')
print('Candidate SDK/tests/fixtures match actual focused direct inputs')

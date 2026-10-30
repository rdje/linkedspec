"""One-shot retained metadata/producers; never discard compiler object evidence here."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
PREFIX = Path(__file__).parent
WORK = ROOT / '.linkedspec-data/verification/project-data-cleanup46-2'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] == ['--capture'], 'only explicit one-shot capture; normal reverify uses review.py'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == '3332cf3be2695d3456a0c47a3215c44a78b14cf0'
plan = json.loads((WORK / 'plan.json').read_text())
disposal = json.loads((WORK / 'disposal.json').read_text())
assert disposal['deleted_objects'] == plan['totals']['selected_files'] and disposal['quarantine_absent']
assert not (PREFIX / 'intake.json.gz').exists()


def split(source, stem):
    parts = []
    with source.open('rb') as stream:
        while raw := stream.read(31 * 1024 * 1024):
            path = PREFIX / (stem + '-' + str(len(parts) + 1).zfill(3) + '.part')
            with path.open('xb') as output:
                output.write(raw)
            assert path.read_bytes() == raw
            parts.append(dict(path=path.relative_to(ROOT).as_posix(), bytes=len(raw), sha256=sha(raw)))
    return dict(parts=parts, bytes=source.stat().st_size,
                sha256=hashlib.file_digest(source.open('rb'), 'sha256').hexdigest())


manifest = split(WORK / 'entries.jsonl.gz', 'entries')
assert manifest['sha256'] == plan['manifest_sha256']
binary = split(WORK / 'current-test-executable.gz', 'current-test')
paths = set(path for path in WORK.iterdir() if path.is_file()
            and path.name not in ('entries.jsonl.gz', 'current-test-executable.gz'))
verification = ROOT / '.linkedspec-data/verification'
paths.update(path for path in verification.glob('project-data-cleanup46-2*') if path.is_file()
             and path.name not in ('project-data-cleanup46-2-retain.log', 'project-data-cleanup46-2-retain.stderr'))
paths.update(path for path in verification.glob('project_data_cleanup46_2*.py') if path.is_file())
paths.add(verification / 'computed-functions-claim-inputs.py')
paths.add(verification / 'type-slice-docs.py')
paths.add(ROOT / '.linkedspec-data/scratch/ls004-adoption26/adopt.py')
paths.update(PREFIX.glob('*.py'))
inputs = []
aliases = []
seen = {}
for path in sorted(paths):
    assert path.is_relative_to(ROOT) and path.is_file() and not path.is_symlink()
    raw = path.read_bytes()
    name = path.relative_to(ROOT).as_posix()
    digest = sha(raw)
    if digest in seen:
        aliases.append(dict(path=name, bytes=len(raw), sha256=digest, target=seen[digest]))
        continue
    seen[digest] = name
    inputs.append(dict(path=name, bytes=len(raw), sha256=digest,
                       base64=base64.b64encode(raw).decode()))
record = dict(owner='TYPE-REFERENCE-BOOK.1.2.23.3.46.2',
              base='3332cf3be2695d3456a0c47a3215c44a78b14cf0',
              manifest=manifest, current_test_executable=binary, inputs=inputs, aliases=aliases,
              observed_exits=dict(plan=0, controls_initial=1, controls_final=0,
                                  live_owner_refusal=1, idle_liveness=0, quarantine=0,
                                  current_build=0, dispose=0, review=0, preflight=0),
              limits='Dated exact metadata and named object disposal, not physical volume free-space causality. '
              'Original disposable object content is intentionally not retained; exact historical build reproduction '
              'is not claimed. Every non-selected direct entry is preserved. Initial top-level claim discovery earns '
              'no proof credit; nested-schema correction precedes deletion, with complete accepted namespace retained. '
              'Original plan producer predates the dot-traversal guard repair; its fixed source scope and selection '
              'are unchanged. Actual initial/final guard epochs survive. Partial duplicate old-target du was stopped143; '
              'complete scratch census exited0. No cold dependency bootstrap, full suite or dependency implementation audit. '
              'Historical adoption producer is read-only provenance and must never be reexecuted under current policy.')
for row in inputs:
    raw = base64.b64decode(row['base64'])
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
with (PREFIX / 'intake.json.gz').open('xb') as output:
    output.write(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
assert (PREFIX / 'intake.json.gz').stat().st_size < 32 * 1024 * 1024
print(json.dumps(dict(inputs=len(inputs), manifest_parts=len(manifest['parts']), manifest_bytes=manifest['bytes'],
                      executable_parts=len(binary['parts']), intake_bytes=(PREFIX / 'intake.json.gz').stat().st_size)))

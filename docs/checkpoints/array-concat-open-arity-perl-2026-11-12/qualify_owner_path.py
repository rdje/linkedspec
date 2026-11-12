"""Qualify only runtime absolute-vs-relative owner representation; keep original1."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
source = BASE / 'check_epoch.py'
target = BASE / 'check_epoch_qualified.py'
assert not target.exists() and not (BASE / 'before-check.json').exists()
failed = BASE / 'launches/check-before'
assert (failed / 'exit.txt').read_text() == '1\n'
stderr = gzip.decompress((failed / 'stderr.log.gz').read_bytes())
assert b"owner['path'] == owner_path" in stderr and b'AssertionError' in stderr
owners = []
for line in gzip.decompress((BASE / 'before/normal-stderr.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('# ARRAY_CONCAT_NORMAL_OWNER '):
        owners.append(json.loads(line[len('# ARRAY_CONCAT_NORMAL_OWNER '):]))
assert len(owners) == 1
owner = owners[0]
relative = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
assert Path(owner['path']).is_absolute() and Path(owner['path']).resolve() == ROOT / relative
row = json.loads((BASE / 'before/input-identities.json').read_bytes())[relative]
assert owner['bytes'] == row['bytes'] and owner['sha256'] == row['sha256']
body = source.read_text()
old = "assert owner['path'] == owner_path and owner['bytes'] == metadata[owner_path]['bytes'] and owner['sha256'] == metadata[owner_path]['sha256']"
new = "assert Path(owner['path']).resolve() == ROOT / owner_path and owner['bytes'] == metadata[owner_path]['bytes'] and owner['sha256'] == metadata[owner_path]['sha256']"
assert body.count(old) == 1
body = body.replace(old, new)
old_result = '    loaded_owner=owner, old_failed_groups=28 if old else 0,'
new_result = "    loaded_owner=owner, relative_owner=owner_path, runtime_root_sha256=hashlib.sha256(str(ROOT).encode()).hexdigest(), old_failed_groups=28 if old else 0,"
assert body.count(old_result) == 1
body = body.replace(old_result, new_result)
target.write_text(body)
(BASE / 'owner-path-qualification.json').write_text(json.dumps(dict(
    original=source.name, original_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    qualified=target.name, qualified_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
    original_actual_exit=1, original_stderr_bytes=len(stderr), original_stderr_sha256=hashlib.sha256(stderr).hexdigest(),
    relative_owner=relative, runtime_root_sha256=hashlib.sha256(str(ROOT).encode()).hexdigest(),
    cause='The runtime reports its actual repo-root absolute INC path; the original checker required relative spelling. Captured body bytes/hash exactly match the declared owner.',
    correction='Resolve the observed spelling against the actual current root for exact path equality, retaining byte/hash checks. Record relative owner/root-prefix digest so later historical recovery need not depend on the old checkout location. Original source/actual1/channels remain, no SDK replay.'), indent=2) + '\n')
print('Qualified exact owner path representation with unchanged byte/hash checks; original checker1 retained')

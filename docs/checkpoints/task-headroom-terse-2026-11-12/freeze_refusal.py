"""Retain the guarded refusal, exact unchanged source and observed root cause."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
SOURCE=Path('docs/tasks/SPEC-FORMAT-TERSE.md')
ACTIVATION='9f11029e5af9d6168925f532d4c1911637421af3'
assert (BASE/'commands/migration/exit.txt').read_text()=='1\n'
error=gzip.decompress((BASE/'commands/migration/stderr.log.gz').read_bytes())
assert b"ValueError: no closed narrative capacity" in error
assert gzip.decompress((BASE/'commands/migration/stdout.log.gz').read_bytes())==b''
body=SOURCE.read_bytes();assert body==subprocess.check_output(['git','show',ACTIVATION+':'+str(SOURCE)])
row=json.loads((BASE/'inputs-before-migration-identities.json').read_bytes())[str(SOURCE)]
assert len(body)==row['bytes'] and hashlib.sha256(body).hexdigest()==row['sha256'] and SOURCE.stat().st_mode&0o777==row['mode']
head=body.split(b'## Current Frontier\n')[0];matches=list(re.finditer(rb'^- ID: `([^`\n]+)`\n',head,re.M))
nodes=[head[m.start():matches[i+1].start() if i+1<len(matches) else len(head)] for i,m in enumerate(matches)]
assert len(nodes)==189 and all(b'  Narrative:' in node for node in nodes)
assert not Path('docs/history/task-narrative-epochs/TYPE-REFERENCE-BOOK.1.2.23.4.32.json').exists()
image=BASE/'source-after-refusal.md.gz';assert not image.exists();image.write_bytes(gzip.compress(body,mtime=0))
assert gzip.decompress(image.read_bytes())==body
result=dict(refusal='EXPECTED GUARD',actual_migration_exit=1,source=str(SOURCE),source_unmodified=True,source_sha256=hashlib.sha256(body).hexdigest(),manifest_present_after_refusal=False,records=189,records_with_original_archive_pointer=189,root_cause='migrate_epoch excludes both original Narrative and later Narrative epoch pointers before selecting new capacity; the vocabulary-only preflight did not establish remaining capacity.',repair='Keep this source untouched. Under the same headroom32 maintenance leaf select a fresh compatible unpartitioned source and check actual eligibility before its own new operation.',limits='Guarded refusal and exact source state only; no migration, capacity, old archive re-admission, SDK or disk-reclamation credit.')
(BASE/'refusal-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
rows={}
for path in sorted(BASE.rglob('*')):
    if path.is_file():
        assert not path.is_symlink()
        raw=path.read_bytes();rows[str(path)]=dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
(BASE/'refusal-sealed-identities.json').write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
print(json.dumps(result))

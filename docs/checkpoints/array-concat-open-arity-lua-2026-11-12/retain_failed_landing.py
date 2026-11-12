"""Retain the actual failed normal landing before any corrective mutation."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT = BASE / 'landing-failure'
OUT.mkdir()
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip() == 'fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
log = Path('.linkedspec-data/array-concat-open-arity-lua-commit.log')
raw = log.read_bytes()
(OUT / 'normal-combined.log.gz').write_bytes(gzip.compress(raw,mtime=0))
assert gzip.decompress((OUT / 'normal-combined.log.gz').read_bytes()) == raw
statuses = re.findall(r'^  (PASS|FAIL)  ([A-Z-]+)',raw.decode(),re.M)
assert len(statuses) == 10 and sum(status=='PASS' for status,name in statuses)==8
assert {name for status,name in statuses if status=='FAIL'} == {'DOCUMENT-HISTORY','README-STABILITY'}
assert b'aggregate bytes 12589915/12582912' in raw
assert b'change_history current hot shard has a non-dated change heading' in raw
command = ['git','ls-files','--stage','-z']
result = subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'):
    body=getattr(result,channel)
    (OUT / ('index-'+channel+'.log.gz')).write_bytes(gzip.compress(body,mtime=0))
(OUT / 'index-command.json').write_text(json.dumps(dict(argv=command,cwd='.',exit=result.returncode),indent=2)+'\n')
assert result.returncode==0 and result.stderr==b''
paths=[Path('CHANGES.md'),Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'),Path('docs/tasks/TYPE-REFERENCE-BOOK.md'),Path('git_message_brief.txt')]
rows={}
with tarfile.open(OUT/'documents-before-fix.tar.gz','x:gz') as archive:
    for path in paths:
        assert path.is_file() and not path.is_symlink()
        body=path.read_bytes()
        rows[str(path)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=path.stat().st_mode&0o777)
        archive.add(path,arcname=str(path),recursive=False)
with tarfile.open(OUT/'documents-before-fix.tar.gz') as archive:
    assert set(archive.getnames())==rows.keys()
    for member in archive:
        body=archive.extractfile(member).read();row=rows[member.name]
        assert len(body)==row['bytes'] and hashlib.sha256(body).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
(OUT/'document-identities.json').write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
(OUT/'result.json').write_text(json.dumps(dict(normal_exit=1,passed=8,failed=['DOCUMENT-HISTORY','README-STABILITY'],combined_log_sha256=hashlib.sha256(raw).hexdigest(),index_stdout_sha256=hashlib.sha256(result.stdout).hexdigest(),scope='Actual failed normal gate, exact index metadata and document/full-mode preimages; combined channels are not reconstructed as separate hook streams. No SDK replay or global/native liveness claim.'),indent=2)+'\n')
print('Retained actual first normal1/eightPASS-twoFAIL, index metadata and full document preimages; no corrective mutation yet')

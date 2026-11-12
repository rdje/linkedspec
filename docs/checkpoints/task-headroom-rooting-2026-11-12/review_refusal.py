"""Recover the prior guarded refusal without replaying its writer or live state."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
ROOT=Path(__file__).resolve().parents[3]
OLD=Path('docs/checkpoints/task-headroom-terse-2026-11-12')
SOURCE='docs/tasks/SPEC-FORMAT-TERSE.md'
for name,row in json.loads((ROOT/OLD/'refusal-sealed-identities.json').read_bytes()).items():
    p=Path(name);assert not p.is_absolute() and '..' not in p.parts
    raw=(ROOT/p).read_bytes();assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
report=json.loads((ROOT/OLD/'refusal-result.json').read_bytes())
after=gzip.decompress((ROOT/OLD/'source-after-refusal.md.gz').read_bytes())
rows=json.loads((ROOT/OLD/'inputs-before-migration-identities.json').read_bytes())
with tarfile.open(ROOT/OLD/'inputs-before-migration.tar.gz') as archive:
    member=archive.getmember(SOURCE);before=archive.extractfile(member).read()
    assert member.mode&0o777==rows[SOURCE]['mode']
assert before==after==subprocess.check_output(['git','show','9f11029e5af9d6168925f532d4c1911637421af3:'+SOURCE],cwd=ROOT)
assert len(before)==rows[SOURCE]['bytes'] and hashlib.sha256(before).hexdigest()==rows[SOURCE]['sha256']
error=gzip.decompress((ROOT/OLD/'commands/migration/stderr.log.gz').read_bytes())
assert (ROOT/OLD/'commands/migration/exit.txt').read_text()=='1\n'
assert gzip.decompress((ROOT/OLD/'commands/migration/stdout.log.gz').read_bytes())==b''
with tarfile.open(ROOT/OLD/'inputs-before-migration.tar.gz') as archive:
    instrument=archive.extractfile('tools/migrate_task_narrative.py').read()
assert instrument==subprocess.check_output(['git','show','9f11029e5af9d6168925f532d4c1911637421af3:tools/migrate_task_narrative.py'],cwd=ROOT)
assert b"if closed and b'  Narrative:' not in node and b'  Narrative epoch:' not in node:" in instrument

def validate(source,metadata,stderr):
    assert hashlib.sha256(source).hexdigest()==metadata['source_sha256'],'source identity'
    assert metadata['actual_migration_exit']==1 and metadata['manifest_present_after_refusal'] is False,'refusal state'
    assert b'ValueError: no closed narrative capacity' in stderr,'actual refusal reason'
    head=source.split(b'## Current Frontier\n')[0]
    matches=list(re.finditer(rb'^- ID: `([^`\n]+)`\n',head,re.M))
    nodes=[head[m.start():matches[i+1].start() if i+1<len(matches) else len(head)] for i,m in enumerate(matches)]
    assert len(nodes)==metadata['records']==189,'record census'
    assert all(b'  Narrative:' in node for node in nodes) and metadata['records_with_original_archive_pointer']==189,'original pointer exclusion'
validate(after,report,error)
controls=[]
changed=after.replace(b'  Narrative:',b'  Prior narrative:',1);modified=copy.deepcopy(report);modified['source_sha256']=hashlib.sha256(changed).hexdigest()
for label,body,record,channel,reason in (
    ('missing original pointer',changed,modified,error,'original pointer exclusion'),
    ('different producer failure',after,report,error.replace(b'no closed narrative capacity',b'other failure'),'actual refusal reason'),
    ('false post-refusal manifest',after,dict(report,manifest_present_after_refusal=True),error,'refusal state'),
):
    try:validate(body,record,channel)
    except AssertionError as failure:assert reason in str(failure),'control reason'
    else:raise AssertionError('ineffective refusal control:'+label)
    controls.append(label)
print(json.dumps(dict(refusal_recovery='PASS',actual_prior_exit=1,unchanged_source=True,original_pointer_records=189,corruptions=controls,scope='Historical guarded refusal/source/channel recovery only. No replay, current manifest-absence assertion, new capacity, old archive re-admission or native/OS closure.')))

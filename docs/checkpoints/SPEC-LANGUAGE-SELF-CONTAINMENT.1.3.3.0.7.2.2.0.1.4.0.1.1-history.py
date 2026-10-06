"""Independently verify the governed clean-source history rollover and RED controls."""
from pathlib import Path
import copy
import base64
import gzip
import hashlib
import json
import subprocess
import tempfile
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('history.py')
BASE='b2156813fffed53622e640583a46a4ca94186a08'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def git(path):return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
old_manifest=git('docs/history/changes/manifest.jsonl');old_root=git('CHANGES.md')
current_manifest=(ROOT/'docs/history/changes/manifest.jsonl').read_bytes()
current_root=(ROOT/'CHANGES.md').read_bytes()
row=json.loads(current_manifest.splitlines()[1]);target=row['target_path'];archive=(ROOT/target).read_bytes()
rolled=json.loads(Path(PREFIX+'history-rolled-root.json').read_bytes());rolled_root=gzip.decompress(base64.b64decode(rolled['data'],validate=True))
assert len(rolled_root)==rolled['bytes'] and sha(rolled_root)==rolled['sha256'], 'retained generated root identity'
def check(manifest,root,part):
 rows=manifest.splitlines(keepends=True);old=old_manifest.splitlines(keepends=True)
 assert rows[2:]==old[1:], 'prior immutable rows preserved'
 header=json.loads(rows[0]);expected=json.loads(old[0]);expected['segment_count']+=1
 assert header==expected, 'only segment count header advances'
 entry=json.loads(rows[1]);assert entry['source_commit']==BASE and entry['source_path']=='CHANGES.md' and entry['immutable'] is True, 'clean source boundary'
 assert entry['source_blob']==subprocess.check_output(['git','rev-parse',BASE+':CHANGES.md'],cwd=ROOT).decode().strip(), 'source blob identity'
 lines=old_root.splitlines(keepends=True);start=entry['source_start_line'];end=entry['source_end_line']
 assert end==len(lines) and part==b''.join(lines[start-1:end]), 'exact clean source suffix'
 assert len(part)==entry['byte_count'] and len(part.splitlines())==entry['line_count'] and sha(part)==entry['sha256'], 'archive bytes counts and hash'
 first=root.index(b'\n## ')+1;second=root.index(b'\n## ',first)+1
 assert b'.1.4.0.1.1)' in root[first:second], 'new owned record retained'
 assert root+b'\n'==rolled_root, 'only terminal separator normalization'
 assert root[:first]+root[second:]+b'\n'+part==old_root, 'lossless old root reconstruction'
check(current_manifest,current_root,archive)
scratch=ROOT/'.linkedspec-data/scratch/nested-boundary';scratch.mkdir(parents=True,exist_ok=True)
tree=Path(tempfile.mkdtemp(prefix='history-eof-',dir=scratch));assert tree.stat().st_dev==ROOT.stat().st_dev
initial=tree/'rolled.md';initial.write_bytes(rolled_root)
commands=[['git','diff','--no-index','--check','/dev/null',initial.relative_to(ROOT).as_posix()],['git','diff','--check','--','CHANGES.md']]
channels=[]
for command in commands:
 result=subprocess.run(command,cwd=ROOT,capture_output=True)
 channels.append(dict(command=command,exit=result.returncode,stdout=dict(encoding='gzip-base64',bytes=len(result.stdout),sha256=sha(result.stdout),data=base64.b64encode(gzip.compress(result.stdout,mtime=0)).decode()),stderr=dict(encoding='gzip-base64',bytes=len(result.stderr),sha256=sha(result.stderr),data=base64.b64encode(gzip.compress(result.stderr,mtime=0)).decode())))
assert channels[0]['exit']!=0 and b'new blank line at EOF' in gzip.decompress(base64.b64decode(channels[0]['stdout']['data'])), 'actual generated EOF RED'
assert channels[1]['exit']==0 and channels[1]['stdout']['bytes']==channels[1]['stderr']['bytes']==0, 'actual normalized EOF GREEN'
controls=[]
for name,mutate,reason in [
 ('changed prior row',lambda m,r,a:(m.replace(b'"segment_id":"4967"',b'"segment_id":"bad"'),r,a),'prior immutable rows preserved'),
 ('changed source boundary',lambda m,r,a:(m.replace(BASE.encode(),b'0'*40,1),r,a),'clean source boundary'),
 ('lost clean suffix',lambda m,r,a:(m,r,a[:-1]),'exact clean source suffix'),
 ('forged hash',lambda m,r,a:(m.replace(row['sha256'].encode(),b'0'*64,1),r,a),'archive bytes counts and hash'),
 ('lost new record',lambda m,r,a:(m,r.replace(b'.1.4.0.1.1)',b'.foreign)',1),a),'new owned record retained'),
 ('changed retained old root',lambda m,r,a:(m,r+b'corruption\n',a),'only terminal separator normalization'),
]:
 m,r,a=mutate(current_manifest,current_root,archive)
 try:check(m,r,a)
 except AssertionError as error:
  assert str(error)==reason,(name,str(error),reason)
  controls.append(dict(name=name,observed='RED',reason=reason))
 else:raise AssertionError('accepted corruption '+name)
paths=[Path(PREFIX+'history-rolled-root.json').relative_to(ROOT).as_posix(),'CHANGES.md','docs/history/changes/manifest.jsonl',target,'tools/roll_document_history.pl']
report=dict(complete=True,base=BASE,segment_id=row['segment_id'],archive_lines=row['line_count'],archive_bytes=row['byte_count'],manifest_lines=len(current_manifest.splitlines()),manifest_bytes=len(current_manifest),prior_rows=len(old_manifest.splitlines())-1,root_terminal_lf_removed=1,generated_root_bytes=len(rolled_root),source_start_line=row['source_start_line'],source_end_line=row['source_end_line'],inputs=[dict(path=p,sha256=sha((ROOT/p).read_bytes())) for p in paths],instrument_sha256=sha(Path(__file__).read_bytes()),controls=controls,whitespace_runs=channels)
Path(PREFIX+'history.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ('inputs','controls')})+'; six history RED controls')

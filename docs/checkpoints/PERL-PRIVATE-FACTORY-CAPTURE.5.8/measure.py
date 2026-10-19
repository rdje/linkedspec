"""Measure actual rollover/old-cap refusal with complete original-project inputs."""
import base64
import gzip
import hashlib
import json
import re
import stat
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
REG='doctrine/readme_stability/routes.jsonl'
INDEX='docs/decisions/INDEX.md'
MANIFEST='docs/history/changes/manifest.jsonl'
TARGET=ROOT/(PREFIX+'measurement.json')
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
raw=lambda p:(ROOT/p).read_bytes()
assert not TARGET.exists()
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()==BASE
assert json.loads(raw(PREFIX+'preservation.json'))['result']=='PASS'
assert subprocess.run(['git','diff','--cached','--quiet','--'],cwd=ROOT).returncode==0
CHANGE=('## 2026-10-19 — PERL-PRIVATE-FACTORY-CAPTURE.5.8 — Finite continuity capacity\n\n'
    'Measure the exact clean-source change-history rollover and exhausted engineering-note aggregate. '
    'Preserve the whole accepted565-input/129686-byte compiler publication and actual baseline, all '
    'archive/decision bytes and source coordinates. Admit only one measured member/manifest increment, '
    'one finite note envelope and sole indexed authority overhead; unchanged production controls and '
    'exact staged canonical CI govern admission. No runtime change or future archive reserve.\n\n').encode()
NOTE=('## 2026-10-19 — PERL-PRIVATE-FACTORY-CAPTURE.5.8 — Finite continuity capacity\n\n'
    'Required records exhaust the existing note aggregate and trigger change-history rollover. '
    'Measure actual complete-record retention and old-cap refusals before selecting exact finite '
    'growth. Preserve accepted compiler evidence, immutable history and all source coordinates. '
    'One bounded note envelope covers this maintenance, due artifact review, fixture admission, '
    'pipeline and metadata continuation with bounded child splits; no archive reserve follows.\n\n').encode()
originals={p:raw(p) for p in ('CHANGES.md','DEVELOPMENT_NOTES.md',REG,INDEX,MANIFEST)}
for p,value in originals.items():assert value==subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
immutable={}
for directory in ('docs/history/changes','docs/history/development-notes','docs/decisions'):
    listing=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--',directory],cwd=ROOT,text=True).splitlines()
    for p in listing:
        if p in (MANIFEST,INDEX):continue
        old=subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
        assert raw(p)==old;immutable[p]=sha(old)
rows=[json.loads(line) for line in originals[REG].splitlines()]
support={'.gitattributes','.gitignore','.knowledge_map.conf','README.md','README_POLICY.md',PREFIX+'measure.py'}
listing=subprocess.check_output(['git','ls-tree','-r','-z',BASE,'--','tools','scripts','capability_conformance','doctrine','knowledge-map/scripts'],cwd=ROOT)
for entry in filter(None,listing.split(b'\0')):
    header,spelling=entry.split(b'\t');mode,kind,identity=header.decode().split()
    assert kind=='blob' and mode in ('100644','100755')
    support.add(spelling.decode())
git_dir=Path(subprocess.check_output(['git','rev-parse','--absolute-git-dir'],cwd=ROOT,text=True).strip()).resolve()
assert git_dir.is_relative_to(ROOT), 'actual own-project Git contract'
history_source=raw('tools/test_document_history_rollover.py')
revision=re.search(rb'^SOURCE_REVISION = "([0-9a-f]{40})"$',history_source,re.M).group(1).decode()
git_inputs={}
for p in ('CHANGES.md','DEVELOPMENT_NOTES.md',MANIFEST,'docs/history/development-notes/manifest.jsonl'):
    value=subprocess.check_output(['git','show',revision+':'+p],cwd=ROOT)
    git_inputs[revision+':'+p]=dict(sha256=sha(value),bytes_base64=encode(value))
record=dict(result='pending',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),
    original_inputs={p:dict(sha256=sha(v),bytes_base64=encode(v)) for p,v in originals.items()},
    records=dict(changes_base64=encode(CHANGE),engineering_base64=encode(NOTE)),
    preserved=immutable,git_inputs=git_inputs,git_directory=git_dir.relative_to(ROOT).as_posix(),captures={},commands=[])
def retain():TARGET.write_text(json.dumps(record,indent=2)+'\n')
def capsule(name):
    paths=set(support);directories={'perl','specs','t','tests'}
    for row in rows:
        for pattern in row.get('members',[]):
            assert not pattern.startswith(('rgx/','pgen/'))
            for source in ROOT.glob(pattern):
                if source.is_file() and not source.is_symlink():paths.add(source.relative_to(ROOT).as_posix())
        for spelling in row.get('members',[])+row.get('route_targets',[]):
            source=ROOT/spelling
            if source.is_dir():directories.add(spelling)
            elif source.is_file() and not source.is_symlink():paths.add(spelling)
    files={}
    for p in sorted(paths):
        source=ROOT/p;assert not source.is_symlink() and source.resolve().is_relative_to(ROOT)
        assert source.stat().st_dev==ROOT.stat().st_dev
        value=source.read_bytes();files[p]=dict(sha256=sha(value),mode=stat.S_IMODE(source.stat().st_mode),bytes_base64=encode(value))
    payload=gzip.compress(json.dumps(files,sort_keys=True,separators=(',',':')).encode(),mtime=0)
    with (ROOT/(PREFIX+name)).open('xb') as output:output.write(payload)
    return dict(path=PREFIX+name,sha256=sha(payload),files=len(files),directories=sorted(directories))
def run(command):
    tracked=subprocess.check_output(['git','ls-files','--cached','-z'],cwd=ROOT)
    others=subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=ROOT)
    process=subprocess.run(command,cwd=ROOT,capture_output=True)
    row=dict(command=command,returncode=process.returncode,stdout_base64=encode(process.stdout),stderr_base64=encode(process.stderr),
        tracked_namespace_base64=encode(tracked),untracked_namespace_base64=encode(others))
    record['commands'].append(row);retain();return process
record['captures']['original']=capsule('original-inputs.json.gz');retain()
for p,addition in (('CHANGES.md',CHANGE),('DEVELOPMENT_NOTES.md',NOTE)):
    value=originals[p];start=re.search(rb'^## ',value,re.M).start()
    (ROOT/p).write_bytes(value[:start]+addition+value[start:])
record['captures']['unrolled']=capsule('unrolled-inputs.json.gz');retain()
pressure=run(['perl','tools/roll_document_history.pl','--surface','change_history','--check'])
assert pressure.returncode!=0 and b'rollover required for change_history' in pressure.stderr
rolled=run(['perl','tools/roll_document_history.pl','--surface','change_history','--apply'])
assert rolled.returncode==0 and b'archived' in rolled.stdout
record['captures']['rolled']=capsule('rolled-inputs.json.gz');retain()
denied=run(['perl','scripts/check_readme_routing_pressure.pl','--report'])
assert denied.returncode!=0
for reason in (b'surface change_history exceeds control',b'surface engineering_notes exceeds control'):
    assert reason in denied.stderr,(reason,denied.stderr)
assert raw(REG)==originals[REG] and raw(INDEX)==originals[INDEX]
assert all(sha(raw(p))==identity for p,identity in immutable.items())
record['result']='PASS'
record['scope']='Actual original-project complete-record pressure, rollover and old-cap refusal before authority/limit writes. Full routed data, parent-owned helper/config/attribute source, directory existence, per-command Git namespaces and four historical regression inputs are retained. No copied-root portability, immutable host-toolchain or whole canonical admission is inferred. System tools and actual project Git metadata are read-only dependencies; no other repository/submodule implementation is inspected.'
retain()
print('Continuity measurement PASS:',len(immutable),'unchanged prior files;one actual rollover;old member/manifest/aggregate RED')

"""Retain complete fixed input bytes and actual original/current classifier channels."""
from pathlib import Path
import base64,gzip,hashlib,io,json,os,stat,subprocess,tarfile
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('selector-capture.py')
TARGET='tools/check_executable_aggregate_selector_sources.py'
OLD=Path(PREFIX+'before-check_executable_aggregate_selector_sources.py').relative_to(ROOT).as_posix()
def sha(raw):return hashlib.sha256(raw).hexdigest()
def envelope(raw):return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
# The scan's maintained suffix contract is read from its actual original source.
import importlib.util
spec=importlib.util.spec_from_file_location('original_inventory',ROOT/OLD)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
def inventory():
    return sorted(set(filter(None,subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0'))))
paths=inventory();entries=[];excluded=[];files={}
REVISION='95e6a02935155b9ab7b5c30f79a3275529b803da'
git_members={}
for row in filter(None,subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')):
    meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
    if kind==b'blob' and mode in (b'100644',b'100755'):
        git_members[path.decode()]=(mode.decode(),oid.decode(),int(size))
retained={Path(PREFIX+'selector-first-inputs.tar.gz').relative_to(ROOT).as_posix()}

for path in paths:
    item=ROOT/path
    assert not Path(path).is_absolute() and '..' not in Path(path).parts
    mode=item.lstat().st_mode
    if not stat.S_ISREG(mode):
        excluded.append({'path':path,'reason':'nonregular metadata; no payload read'});continue
    raw=item.read_bytes()
    entry={'path':path,'mode':stat.S_IMODE(mode),'bytes':len(raw),'sha256':sha(raw)}
    original=git_members.get(path)
    if original and original[0][-3:]==oct(entry['mode'])[-3:] and original[2]==len(raw) and hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==original[1]:
        entry.update(source='git',revision=REVISION,oid=original[1])
    elif path in retained:
        entry.update(source='retained-artifact')
    else:
        entry.update(source='capsule');files[path]=(raw,entry['mode'])
    entries.append(entry)
def guard():
    assert inventory()==paths,'unchanged actual Git inventory'
    for e in entries:
        item=ROOT/e['path'];raw=item.read_bytes()
        assert stat.S_IMODE(item.stat().st_mode)==e['mode'] and len(raw)==e['bytes'] and sha(raw)==e['sha256'],'unchanged scanned input'
    return len(entries)
report={'complete':False,'instrument_sha256':sha(Path(__file__).read_bytes()),'runs':[],'inventory':paths,'excluded':excluded,'entries':entries,'scope':'Complete regular candidate Git inventory is a conservative supplied-input superset for the executable scanner and composed public/contract/capability checks; suffix-excluded and undecodable bytes are retained too. Nonregular metadata excluded without payload reads; not a minimal observed IO graph. Actual original/current runs use unchanged candidate inputs; only the executed classifier module changes. Full channels and before/after byte/mode/inventory guards retained. Unchanged bytes are recoverable from immutable Git95; exact authored overlays are in the capsule, except the separately retained original capture capsule referenced by its byte identity. Repository-derived same-volume scratch; necessary host Python/OS/Git reads are read-only.'}
commands=[('before',['bash','tools/project_data_run.sh','python3',Path(PREFIX+'selector-probe.py').relative_to(ROOT).as_posix(),'--epoch','before']),('after',['bash','tools/project_data_run.sh','python3',Path(PREFIX+'selector-probe.py').relative_to(ROOT).as_posix(),'--epoch','after']),('composed',['bash','tools/run_python_project_data.sh','tools/check_public_aggregate_selector_surface.py'])]
for epoch,command in commands:
    before=guard();r=subprocess.run(command,cwd=ROOT,capture_output=True)
    report['runs'].append({'epoch':epoch,'command':command,'exit':r.returncode,'stdout':envelope(r.stdout),'stderr':envelope(r.stderr),'inputs_before':before,'inputs_after':guard()})
    assert r.returncode==(1 if epoch=='before' else 0),'actual expected classifier exit'
    print(epoch+' classifier exit'+str(r.returncode),flush=True)
# Write the recovery capsule only after the actual scans, avoiding a self-input.
out=io.BytesIO()
with tarfile.open(fileobj=out,mode='w') as tar:
    for path,(raw,mode) in sorted(files.items()):
        item=tarfile.TarInfo(path);item.size=len(raw);item.mode=mode;tar.addfile(item,io.BytesIO(raw))
capsule=gzip.compress(out.getvalue(),mtime=0)
Path(PREFIX+'selector-inputs.tar.gz').write_bytes(capsule)
report.update(complete=True,capsule_sha256=sha(capsule))
Path(PREFIX+'selector-actual.json').write_text(json.dumps(report,indent=2)+'\n')
print('Complete original/current/composed classifier capture; '+str(len(entries))+' scanned-input members')

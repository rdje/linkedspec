"""Capture the published progressive gate in its actual tracked repository context."""
from pathlib import Path
import base64,gzip,hashlib,json,stat,subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('component.py')
REVISION='ef2dd019bae121674a6e37a2b14d223bf6c7088c'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def channel(raw):return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
manifest=json.loads(Path(PREFIX+'before-inputs.json').read_bytes())
assert manifest['revision']==REVISION
assert subprocess.run(['git','diff','--cached','--quiet'],cwd=ROOT).returncode==0, 'unchanged parent index'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()==REVISION
entries=[]
for original in manifest['entries']:
    path=original['path'];source=ROOT/path
    assert source.is_file() and not source.is_symlink(), 'regular actual-root input'
    raw=source.read_bytes();mode=stat.S_IMODE(source.stat().st_mode)
    old_hash=original.get('baseline_sha256',original['sha256'])
    old_bytes=original.get('baseline_bytes',original['bytes'])
    row={'path':path,'mode':original['mode'],'filesystem_mode':mode,'oid':original['oid'],'original_bytes':old_bytes,
         'original_sha256':old_hash,'bytes':len(raw),'sha256':sha(raw)}
    if row['sha256']!=old_hash:row['actual_root_delta']=channel(raw)
    entries.append(row)
inputs={'revision':REVISION,'entries':entries,'scope':'Conservative complete regular parent Git superset in the actual repository root, with exact retained actual-root byte deltas. Not minimal observed IO. Parent index remains unchanged; Git trackedness is required by the published component gate. Nonregular/Gitlink payloads excluded through original manifest metadata.'}
Path(PREFIX+'component-inputs.json').write_text(json.dumps(inputs,indent=2)+'\n')
command=['bash','tools/run_python_project_data.sh','tools/check_progressive_span_dispatch_contract.py']
result=subprocess.run(command,cwd=ROOT,capture_output=True)
report={'revision':REVISION,'complete':False,'command':command,'exit':result.returncode,
        'stdout':channel(result.stdout),'stderr':channel(result.stderr),'inputs_before':len(entries),
        'instrument_sha256':sha(Path(__file__).read_bytes()),'input_manifest_sha256':sha(Path(PREFIX+'component-inputs.json').read_bytes()),
        'host_scope':'Necessary read-only OS/Python/Git prerequisites; all project data stays on the repository volume. Only public tracked metadata is read; other repositories and submodule implementations are not consulted.'}
Path(PREFIX+'component.json').write_text(json.dumps(report,indent=2)+'\n')
for item in entries:
    path=ROOT/item['path'];raw=path.read_bytes()
    assert len(raw)==item['bytes'] and sha(raw)==item['sha256'] and stat.S_IMODE(path.stat().st_mode)==item['filesystem_mode'], 'unchanged actual-root inputs'
assert subprocess.run(['git','diff','--cached','--quiet'],cwd=ROOT).returncode==0, 'unchanged component index'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()==REVISION
report.update(inputs_after=len(entries),complete=True)
Path(PREFIX+'component.json').write_text(json.dumps(report,indent=2)+'\n')
assert result.returncode==0 and result.stderr==b'', 'healthy actual component gate'
print(result.stdout.decode(),end='')
print(str(len(entries))+' guarded actual-root inputs; '+str(sum('actual_root_delta' in e for e in entries))+' retained byte deltas')

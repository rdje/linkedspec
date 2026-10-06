"""Retain and repair the component capture's full-mode comparison assumption."""
from pathlib import Path
import base64,gzip,hashlib,json,stat,subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('component-mode-repair.py')
def sha(raw):return hashlib.sha256(raw).hexdigest()
def channel(raw):return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
p=Path(PREFIX+'component.py');original=p.read_bytes()
needle=b"    assert mode==int(original['mode'][-3:],8), 'original input mode'\n"
assert original.count(needle)==1, 'original one-shot repair precondition before writes'
Path(PREFIX+'component-rejected-producer.py').write_bytes(original)
command=['bash','tools/run_python_project_data.sh',p.relative_to(ROOT).as_posix()]
r=subprocess.run(command,cwd=ROOT,capture_output=True)
assert r.returncode==1 and b'AssertionError: original input mode' in r.stderr
census=[]
for e in json.loads(Path(PREFIX+'before-inputs.json').read_bytes())['entries']:
    mode=stat.S_IMODE((ROOT/e['path']).stat().st_mode)
    if mode!=int(e['mode'][-3:],8):
        census.append({'path':e['path'],'git_mode':e['mode'],'filesystem_mode':mode,
                       'executable_drift':bool(mode&0o111)!=bool(int(e['mode'][-3:],8)&0o111)})
assert len(census)==36 and not any(e['executable_drift'] for e in census)
assert census[0]=={'path':'noncore/AmbiTiming.pm','git_mode':'100644','filesystem_mode':0o640,'executable_drift':False}
changed=original.replace(needle,b'')
changed=changed.replace(b"row={'path':path,'mode':original['mode'],'oid':original['oid']",b"row={'path':path,'mode':original['mode'],'filesystem_mode':mode,'oid':original['oid']")
changed=changed.replace(b"stat.S_IMODE(path.stat().st_mode)==int(item['mode'][-3:],8)",b"stat.S_IMODE(path.stat().st_mode)==item['filesystem_mode']")
assert changed!=original and b"item['filesystem_mode']" in changed
p.write_bytes(changed)
result={'command':command,'exit':r.returncode,'stdout':channel(r.stdout),'stderr':channel(r.stderr),
        'before_sha256':sha(original),'after_sha256':sha(changed),'mode_differences':census,
        'instrument_sha256':sha(Path(__file__).read_bytes()),
        'scope':'Original capture stops before the component gate executes: full filesystem permissions were incorrectly equated with Git mode. Thirty-six readable files differ, including noncore/AmbiTiming.pm0640 versus tracked100644; no executable-bit drift. Preserve actual filesystem mode separately and guard that same mode after execution. No chmod, tracked mode, source-byte or contract change.'}
Path(PREFIX+'component-mode-repair.json').write_text(json.dumps(result,indent=2)+'\n')
print('Retained actual instrument RED1 and complete36-path mode census; actual modes are separately preserved/guarded')

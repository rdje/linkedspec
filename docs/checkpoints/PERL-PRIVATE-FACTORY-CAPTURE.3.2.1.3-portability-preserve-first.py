from pathlib import Path
import base64,gzip,hashlib,json,subprocess
prefix='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
sha=lambda raw:hashlib.sha256(raw).hexdigest()
entries=subprocess.check_output(['git','diff','--cached','--name-only','-z']).decode().split('\0')
rows=[]
for path in filter(None,entries):
 raw=subprocess.check_output(['git','show',':'+path]);assert Path(path).read_bytes()==raw
 rows.append({'path':path,'sha256':sha(raw),'bytes':len(raw),'data_base64':base64.b64encode(raw).decode()})
assert len(rows)==75
claim=next(row for row in rows if row['path']=='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3.json')
assert claim['bytes']==119230
patch=subprocess.check_output(['git','diff','--cached','--binary','--full-index'])
log=Path('.linkedspec-data/verification/'+Path(prefix).name+'commit01.log').read_bytes()
body={'base':'61a73324f06238418301eac88fd3f908665ecbe3','staged_files':rows,'staged_diff_sha256':sha(patch),'staged_diff_base64':base64.b64encode(patch).decode(),'actual_commit_returncode':1,'commit_log_base64':base64.b64encode(log).decode(),'scope':'Complete rejected75-file staged candidate, full first511-binding/119230 publication and all new input bytes retained before portability correction. Original native/capture/fault/consumer/standard sources and observations are unchanged. Raw diagnostic bytes remain recoverable exactly, including absolute traceback identity; encoding is portable project data, never a configured path.'}
raw=(json.dumps(body,indent=2)+'\n').encode()
envelope={'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
p=Path(prefix+'portability-first-candidate.json');assert not p.exists();p.write_text(json.dumps(envelope,indent=2)+'\n')
print('Retained rejected75-file candidate and actual commit1 before writes; full first511/119230 publication is recoverable.')

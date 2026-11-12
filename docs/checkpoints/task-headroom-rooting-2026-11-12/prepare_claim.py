"""Disclose the actual auxiliary committed-range pack measurement and open legs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.32'
path=Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.3.80.5.json')
raw=path.read_bytes();assert raw==subprocess.check_output(['git','show','9f11029e5af9d6168925f532d4c1911637421af3:'+str(path)])
image=BASE/'claim-schema-template.json.gz';assert not image.exists();image.write_bytes(gzip.compress(raw,mtime=0));assert gzip.decompress(image.read_bytes())==raw
(BASE/'claim-schema-origin.json').write_text(json.dumps(dict(source=str(path),image=str(image),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),mode=path.stat().st_mode&0o777),indent=2)+'\n')
receipt=json.loads((BASE/'push-monitor-current/result.json').read_bytes())
assert receipt['head']=='9f11029e5af9d6168925f532d4c1911637421af3' and receipt['estimated_non_thin_pack_bytes']==1352197517
record=json.loads(raw);record['owner']=OWNER;claim=record['claims'][0]
claim['statement']='At committed HEAD9f11029e5af9d6168925f532d4c1911637421af3 excluding cached origin/main4683555ec51f04b8977812ce4e984c5cc6e6f42c, the one-worker explicit no-sparse non-thin pack is1352197517 bytes for106 outgoing commits. The director1500000000-byte trigger has147802483 bytes remaining; advisory1400000000 has47802483 bytes. This excludes all uncommitted headroom32 work and is not negotiated upload size.'
claim['scope']='One actual local ref-bound operational measurement, retained from the completed post-Lua run with before-use source/policy/wrappers, actual commands/channels, configuration, object metadata and result under '+str(BASE/'push-monitor-current')+'/. Finite task-source/byte-preservation controls are separately described, without runtime/performance/population/completeness inference. No remote freshness, future size or full physical/native closure follows.'
claim['rederive']['result']='Actual0 at9f11029e5/base4683555e:1352197517 bytes,46757 logical/header objects,106 commits,147802483-byte trigger margin and47802483-byte advisory margin. Stream/stat/header/footer/ref/config/source/empty32 checks pass; preparation/trigger false. Actual retained receipts are under push-monitor-current/.'
claim['falsify']['reason']='The committed producer retains historical independent native validation and twelve RED controls at102ec3446 refs. This new9f11029e5 raw artifact has not received a separate independent actual-file size falsification epoch. Parent30 owns that publication qualification; old controls are not new observations.'
target=Path('docs/claims')/(OWNER+'.json');assert not target.exists();target.write_text(json.dumps(record,indent=2)+'\n')
print('Declared actual9f pack rederive and explicit current-falsification30/native4.2 gaps; task data supplies no runtime or population measurement')

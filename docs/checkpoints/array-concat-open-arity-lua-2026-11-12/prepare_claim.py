"""Declare actual auxiliary telemetry and its remaining independently owned gaps."""
import json
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
LEAF='TYPE-REFERENCE-BOOK.1.2.23.3.80.5'
old=Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.3.80.4.json')
raw=old.read_bytes();assert raw==subprocess.check_output(['git','show','HEAD:'+str(old)])
# This is schema reuse only: all ref/count/size statements refer to the new actual receipt.
record=json.loads(raw);record['owner']=LEAF
claim=record['claims'][0]
claim['statement']='At committed HEADfb613736f68f7d1f90df5ade3c0e73c98160ca3f excluding cached origin/main4683555ec51f04b8977812ce4e984c5cc6e6f42c, the one-worker explicit no-sparse non-thin serialized pack is1325660163 bytes. There are105 outgoing commits and174339837 bytes below the director1500000000-byte trigger. This excludes all uncommitted Lua work and is not negotiated upload size.'
claim['scope']='One actual local ref-bound operational measurement. Before-use source/policy/project-wrapper inputs, actual commands/channels, selected configuration, logical object metadata and result survive under '+str(BASE/'push-monitor-current')+'/. Raw packs remain ignored on this volume. No remote freshness/native physical closure/future size/backend completeness follows.'
claim['rederive']['result']='Actual0 atfb613736f/base4683555e:1325660163 bytes,46245 logical/header objects,105 commits,174339837-byte trigger margin and74339837-byte advisory margin. Empty range32 bytes; preparation/trigger false. Source/command/channel/result receipts retained under push-monitor-current/.'
claim['falsify']['reason']='The committed producer retains historical independent validation and twelve REDs at its prior102ec3446 refs. This newfb613736f actual file has not received a separate independent actual-file/historical size falsification epoch. Parent30 owns that qualification; old controls are not new observations.'
target=Path('docs/claims')/(LEAF+'.json');assert not target.exists()
target.write_text(json.dumps(record,indent=2)+'\n')
print('Declared actual fb outgoing-size telemetry with checked rederive and explicit30/4.2 gaps; finite authored Lua examples are not population claims')

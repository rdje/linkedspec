"""Historical activation actor; run once from the recorded clean base."""
from pathlib import Path
import gzip, hashlib, json, subprocess, sys
old='docs/checkpoints/type-cli-runtime-errors/'
sys.path.insert(0,old)
import common as c
base=subprocess.check_output(['git','rev-parse','HEAD']).decode().strip()
assert base=='9dd5e35550036c5093a35986a2b3149f8ea79f9a'
status=c.run(['git','status','--porcelain'])
assert status['returncode']==0 and not c.decode(status['stdout_base64'])
assert Path('git_message_brief.txt').stat().st_size==0
planned={'capability_conformance/signed_array_selector_contract.json','tools/check_signed_array_selector_contract.py','docs/knowledge/signed-array-selector-neutral-contract.md','docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'}
census={}
for name in subprocess.check_output(['git','ls-files','docs/claims']).decode().splitlines():
 value=json.loads(Path(name).read_bytes())
 live=[claim for claim in value['claims'] if claim['durability'].get('status')=='checked' and claim['durability'].get('mode')=='live']
 if live:
  inputs=sorted({item['path'] for claim in live for item in claim['durability']['inputs']})
  census[name]=dict(packet=c.read(name),inputs=inputs)
  assert not (planned & set(inputs)), (name,planned & set(inputs))
prior_paths=set(c.load('publication-inputs.json.gz')['inputs'])|{old+'publication-inputs.json.gz',old+'publication.json','docs/claims/TYPE-REFERENCE-BOOK.1.2.17.8.json'}
tree={}
for row in subprocess.check_output(['git','ls-tree','-rz',base]).split(b'\0'):
 if row:
  metadata,name=row.split(b'\t',1)
  mode,kind,oid=metadata.decode().split()
  if mode in ('100644','100755'): tree[name.decode()]=dict(mode=mode,oid=oid)
images={path:dict(**c.identity(path),git=tree[path]) for path in sorted(prior_paths)}
proof=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(sorted(images))+'\n').encode())
assert proof['returncode']==0 and c.decode(proof['stdout_base64']).decode().splitlines()==[images[path]['git']['oid'] for path in sorted(images)]
prior=c.run(['bash','tools/run_python_project_data.sh',old+'publish.py'])
assert prior['returncode']==0 and not c.decode(prior['stderr_base64'])
assert all(c.identity(path)=={k:v[k] for k in ('sha256','mode')} for path,v in images.items())
folder=Path('docs/checkpoints/signed-array-contract')
assert not folder.exists()
folder.mkdir()
activation=dict(base=base,status=status,prior_images=images,git_verification=proof,prior_readonly=prior,prior_outputs={path:c.read(path) for path in [old+'publication-inputs.json.gz',old+'publication.json','docs/claims/TYPE-REFERENCE-BOOK.1.2.17.8.json']},live_claims=census,planned_paths=sorted(planned),scope='New signed neutral authority/checker and pending public teaching only. No live input intersections; prior publications remain unchanged. Other repositories and Gitlinks are read-only black boxes. All project data stays on-volume.')
with (folder/'activation.json.gz').open('xb') as out: out.write(gzip.compress((json.dumps(activation,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
text=Path(old+'common.py').read_text().replace(c.BASE,base).replace(c.PREFIX,'docs/checkpoints/signed-array-contract/').replace(c.OWNER,'TYPE-REFERENCE-BOOK.1.2.17.1').replace('Perl CLI runtime-error repair','signed-selector neutral contract')
(folder/'common.py').write_text(text)
p=Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text=p.read_text()
start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.1`')
end=text.index('- ID: ',start+5)
node=text[start:end].replace('Status: `pending`','Status: `active`',1).replace('  Planned tier: `canonical`','  Owned paths: capability_conformance/signed_array_selector_contract.json; tools/check_signed_array_selector_contract.py; docs/checkpoints/signed-array-contract/; one new canonical Knowledge card, pending-extension book section and normal task/roadmap/continuity. Frozen v1 authorities/checkers/history and all runtime code remain unchanged.\n  Verification tier: `canonical`\n  Focused checks: Source-bound neutral arithmetic/read/write/diagnostic/effect/identity/copy cases; full historical-v1 compatibility; actual finite oracle/source controls and input/scope denials; complete affected book render; memory/history/Knowledge/whitespace and all normal doctrines.\n  Canonical trigger: Separate cross-backend target contract/checker; exact staged canonical receipt before landing.',1).replace('  Claim verification: none: Pending transition child; declare source-bound measurements before activation.','  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.1.json`',1)
node+='  Activation: Clean '+base+' after CLI17.8 canonical/all10 hooks/post-pointer/brief0. Whole prior publication/manifest/claim and actual clean readonly0 plus independently Git-verified images precede first writes; complete checked-live census has no planned-path intersections. No runtime or signed capability admission.\n\n'
text=text[:start]+node+text[end:]
text=text.replace('| `TYPE-REFERENCE-BOOK.1.2.17.1` | `pending` |','| `TYPE-REFERENCE-BOOK.1.2.17.1` | `active` |',1)
p.write_text(text)
Path('MEMORY.md').write_text('# MEMORY\n\n- activation_commit: `'+base+'` — clean signed neutral17.1 base; derive current HEAD from Git.\n- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.17.8` —9dd5e3555; canonical/all10 hooks/post-pointer/brief0 and clean Git.\n- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.1`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.\n- next_action: Freeze separate signed-selector authority/checker, preserve exact historical-v1 identities and compatibility, retain actual finite source/oracle/input/book controls, then canonical CI and commit.\n- in_flight_uncommitted: Contract17.1 activation only; no runtime or existing contract edits; no background job.\n- proof: docs/checkpoints/signed-array-contract/activation.json.gz; prior CLI/intake publications remain live/unchanged. Never rerun historical capture writers.\n- steering: [-n]=[size-n] when size-n>=0; negative selectors cannot create. Backend children17.2–6 and admission17.7 follow this contract; then14/16/19/21/20 and complete references.\n- limits: Other repositories/submodules read-only black boxes; all project data on-volume; no signed admission or push until PNT exhausted.\n')
print('Contract17.1 activated from clean',base,'with',len(images),'Git-verified prior images and no live intersections')

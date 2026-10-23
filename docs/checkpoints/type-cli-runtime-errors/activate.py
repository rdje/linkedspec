# Historical authored stdin, retained after its successful invocation; do not rerun.
from pathlib import Path
import base64, gzip, hashlib, json, subprocess, sys
prefix='docs/checkpoints/type-cli-runtime-errors/'
old='docs/checkpoints/signed-array-selectors/'
sys.path.insert(0,old)
import common as c
head=subprocess.check_output(['git','rev-parse','HEAD']).decode().strip()
assert head=='329cee31c566cfb054557b8a2ebab62bac015db1'
status=c.run(['git','status','--porcelain'])
assert status['returncode']==0 and not c.decode(status['stdout_base64'])
manifest=c.load('publication-inputs.json.gz')
claim='docs/claims/TYPE-REFERENCE-BOOK.1.2.17.0.json'
images=set(manifest['inputs'])|{old+'publication-inputs.json.gz',old+'publication.json',claim}
tree={}
for row in subprocess.check_output(['git','ls-tree','-rz',head]).split(b'\0'):
 if row:
  metadata,name=row.split(b'\t',1)
  mode,kind,oid=metadata.decode().split()
  if mode in ('100644','100755'): tree[name.decode()]=dict(mode=mode,oid=oid)
identities={path:dict(**c.identity(path),git=tree[path]) for path in sorted(images)}
proof=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(sorted(images))+'\n').encode())
assert proof['returncode']==0 and not c.decode(proof['stderr_base64'])
assert c.decode(proof['stdout_base64']).decode().splitlines()==[identities[path]['git']['oid'] for path in sorted(images)]
planned={'bin/linkedspec','t/trace_cli.t','docs/linkedspec-book/src/public-api/integration-perl.md','docs/knowledge/perl-primary-cli-operational-failures.md'}
census={}
intersections={}
for name in subprocess.check_output(['git','ls-files','docs/claims']).decode().splitlines():
 value=json.loads(c.source(name).read_bytes())
 live=[item for item in value['claims'] if item['durability'].get('status')=='checked' and item['durability'].get('mode')=='live']
 if live:
  census[name]=dict(packet=c.read(name),inputs=sorted({i['path'] for item in live for i in item['durability']['inputs']}))
  hit=planned&set(census[name]['inputs'])
  if hit: intersections[name]=sorted(hit)
assert not intersections, intersections
baseline=c.run(['bash','tools/run_python_project_data.sh',old+'publish.py'])
assert baseline['returncode']==0 and not c.decode(baseline['stderr_base64'])
assert all(c.identity(path)=={key:item[key] for key in ('sha256','mode')} for path,item in identities.items())
value=dict(base=head,status=status,manifest=c.read(old+'publication-inputs.json.gz'),publication=c.read(old+'publication.json'),claim=c.read(claim),inputs=manifest['inputs'],images=identities,git_verification=proof,live_claims=census,direct_intersections=intersections,planned_paths=sorted(planned),baseline=baseline,
 prior_commit='329cee31c - all10 doctrines/post-pointer PASS; brief0 and clean Git',
 redundant_check='Standalone claim check was terminated with143 after the exact normal pre-commit claim check and all10 doctrines passed. It earns no separate PASS credit; no pending job remains.')
folder=Path(prefix)
assert not folder.exists()
folder.mkdir()
with (folder/'activation.json.gz').open('xb') as out: out.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
(folder/'common.py').write_text(Path(old+'common.py').read_text().replace(c.BASE,head).replace(c.PREFIX,prefix).replace(c.OWNER,'TYPE-REFERENCE-BOOK.1.2.17.8').replace('signed-index intake','Perl CLI runtime-error repair'))
(folder/'context.py').write_bytes(Path(old+'context.py').read_bytes())
tree_path=Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text=tree_path.read_text()
start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.8`')
end=text.index('- ID: ',start+5)
node=text[start:end].replace('Status: `pending` / owned P1 public-command defect','Status: `active` / owned P1 public-command defect',1)
node=node.replace('  Planned tier: `canonical`','  Owned paths: bin/linkedspec, t/trace_cli.t, docs/checkpoints/type-cli-runtime-errors/, current Perl CLI Knowledge card/public integration book; normal task/roadmap/continuity. Other repositories/submodules and frozen selector authorities remain unchanged.\n  Verification tier: `canonical`\n  Focused checks: Public Get/descriptor/dump/native/fresh and exact CLI before/after/source-inverse channels; valid null/false/no-match controls; permanent trace/CLI consumers and shared manifest default/POSIX; current Knowledge/complete rendered book; artifact/scope falsifiers, memory/history/whitespace and normal doctrines.\n  Canonical trigger: Public primary-command runtime-error reporting repair; exact staged canonical CI and normal hooks before admission.',1)
node=node.replace('  Claim verification: none: Pending repair; actual before observations belong to intake17.0.','  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.8.json`',1)
node+='  Activation: Clean '+head+' after intake17.0/all10 hooks/post-pointer/brief0. Whole accepted intake publication/claim/manifest and actual readonly0 plus82 independently Git-verified images precede repair writes; complete checked-live census has zero planned-path intersections. Prior intake remains live/unchanged. Redundant standalone gate termination143 is qualified in activation evidence.\n\n'
text=text[:start]+node+text[end:]
text=text.replace('| `TYPE-REFERENCE-BOOK.1.2.17.8` | `pending` |','| `TYPE-REFERENCE-BOOK.1.2.17.8` | `active` |',1)
tree_path.write_text(text)
Path('MEMORY.md').write_text('# MEMORY\n\n- activation_commit: `'+head+'` — clean CLI repair17.8 base; derive current HEAD from Git.\n- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.17.0` —329cee31c; all10 hooks/post-pointer/brief0 and clean Git.\n- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.8`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.\n- next_action: Freeze exact public/library/CLI and permanent regression RED at unchanged bin/linkedspec, then repair context last_error propagation, retain inverse/controls/book/input evidence and run canonical CI before commit.\n- in_flight_uncommitted: CLI17.8 activation only; runtime/test/contract unchanged. No background job. Intake readonly0/whole82-image Git custody and full live census precede writes.\n- proof: docs/checkpoints/type-cli-runtime-errors/activation.json.gz; prior signed-array-selectors/publish.py stays read-only/current. Never rerun historical capture writers.\n- steering: Repair CLI17.8 before signed contract17.1/backend/admission17.2–7; [-n]=[size-n] when size-n>=0. Then14/16/19/raw-regex21/policy20 and complete references.\n- limits: Other repositories/submodules stay read-only black boxes; all data stays on-volume. No signed admission or push until PNT exhausted.\n')
p=Path('LIVE_ACHIEVEMENT_STATUS.md')
text=p.read_text().replace('Signed-selector17 remains active; bounded intake17.0 is complete. P1 Perl CLI17.8 precedes neutral contract17.1 and owned backend children.','P1 Perl CLI TYPE-REFERENCE-BOOK.1.2.17.8 is active at clean329cee31c. Intake17.0 is complete; frozen selector/runtime policy stays unchanged until separate signed children.',1)
p.write_text(text)
print('CLI17.8 activated from clean',head,'with',len(identities),'Git-verified prior images and no live intersections')

"""Preserve accepted pipeline11 evidence before activating deferred indexed writes."""
import base64,gzip,hashlib,json,pathlib,subprocess
R=pathlib.Path.cwd()
B=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
P=R/'docs/checkpoints/type-deferred-indexed-writes'
S=R/'.linkedspec-data/verification/indexed12'
def packet(raw):return dict(sha256=hashlib.sha256(raw).hexdigest(),base64=base64.b64encode(raw).decode())
command=['bash','tools/run_python_project_data.sh','docs/checkpoints/type-registered-array-pipelines/publish5.py']
p=subprocess.run(command,capture_output=True)
run=dict(command=command,returncode=p.returncode,stdout=packet(p.stdout),stderr=packet(p.stderr))
(S/'prior-run.json.gz').write_bytes(gzip.compress(json.dumps(run).encode(),mtime=0))
assert p.returncode==0,(p.stdout,p.stderr)
claims={}
for name in sorted((R/'docs/claims').glob('*.json')):
 raw=name.read_bytes();record=json.loads(raw)
 if not any(c['durability'].get('mode')=='live' for c in record['claims']):continue
 claims[name.relative_to(R).as_posix()]=dict(**packet(raw),mode=name.stat().st_mode&0o7777)
 for claim in record['claims']:
  d=claim['durability']
  if d.get('mode')!='live':continue
  for item in d['inputs']:
   actual=subprocess.check_output(['git','show',B+':'+item['path']])
   assert hashlib.sha256(actual).hexdigest()==item['sha256'],item['path']
P.mkdir()
(P/'bootstrap.py').write_bytes(pathlib.Path(__file__).read_bytes())
(P/'prior-accepted.json.gz').write_bytes(gzip.compress(json.dumps(dict(base=B,claims=claims,readonly=run),sort_keys=True).encode(),mtime=0))
name=R/'docs/claims/TYPE-REFERENCE-BOOK.1.2.11.json'
record=json.loads(name.read_bytes())
for claim in record['claims']:
 d=claim['durability'];assert d['mode']=='live';d.update(mode='historical',revision=B)
name.write_text(json.dumps(record,separators=(',',':'))+'\n')
name=R/'docs/tasks/TYPE-REFERENCE-BOOK.md';text=name.read_text()
text=text.replace('- Status: `active` / next registered pipeline .1.2.11; before enumeration','- Status: `active` / deferred indexed writes .1.2.12; before enumeration',1)
text=text.replace('- Last updated: `2026-10-21`','- Last updated: `2026-10-22`',1)
text=text.replace('  Status: `pending` / P2 defect owned\n  Goal: Execute typed indexed writes inside deferred codeblocks.','  Status: `active` / public contract reproduction\n  Goal: Execute typed indexed writes inside deferred codeblocks.',1)
text=text.replace('  Planned tier: `canonical`\n  Claim verification: none: Pending repair; actual intake diagnosis is bound to claim9.','  Verification tier: `canonical`\n  Focused checks: Public descriptor/Get/dump/native/fresh indexed-write cases; unchanged neutral write fixture; copy/alias, dynamic caller and parameter identities, null presence, ordered effects, exact typed spans, malformed records, permanent/direct dependents, complete book and source-fault restoration.\n  Canonical trigger: Public deferred typed-write availability; exact staged canonical receipt and normal hooks required.\n  Claim verification: none: Active diagnosis; a source-bound record is required before measured completion.\n  Activation: Clean '+B+'; accepted pipeline11 readonly replay and all live claim input blobs verified before writes. Whole prior records/channels retained under docs/checkpoints/type-deferred-indexed-writes/prior-accepted.json.gz; pipeline11 becomes revision-bound without changing observations.',1)
text=text.replace('| 9 | `TYPE-REFERENCE-BOOK.1.2.11` | `pending` | Registered sorted/ordinary length after10. |','| 9 | `TYPE-REFERENCE-BOOK.1.2.11` | `completed` | Registered pipelines/length accepted at '+B[:9]+'. |',1)
text=text.replace('| 10 | `TYPE-REFERENCE-BOOK.1.2.12` | `pending` |','| 10 | `TYPE-REFERENCE-BOOK.1.2.12` | `active` |',1)
name.write_text(text)
name=R/'MEMORY.md'
name.write_text('# MEMORY\n\n- activation_commit: `'+B+'` — clean deferred indexed-write base; Git owns current identity.\n- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.11` — accepted registered pipelines and length.\n- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.12` (active); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.\n- next_action: Reproduce deferred typed indexed writes through public tools, then implement the unchanged atomic write contract with explicit caller/parameter presence and key-kind controls.\n- in_flight_uncommitted: Indexed-write activation and accepted pipeline11 claim custody; finish focused/canonical proof and commit before the next leaf.\n- blockers: none established; last14 and complete inventory remain queued.\n- limits: Other repositories and submodules are read-only black boxes; project data remains on-volume. No push until PNT is exhausted.\n')
print('Activated indexed12 from',B,'after prior readonly PASS; live claim blobs retained exactly')

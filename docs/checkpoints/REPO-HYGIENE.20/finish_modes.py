from pathlib import Path
import json
import re
import sys
sys.path.insert(0,'docs/checkpoints/REPO-HYGIENE.20')
import common as c
import context
path='docs/knowledge/project-root-evidence-filesystem-modes.md'
prior=c.load('prior10.json.gz')
for file,entry in prior['live_claims'].items():
    for claim in json.loads(c.decode(entry['packet']['base64']))['claims']:
        d=claim.get('durability',{})
        if d.get('status')=='checked' and d.get('mode','live')=='live':
            assert path not in {item['path'] for item in d['inputs']},file
before=c.read(path)
old=c.decode(before['base64']).decode()
end=old.index('\n---\n',4)+5
header,body=old[:end],old[end:]
header=re.sub(r'^date:.*$','date: 2026-10-22',header,count=1,flags=re.M)
header=re.sub(r'^evidence:.*$', 'evidence: ".1.5.2 rejects full-stat/Git equality before checker execution:36 readable0640/100644 differences (first noncore/AmbiTiming.pm), no executable drift. Actual permissions stay guarded; no chmod. Healthy4638 inputs/five byte deltas, exact three-edit repair/original RED/four controls remain retained."',header,count=1,flags=re.M)
header=re.sub(r'^reverify:.*$', 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.20/review.py"',header,count=1,flags=re.M)
header=header[:-4]+'evidence_update_2026_10_22: "Hygiene20 rechecks the existing distinction:35x0640/100644 and1x0750/100755. The rejected equality and overgeneralized preparation stay whole; distinct full-mode/Git-field checks and four actual denials pass without chmod."\n---\n'
after=header+body
assert len(after.encode())<=len(old.encode())+3,(len(old.encode()),len(after.encode()))
c.write_new('mode-card-inputs.json.gz',dict(context=context.snapshot(),before=before,
    producer=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix())))
c.source(path).write_text(after)
assert after[len(header):]==body
tree_path='docs/tasks/REPO-HYGIENE.md'
tree_before=c.read(tree_path)
tree=c.decode(tree_before['base64']).decode().replace('Status: `active` / custody permission-representation correction','Status: `done` / focused proof; normal landing required',1)
tree=tree.replace('artifact and helper reverify headers/derived map','artifact, helper and mode reverify headers/derived map',1)
marker='  Limits: Dated metadata, not content ownership/disposability'
tree=tree.replace(marker,'  Custody correction verified: real Git checks blob/mode identity separately; full filesystem permissions match the original manifest or three complete owned packets. Distinct healthy/restored checks and four actual missing-image/executable/other-permission/baseline denials pass. Original failed reviewer/preparation/data remain whole; no chmod. Complete89-input book and actual missing-marker RED pass. Focused scalar/Knowledge/history/doctrines and normal landing remain required.\n'+marker,1)
c.source(tree_path).write_text(tree)
readme_path=c.PREFIX+'README.md'
readme_before=c.read(readme_path)
text=c.decode(readme_before['base64']).decode()
text+='''\nThe rejected custody.py equates full filesystem permissions with Git mode. Its\nhealthy/restored failures and complete36-row observation remain immutable. A\npreparation also overgeneralizes its displayed subset before source writes; the\nactual groups are35x0640/100644 and1x0750/100755. The canonical mode card already\nrecords this distinction. custody_final.py independently checks real Git identity\nand captured full permissions; distinct healthy/restored checks and four actual\nmissing-image/executable/other-permission/baseline denials pass. No chmod occurs.\nOriginal sources and failures receive no successful-proof credit.\n'''
c.source(readme_path).write_text(text)
# Adopt successful recovery actors exactly; their original paths stay in the records.
for source,target in [('hygiene20-resume-header.py','resume_header.py'),
                      ('hygiene20-prepare-custody-final.py','custody_repair.py'),
                      ('hygiene20-finish-modes.py','finish_modes.py')]:
    packet=c.read('.linkedspec-data/verification/'+source)
    with (c.ROOT/c.PREFIX/target).open('xb') as out:out.write(c.decode(packet['base64']))
    (c.ROOT/c.PREFIX/target).chmod(packet['mode'])
c.write_new('mode-card.json.gz',dict(before=before,after=c.read(path),
    tree_before=tree_before,tree_after=c.read(tree_path),readme_before=readme_before,readme_after=c.read(readme_path),
    knowledge_byte_delta=len(after.encode())-len(old.encode()),
    scope='Refresh the already canonical mode rule to its actual current readonly review. All historical body bytes/questions stay exact; original false-equality refusals remain unchanged.'))
print('Mode guidance and actual correction aligned; Knowledge byte delta',len(after.encode())-len(old.encode()))

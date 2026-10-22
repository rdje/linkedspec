from pathlib import Path
import sys
sys.path.insert(0,'docs/checkpoints/REPO-HYGIENE.20')
import common as c
import context
old=c.load('custody-refusal.json.gz')
groups={}
for row in old['differences']:
    key=(row['filesystem_mode'],row['git_mode'])
    groups[key]=groups.get(key,0)+1
assert groups=={(0o640,'100644'):35,(0o750,'100755'):1}
c.write_new('custody-preparation-refusal.json.gz',dict(
    failed_actor=c.read('.linkedspec-data/verification/hygiene20-repair-custody.py'),
    merged_log=c.read('.linkedspec-data/verification/hygiene20-repair-custody.log'),
    groups=[dict(files=n,filesystem_mode=mode,git_mode=git) for (mode,git),n in groups.items()],
    actor=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix()),context=context.snapshot(),
    scope='The first preparation overgeneralized the first displayed0640 rows and stopped before source writes. Actual full groups are35x0640/100644 and1x0750/100755. The original refusal scope sentence is incorrect; its underlying complete data and raw failure remain unchanged.'))
tree=c.source('docs/tasks/REPO-HYGIENE.md').read_text()
tree=tree.replace('Status: `done` / focused proof; normal landing required','Status: `active` / custody permission-representation correction',1)
marker='  Limits: Dated metadata, not content ownership/disposability'
assert tree.count(marker)==1
tree=tree.replace(marker,'  Owned proof defect: Initial custody healthy/restored checks wrongly equate full filesystem permissions with Git mode. The existing canonical mode card already distinguishes them. All36 recorded differences (35x0640/100644,1x0750/100755) and original source/channels remain whole. The first repair preflight also overgeneralized the displayed subset and stops before source writes; its exact source/log remain retained. Correct with separate Git identity and captured full-mode checks, without chmod; test executable and other permission corruption in a distinct epoch.\n'+marker,1)
c.source('docs/tasks/REPO-HYGIENE.md').write_text(tree)
text=c.decode(old['before']['custody.py']['base64']).decode()
text=text.replace("assert all({key:value['images'][path][key] for key in ('sha256','mode')} == item for path,item in declared.items())", "assert all({key:value['images'][path][key] for key in ('sha256','mode')} == item for path,item in declared.items()), 'accepted byte/mode declaration'",1)
line="        assert image['mode'] == int(regular[path]['mode'],8)&0o7777, 'committed full mode'\n"
assert text.count(line)==1
text=text.replace(line,'',1)
marker="    original = json.loads(c.decode(value['claim']['base64']))"
extra="    # Git identity and complete filesystem permissions are distinct fields.\n    for key,path in [('claim','docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json'),\n                     ('publication','docs/checkpoints/type-array-count-first/publication4.json'),\n                     ('manifest','docs/checkpoints/type-array-count-first/publication4-inputs.json.gz')]:\n        assert value['images'][path]['mode'] == value[key]['mode'], 'owned full-mode packet'\n"
assert text.count(marker)==1
text=text.replace(marker,extra+marker,1)
with (c.ROOT/c.PREFIX/'custody_final.py').open('x') as output:output.write(text)
control=c.decode(old['before']['custody_controls.py']['base64']).decode()
control=control.replace("c.PREFIX+'custody.py'", "c.PREFIX+'custody_final.py'")
control=control.replace("('missing','mode','baseline')", "('missing','mode','permission','baseline')")
control=control.replace("    cases['baseline']['baseline']['returncode'] = 1", "    cases['permission']['images']['noncore/AmbiTiming.pm']['mode'] ^= 0o004\n    cases['baseline']['baseline']['returncode'] = 1")
control=control.replace("mode=b'committed full mode'", "mode=b'owned full-mode packet',permission=b'accepted byte/mode declaration'")
control=control.replace('custody-healthy.json.gz','custody2-healthy.json.gz').replace('custody-fault-','custody2-fault-').replace('custody-controls.json.gz','custody2-controls.json.gz')
control=control.replace('missing-image/mode/baseline actual denials','missing-image/executable/full-permission/baseline actual denials')
with (c.ROOT/c.PREFIX/'custody_controls2.py').open('x') as output:output.write(control)
review=c.source(c.PREFIX+'review.py').read_text()
review=review.replace('import custody\n','import custody_final as custody\n',1).replace('custody-controls.json.gz','custody2-controls.json.gz')
review=review.replace("mode='committed full mode',baseline=", "mode='owned full-mode packet',permission='accepted byte/mode declaration',baseline=")
review=review.replace("c.load('custody-fault-'", "c.load('custody2-fault-'").replace('custody_denials=3','custody_denials=4')
c.source(c.PREFIX+'review.py').write_text(review)
c.write_new('custody-repair.json.gz',dict(
    producer=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix()),
    original=old['before'],after={name:c.read(c.PREFIX+name) for name in ('custody_final.py','custody_controls2.py','review.py')},
    scope='Remove only false full-permission/Git equality. Real Git checks committed blob/mode identity; every full filesystem mode independently matches its original manifest or one of three complete owned packets. No chmod; original failed sources/data stay immutable.'))
print('Distinct custody correction prepared from all36 observations; no chmod')

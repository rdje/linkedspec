from pathlib import Path
import sys
sys.path.insert(0,'docs/checkpoints/REPO-HYGIENE.20')
import common as c
path='docs/knowledge/project-root-evidence-filesystem-modes.md'
before=c.read(path)
text=c.decode(before['base64']).decode()
old='36 readable0640/100644 differences (first noncore/AmbiTiming.pm)'
new='36 permission differences, first noncore/AmbiTiming.pm0640/100644'
assert text.count(old)==1
text=text.replace(old,new,1)
assert len(text.encode())<=len(c.decode(before['base64']))+22
c.source(path).write_text(text)
producer=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix())
with (c.ROOT/c.PREFIX/'mode_wording.py').open('xb') as out:out.write(c.decode(producer['base64']))
c.write_new('mode-card-wording.json.gz',dict(before=before,after=c.read(path),producer=producer,
    scope='Clarify that0640/100644 is the first historical difference, not all36. The new dated observation separately retains35/1 complete groups. Original intermediate header remains in mode-card.json.gz. Historical body/questions stay unchanged.'))

from pathlib import Path
import sys
sys.path.insert(0,'docs/checkpoints/REPO-HYGIENE.20')
import common as c
path=c.PREFIX+'document.py'
before=c.read(path)
log=c.read('.linkedspec-data/verification/hygiene20-document.log')
c.write_new('documentation-preflight.json.gz',dict(producer=before,merged_log=log,
    observed_wrapper_exit=1,scope='Knowledge proposal exceeds the remaining two-byte allowance by46; assertion precedes all documentation writes. This is a preflight refusal, not product or falsifier evidence.'))
text=c.decode(before['base64']).decode()
old='Hygiene20 retains dated22234 parent rows and483 Rust incremental rows; zero removals. Actual fresh/lstat/traversal proof and four reason-sensitive reader denials pass; accepted10 whole custody precedes shared writes. No content ownership or purge authority is inferred.'
new='Hygiene20 retains dated22234 parent/483 Rust rows, zero removals; fresh/lstat/traversal proof and four reader denials pass. Whole accepted10 custody precedes shared writes; metadata grants no deletion or purge authority.'
assert text.count(old)==1
c.source(path).write_text(text.replace(old,new,1))
c.write_new('documentation-header-repair.json.gz',dict(before=before,after=c.read(path),
    actor=c.read(Path(__file__).as_posix()),scope='Concise current evidence retains the complete historical card body, every question and unchanged budget.'))

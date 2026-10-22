from pathlib import Path
import sys
sys.path.insert(0,'docs/checkpoints/REPO-HYGIENE.20')
import common as c
before=c.load('documentation-preflight.json.gz')['producer']
after=c.read(c.PREFIX+'document.py')
old='Hygiene20 retains dated22234 parent rows and483 Rust incremental rows; zero removals. Actual fresh/lstat/traversal proof and four reason-sensitive reader denials pass; accepted10 whole custody precedes shared writes. No content ownership or purge authority is inferred.'
new='Hygiene20 retains dated22234 parent/483 Rust rows, zero removals; fresh/lstat/traversal proof and four reader denials pass. Whole accepted10 custody precedes shared writes; metadata grants no deletion or purge authority.'
assert c.decode(after['base64'])==c.decode(before['base64']).replace(old.encode(),new.encode(),1)
failed=c.read('.linkedspec-data/verification/hygiene20-tighten-header.py')
with (c.ROOT/c.PREFIX/'header_preflight.py').open('xb') as stream:stream.write(c.decode(failed['base64']))
c.write_new('documentation-header-repair.json.gz',dict(before=before,after=after,failed_actor=failed,
    actor=c.read(Path(__file__).resolve().relative_to(c.ROOT).as_posix()),
    scope='The concise header change completed. Its original parent failed while recording an absolute __file__ through the relative-only read helper; original parent channels were not retained. Exact failed source and before/after bytes remain. This continuation verifies the one literal replacement; no product or metadata falsifier RED is inferred.'))

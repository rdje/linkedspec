"""Clarify archive-before-fix versus supplied replay after the code repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
CARD='docs/knowledge/perl-factory-capture-framework.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'knowledge-chronology.json')
assert not target.exists()
first=json.loads(gzip.decompress((ROOT/(PREFIX+'knowledge-inputs.json.gz')).read_bytes()))['current'][CARD]
source=ROOT/CARD;before=source.read_bytes()
assert sha(before)==first['sha256']
old=b'546-input evidence is byte/mode preserved and fully replayed before repair.'
new=b'546-input evidence is byte/mode preserved before repair and replayed from saved inputs.'
assert before.count(old)==1
after=before.replace(old,new,1)
size=sum(p.stat().st_size for p in (ROOT/'docs/knowledge').rglob('*.md') if p.is_file())+len(after)-len(before)
assert size<=8388608
source.write_bytes(after)
report=dict(producer_sha256=sha(Path(__file__).read_bytes()),card=CARD,
    before_sha256=sha(before),before_base64=encode(before),after_sha256=sha(after),
    actual_mode=source.stat().st_mode&0o7777,knowledge_bytes=size,
    scope='The input archive and baseline preceded all bound repairs; the full supplied publisher replay occurred afterward against saved inputs. This one-sentence correction preserves the first final Knowledge capture and every original byte; it changes no runtime observation, budget or membership.')
with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
print('Knowledge chronology clarified;full original retained;',size,'current bytes')

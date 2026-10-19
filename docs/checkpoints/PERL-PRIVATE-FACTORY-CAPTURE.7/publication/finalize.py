"""Retain the last cap refusal and use readable bounded serialization."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
DIRECTORY=ROOT/(PREFIX+'publication')
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=DIRECTORY/'before-layout.json.gz';assert not target.exists()
path=DIRECTORY/'publish-final.py';source=path.read_bytes()
prefix=source.split(b'\nassert len(value)<=131072',1)[0]
guard=b'if p.is_file())';assert prefix.count(guard)==1
prefix=prefix.replace(guard,b"if p.is_file() and p.name not in {'finalize.py','verify.py'})",1)
namespace={'__file__':str(path),'__name__':'readonly_before_layout_recurrence'}
exec(compile(prefix,str(path),'exec'),namespace)
draft=namespace['value'];assert len(draft)==131726 and len(namespace['bindings'])==598
combined=(ROOT/'.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.7-publication-final.log').read_bytes()
assert combined.rstrip().endswith(b'AssertionError: (131726, 598)')
history=dict(source_base64=encode(source),source_sha256=sha(source),
    repair_base64=encode((DIRECTORY/'repair.json').read_bytes()),draft_base64=encode(draft),draft_sha256=sha(draft),
    bytes=131726,bindings=598,exit_observed=1,combined_base64=encode(combined),
    scope='Full actual cap failure/source and distinct readonly before-layout recurrence retain the complete598-input logical draft. Only the two new refinement sources are excluded from that old namespace. No writer or native observation is replayed, refreshed or assigned an invented revision.')
with target.open('xb') as output:output.write(gzip.compress(json.dumps(history,sort_keys=True).encode(),mtime=0))
assert source.count(b'indent=2')==1
final=source.replace(b'indent=2',b'indent=1',1)
old=b"for name in ('review-current.py','evidence.py'):"
new=b"for name in ('publication/verify.py','review-current.py','evidence.py'):"
assert final.count(old)==1;final=final.replace(old,new,1)
record=json.loads((DIRECTORY/'repair.json').read_bytes())
record.update(final_source_sha256=sha(final),layout_producer_sha256=sha(Path(__file__).read_bytes()),
    lineage_verifier_sha256=sha((DIRECTORY/'verify.py').read_bytes()),before_layout_sha256=sha(target.read_bytes()),
    layout_scope='Schema/registry require strict bounded JSON and do not mandate indentation. Use readable indent1 with identical predicates/input selection/cap131072 and add whole logical-draft semantic verification. Preserve the exact prior sources/repairs/drafts/failures; no measurement or capacity changes.')
path.write_bytes(final);(DIRECTORY/'repair.json').write_text(json.dumps(record,indent=2)+'\n')
print('Final layout prepared:all prior drafts retained;indent1/same schema/cap;semantic lineage verification added')

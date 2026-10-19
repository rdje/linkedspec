"""Readonly whole logical-draft reconstruction without native or writer replay."""
import base64
import gzip
import hashlib
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
DIRECTORY=ROOT/(PREFIX+'publication')
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
record=json.loads((DIRECTORY/'repair.json').read_bytes())
initial=(DIRECTORY/'publish-initial.py').read_bytes()
initial_raw=gzip.decompress((DIRECTORY/'initial-draft.json.gz').read_bytes())
failure=json.loads((DIRECTORY/'failure.json').read_bytes())
prepared=json.loads(gzip.decompress((DIRECTORY/'preparation-history.json.gz').read_bytes()))
last=json.loads(gzip.decompress((DIRECTORY/'before-layout.json.gz').read_bytes()))
assert sha(initial)==record['original_source_sha256']==failure['original_source_sha256']
assert sha(initial_raw)==record['original_draft_sha256']==failure['retained_draft_sha256']
assert failure['original_exit_observed']==1 and b'AssertionError: (138598, 619)' in decode(failure['original_combined_base64'])
assert prepared['bytes']==132933 and prepared['bindings']==596 and prepared['preflight_exit_observed']==1
assert last['bytes']==131726 and last['bindings']==598 and last['exit_observed']==1
assert b'AssertionError: (131726, 598)' in decode(last['combined_base64'])

def reconstruct(source,raw_value,source_path,overrides,expected_count,expected_bytes):
    assert len(raw_value)==expected_bytes,'whole logical draft byte population'
    claim=json.loads(raw_value)
    bindings=claim['claims'][0]['durability']['inputs']
    assert len(bindings)==len({v['path'] for v in bindings})==expected_count
    for item in bindings:
        p=item['path'];value=overrides.get(p)
        if value is None:value=(ROOT/p).read_bytes()
        assert sha(value)==item['sha256'],'whole logical draft input custody'
    prefix=source.split(b'\nassert len(value)<=131072',1)[0]
    assert prefix!=source
    read_bytes,iterdir,argv=Path.read_bytes,Path.iterdir,sys.argv
    immediate=[ROOT/v['path'] for v in bindings if (ROOT/v['path']).parent==DIRECTORY]
    def supplied_read(path):
        try:name=path.resolve().relative_to(ROOT).as_posix()
        except ValueError:return read_bytes(path)
        return overrides[name] if name in overrides else read_bytes(path)
    def supplied_entries(path):
        return iter(immediate) if path.resolve()==DIRECTORY else iterdir(path)
    namespace={'__file__':str(ROOT/source_path),'__name__':'readonly_logical_draft_reconstruction'}
    try:
        Path.read_bytes=supplied_read;Path.iterdir=supplied_entries;sys.argv=[source_path]
        exec(compile(prefix,source_path,'exec'),namespace)
    finally:Path.read_bytes=read_bytes;Path.iterdir=iterdir;sys.argv=argv
    assert namespace['value']==raw_value,'byte-exact whole logical draft reconstruction'

reconstruct(initial,initial_raw,PREFIX+'publish.py',{PREFIX+'publish.py':initial},619,138598)
prepared_source=decode(prepared['prepared_source_base64'])
prepared_repair=decode(prepared['prepared_repair_base64'])
prepared_raw=decode(prepared['prepared_draft_base64'])
assert sha(prepared_source)==prepared['prepared_source_sha256'] and sha(prepared_raw)==prepared['prepared_draft_sha256']
reconstruct(prepared_source,prepared_raw,PREFIX+'publication/publish-final.py',
    {PREFIX+'publication/publish-final.py':prepared_source,PREFIX+'publication/repair.json':prepared_repair},596,132933)
last_source=decode(last['source_base64']);last_repair=decode(last['repair_base64']);last_raw=decode(last['draft_base64'])
assert sha(last_source)==last['source_sha256'] and sha(last_raw)==last['draft_sha256']
reconstruct(last_source,last_raw,PREFIX+'publication/publish-final.py',
    {PREFIX+'publication/publish-final.py':last_source,PREFIX+'publication/repair.json':last_repair},598,131726)
current=(DIRECTORY/'publish-final.py').read_bytes()
assert sha(current)==record['final_source_sha256']
assert sha((DIRECTORY/'finalize.py').read_bytes())==record['layout_producer_sha256']
assert sha(Path(__file__).read_bytes())==record['lineage_verifier_sha256']
expected=last_source.replace(b'indent=2',b'indent=1',1)
old=b"for name in ('review-current.py','evidence.py'):"
new=b"for name in ('publication/verify.py','review-current.py','evidence.py'):"
assert expected.count(old)==1 and last_source.count(b'indent=2')==1
assert current==expected.replace(old,new,1),'only layout and actual lineage verification added'
print('Publication lineage PASS:whole619/138598,596/132933,598/131726 drafts/input namespaces;no writer/native replay')

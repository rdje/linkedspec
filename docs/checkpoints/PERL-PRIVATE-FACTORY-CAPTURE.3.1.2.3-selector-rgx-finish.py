"""Finish the guarded alias after retaining its actual draft name-binding failure."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM=ROOT/'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
PUBLISHER=ROOT/(PREFIX+'selector-publication-source.py')
draft=ROOT/(PREFIX+'selector-publication-rgx-draft.py');assert not draft.exists()
assert CLAIM.read_bytes()==(ROOT/(PREFIX+'selector-claim-before-rgx.json')).read_bytes()
raw=PUBLISHER.read_bytes();old=b"==m.sha((ROOT/snapshot).read_bytes())";new=b"==old.m.sha((ROOT/snapshot).read_bytes())"
assert raw.count(old)==1
draft.write_bytes(raw);PUBLISHER.write_bytes(raw.replace(old,new,1))
spec=importlib.util.spec_from_file_location('aliased_final_publication',PUBLISHER);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
record=m.expected();encoded=(json.dumps(record,indent=2)+'\n').encode();assert len(encoded)<=131072
CLAIM.write_bytes(encoded)
print('Exact alias completed after retained draft binding failure:',len(encoded),'bytes;',len(record['claims'][2]['durability']['inputs']),'additional current inputs.')

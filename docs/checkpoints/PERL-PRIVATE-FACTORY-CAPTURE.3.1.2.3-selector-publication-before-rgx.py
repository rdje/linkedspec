"""One-shot compose the finite literal migration onto the retained uncommitted correction."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def expected():
 old=module('initial_selector_publication',PREFIX+'selector-publish.py');record=old.expected()
 claim=record['claims'][2]
 claim['statement']+=' Six inference-fixture literals migrate to the retained quoted-literal constructor. Exact277 paired assertion names and supplied33/152 pass; actual unchanged two-input executable classifier rejects six original positives and accepts zero current positives.'
 claim['scope']+=' Original fixture bytes remain exact at CDC and replay in the original504-input proof. The intermediate368-input publication, original reader and three prior evidence channels remain retained. Only six fixture literals and the historical-prose reconstruction change; no runtime or scanner implementation changes. Supplied152 input identities derive from the immutable CDC seed, with only the one current fixture overlay.'
 claim['falsify']['red_control']+=' Exact six original source positives become zero; paired277 plans/names preserve all passing assertions, and complete33-suite supplied consumers pass. All original source and intermediate publication identities remain bound.'
 return record
if __name__=='__main__':
 assert (ROOT/CLAIM).read_bytes()==(ROOT/(PREFIX+'selector-claim-before-source.json')).read_bytes(),'one-shot intermediate publication'
 reviewer=module('current_selector_reader',PREFIX+'selector-review.py');reviewer.proof()
 raw=(json.dumps(expected(),indent=2)+'\n').encode();assert len(raw)<=131072,('bounded claim',len(raw))
 (ROOT/CLAIM).write_bytes(raw)
 print('Final finite source-migration publication:',len(raw),'bytes;',len(expected()['claims'][2]['durability']['inputs']),'additional live inputs.')

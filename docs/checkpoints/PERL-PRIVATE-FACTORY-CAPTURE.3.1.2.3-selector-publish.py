"""One-shot revise an uncommitted candidate, retaining its exact earlier publication."""
import copy,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
spec=importlib.util.spec_from_file_location('selector_review',ROOT/(PREFIX+'selector-review.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
def expected():
 record=json.loads(m.read(PREFIX+'selector-before-claim.json'));assert len(record['claims'])==4
 record['claims'][0]['rederive']['command']=record['claims'][0]['rederive']['command'].replace(PREFIX+'audit-review.py',PREFIX+'selector-review.py')
 repair=record['claims'][2]
 repair['statement']+=' The exact original uncommitted four-claim publication and all504 live bindings replay in supplied isolation; the corrected product explanation passes the unchanged classifier70/36 and complete book57+32/three controls. Three actual reviewer counterfactuals reject then restore.'
 repair['scope']+=' Original repair measurements retain their exact pre-correction source/producer/channel boundary via the retained publication and clean-CDC model blob. Only the obsolete fixture spelling is removed from current teaching; no selector-classifier rule/count, runtime, capacity control or committed measurement changes. All259 original additional inputs remain hash-gated by the retained exact publication and supplied original validator; the shared245 remain directly gated by the first claim. Original57-source book captures omit32 external includes and are qualified as narrower rendered observations; startup .5 retains the wider historical audit. Current89-input book/classifier sources and original proof reconstruction are bound here.'
 repair['rederive']['command']='bash tools/run_python_project_data.sh '+PREFIX+'selector-review.py; bash tools/run_python_project_data.sh '+PREFIX+'capacity.py final'
 repair['rederive']['granularity']+=' Every original504 input identity, exact two-paragraph correction, all70 scanned public files/36 classified references, full57-source/32-include corrected book and three actual proof-reader RED/restoration pairs.'
 repair['rederive']['result']+=' Original504 exact; classifier70/36 RED/GREEN, corrected book57+32/3 and evidence3 PASS.'
 repair['falsify']['red_control']+=' The actual unchanged classifier rejects the original internal fixture spelling; the corrected explanation restores exact36 classified references. Actual proof-reader REDs reject an altered original publication, a forged positive count and an omitted scanned input; original evidence restores before PASS.'
 repair['durability']['inputs']=[{'path':p,'sha256':m.sha(m.read(p)),
  'role':'producer' if Path(p).suffix in ('.py','.pl','.t') else 'input'} for p in m.publication_inputs()]
 return record
if __name__=='__main__':
 assert m.read(CLAIM)==m.read(PREFIX+'selector-before-claim.json'),'one-shot revision of exact uncommitted publication'
 m.proof();raw=(json.dumps(expected(),indent=2)+'\n').encode()
 assert len(raw)<=131072,('bounded revised claim',len(raw))
 (ROOT/CLAIM).write_bytes(raw)
 print('Revised publication:',len(raw),'bytes;',len(expected()['claims'][2]['durability']['inputs']),'additional live inputs; exact original retained.')

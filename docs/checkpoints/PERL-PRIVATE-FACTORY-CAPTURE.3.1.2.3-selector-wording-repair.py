"""One-shot correct a draft policy attribution without changing measured proof."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
CARD='docs/knowledge/perl-factory-fixture-selector-context.md'
before_claim=ROOT/(PREFIX+'selector-claim-before-wording.json')
before_card=ROOT/(PREFIX+'selector-card-before-wording.md')
assert not before_claim.exists() and not before_card.exists(),'one-shot draft wording correction'
original=(ROOT/CLAIM).read_bytes();card=(ROOT/CARD).read_bytes()
old=b'to fit the existing artifact limit;';new=b'to fit its chosen524288-byte capture budget;'
assert card.count(old)==1
before_claim.write_bytes(original);before_card.write_bytes(card)
(ROOT/CARD).write_bytes(card.replace(old,new,1))
spec=importlib.util.spec_from_file_location('final_publication',ROOT/(PREFIX+'selector-publication-source.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
expected=m.expected();prior=json.loads(original)
assert expected['claims'][:2]==prior['claims'][:2] and expected['claims'][3]==prior['claims'][3]
old_claim=dict(prior['claims'][2]);new_claim=dict(expected['claims'][2]);old_claim.pop('durability');new_claim.pop('durability')
assert old_claim==new_claim,'measured proof/disclosure unchanged'
old_inputs={r['path']:r for r in prior['claims'][2]['durability']['inputs']}
new_inputs={r['path']:r for r in expected['claims'][2]['durability']['inputs']}
assert set(new_inputs)-set(old_inputs)=={before_claim.relative_to(ROOT).as_posix(),before_card.relative_to(ROOT).as_posix(),Path(__file__).relative_to(ROOT).as_posix()}
assert all(new_inputs[p]==r for p,r in old_inputs.items() if p!=CARD),'only corrected draft card identity changes'
raw=(json.dumps(expected,indent=2)+'\n').encode();assert len(raw)<=131072
(ROOT/CLAIM).write_bytes(raw)
print('Draft policy attribution corrected; every measured field/hash except current card identity remains exact:',len(raw),'bytes.')

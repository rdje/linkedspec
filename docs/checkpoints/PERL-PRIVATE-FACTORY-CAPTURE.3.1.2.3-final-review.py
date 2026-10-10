"""Readonly combined repair review with exact semantic counterfactual evidence."""
import copy,json
from pathlib import Path
import importlib.util
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
spec=importlib.util.spec_from_file_location('audit_review',ROOT/(PREFIX+'audit-review.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.review()
data=m.load('audit-evidence.json')
assert data['producer_sha256']==m.sha(m.read(PREFIX+'audit-evidence.py'))
assert [r['name'] for r in data['rows']]==['forged_guard','missing_reader_input','forged_runtime_binding','forged_initial_input']
for row in data['rows']:
 expected=json.loads(m.read(row['path']))
 if row['name']=='forged_runtime_binding':expected['claims'][0]['durability']['inputs'][0]['sha256']='0'*64
 else:
  observation=json.loads(m.decoded(expected['stdout']))
  if row['name']=='forged_guard':observation['healthy_audit_guard']['original_log_attempts']=1
  elif row['name']=='missing_reader_input':del observation['tracked_inputs'][next(iter(observation['tracked_inputs']))]
  else:observation['tracked_inputs'][next(iter(observation['tracked_inputs']))]='0'*64
  mutant=json.loads(m.decoded(row['mutant']))
  assert json.loads(m.decoded(mutant['stdout']))==observation,'exact semantic evidence counterfactual'
  expected['stdout']=mutant['stdout']
 assert json.loads(m.decoded(row['mutant']))==expected,'only declared evidence field changes'
 assert row['args']==['python3',PREFIX+'audit-review.py'] and row['exit_code']!=0
 assert row['reason'].encode() in m.decoded(row['stderr'])
 m.decoded(row['stdout'])
assert data['restored']['exit_code']==0 and not m.decoded(data['restored']['stderr'])
assert b'Historical inverse review PASS' in m.decoded(data['restored']['stdout'])
print('Combined historical repair review PASS; four actual semantic evidence REDs and exact restoration retained.')

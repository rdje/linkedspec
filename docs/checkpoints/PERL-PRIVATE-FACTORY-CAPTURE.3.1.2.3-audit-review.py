"""Readonly exact historical inverse, book, frozen runtime and publication review."""
import base64,copy,gzip,hashlib,importlib.util,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BASE='cdc45f9cbddbc53603e885225af2a35688657292'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
AUDITOR='tests/language-readiness/verify_objectives.py'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
RUNTIME='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1.json'
TARGET='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
BOOK='docs/linkedspec-book/src/architecture/structured-format-program.md'
sha=lambda r:hashlib.sha256(r).hexdigest()
read=lambda p:(ROOT/p).read_bytes()
load=lambda tail:json.loads(read(PREFIX+tail))
blob=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)


def module(name,path):
 spec=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m


def decoded(envelope):
 raw=gzip.decompress(base64.b64decode(envelope['data'],validate=True))
 assert envelope['encoding']=='gzip-base64' and len(raw)==envelope['bytes'] and sha(raw)==envelope['sha256'],'complete actual channel identity'
 return raw


def expected_inputs():
 final=json.loads(decoded(load('audit-final.json')['stdout']))
 book=load('book-review.json')
 paths=set(final['tracked_inputs'])|set(book['source_inputs'])|{RUNTIME,'docs/knowledge/perl-contract-factory-historical-inverse.md'}
 paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob('PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-*') if p.is_file())
 paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/knowledge').glob('perl-*-capture*.md') if '3.1.2.3-book-review.py' in p.read_text())
 initial=module('metadata_publication',PREFIX+'repair-publication.py').expected()
 return sorted(paths-{r['path'] for r in initial['claims'][0]['durability']['inputs']})


def review():
 before,after,final=[load('audit-'+s+'.json') for s in ('before','after','final')]
 assert read(PREFIX+'audit-before.py')==blob(AUDITOR),'original auditor preserved'
 assert before['auditor_sha256']==sha(blob(AUDITOR)) and before['candidate']['base']==BASE
 patch=decoded(before['candidate']['full_index_binary_diff'])
 assert b'diff --git a/tests/language-readiness/verify_objectives.py' not in patch,'candidate predates auditor repair'
 assert before['exit_code']!=0 and b'unreviewed boundary contract drift: perl/LinkedSpec/ActionIR/Contracts.pm' in decoded(before['stderr'])
 decoded(before['stdout'])
 assert before['producer_sha256']==after['producer_sha256']==sha(read(PREFIX+'audit-capture.py'))
 assert final['producer_sha256']==sha(read(PREFIX+'audit-final-capture.py'))
 observations=[]
 for row in (after,final):
  assert row['args']==['bash','tools/run_python_project_data.sh',PROOF] and row['exit_code']==0 and not decoded(row['stderr'])
  assert row['proof_sha256']==sha(read(PROOF)) and row['auditor_sha256']==sha(read(AUDITOR))
  data=json.loads(decoded(row['stdout']));observations.append(data)
  assert data['restored_inputs']==134 and data['restored_bytes']==84613241 and len(data['controls'])==22
  assert data['audit_controls']['governance_mutations_rejected']==64
  assert data['healthy_audit_guard']=={'original_log_attempts':0,'tracked_write_attempts':0},'healthy read/write guard remains zero'
  assert data['isolated_deterministic_capture'] is True
 assert set(observations[0]['tracked_inputs'])==set(observations[1]['tracked_inputs']) and len(observations[1]['tracked_inputs'])==183,'complete actual reader input population'
 for i,data in enumerate(observations):
  for path,digest in data['tracked_inputs'].items():
   raw=blob(path) if i==0 and path==BOOK else read(path)
   assert sha(raw)==digest,'actual captured input identity: '+path
 audit=module('current_audit',AUDITOR)
 source='perl/LinkedSpec/ActionIR/Contracts.pm'
 original=subprocess.check_output(['git','show',audit.BOUNDARY_BEFORE+':'+source],cwd=ROOT)
 row=audit.verify_boundary_contract_evolution(source,read(source),sha(original))
 assert row['current']==sha(read(source)) and row['factory_capture_owners']==['PERL-PRIVATE-FACTORY-CAPTURE.2.1.0','PERL-PRIVATE-FACTORY-CAPTURE.2.1.1']
 original_claim=blob(RUNTIME)
 assert read(PREFIX+'before-runtime.json')==original_claim,'original runtime claim exact'
 expected=json.loads(original_claim);count=0
 for claim in expected['claims']:
  d=claim['durability']
  if d.get('mode')=='live':
   for entry in d['inputs']:
    assert sha(blob(entry['path']))==entry['sha256'],'original runtime Git input identity'
    count+=1
   d.update(mode='historical',revision=BASE)
 assert count==241 and json.loads(read(RUNTIME))==expected,'runtime claim mode/revision-only preservation'
 book_args=['python3',PREFIX+'book-review.py']
 p=subprocess.run(book_args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 assert p.returncode==0 and not p.stderr,'current complete book review'
 metadata=module('original_metadata',PREFIX+'repair-publication.py').expected()
 current=json.loads(read(TARGET))
 if len(current['claims'])==4:
  metadata['claims'][0]['rederive']['command']=metadata['claims'][0]['rederive']['command'].replace(PREFIX+'repair-publication.py review',PREFIX+'audit-review.py')
  assert current['claims'][:2]==metadata['claims'],'original capacity publication preserved except readonly replay routing'
  assert [r['name'] for r in current['claims'][2:]]==['contracts-factory-historical-inverse','original-runtime-book-preservation']
  inputs=current['claims'][2]['durability']['inputs']
  assert {r['path'] for r in inputs}==set(expected_inputs()),'complete shared/new repair input population'
 else:
  assert current==metadata,'exact original corrected capacity publication'
 schema=module('actual_schema',PREFIX+'schema.py')
 validator=schema.validator();assert validator.validate(validator.strict_json(read(TARGET)),TARGET,schema.read_input,lambda owner:None)==(len(current['claims']),0)
 print('Historical inverse review PASS:134/84613241;recovery22/evolution64;guard0;runtime241 preserved;book57/2.')


if __name__=='__main__':review()

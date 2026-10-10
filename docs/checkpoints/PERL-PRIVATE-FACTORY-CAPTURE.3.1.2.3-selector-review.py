"""Readonly original-proof replay and exact public explanation correction."""
import base64,hashlib,importlib.util,json,os,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
MODEL='docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
CHECKER='tools/check_public_aggregate_selector_surface.py'
BASE='cdc45f9cbddbc53603e885225af2a35688657292'
OLD=('For example, a controlled probe of the retained private container-inference\n'
     'helper maps `copy('+'array'+'(x))` to `array`; this is an internal fixture input.\n').encode()
NEW=('For example, the historical container-inference fixture supplies a retired\n'
     'aggregate selector to the retained helper and observes the internal `array`\n'
     'classification. This controlled fixture does not describe current authored syntax.\n').encode()
sha=lambda r:hashlib.sha256(r).hexdigest()
read=lambda p:(ROOT/p).read_bytes()
load=lambda tail:json.loads(read(PREFIX+tail))
blob=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)

def module(name,path):
 spec=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def original_inputs():
 record=load('selector-before-claim.json')
 rows=[r for c in record['claims'] if c['durability']['mode']=='live' for r in c['durability']['inputs']]
 assert len(rows)==504 and len({r['path'] for r in rows})==504
 return {r['path']:r['sha256'] for r in rows}

def publication_inputs():
 before=load('selector-before-claim.json')
 paths={PREFIX+'selector-before-claim.json',PREFIX+'final-review.py',PREFIX+'audit-review.py'}
 paths.update(load('selector-book-review.json')['source_inputs'])
 checker=module('public_classifier',CHECKER)
 paths.update(p.relative_to(ROOT).as_posix() for p in checker.public_markdown_paths())
 paths.add(CHECKER)
 paths.add('t/actionir_method_inference_capture.t')
 paths.add('tools/check_executable_aggregate_selector_sources.py')
 paths.add('docs/knowledge/perl-inference-fixture-current-constructor.md')
 paths.add('docs/knowledge/perl-factory-fixture-selector-context.md')
 paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob('PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-selector-*') if p.is_file())
 shared={r['path'] for r in before['claims'][0]['durability']['inputs']}
 return sorted(paths-shared)

def run(args,cwd=ROOT):
 p=subprocess.run(args,cwd=cwd,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',GIT_OPTIONAL_LOCKS='0'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 return {'args':args,'exit_code':p.returncode,'stdout_base64':base64.b64encode(p.stdout).decode(),'stderr_base64':base64.b64encode(p.stderr).decode()}

def proof():
 freeze=load('selector-freeze.json');before=read(PREFIX+'selector-before-claim.json')
 assert freeze['base']==BASE and freeze['claim']==CLAIM and freeze['claims']==4 and freeze['live_inputs']==504
 assert freeze['original_sha256']==sha(before),'original publication identity'
 assert freeze['producer_sha256']==sha(read(PREFIX+'selector-freeze.py'))
 source=blob(MODEL)
 assert freeze['model']==MODEL and freeze['model_git_sha256']==sha(source)
 assert source.count(OLD)==1 and read(MODEL)==source.replace(OLD,NEW,1),'only exact historical fixture explanation changes'
 inputs=original_inputs()
 fixture='t/actionir_method_inference_capture.t'
 original_fixture=blob(fixture)
 retired=('array'+'(x)').encode()
 assert original_fixture.count(retired)==6 and read(fixture)==original_fixture.replace(retired,b'array("x")'),'only six retained constructor fixture literals change'
 originals={p:source if p==MODEL else original_fixture if p==fixture else read(p) for p in inputs}
 assert {p:sha(r) for p,r in originals.items()}==inputs,'all504 original proof input identities'
 # Supply only the original504 inputs and exact original publication. Read-only
 # Git object/index queries use this repository; no other repository is involved.
 with tempfile.TemporaryDirectory(prefix='factory-selector-original-',dir=os.environ['TMPDIR']) as directory:
  supplied=Path(directory);assert supplied.stat().st_dev==ROOT.stat().st_dev
  files=dict(originals,**{CLAIM:before})
  for p,raw in files.items():
   target=supplied/p;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw)
  (supplied/'.git').write_text('gitdir: '+str(ROOT/'.git')+'\n')
  result=run(['python3',PREFIX+'final-review.py'],supplied)
  assert result['exit_code']==0 and not base64.b64decode(result['stderr_base64']),'original supplied repair proof'
  assert b'Combined historical repair review PASS' in base64.b64decode(result['stdout_base64'])
  assert all((supplied/p).read_bytes()==raw for p,raw in files.items()),'original proof supplied inputs remain unchanged'
 classifier=module('actual_public_classifier',CHECKER)
 paths=[p.relative_to(ROOT).as_posix() for p in classifier.public_markdown_paths()]
 assert len(paths)==70
 population={p:sha(read(p)) for p in paths+[CHECKER,PREFIX+'selector-classify.py']}
 for mode in ('before','after'):
  row=load('selector-'+mode+'.json');expected=dict(population)
  if mode=='before':expected[MODEL]=sha(source)
  assert row['mode']==mode and row['inputs']==dict(sorted(expected.items())),'complete actual classifier input population'
  assert row['producer_sha256']==sha(read(PREFIX+'selector-capture.py')) and row['unchanged'] is True
  assert row['args']==['python3',PREFIX+'selector-classify.py']
  out=base64.b64decode(row['stdout_base64'],validate=True);err=base64.b64decode(row['stderr_base64'],validate=True)
  if mode=='before':
   assert row['exit_code']!=0 and MODEL.encode() in err and b'without explicit removed/rejected/migrated historical context' in err,'actual unclassified fixture RED'
  else:
   assert row['exit_code']==0 and not err and json.loads(out)=={'public_files':70,'classified_references':36,'result':'PASS'},'actual unchanged classifier GREEN metrics'
 draft=load('selector-book-draft.json')
 assert draft['result']=='pending' and len(draft['rows'])==1
 assert draft['producer_sha256']==sha(read(PREFIX+'selector-book-draft.py'))
 row=draft['rows'][0]
 assert row['name']=='final' and row['returncode']==0 and row['unchanged'] is True and row['marker_present'] is False
 assert row['output_locations']==['output/architecture/structured-format-program.html']
 assert row['inputs']=={p:sha(read(p)) for p in load('book-review.json')['source_inputs']},'exact failed draft book population'
 assert b'Error updating' in base64.b64decode(row['stderr_base64'],validate=True)
 assert b'examples/integration/word.spec' in base64.b64decode(row['stderr_base64'],validate=True)
 assert b'This controlled fixture does not describe current authored syntax.' not in base64.b64decode(row['html_base64'],validate=True)
 base64.b64decode(row['stdout_base64'],validate=True)
 intermediate=load('selector-source-freeze.json')
 assert intermediate['producer_sha256']==sha(read(PREFIX+'selector-source-freeze.py'))
 assert intermediate['claim_sha256']==sha(read(PREFIX+'selector-claim-before-source.json')) and intermediate['live_inputs']==368
 import gzip
 reader=intermediate['reader'];old_reader=gzip.decompress(base64.b64decode(reader['data'],validate=True))
 assert reader['encoding']=='gzip-base64' and reader['bytes']==len(old_reader) and reader['sha256']==sha(old_reader)
 old_evidence=load('selector-evidence.json')
 assert intermediate['evidence_sha256']==sha(read(PREFIX+'selector-evidence.json'))
 assert old_evidence['reviewer_sha256']==sha(old_reader) and old_evidence['producer_sha256']==sha(read(PREFIX+'selector-evidence.py'))
 scanner='tools/check_executable_aggregate_selector_sources.py'
 for mode in ('before','after'):
  row=load('selector-source-'+mode+'.json')
  expected={fixture:sha(original_fixture if mode=='before' else read(fixture)),PREFIX+'selector-review.py':sha(old_reader if mode=='before' else Path(__file__).read_bytes()),PREFIX+'selector-source-probe.py':sha(read(PREFIX+'selector-source-probe.py')),scanner:sha(read(scanner))}
  assert row['inputs']==expected and row['producer_sha256']==sha(read(PREFIX+'selector-source-capture.py'))
  assert row['args']==['python3',PREFIX+'selector-source-probe.py'] and row['unchanged'] is True and not base64.b64decode(row['stderr_base64'],validate=True)
  observed=json.loads(base64.b64decode(row['stdout_base64'],validate=True))
  assert row['exit_code']==(1 if mode=='before' else 0) and len(observed['positive'])==(6 if mode=='before' else 0)
 seed_path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1-consumers.json'
 seed_raw=blob(seed_path);seed=json.loads(seed_raw)
 assert len(seed['inputs'])==152
 for p,h in seed['inputs'].items():
  assert sha(blob(p))==h
  if p!=fixture:assert sha(read(p))==h,'current supplied consumer identity: '+p
 paired=[]
 for mode in ('before','after','consumers'):
  row=load('selector-fixture-'+mode+'.json');population=dict(seed['inputs'])
  if mode!='before':population[fixture]=sha(read(fixture))
  assert row['inputs']==dict(sorted(population.items())) and row['base']==BASE and row['seed']==seed_path and row['seed_sha256']==sha(seed_raw)
  assert row['producer_sha256']==sha(read(PREFIX+'selector-consumers.py')) and row['unchanged'] is True and row['exit_code']==0
  expected_args=seed['command'] if mode=='consumers' else ['perl','-Iperl',fixture]
  assert row['args']==expected_args
  out=base64.b64decode(row['stdout_base64'],validate=True);err=base64.b64decode(row['stderr_base64'],validate=True)
  if mode=='consumers':assert b'All tests successful.' in out and b'Files=33,' in out
  else:
   import re
   assert re.findall(rb'^1\.\.(\d+)$',out,re.M)==[b'277'] and not re.search(rb'^not ok ',out,re.M) and not err
   names=re.findall(rb'^ok (\d+) - (.*)$',out,re.M)
   assert [int(n) for n,_ in names]==list(range(1,278));paired.append(names)
 assert paired[0]==paired[1],'same complete277 fixture assertion population'
 for mode in ('before','after','consumers'):
  row=load('selector-fixture-draft-'+mode+'.json')
  assert row['inputs']==dict(sorted(seed['inputs'].items())) and row['producer_sha256']==sha(read(PREFIX+'selector-consumers-draft.py'))
  assert row['exit_code']==0 and row['unchanged'] is True
  out=base64.b64decode(row['stdout_base64'],validate=True);base64.b64decode(row['stderr_base64'],validate=True)
  assert (b'Files=33,' in out) if mode=='consumers' else (b'1..277' in out)
 row=run(['python3',PREFIX+'selector-book-review.py'])
 assert row['exit_code']==0 and not base64.b64decode(row['stderr_base64']),'current corrected complete book'
 print('Public explanation review PASS: original504 proof exact; classifier70/36 RED/GREEN; corrected book57+32/3.')

def review():
 proof()
 publisher=module('selector_publication',PREFIX+'selector-publication-source.py')
 assert json.loads(read(CLAIM))==publisher.expected(),'exact bounded revised publication'
 evidence=load('selector-evidence-source.json')
 assert evidence['producer_sha256']==sha(read(PREFIX+'selector-evidence-source.py'))
 assert evidence['reviewer_sha256']==sha(Path(__file__).read_bytes())
 reasons={'forged_original_publication':'original publication identity',
          'forged_positive_metric':'actual unchanged classifier GREEN metrics',
          'missing_classifier_input':'complete actual classifier input population'}
 assert [r['name'] for r in evidence['rows']]==list(reasons)
 for row in evidence['rows']:
  expected=json.loads(read(row['path']))
  if row['name']=='forged_original_publication':expected['claims'][0]['durability']['inputs'][0]['sha256']='0'*64
  elif row['name']=='forged_positive_metric':expected['stdout_base64']=base64.b64encode(b'{"public_files":70,"classified_references":0,"result":"PASS"}\n').decode()
  else:del expected['inputs'][next(iter(expected['inputs']))]
  assert base64.b64decode(row['mutant_base64'],validate=True)==(json.dumps(expected,indent=2)+'\n').encode(),'exact selector evidence counterfactual'
  assert row['reason']==reasons[row['name']] and row['observed']['args']==['python3',PREFIX+'selector-review.py','--proof-only']
  assert row['observed']['exit_code']!=0 and row['reason'].encode() in base64.b64decode(row['observed']['stderr_base64'],validate=True)
  base64.b64decode(row['observed']['stdout_base64'],validate=True)
 assert evidence['restored']['exit_code']==0 and not base64.b64decode(evidence['restored']['stderr_base64'],validate=True)
 assert b'Public explanation review PASS' in base64.b64decode(evidence['restored']['stdout_base64'],validate=True)
 schema=module('claim_schema',PREFIX+'schema.py');validator=schema.validator()
 assert validator.validate(validator.strict_json(read(CLAIM)),CLAIM,schema.read_input,lambda owner:None)==(4,0)
 print('Final finite-capacity/historical/public-explanation review PASS; evidence3 restored; canonical receipt required.')

if __name__=='__main__':
 assert sys.argv[1:] in ([],['--proof-only'])
 proof() if sys.argv[1:] else review()

"""Capture once; subsequently verify publication and its complete input superset readonly."""
import json,sys
import common as c
import review
MANIFEST=c.PREFIX+'manifest.json.gz'
PUBLICATION=c.PREFIX+'publication.json'
CLAIM='docs/claims/'+c.OWNER+'.json'
TARGET='tests/numeric-codeblocks/indexed-writes.json'

def input_paths():
 return sorted(set(c.paths())-{MANIFEST,PUBLICATION,CLAIM})
def validate_scope(actual):
 floor=set(c.load('focused6.json.gz')['context']['inputs'])-{MANIFEST,PUBLICATION,CLAIM}
 assert floor<=set(actual),'measurement input: '+sorted(floor-set(actual))[0] if floor-set(actual) else ''
 assert TARGET in actual,'required fixture: '+TARGET
 assert actual[TARGET]==c.identity(TARGET),'fixture identity: '+TARGET

def validate_identity(declared,actual):
 assert set(declared)==set(actual),'input population'
 for path,packet in actual.items():
  assert declared[path]['sha256']==packet['sha256'],'input bytes: '+path
  assert declared[path]['mode']==packet['mode'],'input mode: '+path

def controls():
 supplied=c.load('artifact2-inputs.json.gz')
 result={}
 for name,declared in supplied['cases'].items():
  try:validate_identity(declared,supplied['actual'])
  except AssertionError as error:result[name]=dict(rejected=True,reason=str(error))
  else:result[name]=dict(rejected=False,reason='')
 return result

def scope_control():
 actual={path:c.identity(path) for path in input_paths()}
 try:validate_scope(actual)
 except AssertionError as error:return dict(rejected=True,reason=str(error))
 return dict(rejected=False,reason='')

def record(result):
 producers=set(c.SOURCES+review.verify.SUITES)
 producers.update(path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl','.js')))
 producers.update(['tools/project_data_run.sh','tools/project_data_env.sh','tools/run_python_project_data.sh'])
 inputs=[dict(path=p,sha256=c.identity(p)['sha256'],role='producer') for p in sorted(producers)]
 inputs.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
 return dict(version=1,owner=c.OWNER,claims=[dict(
  name='perl-deferred-indexed-writes',
  statement='Perl deferred codeblocks execute typed indexed writes through the atomic nested-write runtime, retain caller null presence across forwarded and registry-returned calls and copied fixed/rest parameter identity, preserve operand order and detached roots, and reject guarded or malformed writes before effects.',
  scope='Fixed public descriptor/native/Get-dump/independently emitted Perl routes plus unchanged frozen write success/failure/evaluation cases; malformed controls cover basic write fields and operand headers, without general recursive ActionIR-carrier admission. Native error routes retain the existing intentional library level-zero trace; success routes stay quiet. No other-backend, requested signed selectors17, deferred with16, last14, complete reference or wider historical-audit admission. Every measurement retains its actual capture epoch; final continuity is a later authored publication. The conservative current watchset includes every regular main-repository input except this claim and its own manifest/publication. It is a superset, not a minimal I/O graph. Gitlinks, symlinks and documented public dependency/tool outputs remain read-only prerequisites.',
  rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',granularity='Each fixed public value or exact typed error, direct frozen structural/error-span/evaluation-failure case, parameter restoration and malformed/guard control. Focused proof counts top-level TAP groups; exact staged canonical proof governs admission.',result=f"{result['cases']} cases/{result['accepted_red']} accepted RED/{result['accepted_controls']} controls;{result['faults']} restored source faults;{result['direct_suites']}/{result['direct_tap']} top-level TAP;complete book{result['book_inputs']}/{result['book_examples']} exact examples and rendered heading RED;actual identity/scope denials and validator bypass/restoration."),
  falsify=dict(status='checked',hypothesis='Adding a dispatch alone can mutate aliases, coerce bound null, lose caller/parameter presence, snapshot before RHS effects, or execute operands before the receiver guard.',oracle='Existing frozen v1 fixture and ordinary-action controls predate this repair; explicit values/kinds, exact error fields/spans, original objects/effect sequences and independent mutated-result/receiver probes distinguish the competing implementations.',red_control='Actual accepted-source rollback fails the corrected fixed plan; reapplication passes with exact byte restoration. Thirteen syntax-valid actual source faults reject and restore. Missing/byte/mode declarations reject, admit with the actual validator bypass, reject after restoration, and restore source exactly. Actual named fixture omission rejects against the measured-input floor, admits under scope bypass and rejects after restoration. The removed rendered heading rejects. Paragraph reflow preserves the prior page signature after verifying the sole content-addressed search reference. Reproduced original HTML matches exactly; native JSON.parse calibrates complete old/new search data. Every posting, URL and option stays exact while document bodies differ only in whitespace. Actual supplied prose mutation and resealed URL corruption reject. Initial wrapper collision, parenthesized-assignment fixture, negative-error adapter and wrong ordinary caller-presence fault selection retain actual sources/observations without successful-control credit. Fact-budget drafts refused before writes; their original unsaved tool channels are unavailable.'),
  durability=dict(status='checked',mode='live',inputs=inputs))])

def main():
 if sys.argv[1:]==['--controls']:print(json.dumps(controls(),sort_keys=True));return
 if sys.argv[1:]==['--scope-control']:print(json.dumps(scope_control(),sort_keys=True));return
 assert sys.argv[1:] in ([],['--capture'])
 capture=sys.argv[1:]==['--capture']
 actual={path:c.identity(path) for path in input_paths()}
 validate_scope(actual)
 result=review.check()
 evidence=c.load('artifact2-run.json.gz')
 assert evidence['restored'] and evidence['denials']==3
 assert all(item['rejected'] for item in controls().values())
 assert evidence['original']==c.read(c.PREFIX+'publish.py')
 for name in ('healthy','restored_run'):
  assert evidence[name]['returncode']==0
  assert json.loads(c.decode(evidence[name]['stdout_base64']))==controls()
 assert evidence['bypass']['returncode']==0
 assert all(not item['rejected'] for item in json.loads(c.decode(evidence['bypass']['stdout_base64'])).values())
 scope=c.load('scope2-run.json.gz')
 assert scope['restored'] and scope['target']==TARGET
 assert scope['original']==c.read(c.PREFIX+'publish.py')
 for name in ('healthy','green'):
  assert scope[name]['returncode']==0
  assert json.loads(c.decode(scope[name]['stdout_base64']))==dict(rejected=False,reason='')
 for name in ('omitted','validator_restored'):
  assert scope[name]['returncode']==0
  assert json.loads(c.decode(scope[name]['stdout_base64']))==dict(rejected=True,reason='measurement input: '+TARGET)
 assert scope['bypass']['returncode']==0
 assert json.loads(c.decode(scope['bypass']['stdout_base64']))==dict(rejected=False,reason='')
 if capture:
  assert not (c.ROOT/CLAIM).exists()
  c.save('manifest.json.gz',dict(base=c.BASE,inputs=actual,scope='Conservative complete regular main-repository population; measured epochs retain exact pre-publication inputs, changed/new plain source images and real accepted Git reconstruction.'))
 validate_identity(c.load('manifest.json.gz')['inputs'],actual)
 validate_identity(actual,{path:c.identity(path) for path in input_paths()})
 value=record(result)
 publication=dict(result=result,record=value)
 if capture:
  c.save('publication.json',publication)
  with (c.ROOT/CLAIM).open('x') as stream:stream.write(json.dumps(value,separators=(',',':'))+'\n')
 else:
  assert json.loads((c.ROOT/CLAIM).read_bytes())==value
  assert c.load('publication.json')==publication
 print('Deferred indexed-write publication PASS:',len(actual),'inputs;',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()

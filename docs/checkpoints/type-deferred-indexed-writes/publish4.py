"""Capture once; subsequently verify publication and its complete input superset readonly."""
import json,sys
import common as c
import review4 as review
MANIFEST=c.PREFIX+'manifest4.json.gz'
PUBLICATION=c.PREFIX+'publication4.json'
CLAIM='docs/claims/'+c.OWNER+'.json'
TARGET='tests/numeric-codeblocks/indexed-writes.json'
TARGETS=[TARGET,'t/multiline_helper_pattern_validation.t','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json']

def input_paths():
 return sorted(set(c.paths())-{MANIFEST,PUBLICATION,CLAIM})
def validate_scope(actual):
 floor=set(c.load('focused10.json.gz')['context']['inputs'])-{MANIFEST,PUBLICATION,CLAIM}
 assert floor<=set(actual),'measurement input: '+sorted(floor-set(actual))[0] if floor-set(actual) else ''
 for path in TARGETS:
  assert path in actual,'required fixture: '+path
  assert actual[path]==c.identity(path),'fixture identity: '+path

def validate_identity(declared,actual):
 assert set(declared)==set(actual),'input population'
 for path,packet in actual.items():
  assert declared[path]['sha256']==packet['sha256'],'input bytes: '+path
  assert declared[path]['mode']==packet['mode'],'input mode: '+path

def controls():
 supplied=c.load('artifact5-inputs.json.gz')
 result={}
 for name,declared in supplied['cases'].items():
  try:validate_identity(declared,supplied['actual'])
  except AssertionError as error:result[name]=dict(rejected=True,reason=str(error))
  else:result[name]=dict(rejected=False,reason='')
 return result

def scope_control():
 # Scope probes need the complete population and named fixture identities.
 # Main publication below still computes/verifies every regular byte identity.
 actual=dict.fromkeys(input_paths())
 for path in TARGETS:
  if path in actual:actual[path]=c.identity(path)
 try:validate_scope(actual)
 except AssertionError as error:return dict(rejected=True,reason=str(error))
 return dict(rejected=False,reason='')

def base_record(result):
 producers=set(c.SOURCES+review.verify.SUITES)
 producers.add('t/actionir_tracking_predicate_probe.pl')
 producers.update(path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl','.js')))
 producers.update(['tools/project_data_run.sh','tools/project_data_env.sh','tools/run_python_project_data.sh'])
 inputs=[dict(path=p,sha256=c.identity(p)['sha256'],role='producer') for p in sorted(producers)]
 inputs.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
 return dict(version=1,owner=c.OWNER,claims=[dict(
  name='perl-deferred-indexed-writes',
  statement='Perl deferred codeblocks execute typed indexed writes through the atomic nested-write runtime, retain caller null presence across forwarded and registry-returned calls and copied fixed/rest parameter identity, preserve operand order and detached roots, and reject guarded or malformed writes before effects.',
  scope='Fixed public descriptor/native/Get-dump/independently emitted Perl routes plus unchanged frozen write success/failure/evaluation cases; malformed controls cover basic write fields and operand headers, without general recursive ActionIR-carrier admission. Native error routes retain the existing intentional library level-zero trace; success routes stay quiet. No other-backend, requested signed selectors17, deferred with16, last14, complete reference or wider historical-audit admission. Every measurement retains its actual capture epoch; final continuity is a later authored publication. The conservative current watchset includes every regular main-repository input except this claim and its own manifest/publication. It is a superset, not a minimal I/O graph. Gitlinks, symlinks and documented public dependency/tool outputs remain read-only prerequisites.',
  rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish4.py',granularity='Each fixed public value or exact typed error, direct frozen structural/error-span/evaluation-failure case, parameter restoration and malformed/guard control. Focused proof counts top-level TAP groups; exact staged canonical proof governs admission.',result=f"{result['cases']} cases/{result['accepted_red']} accepted RED/{result['accepted_controls']} controls;{result['faults']} restored source faults;{result['direct_suites']}/{result['direct_tap']} top-level TAP;complete book{result['book_inputs']}/{result['book_examples']} exact examples and rendered heading RED;actual identity/scope denials and validator bypass/restoration."),
  falsify=dict(status='checked',hypothesis='Adding a dispatch alone can mutate aliases, coerce bound null, lose caller/parameter presence, snapshot before RHS effects, or execute operands before the receiver guard.',oracle='Existing frozen v1 fixture and ordinary-action controls predate this repair; explicit values/kinds, exact error fields/spans, original objects/effect sequences and independent mutated-result/receiver probes distinguish the competing implementations.',red_control='Actual accepted-source rollback fails the corrected fixed plan; reapplication passes with exact byte restoration. Thirteen syntax-valid actual source faults reject and restore. Missing/byte/mode declarations reject, admit with the actual validator bypass, reject after restoration, and restore source exactly. Actual named fixture omission rejects against the measured-input floor, admits under scope bypass and rejects after restoration. The removed rendered heading rejects. Paragraph reflow preserves the prior page signature after verifying the sole content-addressed search reference. Reproduced original HTML matches exactly; native JSON.parse calibrates complete old/new search data. Every posting, URL and option stays exact while document bodies differ only in whitespace. Actual supplied prose mutation and resealed URL corruption reject. Initial wrapper collision, parenthesized-assignment fixture, negative-error adapter and wrong ordinary caller-presence fault selection retain actual sources/observations without successful-control credit. Fact-budget drafts refused before writes; their original unsaved tool channels are unavailable.'),
  durability=dict(status='checked',mode='live',inputs=inputs))])


def parsed(run):
 assert run['returncode']==0 and not c.decode(run['stderr_base64'])
 return json.loads(c.decode(run['stdout_base64']))

def record(result):
 value=base_record(result)
 claim=value['claims'][0]
 claim['statement']+=' Complete tracked scalar statements preserve their assigned values without void-context warnings; incomplete raw-regex compatibility fragments stay intact.'
 claim['scope']+=' Whole publication2 and actual readonly PASS precede a path-specific whitespace attribute for the verbatim paragraph separator; runtime and book bytes are unchanged. Ten fixed lifecycle/value controls and eight explicit-host raw compatibility controls supplement the write population. Rejected first canonical/publication evidence is recoverable as an unpublished source epoch, not an accepted Git revision. The exact new public limitation paragraph is an explicit authored overlay in the rendered comparison. General raw-regex fidelity remains outside admission and is owned by TYPE-REFERENCE-BOOK.1.2.21.'
 claim['rederive']['result']=(f"{result['cases']} public cases/{result['accepted_red']} accepted-source RED/{result['accepted_controls']} controls;"
  f"{result['faults']} restored source faults;{result['direct_suites']}/{result['direct_tap']} top-level TAP;"
  f"book{result['book_inputs']}/{result['book_examples']} examples with explicit authored overlay and heading/prose/URL denials;"
  'ten lifecycle/value and eight current/accepted explicit-host compatibility controls; three identity denials and three independently omitted required fixtures, including bypass/restoration.')
 claim['falsify']['red_control']=(f"Actual accepted-source rollback/reapplication and {result['faults']} syntax-valid source faults distinguish dispatch, presence, order, guards, detachment, assignment result, void-context warnings and raw-fragment wrapping. "
  'The first exact staged canonical gate completed1035 and failed only800/1034; its complete combined log, original claim/publication/manifest and recoverable input epoch remain retained. '
  'The repaired statement and raw-fragment controls pass without weakening those permanent oracles. The first repaired raw probe required quiet execution without a default host subject; the accepted compiler has the same warning and value7. Explicit subject calibration passes both source epochs. '
  'Actual missing/byte/mode declarations reject, admit under validator bypass, reject after restoration and restore source exactly. Each of three real required-fixture omissions rejects against the measured-input floor, admits under scope bypass and rejects after restoration. '
  'The original book4 HTML reproduces exactly. The exact authored limitation paragraph is inserted in the retained old-source frame before comparing against the current render. All other source changes remain the prior paragraph reflow. After this explicit overlay, complete search data differ only in document-body whitespace; native JSON.parse calibrates both datasets. Actual missing heading, prose-source mutation and resealed URL corruption reject. '
  'All prior wrong controls, wrapper/fixture/adapter mistakes and failed instruments remain retained and receive no extra successful-control credit. Exact staged canonical CI and normal hooks govern final admission.')
 claim['scope']+=' The private predicate comparison retains every field in296 original loaded/cold rows. Only26 nested-consumer rows deliberately change assignment source text, including one source-target conversion count4->5; this is not unchanged consumer emission or full-helper admission. The original native fixture/probe remain byte-exact. Source9 is unchanged; focused10 adds the direct private consumer to the prior21 suites.'
 claim['rederive']['result']+=f" Private rows{result['private_rows']}/{result['private_changed_rows']} deliberate consumer changes; actual old-result inverse rejects both source and executable value oracles and restores GREEN."
 claim['falsify']['red_control']+=' Canonical2 completes private91/32246 and rejects only tracking predicate26/516. Its whole publication3, actual readonly PASS, full log and recoverable input epoch precede edits. Full row comparison leaves callback ordering, local aliases, tied fetches, boolean/error effects and private authority exact. The consumer expected-source projection changes only the documented assignment format and additional emitted identifier read, never observed rows or original captures. The actual syntax-valid old-result inverse rejects the updated consumer and independent executable value oracle, then restores both. Earlier sixteen source-fault9 controls remain their actual unchanged-source epoch; the extra inverse is not counted as a new distinct fault family.'
 import copy
 value['claims'].append(dict(
  name='raw-assigned-regex-payload-intake',
  statement='Two LF subjects show that assigned raw multiline regexes match an inserted-semicolon pattern instead of their authored pattern on both accepted-source replay and current native/fresh Perl routes.',
  scope='Exactly the two retained source/subject pairs in compatibility3.plans.intake, with an explicitly supplied Perl default subject. This is a diagnosed existing defect, not repaired regex support or a portable raw-host capability. TYPE-REFERENCE-BOOK.1.2.21 owns repair after grouped19 and before20/inventory. CRLF and the complete raw-regex family are not inferred from this intake.',
  rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish4.py',granularity='Each fixed LF subject, native/fresh route and accepted/current source epoch; full channels and exact source restoration are retained.',result='Both source epochs produce false/true for original/semicolon subjects, while the authored literal oracle produces true/false. The inserted-semicolon oracle produces false/true.'),
  falsify=dict(status='checked',hypothesis='The wrong result is only an uninitialized host subject or a regression introduced by deferred-write tracking.',oracle='An independent direct Perl literal oracle tests authored and inserted-semicolon patterns on the same explicitly supplied subjects. Actual accepted-source rollback supplies the source-history control.',red_control='All four native/fresh subject comparisons in each source epoch disagree with the authored oracle and agree with its inserted-semicolon twin, without warnings or runtime errors. Emitted handler text retains the inserted semicolon; original source/subject bytes and oracle producer are hash-gated.'),
  durability=copy.deepcopy(claim['durability'])))
 return value

def main():
 if sys.argv[1:]==['--controls']:print(json.dumps(controls(),sort_keys=True));return
 if sys.argv[1:]==['--scope-control']:print(json.dumps(scope_control(),sort_keys=True));return
 assert sys.argv[1:] in ([],['--capture'])
 capture=sys.argv[1:]==['--capture']
 actual={path:c.identity(path) for path in input_paths()}
 validate_scope(actual)
 result=review.check()
 evidence=c.load('artifact5-run.json.gz')
 assert evidence['restored'] and evidence['denials']==3
 assert all(item['rejected'] for item in controls().values())
 assert evidence['original']==c.read(c.PREFIX+'publish4.py')
 for name in ('healthy','restored_run'):
  assert evidence[name]['returncode']==0
  assert json.loads(c.decode(evidence[name]['stdout_base64']))==controls()
 assert evidence['bypass']['returncode']==0
 assert all(not item['rejected'] for item in json.loads(c.decode(evidence['bypass']['stdout_base64'])).values())
 scope=c.load('scope5-runs.json.gz')
 assert scope['restored'] and scope['targets']==TARGETS
 assert scope['original']==c.read(c.PREFIX+'publish4.py')
 for target,observations in scope['runs'].items():
  assert target in TARGETS
  for name in ('healthy','green'):
   assert parsed(observations[name])==dict(rejected=False,reason='')
  for name in ('omitted','validator_restored'):
   assert parsed(observations[name])==dict(rejected=True,reason='measurement input: '+target)
  assert parsed(observations['bypass'])==dict(rejected=False,reason='')
 assert set(scope['runs'])==set(TARGETS)
 if capture:
  prior=c.load('rejected-canonical2.json.gz')['files'][CLAIM]
  assert c.read(CLAIM)==prior,'unpreserved claim candidate'
  c.save('manifest4.json.gz',dict(base=c.BASE,inputs=actual,scope='Conservative complete regular main-repository population; measured epochs retain exact pre-publication inputs, changed/new plain source images and real accepted Git reconstruction.'))
 validate_identity(c.load('manifest4.json.gz')['inputs'],actual)
 validate_identity(actual,{path:c.identity(path) for path in input_paths()})
 value=record(result)
 publication=dict(result=result,record=value)
 if capture:
  c.save('publication4.json',publication)
  with (c.ROOT/CLAIM).open('w') as stream:stream.write(json.dumps(value,separators=(',',':'))+'\n')
 else:
  assert json.loads((c.ROOT/CLAIM).read_bytes())==value
  assert c.load('publication4.json')==publication
 print('Deferred indexed-write publication PASS:',len(actual),'inputs;',json.dumps(result,sort_keys=True))
if __name__=='__main__':main()

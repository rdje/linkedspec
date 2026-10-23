"""Prepare a new publisher after the running measurement sequence finishes."""
import sys
sys.path.insert(0,'docs/checkpoints/type-deferred-indexed-writes')
import common as c
original=c.read(c.PREFIX+'publish.py')
text=c.decode(original['base64']).decode()
def replace(needle,replacement,count=1):
 global text
 assert text.count(needle)==count,(needle,text.count(needle),count)
 text=text.replace(needle,replacement)
replace('import review\n','import review2 as review\n')
replace('manifest.json.gz','manifest2.json.gz',3)
replace('publication.json','publication2.json',3)
replace('focused6.json.gz','focused8.json.gz')
replace('artifact2-inputs.json.gz','artifact3-inputs.json.gz')
replace('artifact2-run.json.gz','artifact3-run.json.gz')
replace("TARGET='tests/numeric-codeblocks/indexed-writes.json'", "TARGET='tests/numeric-codeblocks/indexed-writes.json'\nTARGETS=[TARGET,'t/multiline_helper_pattern_validation.t']")
replace(" assert TARGET in actual,'required fixture: '+TARGET\n assert actual[TARGET]==c.identity(TARGET),'fixture identity: '+TARGET", " for path in TARGETS:\n  assert path in actual,'required fixture: '+path\n  assert actual[path]==c.identity(path),'fixture identity: '+path")
replace("def scope_control():\n actual={path:c.identity(path) for path in input_paths()}\n", "def scope_control():\n # Scope probes need the complete population and named fixture identities.\n # Main publication below still computes/verifies every regular byte identity.\n actual=dict.fromkeys(input_paths())\n for path in TARGETS:\n  if path in actual:actual[path]=c.identity(path)\n")
replace('def record(result):\n','def base_record(result):\n')
replace("c.PREFIX+'publish.py'","c.PREFIX+'publish2.py'",3)
start=text.index(" scope=c.load('scope2-run.json.gz')")
end=text.index(' if capture:\n',start)
text=text[:start]+''' scope=c.load('scope3-runs.json.gz')
 assert scope['restored'] and scope['targets']==TARGETS
 assert scope['original']==c.read(c.PREFIX+'publish2.py')
 for target,observations in scope['runs'].items():
  assert target in TARGETS
  for name in ('healthy','green'):
   assert parsed(observations[name])==dict(rejected=False,reason='')
  for name in ('omitted','validator_restored'):
   assert parsed(observations[name])==dict(rejected=True,reason='measurement input: '+target)
  assert parsed(observations['bypass'])==dict(rejected=False,reason='')
 assert set(scope['runs'])==set(TARGETS)
'''+text[end:]
replace("  assert not (c.ROOT/CLAIM).exists()", "  prior=c.load('rejected-canonical1.json.gz')['publication'][CLAIM]\n  assert c.read(CLAIM)==prior,'unpreserved claim candidate'")
replace("with (c.ROOT/CLAIM).open('x')", "with (c.ROOT/CLAIM).open('w')")
record='''
def parsed(run):
 assert run['returncode']==0 and not c.decode(run['stderr_base64'])
 return json.loads(c.decode(run['stdout_base64']))

def record(result):
 value=base_record(result)
 claim=value['claims'][0]
 claim['statement']+=' Complete tracked scalar statements preserve their assigned values; incomplete raw-regex compatibility fragments stay intact.'
 claim['scope']+=' Ten fixed lifecycle/value controls and eight explicit-host raw compatibility controls supplement the write population. Rejected first canonical/publication evidence is recoverable as an unpublished source epoch, not an accepted Git revision. The exact new public limitation paragraph is an explicit authored overlay in the rendered comparison. General raw-regex fidelity remains outside admission and is owned by TYPE-REFERENCE-BOOK.1.2.21.'
 claim['rederive']['result']=(f"{result['cases']} public cases/{result['accepted_red']} accepted-source RED/{result['accepted_controls']} controls;"
  f"{result['faults']} restored source faults;{result['direct_suites']}/{result['direct_tap']} top-level TAP;"
  f"book{result['book_inputs']}/{result['book_examples']} examples with explicit authored overlay and heading/prose/URL denials;"
  'ten lifecycle/value and eight current/accepted explicit-host compatibility controls; three identity denials and two independently omitted required fixtures, including bypass/restoration.')
 claim['falsify']['red_control']=(f"Actual accepted-source rollback/reapplication and {result['faults']} syntax-valid source faults distinguish dispatch, presence, order, guards, detachment, assignment result and raw-fragment wrapping. "
  'The first exact staged canonical gate completed1035 and failed only800/1034; its complete combined log, original claim/publication/manifest and recoverable input epoch remain retained. '
  'The repaired statement and raw-fragment controls pass without weakening those permanent oracles. The first repaired raw probe required quiet execution without a default host subject; the accepted compiler has the same warning and value7. Explicit subject calibration passes both source epochs. '
  'Actual missing/byte/mode declarations reject, admit under validator bypass, reject after restoration and restore source exactly. Each of two real required-fixture omissions rejects against the measured-input floor, admits under scope bypass and rejects after restoration. '
  'The original book4 HTML reproduces exactly. The exact authored limitation paragraph is inserted in the retained old-source frame before comparing against the current render. All other source changes remain the prior paragraph reflow. After this explicit overlay, complete search data differ only in document-body whitespace; native JSON.parse calibrates both datasets. Actual missing heading, prose-source mutation and resealed URL corruption reject. '
  'All prior wrong controls, wrapper/fixture/adapter mistakes and failed instruments remain retained and receive no extra successful-control credit. Exact staged canonical CI and normal hooks govern final admission.')
 import copy
 value['claims'].append(dict(
  name='raw-assigned-regex-payload-intake',
  statement='Two LF subjects show that assigned raw multiline regexes match an inserted-semicolon pattern instead of their authored pattern on both accepted-source replay and current native/fresh Perl routes.',
  scope='Exactly the two retained source/subject pairs in compatibility2.plans.intake, with an explicitly supplied Perl default subject. This is a diagnosed existing defect, not repaired regex support or a portable raw-host capability. TYPE-REFERENCE-BOOK.1.2.21 owns repair after grouped19 and before20/inventory. CRLF and the complete raw-regex family are not inferred from this intake.',
  rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish2.py',granularity='Each fixed LF subject, native/fresh route and accepted/current source epoch; full channels and exact source restoration are retained.',result='Both source epochs produce false/true for original/semicolon subjects, while the authored literal oracle produces true/false. The inserted-semicolon oracle produces false/true.'),
  falsify=dict(status='checked',hypothesis='The wrong result is only an uninitialized host subject or a regression introduced by deferred-write tracking.',oracle='An independent direct Perl literal oracle tests authored and inserted-semicolon patterns on the same explicitly supplied subjects. Actual accepted-source rollback supplies the source-history control.',red_control='All four native/fresh subject comparisons in each source epoch disagree with the authored oracle and agree with its inserted-semicolon twin, without warnings or runtime errors. Emitted handler text retains the inserted semicolon; original source/subject bytes and oracle producer are hash-gated.'),
  durability=copy.deepcopy(claim['durability'])))
 return value

'''
text=text.replace('\ndef main():','\n'+record+'def main():',1)
compile(text,c.PREFIX+'publish2.py','exec')
with (c.ROOT/c.PREFIX/'publish2.py').open('x') as stream:stream.write(text)
c.save('publication2-preparation.json.gz',dict(original=original,current=c.read(c.PREFIX+'publish2.py'),
 producer=c.read(c.PREFIX+'prepare_publication2.py')))
print('Prepared distinct current publisher with two fixture witnesses and diagnostic ownership.')

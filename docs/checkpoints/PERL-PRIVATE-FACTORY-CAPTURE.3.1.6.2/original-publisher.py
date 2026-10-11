"""Publish once or reconstruct readonly the bounded number/string callback claim."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE='5bf068c924f190fdc7b9f904b9b9720cc638f2e9'
LEAF='PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2'
PREFIX='docs/checkpoints/'+LEAF+'-'
CARD='docs/knowledge/perl-scalar-receiver-required-capture.md'
OLD_PRODUCER='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1-publish-claim.py'
TARGET=ROOT/('docs/claims/'+LEAF+'.json')
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT/(PREFIX+tail+'.json')).read_bytes())


for tail in ('review.py','evidence.py','compatibility/run.py'):
    result=subprocess.run(['python3',PREFIX+tail],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
    assert result.returncode==0 and not result.stderr,('actual readonly proof',tail,result.stderr)
runtime,evidence,freeze=[record(tail) for tail in ('review','evidence','freeze')]
expected={'preserved_bindings':314,'native_inputs':193,'paired_inputs':195,'callbacks':16,'branches':73,
          'authority_rows':8,'public_rows':4,'cold_rows':4,'assertions':436,'original_red':12,'original_controls':424,
          'supplied_suites':63,'supplied_assertions':12315,'book_sources':89,'book_controls':3,
          'faults':{family+'-'+label:6 if family=='string' and label=='copied-arguments' else count
                    for family in ('number','string') for label,count in
                    [('raw-callback',6),('wrapper-identity',2),('copied-arguments',4),('late-map-selection',3),('missing-diagnostic',4)]}}
assert runtime['result']==evidence['result']=='PASS'
assert all(runtime[key]==value for key,value in expected.items()),'actual bounded runtime population'
assert len(evidence['controls'])==7
assert record('evidence-reached')=={'healthy':evidence['healthy'],'rows':evidence['controls']},'all actual reached channels'
correction=record('review-correction')
draft=(ROOT/correction['original_producer']).read_bytes()
assert correction['original_sha256']==digest(draft) and correction['reported_exit']==1 and correction['owner']==LEAF
old="any(tag in left['name'] for tag in ('-missing-','-noncode-'))"
new="re.fullmatch(r'(number|string)-(missing|noncode)-(trim_action_ir_value|parse_method_function_expr)',left['name'])"
assert draft.decode().count(old)==1 and draft.decode().replace(old,new)==(ROOT/(PREFIX+'review.py')).read_text(),'exact disclosed reader-only repair'
paths=set(runtime['input_metadata'])|set(evidence['inputs'])|{CARD}
for candidate in (ROOT/'docs/checkpoints').glob(LEAF+'-*'):
    if candidate.is_file():
        paths.add(candidate.relative_to(ROOT).as_posix())
    elif candidate.is_dir():
        paths.update(p.relative_to(ROOT).as_posix() for p in candidate.rglob('*') if p.is_file())
inputs=[{'path':path,'sha256':digest((ROOT/path).read_bytes()),
         'role':'producer' if Path(path).suffix in ('.py','.pl','.pm','.t') else 'input'} for path in sorted(paths)]
before=(ROOT/freeze['before']).read_bytes()
assert before==subprocess.check_output(['git','show',BASE+':'+freeze['claim']],cwd=ROOT)
old_claim=json.loads(before)
bindings=[entry for claim in old_claim['claims'] if claim['durability']['mode']=='live' for entry in claim['durability']['inputs']]
assert len(bindings)==314 and freeze['verified_bindings']==314
historical=[{'path':freeze['claim'],'sha256':digest(before),'role':'input'},
 {'path':OLD_PRODUCER,'sha256':digest(subprocess.check_output(['git','show',BASE+':'+OLD_PRODUCER],cwd=ROOT)),'role':'producer'}]
statement=('Four required number/string callbacks retain eager actual-reference selection, maps, contexts, effects, successful error '
           'states and fatal identity while isolating child publication. Actual splitter substring aliases and parser-returned call '
           'object/source annotations stay native, including shared returned references. Immutable193-input native16 callback/73 branch/'
           '8 authority/4 public-source/4 cold rows precede assertions and the exact two-return change. Paired436 TAP retains12 original '
           'authority REDs/424 controls/all436 current GREEN. Five separate syntax-valid whole-module faults for each owner fail6/2/4/3/4 '
           'for number and6/2/6/3/4 for string. Supplied63 suites/195 inputs/12315 assertions, seven actual evidence RED/restorations and '
           'full book89/three controls pass; every actual ordered command path/header/plan and predecessor diagnostic byte is checked.')
limits=('The first independent reader exited1 on an overbroad diagnostic-label match before producing a report; its exact draft and '
        'observed outer-boundary transcription are retained. A prematurely started evidence attempt exited1 at the missing report before '
        'copying inputs or retaining results; its identical producer later runs against the actual successful prerequisite. Neither failed '
        'preflight is claimed as a partial success. Native/runtime/capture/fault/consumer/book instruments and observations were never '
        'refreshed. Only supplied diagnostic locations are normalized in comparison copies; raw channels and exact stems/source lines stay '
        'retained. Supplemental standard syntax/public Phase0 passes1035 with complete channels but no full transitive input capsule, '
        'benchmark or private/canonical admission. Canonical fixture registration stays separately owned by .7 before pipeline .6.')
data={'version':1,'owner':LEAF,'claims':[
 {'name':'scalar-required-callback-isolation','statement':statement,'scope':runtime['scope']+' '+limits,
  'rederive':{'status':'checked','command':'bash tools/run_python_project_data.sh '+PREFIX+'publish-claim.py; independently review.py, consumer-review.py and evidence.py under that wrapper. Defaults readonly; capture/freezer/fault/evidence writers are one-shot.',
             'granularity':'Every native16 callback/73 branch/8 actual authority/4 public-source/4 cold row; every193 native/current and195 paired/direct input; all436 paired assertion names/12 original failures; all ten whole syntax-valid mutants and actual named failures; every63 suite command path/header/plan; seven changed/restored input populations/channels; all89 book/include inputs and three actual controls.',
             'result':statement},
  'falsify':{'status':'checked','hypothesis':'Raw required children may donate publication, wrapper identity may replace actual known references, copied arguments may preserve substring and string annotation effects, later parser map entries may replace eagerly selected callbacks, or missing semantic reasons/checkpoint suites may pass reconstruction.',
            'oracle':'Immutable first-native ledgers plus authored ordinary outcomes, actual callback and shared-returned-object identities/source annotations, actual eligibility and parent-packet lookup, complete original/current TAP, independent whole-mutant reconstruction, all actual consumer command paths and full recursive book.',
            'red_control':'Exactly12 original authority failures become GREEN with424 controls unchanged. Each owner has raw/wrapper/copy/late-selection/diagnostic faults with complete436-name plans and named failures; number6/2/4/3/4 and string6/2/6/3/4. Seven actual artifact RED/restorations reject false positive, inverse hash drift, missing semantic reason beyond rehashed immediate index, false native flag, omitted checkpoint header beyond updated immediate review binding, original314 corruption and changed book source. Book controls fail missing SUMMARY, lose changed prose in rendered HTML and diagnose missing include despite exit0.'},
  'durability':{'status':'checked','mode':'live','inputs':inputs}},
 {'name':'original-array-boundary-preservation',
  'statement':'All314 predecessor live input hashes and every original proof/claim field remain exact; only the one live mode/revision becomes historical at5bf068c92. Existing historical legacy preservation remains unchanged.',
  'scope':'Complete accepted array callback claim and314 original Git bindings, exact before-copy and actual original publisher. No predecessor runtime/native/CI/book/consumer observation is refreshed; original replay requires its accepted Git input state.',
  'rederive':{'status':'checked','command':'bash tools/run_python_project_data.sh '+PREFIX+'review.py; separately evidence.py under that wrapper.',
             'granularity':'Original accepted Git claim, all314 original input hashes and exact mode/revision-only conversion.',
             'result':'All314 original hashes and fields remain exact; actual first-binding corruption rejects and exact original bytes restore to PASS.'},
  'falsify':{'status':'checked','hypothesis':'A historical label can conceal refreshed or corrupted original input/proof fields.',
            'oracle':'Accepted Git blobs, exact original before-copy and one-shot freezer, with JSON equality permitting only the one mode/revision conversion.',
            'red_control':'Actual all-zero first original input SHA fails frozen original claim fields; exact original bytes restore before actual readonly PASS.'},
  'durability':{'status':'checked','mode':'historical','revision':BASE,'inputs':historical}}
]}
serialized=(json.dumps(data,indent=2)+'\n').encode()
assert len(serialized)<=131072,('bounded claim size',len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(),'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes()==serialized,'required scalar publication drift'
print('Scalar required publication PASS:',len(inputs),'live inputs;',len(serialized),'bytes; original314 preserved; supplemental public Phase01035')

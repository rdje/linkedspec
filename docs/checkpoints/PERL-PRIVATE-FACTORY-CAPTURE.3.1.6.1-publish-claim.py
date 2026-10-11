"""Publish once, or reconstruct readonly, bounded required-array callback claims."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE='c90b99a831461e25adbc2b34d7da7d3deed11531'
LEAF='PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1'
PREFIX='docs/checkpoints/'+LEAF+'-'
TARGET=ROOT/('docs/claims/'+LEAF+'.json')
OLD_PRODUCER='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-publish-claim.py'
CARD='docs/knowledge/perl-array-receiver-required-capture.md'
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT/(PREFIX+tail+'.json')).read_bytes())


for tail in ('review.py','evidence-final.py','compatibility/run.py'):
    result=subprocess.run(['python3',PREFIX+tail],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
    assert result.returncode==0 and not result.stderr,('actual readonly proof',tail,result.stderr)
runtime,evidence,freeze=[record(tail) for tail in ('review','evidence','freeze')]
expected={'preserved_bindings':322,'native_inputs':189,'paired_inputs':191,'callbacks':8,'branches':34,
          'authority_rows':4,'public_rows':2,'cold_rows':2,'assertions':215,'original_red':6,'original_controls':209,
          'supplied_suites':62,'supplied_assertions':11879,'book_sources':89,'book_controls':3,
          'faults':{'raw-callback':6,'wrapper-identity':2,'copied-arguments':4,'late-map-selection':3,'missing-diagnostic':4}}
assert runtime['result']==evidence['result']=='PASS'
assert all(runtime[key]==value for key,value in expected.items())
assert len(evidence['controls'])==7
reached=record('evidence-reached')
assert reached=={'healthy':evidence['healthy'],'rows':evidence['controls']},'all actually reached control channels retained'
correction=record('evidence-correction')
assert correction['original_sha256']==digest((ROOT/correction['original_producer']).read_bytes())
assert correction['reported_exit']==1 and correction['repair_owner']==LEAF
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
old=json.loads(before)
bindings=[entry for claim in old['claims'] if claim['durability']['mode']=='live' for entry in claim['durability']['inputs']]
assert len(bindings)==322 and freeze['verified_bindings']==322
historical=[{'path':freeze['claim'],'sha256':digest(before),'role':'input'},
 {'path':OLD_PRODUCER,'sha256':digest(subprocess.check_output(['git','show',BASE+':'+OLD_PRODUCER],cwd=ROOT)),'role':'producer'}]
statement=('Two required array receiver callbacks retain eager acquisition, actual selected references, maps, scalar context, '
           'successful error state and fatal objects. Actual substring aliases retain mutation effects that a copied argument loses. '
           'Immutable189-input native8 callback/34 branch/4 authority/2 public source/2 cold rows precede assertions and one resolver edit. '
           'Paired215 TAP retains6 original authority REDs/209 controls/all215 current GREEN. Five syntax-valid full-module faults '
           'fail6/2/4/3/4. Actual supplied62 suites/191 inputs/11879 assertions, seven reason-sensitive evidence RED/restorations '
           'and full book89/three controls pass. Original consumer wrapper outer1 remains distinct from actual inner PASS; separate '
           'readonly review checks every ordered command path/header/plan, including its checkpoint suite, and unchanged predecessor diagnostics.')
limits=('First evidence attempt outer1 and exact original source are retained, but its reached inner channels were not saved and '
        'are unavailable; no partial original-control success is claimed. Corrected fresh seven-control recurrence separately retains '
        'every actual changed artifact, healthy/RED/restored channel and immediate index-binding intervention. Raw missing-dependency '
        'paths are retained, with only supplied diagnostic locations normalized in paired comparisons. Supplemental standard public '
        'syntax/Phase0 passes1035 with complete channels but no full transitive input capsule or private/canonical admission.')
data={'version':1,'owner':LEAF,'claims':[
 {'name':'array-required-callback-isolation','statement':statement,'scope':runtime['scope']+' '+limits,
  'rederive':{'status':'checked','command':'bash tools/run_python_project_data.sh '+PREFIX+'publish-claim.py; independently review.py, consumer-review.py and evidence-final.py under that wrapper. Defaults readonly; capture/freezer/fault/evidence writers are one-shot.',
             'granularity':'Every8 native callback/34 branch/4 actual authority/2 public source/2 cold row, all215 paired TAP names/exact6 original failures, every189 native/current and191 supplied input, five whole syntax-valid mutants, all62 command paths/headers/plans, seven damaged/restored input sets and all89 book/include inputs/three controls.',
             'result':statement},
  'falsify':{'status':'checked','hypothesis':'Raw required callbacks can donate nested publication, wrapper identity can substitute for actual known callbacks, copying substring arguments preserves native effects, a later map entry can replace an eagerly selected parser, altered diagnostics or missing checkpoint suites can pass.',
            'oracle':'Immutable first-native full ordinary ledgers and authored result/branch/role cases; actual original/current producer eligibility and parent packet lookup; full source reconstruction and paired assertion names. Separate path-complete consumer reconstruction uses actual command paths and headers rather than t-only spelling.',
            'red_control':'Exactly6 original authority failures become GREEN with209 controls preserved. Raw callback/wrapper identity/copied argument/late selection/diagnostic faults cause6/2/4/3/4 complete-plan named failures. Seven actual artifact RED/restorations cover false positive, original inverse-hash denial, missing semantic reason beyond its updated index binding, false native flag, omitted checkpoint header beyond its updated immediate review binding, original322 corruption and changed book source. Full book controls fail missing SUMMARY, lose removed prose in HTML and diagnose omitted include despite exit0.'},
  'durability':{'status':'checked','mode':'live','inputs':inputs}},
 {'name':'original-legacy-boundary-preservation',
  'statement':'All322 predecessor live input hashes and every original proof/claim field remain exact. Only one live mode/revision becomes historical atc90b99a83; the already historical scalar-copy preservation stays exact.',
  'scope':'Complete accepted legacy callback claim and all322 original Git bindings, before-copy and actual original publisher. No original native/runtime/book/consumer observation is refreshed; its replay requires accepted Git inputs.',
  'rederive':{'status':'checked','command':'bash tools/run_python_project_data.sh '+PREFIX+'review.py; separately evidence-final.py under that wrapper.',
             'granularity':'Complete original Git claim, every322 accepted Git hash and exact mode/revision-only conversion.',
             'result':'All322 original hashes and fields remain exact; an actual first-binding corruption rejects and exact original bytes restore to PASS.'},
  'falsify':{'status':'checked','hypothesis':'A historical label hides refreshed or corrupted original input/proof fields.',
            'oracle':'Accepted Git blobs, original before-copy, one-shot freezer and exact JSON comparison allowing only the one mode/revision conversion.',
            'red_control':'All-zero first original input SHA fails with frozen original claim fields; original bytes restore before actual readonly PASS.'},
  'durability':{'status':'checked','mode':'historical','revision':BASE,'inputs':historical}},
]}
serialized=(json.dumps(data,indent=2)+'\n').encode()
assert len(serialized)<=131072,('bounded claim size',len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(),'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes()==serialized,'required array publication drift'
print('Array required publication PASS:',len(inputs),'live inputs;',len(serialized),'bytes; original322 preserved; supplemental public Phase01035')

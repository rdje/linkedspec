"""Readonly reconstruction of number/string native boundaries, paired tests, complete faults and book."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE='5bf068c924f190fdc7b9f904b9b9720cc638f2e9'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-'
MODULE='perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE='t/actionir_scalar_receiver_required_probe.pl'
COLD='t/actionir_scalar_receiver_required_cold_probe.pl'
TEST='t/actionir_scalar_receiver_required_capture.t'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1-consumers.json'
OLD_CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1.json'
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()
used=set()


def read(path):
    used.add(path)
    return (ROOT/path).read_bytes()


def record(tail):
    return json.loads(read(PREFIX+tail+'.json'))


def blob(path):
    return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)


def channel(row,name):
    return base64.b64decode(row[name+'_base64'],validate=True)


def tap(row):
    output=channel(row,'stdout')
    plans=re.findall(rb'^1\.\.(\d+)$',output,re.MULTILINE)
    rows=re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$',output,re.MULTILINE)
    assert len(plans)==1 and [int(n) for failed,n,label in rows]==list(range(1,int(plans[0])+1)),'complete TAP'
    return [label.decode() for failed,n,label in rows],[label.decode() for failed,n,label in rows if failed]


original_claim=blob(OLD_CLAIM)
freeze=record('freeze')
assert read(freeze['before'])==original_claim and freeze['revision']==BASE
assert freeze['original_sha256']==digest(original_claim) and freeze['producer_sha256']==digest(read(PREFIX+'freeze.py'))
expected_old=json.loads(original_claim)
live=[claim for claim in expected_old['claims'] if claim['durability']['mode']=='live']
assert len(live)==1 and live[0]['name']=='array-required-callback-isolation'
bindings=live[0]['durability']['inputs']
assert len(bindings)==len({row['path'] for row in bindings})==314
for row in bindings:
    assert digest(blob(row['path']))==row['sha256'],'original Git binding'
live[0]['durability'].update(mode='historical',revision=BASE)
old_raw=read(OLD_CLAIM)
assert json.loads(old_raw)==expected_old,'frozen original claim fields'
assert freeze['after_sha256']==digest(old_raw) and freeze['verified_bindings']==314

original=blob(MODULE).decode()
owners={family:'_normalize_'+family+'_receiver_value_chain_expr' for family in ('number','string')}
expected_source=original
for owner in owners.values():
    begin=expected_source.index('sub '+owner+' {')
    end=expected_source.index('\nsub ',begin+1)
    body=expected_source[begin:end]
    assert body.count('return $cb;')==1
    expected_source=expected_source[:begin]+body.replace('return $cb;','return _bind_emission_dependency($cb);')+expected_source[end:]
source=read(MODULE).decode()
assert source==expected_source,'whole module exact two-return change'
die_lines={family:original[:original.index('  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep)',original.index('sub '+owner+' {'))].count('\n')+1 for family,owner in owners.items()}
seed_raw=read(SEED)
assert seed_raw==blob(SEED)
seed=json.loads(seed_raw)
assert seed['returncode']==0 and seed['unchanged'] and len(seed['inputs'])==191
native_inputs=dict(seed['inputs'])
for path,sha in seed['inputs'].items():
    assert digest(blob(path))==sha,'accepted seed Git binding'
    if path!=MODULE:
        assert digest(read(path))==sha,'unchanged direct seed input'
for path in (PROBE,COLD):
    assert path not in native_inputs
    native_inputs[path]=digest(read(path))
current_inputs=dict(native_inputs,**{MODULE:digest(source.encode())})
paired_inputs=dict(current_inputs,**{TEST:digest(read(TEST)),PREFIX+'native.json':digest(read(PREFIX+'native.json'))})
assert len(native_inputs)==193 and len(paired_inputs)==195
producer=read(PREFIX+'capture.py')
assert b"every ordered supplied command path/header" in producer,'retained path-complete capture guard'


def capture(row,population,command):
    assert row['base']==BASE and row['seed']==SEED and row['seed_sha256']==digest(seed_raw)
    assert row['producer_sha256']==digest(producer),'immutable capture producer'
    assert row['inputs']==population and row['command']==command and row['unchanged'],'exact supplied input population'


native,current,before,fixture,consumers=[record(t) for t in ('native','current','before','fixture','consumers')]
probe_command=['perl','-Iperl','./'+PROBE,'observe']
capture(native,native_inputs,probe_command)
capture(current,current_inputs,probe_command)
capture(before,dict(paired_inputs,**{MODULE:native_inputs[MODULE]}),['perl','-Iperl',TEST])
capture(fixture,paired_inputs,['perl','-Iperl',TEST])
capture(consumers,paired_inputs,seed['command']+[TEST])
assert native['returncode']==current['returncode']==fixture['returncode']==consumers['returncode']==0
assert not channel(native,'stderr') and not channel(current,'stderr') and not channel(fixture,'stderr')
first,now=[json.loads(channel(row,'stdout')) for row in (native,current)]
assert set(first)==set(now)=={'callbacks','branches','authority','public','cold'}
assert len(first['callbacks'])==len(now['callbacks'])==16 and first['callbacks']==now['callbacks'],'native callback values aliases effects errors'
assert len(first['branches'])==len(now['branches'])==73
diagnostic_cases=set()
for left,right in zip(first['branches'],now['branches']):
    left,right=copy.deepcopy(left),copy.deepcopy(right)
    assert left['name']==right['name']
    if re.fullmatch(r'(number|string)-(missing|noncode)-(trim_action_ir_value|parse_method_function_expr)',left['name']):
        diagnostic_cases.add(left['name'])
        for row in (left,right):
            text=row['error']
            match=re.fullmatch(r"(\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '(trim_action_ir_value|parse_method_function_expr)') at ([^\n]*?/)?perl/LinkedSpec/ActionIR/MethodLowering\.pm line (\d+)(?:, <[^\n]+> line \d+)?\.\n",text)
            assert match and int(match[4])==die_lines[left['family']],'exact required diagnostic stem/source line'
            row['error']=match[1]
    assert left==right,'complete native branch after disclosed location-only comparison'
assert len(diagnostic_cases)==8
for row in now['callbacks']+now['branches']:
    assert row['optional_kind_calls']==0 and all(value==1 for value in row['map_expected'].values())
    assert all(trace['context']=='scalar' and trace['readonly']==[0] and trace['caller_slot']==0 for trace in row['trace'])
for family,receiver,method in (('number','score','abs'),('string','raw','trim')):
    effect=next(row for row in now['callbacks'] if row['name']==family+'-trim_action_ir_value-effect')
    assert effect['value'] is None and effect['caller_after']==receiver+'.'+method+'()'
    assert [trace['args'][0] for trace in effect['trace']]==[receiver+'.'+method+'()',receiver+'.'+method+'()',receiver,'.'+method+'()','.'+method+'()','', '.'+method+'()','.'+method+'()'],'actual substring effects'
string_effect=next(row for row in now['callbacks'] if row['name']=='string-parse_method_function_expr-effect')
assert string_effect['parsed_after']==[{'method':'trim','args':[],'__source_expr':'trim()!'}],'actual parser alias and returned-object annotation'
shared=next(row for row in now['branches'] if row['name']=='string-shared-returned-call')
assert shared['parsed_same']==[[1,1],[1,1]] and shared['parsed_after']==[{'method':'trim','args':[],'__source_expr':'lowercase()'}]*2,'actual shared returned-reference annotation'
assert len(first['authority'])==len(now['authority'])==8
roles=['trim_action_ir_value','parse_method_function_expr']
for left,right,(family,role,known) in zip(first['authority'],now['authority'],[(f,r,k) for f in owners for r in roles for k in (0,1)]):
    calls=5 if role==roles[0] else 1
    value='num_abs(score)' if family=='number' else 'trim(raw)'
    assert left=={'family':family,'role':role,'known':known,'value':value,'eligible':[1]*calls,
                  'parent_packet':1,'selected_calls':calls,'map_identity':1},'original actual authority donation'
    assert right==dict(left,eligible=[known]*calls,parent_packet=0),'repaired callback identity and separate capture'
assert first['public']==now['public'] and len(now['public'])==4 and all(row['value'] and row['error'] is None for row in now['public'])
assert first['cold']==now['cold'],'complete cold channels'
cold=now['cold']
assert cold['returncode']==0 and not cold['stderr'] and cold['value']['loaded_before']==cold['value']['loaded_after']==0
assert len(cold['value']['rows'])==4 and [row['value'] for row in cold['value']['rows']]==['num_abs(score)',None,'trim(raw)',None]

names,red=tap(before)
positive_names,positive_red=tap(fixture)
expected_red=[f'{family} authority {role} known{known} {reason}' for family in owners for role in roles for known in (0,1)
              for reason in ('no child publication donation','actual callback identity') if known==0 or reason.startswith('no child')]
assert len(names)==436 and names==positive_names and red==expected_red and len(red)==12 and before['returncode']==12,'paired original semantic REDs'
assert not positive_red,'positive runtime TAP'
consumer_review=record('consumer-review')
assert consumer_review['producer_sha256']==digest(read(PREFIX+'consumer-review.py'))
assert consumer_review['consumer_sha256']==digest(read(PREFIX+'consumers.json'))
assert consumer_review['result']=='PASS' and consumer_review['suites']==63 and consumer_review['assertions']==12315
assert consumer_review['supplied_inputs']==paired_inputs and consumer_review['suite_paths']==consumers['command'][3:]
assert channel(consumers,'stderr')==channel(seed,'stderr'),'unchanged public-copy diagnostic'
headers=re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$',channel(consumers,'stdout'),re.MULTILINE)
assert headers==[p.encode() for p in consumers['command'][3:]],'all63 command paths including checkpoint fixture'
assert re.findall(rb'^Files=(\d+), Tests=(\d+),',channel(consumers,'stdout'),re.MULTILINE)==[(b'63',b'12315')]
assert len(re.findall(rb'^1\.\.\d+$',channel(consumers,'stdout'),re.MULTILINE))==63
assert channel(consumers,'stdout').endswith(b'Result: PASS\n') and b'All tests successful.\n' in channel(consumers,'stdout')
assert not re.search(rb'^not ok ',channel(consumers,'stdout'),re.MULTILINE)

inverses=record('inverses')
assert inverses['producer_sha256']==digest(read(PREFIX+'faults.py'))
assert inverses['fixture_sha256']==digest(read(PREFIX+'fixture.json')) and inverses['inputs']==paired_inputs and inverses['unchanged']
binding='return _bind_emission_dependency($cb);'
faults=[('raw-callback',binding,'return $cb;',6),
 ('wrapper-identity',binding,'return _bind_emission_dependency(sub { return $cb->(@_) });',2),
 ('copied-arguments',binding,'return _bind_emission_dependency(sub { my @args=@_; return $cb->(@args) });',4),
 ('late-map-selection',binding,'return _bind_emission_dependency(sub { return $deps->{$name}->(@_) });',3),
 ('missing-diagnostic','::_require_dep)','::_wrong_dep)',4)]
expected_faults=[(family,label,old,new,6 if family=='string' and label=='copied-arguments' else count)
                 for family in owners for label,old,new,count in faults]
assert len(inverses['rows'])==len(expected_faults)==10
for entry,(family,short_label,old,new,count) in zip(inverses['rows'],expected_faults):
    label=family+'-'+short_label
    raw=read(entry['path'])
    row=json.loads(raw)
    assert entry['label']==row['label']==label and entry['sha256']==digest(raw),'inverse artifact binding'
    begin=source.index('sub '+owners[family]+' {')
    end=source.index('\nsub ',begin+1)
    body=source[begin:end]
    assert body.count(old)==1
    mutant=(source[:begin]+body.replace(old,new)+source[end:]).encode()
    assert channel(row,'source')==mutant and row['source_sha256']==digest(mutant),'whole independent mutant reconstruction'
    assert row['producer_sha256']==digest(read(PREFIX+'faults.py')) and row['fixture_sha256']==digest(read(PREFIX+'fixture.json'))
    assert row['inputs']==dict(paired_inputs,**{MODULE:digest(mutant)}) and row['unchanged']
    assert row['syntax_command']==['perl','-Iperl','-c',MODULE] and row['syntax']['returncode']==0
    assert not channel(row['syntax'],'stdout') and b'syntax OK' in channel(row['syntax'],'stderr'),'complete syntax-valid fault'
    fault_names,failures=tap(row)
    reason=(family+' '+('authority trim_action_ir_value known0 no child publication donation' if short_label=='raw-callback'
                       else 'authority parse_method_function_expr known1 actual callback identity')
            if short_label in ('raw-callback','wrapper-identity') else
            'scalar ordinary callback '+family+'-trim_action_ir_value-effect complete native effects and aliases'
            if short_label=='copied-arguments' else
            'scalar branch '+family+'-'+('parser-selected-before-trim' if short_label=='late-map-selection' else 'missing-parse_method_function_expr')+' complete native observation')
    assert fault_names==names and row['returncode']!=0 and entry['failed']==len(failures)==count and row['reason']==entry['reason']==reason and reason in failures,'effective named semantic fault'
    assert row['command']==fixture['command']
book_review=record('book-review')
assert book_review['result']=='PASS' and book_review['source_count']==89 and book_review['actual_controls']==3
assert book_review['producer_sha256']==digest(read(PREFIX+'book-review.py'))
assert book_review['book_capture_sha256']==digest(read(PREFIX+'book.json')) and book_review['book_producer_sha256']==digest(read(PREFIX+'book.py'))
for path,sha in book_review['source_inputs'].items():
    assert digest(read(path))==sha,'complete current book input'
commands=[]
for tail in ('consumer-review.py','book-review.py'):
    command=['python3',PREFIX+tail]
    result=subprocess.run(command,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
    assert result.returncode==0 and not result.stderr,'actual readonly component review'
    commands.append({'command':command,'returncode':result.returncode,
                     'stdout_base64':base64.b64encode(result.stdout).decode(),'stderr_base64':base64.b64encode(result.stderr).decode()})
report={'result':'PASS','producer_sha256':digest(Path(__file__).read_bytes()),'base':BASE,
 'preserved_bindings':314,'native_inputs':193,'paired_inputs':195,'callbacks':16,'branches':73,
 'authority_rows':8,'public_rows':4,'cold_rows':4,'assertions':436,'original_red':12,'original_controls':424,
 'supplied_suites':63,'supplied_assertions':12315,'faults':{family+'-'+label:count for family,label,old,new,count in expected_faults},
 'book_sources':89,'book_controls':3,'actual_component_reviews':commands,
 'input_metadata':{path:digest((ROOT/path).read_bytes()) for path in sorted(used)},
 'scope':'Four required number/string callbacks: actual splitter aliases, eagerly selected references, parser-returned call annotation and shared object identity, native contexts/effects/errors/maps and separate publication. Immutable193-input native/current and195-input paired/direct populations, complete63-suite census and full89-input book. Original314 Git bindings remain historical; no native instrument or observation refreshed. Raw diagnostic locations are retained, with location-only normalization in paired comparisons. Public Toolbox rows are source controls only; optional/direct, complete helper/AST/language, full-private, output/mapping/parent/canonical admissions remain separate.'}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(),'one-shot review already retained'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes())==report,'retained scalar review identity'
print('Scalar required review PASS436/12 RED/424 controls; native16/branches73/authority8/public4/cold4; ten faults;63/195;book89/3; original314 preserved')

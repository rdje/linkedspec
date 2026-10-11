"""Readonly reconstruction of hash native boundaries, paired tests, complete faults and book."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE='e4507973aff0a4ebcd09299d971a8d78a86c10b1'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3-'
MODULE='perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE='t/actionir_hash_receiver_required_probe.pl'
COLD='t/actionir_hash_receiver_required_cold_probe.pl'
TEST='t/actionir_hash_receiver_required_capture.t'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-consumers.json'
OLD_CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1.json'
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
assert read(freeze['before'])==original_claim and freeze['base']==BASE
assert freeze['claim']==OLD_CLAIM
assert freeze['original_sha256']==digest(original_claim) and freeze['producer_sha256']==digest(read(PREFIX+'freeze.py'))
expected_old=json.loads(original_claim)
live=[claim for claim in expected_old['claims'] if claim['durability']['mode']=='live']
assert len(live)==1 and live[0]['name']=='current-admission-review-command'
bindings=live[0]['durability']['inputs']
assert len(bindings)==len({row['path'] for row in bindings})==115
for row in bindings:
    assert digest(blob(row['path']))==row['sha256'],'original Git binding'
assert freeze['intersections']==[{'claim':OLD_CLAIM,'name':live[0]['name'],'bindings':115,
    'intersections':['docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md']}]
live[0]['durability'].update(mode='historical',revision=BASE)
old_raw=read(OLD_CLAIM)
assert json.loads(old_raw)==expected_old,'frozen original claim fields'
assert freeze['after_sha256']==digest(old_raw)
baseline=record('baseline')
assert baseline['producer_sha256']==freeze['producer_sha256'] and baseline['returncode']==0
assert baseline['command']==['python3','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1/publish.py']
assert not channel(baseline,'stderr') and b'PASS' in channel(baseline,'stdout'),'accepted original publication baseline'

original=blob(MODULE).decode()
begin=original.index('sub _normalize_hash_receiver_value_chain_expr {')
end=original.index('\nsub ',begin+1)
original_body=original[begin:end]
assert original_body.count('return $cb;')==1
source=read(MODULE).decode()
expected_source=original[:begin]+original_body.replace('return $cb;','return _bind_emission_dependency($cb);')+original[end:]
assert source==expected_source,'whole module exact one-return change'
die_line=original[:original.index('  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep)',begin)].count('\n')+1
seed_raw=read(SEED)
assert seed_raw==blob(SEED)
seed=json.loads(seed_raw)
assert seed['returncode']==0 and seed['unchanged'] and len(seed['inputs'])==195
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
assert len(native_inputs)==197 and len(paired_inputs)==199
producer=read(PREFIX+'capture.py')
assert b"every ordered supplied command path/header" in producer,'path-complete producer'


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
assert len(first['callbacks'])==len(now['callbacks'])==8 and first['callbacks']==now['callbacks'],'native callback values aliases effects errors'
assert len(first['branches'])==len(now['branches'])==52
diagnostic_cases=set()
for left,right in zip(first['branches'],now['branches']):
    left,right=copy.deepcopy(left),copy.deepcopy(right)
    assert left['name']==right['name']
    if left['name'].startswith(('missing-','noncode-')):
        diagnostic_cases.add(left['name'])
        for row in (left,right):
            text=row['error']
            match=re.fullmatch(r"(\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '(trim_action_ir_value|parse_method_function_expr)') at ([^\n]*?/)?perl/LinkedSpec/ActionIR/MethodLowering\.pm line (\d+)(?:, <[^\n]+> line \d+)?\.\n",text)
            assert match and int(match[4])==die_line,'exact required diagnostic stem/source line'
            row['error']=match[1]
    assert left==right,'complete native branch after disclosed location-only comparison'
assert len(diagnostic_cases)==4
for row in now['callbacks']+now['branches']:
    expected_kind=1 if re.fullmatch(r'copy-(known-hash|excess|hash-lookahead|array-lookahead|known-array|unknown-kind|unknown-hash-lookahead|unknown-array-lookahead)',row['name']) else 0
    assert row['optional_kind_calls']==expected_kind and all(value==1 for value in row['map_expected'].values())
    assert all(trace['context']=='scalar' and trace['readonly']==[0] and trace['caller_slot']==0 for trace in row['trace'])
effect=next(row for row in now['callbacks'] if row['name']=='trim_action_ir_value-effect')
assert effect['value'] is None and effect['caller_after']=='meta.sorted_keys()'
assert [trace['args'][0] for trace in effect['trace']]==['meta.sorted_keys()','meta.sorted_keys()','meta','.sorted_keys()','.sorted_keys()','', '.sorted_keys()','.sorted_keys()'],'actual substring effects'
shared=next(row for row in now['branches'] if row['name']=='shared-returned-call')
assert shared['parsed_same']==[[1,1],[1,1]] and shared['parsed_after']==[{'method':'pick_keys','args':['a']}]*2,'actual shared references without source annotation'
assert shared['value']=='pick_keys(pick_keys(meta, a), a)'
parser_effect=next(row for row in now['callbacks'] if row['name']=='parse_method_function_expr-effect')
assert parser_effect['parsed_after']==[{'method':'sorted_keys','args':[]}],'actual parser result unchanged'
assert len(first['authority'])==len(now['authority'])==4
roles=['trim_action_ir_value','parse_method_function_expr']
for left,right,(role,known) in zip(first['authority'],now['authority'],[(r,k) for r in roles for k in (0,1)]):
    calls=5 if role==roles[0] else 1
    assert left=={'role':role,'known':known,'value':'sorted_keys(meta)','eligible':[1]*calls,
                  'parent_packet':1,'selected_calls':calls,'map_identity':1},'original actual authority donation'
    assert right==dict(left,eligible=[known]*calls,parent_packet=0),'repaired callback identity and separate capture'
assert first['public']==now['public'] and len(now['public'])==2 and all(row['value'] and row['error'] is None for row in now['public'])
assert first['cold']==now['cold'],'complete cold channels'
cold=now['cold']
assert cold['returncode']==0 and not cold['stderr'] and cold['value']['loaded_before']==cold['value']['loaded_after']==0
assert len(cold['value']['rows'])==2 and [row['value'] for row in cold['value']['rows']]==['sorted_keys(meta)',None]

names,red=tap(before)
positive_names,positive_red=tap(fixture)
expected_red=[f'hash authority {role} known{known} {reason}' for role in roles for known in (0,1)
              for reason in ('no child publication donation','actual callback identity') if known==0 or reason.startswith('no child')]
assert len(names)==308 and names==positive_names and red==expected_red and len(red)==6 and before['returncode']==6,'paired original semantic REDs'
assert not positive_red,'positive runtime TAP'
consumer_review=record('consumer-review')
assert consumer_review['producer_sha256']==digest(read(PREFIX+'consumer-review.py'))
assert consumer_review['consumer_sha256']==digest(read(PREFIX+'consumers.json'))
assert consumer_review['result']=='PASS' and consumer_review['suites']==64 and consumer_review['assertions']==12623
assert consumer_review['supplied_inputs']==paired_inputs and consumer_review['suite_paths']==consumers['command'][3:]
assert channel(consumers,'stderr')==channel(seed,'stderr'),'unchanged public-copy diagnostic'
headers=re.findall(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$',channel(consumers,'stdout'),re.MULTILINE)
assert headers==[p.encode() for p in consumers['command'][3:]],'all64 command paths including checkpoint fixture'
assert re.findall(rb'^Files=(\d+), Tests=(\d+),',channel(consumers,'stdout'),re.MULTILINE)==[(b'64',b'12623')]
assert len(re.findall(rb'^1\.\.\d+$',channel(consumers,'stdout'),re.MULTILINE))==64
assert channel(consumers,'stdout').endswith(b'Result: PASS\n') and b'All tests successful.\n' in channel(consumers,'stdout')
assert not re.search(rb'^not ok ',channel(consumers,'stdout'),re.MULTILINE)

inverses=record('inverses')
assert inverses['producer_sha256']==digest(read(PREFIX+'faults.py'))
assert inverses['fixture_sha256']==digest(read(PREFIX+'fixture.json')) and inverses['inputs']==paired_inputs and inverses['unchanged']
body=source[begin:end]
binding='return _bind_emission_dependency($cb);'
faults=[('raw-callback',binding,'return $cb;',6),
 ('wrapper-identity',binding,'return _bind_emission_dependency(sub { return $cb->(@_) });',2),
 ('copied-arguments',binding,'return _bind_emission_dependency(sub { my @args=@_; return $cb->(@args) });',4),
 ('late-map-selection',binding,'return _bind_emission_dependency(sub { return $deps->{$name}->(@_) });',5),
 ('missing-diagnostic','::_require_dep)','::_wrong_dep)',8)]
assert len(inverses['rows'])==len(faults)==5
for entry,(label,old,new,count) in zip(inverses['rows'],faults):
    raw=read(entry['path'])
    row=json.loads(raw)
    assert entry['label']==row['label']==label
    assert entry['sha256']==digest(raw),'inverse artifact binding'
    assert body.count(old)==1
    mutant=(source[:begin]+body.replace(old,new)+source[end:]).encode()
    assert channel(row,'source')==mutant and row['source_sha256']==digest(mutant),'whole exact syntax-valid mutant source'
    assert row['inputs']==dict(paired_inputs,**{MODULE:digest(mutant)}) and row['unchanged']
    assert row['producer_sha256']==inverses['producer_sha256'] and row['fixture_sha256']==inverses['fixture_sha256']
    assert row['syntax_command']==['perl','-Iperl','-c',MODULE] and row['syntax']['returncode']==0 and b'syntax OK' in channel(row['syntax'],'stderr')
    fault_names,failures=tap(row)
    assert fault_names==names and row['returncode']!=0 and entry['failed']==len(failures)==count and row['reason']==entry['reason'] and row['reason'] in failures,'effective named semantic fault'
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
 'preserved_bindings':115,'native_inputs':197,'paired_inputs':199,'callbacks':8,'branches':52,
 'authority_rows':4,'public_rows':2,'cold_rows':2,'assertions':308,'original_red':6,'original_controls':302,
 'supplied_suites':64,'supplied_assertions':12623,'faults':{label:count for label,old,new,count in faults},
 'book_sources':89,'book_controls':3,'actual_component_reviews':commands,
 'input_metadata':{path:digest((ROOT/path).read_bytes()) for path in sorted(used)},
 'scope':'Two required hash-normalizer callbacks and actual splitter substring aliases, acquisition/selection timing, native contexts/effects/errors/maps and separate publication. Complete supplied input populations and full book. Path-complete producer and independent review check every64 command path/header/plan, including the accepted checkpoint fixture. Raw diagnostic locations are retained and only locations normalized in paired comparisons. No native instrument or observation refreshed. Supplemental public Phase0, optional/direct, complete helper/AST/language, full-private, output/mapping/parent/canonical admissions remain separate.'}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(),'one-shot review already retained'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes())==report,'retained hash review identity'
print('Hash required review PASS308/6 RED/302 controls; native8/branches52/authority4/public2/cold2; five faults;64/199;book89/3; original115 preserved')

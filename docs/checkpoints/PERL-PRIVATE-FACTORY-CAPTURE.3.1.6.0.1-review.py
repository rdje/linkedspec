"""Read-only reconstruction of legacy callback, native aliases, supplied consumers and book proof."""
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE='770cffcccea44df8d0e578ed68ad6f9a4b5e0b0e'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-'
MODULE='perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST='t/actionir_receiver_scalar_copy.t'
PROBE='t/actionir_legacy_hash_kind_probe.pl'
COLD='t/actionir_legacy_hash_kind_cold_probe.pl'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-consumers.json'
OLD_CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0.json'
BIND=""" my $kind_callback = (ref($deps) eq 'HASH') ? $deps->{bare_symbol_kind} : undef;
 my $bare_symbol_kind = _bind_emission_dependency(
  ref($kind_callback) eq 'CODE' ? $kind_callback : sub { return undef },
 );
"""
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()
used=set()


def read(path):
    used.add(path)
    return (ROOT/path).read_bytes()


def record(suffix):
    return json.loads(read(PREFIX+suffix+'.json'))


def blob(path):
    return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)


def channel(row,name):
    return base64.b64decode(row[name+'_base64'],validate=True)


def tap(row):
    raw=channel(row,'stdout')
    plans=re.findall(rb'^1\.\.(\d+)$',raw,re.MULTILINE)
    assert len(plans)==1,'complete TAP plan'
    rows=re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$',raw,re.MULTILINE)
    count=int(plans[0])
    assert [int(n) for failed,n,label in rows]==list(range(1,count+1)),'complete TAP population'
    return count,[label.decode() for failed,n,label in rows if failed]


def diagnostic(row):
    raw=channel(row,'stderr')
    prefix=b'# RECEIVER_COPY_OBSERVATIONS '
    assert raw.startswith(prefix) and raw.endswith(b'\n') and raw.count(b'\n')==1,'unexpected public-copy stderr'
    value=json.loads(raw[len(prefix):-1])
    assert isinstance(value,dict) and {'live','standalone','typed_value'}<=value.keys(),'invalid public-copy diagnostic'
    return value


def check_capture(row,producer,population,command):
    assert row['base']==BASE and row['seed']==SEED and row['seed_sha256']==digest(seed_raw),'capture seed'
    assert row['producer_sha256']==digest(read(PREFIX+producer+'.py')),'capture producer'
    assert row['inputs']==population,'capture supplied population'
    assert row['command']==command and row['unchanged'] is True,'capture command/input preservation'


def edit(source,old,new):
    begin=source.index('sub _normalize_hash_receiver_value_chain_expr {')
    end=source.index('\nsub ',begin+1)
    body=source[begin:end]
    assert body.count(old)==1,'unique owner intervention'
    return source[:begin]+body.replace(old,new)+source[end:]


def replay(writer,inputs,outputs,overwritten=()):
    inputs=dict(inputs,**{writer:read(writer)})
    with tempfile.TemporaryDirectory(prefix='legacy-kind-replay-',dir=os.environ['TMPDIR']) as temporary:
        directory=Path(temporary)
        assert directory.stat().st_dev==ROOT.stat().st_dev
        for path,raw in inputs.items():
            target=directory/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw)
        command=['python3',writer]
        result=subprocess.run(command,cwd=directory,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
        assert result.returncode==0 and not result.stderr,'correction replay failed'
        for path,raw in outputs.items():
            assert (directory/path).read_bytes()==raw,'correction replay output'
        for path,raw in inputs.items():
            if path not in overwritten:
                assert (directory/path).read_bytes()==raw,'correction replay input mutation'
        assert {p.relative_to(directory).as_posix() for p in directory.rglob('*') if p.is_file()}==set(inputs)|set(outputs),'correction replay file population'
        return {'command':command,'returncode':result.returncode,
                'stdout_base64':base64.b64encode(result.stdout).decode(),
                'stderr_base64':base64.b64encode(result.stderr).decode(),
                'inputs':{p:digest(raw) for p,raw in sorted(inputs.items())},
                'outputs':{p:digest(raw) for p,raw in sorted(outputs.items())}}


original_claim=blob(OLD_CLAIM)
assert read(PREFIX+'before-copy.json')==original_claim,'frozen original claim bytes'
before_claim=json.loads(original_claim)
converted=json.loads(original_claim)
bindings=[]
for claim in converted['claims']:
    if claim['durability']['mode']=='live':
        bindings.extend(claim['durability']['inputs'])
        claim['durability'].update(mode='historical',revision=BASE)
assert len(bindings)==546 and len({entry['path'] for entry in bindings})==546,'original binding population'
for entry in bindings:
    assert digest(blob(entry['path']))==entry['sha256'],'original Git binding'
assert read(OLD_CLAIM)==(json.dumps(converted,indent=2)+'\n').encode(),'frozen original claim fields'
freeze=record('freeze')
assert freeze['revision']==BASE and freeze['verified_bindings']==546
assert freeze['original_sha256']==digest(original_claim) and freeze['after_sha256']==digest(read(OLD_CLAIM))
assert freeze['producer_sha256']==digest(read(PREFIX+'freeze.py'))

seed_raw=read(SEED)
assert seed_raw==blob(SEED),'accepted seed bytes'
seed=json.loads(seed_raw)
assert seed['returncode']==0 and seed['unchanged'] is True and len(seed['inputs'])==184
for path,sha in seed['inputs'].items():
    assert digest(blob(path))==sha,'accepted supplied input'
    if path not in (MODULE,TEST):
        assert digest(read(path))==sha,'unchanged supplied control'
old_module=blob(MODULE).decode()
module=read(MODULE).decode()
expected=edit(old_module,' my $trimmed = $trim_action_ir_value->($expr);\n',
              BIND+'\n my $trimmed = $trim_action_ir_value->($expr);\n')
assert module==expected,'bounded production edit'
old_test=blob(TEST)
assert old_test.endswith(b'done_testing();\n')
assert read(TEST).startswith(old_test[:-len(b'done_testing();\n')]),'original public fifty-test prefix'
draft=read(PREFIX+'fixture-draft.t')
assert draft.startswith(old_test[:-len(b'done_testing();\n')]),'draft public fifty-test prefix'

native_population=dict(seed['inputs'],**{PROBE:digest(read(PROBE)),COLD:digest(read(COLD))})
current_population=dict(native_population,**{MODULE:digest(module.encode()),TEST:digest(read(TEST))})
native_path=PREFIX+'native.json'
native_raw=read(native_path)
paired_population=dict(current_population,**{native_path:digest(native_raw)})
draft_population=dict(paired_population,**{MODULE:digest(old_module.encode()),TEST:digest(draft)})
before_population=dict(paired_population,**{MODULE:digest(old_module.encode())})
assert len(native_population)==186 and len(paired_population)==187
native=json.loads(native_raw)
current=record('current')
draft_before=record('before')
before=record('before-complete')
first_positive=record('fixture')
positive=record('positive')
consumers=record('consumers')
probe_command=['perl','-Iperl',PROBE,'observe']
test_command=['perl','-Iperl',TEST]
check_capture(native,'capture',native_population,probe_command)
check_capture(current,'final-capture',current_population,probe_command)
check_capture(draft_before,'capture',draft_population,test_command)
check_capture(before,'complete-capture',before_population,test_command)
check_capture(first_positive,'complete-capture',paired_population,test_command)
check_capture(positive,'final-capture',paired_population,test_command)
check_capture(consumers,'final-capture',paired_population,seed['command'])
assert native['returncode']==current['returncode']==0
assert not channel(native,'stderr') and not channel(current,'stderr')
original=json.loads(channel(native,'stdout'))
observed=json.loads(channel(current,'stdout'))
case_source=read(PROBE).decode().split('sub cases {',1)[1].split('\nsub setup {',1)[0]
definitions=[line for line in case_source.splitlines() if "{name=>'" in line]
names=[re.search(r"name=>'([^']+)'",line).group(1) for line in definitions]
assert len(names)==35 and [row['name'] for row in original['cases']]==names==[row['name'] for row in observed['cases']]
controls=0
for line,old,row in zip(definitions,original['cases'],observed['cases']):
    if 'repair=>1' not in line:
        assert row==old,'complete native control'
        controls+=1
    value=re.search(r"value=>'([^']*)'",line)
    error=re.search(r"error=>'([^']*)'",line)
    calls=int(re.search(r'calls=>(\d+)',line).group(1))
    assert row['value']==(value.group(1) if value else None),'authored case result'
    assert row['error_kind']==(error.group(1) if error else None),'authored case error'
    assert len(row['trace'])==calls and row['public_map_preserved']==1,'actual callback/map'
    assert row['eligible']==[0]*calls,'ordinary callback eligibility'
    for call in row['trace']:
        assert call['origin']=='map' and call['context']=='scalar' and call['args']==['meta'],'actual selected callback'
        assert call['readonly']==[0] and call['caller_slot']==0,'native match flag/caller boundary'
assert controls==23
assert original['cold']['returncode']==observed['cold']['returncode']==0
assert observed['cold']['value']['rows'][0]==original['cold']['value']['rows'][0],'cold native control'
assert observed['cold']['value']['loaded_before']==observed['cold']['value']['loaded_after']==0,'cold channel laziness'
assert observed['cold']['value']['rows'][1]['error'] is None and observed['cold']['value']['rows'][1]['value'] is None
assert observed['cold']['value']['rows'][1]['map_preserved']==1
for packet in (original,observed):
    assert json.loads(base64.b64decode(packet['cold']['stdout_base64'],validate=True))==packet['cold']['value'],'actual cold channel'

draft_count,draft_fail=tap(draft_before)
count,failures=tap(before)
assert draft_count==408 and len(draft_fail)==33 and draft_before['returncode']==33
assert [label for label in draft_fail if label.startswith('legacy native-')]==['legacy native-readonly complete native observation']
assert count==487 and len(failures)==48 and before['returncode']==48
assert all(label.startswith('legacy ') and not label.startswith('legacy native-') for label in failures),'only intended before REDs'
assert set(draft_fail)-{'legacy native-readonly complete native observation'}<=set(failures),'draft target failures retained'
for row in (first_positive,positive):
    assert row['returncode']==0 and tap(row)==(count,[]),'positive runtime TAP'
    diagnostic(row)
assert channel(first_positive,'stdout')==channel(positive,'stdout'),'first positive TAP unchanged'
assert channel(first_positive,'stderr')==channel(positive,'stderr'),'first positive diagnostic unchanged'
assert consumers['returncode']==0 and b'All tests successful.' in channel(consumers,'stdout')
old_stats=re.search(rb'Files=(\d+), Tests=(\d+),',channel(seed,'stdout'))
stats=re.search(rb'Files=(\d+), Tests=(\d+),',channel(consumers,'stdout'))
assert stats and old_stats and int(stats[1])==int(old_stats[1])==61,'supplied suite population'
assert int(stats[2])==int(old_stats[2])+count-50,'supplied assertion preservation'

raw=""" my $kind_callback = (ref($deps) eq 'HASH') ? $deps->{bare_symbol_kind} : undef;
 my $bare_symbol_kind = ref($kind_callback) eq 'CODE' ? $kind_callback : sub { return undef };
"""
late=edit(module,BIND,'')
late=edit(late,' my $trimmed = $trim_action_ir_value->($expr);\n',' my $trimmed = $trim_action_ir_value->($expr);\n'+BIND)
variants=[
 ('remove-binding',edit(module,BIND,''),'legacy map-over-undefined-package result'),
 ('raw-callback',edit(module,BIND,raw),'legacy authority/0 separate publication'),
 ('copy-argument',edit(module,BIND,BIND.replace('? $kind_callback :','? sub { my $name = $_[0]; return $kind_callback->($name) } :')),'legacy native-hash actual readonly match alias'),
 ('hash-default',edit(module,BIND,BIND.replace('sub { return undef }',"sub { return 'hash' }")),'legacy missing-map-over-hash-package result'),
 ('late-selection',late,'legacy native-map-replacement result'),
]
inverse_index=record('inverses')
assert inverse_index['producer_sha256']==digest(read(PREFIX+'final-capture.py'))
assert inverse_index['positive']==PREFIX+'positive.json'
assert [row['label'] for row in inverse_index['variants']]==[label for label,source,reason in variants]
fault_counts={}
for (label,changed,reason),summary in zip(variants,inverse_index['variants']):
    row=record('inverse-'+label)
    population=dict(paired_population,**{MODULE:digest(changed.encode())})
    check_capture(row,'final-capture',population,test_command)
    check_capture(row['syntax'],'final-capture',population,['perl','-Iperl','-c',MODULE])
    assert base64.b64decode(row['module_source_base64'],validate=True)==changed.encode(),'actual semantic fault source'
    assert row['syntax']['returncode']==0 and b'syntax OK' in channel(row['syntax'],'stderr'),'syntax-valid fault'
    n,failed=tap(row)
    assert n==count and row['returncode']!=0 and reason in failed,'effective named semantic fault'
    assert all(name.startswith('legacy ') for name in failed),'public fifty controls survive faults'
    assert row['label']==label and row['reason']==reason
    assert summary=={'label':label,'reason':reason,'failures':failed,'artifact':PREFIX+'inverse-'+label+'.json'},'fault summary'
    fault_counts[label]=len(failed)

alias=record('match-alias')
assert alias['producer_sha256']==digest(read(PREFIX+'match-alias.py'))
assert alias['inputs']=={'t/perl_match_alias_writability_probe.pl':digest(read('t/perl_match_alias_writability_probe.pl'))}
assert alias['command']==['perl','t/perl_match_alias_writability_probe.pl'] and alias['returncode']==0 and alias['unchanged'] is True
assert not channel(alias,'stderr')
oracle=json.loads(channel(alias,'stdout'))
assert oracle['perl_version']=='v5.34.1','measured interpreter scope'
assert [row['name'] for row in oracle['rows']]==['lexical','literal','match','copied-match']
assert [row['readonly_flag'] for row in oracle['rows']]==[0,1,0,0],'match oracle flags'
assert [row['actual_slot'] for row in oracle['rows']]==[1,0,1,1],'match oracle actual aliases'
for row in oracle['rows']:
    if row['name'] in ('literal','match'):
        assert 'Modification of a read-only value attempted' in row['error'] and 'after' not in row,'match oracle write rejection'
    else:
        assert row['after']=='meta!' and row['result']=='completed' and 'error' not in row,'match oracle copied/lexical writability'

fixture_correction=record('fixture-correction')
capture_correction=record('capture-correction')
replays=[
 replay(PREFIX+'fixture-correction.py',
  {TEST:draft,PREFIX+'capture.py':read(PREFIX+'capture.py'),PREFIX+'before.json':read(PREFIX+'before.json')},
  {TEST:read(TEST),PREFIX+'complete-capture.py':read(PREFIX+'complete-capture.py'),
   PREFIX+'fixture-draft.t':draft,PREFIX+'fixture-correction.json':read(PREFIX+'fixture-correction.json')},(TEST,)),
 replay(PREFIX+'capture-correction.py',
  {PREFIX+'complete-capture.py':read(PREFIX+'complete-capture.py'),PREFIX+'fixture.json':read(PREFIX+'fixture.json'),
   PREFIX+'capture-correction-draft.py':read(PREFIX+'capture-correction-draft.py')},
  {PREFIX+'final-capture.py':read(PREFIX+'final-capture.py'),PREFIX+'capture-correction.json':read(PREFIX+'capture-correction.json')}),
]
assert fixture_correction['corrected_test_sha256']==digest(read(TEST))
assert capture_correction['observed_inner_exit']==0 and capture_correction['reported_outer_exit']==1
assert capture_correction['observed_assertions']==count and capture_correction['observed_failures']==0
book_review=json.loads(read(PREFIX+'book-review.json'))
assert book_review['result']=='PASS' and book_review['source_count']==89 and book_review['actual_controls']==3
assert book_review['producer_sha256']==digest(read(PREFIX+'book-review.py'))
assert book_review['book_capture_sha256']==digest(read(PREFIX+'book.json'))
assert book_review['book_producer_sha256']==digest(read(PREFIX+'book.py'))
for path,sha in book_review['source_inputs'].items():
    assert digest(read(path))==sha,'current complete book input'
book_result=subprocess.run(['python3',PREFIX+'book-review.py'],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
assert book_result.returncode==0 and not book_result.stderr,'complete book review'
report={'result':'PASS','producer_sha256':digest(Path(__file__).read_bytes()),
 'base':BASE,'preserved_bindings':546,'native_cases':len(names),'native_controls':controls,
 'repair_cases':len(names)-controls,'assertions':count,'original_red':len(failures),'original_controls':count-len(failures),
 'supplied_suites':int(stats[1]),'supplied_inputs':len(paired_population),'supplied_assertions':int(stats[2]),
 'faults':fault_counts,'pure_perl_oracle_cases':len(oracle['rows']),'perl_version':oracle['perl_version'],
 'draft_assertions':draft_count,'draft_red':len(draft_fail),'correction_replays':replays,
 'book_sources':book_review['source_count'],'book_controls':book_review['actual_controls'],
 'book_review_stdout_base64':base64.b64encode(book_result.stdout).decode(),
 'input_metadata':{path:digest((ROOT/path).read_bytes()) for path in sorted(used)},
 'scope':'Bounded legacy optional-kind selection/capture, native match aliases and actual control faults. First native/draft/current streams remain exact. Original546 bindings stay historical at accepted Git. Source-bound supplied population and full book are distinct from supplemental live-worktree Phase0, complete helper/AST/language, required .6.3, sibling optional/direct, output/mapped/full-private/parent/canonical admission.'}
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    assert not target.exists(),'one-shot review publication'
    target.write_text(json.dumps(report,indent=2)+'\n')
else:
    assert json.loads(target.read_bytes())==report,'retained review identity'
print('Legacy hash kind review PASS487/48 RED/439 controls; five faults,61/187,match oracle4,book89/3; original546 preserved')

"""Prepare fresh private-consumer proof while retaining all source9 observations."""
import ast
import common as c
import compare_tracking
result=compare_tracking.check()
assert result==c.load('tracking-full-row-comparison.json.gz')['result']
assert c.load('tracking-assignment-inverse.json.gz')['restored']
for path,image in c.load('rejected-canonical2.json.gz')['sources'].items():assert c.read(path)==image,path
created={}
def create(name,text):
 ast.parse(text)
 path=c.PREFIX+name
 with (c.ROOT/path).open('x') as stream:stream.write(text)
 created[path]=c.read(path)
raw=c.decode(c.read(c.PREFIX+'verify2.py')['base64']).decode()
raw=raw.replace('verify2.py','verify3.py').replace("SUITES=['t/multiline", "SUITES=['t/actionir_tracking_predicate_capture.t','t/multiline",1)
create('verify3.py',raw)
raw=c.decode(c.read(c.PREFIX+'review3.py')['base64']).decode()
raw=raw.replace('import verify2 as verify','import verify3 as verify\nimport compare_tracking').replace('focused9.json.gz','focused10.json.gz')
marker='def check():\n'
private='''def check_private_compatibility():
 rejected=c.load('rejected-canonical2.json.gz')
 assert rejected['canonical_result']['exit_code']==1 and rejected['readonly']['returncode']==0
 raw=c.decode(rejected['canonical_log']['base64'])
 assert c.sha(raw)==rejected['canonical_log']['sha256']
 assert b'Files=91, Tests=32246,' in raw and b'Failed 26/516 subtests' in raw and b'Result: FAIL' in raw
 import gzip
 manifest=json.loads(gzip.decompress(c.decode(rejected['files'][c.PREFIX+'manifest3.json.gz']['base64'])))
 exclusions={c.PREFIX+'manifest3.json.gz',c.PREFIX+'publication3.json','docs/claims/'+c.OWNER+'.json'}
 context=rejected['context']
 assert set(context['inputs'])-exclusions==set(manifest['inputs'])
 for path,identity in manifest['inputs'].items():
  assert context['inputs'][path]==identity
  image=context['overrides'].get(path)
  if image is not None:
   assert c.sha(c.decode(image['base64']))==identity['sha256'] and image['mode']==identity['mode']
  elif c.identity(path)!=identity:
   assert c.sha(subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT))==identity['sha256'],path
 result=compare_tracking.check()
 assert result==c.load('tracking-full-row-comparison.json.gz')['result']
 path='t/actionir_tracking_predicate_probe.pl'
 assert c.read(path)==rejected['files'][path]
 assert c.decode(c.read(path)['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json'
 assert c.decode(c.read(path)['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 inverse=c.load('tracking-assignment-inverse.json.gz')
 assert inverse['restored'] and inverse['syntax']['returncode']==0
 assert inverse['red']['returncode']!=0 and inverse['green']['returncode']==0
 assert inverse['original']==c.read(inverse['path'])
 assert b'preserves complete native row with private authority' in c.decode(inverse['red']['stderr_base64'])
 assert b'tracked scalar assignments preserve values and remain quiet in every context' in c.decode(inverse['red']['stderr_base64'])
 for path,image in inverse['suites'].items():assert c.read(path)==image,path
 return dict(private_rows=result['total_rows'],private_changed_rows=len(result['changed_rows']))

'''
assert raw.count(marker)==1
raw=raw.replace(marker,private+marker+' private=check_private_compatibility()\n',1)
source="for path in c.SOURCES+verify.SUITES+['tests/numeric-codeblocks/indexed-writes.json']:"
target="for path in c.SOURCES+verify.SUITES+['tests/numeric-codeblocks/indexed-writes.json','t/actionir_tracking_predicate_probe.pl','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json']:"
assert raw.count(source)==1;raw=raw.replace(source,target,1)
line=next(line for line in raw.splitlines() if line.startswith(' return dict(cases='))
raw=raw.replace(line,line.replace(' return dict',' result=dict',1)+'\n result.update(private)\n return result',1)
create('review4.py',raw)
raw=c.decode(c.read(c.PREFIX+'publish3.py')['base64']).decode()
for source,target in [('import review3 as review','import review4 as review'),('manifest3','manifest4'),
 ('publication3.json','publication4.json'),('artifact4-','artifact5-'),('scope4-runs','scope5-runs'),
 ('publish3.py','publish4.py'),('focused9.json.gz','focused10.json.gz')]:
 assert source in raw,source;raw=raw.replace(source,target)
source="prior=c.load('publication2-whitespace-boundary.json.gz')['files'][CLAIM]"
assert raw.count(source)==1
raw=raw.replace(source,"prior=c.load('rejected-canonical2.json.gz')['files'][CLAIM]",1)
source="TARGETS=[TARGET,'t/multiline_helper_pattern_validation.t']"
assert raw.count(source)==1
raw=raw.replace(source,"TARGETS=[TARGET,'t/multiline_helper_pattern_validation.t','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json']",1)
source=' producers=set(c.SOURCES+review.verify.SUITES)'
assert raw.count(source)==1
raw=raw.replace(source,source+"\n producers.add('t/actionir_tracking_predicate_probe.pl')",1)
raw=raw.replace('two independently omitted required fixtures','three independently omitted required fixtures')
raw=raw.replace('Each of two real required-fixture omissions','Each of three real required-fixture omissions')
source=' import copy\n'
assert raw.count(source)==1
append=''' claim['scope']+=' The private predicate comparison retains every field in296 original loaded/cold rows. Only26 nested-consumer rows deliberately change assignment source text, including one source-target conversion count4->5; this is not unchanged consumer emission or full-helper admission. The original native fixture/probe remain byte-exact. Source9 is unchanged; focused10 adds the direct private consumer to the prior21 suites.'
 claim['rederive']['result']+=f" Private rows{result['private_rows']}/{result['private_changed_rows']} deliberate consumer changes; actual old-result inverse rejects both source and executable value oracles and restores GREEN."
 claim['falsify']['red_control']+=' Canonical2 completes private91/32246 and rejects only tracking predicate26/516. Its whole publication3, actual readonly PASS, full log and recoverable input epoch precede edits. Full row comparison leaves callback ordering, local aliases, tied fetches, boolean/error effects and private authority exact. The consumer expected-source projection changes only the documented assignment format and additional emitted identifier read, never observed rows or original captures. The actual syntax-valid old-result inverse rejects the updated consumer and independent executable value oracle, then restores both. Earlier sixteen source-fault9 controls remain their actual unchanged-source epoch; the extra inverse is not counted as a new distinct fault family.'
'''
raw=raw.replace(source,append+source,1)
create('publish4.py',raw)
raw=c.decode(c.read(c.PREFIX+'artifacts4.py')['base64']).decode()
for source,target in [('import publish3 as publish','import publish4 as publish'),('publish3.py','publish4.py'),
 ('artifact4-','artifact5-'),('scope4-runs','scope5-runs'),('artifacts4.py','artifacts5.py')]:
 assert source in raw,source;raw=raw.replace(source,target)
raw=raw.replace('named omissions2','named omissions3')
create('artifacts5.py',raw)
path='docs/knowledge/perl-method-assignment-required-capture.md'
before=c.read(path);raw=c.decode(before['base64']).decode()
raw=raw.replace('date: 2026-10-12','date: 2026-10-23',1)
raw=raw.replace('  - "how do recurring private tests survive MethodLowering line changes"',
 '  - "why does the private tracking fixture expect a presence-only assignment"\n  - "how do recurring private tests survive MethodLowering line changes"',1)
source='reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/type-evaluated-values/publish.py. Prior:1a8b20201."'
assert raw.count(source)==1
raw=raw.replace(source,'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-deferred-indexed-writes/publish4.py; original private observations remain historical below."',1)
marker='The receiver mutation and nested write predicates each validate'
assert raw.count(marker)==1
raw=raw.replace(marker,'October12 tracking proof (consumer emission is qualified below):\n\n'+marker,1)
raw+='''
October23 deferred-write12 preserves the original native fixture/probe and all
predicate/authority fields. Returning the assigned value changes26 consumer rows
among296 loaded/cold rows; scalar(value) stays quiet in void/value/list contexts.
One overloaded source target converts five times instead of four because the
new template spells its result slot again. The permanent test projects only this
expected consumer format and its extra source read, retaining every other field.
An actual old-result source inverse rejects both the projected consumer and the
independent executable value oracle, then restores GREEN. See
tracking-full-row-comparison and tracking-assignment-inverse under
`docs/checkpoints/type-deferred-indexed-writes/`. This qualifies consumer emission;
it does not weaken predicate selection, aliases, tied fetches or error controls.
'''
(c.ROOT/path).write_text(raw)
c.save('private-proof-preparation.json.gz',dict(created=created,knowledge_before=before,knowledge_after=c.read(path),
 comparison=result,sources={p:c.read(p) for p in c.SOURCES},producer=c.read(c.PREFIX+'prepare_private_proof.py')))
print('Prepared22-suite focus, strict private review, publication4/three fixture controls; source9 unchanged')

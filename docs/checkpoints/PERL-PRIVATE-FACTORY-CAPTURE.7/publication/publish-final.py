"""Readonly complete supplied fixture admission; --capture creates its claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
LEAF='PERL-PRIVATE-FACTORY-CAPTURE.7'
sha=lambda v:hashlib.sha256(v).hexdigest()
raw=lambda p:(ROOT/p).read_bytes()
assert sys.argv[1:] in ([],['--capture'])
for name in ('publication/verify.py','review-current.py','evidence.py'):
    run=subprocess.run(['python3',PREFIX+name],cwd=ROOT,capture_output=True)
    assert run.returncode==0 and not run.stderr,('actual readonly review',name,run.stderr)
review=json.loads(raw(PREFIX+'review-current.json'));evidence=json.loads(raw(PREFIX+'evidence.json'))
assert review['result']==evidence['result']=='PASS' and len(evidence['controls'])==6
population=review['population']
assert population['original_claim_inputs']==175 and population['original_claim_bytes']==43696
assert population['suites']==91 and population['helpers']==46 and population['supplied_inputs']==363
assert population['assertions']==30394 and population['selected_faults']==4
assert population['recovered_inputs']==134 and population['evolution_denials']==368 and population['new_evolution_denials']==280
assert population['knowledge_bytes']==8388024 and population['book_inputs']==89
knowledge=json.loads(raw(PREFIX+'knowledge.json'));book=json.loads(raw(PREFIX+'book-review.json'))
markdown={p for p in knowledge['inputs'] if p.endswith('.md') and p.startswith(('docs/knowledge/','docs/decisions/'))}
assert len(markdown)==1487 and len(knowledge['changed_cards'])==15
paths=(set(review['inputs'])-markdown)|set(knowledge['changed_cards'])
keep=set(book['oracle_inputs'])|set(book['source_inputs'])|{'docs/checkpoints/REPO-HYGIENE.19/canonical.log.gz'}
# Complete dated Markdown and prior checkpoint data remain byte-retained in the
# bound capsules and gated by actual readonly reviews. Current code, overlays,
# book/oracles, configuration, contracts and every new producer stay explicit.
source_suffixes={'.py','.pl','.pm','.t','.sh'}
paths={p for p in paths if not(p.startswith('docs/checkpoints/') and not p.startswith(PREFIX)
    and Path(p).suffix not in source_suffixes and p not in keep)}
audit_inputs=json.loads(raw(PREFIX+'audit-final.json'))['inputs']
paths={p for p in paths if not(p.startswith('docs/checkpoints/') and not p.startswith(PREFIX)
    and Path(p).suffix in {'.py','.sh'} and p not in audit_inputs and p not in keep)}

paths.update(PREFIX+n for n in ('review-current.json','evidence.py','evidence.json',
    'evidence-originals.json.gz','evidence-reached.json.gz','publish.py'))
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/(PREFIX+'publication')).iterdir() if p.is_file())
bindings=[]
for p in sorted(paths):
    source=ROOT/p;assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=p,sha256=sha(source.read_bytes()),role='producer' if source.suffix in source_suffixes else 'input'))
statement='Exact150-line CI registration selects91 supplied suites/46 helpers:137 tracked/syntax checks and91 suites/30394 assertions from363 unchanged inputs. Four actual exit-zero selection faults and six artifact denials are distinguished. Historical134 recovered files/84613241 bytes,22 recovery controls and368 evolution denials (280 new) pass with zero healthy original-log reads/tracked writes. Whole175/full43696 predecessor and baseline stay historical at858eba97c. Complete Knowledge1487/1349 facts/10442 keys/15 routes/one body/8388024 bytes and book89/four controls pass. Exact staged canonical receipt and normal hooks govern admission.'
claim=dict(name='complete-supplied-private-fixture-canonical-selection',statement=statement,
    scope='Only CI/auditor code changes. Original86/132/131 omissions describe direct execution/track/syntax registration; indirect coverage and runtime defect counts are unassessed. Duplicate syntax138 leaves unique prove91/30394. Original four rows and successful audit command keep their actors; finishers supply only disabled execution/metadata. All failures/exact repairs,194 audit inputs, 619/full138598 and596/full132933 logical drafts remain retained without invented revisions. Original/current Markdown, prior artifacts and retired source bytes stay whole in gated bound capsules; current invoked sources, overlays, contracts/config, book/oracles and new producers are explicit. All15 original cards remain whole/14 bodies exact. Dry run8389286 refuses before writes; final8388024 stays under unchanged8MiB. Claim cap131072 stays fixed. Canonical logs/receipt are separately governed/excluded. No runtime/fixture/dependency/pin/language/budget, arbitrary shell, copied-root, immutable host-toolchain or liveness/recovery/purge claim. Startup.7, pipeline.6, metadata.12 and broader private/mapped/parent admissions stay open.',
    rederive=dict(status='checked',command='bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/publish.py (readonly). review-current.py and evidence.py recheck all retained populations; original writers remain retired.',
        granularity='175/full43696;91 suites/46 helpers/363 inputs/30394 assertions; five actual scripts/channels/actors; exact150-line inverse;134 recovered/84613241 bytes/22 recovery/368 evolution and194 audit inputs; 1487 Markdown/15 originals/14 exact bodies;89 book inputs/four renders;six artifact denials.',result='All scoped checks PASS; exact staged canonical receipt governs admission.'),
    falsify=dict(status='checked',hypothesis='A green shell result or coherent immediate hashes '
        'could hide missing/duplicated/disabled fixture work, changed accepted custody, '
        'incomplete fault evidence, a missing evolution denial or incorrect rendered selection.',
        oracle='Accepted Git whole bytes/modes and actual baseline; original supplied command/input capsule; independent ordered syntax/test populations and harness summary; original runner hash and accepted recovery/evolution ledger plus280 exact mutations; independently derived rendered tables.',
        red_control='Original direct-selection and unchanged-auditor REDs; four actual exit-zero selection faults; 280 added mutations within368 evolution denials; six coherent artifact forgeries with full changed bytes/modes/channels and exact restored PASS; four book mutations; actual8389286 prewrite budget refusal. Named reasons and all original actors remain gated in review-current.'),
    durability=dict(status='checked',mode='live',inputs=bindings))
value=(json.dumps(dict(version=1,owner=LEAF,claims=[claim]),indent=1)+'\n').encode()
assert len(value)<=131072,(len(value),len(bindings))
target=ROOT/('docs/claims/'+LEAF+'.json')
if sys.argv[1:]:
    with target.open('xb') as output:output.write(value)
else:assert target.read_bytes()==value
print('Supplied fixture admission publication PASS:',len(bindings),'live inputs;',len(value),'bytes')

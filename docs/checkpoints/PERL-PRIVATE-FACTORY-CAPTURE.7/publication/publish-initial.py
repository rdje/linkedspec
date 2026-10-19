"""Readonly complete supplied fixture admission; --capture creates its claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
LEAF='PERL-PRIVATE-FACTORY-CAPTURE.7'
sha=lambda v:hashlib.sha256(v).hexdigest()
raw=lambda p:(ROOT/p).read_bytes()
assert sys.argv[1:] in ([],['--capture'])
for name in ('review-current.py','evidence.py'):
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
paths.update(PREFIX+n for n in ('review-current.json','evidence.py','evidence.json',
    'evidence-originals.json.gz','evidence-reached.json.gz','publish.py'))
bindings=[]
for p in sorted(paths):
    source=ROOT/p;assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=p,sha256=sha(source.read_bytes()),role='producer' if source.suffix in source_suffixes else 'input'))
statement=('One exact150-line CI insertion selects91 supplied suites and46 test helpers through137 '
    'tracked/syntax checks and91 suites/30394 assertions. All363 supplied bytes/modes stay exact. '
    'Four actual exit-zero selection faults are distinguished. Exact historical inverse/22 recovery '
    'controls/368 evolution denials (280 new) pass with134 recovered files/84613241 bytes and zero '
    'healthy original-log reads/tracked writes. Whole175-input/43696-byte predecessor and actual '
    'baseline remain historical at858eba97c. Six artifact denials, complete Knowledge1487/1349 '
    'facts/10442 keys/fifteen routes/one body/8388024 bytes and book89/four controls pass. '
    'Exact staged canonical CI and normal hooks govern admission.')
claim=dict(name='complete-supplied-private-fixture-canonical-selection',statement=statement,
    scope='Original literal commands omit86 direct suite executions and132/131 tracked/syntax '
        'paths across137. Indirect coverage is not inventoried and omissions are not runtime '
        'defect counts. One historical checkpoint suite belongs to the supplied91;46 t/*.pl '
        'helpers are selected and three incidental legacy namespace scripts stay retained. '
        'Healthy137/91/30394, omitted-suite136/90/30179, omitted-helper136/91/30394, duplicate '
        'syntax138 with unique prove91/30394, and disabled137/no suites all exit0. Original '
        'four observations keep their original actor; only disabled execution has a distinct '
        'finisher. Original old-auditor PASS/RED, t/-only inventory refusal, ambiguous metadata '
        'anchor, whole-runner suffix collision, duplicate-report postcondition and recovered '
        'count mistakes remain preserved with exact bounded corrections. Successful historical '
        'command capture keeps its identity; metadata alone is finalized after manifest-derived '
        '134 replaces incorrect192. Complete194 audit inputs retain bytes/modes. Original '
        '8389286 dry run refuses before card writes; pure proposals reconstruct from real accepted '
        'Git, and distinct condensation gives8388024 under unchanged8MiB. All15 whole original '
        'cards remain retained and14 bodies stay exact. Complete original/current Markdown and '
        'prior checkpoint artifact bytes remain in bound capsules and are gated by actual '
        'readonly reviews; current code, overlays, book/oracles, config/contracts and all new '
        'producers are explicit bindings. Only CI/auditor code changes. Actual canonical logs '
        'and receipt are separately governed and excluded from this fixed census. No runtime, '
        'fixture, dependency/pin, language, budget, arbitrary-shell, copied-root, immutable '
        'host-toolchain or liveness/recovery/purge claim. Startup.7, pipeline.6, metadata.12 '
        'and broader private/mapped/parent admissions retain separate owners.',
    rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+PREFIX+
        'publish.py (readonly default). review-current.py, review-selection.py, review-audit.py, '
        'book-review.py, inventory-final.py and evidence.py defaults are readonly. All '
        'capture/preservation/preparation/repair/finisher writers remain retired one-shot instruments.',
        granularity='Every175 predecessor binding/whole43696 bytes and fixed accepted claim namespace; '
            'all91 suite/46 helper/363 supplied inputs, five actual Bash scripts/channels and '
            'per-case actors; exact150-line insertion and complete original auditor/inverse; '
            'all134 recovered paths/22 recovery/368 evolution controls and194 audit inputs; '
            'all1487 original/current Markdown bytes/modes,15 whole originals/14 exact bodies; '
            '89 book/include inputs/four render controls and six full artifact counterfactuals.',result=statement),
    falsify=dict(status='checked',hypothesis='A green shell result or coherent immediate hashes '
        'could hide missing/duplicated/disabled fixture work, changed accepted custody, '
        'incomplete fault evidence, a missing evolution denial or incorrect rendered selection.',
        oracle='Real accepted Git namespace/whole bytes/modes and successful baseline; original '
            'supplied command and full input capsule; independent actual ordered syntax/test '
            'populations and original harness summary; exact original runner hash and actual '
            'accepted recovery/evolution ledger plus280 narrow block mutations; separately '
            'derived rendered tables and complete recursive include graph.',
        red_control='Original require-complete command exits1; unchanged original auditor passes '
            'before insertion and rejects afterward. Four actual exit-zero selections are RED '
            'at their measured syntax/test/summary granularity. All280 added registration '
            'mutations reject within368 total evolution controls. Six artifact forgeries '
            'deny changed predecessor, coherent summary/syntax, missing fault, coherent '
            'evolution count and repacked rendered selection; complete changed bytes/modes '
            'and both channels restore exact PASS. Four actual book mutations have scoped '
            'render/error oracles. Actual dry run refuses8389286 before any card write.'),
    durability=dict(status='checked',mode='live',inputs=bindings))
value=(json.dumps(dict(version=1,owner=LEAF,claims=[claim]),indent=2)+'\n').encode()
assert len(value)<=131072,(len(value),len(bindings))
target=ROOT/('docs/claims/'+LEAF+'.json')
if sys.argv[1:]:
    with target.open('xb') as output:output.write(value)
else:assert target.read_bytes()==value
print('Supplied fixture admission publication PASS:',len(bindings),'live inputs;',len(value),'bytes')

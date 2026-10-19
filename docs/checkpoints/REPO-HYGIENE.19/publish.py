"""Readonly dated retention publication; --capture creates its bounded claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
LEAF='REPO-HYGIENE.19'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
raw=lambda p:(ROOT/p).read_bytes()
assert sys.argv[1:] in ([],['--capture'])
repair=json.loads(raw(PREFIX+'review-repair.json'))
source=raw(PREFIX+'review-current.py')
assert repair['result']=='PASS' and repair['original_returncode']==1
assert repair['producer_sha256']==sha(raw(PREFIX+'repair-review.py'))
assert repair['original_source_sha256']==sha(source)
assert b'assert len(source_lines)==len(final_lines)' in decode(repair['original_stderr_base64'])
old,new=decode(repair['old_base64']),decode(repair['new_base64'])
assert source.count(old)==1
corrected=source.replace(old,new).replace(b"PREFIX+'review-current.py'",b"PREFIX+'review-final.py'")
corrected=corrected.replace(b"PREFIX+'review-current.json'",b"PREFIX+'review-final.json'")
corrected=corrected.replace(b"{'review-current.json','evidence.py'",b"{'review-current.json','review-final.json','evidence.py'")
assert corrected==raw(PREFIX+'review-final.py') and sha(corrected)==repair['corrected_sha256']
for name in ('review-final.py','evidence.py'):
    run=subprocess.run(['python3',PREFIX+name],cwd=ROOT,capture_output=True)
    assert run.returncode==0 and not run.stderr,('readonly proof',name,run.stderr)
review=json.loads(raw(PREFIX+'review-final.json'));evidence=json.loads(raw(PREFIX+'evidence.json'))
assert review['result']==evidence['result']=='PASS' and len(evidence['controls'])==4
population=review['population']
assert population['original_claim_inputs']==550 and population['original_claim_bytes']==128458
assert population['knowledge_bytes']==8388524 and population['warning_occurrences']==24
knowledge=json.loads(raw(PREFIX+'knowledge.json'))
markdown={p for p in knowledge['inputs'] if p.endswith('.md') and p.startswith(('docs/knowledge/','docs/decisions/'))}
assert len(markdown)==1487 and len(knowledge['changed_cards'])==14
# The complete dated Markdown population is retained in the bound capsule and
# gated by the actual readonly reviewer. Bind current overlays separately.
paths=(set(review['inputs'])-markdown)|set(knowledge['changed_cards'])
paths.update(PREFIX+n for n in ('review-final.json','evidence.py','evidence.json','evidence-originals.json.gz','evidence-reached.json.gz','publish.py'))
bindings=[]
for p in sorted(paths):
    path=ROOT/p;assert path.is_file() and not path.is_symlink()
    bindings.append(dict(path=p,sha256=sha(path.read_bytes()),role='producer' if path.suffix in ('.py','.pl','.pm','.sh','.t') else 'input'))
statement=('Dated parent16443/17576851726 and separate Rust incremental483/2390810573 metadata '
    'are retained with zero removals. Four actual channel, eight warning-artifact and four '
    'custody denials restore exact PASS. Complete canonical output has24 public compiler-summary '
    'occurrences:12 pgen reports7093 and12 rgx-core reports26. Whole550-input/128458-byte '
    'predecessor and actual baseline remain historical at e953f69a9. Complete Knowledge1487 '
    'Markdown/1349 facts/fourteen routes/one body/8388524 bytes and book89/four controls pass.')
claim=dict(name='dated-retained-metadata-public-warning-output',statement=statement,
    scope='Metadata observation2026-10-19T00:47:29.953626UTC preserves all artifacts/caches; '
        'Rust release is absent and deps has zero log/bin rows. Full actual census/live-review '
        'commands, exits, channels, source guards, fresh/lstat/size/traversal controls remain '
        'captured. No current filesystem stability, content/disposability, liveness, '
        'concurrent adversarial traversal, recovery or purge claim. Compiler counts are '
        'reported summary occurrences, not distinct diagnostics/bugs, proven comparable '
        'configurations or an internal cause. Full accepted canonical log, partial/final '
        'observations, observed CLI identities and real staged/promoted receipts are '
        'retained; independent raw-line/phase/crate/count and parent/diff/tree derivation '
        'pass. Old1870/26 account remains whole at accepted Git and in tracked evidence. '
        'RUST-DEPENDENCY-WARNING-ZERO.1/.2 keep fuller census/upstream ownership open and '
        'non-blocking behind residual repair. No new Rust build, dependency implementation '
        'inspection, separate PGEN procedure, source/pin change, cargo fix or suppression. '
        'Fixed accepted claim namespace, every original binding byte/actual mode and whole '
        'publication match accepted Git; only durability mode/revision changes. Complete '
        'original/current Markdown bytes are bound in knowledge-inputs.json.gz and gated '
        'by the actual readonly reviewer; fourteen current overlays and other actual '
        'support/book inputs are separately bound. Thirteen card bodies and native '
        'teaching stay exact. First oversized Knowledge header is refused before writes; '
        'only concise evidence expression/report path changes. First reader wrongly '
        'requires equal physical expression line counts; original failure/source and '
        'exact expression-boundary correction stay retained. Existing limits, runtime, '
        'test/checker/CI mechanisms and dependencies stay exact. This focused dated '
        'observation grants no new canonical/private/pipeline/parent admission; startup.7 '
        'restrictions and fixture.7/pipeline.6/metadata.12 remain separately owned.',
    rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+PREFIX+
        'publish.py (readonly default). review-final.py, actual-review.py, metadata-evidence.py, '
        'warning-review.py, warning-evidence.py, book-review.py and evidence.py defaults '
        'are readonly. All original capture/preparation/repair writers remain retired.',
        granularity='Each dated parent/Rust metadata row, both actual commands/channels/guards '
            'and independent live controls; every24 summary line/phase/crate/count and two '
            'actual receipts; fixed accepted claim namespace,550 bindings/full128458 bytes; '
            'all1487 original/current Markdown bytes and separate archive/current modes, '
            'fourteen headers/thirteen exact bodies;89 complete book/include inputs and '
            'four rendered controls;4+8+4 full actual artifact denials/restorations.',result=statement),
    falsify=dict(status='checked',hypothesis='Incomplete claim/binding/summary populations, '
        'coherent immediate hashes or rehashed output could hide changed accepted custody, '
        'producer failure/missing channels, swapped counts/crates/phases, forged receipts '
        'or historical baseline, failed canonical outcome, or incorrect rendered teaching.',
        oracle='Actual original Git namespace/bytes/modes and successful baseline; independent '
            'fresh OS metadata, complete channels and source guards; raw summary bytes/nearest '
            'public phase and actual accepted parent/diff/tree; separately derived rendered '
            'warning/native/capacity tables and complete recursive include graph.',
        red_control='Actual live aggregate inflation/balanced redistribution and five traversal '
            'denials pass. Four actual metadata-channel, eight warning-artifact and four '
            'preservation/rendered-count forgeries reject for distinct observed reasons; '
            'full changed bytes/modes/channels and exact restored PASS are retained. Four '
            'actual book mutations have scoped rendered/source/error oracles. Original '
            '8388673-byte header proposal is refused before writes under unchanged8MiB.'),
    durability=dict(status='checked',mode='live',inputs=bindings))
value=(json.dumps(dict(version=1,owner=LEAF,claims=[claim]),indent=2)+'\n').encode()
assert len(value)<=131072,(len(value),len(bindings))
target=ROOT/('docs/claims/'+LEAF+'.json')
if sys.argv[1:]:
    with target.open('xb') as output:output.write(value)
else:assert target.read_bytes()==value
print('Retained metadata/output publication PASS:',len(bindings),'live inputs;',len(value),'bytes')

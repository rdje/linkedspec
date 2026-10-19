"""Retain the prepared draft and shorten only repeated claim prose."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
DIRECTORY=ROOT/(PREFIX+'publication')
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
history=DIRECTORY/'preparation-history.json.gz';assert not history.exists()
path=DIRECTORY/'publish-final.py';source=path.read_bytes()
prefix=source.split(b'\nassert len(value)<=131072',1)[0]
guard=b'if p.is_file())'
assert prefix.count(guard)==1
# Reconstruct the namespace before this refinement source was created.
prefix=prefix.replace(guard,b"if p.is_file() and p.name != 'compact-claim.py')",1)
namespace={'__file__':str(path),'__name__':'readonly_prepared_draft_recurrence'}
exec(compile(prefix,str(path),'exec'),namespace)
draft=namespace['value'];assert len(draft)==132933 and len(namespace['bindings'])==596
prior=json.loads((DIRECTORY/'repair.json').read_bytes())
archive=dict(prepared_source_base64=encode(source),prepared_source_sha256=sha(source),
    prepared_repair_base64=encode((DIRECTORY/'repair.json').read_bytes()),
    prepared_draft_base64=encode(draft),prepared_draft_sha256=sha(draft),bindings=596,bytes=132933,
    preflight_exit_observed=1,
    transcribed_tool_output='Final publisher preflight: 132933 bytes; 596 inputs;cap131072\nTraceback (most recent call last):\n  File "<stdin>", line 8, in <module>\nAssertionError\n',
    scope='Original tool result is explicitly transcribed, not an original transport envelope. Distinct readonly recurrence retains the complete prepared logical draft using the before-refinement namespace; only this newly created source is excluded from that old namespace. No writer/native observation is replayed. All earlier source/draft/failure files stay unchanged.')
with history.open('xb') as output:output.write(gzip.compress(json.dumps(archive,sort_keys=True).encode(),mtime=0))
scope=('Only CI/auditor code changes. Original86/132/131 omissions describe direct execution/track/syntax '
    'registration; indirect coverage and runtime defect counts are unassessed. Duplicate syntax138 '
    'leaves unique prove91/30394. Original four rows and successful audit command keep their actors; '
    'finishers supply only disabled execution/metadata. All failures/exact repairs,194 audit inputs, '
    '619/full138598 and596/full132933 logical drafts remain retained without invented revisions. '
    'Original/current Markdown, prior artifacts and retired source bytes stay whole in gated bound '
    'capsules; current invoked sources, overlays, contracts/config, book/oracles and new producers '
    'are explicit. All15 original cards remain whole/14 bodies exact. Dry run8389286 refuses before '
    'writes; final8388024 stays under unchanged8MiB. Claim cap131072 stays fixed. Canonical logs/receipt '
    'are separately governed/excluded. No runtime/fixture/dependency/pin/language/budget, arbitrary '
    'shell, copied-root, immutable host-toolchain or liveness/recovery/purge claim. Startup.7, '
    'pipeline.6, metadata.12 and broader private/mapped/parent admissions stay open.')
start=source.index(b'\n    scope=');end=source.index(b'\n    rederive=',start)
source=source[:start]+('\n    scope='+repr(scope)+',').encode()+source[end:]
start=source.index(b'rederive=dict(status=');a=source.index(b'command=',start);b=source.index(b'\n        granularity=',a)
command='bash tools/run_python_project_data.sh '+PREFIX+'publish.py (readonly). review-current.py and evidence.py recheck all retained populations; original writers remain retired.'
source=source[:a]+('command='+repr(command)+',').encode()+source[b:]
a=source.index(b'granularity=',start);b=source.index(b'\n    falsify=',a)
granularity=('175/full43696;91 suites/46 helpers/363 inputs/30394 assertions; five actual scripts/channels/actors; '
    'exact150-line inverse;134 recovered/84613241 bytes/22 recovery/368 evolution and194 audit inputs; '
    '1487 Markdown/15 originals/14 exact bodies;89 book inputs/four renders;six artifact denials.')
source=source[:a]+('granularity='+repr(granularity)+",result='All scoped checks PASS; exact staged canonical receipt governs admission.'),").encode()+source[b:]
a=source.index(b'        oracle=',source.index(b'\n    falsify='));b=source.index(b'\n        red_control=',a)
oracle=('Accepted Git whole bytes/modes and actual baseline; original supplied command/input capsule; '
    'independent ordered syntax/test populations and harness summary; original runner hash and '
    'accepted recovery/evolution ledger plus280 exact mutations; independently derived rendered tables.')
source=source[:a]+('        oracle='+repr(oracle)+',').encode()+source[b:]
a=source.index(b'        red_control=',source.index(b'\n    falsify='));b=source.index(b'\n    durability=',a)
red=('Original direct-selection and unchanged-auditor REDs; four actual exit-zero selection faults; '
    '280 added mutations within368 evolution denials; six coherent artifact forgeries with full '
    'changed bytes/modes/channels and exact restored PASS; four book mutations; actual8389286 '
    'prewrite budget refusal. Named reasons and all original actors remain gated in review-current.')
source=source[:a]+('        red_control='+repr(red)+'),').encode()+source[b:]
compile(source,str(path),'exec')
prior.update(final_source_sha256=sha(source),prose_refinement_producer_sha256=sha(Path(__file__).read_bytes()),
    prepared_history_sha256=sha(history.read_bytes()),
    refinement_scope='Only repeated claim prose is shortened; no input selection, producer, native observation, limit or semantic predicate changes. Full prepared source/repair/logical draft and transcribed preflight remain in preparation-history.json.gz. Every publication file stays explicitly bound.')
path.write_bytes(source);(DIRECTORY/'repair.json').write_text(json.dumps(prior,indent=2)+'\n')
print('Prepared draft retained; only repeated prose shortened; all input selections/caps unchanged')

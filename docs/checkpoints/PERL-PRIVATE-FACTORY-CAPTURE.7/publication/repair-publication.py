"""Retain the initial logical draft and prepare a bounded stable entrypoint."""
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
target=DIRECTORY/'repair.json';assert not target.exists()
entry=ROOT/(PREFIX+'publish.py');original=entry.read_bytes()
combined=(ROOT/'.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.7-publication.log').read_bytes()
assert combined.rstrip().endswith(b'AssertionError: (138598, 619)')
prefix=original.split(b'\nassert len(value)<=131072',1)[0]
assert prefix!=original
namespace={'__file__':str(entry),'__name__':'readonly_original_draft_recurrence'}
exec(compile(prefix,str(entry),'exec'),namespace)
draft=namespace['value'];initial=json.loads(draft)
assert len(draft)==138598 and len(initial['claims'][0]['durability']['inputs'])==619
assert next(v for v in initial['claims'][0]['durability']['inputs'] if v['path']==PREFIX+'publish.py')['sha256']==sha(original)
with (DIRECTORY/'publish-initial.py').open('xb') as output:output.write(original)
with (DIRECTORY/'initial-draft.json.gz').open('xb') as output:output.write(gzip.compress(draft,mtime=0))
failure=dict(result='RETAINED',original_source_sha256=sha(original),original_exit_observed=1,
    original_combined_base64=encode(combined),initial_bindings=619,initial_bytes=138598,
    recurrence_prefix_sha256=sha(prefix),retained_draft_sha256=sha(draft),
    scope='Initial in-memory draft was not serialized at the failing call. This distinct readonly pure-prefix recurrence runs while all inputs and original publisher remain unchanged, then retains the full619-input/138598-byte logical draft and original source. It executes no writer or native capture and invents no accepted Git revision. Original actual failure/transport scope stays explicit.')
with (DIRECTORY/'failure.json').open('x') as output:output.write(json.dumps(failure,indent=2)+'\n')
source=original.replace(b'ROOT=Path(__file__).resolve().parents[3]',b'ROOT=Path(__file__).resolve().parents[4]',1)
marker=b"\npaths.update(PREFIX+n for n in ('review-current.json'"
addition=b'''\naudit_inputs=json.loads(raw(PREFIX+'audit-final.json'))['inputs']
paths={p for p in paths if not(p.startswith('docs/checkpoints/') and not p.startswith(PREFIX)
    and Path(p).suffix in {'.py','.sh'} and p not in audit_inputs and p not in keep)}
'''
assert source.count(marker)==1;source=source.replace(marker,addition+marker,1)
assert source.count(b'\nbindings=[]\n')==1
source=source.replace(b'\nbindings=[]\n',b"\npaths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/(PREFIX+'publication')).iterdir() if p.is_file())\nbindings=[]\n",1)
statement=('Exact150-line CI registration selects91 supplied suites/46 helpers:137 tracked/syntax '
    'checks and91 suites/30394 assertions from363 unchanged inputs. Four actual exit-zero '
    'selection faults and six artifact denials are distinguished. Historical134 recovered '
    'files/84613241 bytes,22 recovery controls and368 evolution denials (280 new) pass with '
    'zero healthy original-log reads/tracked writes. Whole175/full43696 predecessor and '
    'baseline stay historical at858eba97c. Complete Knowledge1487/1349 facts/10442 keys/15 '
    'routes/one body/8388024 bytes and book89/four controls pass. Exact staged canonical '
    'receipt and normal hooks govern admission.')
start=source.index(b'statement=(');end=source.index(b'\nclaim=dict(',start)
source=source[:start]+('statement='+repr(statement)).encode()+source[end:]
scope=('Only CI/auditor code changes. Original literal omissions86 execution/132 tracked/131 '
    'syntax are direct-command counts; indirect coverage and runtime defect counts are '
    'unassessed. One historical checkpoint suite and46 test helpers belong to the supplied '
    'population. Duplicate syntax138 leaves unique prove91/30394; other actual faults lose '
    'suite/helper/execution work despite exit0. Four original rows keep their actor; only '
    'disabled execution and later metadata have distinct finishers. Successful audit '
    'command capture retains its identity and194 full inputs; manifest membership derives134 '
    'rather than the incorrect192 metadata guard. Original failures/exact repairs remain '
    'retained. Initial619/full138598 draft is reconstructed under unchanged inputs and '
    'retained with its source/actual cap refusal; no originally serialized transport or '
    'invented revision is claimed. Original/current Markdown, prior artifacts and retired '
    'producer sources stay whole in bound capsules and are gated by readonly reviews. '
    'Current invoked sources, overlays, contracts/config, book/oracles and new producers '
    'are explicit. All15 original cards remain whole;14 bodies stay exact. Dry run8389286 '
    'refuses before writes; distinct condensation gives8388024 under unchanged8MiB. Claim '
    'cap131072 stays fixed. Canonical logs/receipt are separately governed/excluded from '
    'this census. No fixture/runtime/dependency/pin/language/budget, arbitrary-shell, '
    'copied-root, immutable host-toolchain or liveness/recovery/purge claim. Startup.7, '
    'pipeline.6, metadata.12 and broader private/mapped/parent admissions remain open.')
start=source.index(b'\n    scope=');end=source.index(b'\n    rederive=',start)
source=source[:start]+('\n    scope='+repr(scope)+',').encode()+source[end:]
compile(source,str(DIRECTORY/'publish-final.py'),'exec')
wrapper=b'''"""Stable readonly entrypoint; original draft/source and bounded repair stay retained."""
import hashlib
import json
from pathlib import Path
directory=Path(__file__).resolve().parent/'publication'
record=json.loads((directory/'repair.json').read_bytes())
source=directory/'publish-final.py';value=source.read_bytes()
assert hashlib.sha256(value).hexdigest()==record['final_source_sha256']
assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest()==record['wrapper_sha256']
exec(compile(value,str(source),'exec'),{'__file__':str(source),'__name__':'__main__'})
'''
record=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),
    original_source_sha256=sha(original),original_draft_sha256=sha(draft),original_bindings=619,original_bytes=138598,
    final_source_sha256=sha(source),wrapper_sha256=sha(wrapper),
    scope='Keep all original native observations and the entire uncommitted logical publication. One exact additional filter places29 retired prior checkpoint source paths in already bound complete capsules, preserving current invoked/audit sources and all new producers explicitly. Concise statement/scope retains the measured limits. Add every publication artifact as an input and retain indent2/cap131072. Stable entrypoint loads this source module; exact readonly recurrence and canonical admission remain required.')
with (DIRECTORY/'publish-final.py').open('xb') as output:output.write(source)
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
entry.write_bytes(wrapper)
print('Publication repair prepared:whole619/full138598 retained;current sources explicit;cap unchanged')

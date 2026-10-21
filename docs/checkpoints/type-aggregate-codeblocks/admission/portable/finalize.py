"""Prepare the clean portable handoff after all named source epochs pass."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import publish_portable


def first_record(text,paragraph):
    start=text.index('\n## ')+1;end=text.find('\n## ',start+1)
    if end<0:end=len(text)
    return text[:end].rstrip()+'\n\n'+paragraph+'\n\n'+text[end:].lstrip('\n')


def main():
    result=publish_portable.proof(publish_portable.input_paths(),False,require_documents=False)
    fact='docs/knowledge/terse-type-method-surface-inventory.md'
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    paths=['CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
        task,'docs/TASK_TREE.md',c.PREFIX+'README.md',fact]
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    after['CHANGES.md']=after['CHANGES.md'].replace('publish_admitted.py','publish_portable.py')
    after['CHANGES.md']=first_record(after['CHANGES.md'],
        'Portable retention preserves the whole third10540-input draft/actual readonly0 and10543 '
        'Git-verified images before replacing three oversized staged blobs with37 verified32MiB '
        'chunks. Exact1171950805 logical bytes/full modes reconstruct into ignored project-local '
        'aliases. Five pre-root-guard artifact faults restore; a metadata-only nested-root RED and '
        'fresh final-helper cold replay cover the sole helper delta. Actual readers use reconstructed '
        'files before three verified backups are deleted, leaving zero residue. Canonical2 was '
        'deliberately superseded143. Current source-readonly gateway is publish_portable.py; exact '
        'staged Git-size/canonical admission remains required. No tracked input is changed by default.')
    notes=after['DEVELOPMENT_NOTES.md']
    old='Checkpoint context previously embedded every earlier changed gzip in later snapshots. Actual retained overrides distinguish that recursion. Future snapshots retain immutable gzip byte/mode identities, whole changed plain sources and real accepted Git recovery; any later gzip change needs an explicit before packet. All existing gzip evidence stays unchanged and hash-gated.'
    new='Checkpoint context stops recursively embedding immutable gzip/chunks, retaining their byte/mode identities and whole plain-source packets. Three oversized draft inputs now recover from37 tracked32MiB chunks into ignored aliases. Five faults retain the pre-root-guard helper; a metadata-only boundary RED and final cold replay cover its sole delta. All old logical bytes/modes remain exact; changing an immutable input needs a before packet.'
    assert notes.count(old)==1
    notes=notes.replace(old,new,1).replace('publish_admitted.py','publish_portable.py')
    assert len(notes.encode())<65536*0.9
    after['DEVELOPMENT_NOTES.md']=notes
    text=after[fact]
    text=text.replace('date: 2026-10-21\n',
        '  - "how do checkpoint chunks restore data and reject nested Git roots"\ndate: 2026-10-21\n',1)
    old_evidence='TYPE-REFERENCE-BOOK.1.2.3-.7 retain accepted/candidate epochs and actual producer faults. Aggregate7 owns deferred dispatch/shapes;95 owns selected-string kinds and9 the deferred sorted pipeline.'
    assert text.count(old_evidence)==1
    text=text.replace(old_evidence,'TYPE-REFERENCE-BOOK.1.2.3-.7 retain actual source/fault epochs. Aggregate7 binds portable input custody;95/9 remain owned.',1)
    old_paragraph='Checkpoint context once embedded prior gzip inputs recursively. It now keeps their immutable byte/mode identities; old full snapshots remain hash-gated. collection/repack.json.gz retains the actual old duplication RED.'
    assert text.count(old_paragraph)==1
    text=text.replace(old_paragraph,'Context stopped embedding immutable gzip/chunks. Oversized drafts recover from37 verified32MiB parts into ignored local aliases; exact bytes/modes and nested-repository guards remain checked. Old recursive snapshots stay retained.',1)
    text=text.replace('publish_admitted.py','publish_portable.py')
    knowledge=sum(path.stat().st_size for path in (ROOT/'docs/knowledge').glob('*.md'))
    knowledge+=len(text.encode())-len(c.decode(before[fact]['base64']))
    assert knowledge<=8388608,knowledge
    after[fact]=text
    start=after[task].index('- ID: `'+c.OWNER+'`\n');end=after[task].index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n',start)
    node=after[task][start:end].replace('Status: `in_progress` / portable retained-input admission',
        'Status: `done` / bounded Perl availability and portable evidence admission',1)
    node=node.replace('  - [ ] **NO REGRESSION**','  - [x] **NO REGRESSION**',1).replace('  - [ ] **LOCKSTEP**','  - [x] **LOCKSTEP**',1)
    node+='  Portable verification:37 chunks/3 cold aliases/1171950805 exact bytes/full modes; five actual pre-root-guard faults, one metadata-only root RED and final-helper cold replay. Recovered inputs feed actual maintained readers before verified backup deletion/residue0. Whole third10540/images10543 and all earlier epochs survive. Current publish_portable.py, prospective physical-size checks and exact staged Git/canonical receipt govern landing.\n\n'
    after[task]=after[task][:start]+node+after[task][end:]
    after[task]=after[task].replace('| `'+c.OWNER+'` | `in_progress` | Portable retained-input admission; pipeline9 follows clean landing. |',
        '| `'+c.OWNER+'` | `done` | Bounded availability/portable evidence; owned pipeline9 next. |',1)
    assert len(after[task].encode())<=65536
    after['docs/TASK_TREE.md']=after['docs/TASK_TREE.md'].replace(
        '`active` / aggregate .1.2.7 portable admission; .1.2.9 next',
        '`active` / aggregate .1.2.7 done; pipeline .1.2.9 next',1)
    live=after['LIVE_ACHIEVEMENT_STATUS.md']
    live=live.replace(c.OWNER+' behavior/book/pressure proof passes; portable retained-input admission remains in progress. Deferred sorted/take9 follows the clean canonical commit.',
        c.OWNER+' completes bounded Perl aggregate availability and portable evidence admission; deferred sorted/take9 follows clean Git.',1)
    live=live.replace('publish_admitted.py','publish_portable.py')
    live=live.replace('Exact staged canonical receipt is required for landing.',
        'Whole third10540/images10543/actual readonly0 survives.37 chunks restore3 exact logical '
        'inputs; five pre-root-guard controls and final boundary/cold replay pass with zero backup '
        'residue. Exact staged Git-size/canonical receipt is required for landing.',1)
    after['LIVE_ACHIEVEMENT_STATUS.md']=live
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — derive current HEAD from Git; normal post-commit requires HEAD^1.
- latest_completed_leaf: `{c.OWNER}` — subject `{c.OWNER} - execute deferred array reducers`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.9` (pending clean activation); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Run aggregate publish_portable.py source-readonly; preserve its complete claim/publication/physical and logical input manifests/full modes and actual clean baseline before activating the owned deferred sorted/take pipeline9. Continue full PNT after each normal commit.
- in_flight_uncommitted: none; intended clean post-landing handoff. No verification job belongs to the committed state.
- current_proof:214/212 values/two diagnostics;106 accepted RED/108 controls;7 restored runtime faults;final14/1948;201+3 permanent/15 malformed;book89/3/heading RED;history650 unchanged. Exact staged Git-size/canonical receipt governs landing.
- book_admission:50007/50000 RED ->49836 after171 lossless prose-line reductions; unchanged fences/rendered content and15 whitespace-only search bodies. Fact finding/questions merged into existing owner; no budget raised.
- checkpoint: {c.PREFIX}README.md; publish_portable.py is current source-readonly gateway; it rehydrates ignored logical aliases from tracked chunks. Claim docs/claims/{c.OWNER}.json.
- portable_inputs:37 verified32MiB chunks/3 aliases/1171950805 exact bytes/full modes. Five chunk/alias faults retain pre-root-guard bytes; separate metadata-only nested-root RED/rejection and final cold replay cover the helper delta. Actual readers consume recovered inputs before verified backup deletion/residue0.
- custody: Whole accepted drop10334 plus unpublished10496/images10499,10522/images10525 and10540/images10543/full modes/actual readonly0 survive. No draft Git revision invented; old publication outputs remain frozen. Canonical1/2 deliberately joined143 before bound changes; neither is claimed successful.
- containment: Notes compact only the new record; provisional4959 outputs/failures survive and committed history stays unchanged. context.py hash-gates immutable gzip/chunks without recursive embedding; all prior logical bytes remain exact.
- kind95: Three real selected-string index failures/two scalar controls/B flags remain owned despite numeric JSON. Actual old192-input library/65 loaded owners is verified/restored. Original95 instrument/environment remains unretained;95 follows94 before51 with Boolean audit.
- next_owned:9 -> inventory1 -> book mapping2 -> layout3 -> legacy8 -> metadata QA13 -> references/closeout. Startup20/32/35/87.4 and constructor94 remain owned.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; less than24h. Frozen inputs/chunks remain required. Reconstructed aliases are project-local generated data; the gateway verifies them.
- standing_limit: Other repositories and RGX/PGEN remain read-only black boxes. Project data stays on this volume. Full CI before final clean push; no push yet.
'''
    after[c.PREFIX+'README.md']=after[c.PREFIX+'README.md'].replace(
        'Current readonly rederive: publish_admitted.py.',
        'Current source-readonly rederive: publish_portable.py.',1)
    after[c.PREFIX+'README.md']+='''
Portable source admission: three oversized staged blobs remain recoverable as37
tracked chunks of at most32MiB. large_inputs.py verifies their manifest, exact
bytes and logical modes before reconstructing only three explicitly ignored
project-local aliases. The current gateway is publish_portable.py; tracked
inputs never change during default rederive. All old publication outputs and
before images stay frozen, including the whole third10540/10543/readonly0.
Five actual faults use the retained pre-root-guard helper. A separate read-only
Gitlink metadata probe exposes/rejects the root bypass; final helper cold replay
checks all3 aliases. No submodule implementation is read and nothing is written
there. Actual maintained readers use recovered bytes before exactly3 verified
old backups are removed; residue0. Final physical-input and staged Git size
checks plus exact canonical receipt govern landing. No Git history rewrite,
capacity increase or outside project storage is required.
'''
    c.write_new('admission/portable/final-docs.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},
        result=result,knowledge_bytes=knowledge,producer=c.read(c.PREFIX+'admission/portable/finalize.py'),
        scope='Intended clean portable handoff; current publication/readonly/staged Git-size and '
              'exact canonical receipt remain required before normal commit. Whole earlier sources '
              'and all failed/superseded epochs remain recoverable. No own commit hash invented.'))
    for path,text in after.items():(ROOT/path).write_text(text)
    print('Portable handoff prepared; notes',len(notes.encode()),'bytes;Knowledge',knowledge,'; next9 after canonical landing')


if __name__=='__main__':main()

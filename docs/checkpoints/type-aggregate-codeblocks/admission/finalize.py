"""Close the lossless book admission before final publication and canonical landing."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import review
from admission import verify


def first_record(text,paragraph):
    start=text.index('\n## ')+1
    end=text.find('\n## ',start+1)
    if end<0:end=len(text)
    return text[:end].rstrip()+'\n\n'+paragraph+'\n\n'+text[end:].lstrip('\n')


def main():
    result=review.check(False,doc_stem='admission/doc')
    admission=verify.check()
    assert admission['public_reference_after']==49836
    paths=['CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/TASK_TREE.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    after['CHANGES.md']=first_record(after['CHANGES.md'],
        'Book admission retained the whole first10496-input unpublished claim/publication, actual readonly0 '
        'and10499 Git-verified staged images before correcting public_reference50007/50000. Lossless prose '
        'reflow removes171 lines; corrected49836/50000 passes without budget changes. All code fences and '
        'normalized rendered content matches. The sole generated search-index URL differs after15 whitespace-only '
        'chapter-body changes; both actual89-input rebuilds reproduce the measured pages byte-for-byte. '
        'Fresh book89/three executed examples/heading RED passes. '
        'Current rederive is type-aggregate-codeblocks/publish_final.py; the original publication stays frozen.')
    after['DEVELOPMENT_NOTES.md']=first_record(after['DEVELOPMENT_NOTES.md'],
        'The first full preflight exposed public-reference pressure and was deliberately joined143 before '
        'bound inputs changed. Preserve unpublished source images as packets plus real accepted Git and '
        'immutable hash-gated artifacts; do not invent a draft Git revision. The prose-only correction '
        'has a separate book epoch and actual pressure report; compare complete normalized rendered pages '
        'as well as unchanged examples. A strict page comparator initially rejected the sole generated '
        'search-index URL. Actual rebuilt indexes differ only in15 chapter-body whitespace strings; all '
        'other decoded fields match. Retain that rejection and verify the payload before normalizing its '
        'reference. Original and final publications remain distinct.')
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    start=after[task].index('- ID: `'+c.OWNER+'`\n')
    end=after[task].index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n',start)
    node=after[task][start:end]
    node=node.replace('Status: `in_progress` / public-reference pressure admission',
        'Status: `done` / bounded Perl availability and lossless book admission',1)
    node=node.replace('  - [ ] **NO REGRESSION**','  - [x] **NO REGRESSION**',1)
    node=node.replace('  - [ ] **LOCKSTEP**','  - [x] **LOCKSTEP**',1)
    node=node.replace('Corrected book/proof/canonical landing remain required.',
        'Corrected49836/50000 passes;171 prose lines removed with complete normalized rendered content identity, '
        'unchanged fences and fresh89/3/heading RED. publish_final.py binds the final epoch; exact staged '
        'canonical receipt and normal hooks govern landing.',1)
    after[task]=after[task][:start]+node+after[task][end:]
    after[task]=after[task].replace('  Commit subject: `'+c.OWNER+' - execute deferred array reducers`.',
        '  Render-comparator defect owned/fixed: complete whitespace-normalized HTML first rejected the '
        'generated search-index URL. Retained rejection plus actual89-input old/new rebuilds reproduce '
        'both pages; decoded indexes differ only in15 whitespace-only chapter-body strings. Verify '
        'that payload and every other decoded field before normalizing the one reference.\n'
        '  Commit subject: `'+c.OWNER+' - execute deferred array reducers`.',1)
    after[task]=after[task].replace('| `'+c.OWNER+'` | `in_progress` | Public-reference pressure admission; pipeline9 follows clean landing. |',
        '| `'+c.OWNER+'` | `done` | Bounded availability/book admission; owned pipeline9 next. |',1)
    assert len(after[task].encode())<=65536
    after['docs/TASK_TREE.md']=after['docs/TASK_TREE.md'].replace(
        '`active` / aggregate .1.2.7 pressure admission; .1.2.9 next',
        '`active` / aggregate .1.2.7 done; pipeline .1.2.9 next',1)
    live=after['LIVE_ACHIEVEMENT_STATUS.md']
    live=live.replace(c.OWNER+' behavior proof is verified; public-reference pressure admission remains in progress. Pipeline9 follows its clean canonical commit.',
        c.OWNER+' completes bounded Perl aggregate availability and lossless book admission; deferred sorted/take pipeline9 is next from clean Git.',1)
    live=live.replace('Exact staged canonical receipt is required for landing.',
        'Book pressure49836/50000 passes after171 lossless prose-line reductions; complete normalized '
        'rendered content identity,15 whitespace-only search bodies and fresh89/3 are verified. Whole first10496/images10499/actual readonly0 '
        'remain recoverable. Exact staged canonical receipt is required for landing.',1)
    live=live.replace('run the aggregate readonly publication',
        'run the aggregate publish_final.py readonly publication',1)
    after['LIVE_ACHIEVEMENT_STATUS.md']=live
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — derive current HEAD from Git; normal post-commit requires HEAD^1.
- latest_completed_leaf: `{c.OWNER}` — subject `{c.OWNER} - execute deferred array reducers`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.9` (pending clean activation); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Run aggregate publish_final.py readonly; preserve its complete claim/publication/input manifest/full modes and actual clean baseline before activating the owned deferred sorted/take pipeline9. Continue full PNT after each normal commit.
- in_flight_uncommitted: none; intended clean post-landing handoff. No mutant or verification job belongs to the committed state.
- current_proof:214/212 values/two diagnostics;106 accepted RED/108 controls;7 actual faults/restorations;final14/1948;201+3 permanent/15 malformed;book89/3/heading RED;Knowledge/history650 unchanged. Exact staged canonical receipt governs landing.
- book_admission: Actual50007/50000 RED;171 lossless prose-line reductions;49836/50000 passes. All fences/normalized rendered content match. Sole generated search-index reference differs after15 whitespace-only body changes; actual old/new rebuilds reproduce both measured pages. Initial comparator rejection stays retained. Fresh89/3 passes; no budget raised.
- checkpoint: {c.PREFIX}README.md; publish_final.py is current readonly rederive; claim docs/claims/{c.OWNER}.json.
- custody: Whole accepted drop10334/full modes/clean readonly0 at real efad remains. admission/first.json.gz retains unpublished first10496-input claim/publication/full modes/actual readonly0 and10499 Git-verified staged images. Original publication/manifest stay frozen; no draft Git revision is invented.
- source_epochs: Six aggregate faults retain pre-guard bytes; final guard has actual removal RED/restoration plus final214/direct14 proof. Rejected shadow/oracle/quietness preparations stay explicit. Old failed preflight was deliberately joined143 before correction.
- kind95: Three real selected-string index failures/two scalar controls/B flags remain owned despite numeric JSON. Actual old192-input library/65 loaded owners is byte-verified and restored. Original95 instrument/environment is unretained;95 remains after94 before51 with Boolean-authority audit.
- next_owned:9 -> inventory1 -> book mapping2 -> layout3 -> legacy8 -> metadata QA13 -> references/closeout. Startup20/32/35/87.4 and constructor94 remain owned.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; less than24h. Frozen old cache/source images remain required inputs.
- standing_limit: Other repositories and RGX/PGEN remain read-only black boxes. Project data stays on this volume. Full CI before final clean push; no push yet.
'''
    after[c.PREFIX+'README.md']+='''
Final book admission: public_reference49836/50000 passes after171 prose-line
reductions, with every non-whitespace source character/code fence unchanged and
complete normalized rendered-content identity. The sole generated search-index
URL differs; actual89-input rebuilds reproduce both measured pages and decoded
indexes differ only in15 whitespace-only chapter-body strings. The initial
strict comparator rejection remains retained. Fresh89-input/three-example book
proof and actual displaced-heading RED pass. The original first publication and
manifest remain frozen; current readonly rederive is publish_final.py. Its final
manifest/claim bind the corrected epoch. Exact staged canonical receipt and
normal hooks govern landing; pipeline9 follows only from clean committed Git.
'''
    c.write_new('admission/final-docs.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},
        result=result,admission=admission,producer=c.read(c.PREFIX+'admission/finalize.py'),
        scope='Intended clean post-landing handoff. Final publication and exact staged canonical '
              'receipt/normal hooks remain required; no current commit hash is invented.'))
    for path,text in after.items():(c.ROOT/path).write_text(text)
    print('Final handoff prepared:214/14/1948;book89/3;pressure49836/50000; next9 after canonical landing')


if __name__=='__main__':main()

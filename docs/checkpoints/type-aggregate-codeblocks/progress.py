"""Overwrite the durable in-flight pointer between source-stable verification stages."""
import sys
import common as c


def main():
    assert sys.argv[1:] in (['accepted'],['focused'],['book'],['history'])
    stage=sys.argv[1]
    next_actions={
        'accepted':'Run accepted.py: corrected214 with three real efad execution owners temporarily installed; recovery is accepted-before.json.gz. Join it and verify restoration before any other command.',
        'focused':'Run focused.py for14 dependent suites/scanner/historical audit, then resolve any actual historical inverse RED before canonical admission.',
        'book':'Run doc_proof.py and current known-kind diagnostic; finish proof custody/publication, commit docs and exact canonical candidate.',
        'history':'Resolve the retained historical audit RED with an exact owned aggregate inverse; retain old controls and actual faults before final gates.',
    }
    before=c.read('MEMORY.md')
    after=f'''# MEMORY

- activation_commit: `{c.BASE}` — derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.6` — committed generated drop repair.
- active_work_unit: `{c.OWNER}` (in progress); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: {next_actions[stage]}
- in_flight_uncommitted: Aggregate7 production in Numeric/CodeblockRuntime/MethodLowering;201 permanent cases plus3 updated expectations; book/facts/task95 qualification. Canonical/normal commit pending. No active fault at this pointer write; all six producer faults are restored.
- current_proof: Corrected214 public cases pass212 values/two diagnostics. Original176, rejected214/18 discrepancies, corrected source epochs and six actual faults/fresh restorations survive in {c.PREFIX}.
- recovery: Every temporary source installation has a whole before packet written first; inspect active process/log before recovery. accepted-before.json.gz governs the upcoming accepted-source replay; fault-inputs.json.gz retains final producer bytes.
- known_kind95: JSON numbers can retain internal string kind. Three actual array-write index failures and two scalar controls plus B flags are retained;95 stays after94 before51. Original quoted JSON is historical, with original instrument/environment unretained; no95 fix here.
- known_pipeline9: Deferred sorted/take pipeline fails at sorted;9 is owned next after clean7, before inventory1. Do not pivot dirty.
- custody: Whole drop10334/full modes/actual clean readonly0 at real efad preserved in prior.json.gz before bound writes. Earlier source/cache images remain intact.
- containment: Task root compacted with complete before-image/formal declarations retained; Knowledge source8388576/8388608 after compaction. No budgets raised.
- verification: Host profile for public quiet wrappers/canonical/normal commit; no weakening. Full gate after exact staging; no push until PNT exhausted.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00 in docs/ARTIFACT_CLEANUP.md; less than24h, no cleanup due.
- deferred:7 ->9 -> inventory1 -> book mapping2 -> layout3 -> legacy8 -> metadata QA13 -> references/closeout. Other startup20/32/35/87.4 and constructor94 remain owned.
- standing_limit: Other repositories and RGX/PGEN are read-only black boxes; project data stays on this volume.
'''
    c.write_new('progress-'+stage+'.json.gz',dict(before=before,after_base64=c.encode(after.encode()),
        producer=c.read(c.PREFIX+'progress.py')))
    (c.ROOT/'MEMORY.md').write_text(after)
    if stage=='accepted':
        path='docs/checkpoints/type-drop-generated/README.md';old=c.read(path)
        text=c.decode(old['base64']).decode()
        needle='Historical at accepted'+c.BASE
        assert text.count(needle)==1
        new=text.replace(needle,'Historical at accepted '+c.BASE,1)
        c.write_new('prior-readme-clarity.json.gz',dict(path=path,before=old,after_base64=c.encode(new.encode())))
        (c.ROOT/path).write_text(new)
    print('Durable aggregate pointer:',stage)


if __name__=='__main__':main()

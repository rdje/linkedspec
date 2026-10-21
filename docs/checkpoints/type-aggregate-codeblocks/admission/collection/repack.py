"""Preserve provisional history and repair recursive checkpoint snapshot duplication."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def main():
    old=c.load('admission/collection/pressure-inputs.json.gz')
    context=c.PREFIX+'context.py'
    assert old['overrides'][context]==c.read(context)
    copies={path:packet for path,packet in old['overrides'].items() if path.endswith('.gz')}
    assert copies
    try:assert not copies,'Immutable gzip inputs must not be embedded in future overrides'
    except AssertionError as error:red=dict(rejected=True,message=str(error))
    else:raise AssertionError('Old recursive producer did not distinguish the storage contract')
    for path,packet in copies.items():
        assert c.sha(c.decode(packet['base64']))==packet['sha256']==old['inputs'][path]['sha256']
        assert packet['mode']==old['inputs'][path]['mode']
    notes='DEVELOPMENT_NOTES.md';manifest='docs/history/development-notes/manifest.jsonl'
    archive='docs/history/development-notes/segment-4959-f25e2fcd9f72.md'
    fact='docs/knowledge/terse-type-method-surface-inventory.md'
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    paths=[notes,manifest,archive,context,fact,task,'CHANGES.md','MEMORY.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items() if path!=archive}
    original=c.decode(old['overrides'][notes]['base64']).decode()
    start=original.index('## 2026-10-21 — '+c.OWNER)
    end=original.index('\n## ',start+1)
    header=original[start:original.index('\n',start)]
    summary='''Array reducers keep Perl's legacy all-term decimal/empty/Boolean/selected-term policy, separate from scalar ADR0029. Scalar min/max operands evaluate before kind rejection; zero-argument array receivers terminate. Invalid emitted shapes return complete undef. One preflight skip preserves typed malformed-call errors and caller/record values.

Numeric JSON can hide selected-string kind95: real index writes and B flags distinguish it.95 owns Boolean authority/result normalization. Actual old192-input library replay checks65 loaded owners; rejected shadows and the original unretained95 environment stay explicit. Parse the existing complete receiver-copy diagnostic rather than suppressing it.

Book reflow preserves all fences and normalized rendered content. Verify the sole changed search-index URL against both actual payloads:15 body whitespace changes, all other fields equal. Merge the entire new finding/questions into the existing card to respect1350 files. Canonical1/failed pressure epochs remain retained. Provisional rollover4959 exceeded frozen archive capacity; its full outputs survive while final notes restore the old manifest and compact only this new record.

Checkpoint context previously embedded every earlier changed gzip in later snapshots. Actual retained overrides distinguish that recursion. Future snapshots retain immutable gzip byte/mode identities, whole changed plain sources and real accepted Git recovery; any later gzip change needs an explicit before packet. All existing gzip evidence stays unchanged and hash-gated.

Canonical source epochs, rejected preparations and before packets: docs/checkpoints/type-aggregate-codeblocks/. Current readonly command is publish_admitted.py; exact canonical receipt governs landing. Pipeline9 and kind95 remain owned.
'''
    after[notes]=original[:start]+header+'\n\n'+summary+original[end:]
    assert len(after[notes].encode())<65536*0.9
    raw=subprocess.check_output(['git','show',c.BASE+':'+manifest],cwd=ROOT)
    after[manifest]=raw.decode()
    assert b'"segment_id":"4959"' not in raw
    needle='overrides = {path: c.read(path) for path in changed if path in inputs}'
    assert after[context].count(needle)==1
    after[context]=after[context].replace(needle,
        "overrides = {path: c.read(path) for path in changed if path in inputs and not path.endswith('.gz')}",1)
    after[context]=after[context].replace('Changed tracked draft bytes are retained whole;',
        'Changed plain sources are retained whole; immutable gzip inputs stay byte/mode-hash-gated '
        'without embedding prior snapshots. Any later gzip change requires its own before packet;',1)
    question='  - "why did checkpoint input snapshots grow recursively"\n'
    after[fact]=after[fact].replace('date: 2026-10-21\n',question+'date: 2026-10-21\n',1)
    after[fact]+='\nCheckpoint context once embedded prior gzip inputs recursively. It now keeps their immutable byte/mode identities; old full snapshots remain hash-gated. collection/repack.json.gz retains the actual old duplication RED.\n'
    knowledge=sum(path.stat().st_size for path in (ROOT/'docs/knowledge').glob('*.md'))
    knowledge+=len(after[fact].encode())-len(c.decode(before[fact]['base64']))
    assert knowledge<=8388608,knowledge
    old_line=next(line for line in after[task].splitlines() if line.startswith('  Notes containment:'))
    after[task]=after[task].replace(old_line,
        '  Notes containment: provisional4959 rollover/whole outputs remain retained. Frozen48-file/'
        '47-row archive controls reject it; final compaction restores only its uncommitted manifest/'
        'archive changes and shortens this new leaf record below90%. No committed immutable history '
        'or budget changes. The two failed pressure epochs remain explicit.',1)
    after['CHANGES.md']=after['CHANGES.md'].replace(
        'standard rollover archives81 clean-source lines as4959.',
        'provisional rollover4959 is retained and undone after frozen archive-capacity rejection. '
        'Compact only the new notes record below90%. Checkpoint snapshot overrides now retain '
        'immutable gzip identities without recursively embedding old snapshots; all old evidence stays hash-gated.',1)
    after['MEMORY.md']+='- snapshot_repair: Whole provisional4959 outputs and failed archive-capacity report survive; final notes compact only the new record. context.py stops embedding immutable gzip in future overrides; original duplicate snapshots stay retained. New actual no-gzip-override/pressure proof and exact canonical receipt govern landing.\n'
    after[c.PREFIX+'README.md']+='''
Final containment supersedes the provisional rollover: full4959 generated
outputs survive in collection/repack.json.gz and the failed pressure epoch.
Restore only that uncommitted rollover and compact this new notes record;
committed immutable history and every limit stay unchanged. context.py now
retains immutable gzip inputs by byte/mode identity rather than recursively
embedding earlier snapshots. Existing large snapshots remain unchanged and
hash-gated; changing a gzip later requires an explicit before packet. The real
old duplication RED and fresh no-gzip-override GREEN govern this bounded repair.
'''
    compile(after[context],context,'exec')
    c.write_new('admission/collection/repack.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},removed=archive,
        original_notes=old['overrides'][notes],duplication_red=red,
        duplicated_gzip_inputs=len(copies),duplicated_gzip_bytes=sum(len(c.decode(item['base64'])) for item in copies.values()),
        producer=c.read(c.PREFIX+'admission/collection/repack.py'),
        scope='Retain every provisional generated output and old actual gzip-duplication epoch. '
              'Compact only the new notes record and remove only the uncommitted provisional archive. '
              'Future context captures immutable gzip identities, never overwrites their bytes; '
              'whole plain source packets and accepted Git continue to recover older epochs.'))
    for path,text in after.items():(ROOT/path).write_text(text)
    (ROOT/archive).unlink()
    print('Repacked:',len(copies),'observed old gzip copies; notes',len(after[notes].encode()),
        'bytes; old manifest restored; all provisional outputs retained; Knowledge',knowledge)


if __name__=='__main__':main()

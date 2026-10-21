"""Adopt verified bounded chunks and the whole pre-migration source epoch."""
import gzip
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import large_inputs


def copy_new(source,target):
    assert source.is_file() and not source.is_symlink() and not target.exists()
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(source,target)
    assert c.sha(source.read_bytes())==c.sha(target.read_bytes())
    assert source.stat().st_mode&0o7777==target.stat().st_mode&0o7777


def main():
    folder=ROOT/(c.PREFIX+'admission/portable')
    source=ROOT/'.linkedspec-data/verification/type-aggregate-third-epoch.json.gz'
    copy_new(source,folder/'third.json.gz')
    third=c.load('admission/portable/third.json.gz')
    assert len(third['inputs'])==10540 and len(third['images'])==10543
    preserver=ROOT/'.linkedspec-data/verification/type-aggregate-portable-preserve.py'
    assert c.read(preserver.relative_to(ROOT).as_posix())==third['producer']
    copy_new(preserver,folder/'preserve.py')
    prepared=ROOT/'.linkedspec-data/verification/type-aggregate-portable-chunks'
    report=json.loads(gzip.decompress((prepared/'preparation.json.gz').read_bytes()))
    split=ROOT/'.linkedspec-data/verification/type-aggregate-portable-chunks.py'
    assert c.read(split.relative_to(ROOT).as_posix())==report['producer']
    copy_new(split,folder/'split.py')
    copy_new(prepared/'preparation.json.gz',folder/'preparation.json.gz')
    value=large_inputs.validate_manifest(json.loads((prepared/'manifest.json').read_bytes()))
    assert set(third['oversized'])==large_inputs.LOGICAL_PATHS
    for item in value['objects']:
        assert large_inputs.identity(ROOT/item['path'])=={key:item[key] for key in ('sha256','size','mode')}
        assert third['inputs'][item['path']]=={key:item[key] for key in ('sha256','mode')}
        for part in item['parts']:
            old=prepared/item['sha256']/Path(part['path']).name
            assert c.sha(old.read_bytes())==part['sha256'] and old.stat().st_size==part['size']
            copy_new(old,ROOT/part['path'])
    copy_new(prepared/'manifest.json',folder/'manifest.json')
    terminal={name:c.read('.linkedspec-data/verification/type-aggregate-canonical2.'+name)
        for name in ('log','status')}
    assert c.decode(terminal['status']['base64']).strip()==b'143'
    absence=c.run(['ps','-p','78131,78323,79137,87604,93148,93149','-o','pid=,ppid=,comm='])
    assert absence['returncode']==1 and not c.decode(absence['stdout_base64'])
    paths=['.gitignore','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','docs/tasks/TYPE-REFERENCE-BOOK.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    after['.gitignore']+='\n# Reconstructed exact checkpoint inputs; tracked32MiB chunks are authoritative.\n'
    after['.gitignore']+=''.join('/'+path+'\n' for path in sorted(large_inputs.LOGICAL_PATHS))
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    start=after[task].index('- ID: `'+c.OWNER+'`\n');end=after[task].index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n',start)
    node=after[task][start:end].replace('Status: `done` / bounded Perl availability and lossless book admission',
        'Status: `in_progress` / portable retained-input admission',1)
    node=node.replace('  - [x] **NO REGRESSION**','  - [ ] **NO REGRESSION**',1).replace('  - [x] **LOCKSTEP**','  - [ ] **LOCKSTEP**',1)
    after[task]=after[task][:start]+node+after[task][end:]
    after[task]=after[task].replace('| `'+c.OWNER+'` | `done` | Bounded availability/book admission; owned pipeline9 next. |',
        '| `'+c.OWNER+'` | `in_progress` | Portable retained-input admission; pipeline9 follows clean landing. |',1)
    after['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.6`; aggregate7 is uncommitted.
- active_work_unit: `{c.OWNER}`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Verify adopted37 chunks and fresh exact aliases with missing/byte/order/mode controls. Finish portable publisher/current fact/pointer/handoff, actual readonly run and full exact canonical gate; normal commit before9. No push yet.
- in_flight_uncommitted: Aggregate7 implementation/tests/book/evidence plus portable-input admission. Canonical2 intentionally superseded143 after actual oversized-blob RED; no canonical job remains.
- behavior_proof:214/106 RED/108 controls;7 restored faults;14/1948;201+3 permanent/15 malformed;book89/3. Runtime/tests/book stay unchanged during portability repair.
- pressure: Actual final20 surfaces/62 routes/40 controls pass. Public49836/50000,knowledge1350 files/8388435 bytes; notes58568 below90%. Budgets and committed history unchanged; provisional4959 outputs survive in collection/repack.json.gz.
- custody: Complete original10496/images10499, second10522/images10525 and third10540/images10543 unpublished source epochs/full modes/actual readonly0 survive. Third actual Git blob sizes expose3 above100MiB; no fake draft Git revision.
- portable_inputs: admission/portable/manifest.json and37 tracked32MiB chunks preserve1171950805 exact bytes/full modes. Three original paths become ignored generated aliases; large_inputs.py reconstructs only verified project-local aliases. Adoption/control/publisher proof remains required.
- resume_guard: If HEAD is still efad and dirty, finish7; do not activate9 from an intended post-landing pointer or obsolete publisher. Current admission owner is docs/checkpoints/type-aggregate-codeblocks/admission/portable/.
- known_defects: Internal kind95 and deferred sorted/take9 remain owned; source epochs/shadow rejection/history650 stay exact. No95/full inventory/cross-backend admission.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; less than24h. Frozen inputs remain required; chunks and aliases stay on this volume.
- standing_limit: Other repositories and RGX/PGEN are read-only black boxes. Full PNT continues after clean landing; no push yet.
'''
    after['LIVE_ACHIEVEMENT_STATUS.md']=after['LIVE_ACHIEVEMENT_STATUS.md'].replace(
        c.OWNER+' completes bounded Perl aggregate availability and lossless book admission; deferred sorted/take pipeline9 is next from clean Git.',
        c.OWNER+' behavior/book/pressure proof passes; portable retained-input admission remains in progress. Deferred sorted/take9 follows the clean canonical commit.',1)
    c.write_new('admission/portable/adoption.json.gz',dict(before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},manifest=value,
        terminal=terminal,absence=absence,producer=c.read(c.PREFIX+'admission/portable/adopt.py'),
        scope='Whole third draft and exact bounded chunks adopted before source-format migration. '
              'Canonical2 deliberately superseded143 after real blob-limit diagnosis; no success '
              'or test failure claimed. Original logical files remain present until verified recovery.'))
    for path,text in after.items():(ROOT/path).write_text(text)
    print('Portable chunks/whole third source epoch adopted; raw aliases preserved; admission reopened7')


if __name__=='__main__':main()

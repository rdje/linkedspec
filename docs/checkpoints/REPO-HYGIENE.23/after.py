"""One-shot dated aftermath; no replay of the cleanup writers."""
import datetime
import json
import os
from pathlib import Path
import common as c
import history_archive as h
import inventory


def main():
    supplied=c.snapshot()
    c.save('after-inputs.json.gz',supplied)
    work=c.ROOT/h.WORK
    archive=c.load('history-archive.json.gz')
    duplicates=[]
    for kind,name in [('payload','history-payload.zip'),('manifest','history-entries.jsonl.gz')]:
        path=work/name
        assert path.is_file() and not path.is_symlink()
        assert path.stat().st_dev==c.ROOT.stat().st_dev
        assert h.file_hash(path)==archive[kind]['sha256']
        assert path.stat().st_size==archive[kind]['bytes']
        for part in archive[kind]['parts']:
            assert c.identity(part['path'])=={key:part[key] for key in ('sha256','mode')}
        duplicates.append(dict(path=path.relative_to(c.ROOT).as_posix(),
            bytes=path.stat().st_size,allocated_bytes=path.stat().st_blocks*512,
            sha256=h.file_hash(path)))
    leases={name:json.loads((work/(name+'-lease.json')).read_text()) for name in ('rust','history')}
    assert all(row['closed'] for row in leases.values())
    assert not os.path.lexists(c.ROOT/h.SOURCE)
    assert not os.path.lexists(work/'old-rust-target')
    assert c.load('history-archive-use.json.gz')['public_outputs_byte_identical']
    c.save('duplicate-disposal-plan.json.gz',dict(files=duplicates,leases=leases,
        retained_parts_verified=True,prior_full_archive_and_actual_consumer_use=True))
    for row in duplicates:(c.ROOT/row['path']).unlink()
    logs={name:c.read('.linkedspec-data/verification/'+name) for name in (
        'hygiene23-inventory.log','hygiene23-rust-cleanup.log','hygiene23-history-archive.log')}
    c.save('completed-jobs.json.gz',dict(logs=logs,leases=leases,
        observed_tool_exits={'inventory_session14630':0,'rust_session83653':0,'history_session22406':0},
        channels='These three shell redirects combined stdout/stderr. Exit0 was observed by the orchestrator when joining each actual session; separate stderr channels are not inferred.',
        duplicate_files_removed=duplicates))
    at=datetime.datetime.now(datetime.timezone.utc).isoformat()
    observation=inventory.scan(c.ROOT,c.ROOT,inventory.gitlinks())
    c.save('inventory-after.json.gz',dict(at_utc=at,observation=observation,
        inputs_unchanged=c.unchanged(supplied['inputs']),
        scope='Same static exclusions as inventory-before: root Git, protected repositories, proof prefix and verification/hygiene23. Other managed-run metadata remains included, including this observer wrapper. Non-atomic dated allocated metadata; no per-file global custody or whole-repository total is claimed.'))
    assert c.unchanged(supplied['inputs'])
    retained=sum(c.source(row['path']).stat().st_blocks*512 for kind in ('payload','manifest') for row in archive[kind]['parts'])
    c.save('after-targets.json.gz',dict(history_source_absent=True,rust_quarantine_absent=True,
        duplicate_originals_absent=all(not os.path.lexists(c.ROOT/row['path']) for row in duplicates),
        retained_history_parts_allocated_bytes=retained,
        rust=c.run(['du','-skx','rust/target']),volume=c.run(['df','-k','.']),
        leases=leases,inputs_unchanged=True))
    print('After census retained:',json.dumps(observation['total']),flush=True)


if __name__=='__main__':main()

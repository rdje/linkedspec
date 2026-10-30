"""Exercise the actual bounded cleanup guards on disposable local fixtures."""
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import runpy
import tempfile
import time

spec = importlib.util.spec_from_file_location('cleanup46', Path(__file__).with_name('cleanup.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
initial = runpy.run_path(str(m.WORK / 'initial-cleanup.py'))
observed = []


def rejects(label, call):
    try:
        call()
    except AssertionError as error:
        observed.append(dict(label=label, rejected=True, reason=str(error)))
    else:
        raise AssertionError('control admitted: ' + label)


with tempfile.TemporaryDirectory(prefix='cleanup46-controls-') as folder:
    m.ROOT = Path(folder)
    m.SOURCE = 'old/debug/deps'
    m.QUARANTINE = m.SOURCE + '-quarantine'
    m.WORK = m.ROOT / 'evidence'
    m.WORK.mkdir()
    source = m.ROOT / m.SOURCE
    source.mkdir(parents=True)
    for name in ('old.rcgu.o', 'keep.d', 'executable.rcgu.o', 'recent.rcgu.o', 'linked.rcgu.o'):
        (source / name).write_bytes(b'fixture data\n')
        os.utime(source / name, (m.CUTOFF / 10**9 - 100, m.CUTOFF / 10**9 - 100))
    (source / 'executable.rcgu.o').chmod(0o755)
    os.utime(source / 'recent.rcgu.o', (time.time(), time.time()))
    os.link(source / 'linked.rcgu.o', source / 'linked-copy.rcgu.o')
    (source / 'symbolic.rcgu.o').symlink_to('keep.d')
    rows = [[path.name, m.selected(path.name, path.lstat()), m.identity(path.lstat())]
            for path in source.iterdir()]
    chosen = [row[0] for row in rows if row[1]]
    assert chosen == ['old.rcgu.o']
    assert 'executable.rcgu.o'.endswith('.rcgu.o')  # filename-only competing policy admits it
    assert not m.selected('executable.rcgu.o', (source / 'executable.rcgu.o').lstat())
    original = b''.join((json.dumps(row) + '\n').encode() for row in rows)

    def manifest(raw, *, extra=0):
        packed = gzip.compress(raw, mtime=0)
        (m.WORK / 'entries.jsonl.gz').write_bytes(packed)
        value = dict(manifest_sha256=hashlib.sha256(packed).hexdigest(),
                     totals=dict(selected_files=1 + extra, retained_entries=len(rows) - 1),
                     source_identity=m.identity(source.stat()), limits='synthetic guard fixture only')
        (m.WORK / 'plan.json').write_text(json.dumps(value))

    manifest(original)
    m.require_base = lambda: None  # Fixture Git identity is deliberately outside the production precondition.
    m.claim_hits = lambda paths: []  # Separate real current-namespace preflight supplies this leg.
    m.save('liveness.json', dict(at_utc=m.datetime.datetime.now(m.datetime.timezone.utc).isoformat()))
    m.quarantine()
    m.save('current-build.json', dict(exit=0, source_absent=True, quarantine_present=True))
    m.dispose()
    m.review()
    observed.append(dict(label='actual bounded quarantine/dispose/review', accepted=True,
                         selected_absent=True, all_other_entries_exact=True))
    altered = [list(row) for row in rows]
    index = next(i for i, row in enumerate(altered) if row[0] == 'keep.d')
    altered[index] = [altered[index][0], False, list(altered[index][2])]
    altered[index][2][3] += 1
    manifest(b''.join((json.dumps(row) + '\n').encode() for row in altered))
    rejects('retained size mismatch', m.review)
    manifest(original, extra=1)
    rejects('wrong removed-object total', m.review)
    altered = [list(row) for row in rows]
    altered[index][1] = True
    manifest(b''.join((json.dumps(row) + '\n').encode() for row in altered))
    rejects('retained entry falsely classified removed', m.review)
    (m.ROOT / 'alias').symlink_to(source, target_is_directory=True)
    rejects('symbolic ancestor', lambda: m.boundary('alias'))
    protected = m.ROOT / 'protected'
    protected.mkdir()
    (protected / '.git').write_text('synthetic boundary marker; not a Git repository\n')
    rejects('nested repository marker', lambda: m.boundary('protected'))
    outside = m.ROOT.parent / 'outside'
    outside.mkdir()
    try:
        initial['boundary'].__globals__['ROOT'] = m.ROOT
        assert initial['boundary']('../outside').is_dir()
        rejects('outside root; initial guard admitted existing sibling', lambda: m.boundary('../outside'))
    finally:
        outside.rmdir()
    assert len(observed) == 7

print(json.dumps(dict(controls=observed, selected_policy=dict(old_regular=True, executable=False,
                 symlink=False, hardlinked=False, recent=False, other_suffix=False),
                 limits='Synthetic guard controls, not actual backend execution or filesystem adversary proof.'), sort_keys=True))

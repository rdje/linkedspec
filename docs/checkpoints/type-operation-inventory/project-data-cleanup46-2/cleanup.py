"""One-shot disposal of obsolete, unlinked Cargo object files; review is read-only.

Never traverse a child directory or follow a symlink. The exact old target is
owned by LinkedSpec; its adjacent retained RGX repository is outside this scope.
Original object bytes are disposable compiler output, not retained evidence.
"""
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.3.46.2'
BASE = '3332cf3be'
WORK = ROOT / '.linkedspec-data/verification/project-data-cleanup46-2'
SOURCE = '.linkedspec-data/scratch/ls004-adoption26/pre-adoption-rust-target/debug/deps'
QUARANTINE = SOURCE + '-cleanup46-2-quarantine'
PREFIX = Path(__file__).parent
CUTOFF = datetime.datetime(2026, 9, 27, tzinfo=datetime.timezone.utc).timestamp() * 10**9


def save(name, value):
    with (WORK / name).open('x') as stream:
        json.dump(value, stream, sort_keys=True, indent=2)
        stream.write('\n')


def load(name):
    return json.loads((WORK / name).read_text())


def identity(info):
    return [info.st_mode, info.st_dev, info.st_ino, info.st_size,
            info.st_mtime_ns, info.st_ctime_ns, info.st_blocks, info.st_nlink]


def boundary(name):
    relative = Path(name)
    assert not relative.is_absolute() and '..' not in relative.parts and relative.as_posix() == name, 'non-canonical relative path'
    path = ROOT / name
    assert path.is_relative_to(ROOT) and path != ROOT
    for parent in (path, *path.parents):
        if not parent.is_relative_to(ROOT):
            continue
        assert not parent.is_symlink(), 'symbolic ancestor'
        if parent != ROOT:
            assert not os.path.lexists(parent / '.git'), 'nested repository ancestor'
    info = path.lstat()
    assert stat.S_ISDIR(info.st_mode) and info.st_dev == ROOT.stat().st_dev
    return path


def selected(name, info):
    return (name.endswith('.rcgu.o') and stat.S_ISREG(info.st_mode)
            and not info.st_mode & 0o111 and info.st_nlink == 1
            and info.st_dev == ROOT.stat().st_dev and info.st_mtime_ns < CUTOFF)


def claim_hits(paths):
    hits = []
    for name in subprocess.check_output(['git', 'ls-files', 'docs/claims/*.json'], cwd=ROOT, text=True).splitlines():
        record = json.loads((ROOT / name).read_text())
        for claim in record['claims']:
            leg = claim['durability']
            if leg.get('mode') != 'live':
                continue
            for item in leg.get('inputs', []):
                if any(item['path'] == path or item['path'].startswith(path + '/') for path in paths):
                    hits.append([name, claim['name'], item['path']])
    return hits


def require_base():
    assert subprocess.check_output(['git', 'rev-parse', '--short=9', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
    assert '- active_work_unit: `' + OWNER + '`;' in (ROOT / 'MEMORY.md').read_text()


def plan():
    require_base()
    WORK.mkdir(exist_ok=False)
    source = boundary(SOURCE)
    assert not os.path.lexists(ROOT / QUARANTINE)
    hits = claim_hits([SOURCE, QUARANTINE])
    assert not hits, hits
    before = identity(source.stat())
    totals = dict(selected_files=0, selected_logical_bytes=0, selected_allocated_bytes=0,
                  retained_entries=0)
    manifest = WORK / 'entries.jsonl.gz'
    with gzip.GzipFile(filename=str(manifest), mode='xb', compresslevel=1, mtime=0) as output:
        with os.scandir(source) as entries:
            for entry in entries:
                info = entry.stat(follow_symlinks=False)
                choose = selected(entry.name, info)
                output.write((json.dumps([entry.name, choose, identity(info)], separators=(',', ':')) + '\n').encode())
                if choose:
                    totals['selected_files'] += 1
                    totals['selected_logical_bytes'] += info.st_size
                    totals['selected_allocated_bytes'] += info.st_blocks * 512
                else:
                    totals['retained_entries'] += 1
    assert identity(source.stat()) == before, 'directory changed during plan'
    assert totals['selected_files'] > 0
    save('plan.json', dict(owner=OWNER, base=BASE, source=SOURCE, quarantine=QUARANTINE,
                          source_identity=before, totals=totals, live_claim_intersections=hits,
                          manifest_sha256=hashlib.file_digest(manifest.open('rb'), 'sha256').hexdigest(),
                          limits='Direct entries only; regular non-executable single-link old .rcgu.o files. '
                          'No object byte retention or exact old-build reproduction claim. Sources, '
                          'executables, all other entries, incremental cache and nested repositories remain. '
                          'Allocated metadata is not physical volume space reclaimed.'))
    print(json.dumps(totals), flush=True)


def liveness():
    require_base()
    result = subprocess.run(['lsof', '-nP', '-u', str(os.getuid()), '-F', 'pfn'], capture_output=True)
    assert result.returncode == 0 and not result.stderr, 'process inspection unavailable or incomplete'
    hits = []
    pid = None
    prefix = str(ROOT / SOURCE)
    for line in result.stdout.decode().splitlines():
        if line.startswith('p'):
            pid = line[1:]
        if line.startswith('n') and (line[1:] == prefix or line[1:].startswith(prefix + '/')
                                     or line[1:] == str(ROOT / QUARANTINE)
                                     or line[1:].startswith(str(ROOT / QUARANTINE) + '/')):
            hits.append(dict(pid=pid, path=line[1:]))
    assert not hits, hits
    save('liveness.json', dict(command=['lsof', '-nP', '-u', '<current-uid>', '-F', 'pfn'],
                              exit=0, stderr='', candidate_hits=hits,
                              at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                              raw_output_sha256=hashlib.sha256(result.stdout).hexdigest(),
                              limits='Successful same-user open-file/cwd inspection at this boundary; '
                              'not a concurrent adversarial filesystem or other-user process guarantee.'))
    print('Candidate has no same-user open file or cwd; inspection succeeded.', flush=True)


def quarantine():
    require_base()
    plan = load('plan.json')
    live = load('liveness.json')
    assert (datetime.datetime.now(datetime.timezone.utc) - datetime.datetime.fromisoformat(live['at_utc'])).total_seconds() < 120
    source = boundary(SOURCE)
    assert identity(source.stat()) == plan['source_identity']
    assert not os.path.lexists(ROOT / QUARANTINE)
    assert not claim_hits([SOURCE, QUARANTINE])
    source.rename(ROOT / QUARANTINE)
    save('quarantine.json', dict(source_absent=not os.path.lexists(source), identity=identity((ROOT / QUARANTINE).stat())))
    print('Exact obsolete deps directory quarantined; current rust/target untouched.', flush=True)


def rows():
    with gzip.open(WORK / 'entries.jsonl.gz', 'rt') as stream:
        for line in stream:
            yield json.loads(line)


def dispose():
    require_base()
    plan = load('plan.json')
    assert hashlib.file_digest((WORK / 'entries.jsonl.gz').open('rb'), 'sha256').hexdigest() == plan['manifest_sha256']
    test = load('current-build.json')
    assert test['exit'] == 0 and test['source_absent'] and test['quarantine_present']
    target = boundary(QUARANTINE)
    start = WORK / 'disposal-started.json'
    if not start.exists():
        assert identity(target.stat()) == load('quarantine.json')['identity']
        save('disposal-started.json', dict(manifest_sha256=plan['manifest_sha256'],
                                         target_identity=identity(target.stat())))
    else:
        started = load('disposal-started.json')
        assert started['manifest_sha256'] == plan['manifest_sha256']
        assert identity(target.stat())[:3] == started['target_identity'][:3]
    deleted = 0
    for name, choose, saved in rows():
        assert '/' not in name and name not in ('.', '..')
        path = target / name
        if choose and not os.path.lexists(path):
            deleted += 1
            continue  # Resume only an already-started exact quarantined plan.
        info = path.lstat()
        assert identity(info) == saved, 'entry changed after plan: ' + name
        if choose:
            assert selected(name, info)
            path.unlink()
            deleted += 1
            if deleted % 250000 == 0:
                print('deleted_objects', deleted, flush=True)
    assert deleted == plan['totals']['selected_files']
    assert not os.path.lexists(ROOT / SOURCE)
    target.rename(ROOT / SOURCE)
    save('disposal.json', dict(deleted_objects=deleted, source_restored=True,
                              quarantine_absent=not os.path.lexists(ROOT / QUARANTINE),
                              completed_utc=datetime.datetime.now(datetime.timezone.utc).isoformat()))
    print('Only exact planned disposable objects removed; retained deps directory restored.', flush=True)


def review():
    source = boundary(SOURCE)
    plan = load('plan.json')
    assert hashlib.file_digest((WORK / 'entries.jsonl.gz').open('rb'), 'sha256').hexdigest() == plan['manifest_sha256']
    assert not os.path.lexists(ROOT / QUARANTINE)
    removed = retained = 0
    for name, choose, saved in rows():
        path = source / name
        if choose:
            assert not os.path.lexists(path), 'planned object remains'
            removed += 1
        else:
            assert identity(path.lstat()) == saved, 'retained entry changed'
            retained += 1
    assert removed == plan['totals']['selected_files'] and retained == plan['totals']['retained_entries']
    with os.scandir(source) as entries:
        assert sum(1 for _ in entries) == retained, 'unexpected residue'
    print(json.dumps(dict(planned_objects_absent=removed, retained_entries_exact=retained,
                          quarantine_absent=True, limits=plan['limits'])), flush=True)


if __name__ == '__main__':
    assert len(sys.argv) == 2
    {'plan': plan, 'liveness': liveness, 'quarantine': quarantine,
     'dispose': dispose, 'review': review}[sys.argv[1]]()

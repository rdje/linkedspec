"""Bound this new task summary, preserving the rejected candidate and all contracts."""
import argparse
import fnmatch
import gzip
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
DIRECTORY = BASE / 'pressure'
OWNER = json.loads((BASE / 'plan.json').read_bytes())['owner']
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.4.35'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
FILES = [PART, 'docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/TASK_TREE.md']
PENDING = ('- ID: `' + NEXT + '`\n  Status: `pending`\n  Goal: Renew task-evidence headroom.\n'
    '  Acceptance: Preserve CORE/unselected/frontier bytes via existing epoch; unchanged limits/tools.\n\n')


def sha(body):
    return hashlib.sha256(body).hexdigest()


def nodes(body):
    text = body.decode()
    hits = list(re.finditer(r'(?m)^- ID: `([^`]+)`\n', text))
    assert hits and len({hit[1] for hit in hits}) == len(hits)
    return text[:hits[0].start()], {hit[1]: text[hit.start():hits[index+1].start() if index+1<len(hits) else len(text)]
        for index, hit in enumerate(hits)}


def registry():
    rows = [json.loads(line) for line in Path('doctrine/readme_stability/routes.jsonl').read_text().splitlines() if line.strip()]
    return next(row for row in rows if row.get('id') == 'task_evidence')


def census():
    row = registry()
    paths = sorted({str(path) for pattern in row['members'] for path in Path('.').glob(pattern)})
    result = {}
    for name in paths:
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        body = path.read_bytes()
        result[name] = dict(bytes=len(body), sha256=sha(body), mode=stat.S_IMODE(path.stat().st_mode))
    return result


def images(label):
    result = {}
    for index, name in enumerate(FILES):
        path = Path(name)
        body = path.read_bytes()
        archive = label + '-' + str(index) + '.gz'
        (DIRECTORY / archive).write_bytes(gzip.compress(body, mtime=0))
        result[name] = dict(archive=archive, bytes=len(body), sha256=sha(body), mode=stat.S_IMODE(path.stat().st_mode))
    return result


def repair():
    DIRECTORY.mkdir()
    script = Path(__file__).read_bytes()
    (DIRECTORY / 'producer.py.gz').write_bytes(gzip.compress(script, mtime=0))
    before = images('before')
    for name in FILES:
        assert subprocess.check_output(['git', 'show', ':' + name]) == Path(name).read_bytes(), 'actual rejected index image'
    failed = Path('.linkedspec-data/rust-loader-commit.log').read_bytes()
    assert b'aggregate bytes 12584665/12582912' in failed
    (DIRECTORY / 'rejected-hook.log.gz').write_bytes(gzip.compress(failed, mtime=0))
    original_members = census()
    assert sum(row['bytes'] for row in original_members.values()) == 12584665, 'actual registered population'
    limits = registry()['limits']
    path = Path(PART)
    preamble, old = nodes(path.read_bytes())
    assert NEXT not in old
    node = old[OWNER]
    prefix = node[:node.index('  Reader defect (owned/fixed):')]
    prefix = re.sub(r'(?m)^  Focused checks:.*$',
        '  Focused checks: Source/body/mode/roles/history/victims; book/memory/scope/hooks/routing.', prefix)
    prefix = re.sub(r'(?m)^  Canonical trigger:.*$', '  Canonical trigger: Registration4.1.2/push30.2.', prefix)
    compact = prefix.rstrip('\n') + '\n  Outcome: PASS; counts, repairs and limits in Evidence.\n\n'
    text = path.read_text().replace(node, compact, 1)
    marker = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1.2`\n'
    assert text.count(marker) == 1
    path.write_text(text.replace(marker, PENDING + marker, 1))
    path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
    text, count = re.subn(r'(?m)^\| 1 \|.*$',
        '| 1 | `' + NEXT + '` | `pending` | Renew task headroom via the existing epoch before generated Rust2. |', path.read_text())
    assert count == 1
    path.write_text(text)
    path = Path('docs/TASK_TREE.md')
    text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Renew task-evidence headroom35 before generated Rust2, remaining Perl/transitive3 and generated Dart/frozen-input work; all registration/publication prerequisites remain.', path.read_text(), count=1)
    path.write_text(text)
    action = 'Renew task-evidence headroom under ' + NEXT + ' using the existing epoch before generated Rust2/remaining Perl-transitive3/generated Dart2/frozen-input3; retain every registration/publication prerequisite.'
    path = Path('MEMORY.md')
    text = re.sub(r'(?m)^- next_action:.*$', '- next_action: ' + action, path.read_text())
    path.write_text(text)
    path = Path('LIVE_ACHIEVEMENT_STATUS.md')
    text, count = re.subn(r'(## Next Action\n\n).*?(?=\n## )', lambda hit: hit[1] + action + '\n', path.read_text(), count=1, flags=re.S)
    assert count == 1
    path.write_text(text)
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        path = Path(name)
        text = path.read_text().replace('Generated Rust2/remaining Perl-transitive3 and generated Dart2/frozen-input3 precede',
            'Task headroom35 precedes generated Rust2/remaining Perl-transitive3 and generated Dart2/frozen-input3 before', 1)
        path.write_text(text)
    argv = ['perl', 'tools/update_task_tree_index.pl', '--tree', 'TYPE-REFERENCE-BOOK']
    (DIRECTORY / 'index-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    output = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (DIRECTORY / ('index-' + channel + '.gz')).write_bytes(gzip.compress(getattr(output, channel), mtime=0))
    (DIRECTORY / 'index-exit.txt').write_text(str(output.returncode) + '\n')
    assert output.returncode == 0 and not output.stderr
    after = images('after')
    current_members = census()
    assert set(original_members) == set(current_members)
    total = sum(row['bytes'] for row in current_members.values())
    assert total <= limits['max_total_bytes'], 'bounded summary must fit unchanged quota'
    record = dict(owner=OWNER, next_owner=NEXT, before=before, after=after,
        members_before=original_members, members_after=current_members, limits=limits,
        before_total=12584665, after_total=total, producer_sha256=sha(script), pending_node=PENDING)
    (DIRECTORY / 'record.json').write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')


def review(current):
    record = json.loads((DIRECTORY / 'record.json').read_bytes())
    assert gzip.decompress((DIRECTORY / 'producer.py.gz').read_bytes()) == Path(__file__).read_bytes()
    recovered = {}
    for label in ('before', 'after'):
        recovered[label] = {}
        for name, row in record[label].items():
            body = gzip.decompress((DIRECTORY / row['archive']).read_bytes())
            assert len(body) == row['bytes'] and sha(body) == row['sha256']
            recovered[label][name] = body
            if current and label == 'after':
                assert Path(name).read_bytes() == body and stat.S_IMODE(Path(name).stat().st_mode) == row['mode']
    old_prefix, old = nodes(recovered['before'][PART])
    new_prefix, new = nodes(recovered['after'][PART])
    assert old_prefix == new_prefix and set(new) == set(old) | {NEXT}
    assert new[NEXT] == PENDING
    for name, body in old.items():
        if name != OWNER:
            assert new[name] == body, 'all unselected bodies/frontier remain exact'
    for key in ('Goal', 'Acceptance', 'Verification tier', 'Claim verification', 'Evidence'):
        pattern = r'(?m)^  ' + key + r':.*$'
        assert re.findall(pattern, old[OWNER]) == re.findall(pattern, new[OWNER]), 'contract/pointer preservation'
    assert record['before_total'] > record['limits']['max_total_bytes'] >= record['after_total']
    assert sum(row['bytes'] for row in record['members_before'].values()) == record['before_total']
    assert sum(row['bytes'] for row in record['members_after'].values()) == record['after_total']
    assert set(record['members_before']) == set(record['members_after'])
    if current:
        assert registry()['limits'] == record['limits'] and census() == record['members_after']
    print(json.dumps(dict(result='PASS', before_bytes=record['before_total'], after_bytes=record['after_total'],
        limit=record['limits']['max_total_bytes'], headroom_bytes=record['limits']['max_total_bytes']-record['after_total'],
        scope='Only the new summary is shortened; original candidate images and all unselected bodies/contracts persist. No cap/tool/runtime change.'), sort_keys=True))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--review', action='store_true')
    parser.add_argument('--current', action='store_true')
    arguments = parser.parse_args()
    if not arguments.review:
        repair()
    review(arguments.current)

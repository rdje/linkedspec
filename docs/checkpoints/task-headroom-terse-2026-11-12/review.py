"""Readonly finite preservation oracle, independent of migrator/parser imports."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/task-headroom-terse-2026-11-12')
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.32'
TREE = 'SPEC-FORMAT-TERSE'
SOURCE = 'docs/tasks/' + TREE + '.md'
ACTIVATION = '9f11029e5af9d6168925f532d4c1911637421af3'
MANIFEST = 'docs/history/task-narrative-epochs/' + OWNER + '.json'
CORE = ('Status', 'Goal', 'Acceptance', 'Dependencies', 'Children', 'Parent',
    'Verification tier', 'Focused checks', 'Canonical trigger', 'Claim verification',
    'Commit', 'Commit subject', 'Planned verification tier', 'Planned focused checks',
    'Planned canonical trigger', 'Planned claim verification', 'Superseded by')


def digest(body):
    return hashlib.sha256(body).hexdigest()


def recover(stem):
    rows = json.loads((ROOT / BASE / (stem + '-identities.json')).read_bytes())
    result = {}
    with tarfile.open(ROOT / BASE / (stem + '.tar.gz')) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in result
            body = archive.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and digest(body) == row['sha256']
            assert member.mode & 0o777 == row['mode']
            result[member.name] = body
    assert result.keys() == rows.keys()
    return result, rows


def split_document(body):
    assert body.count(b'\n## Current Frontier\n') == 1
    head, tail = body.split(b'## Current Frontier\n')
    lines = head.splitlines(keepends=True)
    prefix, records, key = bytearray(), {}, None
    for line in lines:
        if line.startswith(b'- ID: `'):
            assert line.endswith(b'`\n')
            key = line[len(b'- ID: `'):-2].decode()
            assert key not in records
            records[key] = bytearray()
        (prefix if key is None else records[key]).extend(line)
    return bytes(prefix), {name: bytes(value) for name, value in records.items()}, tail


def core_fields(body):
    lines = body.splitlines(keepends=True)
    found = {}
    for number, line in enumerate(lines):
        for label in CORE:
            if line.startswith(('  ' + label + ':').encode()):
                assert label not in found
                value = bytearray(line)
                for continuation in lines[number + 1:]:
                    if continuation.startswith(b'    ') or continuation.startswith(b'\t'):
                        value.extend(continuation)
                    else:
                        break
                found[label] = bytes(value)
    return found


def validate(before, after, row):
    assert row['version'] == 1 and row['epoch'] == OWNER and row['tree'] == TREE
    assert row['source_path'] == SOURCE and row['source_commit'] == ACTIVATION
    assert row['sha256'] == digest(before) and row['bytes'] == len(before)
    assert row['lines'] == before.count(b'\n')
    selected = row['selected']
    assert isinstance(selected, list) and selected and selected == sorted(set(selected))
    prefix, old, tail = split_document(before)
    new_prefix, now, new_tail = split_document(after)
    assert new_prefix == prefix and new_tail == tail
    assert list(old) == list(now) and set(selected) <= old.keys()
    for key in old:
        assert core_fields(old[key]) == core_fields(now[key])
        if key in selected:
            assert core_fields(old[key])['Status'].split(b'`')[1] in (b'done', b'completed', b'closed', b'superseded')
            pointer = ('  Narrative epoch: `' + OWNER + '`; exact accepted source via '
                '`bash tools/run_python_project_data.sh tools/read_task_narrative.py '
                '--tree ' + TREE + ' --epoch ' + OWNER + ' --id ' + key + '`.\n\n').encode()
            assert now[key].count(pointer) == 1 and len(now[key]) < len(old[key])
            allowed = len(now[key].splitlines(keepends=True)[0]) + sum(map(len, core_fields(now[key]).values())) + len(pointer)
            assert len(now[key]) == allowed
        else:
            assert now[key] == old[key]
    assert len(after) < len(before)
    return old, now, tail


def command(name, expected_argv):
    folder = ROOT / BASE / 'commands' / name
    assert json.loads((folder / 'command.json').read_bytes()) == dict(argv=expected_argv, cwd='.')
    assert (folder / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
    return gzip.decompress((folder / 'stdout.log.gz').read_bytes())


def equal(a, b):
    assert a == b


def main():
    for name, row in json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes()).items():
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts
        body = (ROOT / name).read_bytes()
        assert len(body) == row['bytes'] and digest(body) == row['sha256']
        if name.endswith('.gz'):
            gzip.decompress(body)
    inputs, in_rows = recover('inputs-before-migration')
    outputs, out_rows = recover('outputs-before-reader')
    before, after = inputs[SOURCE], outputs[SOURCE]
    row = json.loads(outputs[MANIFEST])
    old, now, tail = validate(before, after, row)
    assert in_rows[SOURCE]['mode'] == out_rows[SOURCE]['mode']
    assert before == subprocess.check_output(['git', 'show', ACTIVATION + ':' + SOURCE], cwd=ROOT)
    assert row['source_blob'] == subprocess.check_output(['git', 'rev-parse', ACTIVATION + ':' + SOURCE], cwd=ROOT, text=True).strip()
    for name in ('tools/migrate_task_narrative.py', 'tools/task_narrative.py', 'tools/read_task_narrative.py'):
        assert inputs[name] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
    for source in json.loads(inputs[str(BASE / 'git-input-identities.json')]):
        manifest = json.loads(inputs[source['manifest']])
        body = gzip.decompress(inputs[source['retained_body']])
        assert digest(body) == source['sha256'] == manifest['sha256']
        assert len(body) == source['bytes'] == manifest['bytes']
        assert source['source_blob'] == manifest['source_blob']
        assert body == subprocess.check_output(['git', 'cat-file', 'blob', source['source_blob']], cwd=ROOT)
    migration = command('migration', ['bash', 'tools/run_python_project_data.sh', 'tools/migrate_task_narrative.py',
        '--apply', '--epoch', OWNER, '--tree', TREE, '--source-commit', ACTIVATION])
    expected = (TREE + ' retained ' + str(len(old)) + ' IDs; ' + str(len(row['selected'])) +
        ' closed narratives; ' + str(len(before) - len(after)) + ' bytes renewed; source ' + ACTIVATION + '\n').encode()
    assert migration == expected
    prefix = ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py', '--tree', TREE, '--epoch', OWNER]
    assert command('reader-all', prefix + ['--all']) == before
    for key, body in old.items():
        assert command('reader-' + key, prefix + ['--id', key]) == body
    # Exact activation Git is the finite source oracle; derive this new epoch's counts.
    assert (ROOT / BASE / 'complete.txt').read_text() == 'Actual migration and every declared public query complete; inputs/outputs unchanged.\n'
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, KeyError):
            controls.append(name)
        else:
            raise AssertionError('ineffective preservation control: ' + name)

    selected = row['selected'][0]
    goal = core_fields(now[selected])['Goal']
    reject('current contract lost', lambda: validate(before, after.replace(goal, b'', 1), row))
    status = core_fields(now[selected])['Status']
    reject('closed status changed', lambda: validate(before, after.replace(status, b'  Status: `active`\n', 1), row))
    reject('stable ID omitted', lambda: validate(before, after.replace(('- ID: `' + selected + '`\n').encode(), b'', 1), row))
    reject('metadata prefix altered', lambda: validate(before, b'X' + after[1:], row))
    reject('full current tail truncated', lambda: validate(before, after[:-1], row))
    reject('wrong epoch pointer', lambda: validate(before, after.replace(('Narrative epoch: `' + OWNER + '`').encode(), b'Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.23.4.20`', 1), row))
    wrong = copy.deepcopy(row); wrong['selected'].remove(selected)
    reject('undeclared extracted member', lambda: validate(before, after, wrong))
    unselected = [key for key in old if key not in row['selected']]
    if unselected:
        key = unselected[0]
        reject('unselected body changed', lambda: validate(before, after.replace(now[key], now[key] + b'changed\n', 1), row))
    else:
        reject('undeclared closed commentary inserted', lambda: validate(before, after.replace(now[selected], now[selected] + b'changed\n', 1), row))
    reject('source identity changed', lambda: validate(before + b'\n', after, row))
    reject('actual public source output drift', lambda: equal(command('reader-all', prefix + ['--all']) + b'\n', before))
    return dict(preservation='PASS', stable_ids=len(old), selected_closed=len(row['selected']),
        unchanged_short_bodies=len(old) - len(row['selected']), original_bytes=len(before),
        current_bytes=len(after), current_text_bytes_renewed=len(before) - len(after),
        current_tail_bytes=len(tail), actual_public_queries=1 + len(old),
        effective_corruptions=controls,
        limits='Historical finite task-data preservation; tools/limits/runtime unchanged. No runtime host, feature/parity/native-custody/whole-project reading admission or disk-reclamation claim.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))

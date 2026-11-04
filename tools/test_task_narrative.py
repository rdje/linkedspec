#!/usr/bin/env python3
"""Independent current-contract oracle and corrupt retained-source controls."""
import gzip
import json
from pathlib import Path
import re
import shutil
import tempfile
import task_narrative as subject

ROOT = subject.ROOT


def contracts(raw):
    # Independent line-state parser: collect each complete core field with its
    # indented continuation, rather than using the migration's regex extractor.
    answer, owner, label = {}, None, None
    for line in raw.splitlines(keepends=True):
        match = re.fullmatch(rb'- ID: `([^`]+)`\n', line)
        if match:
            owner, label = match[1].decode(), None
            if owner in answer:
                raise AssertionError('duplicate current ID')
            answer[owner] = {}
            continue
        if line.startswith(b'## Current Frontier'):
            owner, label = None, None
            continue
        if owner is None:
            continue
        field = re.match(rb'  ([A-Za-z][A-Za-z /()-]*):', line)
        if field:
            label = field[1].decode()
            if label in subject.CORE:
                assert label not in answer[owner], (owner, label, 'duplicate field')
                answer[owner][label] = line
        elif label in subject.CORE and (line.startswith(b'    ') or line.startswith(b'\t')):
            answer[owner][label] += line
        else:
            label = None
    return answer


def retained_migration_preservation():
    for tree in subject.TREES:
        before = gzip.decompress((ROOT / f'docs/checkpoints/document-pressure-restoration/{tree}-task-input.md.gz').read_bytes())
        nodes = subject.nodes(gzip.decompress((ROOT / f'docs/checkpoints/document-pressure-restoration/{tree}-task-output.md.gz').read_bytes()))[1]
        after = b''.join(nodes.values())
        assert contracts(before) == contracts(after), tree + ' contract loss'
        original = subject.nodes(before)[1]
        assert set(original) == set(nodes), tree + ' ID loss'
        for key, value in original.items():
            if not re.search(rb'^  Status: `(done|completed|closed|superseded)`', value, re.M):
                assert value == nodes[key], key + ' open body changed'
        # Distinguishing negative: source and altered current view share the same
        # IDs/statuses but a changed Goal must be detected by this separate oracle.
        changed = re.sub(rb'^(  Goal: )', rb'\1LOST ', after, count=1, flags=re.M)
        assert contracts(before) != contracts(changed)
    print('task-narrative: exact precursor obligations/open bodies retained; altered Goal rejected')


def rejects(function):
    try:
        function()
    except (ValueError, FileNotFoundError):
        return
    raise AssertionError('corrupt narrative accepted')


def controls():
    tree = subject.TREES[0]
    with tempfile.TemporaryDirectory(dir=ROOT/'.linkedspec-data/normal-hook-restoration') as temporary:
        fixture = Path(temporary)
        directory = f'docs/history/task-narrative/{tree}'
        shutil.copytree(ROOT/directory, fixture/directory)
        for source in (ROOT/'docs/tasks').glob('TYPE-REFERENCE-BOOK*'):
            destination = fixture/'docs/tasks'/source.name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)
        subject.ROOT = fixture
        try:
            baseline = subject.archive(tree)
            assert baseline
            manifest = fixture/directory/'manifest.jsonl'
            first = fixture/directory/'source-0001.md'
            saved = first.read_bytes()
            first.write_bytes(saved.replace(b'Goal',b'Loss',1))
            rejects(lambda: subject.archive(tree))
            first.write_bytes(saved)
            first.unlink()
            rejects(lambda: subject.archive(tree))
            first.write_bytes(saved)
            first.unlink()
            first.symlink_to(ROOT/directory/'source-0001.md')
            rejects(lambda: subject.archive(tree))
            first.unlink()
            first.write_bytes(saved)
            rogue = fixture/directory/'rogue.md'
            rogue.write_bytes(b'extra\n')
            rejects(lambda: subject.archive(tree))
            rogue.unlink()
            raw = manifest.read_bytes()
            rows = [json.loads(line) for line in raw.splitlines()]
            rows[1]['start'] += 1
            manifest.write_bytes(b''.join(subject.canonical(row) for row in rows))
            rejects(lambda: subject.archive(tree))
            manifest.write_bytes(raw.replace(b'"pages":', b'"pages":0,"pages":',1))
            rejects(lambda: subject.archive(tree))
            manifest.write_bytes(raw)
            assert subject.archive(tree) == baseline
            index = fixture/'docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl'
            raw = index.read_bytes()
            rows = [json.loads(line) for line in raw.splitlines()]
            rows[1]['sha256'] = '0'*64
            index.write_bytes(b''.join(subject.canonical(row) for row in rows))
            rejects(lambda: subject.current(tree))
            index.write_bytes(raw)
            current = subject.current(tree)
            assert all(subject.partition(key) in subject.PARTS for key in current)
        finally:
            subject.ROOT = ROOT
    print('task-narrative: corruption/missing/symlink/rogue/range/duplicate/stale-index controls PASS')


def epoch_controls():
    epoch = 'TYPE-REFERENCE-BOOK.1.2.20.2'
    row, source = subject.epoch_source(epoch)
    tree = row['tree']
    actual = (ROOT / row['source_path']).read_bytes()
    assert contracts(source) == contracts(actual), 'epoch core contract loss'
    before, after = subject.nodes(source)[1], subject.nodes(actual)[1]
    assert set(before) == set(after), 'epoch current ID loss'
    selected = set(row['selected'])
    for key, node in before.items():
        if key not in selected:
            assert after[key] == node, key + ' unselected/open body changed'
    assert subject.verify_epochs() >= len(selected)
    # Independent source slice for public stable-ID retrieval, not the reader's
    # regex or renderer. The actual CLI probe retains this observation too.
    import subprocess
    key = row['selected'][0]
    start = source.index(('- ID: `' + key + '`\n').encode())
    end = source.find(b'\n- ID: `', start + 1)
    expected = source[start:] if end < 0 else source[start:end + 1]
    result = subprocess.run(['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
                             '--tree', tree, '--epoch', epoch, '--id', key],
                            cwd=ROOT, capture_output=True, check=True)
    assert result.stdout == expected and not result.stderr
    result = subprocess.run(['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
                             '--tree', tree, '--epoch', epoch, '--all'],
                            cwd=ROOT, capture_output=True, check=True)
    assert result.stdout == source and not result.stderr
    result = subprocess.run(['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
                             '--tree', subject.TREES[0], '--all'],
                            cwd=ROOT, capture_output=True, check=True)
    assert result.stdout == subject.archive(subject.TREES[0]) and not result.stderr
    denied = []

    def deny(name, function, reason):
        try:
            function()
        except ValueError as error:
            assert str(error) == reason, (name, str(error))
            denied.append(name)
        else:
            raise AssertionError('epoch control accepted: ' + name)

    with tempfile.TemporaryDirectory(dir=ROOT / '.linkedspec-data/normal-hook-restoration') as temporary:
        fixture = Path(temporary)
        shutil.copytree(ROOT / subject.EPOCH_DIRECTORY, fixture / subject.EPOCH_DIRECTORY)
        current = fixture / row['source_path']
        current.parent.mkdir(parents=True, exist_ok=True)
        current.write_bytes(actual)
        original_git = subject.git
        # Files come from the controlled fixture; Git identities/pathspecs come
        # from the actual repository root, independently of the fixture cwd.
        def repository_git(*args):
            return subprocess.check_output(['git', '-C', str(ROOT), *args])
        subject.git = repository_git
        subject.ROOT = fixture
        try:
            manifest = fixture / subject.epoch_path(epoch)
            raw = manifest.read_bytes()
            assert subject.verify_epochs() >= len(selected)
            cases = [
                ('source-hash', lambda value: value.update(sha256='0' * 64), 'epoch source identity'),
                ('source-blob', lambda value: value.update(source_blob='0' * 40), 'epoch source identity'),
                ('source-type', lambda value: value.update(source_commit=True), 'epoch source identities'),
                ('source-path', lambda value: value.update(source_path='../outside.md'), 'epoch source path'),
                ('empty-selection', lambda value: value.update(selected=[]), 'epoch selected population'),
                ('duplicate-selection', lambda value: value['selected'].append(value['selected'][-1]),
                 'epoch selected population'),
                ('unknown-ID', lambda value: value.update(selected=[tree + '.999999']), 'epoch selected IDs'),
                ('open-node', lambda value: value.update(selected=[tree]), 'only closed narrative may be extracted'),
            ]
            for name, change, reason in cases:
                value = json.loads(raw)
                change(value)
                manifest.write_bytes(subject.canonical(value))
                deny(name, lambda: subject.epoch_source(epoch), reason)
            manifest.write_bytes(raw)
            first = row['selected'][0]
            original_node = after[first]
            assert b'  Goal:' in original_node
            changed = original_node.replace(b'  Goal:', b'  Goal: LOST', 1)
            current.write_bytes(actual.replace(original_node, changed, 1))
            deny('current-goal', subject.verify_epochs, 'epoch current contract changed: ' + first + '/Goal')
            goal = subject.fields(original_node)['Goal']
            duplicate_node = original_node.replace(goal, goal + goal, 1)
            current.write_bytes(actual.replace(original_node, duplicate_node, 1))
            deny('duplicate-current-core', subject.verify_epochs, 'duplicate epoch current core field')
            pointer = subject.epoch_pointer(tree, first, epoch)
            current.write_bytes(actual.replace(pointer, b'', 1))
            deny('missing-pointer', subject.verify_epochs, 'current epoch pointer missing or wrong')
            current.write_bytes(actual)
            manifest.unlink()
            deny('missing-manifest', subject.verify_epochs,
                 'retained epoch member missing' if subject.git('ls-tree', '-r', '--name-only', 'HEAD', '--',
                                                               subject.EPOCH_DIRECTORY).strip()
                 else 'unregistered epoch pointer source')
            manifest.write_bytes(raw)
            rogue = manifest.parent / 'rogue.txt'
            rogue.write_bytes(b'rogue\n')
            deny('rogue-member', subject.verify_epochs, 'unknown epoch member')
            rogue.unlink()
            manifest.unlink()
            manifest.symlink_to(ROOT / subject.epoch_path(epoch))
            deny('symbolic-manifest', subject.verify_epochs, 'unknown epoch member')
            manifest.unlink()
            manifest.write_bytes(raw)
            assert subject.verify_epochs() >= len(selected)
            # Exercise the public one-shot writer's pre-write boundary, using
            # only controlled files on this repository's volume. No other Git
            # repository is initialized or touched by these fixtures.
            import importlib.util
            import os
            from unittest.mock import patch
            spec = importlib.util.spec_from_file_location('epoch_writer_fixture',
                                                         ROOT / 'tools/migrate_task_narrative.py')
            writer = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(writer)
            attempt = epoch + '.999'
            destination = fixture / subject.epoch_path(attempt)
            def migrate_attempt():
                writer.migrate_epoch(attempt, tree, row['source_commit'])
            peer = fixture / 'source-peer.md'
            peer.write_bytes(source)
            current.unlink()
            current.symlink_to(peer)
            deny('writer-source-symlink', migrate_attempt, 'symbolic epoch path')
            assert peer.read_bytes() == source and not destination.exists()
            current.unlink()
            current.write_bytes(source)
            directory = fixture / subject.EPOCH_DIRECTORY
            saved_directory = fixture / 'epoch-store'
            directory.rename(saved_directory)
            directory.symlink_to(saved_directory, target_is_directory=True)
            deny('writer-output-symlink', migrate_attempt, 'symbolic epoch path')
            assert not (saved_directory / destination.name).exists() and current.read_bytes() == source
            directory.unlink()
            saved_directory.rename(directory)
            native_exists = Path.exists
            def repository_boundary_exists(path):
                return True if path == directory / '.git' else native_exists(path)
            with patch.object(Path, 'exists', repository_boundary_exists):
                deny('writer-nested-repository', migrate_attempt, 'nested repository epoch path')
            assert not destination.exists() and current.read_bytes() == source
            native_stat = Path.stat
            def other_volume_stat(path, *args, **kwargs):
                value = native_stat(path, *args, **kwargs)
                if path == current:
                    values = list(value)
                    values[2] += 1
                    return os.stat_result(values)
                return value
            with patch.object(Path, 'stat', other_volume_stat):
                deny('writer-other-volume', migrate_attempt, 'epoch path is on another volume')
            assert not destination.exists() and current.read_bytes() == source
            native_writer_git = writer.git
            def unavailable_ancestor_git(*args):
                if args[0] == 'merge-base':
                    raise subprocess.CalledProcessError(1, ['git', *args])
                return native_writer_git(*args)
            writer.git = unavailable_ancestor_git
            try:
                deny('writer-unretained-ancestor', migrate_attempt,
                     'epoch source is not retained committed history')
            finally:
                writer.git = native_writer_git
            assert not destination.exists() and current.read_bytes() == source
            current.write_bytes(actual)
            peer.unlink()
            assert subject.verify_epochs() >= len(selected)
            legacy_tree = subject.TREES[0]
            legacy_target = fixture / f'docs/tasks/{legacy_tree}.md'
            legacy_target.write_bytes((ROOT / f'docs/tasks/{legacy_tree}.md').read_bytes())
            legacy_directory = f'docs/history/task-narrative/{legacy_tree}'
            shutil.copytree(ROOT / legacy_directory, fixture / legacy_directory)
            (fixture / '.linkedspec-data/normal-hook-restoration').mkdir(parents=True)
            deny('legacy-writer-repeated', writer.migrate, 'archive already exists')
            legacy_evidence = fixture / '.linkedspec-data/normal-hook-restoration' / (legacy_tree + '-candidate-before.md')
            assert not legacy_evidence.exists()
            # Model the exact previously committed manifest independently of
            # the reader. This also tests the boundary before initial landing.
            name = subject.epoch_path(epoch)
            def committed_manifest_git(*args):
                if args == ('ls-tree', '--name-only', 'HEAD', '--', name):
                    return (name + '\n').encode()
                if args == ('show', 'HEAD:' + name):
                    return raw
                return repository_git(*args)
            subject.git = committed_manifest_git
            assert subject.epoch_source(epoch)[1] == source
            changed_manifest = json.loads(raw)
            changed_manifest['selected'] = changed_manifest['selected'][:-1]
            manifest.write_bytes(subject.canonical(changed_manifest))
            deny('changed-committed-manifest', lambda: subject.epoch_source(epoch),
                 'retained epoch manifest changed')
            manifest.write_bytes(raw)
            assert subject.epoch_source(epoch)[1] == source
        finally:
            subject.ROOT = ROOT
            subject.git = original_git
    duplicate = before[first] + b'  Goal: duplicate\n'
    deny('duplicate-core', lambda: subject.compact_epoch(duplicate, tree, first, epoch),
         'duplicate epoch core field')
    print('task-narrative-epoch-controls:', json.dumps(denied))
    print('task-narrative-epoch:', len(before), 'IDs;', len(selected), 'closed;', len(before) - len(selected),
          'unaltered open/unselected bodies;', len(denied), 'specific denials;',
          len(source) - len(actual), 'bytes renewed')


if __name__ == '__main__':
    retained_migration_preservation()
    controls()
    epoch_controls()
    subject.verify()

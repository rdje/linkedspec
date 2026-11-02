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


if __name__ == '__main__':
    retained_migration_preservation()
    controls()
    subject.verify()

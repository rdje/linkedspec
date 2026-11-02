"""Source-bound closed-task narratives and bounded current semantic parts."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
TREES = ('TYPE-REFERENCE-BOOK', 'SPEC-LANGUAGE-SELF-CONTAINMENT', 'SPEC-FORMAT-TERSE')
CORE = ('Status', 'Goal', 'Acceptance', 'Dependencies', 'Children', 'Parent', 'Verification tier',
        'Focused checks', 'Canonical trigger', 'Claim verification', 'Commit', 'Commit subject',
        'Planned verification tier', 'Planned focused checks', 'Planned canonical trigger',
        'Planned claim verification', 'Superseded by')
PARTS = ('overview', 'helpers-01-39', 'helpers-40-59', 'helpers-60plus')
BASE = '0db5e9e87b7c1cfaf09936b9629974787038f5e3'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def canonical(row):
    return json.dumps(row, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode() + b'\n'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    require(isinstance(path, str) and re.fullmatch(r'[A-Za-z0-9_.\-/]+', path)
            and all(x not in ('.', '..') for x in path.split('/')) and not path.startswith('/'), 'unsafe narrative path')
    cursor = ROOT
    for part in path.split('/'):
        cursor /= part
        require(not cursor.is_symlink(), 'symbolic narrative input')
    return cursor.read_bytes()


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def nodes(raw):
    raw = re.split(rb'(?=^## Current Frontier\n)', raw, maxsplit=1, flags=re.M)[0]
    chunks = re.split(rb'(?=^- ID: `)', raw, flags=re.M)
    result = {}
    for chunk in chunks[1:]:
        match = re.match(rb'- ID: `([^`\n]+)`\n', chunk)
        require(match is not None, 'malformed narrative ID')
        key = match[1].decode()
        require(key not in result, 'duplicate narrative ID')
        result[key] = chunk
    return chunks[0], result


def fields(node):
    # Task fields have two-space indentation; multiline values use at least four.
    # Keep complete field values including continuation lines, verbatim.
    return {m[1].decode(): m[0] for m in re.finditer(
        rb'^  ([A-Za-z][A-Za-z /()-]*):[^\n]*(?:\n(?: {4}[^\n]*|\t[^\n]*))*\n?', node, re.M)}


def compact(node, tree, key):
    values = fields(node)
    if not re.match(rb'  Status: `(done|completed|closed|superseded)`', values.get('Status', b'')):
        return node
    lines = [node.splitlines(keepends=True)[0]]
    lines.extend(value for name, value in values.items() if name in CORE)
    lines.append(f'  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree {tree} --id {key}`.\n\n'.encode())
    result = b''.join(lines)
    for name in CORE:
        require(fields(result).get(name) == values.get(name), 'core field changed: ' + name)
    return result


def partition(key):
    match = re.match(r'TYPE-REFERENCE-BOOK\.1\.2\.23\.3\.(\d+)(?:\.|$)', key)
    if not match:
        return 'overview'
    number = int(match[1])
    return 'helpers-01-39' if number < 40 else 'helpers-40-59' if number < 60 else 'helpers-60plus'


def archive(tree):
    directory = f'docs/history/task-narrative/{tree}'
    raw_manifest = read(directory + '/manifest.jsonl')
    rows = raw_manifest.splitlines()
    require(0 < len(rows) <= 128 and len(raw_manifest) <= 65536, 'narrative manifest bound')
    records = []
    for line in rows:
        row = json.loads(line, object_pairs_hook=strict_pairs)
        require(isinstance(row, dict) and canonical(row) == line + b'\n', 'noncanonical narrative record')
        records.append(row)
    meta, pages = records[0], records[1:]
    require(set(meta) == {'type','tree','source_commit','source_path','source_blob','sha256','bytes','lines','pages'}
            and meta['type'] == 'task_narrative_archive' and meta['tree'] == tree
            and meta['source_commit'] == BASE and meta['source_path'] == f'docs/tasks/{tree}.md', 'archive source contract')
    require(type(meta['pages']) is int and meta['pages'] == len(pages), 'archive page count')
    raw, offset, expected = b'', 0, {directory + '/manifest.jsonl'}
    for ordinal, page in enumerate(pages, 1):
        name = f'{directory}/source-{ordinal:04d}.md'
        require(set(page) == {'type','path','start','bytes','lines','sha256'} and page['type'] == 'source_page'
                and page['path'] == name and type(page['start']) is int and page['start'] == offset,
                'archive page ordering/range')
        content = read(name)
        require(type(page['bytes']) is int and type(page['lines']) is int and len(content) == page['bytes']
                and content.count(b'\n') == page['lines'] and len(content) <= 524288
                and page['lines'] <= 4096 and digest(content) == page['sha256'], 'archive page identity/bound')
        raw += content
        offset += len(content)
        expected.add(name)
    require(set(str(p.relative_to(ROOT)) for p in (ROOT / directory).rglob('*') if p.is_file()) == expected,
            'undeclared narrative archive input')
    require(type(meta['bytes']) is int and type(meta['lines']) is int and len(raw) == meta['bytes']
            and raw.count(b'\n') == meta['lines'] and digest(raw) == meta['sha256'], 'archive reconstruction mismatch')
    blob = git('rev-parse', f'{BASE}:{meta["source_path"]}').decode().strip()
    require(meta['source_blob'] == blob and git('cat-file', 'blob', blob) == raw, 'archive differs from Git source')
    # Once published, archive members are immutable, including their manifest.
    retained = git('ls-tree','-r','--name-only', 'HEAD', '--', directory).decode().splitlines()
    for name in retained:
        require(name in expected and read(name) == git('show', 'HEAD:' + name), 'retained archive changed')
    return raw


def strict_pairs(items):
    result = {}
    for key, value in items:
        require(key not in result, 'duplicate archive JSON key')
        result[key] = value
    return result


def current(tree):
    if tree != TREES[0]:
        return nodes(read(f'docs/tasks/{tree}.md'))[1]
    path = f'docs/tasks/{tree}.index.jsonl'
    raw = read(path)
    rows = [json.loads(line, object_pairs_hook=strict_pairs) for line in raw.splitlines()]
    require(raw == b''.join(canonical(row) for row in rows), 'noncanonical TYPE index')
    require(len(rows) == 5 and len(raw) <= 16384, 'TYPE index bound')
    meta = rows[0]
    require(meta == {'type':'task_tree_index','schema_version':1,'tree':tree,'part_count':4,
                     'authority':'docs/decisions/0139-approved-archive-reference-contracts.md',
                     'max_member_lines':5000,'max_member_bytes':786432}, 'TYPE index contract')
    result = {}
    for kind, row in zip(PARTS, rows[1:]):
        name = f'docs/tasks/{tree}.{kind}.md'
        require(set(row) == {'type','tree','mutable','partition_id','path','sha256','line_count','byte_count'}
                and row['type'] == 'task_tree_part' and row['tree'] == tree and row['mutable'] is True
                and row['partition_id'] == kind and row['path'] == name, 'TYPE partition contract')
        part = read(name)
        require(type(row['byte_count']) is int and type(row['line_count']) is int
                and len(part) == row['byte_count'] and part.count(b'\n') == row['line_count']
                and len(part) <= 786432 and row['line_count'] <= 5000 and digest(part) == row['sha256'], 'TYPE partition identity/bound')
        for key, value in nodes(part)[1].items():
            require(partition(key) == kind and key not in result, 'TYPE partition routing/duplicate')
            result[key] = value
    declared = {f'{tree}.md'} | {f'{tree}.{kind}.md' for kind in PARTS}
    present = {p.name for p in (ROOT/'docs/tasks').glob(tree+'*.md')}
    require(declared == present, 'unknown or missing TYPE current partition')
    root = read(f'docs/tasks/{tree}.md')
    require(not nodes(root)[1] and root.count(b'\n') <= 512 and len(root) <= 65536, 'TYPE root bound/duplicate')
    return result


def verify():
    total = 0
    for tree in TREES:
        prior = nodes(archive(tree))[1]
        now = current(tree)
        require(set(prior) <= set(now), 'current task IDs were lost: ' + tree)
        for key, value in prior.items():
            before, after = fields(value), fields(now[key])
            if b'  Narrative: exact predecessor via ' in now[key]:
                # Closed obligations and owner declarations survive compaction.
                for label in CORE:
                    if label not in ('Status', 'Commit', 'Commit subject'):
                        require(before.get(label) == after.get(label), 'closed task contract changed: ' + key + '/' + label)
                require(f'--tree {tree} --id {key}`'.encode() in now[key], 'closed narrative pointer is wrong')
        total += len(prior)
    return total

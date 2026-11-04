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
EPOCH_DIRECTORY = 'docs/history/task-narrative-epochs'


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


def epoch_path(epoch):
    require(isinstance(epoch, str) and re.fullmatch(r'[A-Z][A-Z0-9-]*(?:\.[0-9]+)+', epoch),
            'invalid narrative epoch')
    return f'{EPOCH_DIRECTORY}/{epoch}.json'


def epoch_local_file(name, allow_missing=False):
    """Check the repository write/read boundary without following a link."""
    require(isinstance(name, str) and re.fullmatch(r'[A-Za-z0-9_.\-/]+', name)
            and not name.startswith('/') and all(part not in ('', '.', '..') for part in name.split('/')),
            'unsafe epoch local path')
    cursor = ROOT
    volume = ROOT.stat().st_dev
    parts = Path(name).parts
    for number, part in enumerate(parts):
        cursor /= part
        require(not cursor.is_symlink(), 'symbolic epoch path')
        if not cursor.exists():
            require(allow_missing, 'epoch input is missing')
            return ROOT / name
        require(cursor.stat().st_dev == volume, 'epoch path is on another volume')
        if cursor.is_dir():
            marker = cursor / '.git'
            require(not marker.is_symlink() and not marker.exists(), 'nested repository epoch path')
        if number == len(parts) - 1:
            require(cursor.is_file(), 'nonregular epoch file')
    return cursor


def epoch_pointer(tree, key, epoch):
    return (f'  Narrative epoch: `{epoch}`; exact accepted source via '
            f'`bash tools/run_python_project_data.sh tools/read_task_narrative.py '
            f'--tree {tree} --epoch {epoch} --id {key}`.\n\n').encode()


def compact_epoch(node, tree, key, epoch):
    epoch_path(epoch)
    require(isinstance(tree, str) and re.fullmatch(r'[A-Z][A-Z0-9-]*', tree)
            and isinstance(key, str) and re.fullmatch(re.escape(tree) + r'(?:\.[0-9]+)*', key),
            'invalid epoch task identity')
    labels = re.findall(rb'^  ([A-Za-z][A-Za-z /()-]*):', node, re.M)
    require(all(labels.count(name.encode()) <= 1 for name in CORE), 'duplicate epoch core field')
    values = fields(node)
    require(re.match(rb'  Status: `(done|completed|closed|superseded)`', values.get('Status', b'')),
            'only closed narrative may be extracted')
    require(b'  Narrative:' not in node and b'  Narrative epoch:' not in node,
            'narrative already extracted')
    raw = node.splitlines(keepends=True)[0]
    raw += b''.join(value for name, value in values.items() if name in CORE)
    raw += epoch_pointer(tree, key, epoch)
    require(all(fields(raw).get(name) == values.get(name) for name in CORE), 'epoch core contract loss')
    return raw


def epoch_source(epoch):
    """Read an immutable manifest and its complete committed Git source body.

    Epochs cover unpartitioned current trees. The three original archives and
    their readers retain their original source and storage contracts.
    """
    name = epoch_path(epoch)
    epoch_local_file(name)
    manifest = read(name)
    require(len(manifest) <= 65536, 'epoch manifest bound')
    row = json.loads(manifest, object_pairs_hook=strict_pairs)
    require(canonical(row) == manifest, 'noncanonical epoch manifest')
    require(isinstance(row, dict) and set(row) == {'version', 'epoch', 'tree', 'source_commit', 'source_path', 'source_blob',
                         'sha256', 'bytes', 'lines', 'selected'}, 'epoch manifest schema')
    require(type(row['version']) is int and row['version'] == 1 and row['epoch'] == epoch,
            'epoch identity')
    tree = row['tree']
    require(isinstance(tree, str) and re.fullmatch(r'[A-Z][A-Z0-9-]*', tree), 'epoch tree name')
    require(row['source_path'] == f'docs/tasks/{tree}.md', 'epoch source path')
    require(all(isinstance(row[key], str) and re.fullmatch(r'[0-9a-f]{' + str(size) + '}', row[key])
                for key, size in (('source_commit', 40), ('source_blob', 40), ('sha256', 64))),
            'epoch source identities')
    require(type(row['bytes']) is int and 0 < row['bytes'] <= 1048576
            and type(row['lines']) is int and 0 < row['lines'] <= 8000, 'epoch source bounds')
    selected = row['selected']
    require(isinstance(selected, list) and selected and all(isinstance(key, str) for key in selected)
            and selected == sorted(set(selected)), 'epoch selected population')
    try:
        git('merge-base', '--is-ancestor', row['source_commit'], 'HEAD')
        blob = git('rev-parse', f'{row["source_commit"]}:{row["source_path"]}').decode().strip()
        source = git('cat-file', 'blob', blob)
    except subprocess.CalledProcessError as error:
        raise ValueError('epoch source is not retained committed history') from error
    require(blob == row['source_blob'] and digest(source) == row['sha256']
            and len(source) == row['bytes'] and source.count(b'\n') == row['lines'], 'epoch source identity')
    prior = nodes(source)[1]
    require(all(key in prior and re.fullmatch(re.escape(tree) + r'(?:\.[0-9]+)*', key)
                for key in selected), 'epoch selected IDs')
    for key in selected:
        compact_epoch(prior[key], tree, key, epoch)
    retained = git('ls-tree', '--name-only', 'HEAD', '--', name).decode().splitlines()
    require(not retained or retained == [name] and git('show', 'HEAD:' + name) == manifest,
            'retained epoch manifest changed')
    return row, source


def verify_epochs():
    directory = ROOT / EPOCH_DIRECTORY
    if not directory.exists():
        require(not directory.is_symlink(), 'unsafe epoch directory')
        require(not git('ls-tree', '-r', '--name-only', 'HEAD', '--', EPOCH_DIRECTORY).strip(),
                'retained epoch directory missing')
        paths = []
    else:
        require(not directory.is_symlink() and directory.is_dir(), 'unsafe epoch directory')
        paths = sorted(directory.iterdir())
    expected, selections, sources = set(), set(), set()
    for path in paths:
        require(path.is_file() and not path.is_symlink() and path.suffix == '.json', 'unknown epoch member')
        epoch = path.stem
        name = epoch_path(epoch)
        expected.add(name)
        row, source = epoch_source(epoch)
        tree = row['tree']
        prior, now = nodes(source)[1], current(tree)
        sources.add(row['source_path'])
        for key in row['selected']:
            require((tree, key) not in selections, 'duplicate epoch selection')
            selections.add((tree, key))
            pointer = epoch_pointer(tree, key, epoch).splitlines(keepends=True)[0]
            require(key in now and fields(now[key]).get('Narrative epoch') == pointer
                    and now[key].count(pointer) == 1, 'current epoch pointer missing or wrong')
            labels = re.findall(rb'^  ([A-Za-z][A-Za-z /()-]*):', now[key], re.M)
            require(all(labels.count(label.encode()) <= 1 for label in CORE),
                    'duplicate epoch current core field')
            before, after = fields(prior[key]), fields(now[key])
            require(re.match(rb'  Status: `(done|completed|closed|superseded)`', after.get('Status', b'')),
                    'epoch current node is not closed')
            for label in CORE:
                if label not in ('Status', 'Commit', 'Commit subject'):
                    require(before.get(label) == after.get(label), 'epoch current contract changed: ' + key + '/' + label)
    retained = git('ls-tree', '-r', '--name-only', 'HEAD', '--', EPOCH_DIRECTORY).decode().splitlines()
    require(set(retained) <= expected, 'retained epoch member missing')
    # A new pointer cannot silently lose its manifest or name an unregistered ID.
    for path in (ROOT / 'docs/tasks').glob('*.md'):
        raw = read(str(path.relative_to(ROOT)))
        if b'  Narrative epoch:' not in raw:
            continue
        require(str(path.relative_to(ROOT)) in sources, 'unregistered epoch pointer source')
        for key, node in nodes(raw)[1].items():
            if b'  Narrative epoch:' in node:
                require((key.split('.', 1)[0], key) in selections, 'unregistered epoch pointer ID')
    return len(selections)


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
    verify_epochs()
    return total

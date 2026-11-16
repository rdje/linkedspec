"""Retain and qualify immutable candidate sources; no task migration or SDK runs."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'e476d208dcee58f67ca4d0d7a950d5aa8bdcab00'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.34'
CORE = ('Status', 'Goal', 'Acceptance', 'Dependencies', 'Children', 'Parent',
        'Verification tier', 'Focused checks', 'Canonical trigger', 'Claim verification',
        'Commit', 'Commit subject', 'Planned verification tier', 'Planned focused checks',
        'Planned canonical trigger', 'Planned claim verification', 'Superseded by')


def native(tag, argv, data=None):
    with (BASE / (tag + '-command.json')).open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    if data is not None:
        (BASE / (tag + '-stdin.gz')).write_bytes(gzip.compress(data, mtime=0))
    result = subprocess.run(argv, input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for name in ('stdout', 'stderr'):
        (BASE / (tag + '-' + name + '.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
    (BASE / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and not result.stderr, 'actual command channels retained:' + tag
    return result.stdout


def fields(body):
    """Line-state interpretation separate from the production regex parser."""
    lines = body.splitlines(keepends=True)
    result, cursor = [], 1
    while cursor < len(lines):
        match = re.fullmatch(rb'  ([A-Za-z][A-Za-z /()-]*):[^\n]*\n?', lines[cursor])
        if not match:
            cursor += 1
            continue
        label, value = match[1].decode(), lines[cursor]
        cursor += 1
        while cursor < len(lines) and (lines[cursor].startswith(b'    ') or lines[cursor].startswith(b'\t')):
            value += lines[cursor]
            cursor += 1
        result.append((label, value))
    return result


def propose(tree, body):
    marker = b'## Current Frontier\n'
    count = len(re.findall(rb'^## Current Frontier\n', body, re.M))
    if count != 1:
        return dict(tree=tree, compatible=False, reason='requires one exact uppercase frontier', frontier_count=count)
    content, tail = body.split(marker, 1)
    starts = list(re.finditer(rb'^- ID: `([^`\n]+)`\n', content, re.M))
    selected, scope_loss, duplicates = [], [], []
    ids = []
    for index, match in enumerate(starts):
        key = match[1].decode()
        ids.append(key)
        node = content[match.start():starts[index + 1].start() if index + 1 < len(starts) else len(content)]
        values = fields(node)
        labels = [label for label, _ in values]
        status = next((value for label, value in values if label == 'Status'), b'')
        if not re.match(rb'  Status: `(done|completed|closed|superseded)`', status):
            continue
        if b'  Narrative:' in node or b'  Narrative epoch:' in node:
            continue
        repeated = [label for label in CORE if labels.count(label) > 1]
        if repeated:
            duplicates.append(dict(id=key, labels=repeated))
            continue
        pointer = (f'  Narrative epoch: `{OWNER}`; exact accepted source via '
                   f'`bash tools/run_python_project_data.sh tools/read_task_narrative.py '
                   f'--tree {tree} --epoch {OWNER} --id {key}`.\n\n').encode()
        candidate = node.splitlines(keepends=True)[0] + b''.join(value for label, value in values if label in CORE) + pointer
        if len(candidate) < len(node):
            if 'Scope' in labels:
                scope_loss.append(key)
            selected.append(dict(id=key, before=len(node), after=len(candidate), saved=len(node) - len(candidate)))
    compatible = bool(selected) and not scope_loss and not duplicates and len(set(ids)) == len(ids)
    return dict(tree=tree, compatible=compatible, ids=len(ids), selected=selected,
                selected_scope_loss=scope_loss, duplicate_core=duplicates,
                proposed_saved_bytes=sum(row['saved'] for row in selected), tail_bytes=len(marker) + len(tail),
                reason='qualified source proposal only' if compatible else 'no safe eligible reduction')


def main():
    assert not (BASE / 'scan.json').exists(), 'scan is one-shot'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    sources = [str(BASE / 'scan.py'), 'tools/task_narrative.py', 'tools/migrate_task_narrative.py',
               'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh']
    identities = {}
    with tarfile.open(BASE / 'scan-producers.tar.gz', 'x:gz') as archive:
        for name in sources:
            path = Path(name)
            assert not path.is_absolute() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            identities[name] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'scan-producer-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    raw_tree = native('scan-tree', ['git', 'ls-tree', '-rz', ACTIVATION, '--', 'docs/tasks'])
    tree = {}
    for cell in raw_tree.split(b'\0'):
        if cell:
            header, name = cell.split(b'\t')
            mode, kind, blob = header.decode().split()
            if kind == 'blob':
                tree[name.decode()] = dict(mode=mode, blob=blob)
    names = sorted(name for name in tree if re.fullmatch(r'docs/tasks/[A-Z][A-Z0-9-]*\.md', name)
                   and name[:-3] + '.index.jsonl' not in tree)
    request = ''.join(tree[name]['blob'] + '\n' for name in names).encode()
    packed = native('scan-blobs', ['git', 'cat-file', '--batch'], request)
    reports, offset = [], 0
    for name in names:
        end = packed.index(b'\n', offset)
        blob, kind, count = packed[offset:end].decode().split()
        count = int(count)
        body = packed[end + 1:end + 1 + count]
        assert kind == 'blob' and blob == tree[name]['blob']
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == blob
        assert packed[end + 1 + count:end + 2 + count] == b'\n'
        offset = end + 2 + count
        row = propose(Path(name).stem, body)
        row.update(path=name, blob=blob, mode=tree[name]['mode'], sha256=hashlib.sha256(body).hexdigest())
        reports.append(row)
    assert offset == len(packed)
    report = dict(owner=OWNER, activation=ACTIVATION, sources=reports,
                  limits='Immutable source proposals only; no task mutation, actual capacity renewal, SDK or native/source-origin/physical closure. Production epoch admission and independent preservation still required; full custody remains4.2/SESSION5.')
    (BASE / 'scan.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(json.dumps(sorted([dict(tree=row['tree'], selected=len(row['selected']), saved=row['proposed_saved_bytes'])
                             for row in reports if row['compatible']], key=lambda row: -row['saved'])[:10], indent=2))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""One-time, source-retaining migration authorized by accepted ADR 0139."""
import gzip
from pathlib import Path
import re
import subprocess
from task_narrative import (ROOT, TREES, PARTS, BASE, CORE, archive, canonical, compact, current,
                            compact_epoch, digest, epoch_local_file, epoch_path, fields, git, nodes, partition, require,
                            verify_epochs)


def migrate():
    for tree in TREES:
        target = ROOT / f'docs/tasks/{tree}.md'
        epoch_local_file(str(target.relative_to(ROOT)))
        original = target.read_bytes()
        evidence = ROOT / '.linkedspec-data/normal-hook-restoration' / (tree + '-candidate-before.md')
        epoch_local_file(str(evidence.relative_to(ROOT)), allow_missing=True)
        require(not evidence.exists(), 'migration already attempted; inspect its retained input first')
        directory = ROOT / f'docs/history/task-narrative/{tree}'
        epoch_local_file(str((directory / 'manifest.jsonl').relative_to(ROOT)), allow_missing=True)
        require(not directory.exists(), 'archive already exists')
        evidence.write_bytes(original)
        source = git('show', f'{BASE}:docs/tasks/{tree}.md')
        directory.mkdir(parents=True)
        pages, content, start = [], b'', 0
        def flush():
            nonlocal content, start
            if not content:
                return
            name = str((directory / f'source-{len(pages)+1:04d}.md').relative_to(ROOT))
            (ROOT / name).write_bytes(content)
            pages.append(dict(type='source_page', path=name, start=start, bytes=len(content),
                              lines=content.count(b'\n'), sha256=digest(content)))
            start += len(content)
            content = b''
        for line in source.splitlines(keepends=True):
            require(len(line) <= 524288, 'source line exceeds archive page')
            if len(content)+len(line) > 524288 or content.count(b'\n') >= 4096:
                flush()
            content += line
        flush()
        meta = dict(type='task_narrative_archive', tree=tree, source_commit=BASE,
                    source_path=f'docs/tasks/{tree}.md',
                    source_blob=git('rev-parse', f'{BASE}:docs/tasks/{tree}.md').decode().strip(),
                    sha256=digest(source), bytes=len(source), lines=source.count(b'\n'), pages=len(pages))
        (directory/'manifest.jsonl').write_bytes(b''.join(canonical(x) for x in [meta]+pages))
        require(archive(tree) == source, 'archive differs from predecessor')
        prefix, before = nodes(original)
        rendered = {key:compact(value, tree, key) for key,value in before.items()}
        tail = original.split(b'## Current Frontier\n',1)[1]
        # Current frontier, decisions, questions and blockers remain directly browsable.
        # Old verification/commit/changelog bytes are available in the exact archive.
        tail = tail.split(b'## Verification Log\n',1)[0]
        tail += f'## Historical narrative\n\nExact predecessor: `python3 tools/read_task_narrative.py --tree {tree} --all`.\n'.encode()
        if tree == TREES[0]:
            records = [dict(type='task_tree_index', schema_version=1, tree=tree, part_count=4,
                            authority='docs/decisions/0139-approved-archive-reference-contracts.md',
                            max_member_lines=5000, max_member_bytes=786432)]
            for kind in PARTS:
                name=f'docs/tasks/{tree}.{kind}.md'
                raw=(prefix if kind=='overview' else f'# {tree} — {kind}\n\n'.encode())
                raw+=b''.join(v for k,v in rendered.items() if partition(k)==kind)
                require(len(raw)<=786432 and raw.count(b'\n')<=5000, 'semantic partition exceeds retained bound: '+kind)
                (ROOT/name).write_bytes(raw)
                records.append(dict(type='task_tree_part', tree=tree, mutable=True, partition_id=kind,
                                    path=name, sha256=digest(raw), line_count=raw.count(b'\n'), byte_count=len(raw)))
            (ROOT/f'docs/tasks/{tree}.index.jsonl').write_bytes(b''.join(canonical(x) for x in records))
            target.write_bytes(f'''# {tree}: Complete navigable per-type language reference

- Tree ID: `{tree}`
- Status: `active`
- Authority: accepted ADR `0139`; every stable node lives once in the semantic parts below.

Recover a node with `perl tools/read_task_tree.pl --tree {tree} --id <stable-id>`.
After editing a mutable part run `perl tools/update_task_tree_index.pl --tree {tree}`.

| Current semantic part | Stable-ID responsibility |
| --- | --- |
| [Overview](TYPE-REFERENCE-BOOK.overview.md) | All nodes outside helper-family children |
| [Families 01–39](TYPE-REFERENCE-BOOK.helpers-01-39.md) | `.1.2.23.3.1` through `.39`, including descendants |
| [Families 40–59](TYPE-REFERENCE-BOOK.helpers-40-59.md) | `.1.2.23.3.40` through `.59`, including descendants |
| [Families 60+](TYPE-REFERENCE-BOOK.helpers-60plus.md) | `.1.2.23.3.60` and later families, including descendants |

## Current Frontier
'''.encode()+tail)
        else:
            target.write_bytes(prefix+b''.join(rendered.values())+b'## Current Frontier\n'+tail)
        after=current(tree)
        require(set(before)==set(after), 'migration changed the current ID set')
        for key,value in before.items():
            for label in CORE:
                require(fields(value).get(label)==fields(after[key]).get(label),'migration changed contract: '+key+'/'+label)
            if rendered[key]==value:
                require(after[key]==value,'migration changed an open task body')
        # Retained exact current precursor supports the independently rerunnable migration proof.
        capsule=ROOT/f'docs/checkpoints/document-pressure-restoration/{tree}-task-input.md.gz'
        capsule.write_bytes(gzip.compress(original,mtime=0))
        print(tree, 'retained',len(before),'IDs; archive',len(source),'bytes; current',sum(map(len,after.values())),'bytes')


def migrate_epoch(epoch, tree, revision):
    require(re.fullmatch(r'[A-Z][A-Z0-9-]*', tree), 'invalid epoch tree')
    require(re.fullmatch(r'[0-9a-f]{40}', revision), 'epoch requires an exact source commit')
    target = ROOT / f'docs/tasks/{tree}.md'
    epoch_local_file(str(target.relative_to(ROOT)))
    manifest = ROOT / epoch_path(epoch)
    epoch_local_file(str(manifest.relative_to(ROOT)), allow_missing=True)
    require(not (ROOT / f'docs/tasks/{tree}.index.jsonl').exists(), 'epoch migration requires an unpartitioned tree')
    source_commit = git('rev-parse', '--verify', revision + '^{commit}').decode().strip()
    try:
        git('merge-base', '--is-ancestor', source_commit, 'HEAD')
    except subprocess.CalledProcessError as error:
        raise ValueError('epoch source is not retained committed history') from error
    source_path = str(target.relative_to(ROOT))
    source = git('show', source_commit + ':' + source_path)
    require(target.read_bytes() == source, 'epoch source differs from current tree')
    prefix, before = nodes(source)
    section = re.split(rb'(?=^## Current Frontier\n)', source, maxsplit=1, flags=re.M)
    require(prefix + b''.join(before.values()) == section[0], 'epoch source parser reconstruction')
    selected, rendered = [], {}
    for key, node in before.items():
        values = fields(node)
        closed = re.match(rb'  Status: `(done|completed|closed|superseded)`', values.get('Status', b''))
        if closed and b'  Narrative:' not in node and b'  Narrative epoch:' not in node:
            candidate = compact_epoch(node, tree, key, epoch)
            if len(candidate) < len(node):
                selected.append(key)
                rendered[key] = candidate
                continue
        rendered[key] = node
    require(selected, 'no closed narrative capacity')
    result = prefix + b''.join(rendered.values()) + (section[1] if len(section) == 2 else b'')
    after = nodes(result)[1]
    require(set(before) == set(after), 'epoch current IDs changed')
    for key, node in before.items():
        require(all(fields(node).get(label) == fields(after[key]).get(label) for label in CORE),
                'epoch current contract changed')
        require(key in selected or after[key] == node, 'epoch unselected body changed')
    require(not manifest.exists(), 'epoch already exists')
    row = dict(version=1, epoch=epoch, tree=tree, source_commit=source_commit, source_path=source_path,
               source_blob=git('rev-parse', source_commit + ':' + source_path).decode().strip(),
               sha256=digest(source), bytes=len(source), lines=source.count(b'\n'), selected=sorted(selected))
    raw = canonical(row)
    require(len(raw) <= 65536, 'epoch manifest bound')
    manifest.parent.mkdir(parents=True, exist_ok=True)
    manifest.write_bytes(raw)
    target.write_bytes(result)
    require(verify_epochs() >= len(selected), 'epoch verification failed')
    print(tree, 'retained', len(before), 'IDs;', len(selected), 'closed narratives;',
          len(source) - len(result), 'bytes renewed; source', source_commit)


if __name__=='__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true', required=True)
    parser.add_argument('--epoch')
    parser.add_argument('--tree')
    parser.add_argument('--source-commit')
    args = parser.parse_args()
    if args.epoch:
        require(args.tree and args.source_commit, 'epoch requires tree and explicit source commit')
        migrate_epoch(args.epoch, args.tree, args.source_commit)
    else:
        require(not args.tree and not args.source_commit, 'original migration takes no epoch arguments')
        migrate()

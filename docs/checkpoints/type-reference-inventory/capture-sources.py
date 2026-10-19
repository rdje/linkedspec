"""Capture a conservative owned authority/test/book superset before inventory producers."""
import json
import re
import subprocess
from pathlib import Path
import common as c

tracked = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=c.ROOT).decode().split('\0')
entries = {}
for row in filter(None, tracked):
    header, path = row.split('\t')
    mode, oid, stage = header.split()
    assert stage == '0', ('unmerged source', path)
    entries[path] = dict(git_mode=mode, oid=oid)

roots = ('perl/', 'rust/linkedspec-core/src/', 'rust/linkedspec-runtime/src/',
    'dart/lib/', 'julia/src/', 'lua/src/', 'capability_conformance/', 'tools/',
    't/', 'rust/linkedspec-core/tests/', 'rust/linkedspec-runtime/tests/',
    'dart/test/', 'julia/test/', 'lua/test/', 'unicode_case/')
suffixes = {'.pm', '.pl', '.py', '.sh', '.rs', '.dart', '.jl', '.lua', '.c', '.h',
            '.spec', '.json', '.jsonl', '.toml', '.yaml', '.yml', '.tsv', '.csv', '.txt', '.md'}
paths = set()
for path, item in entries.items():
    if item['git_mode'] not in ('100644', '100755'):
        continue  # Submodules and symlinks are not inspected as implementation inputs.
    suffix = Path(path).suffix
    if path.startswith(roots) and suffix in suffixes:
        paths.add(path)
    if suffix == '.spec' and not path.startswith(('docs/checkpoints/', 'docs/history/')):
        paths.add(path)
    if path.startswith('docs/decisions/') and suffix == '.md':
        paths.add(path)
    if path == 'docs/linkedspec-book/book.toml' or path.startswith('docs/linkedspec-book/src/'):
        paths.add(path)
paths.update(['README.md', 'TOOLBOX.md', 'capability_conformance/README.md',
    'docs/knowledge/terse-type-method-surface-inventory.md',
    'docs/knowledge/uniform-binding-neutral-contract.md',
    'docs/knowledge/current-call-name-inventory-does-not-prove-runtime-semantics.md',
    'docs/knowledge/book-per-type-reference-gap.md',
    'docs/knowledge/cross-backend-scalar-numeric-drift.md',
    'docs/knowledge/terse-primitive-literal-parity.md'])
book = {path for path in paths if path == 'docs/linkedspec-book/book.toml' or path.startswith('docs/linkedspec-book/src/')}
pending = list(book)
while pending:
    path = pending.pop()
    for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', (c.ROOT / path).read_bytes()):
        target = ((c.ROOT / path).parent / name.decode().split(':', 1)[0]).resolve().relative_to(c.ROOT).as_posix()
        assert target in entries and entries[target]['git_mode'] in ('100644', '100755')
        if target not in paths:
            paths.add(target)
            pending.append(target)
paths.update(c.PREFIX + name for name in ('common.py', 'capture-sources.py', 'preserve.py'))
inputs = {path: c.read(path) for path in sorted(paths)}
for path in paths:
    if path in entries:
        expected = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert expected == c.decode(inputs[path]['base64']), ('actual accepted source boundary', path)
c.write_new(c.PREFIX + 'source-inputs.json.gz', dict(base_commit=c.BASE, inputs=inputs,
    git_entries={path: entries[path] for path in paths if path in entries},
    selection=dict(roots=roots, suffixes=sorted(suffixes), all_owned_nonhistorical_spec_sources=True,
        all_decision_records=True, complete_book_sources=True, recursive_tracked_includes=True),
    scope='Conservative tracked owned source/neutral-contract/grammar/test/book superset before any '
          'inventory command. All retained tracked bytes equal real accepted BASE; submodule implementation '
          'is excluded. Capture is custody, not a full-reading audit or a supported-operation count.'), packed=True)
print('Owned source authority/test/book superset retained before producers:', len(inputs))

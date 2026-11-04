"""Select a larger current closed-narrative source; no history implementation audit."""
import hashlib
import json
from pathlib import Path
import re

from intake import BASE, HERE, ROOT, git, subject


def main():
    output = HERE / 'population.json'
    assert not output.exists(), 'population intake is one-shot'
    names = [name for name in git('ls-tree', '-r', '--name-only', BASE, '--', 'docs/tasks').decode().splitlines()
             if name.endswith(('.md', '.index.jsonl'))]
    ignored, inputs = set(), {}
    for name in names:
        if not name.endswith('.index.jsonl'):
            continue
        raw = git('cat-file', 'blob', BASE + ':' + name)
        for line in raw.splitlines():
            row = json.loads(line)
            if row.get('type') == 'task_tree_part' and row.get('mutable') is False:
                ignored.add(row['path'])
        inputs[name] = {'blob': git('rev-parse', BASE + ':' + name).decode().strip(),
                        'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)}
    rows, unsupported = [], []
    for name in names:
        if not name.endswith('.md') or name in ignored or name.endswith('/TEMPLATE.md'):
            continue
        raw = git('cat-file', 'blob', BASE + ':' + name)
        inputs[name] = {'blob': git('rev-parse', BASE + ':' + name).decode().strip(),
                        'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)}
        candidates = []
        try:
            source_nodes = subject.nodes(raw)[1]
        except ValueError as error:
            # The existing migration parser covers multiline node headers.
            # Preserve and disclose legacy inline-root files, never normalize
            # their source or claim that this instrument classified them.
            if str(error) != 'malformed narrative ID':
                raise
            unsupported.append({'path': name, 'reason': str(error)})
            continue
        for key, node in source_nodes.items():
            if (not re.match(rb'  Status: `(done|completed|closed|superseded)`',
                             subject.fields(node).get('Status', b''))
                    or b'  Narrative: exact predecessor via ' in node):
                continue
            tree = key.split('.', 1)[0]
            compact = subject.compact(node, tree, key)
            saving = len(node) - len(compact)
            if saving > 0:
                candidates.append({'id': key, 'source_bytes': len(node), 'legacy_render_bytes': len(compact),
                                   'structural_saving': saving})
        if candidates:
            rows.append({'path': name, 'candidate_count': len(candidates),
                         'structural_saving': sum(row['structural_saving'] for row in candidates),
                         'candidates': candidates})
    rows.sort(key=lambda row: -row['structural_saving'])
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.20.2', 'activation_commit': BASE,
              'producer_source': Path(__file__).read_text(), 'inputs': inputs,
              'excluded_index_registered_immutable_parts': sorted(ignored), 'ranked': rows,
              'unclassified_legacy_inline_headers': unsupported,
              'limits': 'Fixed clean current-task structural census only. Old rendering is a capacity '
                        'estimate, not admission of old-source pointers for new nodes. No source bodies, '
                        'open tasks, immutable history, numerical limits or other repositories change.'}
    output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps([{key: value for key, value in row.items() if key != 'candidates'}
                      for row in rows[:8]], sort_keys=True))


if __name__ == '__main__':
    main()

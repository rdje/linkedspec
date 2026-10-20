"""Apply only the duplicate-intake metadata correction after whole-draft preservation."""
import gzip
import json
import sys
from pathlib import Path
sys.path.insert(1, str(Path(__file__).resolve().parents[1] / 'type-numeric-codeblocks'))
import common as c
import preserve as p


def main():
    saved = json.loads(gzip.decompress((c.ROOT / (p.PREFIX + 'canonical1.json.gz')).read_bytes()))
    assert all(c.read(path) == item for path, item in saved['before'].items())
    changes = {}
    path = 'docs/tasks/SESSION-STARTUP-READING.50-99.md'
    text = (c.ROOT / path).read_text()
    start = text.index('- ID: `SESSION-STARTUP-READING.87.3`')
    end = text.index('- ID: `SESSION-STARTUP-READING.87.4`', start)
    node = text[start:end]
    first = node.index('  Verification tier:')
    last = node.index('  Acceptance:', first)
    node = node[:first] + (
        '  Implementation owner: TYPE-REFERENCE-BOOK.1.2.5 supplies the canonical tier, focused proof and exact staged admission. This duplicate intake is not a second commit owner.\n'
        '  Evidence owner: docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json;318 cases,13 source controls,17 suites/1962 and the exact two-source intake replay.\n'
    ) + node[last:]
    changes[path] = (text[:start] + node + text[end:]).encode()
    path = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
    text = (c.ROOT / path).read_text()
    old = 'Prior4 qualified with distinct accepted14/1924 replay.'
    assert text.count(old) == 1
    text = text.replace(old, 'Prior4 qualified/replayed; canonical1 dual-owner correction in type-numeric-admission/.', 1)
    assert len(text.encode()) <= 65536
    changes[path] = text.encode()
    path = 'MEMORY.md'
    text = (c.ROOT / path).read_text().replace('type-numeric-codeblocks/publish.py', 'type-numeric-codeblocks/publish_final.py')
    text += '- admission: Canonical1 rejected two changed verification owners. Whole first10142-input draft/actual readonly0 and exact candidate survive in docs/checkpoints/type-numeric-admission/. Duplicate startup87.3 now delegates to the sole numeric5 owner; no checker or runtime weakening.\n'
    changes[path] = text.encode()
    for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
        text = (c.ROOT / path).read_text()
        first = text.index('\n## ')
        end = text.index('\n## ', first + 1)
        note = ('\nCanonical1 correctly rejected formal verification declarations for both the implementation owner and its duplicate startup intake. Whole first10142-input uncommitted publication, actual readonly0 and exact rejected candidate survive in docs/checkpoints/type-numeric-admission/. The duplicate delegates to the one numeric5 owner; checker/runtime/book behavior are unchanged. Distinct final publication and canonical retry govern admission.\n')
        changes[path] = (text[:end] + note + text[end:]).encode()
    path = 'docs/checkpoints/type-numeric-codeblocks/README.md'
    text = (c.ROOT / path).read_text().replace('type-numeric-codeblocks/publish.py', 'type-numeric-codeblocks/publish_final.py')
    text += ('\n## Canonical admission correction\n\n'
        'Canonical1 rejects two changed verification declarations: numeric5 and its\n'
        'duplicate startup87.3 intake. The latter now delegates to the sole numeric5\n'
        'owner. The complete first uncommitted claim/publication/10142-input manifest,\n'
        'actual default readonly0, full modes and rejected staged candidate survive in\n'
        'docs/checkpoints/type-numeric-admission/. Original publication artifacts stay\n'
        'whole; they are a draft epoch, without a fictional Git revision. The distinct\n'
        'final publication includes that recovery and actual owner RED/GREEN controls.\n'
        'The checker and runtime remain unchanged. See the existing canonical fact\n'
        'docs/knowledge/task-verification-single-owner.md.\n')
    changes[path] = text.encode()
    p.write('repair.json.gz', dict(before={path: c.read(path) for path in changes},
        after={path: c.encode(raw) for path, raw in changes.items()}, producer=c.read(p.PREFIX + 'repair.py'),
        scope='Remove the duplicate formal declaration; retain its evidence under the sole numeric5 implementation owner. '
              'Record the actual rejected admission and point to a distinct final publication. No code/checker/book changes.'))
    for path, raw in changes.items():
        (c.ROOT / path).write_bytes(raw)
    print('Delegated duplicate intake to sole numeric5 owner; before/after retained')


if __name__ == '__main__':
    main()

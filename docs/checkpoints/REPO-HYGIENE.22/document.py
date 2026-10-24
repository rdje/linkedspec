"""One-shot update of the latest cleanup record, current fact header and example."""
import re
import common as c
import book

CARD = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
LATEST = 'docs/ARTIFACT_CLEANUP.md'


def main():
    metadata = c.load('metadata-result.json')
    paths = [book.BOOK, CARD, LATEST]
    before = {path: c.read(path) for path in paths}
    c.write_new('documentation-inputs.json.gz', dict(before=before,
        producer=c.read(c.PREFIX + 'document.py')))
    draft = {path: c.decode(packet['base64']).decode() for path, packet in before.items()}
    old = 'docs/checkpoints/REPO-HYGIENE.21/review.py'
    assert draft[book.BOOK].count(old) == 1
    draft[book.BOOK] = draft[book.BOOK].replace(old, book.MARKER, 1)
    header, body = draft[CARD].split('\n---\n', 1)
    assert header.count('date: 2026-10-23') == 1 and header.count(old) == 1
    header = header.replace('date: 2026-10-23', 'date: 2026-10-24', 1).replace(old, book.MARKER, 1)
    evidence = 'Hygiene22 retains the dated parent/Rust review with zero removals; independent population/lstat and five metadata denials pass. Metadata grants no disposal authority.'
    header, count = re.subn(r'^evidence_update_2026_10_23: .*$',
        'evidence_update_2026_10_24: "' + evidence + '"', header, count=1, flags=re.M)
    assert count == 1
    draft[CARD] = header + '\n---\n' + body
    assert len(draft[CARD].encode()) <= len(c.decode(before[CARD]['base64']))
    draft[LATEST] = '# Latest artifact cleanup\n\n- Date: ' + metadata['at_utc'] + '\n- Summary: REPO-HYGIENE.22 completed the dated non-following parent/Rust review; zero artifact removals. Verification evidence and reusable caches remain retained. Actual channels, independent population/metadata checks and controls are retained under docs/checkpoints/REPO-HYGIENE.22/.\n'
    for path, text in draft.items():
        c.source(path).write_text(text)
    c.write_new('documentation.json.gz', dict(before=before,
        after={path: c.read(path) for path in paths},
        knowledge_byte_delta=len(draft[CARD].encode()) - len(c.decode(before[CARD]['base64']))))
    print('Latest cleanup, maintenance example and bounded current Knowledge header updated.')


if __name__ == '__main__':
    main()

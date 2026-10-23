"""Canonical maintenance example and its rendered source marker."""
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
MARKER = 'docs/checkpoints/REPO-HYGIENE.21/review.py'


def main():
    import re
    import common as c
    import context
    paths = [BOOK,'docs/ARTIFACT_CLEANUP.md',
        'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
        'docs/knowledge/selected-consumer-proof-input-closure-gap.md',
        'docs/knowledge/perl-method-assignment-required-capture.md']
    before = {path:c.read(path) for path in paths}
    c.write_new('documentation-inputs.json.gz',dict(context=context.snapshot(),
        producer=c.read(c.PREFIX+'document.py'),before=before))
    draft = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    old = 'docs/checkpoints/REPO-HYGIENE.11-review.py'
    assert draft[BOOK].count(old) == 1
    draft[BOOK] = draft[BOOK].replace(old,MARKER,1)
    historical = 'Historical at 1e6096435 with original live claim: bash tools/run_python_project_data.sh docs/checkpoints/type-deferred-indexed-writes/publish4.py.'
    for path in paths[3:]:
        draft[path],count = re.subn(r'^reverify: .*$', 'reverify: "'+historical+'"',draft[path],count=1,flags=re.M)
        assert count == 1
    card = paths[2]
    draft[card] = draft[card].replace('date: 2026-10-22','date: 2026-10-23',1)
    draft[card] = draft[card].replace('docs/checkpoints/REPO-HYGIENE.20/review.py',MARKER,1)
    evidence = 'Hygiene21 retains dated22830 parent rows, zero removals; fresh/lstat/traversal proof and four reader denials pass. Whole accepted12 custody precedes writes. Metadata grants no disposal authority.'
    draft[card],count = re.subn(r'^evidence_update_2026_10_22: .*$',
        'evidence_update_2026_10_23: "'+evidence+'"',draft[card],count=1,flags=re.M)
    assert count == 1
    delta = sum(len(draft[path].encode())-len(c.decode(before[path]['base64'])) for path in paths[2:])
    assert delta <= 0, delta
    for path in paths[2:]:
        assert draft[path].split('\n---\n',1)[1] == c.decode(before[path]['base64']).decode().split('\n---\n',1)[1]
    metadata = c.load('metadata-result.json')
    draft[paths[1]] = '# Latest artifact cleanup\n\n- Date: '+metadata['at_utc']+'\n- Summary: REPO-HYGIENE.21 completed the dated non-following parent/Rust review; zero removals. All verification evidence and reusable caches remain retained. Actual channels, independent metadata checks and controls are retained under docs/checkpoints/REPO-HYGIENE.21/.\n'
    for path,text in draft.items():
        c.source(path).write_text(text)
    c.write_new('documentation.json.gz',dict(before=before,
        after={path:c.read(path) for path in paths},knowledge_byte_delta=delta,
        scope='Only current reverify headers/date and bounded metadata evidence change; all Knowledge questions and historical bodies remain exact. The public book uses the current readonly retention example.'))
    print('Maintenance documentation PASS; Knowledge byte delta',delta)


if __name__ == '__main__':
    main()

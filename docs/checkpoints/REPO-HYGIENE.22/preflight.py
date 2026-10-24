"""One-shot live-claim intersection census before shared documentation changes."""
import json
import common as c

PLANNED = ['CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'MEMORY.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
    'docs/tasks/REPO-HYGIENE.md', 'docs/ARTIFACT_CLEANUP.md',
    'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md']


def main():
    inputs = {}
    hits = []
    for file in sorted((c.ROOT / 'docs/claims').glob('*.json')):
        path = file.relative_to(c.ROOT).as_posix()
        inputs[path] = c.read(path)
        value = json.loads(c.decode(inputs[path]['base64']))
        for claim in value['claims']:
            leg = claim['durability']
            if leg['status'] == 'checked' and leg['mode'] == 'live':
                shared = sorted(set(PLANNED) & {item['path'] for item in leg['inputs']})
                if shared:
                    hits.append(dict(record=path, claim=claim['name'], paths=shared))
    c.write_new('preflight.json.gz', dict(base=c.BASE, planned=PLANNED,
        claim_inputs=inputs, live_intersections=hits, producer=c.read(c.PREFIX + 'preflight.py')))
    assert not hits, hits
    print('Shared-document live-claim census PASS; no preservation intersection.')


if __name__ == '__main__':
    main()

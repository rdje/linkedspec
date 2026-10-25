"""Retain the live-claim census before Rust/runtime and shared-document changes."""
import json
import common as c
import epoch

PLANNED = ['CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'MEMORY.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'docs/knowledge/rust-single-index-read-bypasses-typed-binding.md',
    'docs/knowledge/write-vivification-rust-runtime.md',
    'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md']


def main():
    planned = sorted(set(PLANNED + epoch.rust_paths()))
    inputs = {}
    intersections = []
    for file in sorted((c.ROOT / 'docs/claims').glob('*.json')):
        path = file.relative_to(c.ROOT).as_posix()
        inputs[path] = c.read(path)
        value = json.loads(c.decode(inputs[path]['base64']))
        for claim in value['claims']:
            leg = claim['durability']
            if leg['status'] == 'checked' and leg['mode'] == 'live':
                shared = sorted(set(planned) & {item['path'] for item in leg['inputs']})
                if shared:
                    intersections.append(dict(record=path, claim=claim['name'], paths=shared))
    c.write_new('preflight.json.gz', dict(base=c.BASE, planned=planned, claim_inputs=inputs,
        live_intersections=intersections, producer=c.read(c.PREFIX + 'preflight.py')))
    print(json.dumps(dict(live_intersections=intersections), sort_keys=True))


if __name__ == '__main__':
    main()

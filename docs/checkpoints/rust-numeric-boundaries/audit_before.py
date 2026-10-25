"""Retain the reviewed boundary and actual live-claim intersection census."""
import json
import subprocess
import common as c


def main():
    selected = ['docs/knowledge/rust-large-number-conversion-defect.md',
        'rust/linkedspec-core/src/types.rs','rust/Cargo.toml',
        'rust/linkedspec-runtime/src/engine.rs','rust/linkedspec-runtime/src/runtime.rs',
        'rust/linkedspec-runtime/src/spec_parser.rs',
        'rust/linkedspec-runtime/src/staged_parser_registry.rs']
    claims = subprocess.check_output(['git','ls-files','docs/claims'],cwd=c.ROOT,
        text=True).splitlines()
    records, intersections = {}, []
    for name in claims:
        if not name.endswith('.json'):
            continue
        packet = c.read(name)
        record = json.loads(c.decode(packet['base64']))
        records[name] = packet
        for claim in record.get('claims',[]):
            durability = claim.get('durability',{})
            hits = [row['path'] for row in durability.get('inputs',[])
                if row.get('path') in selected]
            if hits and durability.get('mode') != 'historical':
                intersections.append(dict(path=name,claim=claim.get('name'),
                    mode=durability.get('mode'),hits=hits))
    assert not intersections
    supplied = c.context(selected+[c.PREFIX+'AUDIT.md',
        c.PREFIX+'conversion-census.json.gz',c.PREFIX+'conversion-census-inputs.json.gz'])
    c.save('audit-before.json.gz',dict(context=supplied,claims=records,
        nonhistorical_intersections=intersections,
        scope='Actual complete tracked claim namespace before the listed mutable source/fact edits. Historical inputs retain original accepted epochs; zero current/live intersections with these seven paths. Manual consumer audit is retained verbatim, not promoted into a complete execution-coverage claim.'))
    assert c.unchanged(supplied['inputs'])
    print('Pre-repair audit and complete claim census retained; no nonhistorical input intersection.')


if __name__ == '__main__':
    main()

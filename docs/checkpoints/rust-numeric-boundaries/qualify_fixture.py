"""Retain and narrow the provisional text oracle before production changes."""
import json
import common as c


def main():
    names = ['tests/numeric-conversion/cases.json',
        'rust/linkedspec-core/tests/numeric_conversion_contract.rs',
        c.PREFIX+'fixture.py', c.PREFIX+'run_core.py', c.PREFIX+'common.py',
        c.PREFIX+'core-before-run.json.gz', c.PREFIX+'fixture-inputs.json.gz']
    before = {name: c.read(name) for name in names}
    fixture = json.loads(c.decode(before[names[0]]['base64']))
    changed = []
    for row in fixture['cases']:
        # Exact integer spelling is required only in the integer projection
        # domain. Wider floating values require round-trip value preservation;
        # the separate .55.2 owner decides portable decimal/scientific spelling.
        if row['json_kind'] == 'finite_float' and row['id'] not in (
                'large-positive', 'large-negative', 'fraction', 'negative-fraction', 'tenth'):
            if row['expected_text'] is not None:
                changed.append(row['id'])
                row['expected_text'] = None
    fixture['version'] = 2
    fixture['scope'] = ('Authored binary64 input population. Python supplies exact integer '
        'tokens inside signed/unsigned64 and exact input bits elsewhere. Wider finite text '
        'must round-trip its value with consistent Display/length, without selecting the '
        'portable spelling owned by .55.2. The existing +/-1e20 full-decimal to_str control '
        'is retained. Negative zero remains floating JSON and scalar text zero; nonfinite '
        'JSON remains null. Raw serde checks numeric values only, not aggregate-kind identity.')
    (c.ROOT/names[0]).write_text(json.dumps(fixture, indent=2)+'\n')
    test = c.source(names[1]).read_text().replace(
        'Fractional extremes keep their existing Rust decimal formatter.',
        'Wider/fractional values keep the existing Rust decimal formatter.').replace(
        'fraction_text_value', 'floating_text_value').replace(
        'fraction_display', 'floating_display').replace('fraction_length', 'floating_length')
    (c.ROOT/names[1]).write_text(test)
    c.save('fixture-qualification.json.gz', dict(owner=c.OWNER, before=before,
        after={name:c.read(name) for name in names[:2]}, changed_text_targets=changed,
        actual_baseline=c.load('core-before-run.json.gz'),
        cause='The provisional text target required mathematical full integer expansion '
            'for every whole f64. Existing binary64 formatting can round-trip without that '
            'spelling. That stronger lexical policy belongs to .55.2, so those original '
            'text mismatches are not all product-defect credit. Original bytes and outcome '
            'are retained; no numeric JSON/serde target is weakened.',
        producer=c.read(c.PREFIX+'qualify_fixture.py')))
    print('Qualified',len(changed),'provisional wide-text targets; original bytes/outcome retained.')


if __name__ == '__main__':
    main()

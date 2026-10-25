"""Retain provisional instrument limits before complete post-repair proof."""
import json
import common as c


def main():
    names = ['tests/numeric-conversion/programs.json',
        'rust/linkedspec-runtime/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_bridge_contract.rs']
    before = {name:c.read(name) for name in names}
    fixture = json.loads(c.decode(before[names[0]]['base64']))
    row = next(row for row in fixture['cases'] if row['id']=='write/32/below')
    assert '4294967295]' in row['source']
    row['source'] = row['source'].replace('4294967295]',
        '4294967295.999999523162841796875]')
    row['expected'] = {'error':{'code':'nested_write_segment_invalid',
        'reason':'fractional_number'}}
    fixture['version'] = 2
    (c.ROOT/names[0]).write_text(json.dumps(fixture,indent=2)+'\n')
    test = c.source(names[1]).read_text().replace('("below",below,true)',
        '("below",below,below.fract() == 0.0)')
    assert test != c.decode(before[names[1]]['base64']).decode()
    (c.ROOT/names[1]).write_text(test)
    c.save('instrument-corrections.json.gz',dict(before=before,
        after={name:c.read(name) for name in names},
        producer=c.read(c.PREFIX+'instrument_corrections.py'),
        original_bridge=c.load('bridge-before-run.json.gz'),
        bridge_cause='The actual first instrument compiled a generic dispatch_span inside '
            'return; compiler.rs::validate_progressive_span_dispatch_contract correctly '
            'rejected it before any payload execution. The corrected source uses the '
            'existing exclusive assignment form. No product-RED credit from that zero-row run.',
        architecture_cause='The adjacent f64 below 2^32 is fractional; the provisional '
            'program builder truncated it to an integer and the metadata expectation '
            'accepted it. Correct the unexecuted 32-bit target; the actual 64-bit baseline '
            'population/outcomes stay unchanged. No 32-bit execution is claimed.',
        provisional_core_after='The first after runner failed to enroll new untracked '
            'numeric.rs in its primary source packet. Keep that successful numeric run '
            'provisional; fresh complete run_suite inputs must precede accepted execution. '
            'Do not silently backfill the old packet.'))
    print('Instrument limits retained; unexecuted32-bit neighboring-float oracle corrected.')


if __name__ == '__main__':
    main()

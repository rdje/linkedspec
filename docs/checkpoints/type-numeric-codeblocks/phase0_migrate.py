"""Replace frozen numeric spellings with accepted-source semantic goldens."""
import json
import common as c
from phase0_goldens import TEST, FIXTURE_NAME, SETUP


def main():
    plan = c.load('phase0-golden-inputs.json')
    run = c.load('phase0-golden-run.json.gz')
    assert run['inputs_unchanged'] and c.read(TEST) == plan['test']
    original = json.loads(c.decode(run['runs']['original']['stdout_base64']))['rows']
    corrected = json.loads(c.decode(run['runs']['corrected']['stdout_base64']))['rows']
    assert [row['id'] for row in original if 'error' in row['observation']] == [FIXTURE_NAME]
    assert all('error' not in row['observation'] and not row['observation']['warnings'] for row in corrected)
    goldens = {row['id']: row for row in corrected}
    assert len(goldens) == len(plan['assertions'])
    assert all(row['observation'] == goldens[row['id']]['observation']
               for row in original if row['id'] != FIXTURE_NAME)
    text = c.decode(plan['test']['base64']).decode()
    changes = []
    for row in reversed(plan['assertions']):
        assert text[row['start']:row['end']] == row['before']
        actual = row['actual']
        if row['id'] == FIXTURE_NAME:
            assert actual.count('limit, 3)))') == 1
            actual = actual.replace('limit, 3)))', 'limit, 3))', 1)
        expected = goldens[row['id']]['json']
        assert '#' not in expected
        indent = row['indent']
        replacement = (indent + 'is(\n' + indent + '    evaluate_lowered_json(\n'
            + indent + '        ' + actual + ', $numeric_setup,\n' + indent + '    ),\n'
            + indent + '    q#' + expected + '#,\n' + indent + "    '" + row['id'] + "'\n"
            + indent + ');\n')
        changes.append(dict(id=row['id'], before=row['before'], after=replacement,
                            actual_before=row['actual'], actual_after=actual, expected=expected))
        text = text[:row['start']] + replacement + text[row['end']:]
    anchor = ("subtest 'emit_context_lowers_method_contracts_for_capture_and_structured_return_values' => sub {\n"
              '    plan tests => 79;\n')
    assert text.count(anchor) == 1
    setup = '\n    # Independent finite frame; goldens come from accepted frozen fragments.\n'
    setup += '    my $numeric_setup = q{' + SETUP + '};\n'
    text = text.replace(anchor, anchor + setup, 1)
    raw = text.encode()
    c.write_new('phase0-migration.json.gz', dict(producer=c.read(c.PREFIX + 'phase0_migrate.py'),
        oracle_producer=c.read(c.PREFIX + 'phase0_goldens.py'), before=plan['test'], after=c.encode(raw),
        changes=list(reversed(changes)),
        scope='Exactly21 existing numeric assertions observe execution rather than private temporary spelling. '
              'One unbalanced fixture and matching malformed frozen literal are explicitly corrected. '
              'The original error and all20 unchanged reference results remain intact. Root/subtest plans stay unchanged.'))
    (c.ROOT / TEST).write_bytes(raw)
    print('Phase0 numeric semantic assertions migrated:', len(changes), '; one malformed fixture corrected')


if __name__ == '__main__':
    main()

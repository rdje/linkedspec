"""Retain the original mistaken comparison and the canonical read-only correction."""
import json
import common as c
import context


def main():
    card = 'docs/knowledge/terse-direct-access-bare-path-atoms.md'
    sources = ['perl/LinkedSpec/ActionIR/ValueExpr.pm',
        'perl/LinkedSpec/CodeblockRuntime.pm','perl/LinkedSpec/BindingRuntime.pm']
    inputs = dict(context=context.snapshot(),producer=c.read(c.PREFIX+'qualify_key_control.py'),
        canonical=c.read(card),sources={path:c.read(path) for path in sources},
        plan=c.read(c.PREFIX+'cases.json'),observations=c.identity(c.PREFIX+'perl-baseline.json.gz'))
    c.write_new('key-control-inputs.json.gz',inputs)
    measured = c.load('perl-inputs.json.gz')['context']['inputs']
    assert measured[card] == c.identity(card)
    assert all(measured[path] == c.identity(path) for path in sources)
    text = c.decode(inputs['canonical']['base64'])
    for policy in (b'quoted string segments are hash keys',
            b'non-reserved bare path atoms are scalar array indexes',
            b'Segment\nclassification and auto-declaration remain unchanged'):
        assert policy in text
    cases = {row['id']:row for row in c.load('cases.json')['cases']}
    raw = c.load('perl-baseline.json.gz')['run']
    rows = {row['id']:row for row in json.loads(c.decode(raw['stdout_base64']))['rows']}
    chosen = rows['read-dynamic-quoted-key']
    literal = rows['read-quoted-key']
    assert cases['read-dynamic-quoted-key']['requested_value'] == 'key'
    for route in ('native','generated'):
        value = chosen[route]
        assert value['completed'] and not value['exception'] and not value['last_error']
        assert not value['warnings'] and not value['stdout'] and value['value'] is None
        assert literal[route]['value'] == 'key'
    dump = chosen['native']['dump']
    assert '$__ls_read_index = $chosen_index;' in dump
    assert 'ref($__ls_read_value) eq "ARRAY"' in dump
    assert '$__ls_read_value->[$__ls_read_index] : undef' in dump
    c.write_new('key-control-qualification.json',dict(id='read-dynamic-quoted-key',
        original_comparison_target='key',qualified_current_control_value=None,
        classification='Original finite-grid expectation error; current ordinary Perl behavior follows its existing authored array-index branch.',
        reason='A bare selector variable is an ordinary scalar array index. It is not a quoted key segment. The retained harray receiver fails that guarded ARRAY check and yields null; the literal quoted-key twin yields key.',
        canonical=card,source_owner='perl/LinkedSpec/ActionIR/ValueExpr.pm::_emit_guarded_direct_read_expr',
        limits='Qualifies this original ordinary-Perl control only; actual observations and the original plan/producer remain unchanged. No dynamic-string-key extension, deferred-read equivalence, negative implementation or new portable policy is admitted.'))
    print('Control resolved: authored bare scalar selects the guarded ARRAY branch; null matches current ordinary Perl contract. Original mistaken target and all observations retained.')


if __name__ == '__main__':
    main()

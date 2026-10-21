"""Admit the already fixed value population into ordinary JSON-strict native/fresh tests."""
import common as c
import context


def main():
    candidate = c.load('candidate1-run.json.gz')
    assert candidate['inputs_unchanged'] and not candidate['failures']
    plan = c.load('cases.json')
    path = 't/scalar_numeric_contract.t'
    before = c.read(path)
    text = c.decode(before['base64']).decode()
    old = 'qw(cases effects stability receiver-invalid terminals pipelines)'
    assert text.count(old) == 1
    text = text.replace(old, 'qw(cases effects stability receiver-invalid terminals pipelines sort-kinds)', 1)
    old_source = '            my $source = ($case->{functions} // \'\') . "Top: /x/\\n I { $case->{body} }\\n";'
    assert text.count(old_source) == 1
    new_source = '            my $source = $case->{source}\n                // (($case->{functions} // \'\') . "Top: /x/\\n I { $case->{body} }\\n");'
    text = text.replace(old_source, new_source, 1)
    supplied = context.snapshot()
    c.write_new('permanent-inputs.json.gz', supplied)
    target = 'tests/numeric-codeblocks/sort-kinds.json'
    with (c.ROOT / target).open('xb') as output:
        output.write(c.source(c.PREFIX + 'cases.json').read_bytes())
    (c.ROOT / path).write_text(text)
    (c.ROOT / path).chmod(before['mode'])
    c.write_new('permanent.json.gz', dict(producer=c.read(c.PREFIX + 'permanent.py'),
        path=path, before=before, after=c.read(path), fixture=c.read(target),
        kind_test=c.read('t/sorted_value_kinds_perl.t'), cases=len(plan['cases']),
        scope='The fixed value plan is copied byte-for-byte. Existing JSON-strict native/fresh runner gains one fixture and explicit full-source support for the four implicit-accumulator cases; previous source construction stays unchanged for all existing fixtures. The independent BindingRuntime test checks flags, lexical order, clone kinds and source/result independence.'))
    assert c.source(target).read_bytes() == c.source(c.PREFIX + 'cases.json').read_bytes()
    print('Permanent coverage:', len(plan['cases']), 'unchanged native/fresh cases plus direct flags/clone/source-independence tests')


if __name__ == '__main__':
    main()

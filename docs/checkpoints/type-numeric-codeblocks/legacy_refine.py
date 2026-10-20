"""Retain the first successor actor and correct its Perl call/setup details."""
import common as c


def main():
    actor_path = c.PREFIX + 'legacy_consumers.py'
    while_path = 't/codeblock_while_perl.t'
    scalar_path = 't/actionir_scalar_receiver_required_capture.t'
    paths = (actor_path, while_path, scalar_path)
    before = {path: c.read(path) for path in paths}
    syntax = c.run(['perl', '-c', '-Iperl', while_path])
    assert syntax['returncode'] == 0
    assert b'Useless use of single ref constructor' in c.decode(syntax['stderr_base64'])
    bad = ' subtest ($case->{current_name} // $case->{id}) => sub {'
    good = ' my $case_name = $case->{current_name} // $case->{id};\n subtest $case_name => sub {'
    text = c.decode(before[while_path]['base64']).decode()
    assert text.count(bad) == 1
    after = {while_path: text.replace(bad, good, 1).encode()}
    require = "require './t/lib/LinkedSpecTest/EmittedValues.pm';"
    setup = 'require LinkedSpec::Numeric;\n' + require
    text = c.decode(before[scalar_path]['base64']).decode()
    assert text.count(require) == 1
    after[scalar_path] = text.replace(require, setup, 1).encode()
    actor = c.decode(before[actor_path]['base64']).decode()
    assert actor.count(repr(bad)) == 1 and actor.count(require) == 1
    actor = actor.replace(repr(bad), repr(good), 1).replace(require, setup, 1)
    after[actor_path] = actor.encode()
    c.write_new('legacy-refinement.json.gz', dict(before=before,
        after={path: c.encode(raw) for path, raw in after.items()}, syntax_before=syntax,
        producer=c.read(c.PREFIX + 'legacy_refine.py'),
        scope='Original applied proposal/actor remain intact. A named lexical avoids single-argument '
              'subtest parsing; the numeric fragment observer explicitly loads its runtime dependency. '
              'Warning settings are unchanged.'))
    for path, raw in after.items():
        (c.ROOT / path).write_bytes(raw)
    print('Successor call form and numeric observer setup corrected; first advisory retained')


if __name__ == '__main__':
    main()

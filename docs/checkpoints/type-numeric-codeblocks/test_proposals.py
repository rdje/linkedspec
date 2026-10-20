"""Add recurring independent public numeric cases to the existing contract suite."""
import subprocess
import common as c


def main():
    path = 't/scalar_numeric_contract.t'
    before = c.read(path)
    assert c.decode(before['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
    donor = 't/callable_codeblock_literal_contract.t'
    source = (c.ROOT / donor).read_text()
    start = source.index("subtest 'with exposes the current scoped value to callable dispatch'")
    end = source.index("subtest 'with restores a function binding frame", start)
    block = source[start:end]
    block = block.replace('with exposes the current scoped value to callable dispatch',
        'scalar numeric calls and receivers compose inside deferred codeblocks')
    a = block.index('    my $path = ')
    b = block.index('    my $json = ', a)
    setup = r'''    my @cases;
    foreach my $name (qw(cases effects stability receiver-invalid)) {
        my $path = File::Spec->catfile($repo_root, 'tests', 'numeric-codeblocks', $name . '.json');
        open my $fh, '<:raw', $path or die "Could not read $path: $!";
        my $fixture = JSON::PP->new->utf8->decode(do { local $/; <$fh> });
        close $fh or die "Could not close $path: $!";
        push @cases, @{$fixture->{cases}};
    }
    my $fixture = {cases => \@cases};
'''
    block = block[:a] + setup + block[b:]
    block = block.replace('ScopedWithContract', 'NumericCodeblockContract')
    block = block.replace('scoped-with.spec', 'numeric-codeblocks.spec')
    text = c.decode(before['base64']).decode()
    assert text.count('done_testing;') == 1
    after = text.replace('done_testing;', block + 'done_testing;', 1).encode()
    c.write_new('test-proposals.json.gz', dict(path=path, before=before, after=c.encode(after),
        donor=c.read(donor), producer=c.read(c.PREFIX + 'test_proposals.py'),
        scope='Public behavior checks use the four independent fixture populations and preserve native/fresh '
              'generated values, typed diagnostic causes, warning discipline and healthy stdout.'))
    (c.ROOT / path).write_bytes(after)
    print('Recurring numeric contract test updated with all four fixed fixture populations')


if __name__ == '__main__':
    main()

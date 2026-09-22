use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../perl";
use JSON::PP ();
use Test::More;
use LinkedSpec ();

sub read_text {
    open my $fh, '<:encoding(UTF-8)', $_[0] or die "read $_[0]: $!";
    local $/;
    return <$fh>;
}

sub render_node {
    my ($node) = @_;
    return $node->{kind} eq 'list'
        ? '(' . join(' ', map { render_node($_) } @{$node->{items}}) . ')'
        : $node->{lexeme};
}

my $json = JSON::PP->new->canonical;
my $contract = $json->decode(read_text("$Bin/../tests/sexpr-document-v1/contract.json"));
my $source = read_text("$Bin/../specs/SExprDocumentV1.spec");
my @cases = @{$contract->{cases}};
is(scalar(@cases), 37, 'all independently authored contract cases are present');
my ($reuse) = grep { $_->{id} eq 'reuse_after_rejection' } @cases;
ok($reuse, 'contract supplies an independent reuse expectation');

my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
my $summary = $descriptor->{meta}{action_rewriter_migration};
is($summary->{language_agnostic_ready_ratio}, '1.0000', 'grammar is ActionIR ready');
is($summary->{language_agnostic_blocked_rule_count} || 0, 0, 'no blocked rules');
is($summary->{compatibility_surface_rule_count} || 0, 0, 'no compatibility surface');
my $parser = LinkedSpec::Get(\$source);
ok(ref($parser) eq 'CODE', 'compile one reusable document parser');

for my $case (@cases) {
    subtest $case->{id} => sub {
        my $input = $case->{input};
        my $value = eval { $parser->(\$input) };
        my $error = $@;
        if ($case->{outcome} eq 'accept') {
            is($error, '', 'no exception');
            # JSON equality also distinguishes numeric scalars from string lexemes.
            is($json->encode($value), $json->encode($case->{expected}), 'exact authored tree');
            my $rendered = join("\n", map { render_node($_) } @{$case->{expected}{forms}});
            my $again = eval { $parser->(\$rendered) };
            is($@, '', 'token-preserving serialization parses');
            is($json->encode($again), $json->encode($case->{expected}), 'token spelling round trip');
        } else {
            is(ref($error), 'LinkedSpec::RuntimeExitNow', 'typed grammar rejection');
            is(ref($error) ? $error->{status} : undef, 1, 'status 1');
            ok(!defined($value), 'no accepted partial document');
            my $next = $reuse->{input};
            my $again = eval { $parser->(\$next) };
            is($@, '', 'same compiled parser accepts independent input after rejection');
            is($json->encode($again), $json->encode($reuse->{expected}), 'no failed-input state leaks');
        }
    };
}

subtest 'EOF alone cannot establish full recognition' => sub {
    my $unsafe = $source;
    my $removed = ($unsafe =~ s/ -> Invalid \{ exit_now\(1\) \}\n//g);
    is($removed, 2, 'mutation removes exactly the two rejecting edges');
    my $parser = LinkedSpec::Get(\$unsafe);
    my $input = '(a) junk (b)';
    my $value = eval { $parser->(\$input) };
    is($@, '', 'mutated grammar wrongly accepts interstitial junk');
    is(pos($input), length($input), 'wrongly accepted parse reaches EOF');
    is(scalar(@{$value->{forms}}), 2, 'wrongly accepted parse retains both surrounding forms');
};

done_testing;

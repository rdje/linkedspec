use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

# TYPE-REFERENCE-BOOK.1.2.23.3.63.1 — excluded sources retain their current owner.
sub snapshot_fence_value {
    my ($value) = @_;
    return $value unless ref $value;
    return {map { $_ => snapshot_fence_value($value->{$_}) } keys %$value}
        if (reftype($value) // '') eq 'HASH';
    return [map { snapshot_fence_value($_) } @$value]
        if (reftype($value) // '') eq 'ARRAY';
    return "$value";
}

sub snapshot_fence_error {
    my ($value) = @_;
    return undef unless ref($value) || (defined($value) && length($value));
    return {class => ref($value), value => snapshot_fence_value($value)};
}

open my $fh, '<', 'tests/fixtures/free_numeric_excluded_source_ast.json' or die $!;
my $rows = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die $!;

for my $row (@$rows) {
    my $source = $row->{source};
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $ast = eval { LinkedSpec::ActionIR::AST::parse_action_expr($source) };
    my $ast_error = snapshot_fence_error($@);
    my $lowered = eval {
        LinkedSpec::call_spec_handler_subst('Value', 'return('.$source.')');
    };
    my $lower_error = snapshot_fence_error($@);
    is_deeply(
        {source => $source, ast => snapshot_fence_value($ast), ast_error => $ast_error,
            lowered => $lowered, lower_error => $lower_error, warnings => \@warnings},
        $row,
        'original source AST, lowering and diagnostics: '.$source,
    );
}

done_testing();

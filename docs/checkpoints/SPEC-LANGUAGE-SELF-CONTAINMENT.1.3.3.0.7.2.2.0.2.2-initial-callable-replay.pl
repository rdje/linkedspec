use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed reftype);

sub project_failure {
    my ($value) = @_;
    return [map { project_failure($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project_failure($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return "$value" if ref($value);
    return $value;
}

my $returned = do './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-initial-callable-probe.pl';
my $error = $@;
print JSON::PP->new->canonical->utf8->encode({returned => project_failure($returned), error => project_failure($error)});

use strict;
use warnings;
use B ();
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::BindingRuntime ();
local $/;
my $plan = JSON::PP->new->decode(<STDIN>);
my $json = JSON::PP->new->canonical->allow_nonref;
my @rows;
for my $case (@{$plan->{cases}}) {
    my $source = "Top: /x/\n I { return($case->{expression}) }\n";
    my %context;
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
    my $input = 'x';
    my $value = $parser->(\$input);
    my $encoded = $json->encode($value);
    my $flags = B::svref_2object(\$value)->FLAGS;
    push @rows, {id => $case->{id}, value_json => $encoded,
        runtime_kind => LinkedSpec::BindingRuntime::_runtime_kind($value),
        string_flag => ($flags & B::SVp_POK()) ? 1 : 0,
        integer_flag => ($flags & B::SVp_IOK()) ? 1 : 0,
        number_flag => ($flags & B::SVp_NOK()) ? 1 : 0,
        last_error => $context{last_error}};
}
print $json->encode({rows => \@rows, perl_version => "$^V", json_version => $JSON::PP::VERSION}), "\n";

use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
local $/;
my $plan = JSON::PP->new->decode(<STDIN>);
my $json = JSON::PP->new->canonical->allow_nonref;
my (@rows, $index);
for my $case (@{$plan->{cases}}) {
    my %row = (id => $case->{id});
    for my $route (qw(native generated)) {
        my ($value, $error, $output, %context, @warnings);
        {
            open my $capture, '>', \$output or die $!;
            local *STDOUT = $capture;
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            eval {
                my $source = $case->{source};
                my $input = $case->{input};
                if ($route eq 'native') {
                    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                    die 'parser missing' unless ref($parser) eq 'CODE';
                    $value = $parser->(\$input);
                } else {
                    my $emitted = LinkedSpec::emit_generated_source(\$source);
                    my $package = 'AggregateKindHistory'.++$index;
                    eval "package $package; $emitted; 1" or die $@;
                    no strict 'refs';
                    $value = &{$package.'::Execute'}(\$input);
                }
                1;
            } or $error = "$@";
        }
        $row{$route} = {value_json => $json->encode($value), error => $error,
            last_error => $context{last_error}, warnings => \@warnings, stdout => $output // ''};
    }
    push @rows, \%row;
}
print $json->encode({rows => \@rows, inc => \%INC}), "\n";

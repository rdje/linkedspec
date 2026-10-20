use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed reftype);
use LinkedSpec ();

sub data {
    my ($value) = @_;
    return $value unless ref($value);
    return $value if blessed($value) && $value->isa('JSON::PP::Boolean');
    return [map { data($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map { $_ => data($value->{$_}) } keys %$value}
        if (reftype($value) // '') eq 'HASH';
    die 'Unrecognized observed reference: ' . ref($value);
}

sub detail {
    my ($error) = @_;
    return undef unless defined($error) && length("$error");
    return {class => ref($error), fields => data($error)}
        if (reftype($error) // '') eq 'HASH';
    return {class => '', text => "$error"};
}

local $/;
my $plan = JSON::PP->new->utf8->decode(<STDIN>);
my @rows;
my $index = 0;
foreach my $case (@{$plan->{cases}}) {
    my $source = ($case->{functions} // '') . "Top: /x/\n I { $case->{body} }\n";
    my %row = (id => $case->{id});
    foreach my $route (qw(descriptor native generated)) {
        my (@warnings, %context, $value, $exception, $emitted, $diagnostics);
        open my $diagnostic_fh, '>', \$diagnostics or die "Capture output: $!";
        local *STDOUT = $diagnostic_fh;
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        my $ok = eval {
            if ($route eq 'descriptor') {
                my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%context);
                die "Descriptor did not build\n" unless ref($descriptor) eq 'HASH';
                my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
                $value = {map { $_ => data($metadata->{$_}) }
                    qw(canonical_action_ir_nodes canonical_action_ir_fallback_count raw_perl_dependency_count)};
            } elsif ($route eq 'native') {
                my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                die "Native parser did not build\n" unless ref($parser) eq 'CODE';
                my $input = 'x';
                $value = $parser->(\$input);
            } else {
                $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'scoped-with.spec');
                my $package = 'ScopedWithProbe' . $index++;
                eval "package $package; $emitted; 1" or die $@;
                my $input = 'x';
                no strict 'refs';
                $value = &{$package . '::Execute'}(\$input);
            }
            1;
        };
        $exception = $@ unless $ok;
        $row{$route} = {
            completed => $ok ? JSON::PP::true : JSON::PP::false,
            value => data($value), exception => detail($exception),
            last_error => data($context{last_error}),
            runtime_detail => detail($context{last_error}{detail}), warnings => \@warnings,
            stdout => $diagnostics // '',
            defined($emitted) ? (source => $emitted) : (),
        };
    }
    push @rows, \%row;
}
print JSON::PP->new->canonical->allow_nonref->encode({rows => \@rows, inc => \%INC}), "\n";

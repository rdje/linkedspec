use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed reftype);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->allow_nonref;
open my $fh, '<:raw', 'docs/checkpoints/document-pressure-restoration/numeric-calibration-target.json' or die $!;
my $target = do { local $/; $json->decode(<$fh>) };

sub plain {
    my ($value) = @_;
    return $value unless ref($value);
    return [map {plain($_)} @$value] if (reftype($value) // '') eq 'ARRAY';
    if ((reftype($value) // '') eq 'HASH') {
        return { (blessed($value) ? (class => ref($value)) : ()),
            map {$_ => plain($value->{$_})} keys %$value };
    }
    return "$value";
}

my (@rows, $serial);
for my $case (@{$target->{cases}}) {
    for my $variant (qw(fluent nested)) {
        my $body = $variant eq 'fluent' ? $case->{original}{body} : $case->{nested_body};
        my $functions = $variant eq 'fluent' ? ($case->{original}{functions} // '')
            : ($case->{nested_functions} // $case->{original}{functions} // '');
        my $source = $functions . "Top: /x/\n I { $body }\n";
        my (%context, @warnings, $value, $native_error, $native_output, $descriptor, $metadata);
        {
            open my $capture, '>', \$native_output or die $!;
            local *STDOUT = $capture;
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            eval {
                $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
                $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
                my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                die 'No native parser' unless ref($parser) eq 'CODE';
                my $input = 'x'; $value = $parser->(\$input); 1;
            } or $native_error = plain($@);
        }
        my ($emitted, $fresh, $error, $load_error, $loaded);
        {
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'numeric-calibration.spec')};
            $error = plain($@) if $@;
            my $package = 'NumericCalibration' . ++$serial;
            $loaded = defined($emitted) && eval "package $package; $emitted; 1";
            $load_error = plain($@) if $@;
            if ($loaded) {
                eval {no strict 'refs'; my $input = 'x'; $fresh = &{$package . '::Execute'}(\$input); 1}
                    or $error = plain($@);
            }
        }
        push @rows, {id => $case->{id}, variant => $variant, source => $source,
            native => $value, native_error => $native_error, native_context_error => plain($context{last_error}),
            native_output => $native_output, warnings => \@warnings, fresh => $fresh,
            loaded => $loaded ? 1 : 0, load_error => $load_error, fresh_error => $error,
            emitted => $emitted, metadata => {map {$_ => $metadata->{$_}} qw(
                language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count)}};
    }
}
print $json->encode(\@rows), "\n";

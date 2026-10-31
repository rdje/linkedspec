use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use B ();

# Inspect the actual public return slot before serialization or value coercion.
# $_[0] aliases the caller's slot; private validity is diagnostic only.
sub host_scalar_flags {
    my $sv = B::svref_2object(\$_[0]);
    my $flags = $sv->FLAGS;
    my %constants = (
        SVf_IOK => B::SVf_IOK(), SVf_NOK => B::SVf_NOK(), SVf_POK => B::SVf_POK(),
        SVp_IOK => B::SVp_IOK(), SVp_NOK => B::SVp_NOK(), SVp_POK => B::SVp_POK(),
    );
    return {perl_version => "$^V", sv_class => ref($sv), reference => ref($_[0]),
        flags => $flags, constants => \%constants,
        validity => {map { $_ => ($flags & $constants{$_}) ? 1 : 0 } keys %constants}};
}


my ($cases_path, $output_path) = @ARGV;
die 'case/output paths required' unless defined $output_path;
my $json = JSON::PP->new->canonical->ascii;
open my $in, '<', $cases_path or die $!;
my $text; { local $/; $text = <$in> }
my @rows;
sub plain_diagnostic_value {
    my ($value) = @_;
    return $value unless ref($value);
    my $kind = reftype($value) // '';
    return {map { $_ => plain_diagnostic_value($value->{$_}) } keys %$value} if $kind eq 'HASH';
    return [map { plain_diagnostic_value($_) } @$value] if $kind eq 'ARRAY';
    return "$value";
}
sub diagnostic {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    return {map { $_ => plain_diagnostic_value($error->{$_}) } grep { exists $error->{$_} }
        qw(type stage code detail summary helper_name name actual_arity expected_arity arguments_evaluated)}
        if (reftype($error) // '') eq 'HASH';
    return "$error";
}
for my $case (@{$json->decode($text)}) {
    die "probe input transport differs from authored character guards" unless length($case->{input}) == $case->{input_characters} && ord(substr($case->{input},0,1)) == $case->{leading_codepoint};
    my $source = $case->{source};
    my (%context, @warnings);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $native = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    my $build_error = diagnostic($@);
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    my $descriptor_error = diagnostic($@);
    my $meta = $descriptor->{spec}{$case->{rule} // "Value"}{meta}{action_rewriter};
    my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'definedness-numeric-calibration.spec') };
    my $emission_error = diagnostic($@);
    my $package = 'LinkedSpec::DefinednessNumericCalibration'.scalar(@rows);
    my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
    my $load_error = diagnostic($@);
    my @results;
    for my $route (['native', $native], ['fresh', $loaded ? $package->can('Execute') : undef]) {
        my $input = $case->{input};
        my $value = ref($route->[1]) eq 'CODE' ? eval { $route->[1]->(\$input) } : undef;
        my $error = ref($route->[1]) eq 'CODE' ? diagnostic($@) : undef;
        my $host_scalar = host_scalar_flags($value);
        push @results, { route => $route->[0], executed => ref($route->[1]) eq 'CODE' ? 1 : 0,
            host_scalar => $host_scalar, value => $value, error => $error, cursor => pos($input), context_error => $route->[0] eq 'native' ? diagnostic($context{last_error}) : undef };
    }
    my $substitution = eval { LinkedSpec::call_spec_handler_subst($case->{rule}, $case->{body}) };
    my $substitution_error = diagnostic($@);
    push @rows, {fixture => $case, build_error => $build_error,
        descriptor_error => $descriptor_error, emission_error => $emission_error,
        emitted => $emitted, loaded => $loaded ? 1 : 0, load_error => $load_error,
        warnings => \@warnings, results => \@results, substitution => $substitution, substitution_error => $substitution_error,
        metadata => {map { $_ => $meta->{$_} } qw(raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)} };
}
open my $out, '>', $output_path or die $!;
print {$out} $json->encode(\@rows), "\n";
close $out or die $!;
print 'recorded ', scalar(@rows), " actual public source/result controls\n";

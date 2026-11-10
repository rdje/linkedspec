use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use Digest::SHA qw(sha256_hex);
use File::Spec ();
use Cwd qw(getcwd);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

sub snapshot {
    my ($value) = @_;
    return $value unless ref $value;
    return {map { $_ => snapshot($value->{$_}) } keys %$value} if (reftype($value) // '') eq 'HASH';
    return [map { snapshot($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return "$value";
}
sub error_value {
    my ($value) = @_;
    return undef unless ref($value) || (defined($value) && length($value));
    return {class => ref($value), value => snapshot($value)};
}
my $json = JSON::PP->new->canonical->allow_nonref;
open my $fh, '<:raw', 'tests/fixtures/count_result_guard_excluded_ast.json' or die $!;
my $expected = $json->decode(do { local $/; <$fh> });
close $fh or die $!;
my @rows;
for my $row (@$expected) {
    my ($ast, $ast_error, $lowered, $lower_error, @warnings);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    $ast = eval { LinkedSpec::ActionIR::AST::parse_action_expr($row->{source}) };
    $ast_error = error_value($@);
    $lowered = eval { LinkedSpec::call_spec_handler_subst('Value', 'return('.$row->{source}.')') };
    $lower_error = error_value($@);
    push @rows, {source => $row->{source}, ast => snapshot($ast), ast_error => $ast_error,
        lowered => $lowered, lower_error => $lower_error, warnings => \@warnings};
}
my $target = 'count().take(1).with(){return("x")}';
my $spec = "Top::\n I { return($target) }\n";
my (%ctx, $value, $native_exception, $fresh, $fresh_exception);
my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%ctx);
if ($parser) { my $input = 'x'; eval { $value = $parser->(\$input); 1 } or $native_exception = "$@"; }
my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter} || {};
my $generated = LinkedSpec::emit_generated_source(\$spec, source_identity => 'excluded-count-source.spec');
my $loaded = eval "package ExcludedCountFenceProbe; $generated; 1";
my $load_error = "$@";
if ($loaded) { my $input = 'x'; eval { $fresh = ExcludedCountFenceProbe::Execute(\$input); 1 } or $fresh_exception = "$@"; }
my $module = $INC{'LinkedSpec/ActionIR/MethodLowering.pm'};
open my $module_fh, '<:raw', $module or die $!;
my $module_bytes = do { local $/; <$module_fh> };
close $module_fh or die $!;
print $json->encode({rows => \@rows,
    module => {path => File::Spec->abs2rel($module, getcwd()), sha256 => sha256_hex($module_bytes)},
    excluded => {source => $spec, native => $value, native_error => snapshot($ctx{last_error}),
        native_exception => $native_exception, fresh => $fresh, fresh_exception => $fresh_exception,
        generated => $generated, loaded => $loaded ? 1 : 0, load_error => $load_error,
        metadata => {map { $_ => $meta->{$_} } qw(language_agnostic_action_ir_ready raw_perl_dependency_count unresolved_helper_count unresolved_helpers)}},
}), "\n";

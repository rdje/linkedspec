use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use IO::Compress::Gzip qw(gzip $GzipError);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my @cases;
if (@ARGV) {
    my $fixture = shift @ARGV;
    open my $fh, '<:raw', $fixture or die $!;
    my $rows = $json->decode(do { local $/; <$fh> });
    close $fh or die $!;
    @cases = map { [$_->{id}, $_->{body}, $_->{seed_hash}, $_->{source}] } @$rows;
}
my $module_directory = shift @ARGV;

sub error_value {
    my ($error) = @_;
    return undef unless defined($error) && (ref($error) || length($error));
    if ((reftype($error) // '') eq 'HASH') {
        my %result = map { $_ => error_value($error->{$_}) }
            grep { exists $error->{$_} } qw(type code stage detail summary helper_name phase rule_label);
        $result{class} = ref($error) if ref($error) ne 'HASH';
        return \%result;
    }
    return "$error";
}

my @observations;
for my $case (@cases) {
    my ($id, $body, $seed_hash, $full_source) = @$case;
    die 'unsafe authored case id' unless $id =~ /\A[a-z0-9_]+\z/;
    my $source = $full_source // "Value:: I {$body}";
    my (@warnings, %context, %row);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    $row{id} = $id;
    $row{body} = $body;
    $row{source} = $source;
    $row{lowered} = eval { LinkedSpec::call_spec_handler_subst('Value', $body) };
    $row{lowering_error} = error_value($@);
    my $descriptor = eval { LinkedSpec::Get(\$source, return_descriptor => 1) };
    $row{descriptor_error} = error_value($@);
    my $meta = $descriptor->{spec}{Value}{meta}{action_rewriter} // {};
    $row{metadata} = {map { $_ => $meta->{$_} } qw(language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count)};
    my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    $row{native_build_error} = error_value($@);
    $row{native_callable} = ref($parser) eq 'CODE' ? 1 : 0;
    $row{emitted_before_load} = eval { LinkedSpec::emit_generated_source(\$source,
        source_identity => 'key-count-selection-2026-11-06.spec') };
    $row{emission_error} = error_value($@);
    if (defined($module_directory) && defined($row{emitted_before_load})) {
        my $path = "$module_directory/$id.pm.gz";
        gzip \$row{emitted_before_load} => $path or die $GzipError;
        $row{module_retained_before_load} = $path;
    }
    if ($row{native_callable}) {
        my $input = 'x';
        $row{native} = eval { $parser->(\$input) };
        $row{native_error} = error_value($@ || $context{last_error});
        $row{native_cursor} = pos($input);
    }
    my $package = 'LinkedSpec::KeyCountSelection::' . $id;
    $row{loaded} = defined($row{emitted_before_load}) && eval "package $package; $row{emitted_before_load}; 1" ? 1 : 0;
    $row{load_error} = error_value($@);
    if ($row{loaded}) {
        my $input = 'x';
        $row{fresh} = eval { $package->can('Execute')->(\$input) };
        $row{fresh_error} = error_value($@);
        $row{fresh_cursor} = pos($input);
    }
    $row{warnings} = \@warnings;
    push @observations, \%row;
}
print $json->encode(\@observations), "\n";

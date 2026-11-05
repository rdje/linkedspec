use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use IO::Compress::Gzip qw(gzip $GzipError);
use LinkedSpec ();

my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my @cases = (
    ['length_compatible', 'return([length("tail").add(1),"tail".length().add(1),length(undef),length("")])'],
    ['length_free_guard', 'order="";a=length("tail").take({order=cat(order,"A");1});b=length("tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])'],
    ['length_receiver_guard', 'order="";out={order=cat(order,"S");"tail"}.length().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])'],
    ['key_count_compatible', 'return([count_keys({"k":1}).add(1),{"k":1}.count_keys().add(1),count_keys(undef)])'],
    ['key_count_free_guard', 'order="";a=count_keys({"k":1}).take({order=cat(order,"A");1});b=count_keys({"k":1}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])'],
    ['key_count_receiver_guard', 'order="";out={order=cat(order,"S");{"k":1}}.count_keys().take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])'],
);
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
    if ($row{native_callable}) {
        my $input = 'x';
        $row{native} = eval { $parser->(\$input) };
        $row{native_error} = error_value($@ || $context{last_error});
        $row{native_cursor} = pos($input);
    }
    $row{emitted_before_load} = eval { LinkedSpec::emit_generated_source(\$source,
        source_identity => 'length-selection-2026-11-05.spec') };
    $row{emission_error} = error_value($@);
    if (defined($module_directory) && defined($row{emitted_before_load})) {
        my $path = "$module_directory/$id.pm.gz";
        gzip \$row{emitted_before_load} => $path or die $GzipError;
        $row{module_retained_before_load} = $path;
    }
    my $package = 'LinkedSpec::LengthSelection::' . $id;
    $row{loaded} = defined($row{emitted_before_load}) && eval "package $package; $row{emitted_before_load}; 1" ? 1 : 0;
    $row{load_error} = error_value($@);
    if ($row{loaded}) {
        my $input = 'x';
        $row{fresh} = eval { $package->can('Execute')->(\$input) };
        $row{fresh_error} = error_value($@);
        $row{fresh_cursor} = pos($input);
    }
    if ($seed_hash && defined($row{emitted_before_load})) {
        my $seeded_package = $package . 'Seeded';
        $row{seeded_loaded} = eval "package $seeded_package; $row{emitted_before_load}; 1" ? 1 : 0;
        $row{seeded_load_error} = error_value($@);
        if ($row{seeded_loaded}) {
            {
                no strict 'refs';
                %{"${seeded_package}::4"} = (probe => 'HOST_PACKAGE');
            }
            my $input = 'x';
            $row{seeded_fresh} = eval { $seeded_package->can('Execute')->(\$input) };
            $row{seeded_error} = error_value($@);
        }
    }
    $row{warnings} = \@warnings;
    push @observations, \%row;
}
print $json->encode(\@observations), "\n";

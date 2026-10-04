use strict;
use warnings;
BEGIN {
    if ($ENV{LINKEDSPEC_SOURCE_PROVENANCE_BASELINE}) {
        my $prefix = './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0-before-';
        for my $name (qw(ScannerCore LegacyRules PrimitivePipelineRules FlowRules)) {
            require $prefix.$name.'.pm';
            my $package = $name eq 'ScannerCore' ? $name : 'Scanner/'.$name;
            $INC{'LinkedSpec/ActionIR/'.$package.'.pm'} = $prefix.$name.'.pm';
        }
    }
}
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
use Encode qw(encode);
use Digest::SHA qw(sha256_hex);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0-';
my $json = JSON::PP->new->canonical->utf8;
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $id = shift // die 'case required';
my @selected = grep { $_->{id} eq $id } @$cases;
die 'exactly one case required' unless @selected == 1;
my $case = $selected[0];
my ($public, $private, $substitution, $diagnostics, $dump, $emitted, $failure);
my ($stdout, $stderr) = ('', '');
my $entry = LinkedSpec::ActionIR::ScannerCore->can('_scan_contract_ir_events_with_provenance');
{
    open my $out, '>', \$stdout or die $!;
    open my $err, '>', \$stderr or die $!;
    local *STDOUT = $out;
    local *STDERR = $err;
    my $ok = eval {
        my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
        my $contract = {id => $case->{contract}};
        $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events($contract, $case->{action}, $deps);
        $private = $entry ? $entry->($contract, $case->{action}, $deps)
            : {events => $public, source_origins => []};
        $substitution = LinkedSpec::call_spec_handler_subst('Top', $case->{action});
        LinkedSpec::Get(\$case->{source}, dump_parser_source => 1, parser_source_ref => \$dump);
        my $descriptor = LinkedSpec::Get(\$case->{source}, return_descriptor => 1);
        $diagnostics = $descriptor->{spec}{Top}{meta}{action_rewriter};
        $emitted = LinkedSpec::emit_generated_source(\$case->{source}, source_identity => $id.'.spec');
        1;
    };
    $failure = $@ unless $ok;
}
print $json->pretty->encode({id => $id, source => $case->{source}, action => $case->{action},
    source_sha256 => sha256_hex(encode('UTF-8', $case->{source})),
    seed => $ENV{PERL_HASH_SEED}, perturb => $ENV{PERL_PERTURB_KEYS},
    public_events => $public, provenance_available => $entry ? 1 : 0, private_result => $private,
    substitution => $substitution, diagnostics => $diagnostics, dump => $dump, emitted => $emitted,
    failure => $failure, internal_stdout => $stdout, internal_stderr => $stderr});

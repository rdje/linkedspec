use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
BEGIN {
    if ($ENV{LINKEDSPEC_PIPELINE_METADATA_BASELINE}) {
        my $file = './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1-before-PrimitivePipelineRules.pm';
        require $file;
        $INC{'LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm'} = $file;
    }
}
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $json = JSON::PP->new->canonical->utf8;
my $path = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1-cases.json';
open my $file, '<:raw', $path or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $defaults = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
for my $case (@$cases) {
    subtest $case->{id} => sub {
        my %deps = %$defaults;
        $deps{build_array_pipeline_plan_from_expr} = sub { return $case->{plan} } if $case->{custom_plan};
        my $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            {id => 'split_array'}, $case->{action}, \%deps);
        my $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
            {id => 'split_array'}, $case->{action}, \%deps);
        my $event = {raw => $case->{expr}, args => {target => 'items', delimiter => '/\\,/', source => $case->{source_after}}};
        is_deeply($public, [$event, $event, $event], 'source is the independently authored normalized expression or legacy fallback');
        is_deeply($private->{events}, $public, 'private recording preserves corrected public arguments');
        is_deeply([map { $_->{source_span} } @{$private->{source_origins}}], $case->{spans}, 'existing original scalar origins survive the metadata correction');
        for my $i (0 .. $#{$private->{source_origins}}) {
            my $origin = $private->{source_origins}[$i];
            is($origin->{source}, $case->{action}, 'original Unicode/CRLF source');
            is(refaddr($origin->{event}), refaddr($private->{events}[$i]), 'origin still refers to the returned event');
        }
        ok(!grep({ join(',', sort keys %$_) ne 'args,raw' } @{$public}), 'event keys are unchanged');
    };
}
done_testing();

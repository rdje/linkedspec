use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
BEGIN {
    if ($ENV{LINKEDSPEC_BASIC_REGEX_BASELINE}) {
        my $prefix = './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-before-';
        require $prefix.'PrimitiveBasicRules.pm';
        $INC{'LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm'} = $prefix.'PrimitiveBasicRules.pm';
    }
}
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

sub private_scan {
    my ($contract, $code) = @_;
    my $entry = LinkedSpec::ActionIR::ScannerCore->can('_scan_contract_ir_events_with_provenance');
    return $entry->($contract, $code, $deps) if $entry;
    # The before implementation has no provenance channel. Observe its published
    # scanner and explicitly report the absent sidecar, rather than invent spans.
    return {events => LinkedSpec::ActionIR::Scanner::scan_contract_ir_events($contract, $code, $deps), source_origins => []};
}

for my $case (@$cases) {
    subtest $case->{id} => sub {
        my $contract = {id => $case->{contract}};
        my $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events($contract, $case->{action}, $deps);
        my $private = private_scan($contract, $case->{action});
        is_deeply($private->{events}, $public, 'private recording preserves complete public events');
        is_deeply([map { $_->{raw} } @{$public}], $case->{raws}, 'independent original raw occurrence list');
        my $origins = $private->{source_origins};
        is(scalar(@$origins), scalar(@{$case->{starts}}), 'each actual match has one private origin');
        is_deeply([map { $_->{source_span}{start} } @$origins], $case->{starts}, 'independently authored scalar positions');
        for my $i (0 .. $#$origins) {
            my $origin = $origins->[$i];
            is($origin->{source}, $case->{action}, 'complete original source frame');
            is(refaddr($origin->{event}), refaddr($private->{events}[$i]), 'origin points at exact event object');
            is_deeply($origin->{source_span}, {start => $case->{starts}[$i], end => $case->{starts}[$i]+length($case->{raws}[$i])}, 'original raw scalar span');
            is(substr($origin->{source}, $origin->{source_span}{start}, $origin->{source_span}{end}-$origin->{source_span}{start}), $origin->{event}{raw}, 'span retrieves original event bytes');
        }
        ok(!grep({ exists $_->{source_span} || exists $_->{source_origins} } @{$private->{events}}), 'source fields stay outside public events');
    };
}

subtest 'empty basic regex scans preserve existing behavior' => sub {
    for my $case (@$cases) {
        my $result=private_scan({id=>$case->{contract}},'no_helpers_here');
        is_deeply($result,{events=>[],source_origins=>[]},$case->{contract});
    }
};
done_testing();

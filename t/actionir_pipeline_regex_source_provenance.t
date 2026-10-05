use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
BEGIN {
    if ($ENV{LINKEDSPEC_PIPELINE_REGEX_BASELINE}) {
        my $file = './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.0-before-PrimitivePipelineRules.pm';
        require $file;
        $INC{'LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm'} = $file;
    }
}
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $json = JSON::PP->new->canonical->utf8;
my $path = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0-cases.json';
open my $file, '<:raw', $path or die $!;
my $case = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my @contracts = grep { $_->{family} eq 'regex' } @{$case->{contracts}};

for my $contract (@contracts) {
    subtest $contract->{id} => sub {
        my $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            {id => $contract->{id}}, $case->{action}, $deps);
        my (@constructed, $private);
        {
            my $recorder = \&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event = sub {
                push @constructed, [$_[0], $_[0]{args}];
                return $recorder->(@_);
            };
            $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                {id => $contract->{id}}, $case->{action}, $deps);
        }
        my @expected = map { {raw => $_->{raw}, args => $_->{args}} } @{$contract->{events}};
        is_deeply($public, \@expected, 'independently authored original arguments and occurrences');
        is_deeply($private->{events}, \@expected, 'private channel preserves the public event contract');
        my $origins = $private->{source_origins};
        is(scalar(@$origins), scalar(@expected), 'each selected regex occurrence has an origin');
        is_deeply([map { $_->{source_span} } @$origins],
            [map { $_->{source_span} } @{$contract->{events}}], 'literal scalar intervals distinguish repeated and quoted text');
        is(scalar(@constructed), scalar(@expected), 'original constructors invoke the recorder once per event');
        for my $i (0 .. $#$origins) {
            my $origin = $origins->[$i];
            is($origin->{source}, $case->{action}, 'complete original Unicode/CRLF source');
            is(refaddr($origin->{event}), refaddr($private->{events}[$i]), 'origin retains the returned event object');
            is(refaddr($constructed[$i][0]), refaddr($private->{events}[$i]), 'recording retains the constructor event object');
            is(refaddr($constructed[$i][1]), refaddr($private->{events}[$i]{args}), 'recording retains the original argument object');
            my $span = $origin->{source_span};
            is(substr($case->{action}, $span->{start}, $span->{end} - $span->{start}),
                $origin->{event}{raw}, 'source interval retrieves the original raw expression');
        }
        ok(!grep({ join(',', sort keys %$_) ne 'args,raw' } @{$private->{events}}), 'private metadata does not extend public events');
    };
}

subtest 'empty regex scans do not create origins' => sub {
    for my $contract (@contracts) {
        my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
            {id => $contract->{id}}, 'no_pipeline_helpers', $deps);
        is_deeply($result, {events => [], source_origins => []}, $contract->{id});
    }
};

subtest 'rejected calls retain empty original results' => sub {
    for my $entry ([push => 'push(items, input)'], [set_value => 'set(value)'],
                   [trim_each => 'trim_each()'], [split_array => 'split(items)']) {
        my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
            {id => $entry->[0]}, $entry->[1], $deps);
        is_deeply($result, {events => [], source_origins => []}, $entry->[0]);
    }
};

done_testing();

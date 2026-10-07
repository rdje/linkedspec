use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $baseline = $ENV{LINKEDSPEC_MEMBERSHIP_BASELINE} ? 1 : 0;
require LinkedSpec::ActionIR::SourceMembership unless $baseline;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->utf8->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

sub select_members {
    my ($source, $scan) = @_;
    # Explicit before adapter observes the original syntactic producer result.
    # It does not fabricate origins or simulate a repaired production function.
    return $scan if $baseline;
    return LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events($source, $scan);
}

for my $case (@$cases) {
    subtest $case->{id} => sub {
        my $source = $case->{source};
        my $scan = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
            {id => $case->{contract}}, $source, $deps);
        my $before = JSON::PP->new->canonical->encode($scan);
        my $selected = select_members($source, $scan);
        is(JSON::PP->new->canonical->encode($scan), $before, 'original scan is untouched');
        is($source, $case->{source}, 'original source is untouched');
        is_deeply([map { {raw => $_->{event}{raw}, args => $_->{event}{args},
                          source_span => $_->{source_span}} } @{$selected->{source_origins}}],
                  $case->{events}, 'independent original intervals, arguments and occurrence order');
        is(scalar(@{$selected->{events}}), scalar(@{$case->{events}}), 'exact selected event population');
        is(scalar(@{$selected->{source_origins}}), scalar(@{$selected->{events}}), 'selected origins remain complete');
        for my $i (0 .. $#{$selected->{events}}) {
            my $event = $selected->{events}[$i];
            my $origin = $selected->{source_origins}[$i];
            is(refaddr($event), refaddr($origin->{event}), 'actual producer event reference');
            ok(grep({ refaddr($_) == refaddr($event) } @{$scan->{events}}), 'no manufactured event');
            ok(grep({ refaddr($_) == refaddr($origin) } @{$scan->{source_origins}}), 'original origin reference');
            ok(!exists($event->{source_span}) && !exists($event->{source_origins}), 'public event has no source fields');
        }
        is(refaddr($selected), refaddr($scan), 'unchanged selection preserves result identity')
            if @{$selected->{events}} == @{$scan->{events}};
    };
}

subtest 'empty and opaque results retain identity and caller error' => sub {
    for my $events ([], {opaque => ['sentinel']}) {
        my $scan = {events => $events, source_origins => []};
        $@ = 'caller error sentinel';
        my $selected = select_members('source', $scan);
        my $error = $@;
        is(refaddr($selected), refaddr($scan), 'original result identity');
        is(refaddr($selected->{events}), refaddr($events), 'original payload identity');
        is_deeply($selected->{source_origins}, [], 'no invented origins');
        is($error, 'caller error sentinel', 'caller error restored');
    }
};

subtest 'missing and foreign origins cannot invent membership authority' => sub {
    my $source = '"set(counter,1)"';
    my $event = {raw => 'set(counter,1)', args => {source => '1', target => 'counter'}};
    for my $origins ([], [{event => $event, source => 'set(counter,1)',
                          source_span => {start => 0, end => 14}}]) {
        my $scan = {events => [$event], source_origins => $origins};
        my $selected = select_members($source, $scan);
        is(refaddr($selected), refaddr($scan), 'unowned source keeps original result');
        is(refaddr($selected->{events}[0]), refaddr($event), 'unowned event retained');
        is_deeply($selected->{source_origins}, $origins, 'no invented or paired coordinates');
    }
};

subtest 'malformed matching-source authority rejects' => sub {
    my $source = '"set(counter,1)"; set(counter,2)';
    my $scan = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'set_value'}, $source, $deps);
    for my $bad ([-1, 15], [1, 99], [2, 15]) {
        my $copy = JSON::PP->new->decode(JSON::PP->new->encode($scan));
        # JSON transport detaches references; explicitly bind this input control
        # to the transported event. This is a corruption guard, not a producer.
        $copy->{source_origins}[0]{event} = $copy->{events}[0];
        $copy->{source_origins}[0]{source_span} = {start => $bad->[0], end => $bad->[1]};
        my $ok = eval { select_members($source, $copy); 1 };
        my $error = $@;
        ok(!$ok, 'invalid authoritative span rejected');
        like($error, qr/invalid source authority/, 'exact private authority rejection');
    }
};

subtest 'copied origin event cannot authorize an equal raw event' => sub {
    my $source = '"set(counter,1)"; set(counter,2)';
    my $scan = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'set_value'}, $source, $deps);
    $scan->{source_origins}[0]{event} = {%{$scan->{events}[0]}};
    my $selected = select_members($source, $scan);
    is(refaddr($selected), refaddr($scan), 'detached reference declines source authority');
    is(refaddr($selected->{events}[0]), refaddr($scan->{events}[0]), 'no pairing by equal raw text');
};

subtest 'active classification restores caller error after lexical helper work' => sub {
    my $source = '"set(counter,1)"; set(counter,2)';
    my $scan = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'set_value'}, $source, $deps);
    require LinkedSpec::ActionIR::MethodExpr;
    my $original = \&LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges;
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges = sub {
        $@ = 'lexical helper altered error';
        return $original->(@_);
    };
    $@ = 'outer caller error';
    select_members($source, $scan);
    is($@, 'outer caller error', 'successful active selection restores the exact caller state');
};

done_testing();

use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-';
open my $file, '<:raw', $prefix.'review-cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

for my $case (grep { $_->{id} eq 'recursive' || $_->{id} eq 'arguments' } @$cases) {
    for my $contract ('case_flow', 'default_flow') {
        subtest $case->{id}.' '.$contract => sub {
            my @constructed;
            my $recorder = \&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
            my $result;
            {
                no warnings 'redefine';
                local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event = sub {
                    push @constructed, [$_[0], $_[0]{args}]; return $recorder->(@_);
                };
                $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                    {id => $contract}, $case->{action}, $deps);
            }
            my $expected = $case->{expected}{$contract};
            is_deeply($result->{events}, [map { +{raw => $_->{raw}, args => $_->{args}} } @$expected],
                      'original recursive event values and traversal');
            is_deeply($result->{source_origins}, [map { +{event => {raw => $_->{raw}, args => $_->{args}},
                source => $case->{action}, source_span => {start => $_->{start}, end => $_->{end}}} } @$expected],
                'independent original full-action recursive scalar intervals');
            is(scalar @constructed, scalar @$expected, 'all original constructors recorded');
            for my $index (0 .. $#$expected) {
                my $origin = $result->{source_origins}[$index];
                ok(defined($origin) && refaddr($origin->{event}) == refaddr($result->{events}[$index]),
                   'origin belongs to actual returned event');
                ok(defined($origin) && refaddr($constructed[$index][0]) == refaddr($origin->{event}),
                   'original constructed event retained');
                ok(defined($origin) && refaddr($constructed[$index][1]) == refaddr($origin->{event}{args}),
                   'original argument object retained');
            }
        };
    }
}

subtest 'default callbacks retain exact calls results and public event schema' => sub {
    my $source = 'switch(kind, case("x", case("nested")), default(default())); case("tail"); default()';
    for my $contract ('case_flow', 'default_flow') {
        my @calls;
        my $scan = sub {
            my ($private) = @_;
            my %observed;
            for my $key (sort keys %$deps) {
                my $callback = $deps->{$key};
                $observed{$key} = sub {
                    my $row = {name => $key, args => $json->decode($json->encode([@_]))};
                    push @calls, $row;
                    my $result = $callback->(@_);
                    $row->{result} = $json->decode($json->encode($result));
                    return $result;
                };
            }
            return $private
                ? LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id => $contract}, $source, \%observed)->{events}
                : LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id => $contract}, $source, \%observed);
        };
        my $ordinary = $scan->(0);
        my $before = $json->decode($json->encode(\@calls));
        @calls = ();
        is_deeply($scan->(1), $ordinary, 'same public event values/order');
        is_deeply(\@calls, $before, 'same callback inputs/results/counts');
    }
};

subtest 'copied and foreign parser results cannot lend inline argument authority' => sub {
    my $source = 'switch(kind, case("x", case("nested")))';
    for my $kind ('copy', 'foreign') {
        my %custom = %$deps;
        $custom{parse_method_function_expr} = sub {
            my $call = $deps->{parse_method_function_expr}->($kind eq 'foreign' ? 'case("foreign")' : @_);
            return $kind eq 'copy' ? {%$call, args => [@{$call->{args}}]} : $call;
        };
        my $ordinary = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id => 'case_flow'}, $source, \%custom);
        my $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id => 'case_flow'}, $source, \%custom);
        is_deeply($private->{events}, $ordinary, 'ordinary custom parser result retained');
        # The marker with two authored arguments is rejected by the copied
        # parser; the one emitted inline branch has no canonical argument owner.
        is_deeply($private->{source_origins}, $kind eq 'copy' ? [] : [
            {event => {raw => 'case("x", case("nested"))', args => {value => '"foreign"'}},
             source => $source, source_span => {start => 13, end => 38}}
        ], 'only directly captured marker can retain original source authority');
    }
};

subtest 'nested scans errors caller state empty and rejected results remain original' => sub {
    my %nested = %$deps;
    $nested{parse_method_function_expr} = sub {
        LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
            {id => 'case_flow'}, 'case("inner")', $deps);
        return $deps->{parse_method_function_expr}->(@_);
    };
    my $source = 'case("outer") { case("inner") }';
    my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id => 'case_flow'}, $source, \%nested);
    is_deeply([map { $_->{source_span} } @{$result->{source_origins}}],
              [{start => 0, end => 31}, {start => 16, end => 29}], 'outer full-source frames restored');
    my ($calls, $saved) = (0, undef);
    my %throwing = %$deps;
    $throwing{parse_method_function_expr} = sub { ++$calls; die "controlled recursive parser failure\n" };
    my $ok = eval { LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'case_flow'}, 'case("x")', \%throwing); 1 };
    ok(!$ok, 'original exception propagated');
    is($@, "controlled recursive parser failure\n", 'exact exception');
    is($calls, 1, 'throwing parser once');
    { local $@ = 'caller sentinel'; LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'default_flow'}, 'default', $deps); $saved = $@ }
    is($saved, 'caller sentinel', 'caller successful error state');
    for my $contract ('case_flow', 'default_flow') {
        for my $empty ('', 'note()', 'case()', 'default(1,2)') {
            my $ordinary = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id => $contract}, $empty, $deps);
            my $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance({id => $contract}, $empty, $deps);
            is_deeply($private->{events}, $ordinary, 'original rejected/empty event result');
        }
    }
};

done_testing;

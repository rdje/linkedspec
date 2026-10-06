use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::RuleIR::EmitContext ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $authored = $json->decode(do { local $/; <$file> });
close $file or die $!;
my @packages = LinkedSpec::ActionIR::ScannerCore::_scanner_rule_family_packages();
my $dispatchers = \&LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers;
my $record = \&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');

sub truth { return $_[0] ? JSON::PP::true : JSON::PP::false }
sub address { return ref($_[0]) ? refaddr($_[0]) : 0 }
sub snapshot { return $json->decode($json->encode($_[0])) }

sub observe {
    my ($case, $private, $inner, $fatal) = @_;
    my (@calls, @constructed, @visited);
    my ($returned, $selected, $nested, $restored);
    my $triggered = 0;
    my %observed;
    for my $name (sort keys %$deps) {
        my $callback = $deps->{$name};
        $observed{$name} = sub {
            my $row = {callback => $name, args => snapshot([@_])};
            push @calls, $row;
            my $result = $callback->(@_);
            $row->{result} = snapshot($result);
            return $result;
        };
    }
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
        my @original = $dispatchers->();
        my @wrapped;
        for my $index (0 .. $#original) {
            my $callback = $original[$index];
            my $package = $packages[$index];
            push @wrapped, sub {
                my $result = $callback->(@_);
                push @visited, {package => $package, defined => truth(defined $result)};
                ($returned, $selected) = ($result, $package) if defined $result;
                return $result;
            };
        }
        return @wrapped;
    };
    local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event = sub {
        my $event = $_[0];
        push @constructed, [$event, $event->{args}];
        my $result = $record->(@_);
        die "record hook changed event identity\n" unless address($event) == address($result);
        if ($private && $inner && !$triggered) {
            $triggered = 1;
            my $outer_recorder = address($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder);
            my $outer_error = $@;
            if ($fatal) {
                my %broken = (%$deps);
                my $changed = 0;
                my $callback_count = 0;
                $broken{trim_action_ir_value} = sub {
                    ++$callback_count;
                    $changed = address($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) != $outer_recorder;
                    die "nested callback sentinel\n";
                };
                my $ok = eval {
                    LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                        {id => $inner->{contract}}, $inner->{source}, \%broken);
                    1;
                };
                my $error = $@;
                $nested = {completed => truth($ok), error => $error,
                           callback_count => $callback_count, recorder_changed => truth($changed)};
            } else {
                $nested = observe($inner, 1, undef, 0);
            }
            $restored = truth(address($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) == $outer_recorder);
            $@ = $outer_error;
        }
        return $result;
    };
    my $before = address($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder);
    my $sentinel = 'caller sentinel: '.$case->{contract};
    $@ = $sentinel;
    my $result = $private
        ? LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
            {id => $case->{contract}}, $case->{source}, \%observed)
        : {events => LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            {id => $case->{contract}}, $case->{source}, \%observed), source_origins => []};
    my $caller_error = $@;
    my $after = address($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder);
    my @identity;
    if ($private) {
        for my $index (0 .. $#{$result->{events}}) {
            my $event = $result->{events}[$index];
            push @identity, {
                origin_event => truth(address($result->{source_origins}[$index]{event}) == address($event)),
                constructed_event => truth(address($constructed[$index][0]) == address($event)),
                constructed_args => truth(address($constructed[$index][1]) == address($event->{args})),
            };
        }
    }
    return {contract => $case->{contract}, source => $case->{source}, result => $result,
            calls => \@calls, identity => \@identity, visited => \@visited, selected => $selected,
            returned_array => truth(address($returned) == address($result->{events})),
            caller_error => $caller_error, expected_caller_error => $sentinel,
            entry_recorder_restored => truth($before == $after), nested => $nested,
            nested_triggered => truth($triggered), outer_recorder_restored => $restored};
}

my @base;
for my $case (@{$authored->{cases}}) {
    push @base, {public => observe($case, 0, undef, 0), private => observe($case, 1, undef, 0)};
}
my @pairs;
for my $outer (@{$authored->{cases}}) {
    for my $inner (@{$authored->{cases}}) {
        push @pairs, {outer => $outer->{contract}, inner => $inner->{contract},
                      observation => observe($outer, 1, $inner, 0)};
    }
}
my @fatal;
my $basic = $authored->{cases}[3];
for my $outer (@{$authored->{cases}}) {
    push @fatal, {outer => $outer->{contract}, inner => $basic->{contract},
                  observation => observe($outer, 1, $basic, 1)};
}

my ($opaque_report, $empty_report);
{
    my $opaque = {opaque => ['sentinel']};
    my @visited;
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
        return (
            sub { push @visited, 0; $record->({raw=>'abc', args=>{}}, 'abc', 0, 3); return undef },
            sub { push @visited, 1; $@='changed internally'; return $opaque },
            sub { die "opaque fallthrough\n" },
        );
    };
    $@ = 'opaque caller sentinel';
    my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'opaque'}, 'abc', $deps);
    my $error = $@;
    $opaque_report = {result => $result, same_object => truth(address($result->{events}) == address($opaque)),
                      visited => \@visited, caller_error => $error};
}
{
    my @visited;
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
        return (
            sub { push @visited, 0; $record->({raw=>'abc', args=>{}}, 'abc', 0, 3); return [] },
            sub { die "empty fallthrough\n" },
        );
    };
    $@ = 'empty caller sentinel';
    my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => 'empty'}, 'abc', $deps);
    my $error = $@;
    $empty_report = {result => $result, visited => \@visited, caller_error => $error};
}
print $json->pretty->encode({packages => \@packages, dependency_keys => [sort keys %$deps],
                            base => \@base, pairs => \@pairs, fatal_pairs => \@fatal,
                            opaque => $opaque_report, empty => $empty_report,
                            final_recorder_inactive => truth(!defined $LinkedSpec::ActionIR::ScannerCore::_source_event_recorder)});

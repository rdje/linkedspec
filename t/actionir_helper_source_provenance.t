use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
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
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0-';
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

subtest 'private entry is available' => sub {
    ok(LinkedSpec::ActionIR::ScannerCore->can('_scan_contract_ir_events_with_provenance'), 'private provenance channel exists');
};

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

subtest 'empty owned result remains empty' => sub {
    my $result = private_scan({id => 'return_general'}, 'set(counter,1)');
    is_deeply($result, {events => [], source_origins => []}, 'no invented provenance for an empty scan');
};

subtest 'opaque delegation and caller error are preserved' => sub {
    my $opaque = {opaque => ['sentinel']};
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
        return (sub { $@ = 'inner altered error'; return $opaque }, sub { die 'must not fall through' });
    };
    $@ = 'caller sentinel';
    my $result = private_scan({id => 'opaque'}, 'source');
    my $caller_error = $@;
    is(refaddr($result->{events}), refaddr($opaque), 'opaque object identity survives');
    is_deeply($result->{source_origins}, [], 'opaque payload has no invented event origins');
    is($caller_error, 'caller sentinel', 'caller error state survives private delegation');
};

subtest 'nested recording restores the outer source context' => sub {
    my $entry = LinkedSpec::ActionIR::ScannerCore->can('_scan_contract_ir_events_with_provenance');
    if (!$entry) { fail('private channel required for nested recording'); return }
    my $inner;
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
        return sub {
            my ($id, $code) = @_;
            if ($id eq 'inner') {
                my $event = {raw => $code, args => {}};
                return [LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event($event,$code,0,length($code))];
            }
            my $first = LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event({raw => 'return("a")',args => {}},$code,0,11);
            $inner = private_scan({id => 'inner'}, 'return("inner")');
            my $second = LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event({raw => 'return("b")',args => {}},$code,13,24);
            return [$first,$second];
        };
    };
    my $outer = private_scan({id => 'outer'}, 'return("a"); return("b")');
    is_deeply([map { $_->{source_span}{start} } @{$outer->{source_origins}}], [0,13], 'outer origins retain order without inner leakage');
    is(scalar(@{$inner->{source_origins}}),1,'inner invocation has its own origin');
    is($inner->{source_origins}[0]{source}, 'return("inner")','inner source frame stays independent');
};

subtest 'recording validates exact source slices' => sub {
    if (!LinkedSpec::ActionIR::ScannerCore->can('_scan_contract_ir_events_with_provenance')) {
        fail('private channel required for source validation'); return;
    }
    for my $bad ([-1,3,'abc'],[0,4,'abc'],[0,2,'abc'],[0,3,'xyz']) {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
            return sub {
                my ($id,$code) = @_;
                return [LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event({raw=>$bad->[2],args=>{}},$code,$bad->[0],$bad->[1])];
            };
        };
        my $result = eval { private_scan({id=>'bad'},'abc'); 1 };
        ok(!$result, 'invalid bounds or raw source mismatch reject');
        like($@, qr/source provenance/, 'source provenance failure is explicit');
    }
};

subtest 'unrecorded helper leaves event object unchanged' => sub {
    my $hook = LinkedSpec::ActionIR::ScannerCore->can('_record_scanned_source_event');
    if (!$hook) { fail('source hook required for passthrough control'); return }
    my $event = {raw=>'sentinel',args=>{literal=>'set(counter,1)'}};
    is(refaddr($hook->($event)),refaddr($event),'inactive recording is exact passthrough');
    is_deeply($event,{raw=>'sentinel',args=>{literal=>'set(counter,1)'}},'inactive hook adds no fields');
};

subtest 'unowned dispatcher records do not leak into the result' => sub {
    if (!LinkedSpec::ActionIR::ScannerCore->can('_scan_contract_ir_events_with_provenance')) {
        fail('private channel required for dispatched origin isolation'); return;
    }
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub {
        return (
            sub {
                LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event({raw=>'abc',args=>{}},'abc',0,3);
                return undef;
            },
            sub {
                return [LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event({raw=>'abc',args=>{}},'abc',0,3)];
            },
        );
    };
    my $result = private_scan({id=>'owned'},'abc');
    is(scalar(@{$result->{source_origins}}),1,'only the chosen result contributes origins');
    is(refaddr($result->{source_origins}[0]{event}),refaddr($result->{events}[0]),'selected event identity is exact');
};

# Original Legacy diagnosis supplies literal arguments and independently authored
# scalar intervals. Reuse that oracle rather than searching the observed raw text.
open my $legacy_file, '<:raw', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json' or die $!;
my $legacy_cases = $json->decode(do { local $/; <$legacy_file> });
close $legacy_file or die $!;
my %legacy_ids = map { $_ => 1 } qw(call push_single_arg push_indexed_arg push_target_arg
    push_target_indexed_arg push_scope_target_arg return_general return
    call-recognition-exclusions push-literal-target-exclusions);

for my $case (grep { $legacy_ids{$_->{id}} } @$legacy_cases) {
    subtest 'Legacy original producer: '.$case->{id} => sub {
        my $contract = {id => $case->{contracts}[0]};
        my (@public_calls, @private_calls, @constructed);
        my $observe = sub {
            my ($calls) = @_;
            return {map {
                my $key = $_;
                ($key => sub {
                    my $row = {callback => $key, args => $json->decode($json->encode([@_]))};
                    push @$calls, $row;
                    my $result = $deps->{$key}->(@_);
                    $row->{result} = $json->decode($json->encode($result));
                    return $result;
                })
            } keys %$deps};
        };
        my $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            $contract, $case->{action}, $observe->(\@public_calls));
        my $private;
        {
            my $recorder = \&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event = sub {
                my $event = $_[0];
                push @constructed, [$event, $event->{args}];
                return $recorder->(@_);
            };
            $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                $contract, $case->{action}, $observe->(\@private_calls));
        }
        is_deeply($public, $case->{expected_events}, 'original literal events and arguments');
        is_deeply($private->{events}, $public, 'private scan preserves public events');
        is_deeply(\@private_calls, \@public_calls, 'default callback effects and results stay exact');
        my @expected = map {
            my $index = $_;
            {event => $case->{expected_events}[$index], source => $case->{action},
             source_span => {start => $case->{original_spans}[$index][0], end => $case->{original_spans}[$index][1]}}
        } 0 .. $#{$case->{expected_events}};
        is_deeply($private->{source_origins}, \@expected, 'each selected original occurrence has its literal scalar frame');
        is(scalar(@constructed), scalar(@expected), 'one constructor event per selected occurrence');
        for my $index (0 .. $#{$private->{source_origins}}) {
            my $origin = $private->{source_origins}[$index];
            my $event = $private->{events}[$index];
            is(refaddr($origin->{event}), refaddr($event), 'origin retains actual returned event');
            is(refaddr($constructed[$index][0]), refaddr($event), 'origin retains actual constructor event');
            is(refaddr($constructed[$index][1]), refaddr($event->{args}), 'original argument object survives');
        }
        ok(!grep({exists $_->{source_span} || exists $_->{source_origins}} @$public), 'public events gain no source fields');
        is_deeply(private_scan($contract, 'note()'), {events => [], source_origins => []}, 'empty match gains no invented origin');
    };
}

# Current anonymous fixtures preserve the immutable original scalar oracle and
# incorporate only the already verified whole quoted-label correction.
open my $anonymous_file, '<:raw', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.2-cases.json' or die $!;
my $anonymous_cases = $json->decode(do { local $/; <$anonymous_file> });
close $anonymous_file or die $!;

for my $case (grep { $_->{family} eq 'anonymous-capture' } @$anonymous_cases) {
    subtest 'Anonymous original producer: '.$case->{id} => sub {
        my $contract = {id => $case->{contracts}[0]};
        my (@public_calls, @private_calls, @constructed);
        my $observe = sub {
            my ($calls) = @_;
            return {map {
                my $key = $_;
                ($key => sub {
                    my $row = {callback => $key, args => $json->decode($json->encode([@_]))};
                    push @$calls, $row;
                    my $result = $deps->{$key}->(@_);
                    $row->{result} = $json->decode($json->encode($result));
                    return $result;
                })
            } keys %$deps};
        };
        my $public = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
            $contract, $case->{action}, $observe->(\@public_calls));
        my $private;
        {
            my $recorder = \&LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event;
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event = sub {
                my $event = $_[0];
                push @constructed, [$event, $event->{args}];
                return $recorder->(@_);
            };
            $private = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
                $contract, $case->{action}, $observe->(\@private_calls));
        }
        is_deeply($public, $case->{expected_events}, 'original literal events and arguments');
        is_deeply($private->{events}, $public, 'private scan preserves public events');
        is_deeply(\@private_calls, \@public_calls, 'default callback effects and results stay exact');
        my @expected = map {
            my $index = $_;
            {event => $case->{expected_events}[$index], source => $case->{action},
             source_span => {start => $case->{original_spans}[$index][0], end => $case->{original_spans}[$index][1]}}
        } 0 .. $#{$case->{expected_events}};
        is_deeply($private->{source_origins}, \@expected, 'each selected original occurrence has its literal scalar frame');
        is(scalar(@constructed), scalar(@expected), 'one constructor event per selected occurrence');
        for my $index (0 .. $#{$private->{source_origins}}) {
            my $origin = $private->{source_origins}[$index];
            my $event = $private->{events}[$index];
            is(refaddr($origin->{event}), refaddr($event), 'origin retains actual returned event');
            is(refaddr($constructed[$index][0]), refaddr($event), 'origin retains actual constructor event');
            is(refaddr($constructed[$index][1]), refaddr($event->{args}), 'original argument object survives');
        }
        ok(!grep({exists $_->{source_span} || exists $_->{source_origins}} @$public), 'public events gain no source fields');
        is_deeply(private_scan($contract, 'note()'), {events => [], source_origins => []}, 'empty match gains no invented origin');
    };
}

done_testing();

use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();
use LinkedSpec::ActionIR::StatementSplit::Core ();
use LinkedSpec::RuleIR::EmitContext ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-';
sub read_json {
    my ($path) = @_;
    open my $file, '<:raw', $path or die $!;
    my $value = $json->decode(do { local $/; <$file> });
    close $file or die $!;
    return $value;
}
my $cases = read_json($prefix.'cases.json');
my $expected = read_json($prefix.'verification.json')->{expected};
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $split = $deps->{split_action_ir_statements};
sub private_scan {
    my ($contract, $source, $callbacks) = @_;
    return LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => $contract}, $source, $callbacks // $deps);
}
sub public_scan {
    my ($contract, $source, $callbacks) = @_;
    return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
        {id => $contract}, $source, $callbacks // $deps);
}

for my $i (0 .. $#$cases) {
    my ($case, $oracle) = ($cases->[$i], $expected->[$i]);
    subtest $case->{id} => sub {
        is($case->{action}, $oracle->{action}, 'authored original source identity');
        my $public = public_scan($case->{contract}, $case->{action});
        my $private = private_scan($case->{contract}, $case->{action});
        is_deeply($private->{events}, $public, 'complete original public events and arguments');
        my $wanted = [map { $oracle->{statements}[$_] } @{$oracle->{event_indices}}];
        is_deeply([map { $_->{raw} } @$public], [map { $_->{raw} } @$wanted], 'independent event occurrence order');
        my $origins = $private->{source_origins};
        is(scalar(@$origins), scalar(@$wanted), 'each original event has one private origin');
        for my $n (0 .. $#$origins) {
            my ($origin, $statement) = ($origins->[$n], $wanted->[$n]);
            is(refaddr($origin->{event}), refaddr($private->{events}[$n]), 'exact original event object');
            is(refaddr($origin->{event}{args}), refaddr($private->{events}[$n]{args}), 'exact original argument object');
            is($origin->{source}, $case->{action}, 'complete original scalar source');
            is_deeply($origin->{source_span}, {start => $statement->{start}, end => $statement->{end}},
                'independent original scalar occurrence interval');
            is(substr($origin->{source}, $statement->{start}, $statement->{end} - $statement->{start}),
                $origin->{event}{raw}, 'original interval retrieves event raw');
        }
        ok(!grep({ exists $_->{source_span} || exists $_->{source_origins} } @$public), 'no added public source fields');
    };
}

subtest 'five callback signatures, counts and effects match public scans' => sub {
    for my $case (grep { exists $_->{expected_raws} } @$cases) {
        my @observed;
        for my $private (0, 1) {
            my @calls;
            my %callbacks = map {
                my $name = $_; my $callback = $deps->{$name};
                $name => sub { push @calls, [$name, @_]; return $callback->(@_) }
            } keys %$deps;
            my $result = $private ? private_scan($case->{contract}, $case->{action}, \%callbacks)->{events}
                : public_scan($case->{contract}, $case->{action}, \%callbacks);
            push @observed, {events => $result, calls => \@calls};
        }
        is_deeply($observed[1], $observed[0], $case->{contract}.' unchanged callback sequence/arguments');
        is(scalar(grep { $_->[0] eq 'split_action_ir_statements' } @{$observed[1]{calls}}), 1, 'split callback once');
    }
    is_deeply([sort keys %$deps], [sort qw(split_action_ir_statements trim_action_ir_value
        parse_method_function_expr normalize_method_args_with_optional_scope build_array_pipeline_plan_from_expr)],
        'original five dependency interfaces');
};

subtest 'opaque, copied and changed split results do not borrow origins' => sub {
    for my $callback (
        sub { return ['my $x'] },
        sub { return [@{$split->($_[0])}] },
        sub { my $array = $split->($_[0]); $array->[0] = 'my $y'; return $array }) {
        my %callbacks = (%$deps, split_action_ir_statements => $callback);
        my $result = private_scan('my_declare_bare', 'my $x;', \%callbacks);
        is_deeply($result->{events}, public_scan('my_declare_bare', 'my $x;', \%callbacks), 'custom result preserved');
        is_deeply($result->{source_origins}, [], 'no copied or invented coordinates');
    }
};

subtest 'later custom trim preserves events without transformed origins' => sub {
    my %callbacks = (%$deps, trim_action_ir_value => sub {
        my $value = $deps->{trim_action_ir_value}->(@_); $value =~ s/\$x/\$y/g; return $value;
    });
    my $result = private_scan('my_declare_bare', 'my $x;', \%callbacks);
    is_deeply($result->{events}, public_scan('my_declare_bare', 'my $x;', \%callbacks), 'later trim effects unchanged');
    is($result->{events}[0]{raw}, 'my $y', 'actual transformed event');
    is_deeply($result->{source_origins}, [], 'transformed raw has no fabricated original interval');
};

subtest 'nested private splitting and scanning restore outer origins' => sub {
    my $inner;
    my %callbacks = (%$deps, split_action_ir_statements => sub {
        $inner = private_scan('return_bare', 'return 7;');
        return $split->(@_);
    });
    my $outer = private_scan('my_declare_bare', 'my $x; my $x;', \%callbacks);
    is_deeply([map { $_->{source_span} } @{$outer->{source_origins}}], [{start=>0,end=>5},{start=>7,end=>12}],
        'outer exact occurrence frames without inner leakage');
    is_deeply([map { $_->{source_span} } @{$inner->{source_origins}}], [{start=>0,end=>8}], 'inner independent frame');
    is($inner->{source_origins}[0]{source}, 'return 7;', 'inner complete source');
};

subtest 'split callback failures and caller error keep existing behavior' => sub {
    my @errors;
    for my $private (0, 1) {
        my $calls = 0;
        my %callbacks = (%$deps, split_action_ir_statements => sub { ++$calls; die "controlled split failure\n" });
        my $ok = eval { $private ? private_scan('my_declare_bare', 'my $x;', \%callbacks)
            : public_scan('my_declare_bare', 'my $x;', \%callbacks); 1 };
        ok(!$ok, 'same dependency exception propagates');
        push @errors, $@;
        is($calls, 1, 'throwing split callback once');
    }
    is_deeply(\@errors, ["controlled split failure\n", "controlled split failure\n"], 'exact existing errors');
    $@ = 'caller sentinel';
    private_scan('my_declare_bare', 'my $x;');
    is($@, 'caller sentinel', 'private provenance retains caller error');
};

subtest 'empty selected statement results have no fabricated origins' => sub {
    for my $case (grep { exists $_->{expected_raws} } @$cases) {
        is_deeply(private_scan($case->{contract}, 'no_selected_statement'), {events=>[],source_origins=>[]},
            $case->{contract}.' unchanged empty result');
    }
};

subtest 'another callback source cannot authorize original action coordinates' => sub {
    for my $pair (['my $input;', 'my $other;'], ['prefix; my $x;', 'my $x;']) {
        my %callbacks = (%$deps, split_action_ir_statements => sub { return $split->($pair->[1]) });
        my $result = private_scan('my_declare_bare', $pair->[0], \%callbacks);
        is_deeply($result->{events}, public_scan('my_declare_bare', $pair->[0], \%callbacks),
            'actual callback event remains unchanged');
        is_deeply($result->{source_origins}, [], 'foreign source has no original action authority');
    }
};

done_testing;

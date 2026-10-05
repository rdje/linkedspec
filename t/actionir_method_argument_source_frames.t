use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodExpr ();

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $parse = \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr;
my $split = \&LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv;

sub csv_frames {
    my ($callback, @args) = @_;
    my $bridge = LinkedSpec::ActionIR::MethodExpr->can('_split_csv_with_source_frames');
    return $bridge->($callback, @args) if $bridge;
    return {arguments => $callback->(@args), source_frames => []};
}

sub method_frames {
    my ($callback, @args) = @_;
    my $bridge = LinkedSpec::ActionIR::MethodExpr->can('_parse_method_with_source_frames');
    return $bridge->($callback, @args) if $bridge;
    return {call => $callback->(@args), source_frames => []};
}

for my $case (@$cases) {
    subtest $case->{id} => sub {
        my ($count, $returned) = (0, undef);
        my $parsed = method_frames(sub { ++$count; $returned = $parse->(@_); return $returned },
                                   $case->{source}, $case->{receiver});
        is($count, 1, 'original parser callback once');
        is(refaddr($parsed->{call}), refaddr($returned), 'actual returned parser hash');
        is_deeply($parsed->{call}, {method => $case->{method}, source_method => $case->{method},
            source => $case->{trimmed}, args => [map { $_->{raw} } @{$case->{arguments}}]},
            'original parser fields and values');
        is_deeply($parsed->{source_frames}, [map { +{source => $case->{source}, raw => $_->{raw},
            source_span => {start => $_->{start}, end => $_->{end}}} } @{$case->{arguments}}],
            'independent original expression scalar frames');
        my ($split_count, $array) = (0, undef);
        my $csv = csv_frames(sub { ++$split_count; $array = $split->(@_); return $array },
                             $case->{payload}, ($case->{receiver} ? '.' : '').$case->{method});
        is($split_count, 1, 'original CSV callback once');
        is(refaddr($csv->{arguments}), refaddr($array), 'actual returned CSV array');
        is_deeply($csv->{source_frames}, [map { +{source => $case->{payload}, raw => $_->{raw},
            source_span => {start => $_->{start} - $case->{payload_start},
                            end => $_->{end} - $case->{payload_start}}} } @{$case->{arguments}}],
            'independent original payload scalar frames');
    };
}

subtest 'unknown copied foreign and opaque returns preserve identity without authority' => sub {
    for my $value (undef, 'opaque', {}, ['same', 'same']) {
        for my $mode ('csv', 'parse') {
            my $count = 0;
            my $callback = sub { ++$count; return $value };
            my $result = $mode eq 'csv' ? csv_frames($callback, 'same,same')
                                       : method_frames($callback, 'call(same,same)');
            my $actual = $result->{$mode eq 'csv' ? 'arguments' : 'call'};
            is($count, 1, 'unknown callback once');
            ref($value) ? is(refaddr($actual), refaddr($value), 'opaque exact object')
                        : is($actual, $value, 'opaque exact scalar');
            is_deeply($result->{source_frames}, [], 'unknown has no invented frames');
        }
    }
    for my $callback (
        sub { [@{$split->(@_)}] },
        sub { $split->('same,same') },
    ) {
        my $result = csv_frames($callback, ' same, same ');
        is_deeply($result->{arguments}, ['same', 'same'], 'copied or foreign values retained');
        is_deeply($result->{source_frames}, [], 'copied or foreign source denied');
    }
    for my $callback (
        sub { my $r = $parse->(@_); return {%$r} },
        sub { my $r = $parse->(@_); $r->{args} = [@{$r->{args}}]; return $r },
        sub { $parse->('call(same,same)') },
        sub { my $r = $parse->(@_); $r->{source} = 'changed'; return $r },
        sub { my $r = $parse->(@_); $r->{method} = 'changed'; return $r },
        sub { my $r = $parse->(@_); $r->{source_method} = 'changed'; return $r },
    ) {
        my $result = method_frames($callback, ' call(same,same) ');
        is_deeply($result->{call}{args}, ['same', 'same'], 'copied or foreign parser values retained');
        is_deeply($result->{source_frames}, [], 'parser result/source/argument identity denied');
    }
};

subtest 'changed entries decline only their original occurrence' => sub {
    my $csv = csv_frames(sub { my $r = $split->(@_); $r->[0] = 'changed'; return $r }, ' same, same ');
    is_deeply($csv->{arguments}, ['changed', 'same'], 'changed CSV values retained');
    is_deeply($csv->{source_frames}, [undef, {source => ' same, same ', raw => 'same',
        source_span => {start => 7, end => 11}}], 'unchanged CSV neighbor retains original occurrence');
    my $parsed = method_frames(sub { my $r = $parse->(@_); $r->{args}[0] = 'changed'; return $r },
                                ' call( same, same ) ');
    is_deeply($parsed->{call}{args}, ['changed', 'same'], 'changed parser values retained');
    is_deeply($parsed->{source_frames}, [undef, {source => ' call( same, same ) ', raw => 'same',
        source_span => {start => 13, end => 17}}], 'unchanged parser neighbor retains original occurrence');
};

subtest 'custom producer trim and nested collection preserve ordinary behavior' => sub {
    my $trim = \&LinkedSpec::ActionIR::MethodExpr::_trim_method_expr_value;
    my $result;
    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::MethodExpr::_trim_method_expr_value = sub {
            my $value = $trim->(@_); $value =~ s/same/changed/ if defined $value; return $value;
        };
        $result = csv_frames($split, 'same,other');
    }
    is_deeply($result->{arguments}, ['changed', 'other'], 'custom trim values retained');
    is_deeply($result->{source_frames}, [undef, {source => 'same,other', raw => 'other',
        source_span => {start => 5, end => 10}}], 'transformed entry denied with exact neighbor retained');
    my $inner;
    my $outer = method_frames(sub {
        $inner = method_frames($parse, 'inner( "β" )'); return $parse->(@_);
    }, ' call( same, same ) ');
    is_deeply($inner->{source_frames}, [{source => 'inner( "β" )', raw => '"β"',
        source_span => {start => 7, end => 10}}], 'inner original scalar frame');
    is_deeply($outer->{source_frames}, [map { +{source => ' call( same, same ) ', raw => 'same',
        source_span => {start => $_, end => $_ + 4}} } (7, 13)], 'outer restored after nested collection');
};

subtest 'errors signatures and caller error state remain exact' => sub {
    for my $mode ('csv', 'parse') {
        my (@seen, $count);
        my $callback = sub { ++$count; @seen = @_; die "controlled frame failure\n" };
        my $ok = eval {
            $mode eq 'csv' ? csv_frames($callback, 'same,same', 'call', 42)
                           : method_frames($callback, 'call(same,same)', 1, 42); 1;
        };
        ok(!$ok, 'exception propagated');
        is($@, "controlled frame failure\n", 'exact exception');
        is($count, 1, 'throwing callback once');
        is_deeply(\@seen, $mode eq 'csv' ? ['same,same', 'call', 42] : ['call(same,same)', 1, 42],
                  'all original callback arguments');
    }
    my $saved;
    { local $@ = 'caller sentinel'; method_frames($parse, 'call(same)'); $saved = $@ }
    is($saved, 'caller sentinel', 'caller successful error state');
};

subtest 'empty rejected and non-scalar inputs do not invent scalar frames' => sub {
    for my $source (undef, '', ' ', 'call', 'call(a', 'call(a))') {
        is_deeply(method_frames($parse, $source), {call => undef, source_frames => []}, 'original rejection');
    }
    for my $source (undef, '', ' , , ') {
        is_deeply(csv_frames($split, $source), {arguments => [], source_frames => []}, 'original empty CSV');
    }
    my $text = 'same';
    for my $source ({}, \$text) {
        my $ordinary = $split->($source);
        my $observed = csv_frames($split, $source);
        is_deeply($observed->{arguments}, $ordinary, 'non-scalar ordinary stringification');
        ok(!grep({ defined $_ } @{$observed->{source_frames}}), 'no non-scalar source frame');
    }
};

done_testing;

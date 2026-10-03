use strict;
use warnings;
use Test::More;
use LinkedSpec ();
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use IPC::Open2 qw(open2);
use Scalar::Util qw(blessed);

my $json = JSON::PP->new->canonical;
my $path = 'tests/language-readiness/composed/normalization-calls.spec';
open my $source_fh, '<', $path or die $!;
my $source = do { local $/; <$source_fh> };
close $source_fh or die $!;
my @cases = (
    {id => 'P_ab_cd', input => 'ab-cd', sink => 'collect'},
    {id => 'P_mixed_case', input => 'AB-cd', sink => 'collect'},
    {id => 'P_short', input => 'x-y', sink => 'collect'},
    {id => 'P_quiet', input => 'ab-cd', sink => 'absent'},
    {id => 'P_prefix_bad', input => '!ab-cd', sink => 'collect'},
    {id => 'P_suffix_bad', input => 'ab-cd!', sink => 'collect'},
    {id => 'P_empty', input => '', sink => 'collect'},
);

sub expected {
    my ($case) = @_;
    return {value => undef, events => [], exit_status => 1, detachment => undef}
        unless $case->{input} =~ /\A([A-Za-z]+)-([A-Za-z]+)\z/;
    my ($first, $second) = ($1, $2);
    my ($left, $right) = ('new:' . uc($first), 'new:' . uc($second));
    my $value = {
        tree => {a => $left, b => {c => $right}, meta => {count => 2}},
        mapped => {a => $left, b => {c => $right}},
        original => {a => $first, b => {c => $second}},
        seen => [$first, $second], text => 'outside', visits => 2,
    };
    my $events = $case->{sink} eq 'collect' ? [
        {helper_name => 'print_each', rule_label => 'Top', message => "leaf:$first!"},
        {helper_name => 'print_each', rule_label => 'Top', message => "leaf:$second!"},
        {helper_name => 'say', rule_label => 'Top', message => "done:2\n"},
    ] : [];
    return {value => $value, events => $events, exit_status => undef,
        detachment => {mapped_unchanged => 1, original_unchanged => 1,
            deliberately_aliased_control_rejected => 1}};
}

sub native_detachment {
    my ($actual) = @_;
    my $mapped_before = $json->encode($actual->{mapped});
    my $original_before = $json->encode($actual->{original});
    $actual->{tree}{a} = 'actual-root-probe';
    $actual->{tree}{b}{c} = 'actual-nested-probe';
    my $mapped_ok = $json->encode($actual->{mapped}) eq $mapped_before;
    my $original_ok = $json->encode($actual->{original}) eq $original_before;
    my $aliased = {%$actual, mapped => $actual->{tree}};
    my $aliased_before = $json->encode($aliased->{mapped});
    $aliased->{tree}{b}{c} = 'actual-alias-probe';
    return {mapped_unchanged => $mapped_ok ? 1 : 0,
        original_unchanged => $original_ok ? 1 : 0,
        deliberately_aliased_control_rejected =>
            $json->encode($aliased->{mapped}) ne $aliased_before ? 1 : 0};
}

my %ctx;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
is($metadata->{language_agnostic_action_ir_ready}, 1, 'admitted call source is ready');
for my $key (qw(raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count)) {
    is($metadata->{$key}, 0, "admitted call source has zero $key");
}
my @native;
for my $case (@cases) {
    my (@events, $value, $error, $stdout, $stderr);
    $stdout = $stderr = '';
    {
        open my $capture_out, '>', \$stdout or die $!;
        open my $capture_err, '>', \$stderr or die $!;
        local *STDOUT = $capture_out;
        local *STDERR = $capture_err;
        my $input = $case->{input};
        my $options = $case->{sink} eq 'collect' ? {
            diagnostic_sink => sub { push @events, {%{$_[0]}} },
        } : undef;
        my $ok = eval { $value = $parser->(\$input, $options); 1 };
        $error = $@ unless $ok;
    }
    my $exit_status = blessed($error) && $error->isa('LinkedSpec::RuntimeExitNow')
        ? 0 + $error->status : undef;
    my $unexpected_error = defined($error) && !defined($exit_status) ? "$error" : undef;
    my $initial = $json->decode($json->encode($value));
    my $detach = ref($value) eq 'HASH' ? native_detachment($value) : undef;
    my $row = {id => $case->{id}, value => $initial, events => \@events,
        stdout => $stdout, stderr => $stderr, exit_status => $exit_status,
        unexpected_error => $unexpected_error, detachment => $detach};
    my $oracle = expected($case);
    subtest "$case->{id} native" => sub {
        is($json->encode($row->{value}), $json->encode($oracle->{value}),
            'independent typed nested value and continuation');
        is_deeply($row->{events}, $oracle->{events}, 'exact ordered diagnostic delivery or quietness');
        is($row->{exit_status}, $oracle->{exit_status}, 'typed authored exit or successful value');
        is($row->{unexpected_error}, undef, 'no unrelated exception');
        is($ctx{last_error}, undef, 'no suppressed native runtime failure');
        is($row->{stdout}, '', 'no host output');
        is($row->{stderr}, '', 'no host stderr');
        is_deeply($row->{detachment}, $oracle->{detachment},
            'actual returned-tree mutation preserves mapped/original; deliberate alias rejects');
    };
    push @native, $row;
}

my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => $path);
my $child = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl';
my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl', $child);
print {$child_in} $json->encode({emitted => $emitted, cases => \@cases});
close $child_in or die $!;
my $reply = do { local $/; <$child_out> };
close $child_out or die $!;
waitpid($pid, 0);
is($?, 0, 'independent emitted child completes');
my $fresh = eval { $json->decode($reply) };
BAIL_OUT("fresh child did not return its complete JSON record: $@") unless ref($fresh) eq 'HASH';
is($fresh->{emitted_sha256}, sha256_hex($emitted), 'fresh child loads exact emitted bytes');
is(scalar(@{$fresh->{rows}}), scalar(@cases), 'fresh child retains all seven cases');
for my $index (0 .. $#cases) {
    my $case = $cases[$index];
    my $row = $fresh->{rows}[$index];
    my $oracle = expected($case);
    subtest "$case->{id} fresh emitted" => sub {
        is($row->{id}, $case->{id}, 'case identity and order retained');
        is($json->encode($row->{value}), $json->encode($oracle->{value}),
            'independent typed nested value and continuation');
        is_deeply($row->{events}, $oracle->{events}, 'exact ordered diagnostic delivery or quietness');
        is($row->{exit_status}, $oracle->{exit_status}, 'typed authored exit or successful value');
        is($row->{unexpected_error}, undef, 'no unrelated exception');
        is($row->{stdout}, '', 'no host output');
        is($row->{stderr}, '', 'no host stderr');
        is_deeply($row->{detachment}, $oracle->{detachment}, 'actual fresh returned-object and alias controls');
    };
}
note('NORMALIZATION_OBSERVATIONS ' . $json->encode({source_path => $path,
    source_sha256 => sha256_hex($source), emitted_sha256 => sha256_hex($emitted),
    native => \@native, fresh => $fresh->{rows}}));
done_testing();

BEGIN {
 if (grep { $_ eq '--baseline' } @ARGV) {
  require './docs/checkpoints/SESSION-STARTUP-READING.87.2-runtime-before.pm';
  $INC{'LinkedSpec/CodeblockRuntime.pm'} = 'docs/checkpoints/SESSION-STARTUP-READING.87.2-runtime-before.pm';
 }
}
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();
use Scalar::Util qw(blessed reftype refaddr);
use Digest::SHA qw(sha256_hex);
use IPC::Open2 qw(open2);
require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm';

my $json = JSON::PP->new->canonical;
sub project {
    my ($value) = @_;
    return [map { project($_) } @$value] if (reftype($value) // '') eq 'ARRAY';
    return {map(($_ => project($value->{$_})), keys %$value),
        blessed($value) ? (observed_class => blessed($value)) : ()}
        if (reftype($value) // '') eq 'HASH';
    return $value;
}
open my $case_file, '<', 'docs/checkpoints/SESSION-STARTUP-READING.87.2-cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$case_file> });
close $case_file or die $!;
my @cases = map { [$_->{id}, $_->{source}] } @$cases;
my @rows;
for my $case (@cases) {
    my ($id, $source) = @$case;
    my (%ctx, $dump, $value, $failure, $stdout, $stderr, $emitted, $descriptor);
    my ($invocations, $actual_error);
    $stdout = $stderr = '';
    {
        open my $out, '>', \$stdout or die $!;
        open my $err, '>', \$stderr or die $!;
        local *STDOUT = $out;
        local *STDERR = $err;
        my $ok = eval {
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx,
                dump_parser_source => 1, parser_source_ref => \$dump);
            $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
            my $input = '';
            ($invocations, $actual_error) = DeferredControl::Observe::execute(sub {
                $value = $parser->(\$input);
            });
            $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "$id.spec");
            1;
        };
        $failure = $@ unless $ok;
    }
    my $fresh;
    if (defined $emitted) {
        my $pid = open2(my $child_out, my $child_in, $^X, '-Iperl',
            'docs/checkpoints/SESSION-STARTUP-READING.87.2-fresh.pl',
            grep { $_ eq '--baseline' } @ARGV);
        print {$child_in} $json->encode({emitted => $emitted});
        close $child_in or die $!;
        my $reply = do { local $/; <$child_out> };
        close $child_out or die $!;
        waitpid($pid, 0);
        die 'fresh observer failed' if $?;
        $fresh = $json->decode($reply);
    }
    my $meta = $descriptor ? $descriptor->{spec}{Top}{meta}{action_rewriter} : undef;
    push @rows, {id => $id, source => $source, source_sha256 => sha256_hex($source),
        dump => $dump, emitted => $emitted,
        emitted_sha256 => defined($emitted) ? sha256_hex($emitted) : undef,
        native => {value => project($value), exception => project($failure),
            context_error => project($ctx{last_error}), stdout => $stdout, stderr => $stderr,
            invocations => $invocations, actual_error_identity => ref($actual_error) &&
                ref($ctx{last_error}{detail}) ? refaddr($actual_error) == refaddr($ctx{last_error}{detail}) ? 1 : 0 : undef},
        fresh => $fresh, metadata => project($meta)};
}
print $json->pretty->encode({cases => \@rows});

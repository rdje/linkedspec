use strict;
use warnings;
use JSON::PP ();
use POSIX qw(WNOHANG);
use Time::HiRes qw(time sleep);
use LinkedSpec ();

# Bounded phase diagnosis of the interrupted added control, not a benchmark.
my $base = 'docs/checkpoints/count-copy-perl-2026-11-05';
open my $fh, '<', "$base/before/cases.json" or die $!;
my $rows = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die $!;
my ($row) = grep { $_->{id} eq 'receiver_repeated_copy_rejection' } @$rows;
for my $phase ('parse_only', 'substitution') {
    my $pid = fork();
    die $! unless defined $pid;
    if (!$pid) {
        open STDOUT, '>', "$base/slow-$phase.log" or die $!;
        open STDERR, '>', "$base/slow-$phase.stderr" or die $!;
        $| = 1;
        print "BEGIN $phase\n";
        if ($phase eq 'parse_only') {
            my $descriptor = LinkedSpec::Get(\$row->{source}, parse_only => 1);
            print 'RESULT '.ref($descriptor)."\n";
        } else {
            my $body = $row->{source};
            $body =~ s/\AValue:: I \{// or die 'source prefix';
            $body =~ s/\}\z// or die 'source suffix';
            LinkedSpec::configure_trace(trace_level => 'debug', trace_log_mode => 'stdout');
            print LinkedSpec::call_spec_handler_subst('Value', $body), "\n";
        }
        print "COMPLETE $phase\n";
        exit 0;
    }
    my $end = time() + 10;
    my $done = 0;
    while (time() < $end) {
        if (waitpid($pid, WNOHANG) == $pid) { $done = 1; last }
        sleep(0.05);
    }
    if (!$done) { kill 'KILL', $pid; waitpid($pid, 0) }
    print "$phase ".($done ? "exit=$?" : 'bounded-stop')."\n";
}

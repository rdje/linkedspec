use strict;
use warnings;
use POSIX qw(WNOHANG);
use Time::HiRes qw(time sleep);
use LinkedSpec ();

# Qualify bootstrap once, then fork the identical stage probes from that state.
my $pid = fork(); die $! unless defined $pid;
if (!$pid) {
    $| = 1;
    print "WARM_BEGIN\n";
    my $source = 'Value:: I {return(1)}';
    my $parser = LinkedSpec::Get(\$source);
    die 'warmup not callable' unless ref($parser) eq 'CODE';
    my $input = 'x';
    die 'warmup value' unless $parser->(\$input) == 1;
    print "WARM_READY\n";
    do './docs/checkpoints/count-compiler-scaling-2026-11-05/probe.pl';
    die $@ if $@;
    exit 0;
}
my $limit = time() + 180;
while (time() < $limit) {
    if (waitpid($pid, WNOHANG) == $pid) { print "WORKER_STATUS $?\n"; exit($? ? 1 : 0) }
    sleep(0.05);
}
kill 'KILL', $pid;
waitpid($pid, 0);
die "warm-probe bounded stop\n";

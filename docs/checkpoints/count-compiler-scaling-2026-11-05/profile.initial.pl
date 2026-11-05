use strict;
use warnings;
use JSON::PP ();
use POSIX qw(WNOHANG);
use Time::HiRes qw(time sleep);

my ($out, $owner) = @ARGV;
die 'output required' unless defined($out) && -d $out;
if (defined $owner) {
    require "./$owner";
    $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} = "./$owner";
}
require LinkedSpec;
require LinkedSpec::ActionIR::MethodLowering;
my $json = JSON::PP->new->canonical->ascii;
open my $fh, '<', 'docs/checkpoints/count-compiler-scaling-2026-11-05/warm/cases.json' or die $!;
my $rows = $json->decode(do { local $/; <$fh> }); close $fh or die $!;
for my $row (@$rows) {
    my $pid = fork(); die $! unless defined $pid;
    if (!$pid) {
        open STDOUT, '>', "$out/$row->{id}.stdout" or die $!;
        open STDERR, '>', "$out/$row->{id}.stderr" or die $!;
        $| = 1;
        print 'OWNER ', $INC{'LinkedSpec/ActionIR/MethodLowering.pm'}, "\n";
        my ($count, %calls, %sites) = (0);
        my $report = sub {
            print 'PROFILE ', $json->encode({count => $count, sites => \%sites,
                top => [map { {source => $_, count => $calls{$_}} }
                    (sort { $calls{$b} <=> $calls{$a} || $a cmp $b } keys %calls)[0 .. ((keys(%calls) < 12 ? scalar(keys %calls) : 12) - 1)]]}), "\n";
        };
        my $original = \&LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr;
        {
            no warnings 'redefine';
            *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
                ++$count;
                ++$calls{defined($_[0]) ? $_[0] : '<undef>'};
                my (undef, $file, $line) = caller;
                ++$sites{"$file:$line"};
                if ($count > 5000) { $report->(); POSIX::_exit(42) }
                return $original->(@_);
            };
        }
        my $body = $row->{source};
        $body =~ s/\AValue:: I \{// or die 'body prefix';
        $body =~ s/\}\z// or die 'body suffix';
        my $result = LinkedSpec::call_spec_handler_subst('Value', $body);
        print 'LOWERED ', $result, "\n";
        $report->();
        exit 0;
    }
    my ($done, $status);
    my $limit = time() + 10;
    while (time() < $limit) {
        if (waitpid($pid, WNOHANG) == $pid) { $done = 1; $status = $?; last }
        sleep(0.025);
    }
    unless ($done) { kill 'KILL', $pid; waitpid($pid, 0) }
    print $json->encode({id => $row->{id}, completed => $done ? 1 : 0, status => $status}), "\n";
}

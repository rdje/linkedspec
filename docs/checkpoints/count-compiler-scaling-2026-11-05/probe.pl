use strict;
use warnings;
use JSON::PP ();
use POSIX qw(WNOHANG);
use Time::HiRes qw(time sleep);
use LinkedSpec ();

# Public bounded compiler-stage probes, never overwrite historical evidence.
my ($output) = @ARGV;
die 'output directory required' unless defined($output) && -d $output;
my $json = JSON::PP->new->canonical->ascii->allow_nonref;
open my $catalog, '<', 'docs/checkpoints/count-copy-perl-2026-11-05/before/cases.json' or die $!;
my $original = $json->decode(do { local $/; <$catalog> }); close $catalog or die $!;
my ($long) = grep { $_->{id} eq 'receiver_repeated_copy_rejection' } @$original;
die 'missing original source' unless $long;
my $free = $long->{source};
$free =~ s/out=\{order=cat\(order,"S"\);\["a"\]\}\.count\(\)/out=count({order=cat(order,"S");["a"]})/ or die 'free twin';
my $short = $long->{source};
$short =~ s/\.copy\(\)\.copy\(\)// or die 'no-copy twin';
my @cases = (
    { id => 'original_receiver', source => $long->{source} },
    { id => 'free_twin', source => $free },
    { id => 'receiver_no_copy', source => $short },
    { id => 'minimal_block_receiver', source => 'Value:: I {return({["a"]}.count().copy().copy().add(1))}' },
);
open my $cases, '>', "$output/cases.json" or die $!;
print {$cases} $json->pretty->encode(\@cases); close $cases or die $!;
for my $case (@cases) {
    for my $phase ('parse_only', 'substitution', 'native') {
        my $id = "$case->{id}-$phase";
        die 'existing result' if -e "$output/$id.stdout" || -e "$output/$id.stderr";
        my $pid = fork(); die $! unless defined $pid;
        if (!$pid) {
            open STDOUT, '>', "$output/$id.stdout" or die $!;
            open STDERR, '>', "$output/$id.stderr" or die $!;
            $| = 1; print "BEGIN $id\n";
            my $source = $case->{source};
            if ($phase eq 'parse_only') {
                my $value = LinkedSpec::Get(\$source, parse_only => 1);
                print 'DESCRIPTOR ', ref($value), "\n";
            } elsif ($phase eq 'substitution') {
                $source =~ s/\AValue:: I \{// or die 'body prefix';
                $source =~ s/\}\z// or die 'body suffix';
                print LinkedSpec::call_spec_handler_subst('Value', $source), "\n";
            } else {
                my %context;
                my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                die 'not callable' unless ref($parser) eq 'CODE';
                my $input = 'x';
                my $value = $parser->(\$input);
                print 'VALUE ', $json->encode({value => $value, error => $context{last_error}}), "\n";
            }
            print "COMPLETE $id\n";
            exit 0;
        }
        my ($done, $status);
        my $limit = time() + 6;
        while (time() < $limit) {
            if (waitpid($pid, WNOHANG) == $pid) { $done = 1; $status = $?; last }
            sleep(0.025);
        }
        unless ($done) { kill 'KILL', $pid; waitpid($pid, 0) }
        print $json->encode({id => $id, completed => $done ? 1 : 0, status => $status}), "\n";
    }
}

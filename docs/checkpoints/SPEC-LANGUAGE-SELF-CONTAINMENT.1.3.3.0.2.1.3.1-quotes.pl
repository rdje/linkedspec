use strict;
use warnings;
use LinkedSpec::ActionIR::StatementSplit::Core ();
use JSON::PP ();

my $phase = shift // die "quote phase required";
die "invalid quote phase" unless $phase =~ /\A(?:red|green)\z/;
# This is lexer data only; no shell command is executed.
my $source = q!text=`echo {|s,q`; cb={|x,y| return(x) }; return(cb("ok","unused"))!;
my $parts = LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements(
    $source, sub {my $value = shift; $value =~ s/^\s+|\s+$//g; $value});
my @expected = ('text=`echo {|s,q`', 'cb={|x,y| return(x) }', 'return(cb("ok","unused"))');
my $json = JSON::PP->new->canonical;
my $same = $json->encode($parts) eq $json->encode(\@expected);
open my $fh, '>', ".linkedspec-data/scratch/selfcontain13302131/quotes-$phase.json" or die $!;
print {$fh} $json->pretty->encode({source => $source, parts => $parts, expected => \@expected,
    matches_oracle => $same ? JSON::PP::true : JSON::PP::false});
close $fh or die $!;
print "quoted opener control: $phase matches=$same\n";

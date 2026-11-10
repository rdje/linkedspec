use strict;
use warnings;
use JSON::PP ();
use File::Spec ();
use FindBin ();
use Test::More ();

my ($names_path, $seen_path) = @ARGV;
die "names and selection output required\n" unless defined $seen_path;
open my $fh, '<', $names_path or die $!;
my $text; { local $/; $text = <$fh>; }
my $names = JSON::PP->new->decode($text);
my %wanted = map { $_ => 1 } @$names;
die "empty or duplicate selection\n" unless @$names && keys(%wanted) == @$names;
my @seen;
our $inside = 0;
my $original = \&Test::More::subtest;
{
    no warnings 'redefine';
    *Test::More::subtest = sub {
        if (!$inside) {
            return 1 unless $wanted{$_[0]};
            push @seen, $_[0];
        }
        local $inside = ($inside || 0) + 1;
        return $original->(@_);
    };
}
$FindBin::Bin = File::Spec->rel2abs('t');
my $result = do './t/phase0_regression.t';
die $@ if $@;
die $! unless defined $result;
open my $out, '>', $seen_path or die $!;
print {$out} JSON::PP->new->canonical->pretty->encode(\@seen);
close $out or die $!;
die "selection mismatch\n" unless join("\0", sort @seen) eq join("\0", sort @$names);

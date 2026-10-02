package LiteralSignatureBaseline;
use strict;
use warnings;
use File::Spec ();
use Digest::SHA qw(sha256_hex);

# Load through PERL5OPT before the facade can prepend its own library directory.
# The only substituted module is the exact committed pre-fix splitter Core.
BEGIN {
    my $path = File::Spec->rel2abs(
        '.linkedspec-data/scratch/selfcontain13302131/baseline/perl/LinkedSpec/ActionIR/StatementSplit/Core.pm');
    open my $fh, '<', $path or die "missing owned baseline: $!";
    my $source = do { local $/; <$fh> };
    close $fh or die $!;
    my $expected = $ENV{LINKEDSPEC_SIGNATURE_BASELINE_SHA256}
        // die "baseline digest required";
    die "wrong baseline module bytes" unless sha256_hex($source) eq $expected;
    $INC{'LinkedSpec/ActionIR/StatementSplit/Core.pm'} = $path;
    require $path;
    die "wrong selected baseline" unless $INC{'LinkedSpec/ActionIR/StatementSplit/Core.pm'} eq $path;
}
1;

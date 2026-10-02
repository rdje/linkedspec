use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

# This independent process loads only the captured generated source.
my $out = '.linkedspec-data/scratch/selfcontain13302130';
my @rows;
open my $native_fh, '<', "$out/native.json" or die $!;
my $native_text = do { local $/; <$native_fh> };
close $native_fh or die $!;
my $native = JSON::PP->new->decode($native_text);
for my $row (@$native) {
    my $id = $row->{id};
    die "invalid capture id" unless $id =~ /\A[a-z][a-z-]*\z/;
    open my $fh, '<', "$out/$id.pl" or die $!;
    my $source = do { local $/; <$fh> };
    close $fh or die $!;
    (my $suffix = $id) =~ s/-/_/g;
    my $package = 'LiteralDiagnosis::' . $suffix;
    my $loaded = eval "package $package; $source\n1;";
    my $load_error = $loaded ? undef : "$@";
    my ($value, $error);
    if ($loaded) {
        my $input = 'x';
        my $ran = eval { no strict 'refs'; $value = &{"${package}::Execute"}(\$input); 1 };
        $error = "$@" unless $ran;
    }
    push @rows, { id => $id, emitted_sha256 => sha256_hex($source),
        value => $value, error => $error, load_error => $load_error };
}
open my $fh, '>', "$out/fresh.json" or die $!;
print {$fh} JSON::PP->new->canonical->pretty->encode(\@rows);
close $fh or die $!;

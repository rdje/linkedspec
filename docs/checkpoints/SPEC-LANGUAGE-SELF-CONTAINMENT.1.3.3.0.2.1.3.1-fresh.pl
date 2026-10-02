use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(blessed reftype);

sub plain {
    my ($value) = @_;
    return $value unless ref($value);
    my $type = reftype($value) // '';
    my $fields = $type eq 'HASH' ? {map { $_ => plain($value->{$_}) } keys %$value}
        : $type eq 'ARRAY' ? [map { plain($_) } @$value] : "$value";
    return blessed($value) ? {class => ref($value), fields => $fields} : $fields;
}

my $phase = shift // die "phase required";
die "invalid phase" unless $phase =~ /\A(?:red|green|restored-red|reapplied-green)\z/;
my $out = '.linkedspec-data/scratch/selfcontain13302131/' . $phase;
open my $fh, '<', "$out/native.json" or die $!;
my $native = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die $!;
my @rows;
for my $row (@$native) {
    my $id = $row->{id};
    die "invalid capture id" unless $id =~ /\A[a-z][a-z-]*\z/;
    open my $source_fh, '<', "$out/$id.pl" or die $!;
    my $source = do { local $/; <$source_fh> };
    close $source_fh or die $!;
    (my $suffix = $id) =~ s/-/_/g;
    my $package = 'SignatureRepair::' . $suffix;
    my $loaded = eval "package $package; $source\n1;";
    my $load_error = $loaded ? undef : "$@";
    my ($value, $error);
    if ($loaded) {
        my $input = 'x';
        my $ran = eval { no strict 'refs'; $value = &{"${package}::Execute"}(\$input); 1 };
        $error = plain($@) unless $ran;
    }
    push @rows, {id => $id, emitted_sha256 => sha256_hex($source),
        value => $value, error => $error, load_error => $load_error};
}
open my $out_fh, '>', "$out/fresh.json" or die $!;
print {$out_fh} JSON::PP->new->canonical->pretty->encode(\@rows);
close $out_fh or die $!;

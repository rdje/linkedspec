use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use File::Path qw(make_path);

my $out = '.linkedspec-data/scratch/selfcontain13302131/book';
my $mode = shift // 'parent';
if ($mode eq 'child') {
    my $id = shift;
    die "invalid book case" unless defined($id) && $id =~ /\A[0-2]\z/;
    open my $fh, '<', "$out/$id.pl" or die $!;
    my $source = do { local $/; <$fh> };
    close $fh or die $!;
    my $package = 'SignatureBook::Case' . $id;
    my $loaded = eval "package $package; $source\n1;";
    my $load_error = $loaded ? undef : "$@";
    my ($value, $error);
    if ($loaded) {
        my $input = 'x';
        my $ran = eval { no strict 'refs'; $value = &{"${package}::Execute"}(\$input); 1 };
        $error = "$@" unless $ran;
    }
    print JSON::PP->new->canonical->encode({value => $value, error => $error,
        load_error => $load_error, emitted_sha256 => sha256_hex($source)});
    exit;
}
die "unknown mode" unless $mode eq 'parent';
require LinkedSpec;
make_path($out);
my $book = 'docs/linkedspec-book/src/architecture/structured-format-program.md';
open my $fh, '<', $book or die $!;
my $text = do { local $/; <$fh> };
close $fh or die $!;
my ($section) = $text =~ /#### Callable signature pipes in Perl action splitting\n(.*?)\n### Neutral fixtures/s;
die "book section missing" unless defined($section);
my @sources = $section =~ /```spec\n(.*?)```/sg;
die "unexpected book source inventory" unless @sources == 3;
my @rows;
for my $id (0 .. $#sources) {
    my $source = $sources[$id];
    my %ctx;
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
    my $input = 'x';
    my $value = $parser->(\$input);
    die "native book case$id failed" unless defined($value) && $value eq 'ok' && !$ctx{last_error};
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "signature-book-$id.spec");
    open my $source_fh, '>', "$out/$id.pl" or die $!;
    print {$source_fh} $emitted;
    close $source_fh or die $!;
    open my $child, '-|', $^X, '-Iperl', __FILE__, 'child', $id or die $!;
    my $child_text = do { local $/; <$child> };
    close $child or die "fresh book child$id failed";
    my $fresh = JSON::PP->new->decode($child_text);
    die "fresh book case$id failed" unless ($fresh->{value} // '') eq 'ok'
        && !defined($fresh->{load_error}) && !defined($fresh->{error})
        && $fresh->{emitted_sha256} eq sha256_hex($emitted);
    push @rows, {id => $id, source => $source, source_sha256 => sha256_hex($source),
        native => $value, fresh => $fresh, emitted => $emitted};
}
open my $result_fh, '>', "$out/results.json" or die $!;
print {$result_fh} JSON::PP->new->canonical->pretty->encode(\@rows);
close $result_fh or die $!;
print "three verbatim book sources pass native and fresh emitted execution\n";

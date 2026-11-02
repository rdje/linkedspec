use strict;
use warnings;
use Test::More;
use Digest::SHA qw(sha256_hex);
use File::Spec;
use File::Temp qw(tempdir);
use JSON::PP ();
use FindBin qw($RealBin);
use lib "$RealBin/../tools/lib";
use LinkedSpec::DocumentHistoryCatalog qw(read_catalog write_catalog read_history_segment check_catalog_store);

die "run through tools/project_data_run.sh\n" unless $ENV{LINKEDSPEC_RUN_ACTIVE} && $ENV{TMPDIR};
my $directory = File::Spec->abs2rel(tempdir('history-catalog-XXXXXXXX', DIR => $ENV{TMPDIR}, CLEANUP => 1), '.');
my $manifest = "$directory/manifest.jsonl";
my $json = JSON::PP->new->canonical(1)->utf8(1);

sub write_bytes {
    my ($path, $raw) = @_;
    open my $fh, '>:raw', $path or die $!;
    print {$fh} $raw or die $!;
    close $fh or die $!;
}
sub bytes {
    open my $fh, '<:raw', $_[0] or die $!;
    local $/;
    return <$fh>;
}
sub encoded { return join('', map { $json->encode($_)."\n" } @_); }
sub rejects {
    my ($name, $code, $pattern) = @_;
    my $ok = eval { $code->(); 1 };
    ok(!$ok, $name);
    like($@, $pattern, "$name distinguishing reason");
}
sub row {
    my ($id) = @_;
    my $raw = "fixture$id\n";
    my $sha = sha256_hex($raw);
    my $target = "$directory/segment-$id-".substr($sha,0,12).'.md';
    write_bytes($target, $raw);
    return {type => 'segment', surface => 'change_history', current_path => 'CHANGES.md',
        source_path => 'CHANGES.md', source_commit => 'a' x 40, source_blob => 'b' x 40,
        source_start_line => 1, source_end_line => 1, line_count => 1, byte_count => length($raw),
        segment_id => "$id", sha256 => $sha, target_path => $target, immutable => JSON::PP::true,
        retrieval_command => "perl tools/read_document_history.pl --surface change_history --segment $id"};
}
my @records = map { row(sprintf('%04d', $_)) } 990 .. 1056;
my $metadata = {type => 'document_history', schema_version => 1, surface => 'change_history',
    current_path => 'CHANGES.md', authority => 'docs/decisions/0066-bounded-live-document-store.md',
    max_segment_lines => 4096, max_segment_bytes => 524288, source_order => 'reverse-chronological',
    segment_count => scalar(@records)};
write_bytes($manifest, encoded($metadata, @records));
my ($old_meta, $old_rows) = read_catalog($manifest);
my $logical = encoded($old_meta, @$old_rows);
my $history = join('', map { read_history_segment($_) } @$old_rows);
is(scalar(@$old_rows), 67, 'legacy manifest remains readable');
write_catalog($manifest, $old_meta, $old_rows);
my ($new_meta, $new_rows) = read_catalog($manifest);
is(encoded($new_meta, @$new_rows), $logical, 'catalog preserves every ordered record and metadata value');
is(join('', map { read_history_segment($_) } @$new_rows), $history, 'exact history bytes preserved');
cmp_ok(scalar(split /\n/, bytes($manifest)), '<=', 33, 'root is bounded across ID buckets');
ok(check_catalog_store($manifest, $new_rows), 'complete catalog store validates');
my $root_before = bytes($manifest);
my @pages_before = sort glob("$directory/catalog/*.jsonl");
my %pages_before = map { $_ => bytes($_) } @pages_before;
write_catalog($manifest, $new_meta, $new_rows);
is(bytes($manifest), $root_before, 'repeated publication is deterministic');
is_deeply([sort glob("$directory/catalog/*.jsonl")], \@pages_before, 'repeated publication adds no pages');

my @added = (row('0989'), @$new_rows);
my $advanced = {%$new_meta, segment_count => scalar(@added)};
write_catalog($manifest, $advanced, \@added);
my (undef, $current) = read_catalog($manifest);
is(scalar(@$current), 68, 'new segment admitted without rewriting old pages');
is_deeply({map { $_ => bytes($_) } @pages_before}, \%pages_before, 'old immutable pages stay byte-exact');
my ($prior_meta, $prior_rows) = read_catalog($manifest, sub {
    my ($path) = @_;
    return $path eq $manifest ? $root_before : bytes($path);
});
is(encoded($prior_meta, @$prior_rows), $logical, 'old root still resolves after new publication');
ok(check_catalog_store($manifest, $current), 'retained old catalog pages remain declared subsets');
rejects('dropping retained rows', sub { check_catalog_store($manifest, [@$current[1 .. $#$current]]) },
    qr/not retained/);
my $valid = bytes($manifest);
rejects('producer count mismatch', sub { write_catalog($manifest, {%$advanced, segment_count => 1}, $current) },
    qr/producer segment count/);
is(bytes($manifest), $valid, 'bad producer leaves live root unchanged');
my @bad_order = reverse @$current;
rejects('producer ordering mismatch', sub { write_catalog($manifest, $advanced, \@bad_order) },
    qr/not positive and contiguous/);
is(bytes($manifest), $valid, 'bad order leaves live root unchanged');

for my $case (
    ['extra metadata', {%$advanced, surprise => 1}],
    ['wrong metadata type', {%$advanced, type => 'not_history'}],
    ['unsupported metadata version', {%$advanced, schema_version => 99}],
) {
    my ($name, $bad) = @$case;
    rejects("producer $name", sub { write_catalog($manifest, $bad, $current) }, qr/metadata schema/);
    is(bytes($manifest), $valid, "producer $name preserves published root");
    write_bytes($manifest, $valid);
}

my $root_rows = [map { $json->decode($_) } split /\n/, $valid];
my $page = $root_rows->[1]{target_path};
my $page_bytes = bytes($page);
write_bytes($page, $page_bytes."changed\n");
rejects('page corruption', sub { read_catalog($manifest) }, qr/page identity mismatch/);
write_bytes($page, $page_bytes);
rename $page, "$page.saved" or die $!;
rejects('missing page', sub { read_catalog($manifest) }, qr/cannot read/);
rename "$page.saved", $page or die $!;
write_bytes("$directory/catalog/rogue.txt", 'undeclared');
rejects('undeclared store member', sub { check_catalog_store($manifest, $current) }, qr/unknown catalog store member/);
unlink "$directory/catalog/rogue.txt" or die $!;

my $target = $current->[0]{target_path};
my $target_bytes = bytes($target);
write_bytes($target, $target_bytes.'changed');
rejects('segment corruption', sub { read_history_segment($current->[0]) }, qr/segment identity mismatch/);
write_bytes($target, $target_bytes);
rename $target, "$target.saved" or die $!;
symlink "$target.saved", $target or die $!;
rejects('symbolic segment', sub { read_history_segment($current->[0]) }, qr/symbolic catalog path/);
unlink $target or die $!;
rename "$target.saved", $target or die $!;

my $numeric_string = {%$metadata, segment_count => $json->decode('"67"')};
write_bytes($manifest, encoded($numeric_string, @records));
rejects('numeric string metadata', sub { read_catalog($manifest) }, qr/metadata schema/);
my $duplicate = encoded($metadata, @records);
$duplicate =~ s/"type":"document_history"/"type":"document_history","type":"document_history"/;
write_bytes($manifest, $duplicate);
rejects('duplicate JSON key', sub { read_catalog($manifest) }, qr/noncanonical/);
write_bytes($manifest, encoded({%$metadata, segment_count => 68}, @records, $records[-1]));
rejects('duplicate segment', sub { read_catalog($manifest) }, qr/duplicate segment identity/);
write_bytes($manifest, $valid);
ok(check_catalog_store($manifest, $current), 'restored complete store passes');
done_testing();

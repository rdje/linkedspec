#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my $TREE = 'FUTURE-PARITY-BACKLOG';
my $SOURCE_PATH = 'docs/tasks/FUTURE-PARITY-BACKLOG.md';
my $INDEX_PATH = 'docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl';
my $HISTORY_PATH = 'docs/tasks/FUTURE-PARITY-BACKLOG.history.md';
my $AUTHORITY = 'docs/decisions/0084-future-parity-task-partition-capacity.md';
my $JSON = JSON::PP->new->canonical(1)->utf8(1);

my $source_commit;
GetOptions('source-commit=s' => \$source_commit) or die usage();
die usage() if !defined($source_commit) || $source_commit !~ /\A[0-9a-f]{40}\z/;

my @PARTS = (
    ['00-08',    'docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md',   '0',    '8',    1, ['76-3183', '23623-24107']],
    ['09',       'docs/tasks/FUTURE-PARITY-BACKLOG.09.md',      '9',    '9',    1, ['3184-6779']],
    ['10.0-6',   'docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md',  '10',   '10.6', 1, ['6780-10967']],
    ['10.7-10',  'docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md', '10.7', '10.10',1, ['10968-15106']],
    ['11-13',    'docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md',   '11',   '13',   1, ['15107-17122']],
    ['14.0-6.4', 'docs/tasks/FUTURE-PARITY-BACKLOG.14.md',      '14',   '14.6.4', 1, ['17123-21064']],
    ['14.6.5-8', 'docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md','14.6.5','14.8', 1, ['21065-21074']],
    ['15-24',    'docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md',   '15',   '24',   1, ['21075-22878']],
    ['history',  $HISTORY_PATH,                                  undef,  undef,   0, ['22955-23622', '24308-26979']],
);
my @ROOT_SOURCE_RANGES = ('1-75', '22879-22954', '24108-24307');

chdir $ROOT or die "cannot enter repository root: $!\n";
die "task-tree index already exists: $INDEX_PATH\n" if -e $INDEX_PATH;
for my $part (@PARTS) {
    die "task-tree partition already exists: $part->[1]\n" if -e $part->[1];
}

my $source = git_bytes('show', "$source_commit:$SOURCE_PATH");
my $source_blob = git_bytes('rev-parse', "$source_commit:$SOURCE_PATH");
$source_blob =~ s/\n\z//;
die "source blob is not a full Git object id\n" if $source_blob !~ /\A[0-9a-f]{40}\z/;
my @lines = split /(?<=\n)/, $source;
die "unexpected clean task-tree line count: " . scalar(@lines) . "\n" if @lines != 26_979;
die "unexpected clean task-tree byte count: " . length($source) . "\n" if length($source) != 2_720_175;
die "unexpected clean task-tree SHA-256\n"
    if sha256_hex($source) ne '48de44a56bcde1ae6d5e274e2786d939b596d2063756f994d4cfb407be4b3f95';

my @records;
my %output;
for my $part (@PARTS) {
    my ($id, $path, $prefix_start, $prefix_end, $mutable, $ranges) = @$part;
    my $source_bytes = ranges_bytes(\@lines, $ranges);
    my $bytes = $source_bytes;
    $bytes .= "<!-- Source ranges and their immutable migration digest are recorded in $INDEX_PATH. -->\n"
        if $mutable;
    $output{$path} = $bytes;
    push @records, {
        byte_count        => length($bytes),
        line_count        => line_count($bytes),
        mutable           => $mutable ? JSON::PP::true : JSON::PP::false,
        partition_id      => $id,
        path              => $path,
        prefix_end        => $prefix_end,
        prefix_start      => $prefix_start,
        retrieval_command => $mutable
            ? "perl tools/read_task_tree.pl --tree $TREE --id FUTURE-PARITY-BACKLOG." . lookup_example($id)
            : "sed -n '1,160p' $HISTORY_PATH",
        sha256            => sha256_hex($bytes),
        source_ranges     => $ranges,
        source_sha256     => sha256_hex($source_bytes),
        tree              => $TREE,
        type              => 'task_tree_part',
    };
}

my $root_source = ranges_bytes(\@lines, \@ROOT_SOURCE_RANGES);
my $navigation = navigation_text();
my $root = range_bytes(\@lines, '1-75') . $navigation
    . range_bytes(\@lines, '22879-22954')
    . range_bytes(\@lines, '24108-24307')
    . "<!-- Historical verification, commit, and changelog evidence continues through the indexed history part. -->\n";
$output{$SOURCE_PATH} = $root;

my $metadata = {
    authority            => $AUTHORITY,
    history_path         => $HISTORY_PATH,
    max_member_bytes     => 786_432,
    max_member_lines     => 5_000,
    part_count           => 9,
    retrieval_command    => "perl tools/read_task_tree.pl --tree $TREE --id <stable-id>",
    root_path            => $SOURCE_PATH,
    root_source_ranges   => \@ROOT_SOURCE_RANGES,
    root_source_sha256   => sha256_hex($root_source),
    schema_version       => 1,
    semantic_part_count  => 8,
    source_blob          => $source_blob,
    source_byte_count    => length($source),
    source_commit        => $source_commit,
    source_line_count    => scalar(@lines),
    source_path          => $SOURCE_PATH,
    source_sha256        => sha256_hex($source),
    tree                 => $TREE,
    type                 => 'task_tree_index',
    update_command       => "perl tools/update_task_tree_index.pl --tree $TREE",
};
$output{$INDEX_PATH} = join('', map { $JSON->encode($_) . "\n" } ($metadata, @records));

validate_output(\%output, \@records);
for my $path (sort grep { $_ ne $SOURCE_PATH } keys %output) {
    write_atomic($path, $output{$path});
}
write_atomic($SOURCE_PATH, $output{$SOURCE_PATH});

print "task-tree-partitions: wrote bounded $TREE root, 8 semantic parts, 1 immutable history part, and schema-v1 index\n";

sub usage {
    return "usage: perl tools/build_task_tree_partitions.pl --source-commit 40HEX\n";
}

sub lookup_example {
    my ($id) = @_;
    return '0' if $id eq '00-08';
    return '9' if $id eq '09';
    return '10.2' if $id eq '10.0-6';
    return '10.10' if $id eq '10.7-10';
    return '11' if $id eq '11-13';
    return '14' if $id eq '14.0-6.4';
    return '14.6.5' if $id eq '14.6.5-8';
    return '24' if $id eq '15-24';
    die "no lookup example for $id\n";
}

sub navigation_text {
    return <<'TEXT';
### Semantic Part Index

The stable root is a bounded current index. Every task ID remains unchanged and lives in exactly one semantic
part; superseded frontier narrative plus legacy global verification, commit, and changelog logs live in the
immutable history part. The strict machine index is `docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl`.

| Stable task prefix | Owning part |
| --- | --- |
| `.0-.8` | [`FUTURE-PARITY-BACKLOG.00-08.md`](FUTURE-PARITY-BACKLOG.00-08.md) |
| `.9` | [`FUTURE-PARITY-BACKLOG.09.md`](FUTURE-PARITY-BACKLOG.09.md) |
| `.10`, `.10.0-.6` | [`FUTURE-PARITY-BACKLOG.10.0-6.md`](FUTURE-PARITY-BACKLOG.10.0-6.md) |
| `.10.7-.10` | [`FUTURE-PARITY-BACKLOG.10.7-10.md`](FUTURE-PARITY-BACKLOG.10.7-10.md) |
| `.11-.13` | [`FUTURE-PARITY-BACKLOG.11-13.md`](FUTURE-PARITY-BACKLOG.11-13.md) |
| `.14`, `.14.0-.14.6.4` | [`FUTURE-PARITY-BACKLOG.14.md`](FUTURE-PARITY-BACKLOG.14.md) |
| `.14.6.5-.14.8` | [`FUTURE-PARITY-BACKLOG.14.6.5-8.md`](FUTURE-PARITY-BACKLOG.14.6.5-8.md) |
| `.15-.24` | [`FUTURE-PARITY-BACKLOG.15-24.md`](FUTURE-PARITY-BACKLOG.15-24.md) |
| Legacy global history | [`FUTURE-PARITY-BACKLOG.history.md`](FUTURE-PARITY-BACKLOG.history.md) |

Retrieve the bounded owner of any stable ID from any working directory:

```bash
perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.3.1.1
```

Update same-commit mutable-part counts and digests after an owning task edit:

```bash
perl tools/update_task_tree_index.pl --tree FUTURE-PARITY-BACKLOG
```

TEXT
}

sub ranges_bytes {
    my ($lines, $ranges) = @_;
    return join('', map { range_bytes($lines, $_) } @$ranges);
}

sub range_bytes {
    my ($lines, $range) = @_;
    my ($start, $end) = $range =~ /\A([0-9]+)-([0-9]+)\z/
        or die "invalid source range: $range\n";
    die "source range is outside input: $range\n" if $start < 1 || $end < $start || $end > @$lines;
    return join('', @$lines[$start - 1 .. $end - 1]);
}

sub line_count {
    my ($bytes) = @_;
    return 0 if $bytes eq '';
    my $count = () = $bytes =~ /\n/g;
    ++$count if $bytes !~ /\n\z/;
    return $count;
}

sub validate_output {
    my ($output, $records) = @_;
    die "unexpected task-tree output count\n" if keys(%$output) != 11;
    die "unexpected task-tree part count\n" if @$records != 9;
    for my $record (@$records) {
        die "$record->{partition_id} exceeds 5,000 lines\n" if $record->{line_count} > 5_000;
        die "$record->{partition_id} exceeds 786,432 bytes\n" if $record->{byte_count} > 786_432;
    }
    my $root = $output->{$SOURCE_PATH};
    die "bounded root exceeds 5,000 lines\n" if line_count($root) > 5_000;
    die "bounded root exceeds 786,432 bytes\n" if length($root) > 786_432;
}

sub git_bytes {
    my (@args) = @_;
    open my $fh, '-|', 'git', '-C', $ROOT, @args or die "cannot run git @args: $!\n";
    binmode $fh;
    local $/;
    my $bytes = <$fh>;
    close $fh or die "git @args failed\n";
    return defined($bytes) ? $bytes : '';
}

sub write_atomic {
    my ($path, $bytes) = @_;
    my $temporary = "$path.task-tree-build.$$";
    die "temporary output already exists: $temporary\n" if -e $temporary;
    open my $fh, '>:raw', $temporary or die "cannot write $temporary: $!\n";
    print {$fh} $bytes or die "cannot write $temporary: $!\n";
    close $fh or die "cannot close $temporary: $!\n";
    rename $temporary, $path or die "cannot install $path: $!\n";
}

#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my %INDEX = (
    'FUTURE-PARITY-BACKLOG' => 'docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl',
);
my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my $tree;
GetOptions('tree=s' => \$tree) or die usage();
die usage() if !defined($tree) || !exists($INDEX{$tree});

chdir $ROOT or die "cannot enter repository root: $!\n";
my $path = $INDEX{$tree};
my $records = read_index($path);
my $metadata = shift @$records;
die "task-tree index tree mismatch\n" if ($metadata->{tree} // '') ne $tree;

for my $record (@$records) {
    next if !JSON::PP::is_bool($record->{mutable}) || !$record->{mutable};
    my $part_path = $record->{path};
    die "unsafe or symbolic task-tree partition: $part_path\n"
        if !safe_path($part_path) || path_has_symlink($part_path);
    my $bytes = read_bytes($part_path);
    die "$part_path exceeds 5,000 lines\n" if line_count($bytes) > 5_000;
    die "$part_path exceeds 786,432 bytes\n" if length($bytes) > 786_432;
    $record->{line_count} = line_count($bytes);
    $record->{byte_count} = length($bytes);
    $record->{sha256} = sha256_hex($bytes);
}

my $updated = join('', map { $JSON->encode($_) . "\n" } ($metadata, @$records));
write_atomic($path, $updated);
print "task-tree-index: refreshed mutable counts and digests for $tree\n";

sub usage {
    return "usage: perl tools/update_task_tree_index.pl --tree TREE\n";
}

sub read_index {
    my ($path) = @_;
    die "unsafe or symbolic task-tree index\n" if !safe_path($path) || path_has_symlink($path);
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    my @records;
    while (my $line = <$fh>) {
        die "blank task-tree index record\n" if $line eq "\n";
        my $record = eval { JSON::PP->new->utf8(1)->decode($line) };
        die "invalid task-tree index record\n" if !$record || $@ || ref($record) ne 'HASH';
        push @records, $record;
    }
    close $fh or die "cannot close $path: $!\n";
    die "task-tree index must contain metadata plus eight parts\n" if @records != 9;
    return \@records;
}

sub line_count {
    my ($bytes) = @_;
    return 0 if $bytes eq '';
    my $count = () = $bytes =~ /\n/g;
    ++$count if $bytes !~ /\n\z/;
    return $count;
}

sub safe_path {
    my ($path) = @_;
    return defined($path) && !ref($path) && $path ne '' && $path !~ m{\A/}
        && $path !~ m{(?:\A|/)\.\.?(?:/|\z)} && $path !~ m{//} && $path !~ /\\/ && $path !~ /\0/;
}

sub path_has_symlink {
    my ($path) = @_;
    return 1 if !safe_path($path);
    my $cursor = '';
    for my $part (split m{/}, $path) {
        $cursor = $cursor eq '' ? $part : "$cursor/$part";
        return 1 if -l $cursor;
    }
    return 0;
}

sub read_bytes {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    local $/;
    my $bytes = <$fh>;
    close $fh or die "cannot close $path: $!\n";
    return defined($bytes) ? $bytes : '';
}

sub write_atomic {
    my ($path, $bytes) = @_;
    my $temporary = "$path.task-tree-update.$$";
    die "temporary output already exists: $temporary\n" if -e $temporary;
    open my $fh, '>:raw', $temporary or die "cannot write $temporary: $!\n";
    print {$fh} $bytes or die "cannot write $temporary: $!\n";
    close $fh or die "cannot close $temporary: $!\n";
    rename $temporary, $path or die "cannot install $path: $!\n";
}

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
my ($tree, $id);
GetOptions('tree=s' => \$tree, 'id=s' => \$id) or die usage();
die usage() if !defined($tree) || !exists($INDEX{$tree}) || !defined($id);
die "task id is not a stable child of $tree\n"
    if $id !~ /\A\Q$tree\E(?:\.[0-9]+)+\z/;

chdir $ROOT or die "cannot enter repository root: $!\n";
my $records = read_index($INDEX{$tree});
shift @$records;
my ($owner) = grep { owns_id($_, $id) } @$records;
die "no semantic partition owns task id $id\n" if !$owner;
my @owners = grep { owns_id($_, $id) } @$records;
die "multiple semantic partitions own task id $id\n" if @owners != 1;

my $path = $owner->{path};
die "unsafe or symbolic task-tree partition: $path\n" if !safe_path($path) || path_has_symlink($path);
my $bytes = read_bytes($path);
die "task-tree partition digest is stale: $path\n" if sha256_hex($bytes) ne ($owner->{sha256} // '');
die "task id is absent from its owning partition: $id\n"
    if $bytes !~ /^- ID: `\Q$id\E`\s*$/m;
binmode STDOUT, ':raw';
print $bytes;

sub usage {
    return "usage: perl tools/read_task_tree.pl --tree TREE --id STABLE-ID\n";
}

sub owns_id {
    my ($record, $id) = @_;
    return 0 if !JSON::PP::is_bool($record->{mutable}) || !$record->{mutable};
    my $suffix = substr($id, length($tree) + 1);
    my @numbers = map { 0 + $_ } split /\./, $suffix;
    my $top = $numbers[0];
    my $partition = $record->{partition_id} // '';
    return $top <= 8 if $partition eq '00-08';
    return $top == 9 if $partition eq '09';
    return $top == 10 && (!defined($numbers[1]) || $numbers[1] <= 6) if $partition eq '10.0-6';
    return $top == 10 && defined($numbers[1]) && $numbers[1] >= 7 if $partition eq '10.7-10';
    return $top >= 11 && $top <= 13 if $partition eq '11-13';
    return $top == 14 if $partition eq '14';
    return $top >= 15 && $top <= 24 if $partition eq '15-24';
    return 0;
}

sub read_index {
    my ($path) = @_;
    die "unsafe or symbolic task-tree index\n" if !safe_path($path) || path_has_symlink($path);
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    my @records;
    my $line_number = 0;
    while (my $line = <$fh>) {
        ++$line_number;
        die "blank task-tree index record at $path:$line_number\n" if $line eq "\n";
        my $record = eval { JSON::PP->new->utf8(1)->decode($line) };
        die "invalid task-tree index record at $path:$line_number\n"
            if !$record || $@ || ref($record) ne 'HASH';
        push @records, $record;
    }
    close $fh or die "cannot close $path: $!\n";
    die "task-tree index must contain metadata plus eight parts\n" if @records != 9;
    return \@records;
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

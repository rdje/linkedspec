#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my %MANIFEST = (
    live_status       => 'docs/history/live-achievement-status/manifest.jsonl',
    change_history    => 'docs/history/changes/manifest.jsonl',
    engineering_notes => 'docs/history/development-notes/manifest.jsonl',
);
my ($surface, $all, $segment, $grep_literal);
GetOptions(
    'surface=s' => \$surface,
    'all'       => \$all,
    'segment=s' => \$segment,
    'grep=s'    => \$grep_literal,
) or die usage();
die usage() if !defined($surface) || !exists($MANIFEST{$surface});
my $modes = ($all ? 1 : 0) + (defined($segment) ? 1 : 0) + (defined($grep_literal) ? 1 : 0);
die usage() if $modes != 1;
die "segment id must be four decimal digits\n" if defined($segment) && $segment !~ /\A[0-9]{4}\z/;

chdir $ROOT or die "cannot enter repository root: $!\n";
my $records = read_manifest($MANIFEST{$surface});
my $metadata = shift @$records;
die "manifest surface mismatch\n" if ($metadata->{surface} // '') ne $surface;

binmode STDOUT, ':raw';
if ($all) {
    print read_target($_->{target_path}) for @$records;
    exit 0;
}
if (defined $segment) {
    my ($record) = grep { ($_->{segment_id} // '') eq $segment } @$records;
    die "unknown segment for $surface: $segment\n" if !$record;
    print read_target($record->{target_path});
    exit 0;
}

for my $record (@$records) {
    my $bytes = read_target($record->{target_path});
    my @lines = split /(?<=\n)/, $bytes;
    for my $index (0 .. $#lines) {
        next if index($lines[$index], $grep_literal) < 0;
        print "$record->{segment_id}:" . ($index + 1) . ":$lines[$index]";
        print "\n" if $lines[$index] !~ /\n\z/;
    }
}

sub usage {
    return "usage: perl tools/read_document_history.pl --surface ID "
        . "(--all | --segment NNNN | --grep LITERAL)\n";
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

sub read_manifest {
    my ($path) = @_;
    die "unsafe manifest path\n" if !safe_path($path);
    die "manifest path is symbolic: $path\n" if path_has_symlink($path);
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    my @records;
    my $line_number = 0;
    while (my $line = <$fh>) {
        ++$line_number;
        die "blank manifest record at $path:$line_number\n" if $line eq "\n";
        my $record = eval { JSON::PP->new->utf8(1)->decode($line) };
        die "invalid manifest record at $path:$line_number\n" if !$record || $@ || ref($record) ne 'HASH';
        push @records, $record;
    }
    close $fh or die "cannot close $path: $!\n";
    die "empty manifest: $path\n" if !@records;
    return \@records;
}

sub read_target {
    my ($path) = @_;
    die "unsafe segment path\n" if !safe_path($path);
    die "segment path is symbolic: $path\n" if path_has_symlink($path);
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    local $/;
    my $bytes = <$fh>;
    close $fh or die "cannot close $path: $!\n";
    return defined($bytes) ? $bytes : '';
}

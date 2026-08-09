#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();
use File::Path qw(make_path);

my $ROOT = "$RealBin/..";
my $MAX_LINES = 4_096;
my $MAX_BYTES = 524_288;
my $AUTHORITY = 'docs/decisions/0066-bounded-live-document-store.md';
my $JSON = JSON::PP->new->canonical(1)->utf8(1);

my ($surface, $family, $source_path, $source_commit, $current_path);
my $segment_base = 1;
my $source_order = 'source-file';
GetOptions(
    'surface=s'       => \$surface,
    'family=s'        => \$family,
    'source-path=s'   => \$source_path,
    'source-commit=s' => \$source_commit,
    'current-path=s'  => \$current_path,
    'segment-base=i'  => \$segment_base,
    'source-order=s'  => \$source_order,
) or die usage();
die usage() if grep { !defined($_) || $_ eq '' }
    ($surface, $family, $source_path, $source_commit, $current_path);

safe_token($surface, 'surface');
safe_token($family, 'family');
safe_path($source_path, 'source path');
safe_path($current_path, 'current path');
die "source commit must be a full lowercase Git object id\n"
    if $source_commit !~ /\A[0-9a-f]{40}\z/;
die "segment base must be between 1 and 9999\n"
    if $segment_base < 1 || $segment_base > 9_999;
die "source order must be source-file or reverse-chronological\n"
    if $source_order ne 'source-file' && $source_order ne 'reverse-chronological';

chdir $ROOT or die "cannot enter repository root: $!\n";
my $output_dir = "docs/history/$family";
die "history output already exists: $output_dir\n" if -e $output_dir;

my $source = git_bytes('show', "$source_commit:$source_path");
my $source_blob = git_text('rev-parse', "$source_commit:$source_path");
chomp $source_blob;
die "source blob is not a full Git object id\n" if $source_blob !~ /\A[0-9a-f]{40}\z/;

my @lines = split /(?<=\n)/, $source;
my @segments;
my $segment = '';
my $segment_lines = 0;
my $start_line = 1;
for my $line (@lines) {
    my $line_bytes = length($line);
    die "source line exceeds the segment byte ceiling at line " . ($start_line + $segment_lines) . "\n"
        if $line_bytes > $MAX_BYTES;
    if ($segment_lines && ($segment_lines + 1 > $MAX_LINES || length($segment) + $line_bytes > $MAX_BYTES)) {
        push @segments, [$start_line, $segment_lines, $segment];
        $start_line += $segment_lines;
        $segment = '';
        $segment_lines = 0;
    }
    $segment .= $line;
    ++$segment_lines;
}
push @segments, [$start_line, $segment_lines, $segment] if $segment_lines;
die "source is empty; refusing to create an empty history snapshot\n" if !@segments;
die "segment ids would exceed four decimal digits\n"
    if $segment_base + @segments - 1 > 9_999;

make_path($output_dir) or die "cannot create $output_dir: $!\n";
my @records;
my $ordinal = 0;
for my $item (@segments) {
    my ($first, $count, $bytes) = @$item;
    ++$ordinal;
    my $segment_id = sprintf('%04d', $segment_base + $ordinal - 1);
    my $digest = sha256_hex($bytes);
    my $target = "$output_dir/segment-$segment_id-" . substr($digest, 0, 12) . '.md';
    write_bytes($target, $bytes);
    push @records, {
        byte_count         => length($bytes),
        current_path       => $current_path,
        immutable          => JSON::PP::true,
        line_count         => $count,
        retrieval_command  => "perl tools/read_document_history.pl --surface $surface --segment $segment_id",
        segment_id         => $segment_id,
        sha256             => $digest,
        source_blob        => $source_blob,
        source_commit      => $source_commit,
        source_end_line    => $first + $count - 1,
        source_path        => $source_path,
        source_start_line  => $first,
        surface            => $surface,
        target_path        => $target,
        type               => 'segment',
    };
}

my $metadata = {
    authority          => $AUTHORITY,
    current_path       => $current_path,
    max_segment_bytes  => $MAX_BYTES,
    max_segment_lines  => $MAX_LINES,
    schema_version     => 1,
    segment_count      => scalar(@records),
    source_order       => $source_order,
    surface            => $surface,
    type               => 'document_history',
};
my $manifest = join('', map { $JSON->encode($_) . "\n" } ($metadata, @records));
write_bytes("$output_dir/manifest.jsonl", $manifest);
print "document-history: wrote $surface from $source_commit:$source_path as "
    . scalar(@records) . " segment(s), " . length($source) . " bytes\n";

sub usage {
    return "usage: perl tools/build_document_history.pl --surface ID --family DIR --source-path PATH "
        . "--source-commit 40HEX --current-path PATH [--segment-base N] "
        . "[--source-order source-file|reverse-chronological]\n";
}

sub safe_token {
    my ($value, $label) = @_;
    die "$label is unsafe: $value\n" if $value !~ /\A[a-z][a-z0-9_-]*\z/;
}

sub safe_path {
    my ($path, $label) = @_;
    die "$label is unsafe: $path\n"
        if $path =~ m{\A/} || $path =~ m{(?:\A|/)\.\.?(?:/|\z)} || $path =~ m{//}
        || $path =~ /\\/ || $path =~ /\0/;
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

sub git_text {
    return git_bytes(@_);
}

sub write_bytes {
    my ($path, $bytes) = @_;
    open my $fh, '>:raw', $path or die "cannot write $path: $!\n";
    print {$fh} $bytes or die "cannot write $path: $!\n";
    close $fh or die "cannot close $path: $!\n";
}

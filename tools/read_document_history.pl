#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();
use lib "$RealBin/lib";
use LinkedSpec::DocumentHistoryCatalog qw(read_catalog read_history_segment);

my $ROOT = "$RealBin/..";
my %MANIFEST = (
    live_status       => 'docs/history/live-achievement-status/manifest.jsonl',
    change_history    => 'docs/history/changes/manifest.jsonl',
    engineering_notes => 'docs/history/development-notes/manifest.jsonl',
);
my ($surface, $all, $segment, $grep_literal, $catalog_json);
GetOptions(
    'surface=s' => \$surface,
    'all'       => \$all,
    'segment=s' => \$segment,
    'grep=s'    => \$grep_literal,
    'catalog-json' => \$catalog_json,
) or die usage();
die usage() if !defined($surface) || !exists($MANIFEST{$surface});
my $modes = ($all ? 1 : 0) + (defined($segment) ? 1 : 0) + (defined($grep_literal) ? 1 : 0) + ($catalog_json ? 1 : 0);
die usage() if $modes != 1;
die "segment id must be four decimal digits\n" if defined($segment) && $segment !~ /\A[0-9]{4}\z/;

chdir $ROOT or die "cannot enter repository root: $!\n";
my $records = read_manifest($MANIFEST{$surface});
my $metadata = shift @$records;
die "manifest surface mismatch\n" if ($metadata->{surface} // '') ne $surface;

binmode STDOUT, ':raw';
if ($catalog_json) {
    print JSON::PP->new->canonical(1)->utf8(1)->encode([$metadata, @$records]), "\n";
    exit 0;
}
if ($all) {
    print read_history_segment($_) for @$records;
    exit 0;
}
if (defined $segment) {
    my ($record) = grep { ($_->{segment_id} // '') eq $segment } @$records;
    die "unknown segment for $surface: $segment\n" if !$record;
    print read_history_segment($record);
    exit 0;
}

for my $record (@$records) {
    my $bytes = read_history_segment($record);
    my @lines = split /(?<=\n)/, $bytes;
    for my $index (0 .. $#lines) {
        next if index($lines[$index], $grep_literal) < 0;
        print "$record->{segment_id}:" . ($index + 1) . ":$lines[$index]";
        print "\n" if $lines[$index] !~ /\n\z/;
    }
}

sub usage {
    return "usage: perl tools/read_document_history.pl --surface ID "
        . "(--all | --segment NNNN | --grep LITERAL | --catalog-json)\n";
}

sub read_manifest {
    my ($path) = @_;
    my ($metadata, $segments) = read_catalog($path);
    return [$metadata, @$segments];
}

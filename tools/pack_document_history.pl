#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use lib "$RealBin/lib";
use LinkedSpec::DocumentHistoryCatalog qw(read_catalog write_catalog check_catalog_store);

my %PATH = (
    change_history => 'docs/history/changes/manifest.jsonl',
    engineering_notes => 'docs/history/development-notes/manifest.jsonl',
);
my ($surface, $apply);
GetOptions('surface=s' => \$surface, 'apply' => \$apply) or die usage();
die usage() unless defined($surface) && exists($PATH{$surface});
chdir "$RealBin/.." or die "cannot enter repository root: $!\n";
my ($metadata, $records) = read_catalog($PATH{$surface});
my $json = JSON::PP->new->canonical(1)->utf8(1);
my $before = $json->encode([$metadata, @$records]);
if ($apply) {
    write_catalog($PATH{$surface}, $metadata, $records);
    my ($actual_meta, $actual) = read_catalog($PATH{$surface});
    die "catalog conversion changed history metadata or ordered records\n"
        unless $before eq $json->encode([$actual_meta, @$actual]);
    check_catalog_store($PATH{$surface}, $actual);
}
print $json->encode({surface => $surface, applied => $apply ? JSON::PP::true : JSON::PP::false,
    segment_count => scalar(@$records), ordered_records_sha256 => sha256_hex($before)}), "\n";
sub usage {
    return "usage: perl tools/pack_document_history.pl --surface change_history|engineering_notes [--apply]\n";
}

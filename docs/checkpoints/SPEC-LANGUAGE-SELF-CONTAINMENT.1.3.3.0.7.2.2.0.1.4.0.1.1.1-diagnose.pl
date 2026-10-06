#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP ();

my $mode = shift @ARGV;
die "usage: diagnose.pl original|fixed\n" if !defined($mode) || $mode !~ /\A(?:original|fixed)\z/;
my $json = JSON::PP->new->canonical(1);
my $row = $json->decode('{"segment_id":"4966"}');
my $pending_id = $row->{segment_id};
my $before = $json->encode({segment_id => $pending_id});
my $eligible = $pending_id =~ /\A[0-9]{4}\z/ && 0 + $pending_id < 5_000;
my $coerced = $json->encode({segment_id => $pending_id});
$pending_id = sprintf('%04d', $pending_id) if $mode eq 'fixed';
my $expected = $json->encode({segment_id => $pending_id});
my $actual = $json->encode($row);
die "probe does not isolate numeric eligibility flags\n"
    if !$eligible || $before ne '{"segment_id":"4966"}'
    || $coerced ne '{"segment_id":4966}' || $actual ne $before;
print $json->encode({mode => $mode, before => $before, coerced => $coerced,
    expected => $expected, actual => $actual,
    comparison => $expected eq $actual ? JSON::PP::true : JSON::PP::false}), "\n";
exit($expected eq $actual ? 0 : 1);

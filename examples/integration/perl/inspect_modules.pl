#!/usr/bin/env perl
use strict;
use warnings;
no warnings 'once';

# Verification helper: write module provenance after running the real consumer.
# Invoke from the owning repository root with an explicit Perl -I path.
die "Usage: inspect_modules.pl REPORT CONSUMER GRAMMAR INPUT [INPUT ...]\n" unless @ARGV >= 4;
my ($report, $consumer) = splice @ARGV, 0, 2;
my $ok = do $consumer;
die "Consumer did not complete: $@ $!\n" unless defined($ok) && $ok;
my %loaded = %INC;
my @shared = @DynaLoader::dl_shared_objects;

require Cwd;
require Config;
require Module::CoreList;
require JSON::PP;
my $root = Cwd::abs_path('.');
my @modules;
for my $key (sort keys %loaded) {
    my $name = $key;
    $name =~ s{\.pm\z}{};
    $name =~ s{/}{::}g;
    my $path = Cwd::abs_path($loaded{$key});
    my $project_owned = index($path, "$root/") == 0;
    $path = substr($path, length($root) + 1) if $project_owned;
    push @modules, {
        key => $project_owned && $key !~ /\.pm\z/ ? $path : $key,
        path => $path,
        project_owned => $project_owned ? JSON::PP::true() : JSON::PP::false(),
        in_core_catalog => exists($Module::CoreList::version{$]}{$name})
            ? JSON::PP::true() : JSON::PP::false(),
    };
}
open my $fh, '>:raw', $report or die "$report: $!\n";
print {$fh} JSON::PP->new->utf8->canonical->pretty->encode({
    perl => "$^V", modules => \@modules, shared_objects => \@shared,
    core_library_roots => [$Config::Config{privlibexp}, $Config::Config{archlibexp}],
}) or die "$report: $!\n";
close $fh or die "$report: $!\n";

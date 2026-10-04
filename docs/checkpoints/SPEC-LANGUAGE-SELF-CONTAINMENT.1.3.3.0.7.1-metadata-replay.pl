use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::ActionIR::RawDependencies ();

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-';
open my $owner, '<', $prefix . 'before-compat-RawDependencies.pm' or die $!;
my $frozen = do { local $/; <$owner> };
close $owner;
$frozen =~ s/\Apackage LinkedSpec::ActionIR::RawDependencies;/package Checkpoint::FrozenRawDependencies;/
 or die 'Frozen collector package mismatch';
eval $frozen;
die $@ if $@;
my $json = JSON::PP->new->canonical->pretty->utf8;
my $requests = $json->decode(do { local $/; <STDIN> });
my @rows;
for my $request (@$requests) {
 my $old = Checkpoint::FrozenRawDependencies::collect_expression_dependencies(
  $request->{source}, $request->{events});
 my $new = LinkedSpec::ActionIR::RawDependencies::collect_expression_dependencies(
  $request->{source}, $request->{events});
 push @rows, {%$request, before => $old, after => $new};
}
print $json->encode(\@rows);

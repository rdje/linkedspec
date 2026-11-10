use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use Digest::SHA qw(sha256_hex);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

{
 package ScalarCopySnapshotArray;
 sub TIEARRAY { my ($class, $items, $trace) = @_; bless {items => $items, trace => $trace}, $class }
 sub FETCHSIZE { my ($self) = @_; push @{$self->{trace}}, ['size']; scalar @{$self->{items}} }
 sub FETCH { my ($self, $index) = @_; push @{$self->{trace}}, ['fetch', $index]; $self->{items}[$index] }
}

sub snapshot {
 my ($source) = @_;
 my $json = JSON::PP->new->canonical;
 my $nested = [1];
 my $hash = {nested => $nested};
 my $array = [2];
 my $items = [0, '', undef, $hash, $array, JSON::PP::false];
 my @trace;
 our @Top;
 local @Top;
 tie @Top, 'ScalarCopySnapshotArray', $items, \@trace;
 my $run = eval 'sub { '.$source.' }';
 die $@ unless $run;
 my $value = $run->();
 my $source_trace = [@trace];
 my $before = $json->decode($json->encode($value));
 my $outer_distinct = refaddr($value) != refaddr(\@Top) ? 1 : 0;
 my $hash_shared = ref($value->[3]) eq 'HASH' && refaddr($value->[3]) == refaddr($hash) ? 1 : 0;
 my $array_shared = ref($value->[4]) eq 'ARRAY' && refaddr($value->[4]) == refaddr($array) ? 1 : 0;
 $items->[0] = 9;
 $nested->[0] = 7;
 return {before => $before, outer_distinct => $outer_distinct, hash_shared => $hash_shared,
  array_shared => $array_shared, first_after_source_change => $value->[0],
  nested_after_shared_change => ref($value->[3]) eq 'HASH' ? $value->[3]{nested}[0] : undef,
  source_trace => $source_trace};
}

my $source = LinkedSpec::call_spec_handler_subst('Top', 'return(Top.copy())');
my $module = $INC{'LinkedSpec/ActionIR/MethodLowering.pm'};
open my $fh, '<:raw', $module or die $!;
my $raw = do {local $/; <$fh>};
close $fh or die $!;
my $json = JSON::PP->new->canonical;
print $json->encode({source => $source, ast => LinkedSpec::ActionIR::AST::parse_action_expr('Top.copy()'),
 module_sha256 => sha256_hex($raw), actual => snapshot($source), original_oracle => snapshot('return [@Top]'),
 controls => {empty => snapshot('return []'), alias => snapshot('return \\@Top'),
  repeated => snapshot('my @unused = @Top; return [@Top]'),
  lost_nested => snapshot('return [map {ref($_) eq "HASH" ? {} : $_} @Top]')},
}), "\n";

package LinkedSpec::RuntimeLogical;

use 5.010;
use strict;
use warnings;

use B ();
use JSON::PP ();
use POSIX ();
use Scalar::Util qw(blessed);

our $CONTRACT_ID = 'linkedspec-logical-helper-v1';

my $STRING_FLAGS = B::SVf_POK() | B::SVp_POK();
my $NUMERIC_FLAGS = B::SVf_IOK() | B::SVp_IOK() | B::SVf_NOK() | B::SVp_NOK();
my $IMMORTAL_NUMERIC_FLAGS = B::SVf_IOK() | B::SVf_NOK();

sub _number_is_truthy {
 my ($value) = @_;
 my $number = 0 + $value;
 return 0 unless POSIX::isfinite($number);
 return $number == 0 ? 0 : 1;
}

sub expected_arity {
 my ($helper) = @_;
 return 'at least 1 positional argument'
  if defined($helper) && ($helper eq 'and' || $helper eq 'or');
 return 'exactly 1 positional argument'
  if defined($helper) && $helper eq 'not';
 return undef
}

sub arity_is_valid {
 my ($helper, $actual) = @_;
 return 0 unless defined($actual) && $actual =~ /\A\d+\z/;
 return $actual >= 1 ? 1 : 0
  if defined($helper) && ($helper eq 'and' || $helper eq 'or');
 return $actual == 1 ? 1 : 0
  if defined($helper) && $helper eq 'not';
 return 0
}

sub truthy {
 my ($value) = @_;
 return 0 unless defined $value;

 if (ref($value)) {
  return $value ? 1 : 0
   if blessed($value) && $value->isa('JSON::PP::Boolean');
  return @$value ? 1 : 0 if ref($value) eq 'ARRAY';
  if (ref($value) eq 'HASH') {
   return 1 if ($value->{kind} // '') eq 'codeblock_literal';
   return keys(%$value) ? 1 : 0;
  }
  return 1;
 }

 my $flags = B::svref_2object(\$value)->FLAGS;
 # Perl's shared false/zero scalar (returned by false comparisons and an empty
 # array in scalar context) advertises string, integer, and floating-point
 # slots simultaneously.  It is nevertheless a numeric result.  Ordinary
 # strings numerically inspected by Perl retain only one public numeric slot,
 # so string identity still wins for values such as the nonempty string "0".
 return _number_is_truthy($value)
  if ($flags & $IMMORTAL_NUMERIC_FLAGS) == $IMMORTAL_NUMERIC_FLAGS;
 return length($value) ? 1 : 0 if $flags & $STRING_FLAGS;
 return _number_is_truthy($value) if $flags & $NUMERIC_FLAGS;
 return length($value) ? 1 : 0;
}

sub evaluate {
 my ($helper, $values) = @_;
 die "LINKEDSPEC_LOGICAL_RUNTIME_ERROR:invalid_values"
  unless ref($values) eq 'ARRAY';
 die "LINKEDSPEC_LOGICAL_RUNTIME_ERROR:invalid_arity"
  unless arity_is_valid($helper, scalar(@$values));

 if ($helper eq 'and') {
  foreach my $value (@$values) {
   return JSON::PP::false unless truthy($value);
  }
  return JSON::PP::true;
 }
 if ($helper eq 'or') {
  foreach my $value (@$values) {
   return JSON::PP::true if truthy($value);
  }
  return JSON::PP::false;
 }
 return truthy($values->[0]) ? JSON::PP::false : JSON::PP::true
  if $helper eq 'not';
 die "LINKEDSPEC_LOGICAL_RUNTIME_ERROR:unknown_helper";
}

1;

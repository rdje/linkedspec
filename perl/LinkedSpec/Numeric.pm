package LinkedSpec::Numeric;

use 5.010;
use strict;
use warnings;

use B ();
use POSIX ();

our $CONTRACT_ID = 'linkedspec-scalar-numeric-v1';

my $NUMERIC_FLAGS = B::SVp_IOK() | B::SVp_NOK();
my %UNARY_HELPER = map { $_ => 1 } qw(num_abs num_floor num_ceil num_round);
my %VARIADIC_HELPER = map { $_ => 1 } qw(num_add num_mul num_min num_max);
my %BINARY_HELPER = map { $_ => 1 } qw(num_sub num_div num_mod num_eq num_ne num_gt num_ge num_lt num_le);

sub scalar_number {
 my ($value) = @_;
 return undef unless defined($value) && !ref($value);
 my $flags = B::svref_2object(\$value)->FLAGS;
 my $number;
 if ($flags & $NUMERIC_FLAGS) {
  $number = 0 + $value;
 } elsif ($value =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/) {
  $number = 0 + $value;
 } else {
  return undef;
 }
 return POSIX::isfinite($number) ? $number : undef
}

sub _normalized {
 my ($value) = @_;
 return undef unless defined($value) && POSIX::isfinite($value);
 return 0 if $value == 0;
 return $value
}

sub evaluate {
 my ($helper, @args) = @_;
 return undef unless defined($helper);
 return undef if $UNARY_HELPER{$helper} && @args != 1;
 return undef if $VARIADIC_HELPER{$helper} && @args < 2;
 return undef if $BINARY_HELPER{$helper} && @args != 2;
 return undef if $helper eq 'num_clamp' && @args != 3;
 return undef unless $UNARY_HELPER{$helper} || $VARIADIC_HELPER{$helper} || $BINARY_HELPER{$helper}
  || $helper eq 'num_clamp';

 my @numbers;
 foreach my $arg (@args) {
  my $number = scalar_number($arg);
  return undef unless defined($number);
  push @numbers, $number;
 }

 my $result;
 if ($helper eq 'num_add') {
  $result = 0;
  $result += $_ for @numbers;
 } elsif ($helper eq 'num_mul') {
  $result = 1;
  $result *= $_ for @numbers;
 } elsif ($helper eq 'num_sub') {
  $result = $numbers[0] - $numbers[1];
 } elsif ($helper eq 'num_div') {
  return undef if $numbers[1] == 0;
  $result = $numbers[0] / $numbers[1];
 } elsif ($helper eq 'num_mod') {
  return undef if $numbers[1] == 0 || $numbers[0] != int($numbers[0]) || $numbers[1] != int($numbers[1]);
  $result = $numbers[0] - POSIX::floor($numbers[0] / $numbers[1]) * $numbers[1];
 } elsif ($helper eq 'num_abs') {
  $result = abs($numbers[0]);
 } elsif ($helper eq 'num_floor') {
  $result = POSIX::floor($numbers[0]);
 } elsif ($helper eq 'num_ceil') {
  $result = POSIX::ceil($numbers[0]);
 } elsif ($helper eq 'num_round') {
  $result = $numbers[0] >= 0 ? POSIX::floor($numbers[0] + 0.5) : POSIX::ceil($numbers[0] - 0.5);
 } elsif ($helper eq 'num_min') {
  $result = $numbers[0];
  foreach my $number (@numbers[1 .. $#numbers]) {
   $result = $number if $number < $result;
  }
 } elsif ($helper eq 'num_max') {
  $result = $numbers[0];
  foreach my $number (@numbers[1 .. $#numbers]) {
   $result = $number if $number > $result;
  }
 } elsif ($helper eq 'num_clamp') {
  return undef if $numbers[1] > $numbers[2];
  $result = $numbers[0] < $numbers[1] ? $numbers[1]
          : $numbers[0] > $numbers[2] ? $numbers[2]
          : $numbers[0];
 } elsif ($helper eq 'num_eq') {
  $result = $numbers[0] == $numbers[1] ? 1 : 0;
 } elsif ($helper eq 'num_ne') {
  $result = $numbers[0] != $numbers[1] ? 1 : 0;
 } elsif ($helper eq 'num_gt') {
  $result = $numbers[0] > $numbers[1] ? 1 : 0;
 } elsif ($helper eq 'num_ge') {
  $result = $numbers[0] >= $numbers[1] ? 1 : 0;
 } elsif ($helper eq 'num_lt') {
  $result = $numbers[0] < $numbers[1] ? 1 : 0;
 } elsif ($helper eq 'num_le') {
  $result = $numbers[0] <= $numbers[1] ? 1 : 0;
 }
 return _normalized($result)
}

1;

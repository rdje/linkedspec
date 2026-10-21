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
my %SYMBOL_HELPER = (
 '+' => 'num_add', '-' => 'num_sub', '*' => 'num_mul', '/' => 'num_div', '%' => 'num_mod',
 '==' => 'num_eq', '!=' => 'num_ne', '>' => 'num_gt', '>=' => 'num_ge', '<' => 'num_lt', '<=' => 'num_le',
);

sub scalar_helper_name {
 my ($name) = @_;
 return undef unless defined($name) && !ref($name);
 my $helper = $SYMBOL_HELPER{$name} // $name;
 $helper = 'num_'.$helper unless $helper =~ /\Anum_/;
 return $helper if $UNARY_HELPER{$helper} || $VARIADIC_HELPER{$helper}
  || $BINARY_HELPER{$helper} || $helper eq 'num_clamp';
 return undef
}

# Array reducers retain the existing Perl aggregate policy, independently of
# CONTRACT_ID: every term must match the legacy decimal spelling. In particular,
# this does not add scalar-number finite/boolean rules or normalize selected
# original min/max/odd-median terms (the separate result-kind repair owns those).
sub array_helper_name {
 my ($name) = @_;
 return undef unless defined($name) && !ref($name);
 my $helper = $name =~ /\Anum_/ ? $name : 'num_'.$name;
 return $helper if $helper =~ /\Anum_(?:sum|avg|median|range|min|max)\z/;
 return undef
}

sub evaluate_array {
 my ($helper, $source) = @_;
 $helper = array_helper_name($helper);
 return undef unless defined($helper) && ref($source) eq 'ARRAY';
 foreach my $term (@$source) {
  return undef unless defined($term) && $term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/;
 }
 if ($helper eq 'num_sum' || $helper eq 'num_avg') {
  my $total = 0;
  $total += $_ for @$source;
  return $total if $helper eq 'num_sum';
  return @$source ? $total / @$source : undef
 }
 return undef unless @$source;
 if ($helper eq 'num_median') {
  my @terms = sort { $a <=> $b } @$source;
  my $middle = int(@terms / 2);
  return @terms % 2 ? $terms[$middle] : ($terms[$middle - 1] + $terms[$middle]) / 2
 }
 if ($helper eq 'num_min' || $helper eq 'num_max') {
  my $selected;
  foreach my $term (@$source) {
   $selected = $term if !defined($selected)
    || ($helper eq 'num_min' ? $term < $selected : $term > $selected);
  }
  return $selected
 }
 my ($minimum, $maximum, $seen);
 foreach my $term (@$source) {
  if ($seen) {
   $minimum = $term if $term < $minimum;
   $maximum = $term if $term > $maximum;
  } else {
   ($minimum, $maximum, $seen) = ($term, $term, 1);
  }
 }
 return $maximum - $minimum
}

sub arity_is_valid {
 my ($helper, $argc) = @_;
 return 0 unless defined($helper);
 return $argc == 1 if $UNARY_HELPER{$helper};
 return $argc >= 2 if $VARIADIC_HELPER{$helper};
 return $argc == 2 if $BINARY_HELPER{$helper};
 return $argc == 3 if $helper eq 'num_clamp';
 return 0
}

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
 return undef unless arity_is_valid($helper, scalar(@args));

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

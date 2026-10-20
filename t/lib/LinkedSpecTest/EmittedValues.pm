package LinkedSpecTest::EmittedValues;
use strict;
use warnings;
use Scalar::Util qw(refaddr);

sub return_value {
 my ($source) = @_;
 my $execute = eval 'sub { ' . $source . ' }';
 return {error => "compile: $@"} unless ref($execute) eq 'CODE';
 my $value;
 my $ok = eval { $value = $execute->(); 1 };
 return $ok ? {value => $value} : {error => "execute: $@"};
}

sub public_rows {
 my ($rows) = @_;
 return [map {+{%$_, value => return_value($_->{value})}} @$rows];
}

# This secondary consumer observes the emitted invocation ABI, not runtime dispatch.
sub invocation {
 my ($source) = @_;
 require LinkedSpec::CodeblockRuntime;
 my $item = [1, 2];
 my $set = sub { die 'the secondary ABI observer must intercept dispatch' };
 my ($descr, $STRING, $minfo) = ({fixture => 'descriptor'}, \'input', {fixture => 'match'});
 my @calls;
 local *LinkedSpec::CodeblockRuntime::invoke;
 *LinkedSpec::CodeblockRuntime::invoke = sub {
  my ($callable, $args, $bindings, $name, $option, $context) = @_;
  push @calls, {
   callable => refaddr($callable) == refaddr($set) ? 1 : 0,
   args => $args, binding => refaddr($bindings->{set}) == refaddr(\$set) ? 1 : 0,
   name => $name, option => $option,
   descriptor => refaddr($context->{descriptor}) == refaddr($descr) ? 1 : 0,
   input => refaddr($context->{input}) == refaddr($STRING) ? 1 : 0,
   match_info => refaddr($context->{match_info}) == refaddr($minfo) ? 1 : 0,
  };
  return 'observed invocation';
 };
 my $execute = eval 'sub { ' . $source . ' }';
 return {error => "compile: $@"} unless ref($execute) eq 'CODE';
 my $value;
 my $ok = eval { $value = $execute->(); 1 };
 return $ok ? {value => $value, calls => \@calls} : {error => "execute: $@"};
}

1;

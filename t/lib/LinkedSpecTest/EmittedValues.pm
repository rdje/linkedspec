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

# Controlled native set_key fixtures use KEY/VALUE operands. Observe their
# order and snapshot behavior; the later value operand changes the key binding.
sub hash_write {
 my ($source) = @_;
 my ($key, $value) = ('first', 'payload');
 my (%meta, %zero_target, @effects);
 $source =~ s/\$0\{/\$zero_target\{/g;
 $source =~ s/\bKEY\b/do { push \@effects, 'K'; \$key }/g;
 $source =~ s/\bVALUE\b/do { push \@effects, 'V'; \$key = 'later'; \$value }/g;
 my $execute = eval 'sub { ' . $source . ' }';
 return {error => "compile: $@"} unless ref($execute) eq 'CODE';
 my $ok = eval {$execute->(); 1};
 return {error => "execute: $@"} unless $ok;
 return {meta => \%meta, zero_target => \%zero_target, effects => \@effects, key => $key};
}

sub hash_write_golden {
 my ($source) = @_;
 return undef unless defined $source;
 my %goldens = (
  '$meta{KEY} = VALUE' => {meta => {first => 'payload'}, zero_target => {}, effects => ['K', 'V'], key => 'later'},
  '$0{KEY} = VALUE' => {meta => {}, zero_target => {first => 'payload'}, effects => ['K', 'V'], key => 'later'},
  '$meta{0} = VALUE' => {meta => {0 => 'payload'}, zero_target => {}, effects => ['V'], key => 'later'},
  '$meta{KEY} = 0' => {meta => {first => 0}, zero_target => {}, effects => ['K'], key => 'first'},
 );
 return $goldens{$source};
}

sub compare_hash_write {
 my ($actual, $original) = @_;
 my $golden = hash_write_golden($original);
 return $golden ? [hash_write($actual), $golden] : [$actual, $original];
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

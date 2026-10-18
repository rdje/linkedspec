use strict;
use warnings;
use Scalar::Util qw(refaddr);
use Sub::Util qw(set_subname);
use JSON::PP ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::ControlFlow ();

my $cold = @ARGV && $ARGV[0] eq 'cold';
unless ($cold) {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my @keys = qw(trim_action_ir_value split_action_ir_statements normalize_method_tag_expr lower_flow_composite_expr parse_method_function_expr normalize_method_args_with_optional_scope lower_method_value_expr extract_array_symbol_name);
require LinkedSpec::ActionIR::ValueExpr;
sub provider { return $_[0] eq 'extract_array_symbol_name' ? 'LinkedSpec::ActionIR::ValueExpr' : 'LinkedSpec::RuleIR::EmitContext' }
sub public { return provider($_[0])->can('_'.$_[0]) }
my @native = map { public($_) } @keys;
my (%ids, @retained, @rows, @calls, @registrations);
sub identity {
 my ($value) = @_;
 return undef unless ref $value;
 my $address = refaddr($value);
 unless (exists $ids{$address}) {
  $ids{$address} = scalar @retained;
  push @retained, $value;
 }
 return $ids{$address}
}
identity($_) for @native;
sub context { return !defined($_[0]) ? 'void' : $_[0] ? 'list' : 'scalar' }
sub selected {
 my ($callback) = @_;
 return 0 unless defined &LinkedSpec::ActionIR::SourceEmissions::_same_reference;
 my $state = $LinkedSpec::ActionIR::SourceEmissions::_producers;
 return 0 unless ref($state) eq 'HASH'
  && LinkedSpec::ActionIR::SourceEmissions::_same_reference(
   $state->{source_token}, LinkedSpec::ActionIR::SourceEmissions::_current_source_token());
 return LinkedSpec::ActionIR::SourceEmissions::_same_reference(
  $state->{known}{refaddr($callback)}, $callback) ? 1 : 0
}
sub describe {
 my ($value) = @_;
 return {type => 'undefined'} unless defined $value;
 return {type => 'scalar', value => $value} unless ref $value;
 my $result = {type => ref($value), identity => identity($value)};
 if (ref($value) eq 'HASH') {
  $result->{keys} = [sort keys %$value];
  $result->{callbacks} = [map {
   my $key = $_;
   {key => $key, type => ref($value->{$key}), identity => identity($value->{$key}),
    actual_public => refaddr($value->{$key}) == refaddr(public($key)) ? 1 : 0,
    actual_native => refaddr($value->{$key}) == refaddr($native[(grep {$keys[$_] eq $key} 0..$#keys)[0]]) ? 1 : 0}
  } sort keys %$value];
 }
 return $result
}
sub invoke {
 my ($label, $target, $context) = @_;
 @calls = (); @registrations = ();
 my (@values, $successful_error, $warnings);
 local $SIG{__WARN__} = sub { $warnings .= $_[0] };
 my $ok = eval {
  if ($context eq 'void') { LinkedSpec::ActionIR::ControlFlow::default_deps_for_package($target) }
  elsif ($context eq 'list') { @values = LinkedSpec::ActionIR::ControlFlow::default_deps_for_package($target) }
  else { $values[0] = LinkedSpec::ActionIR::ControlFlow::default_deps_for_package($target) }
  $successful_error = $@;
  1
 };
 my $error = $@;
 push @rows, {label => $label, context => $context, target => $target,
  success => $ok ? 1 : 0, values => [map {describe($_)} @values],
  calls => [@calls],
  authority => {registrations => [@registrations], native_selected => [map {selected($_)} @native],
   values => [map {my $map = $_; ref($map) eq 'HASH' ? [map {+{key => $_, selected => selected($map->{$_})}} sort keys %$map] : []} @values]},
  error => ref($error) ? {type => ref($error), identity => identity($error)} : $error,
  successful_error => $successful_error, warnings => $warnings // ''};
}
{
 no strict 'refs'; no warnings 'redefine';
 for my $index (0..$#keys) { *{'ControlDefaultCustom::_'.$keys[$index]} = $native[$index] }
}
my $build = \&LinkedSpec::OwnerDispatch::build_dep_map;
{
 no warnings 'redefine';
 local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
  my $want = wantarray;
  my $call = {context => context($want), owner => $_[0], target => $_[1], keys => [@{$_[2]}]};
  push @calls, $call;
  if (!defined $want) { $build->(@_); return }
  if ($want) {
   my @values = $build->(@_);
   $call->{returned} = [map {identity($_)} @values];
   return @values
  }
  my $value = $build->(@_);
  $call->{returned} = [identity($value)];
  return $value
 };
 my $work = sub {
  for my $repeat (1..2) {
   invoke('native-'.$repeat, 'LinkedSpec::RuleIR::EmitContext', $_) for qw(scalar list void);
  }
  invoke('custom-native-alias', 'ControlDefaultCustom', $_) for qw(scalar list void);
  invoke('undefined-target', undef, 'scalar');
  invoke('unknown-target', 'ControlDefaultMissing', 'scalar');
  for my $index (0..$#keys) {
   my $key = $keys[$index];
   my $opaque = set_subname(provider($key).'::_'.$key, sub { return 'same' });
   no strict 'refs'; no warnings 'redefine';
   local *{provider($key).'::_'.$key} = $opaque;
   invoke('copied-name-'.$key, 'LinkedSpec::RuleIR::EmitContext', 'scalar');
  }
  my $fatal = bless {}, 'ControlDefaultFatal';
  for my $context (qw(scalar list void)) {
   no warnings 'redefine';
   local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
    push @calls, {context => context(scalar wantarray), owner => $_[0], target => $_[1], keys => [@{$_[2]}]};
    die $fatal
   };
   invoke('fatal-object', 'LinkedSpec::RuleIR::EmitContext', $context);
  }
  for my $context (qw(scalar list void)) {
   no warnings 'redefine';
   local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
    my $want = wantarray;
    my $value = $build->(@_);
    push @calls, {context => context($want), owner => $_[0], target => $_[1], keys => [@{$_[2]}], returned => [identity($value)]};
    $@ = 'factory-effect';
    return $value
   };
   invoke('successful-error-effect', 'LinkedSpec::RuleIR::EmitContext', $context);
  }
 };
 if ($cold) { $work->() }
 else {
  my $register = \&LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer;
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer = sub {
   push @registrations, identity($_[0]); return $register->(@_)
  };
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $work)
  });
 }
 invoke('outside', 'LinkedSpec::RuleIR::EmitContext', 'scalar');
}
print JSON::PP->new->canonical->encode({mode => $cold ? 'cold' : 'warm', keys => \@keys,
 providers => [map {provider($_)} @keys], rows => \@rows, source_emissions_loaded => exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0,
 trace_loaded => exists $INC{'LinkedSpec/Trace.pm'} ? 1 : 0,
 loaded_project_modules => [sort grep {m{^LinkedSpec(?:/|\.pm)}} keys %INC]}), "\n";

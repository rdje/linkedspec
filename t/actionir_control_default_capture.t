use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use Sub::Util qw(set_subname);
use IO::Uncompress::Gunzip qw(gunzip);
use IPC::Open3 ();
use Symbol qw(gensym);
use Scalar::Util qw(weaken);
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::ControlFlow ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @keys = qw(trim_action_ir_value split_action_ir_statements normalize_method_tag_expr lower_flow_composite_expr parse_method_function_expr normalize_method_args_with_optional_scope lower_method_value_expr extract_array_symbol_name);
use LinkedSpec::ActionIR::ValueExpr ();
sub provider { return $_[0] eq 'extract_array_symbol_name' ? 'LinkedSpec::ActionIR::ValueExpr' : 'LinkedSpec::RuleIR::EmitContext' }
sub public { return provider($_[0])->can('_'.$_[0]) }
sub select_control {
 my ($callback, $provider) = @_;
 $provider ||= 'LinkedSpec::RuleIR::EmitContext';
 my $selector = $provider->can('_register_builtin_control_emission_callback');
 return $selector ? $selector->($callback) : $callback
}

sub defaults { LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(@_) }
sub scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', $_[0]) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([], $_[0]) }
sub selected {
 my ($callback) = @_;
 my $state = $LinkedSpec::ActionIR::SourceEmissions::_producers;
 return 0 unless ref($state) eq 'HASH'
  && LinkedSpec::ActionIR::SourceEmissions::_same_reference(
   $state->{source_token}, LinkedSpec::ActionIR::SourceEmissions::_current_source_token());
 return LinkedSpec::ActionIR::SourceEmissions::_same_reference(
  $state->{known}{refaddr($callback)}, $callback) ? 1 : 0
}
sub observations {
 # Retain both actual maps while normalizing identities, avoiding address reuse.
 my @maps = map { defaults('LinkedSpec::RuleIR::EmitContext') } 1..2;
 my (%seen, @rows);
 for my $map (@maps) {
  push @rows, {type => ref($map), keys => [sort keys %$map], callbacks => [map {
   my $callback = $map->{$_};
   {key => $_, type => ref($callback), actual_native => refaddr($callback) ==
    refaddr(public($_)) ? 1 : 0,
    identity => $seen{refaddr($callback)} //= scalar(keys %seen)}
  } @keys]};
 }
 return \@rows
}
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n";
 exit 0
}

my $build_map = \&LinkedSpec::OwnerDispatch::build_dep_map;
my $register = \&LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer;
my ($factory_map, @registered);
{
 no warnings 'redefine';
 local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
  $factory_map = $build_map->(@_); return $factory_map
 };
 local *LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer = sub {
  push @registered, $_[0]; return $register->(@_)
 };
 scope(sub { producers(sub {
  my $map = defaults('LinkedSpec::RuleIR::EmitContext');
  is(refaddr($map), refaddr($factory_map), 'default factory returns the exact actual OwnerDispatch map');
  is_deeply([sort keys %$map], [sort @keys], 'native default map retains exactly the original keys');
  is_deeply([sort {$a <=> $b} map {refaddr($_)} @registered],
   [sort {$a <=> $b} map {refaddr($map->{$_})} @keys], 'native default selects each actual reference exactly once');
  for my $key (@keys) {
   my $actual = $map->{$key};
   is(refaddr($actual), refaddr(public($key)), "$key public callback retains exact native reference");
   ok(selected($actual), "$key actual native reference is selected in current scope");
   is(refaddr(select_control($actual, provider($key))),
    refaddr($actual), "$key selector returns the same actual native callback");
  }
  scope(sub { for my $key (@keys) {
   is(refaddr(select_control($map->{$key}, provider($key))),
    refaddr($map->{$key}), "$key nested equal-source registration returns actual callback");
   ok(!selected($map->{$key}), "$key nested equal-source scope cannot borrow registration");
  } });
  producers(sub { for my $key (@keys) {
   ok(!selected($map->{$key}), "$key nested producer scope cannot borrow registration");
  } });
  for my $key (@keys) { ok(selected($map->{$key}), "$key enclosing producer selection restores") }
 }); });
}

for my $key (@keys) {
 my $opaque = set_subname(provider($key).'::_'.$key, sub { return 'same' });
 my $actual = public($key);
 {
  no strict 'refs'; no warnings 'redefine';
  local *{provider($key).'::_'.$key} = $opaque;
  scope(sub { producers(sub {
   my $map = defaults('LinkedSpec::RuleIR::EmitContext');
   is(refaddr($map->{$key}), refaddr($opaque), "$key same-name replacement keeps actual public reference");
   ok(!selected($opaque), "$key same-name replacement remains opaque");
   ok(!selected($actual), "$key replaced native callback is not selected by this factory");
   my @unchanged = grep { $_ ne $key } @keys;
   is_deeply([map {selected($map->{$_})} @unchanged], [(1) x @unchanged], "$key unchanged native defaults remain selected");
   is(refaddr(select_control($opaque, provider($key))),
    refaddr($opaque), "$key selector preserves actual opaque reference");
   ok(!selected($opaque), "$key direct selector cannot select an opaque callback");
   select_control($actual, provider($key));
   ok(selected($actual), "$key retained actual native reference survives symbol replacement");
  }); });
 }
}

{
 no strict 'refs'; no warnings 'redefine';
 for my $key (@keys) {
  *{'ControlDefaultCustom::_'.$key} = public($key);
 }
 scope(sub { producers(sub {
  my $map = defaults('ControlDefaultCustom');
  is_deeply([sort keys %$map], [sort @keys], 'custom target keeps original key population');
  for my $key (@keys) {
   is(refaddr($map->{$key}), refaddr(public($key)), "$key custom target preserves actual native alias");
   if ($key eq 'extract_array_symbol_name') {
    ok(selected($map->{$key}), "$key fixed actual native reference is selected in current scope");
   } else {
    ok(!selected($map->{$key}), "$key custom facade target cannot register its native alias");
   }
  }
 }); });
}

# An opaque replacement actually attempts publication and returns equal text.
# Its ordinary value survives, but factory selection cannot authorize the packet.
for my $key (@keys) {
 scope(sub { producers(sub {
  my $event = {raw => 'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event => $event, source => 'same', source_span => {start => 0, end => 4}});
  my ($calls, $eligible) = (0, undef);
  my $opaque = sub {
   ++$calls; $eligible = LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'same');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   return 'same'
  };
  no strict 'refs'; no warnings 'redefine';
  local *{provider($key).'::_'.$key} = $opaque;
  my $map = defaults('LinkedSpec::RuleIR::EmitContext');
  my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($map->{$key});
  is($capture->{value}, 'same', "$key opaque equal ordinary value survives");
  is($calls, 1, "$key actual opaque callback executes once");
  is($eligible, 0, "$key opaque actual invocation stays ineligible");
  ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $opaque, $event),
   "$key opaque equal text cannot publish a selected packet");
 }); });
}

scope(sub { producers(sub {
 my $before = defaults('LinkedSpec::RuleIR::EmitContext');
 my $opaque = sub { return 'same' };
 no warnings 'redefine';
 local *LinkedSpec::RuleIR::EmitContext::_trim_action_ir_value = $opaque;
 defaults('LinkedSpec::RuleIR::EmitContext');
 ok(selected($before->{trim_action_ir_value}), 'later replacement cannot revoke an already selected actual native callback');
 ok(!selected($opaque), 'later replacement cannot inherit existing selection');
}); });
scope(sub { producers(sub {
 my $map = defaults('ControlDefaultCustom');
 for my $key (@keys) {
  if ($key eq 'extract_array_symbol_name') {
   ok(selected($map->{$key}), "$key fresh fixed actual native reference is selected in current scope");
  } else {
   ok(!selected($map->{$key}), "$key new producer scope cannot borrow expired facade registration");
  }
 }
}); });
my $outside = defaults('LinkedSpec::RuleIR::EmitContext');
ok(!defined($LinkedSpec::ActionIR::SourceEmissions::_producers), 'outside factory creates no global producer scope');
for my $key (@keys) { ok(!selected($outside->{$key}), "$key outside registration grants no authority") }
is_deeply(observations()->[0], observations()->[1], 'repeated native maps retain complete key/ref reuse observations');

# Each provider's catalogue rejects its own other definitions independently.
for my $provider ('LinkedSpec::RuleIR::EmitContext', 'LinkedSpec::ActionIR::ValueExpr') {
 no strict 'refs';
 my %known = map {refaddr(public($_)) => 1} grep {provider($_) eq $provider} @keys;
 my @other = map { [$provider.'::'.$_, *{$provider.'::'.$_}{CODE}] }
  sort grep {$_ ne '_register_builtin_control_emission_callback'} keys %{$provider.'::'};
 @other = grep {defined $_->[1] && !$known{refaddr($_->[1])}} @other;
 scope(sub { producers(sub {
  for my $entry (@other) {
   select_control($entry->[1], $provider);
   ok(!selected($entry->[1]), $entry->[0].' is outside its exact ControlFlow provider population');
  }
  my $selector = $provider->can('_register_builtin_control_emission_callback');
  select_control($selector, $provider);
  ok(!$selector || !selected($selector), $provider.' selector cannot select its own actual callback');
 }); });
}
my ($expired_scope, $outer_scope);
scope(sub { producers(sub {
 my $outer_defaults = defaults('LinkedSpec::RuleIR::EmitContext');
 $outer_scope = $LinkedSpec::ActionIR::SourceEmissions::_producers;
 my $fatal = bless {}, 'ControlDefaultScopeFatal';
 my $ok = eval {
  producers(sub {
   $expired_scope = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   weaken($expired_scope);
   my $nested_defaults = defaults('LinkedSpec::RuleIR::EmitContext');
   die $fatal
  });
  1
 };
 my $error = $@;
 ok(!$ok, 'nested factory scope throws its actual fatal object');
 is(refaddr($error), refaddr($fatal), 'fatal object identity survives nested scope exit');
 is(refaddr($LinkedSpec::ActionIR::SourceEmissions::_producers), refaddr($outer_scope), 'fatal exit restores exact enclosing producer registry');
 ok(!defined $expired_scope, 'completed nested producer registry releases');
 for my $key (@keys) {ok(selected(public($key)), $key.' enclosing registration survives fatal nested exit')}
 weaken($outer_scope);
}); });
ok(!defined $outer_scope, 'completed enclosing producer registry releases');

# Compare all ordinary native observations, including actual factory contexts,
# map identities, symbol replacement, error effects and fatal object identities.
# Authority selection is the one intentional behavioral difference.
my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/';
open my $data_file, '<:raw', $prefix.'before-native-data.json.gz' or die $!;
my $compressed = do {local $/; <$data_file>}; close $data_file;
my $json;
gunzip(\$compressed => \$json) or die $IO::Uncompress::Gunzip::GunzipError;
my $native_data = JSON::PP->new->decode($json);
sub ordinary {
 my ($value) = @_;
 if (ref($value) eq 'HASH') {
  return {map { $_ => ordinary($value->{$_}) }
   grep {$_ ne 'authority' && $_ ne 'selected' && $_ ne 'native_selected' && $_ ne 'registrations'} keys %$value}
 }
 return [map {ordinary($_)} @$value] if ref($value) eq 'ARRAY';
 if (defined($value) && !ref($value)) {
  $value =~ s{(\@INC contains: ).*?/perl( \. perl )}{$1<PROJECT>/perl$2};
 }
 return $value
}
for my $mode (['warm',1], ['cold',3]) {
 my ($label,$index) = @$mode;
 local $ENV{PERL5LIB} = '';
 local $ENV{PERL5OPT} = '';
 my $error_pipe = gensym;
 my $pid = IPC::Open3::open3(undef, my $output, $error_pipe, $^X, '-Iperl', 't/actionir_control_default_native.pl', $label eq 'cold' ? ('cold') : ());
 my $stdout = do {local $/; <$output>};
 my $stderr = do {local $/; <$error_pipe>};
 waitpid($pid, 0);
 is($?, 0, $label.' current native diagnostic exits successfully');
 is($stderr, '', $label.' current native diagnostic has exact empty stderr');
 my $current = JSON::PP->new->decode($stdout);
 my $before = $native_data->[$index]{observation};
 is_deeply($current->{keys}, $before->{keys}, $label.' complete eight-default population stays native');
 is(scalar @{$current->{rows}}, scalar @{$before->{rows}}, $label.' complete native row population is reached');
 for my $i (0..$#{$before->{rows}}) {
  is_deeply(ordinary($current->{rows}[$i]), ordinary($before->{rows}[$i]),
   $label.' native row '.$i.' '.$before->{rows}[$i]{label}.' '.$before->{rows}[$i]{context}.' preserves every ordinary observation');
 }
 is($current->{source_emissions_loaded}, $label eq 'warm' ? 1 : 0, $label.' SourceEmissions loading remains native');
 is($current->{trace_loaded}, 0, $label.' Trace stays unloaded');
}
# A fresh void factory invocation has no returned map to authorize.
scope(sub { producers(sub {
 defaults('LinkedSpec::RuleIR::EmitContext');
 for my $key (@keys) {
  ok(!selected(public($key)), "$key fresh void factory has no returned-map selection");
 }
}); });

# Distinct actual maps distinguish list selection from scalar's last map.
my $native_map = defaults('LinkedSpec::RuleIR::EmitContext');
my $facade_map = {map {$_ => $native_map->{$_}} grep {provider($_) eq 'LinkedSpec::RuleIR::EmitContext'} @keys};
my $fixed_map = {extract_array_symbol_name => $native_map->{extract_array_symbol_name}};
for my $context (qw(scalar list void)) {
 scope(sub { producers(sub {
  my (@calls, @values);
  no warnings 'redefine';
  local *LinkedSpec::OwnerDispatch::build_dep_map = sub {
   push @calls, !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
   return ($facade_map, $fixed_map)
  };
  if ($context eq 'void') { defaults('LinkedSpec::RuleIR::EmitContext') }
  elsif ($context eq 'list') { @values = defaults('LinkedSpec::RuleIR::EmitContext') }
  else { $values[0] = defaults('LinkedSpec::RuleIR::EmitContext') }
  is(scalar @calls, 1, "$context multi-map factory executes once");
  is($calls[0], $context, "$context multi-map factory preserves build context");
  my @expected = $context eq 'list' ? ($facade_map, $fixed_map) : $context eq 'scalar' ? ($fixed_map) : ();
  is(scalar @values, scalar @expected, "$context multi-map factory preserves return population");
  for my $index (0..$#expected) {
   is(refaddr($values[$index]), refaddr($expected[$index]), "$context actual returned map $index stays identical");
  }
  for my $key (@keys) {
   my $expected = $context eq 'list' || ($context eq 'scalar' && $key eq 'extract_array_symbol_name');
   is(selected(public($key)), $expected ? 1 : 0, "$context $key records actual returned-map selection");
  }
 }); });
}
done_testing;

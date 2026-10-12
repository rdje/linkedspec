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
use LinkedSpec::ActionIR::FlowExpr ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @keys = qw(trim_action_ir_value extract_array_symbol_name extract_hash_symbol_name extract_scalar_symbol_name lower_method_value_expr lower_primitive_literal_expr lower_direct_nested_access_value_expr parse_method_function_expr normalize_method_args_with_optional_scope);
sub select_flow {
 my $selector = LinkedSpec::RuleIR::EmitContext->can('_register_builtin_flow_emission_callback');
 return $selector ? $selector->($_[0]) : $_[0]
}

sub defaults { LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(@_) }
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
    refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$_)) ? 1 : 0,
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
   is(refaddr($actual), refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$key)), "$key public callback retains exact native reference");
   ok(selected($actual), "$key actual native reference is selected in current scope");
   is(refaddr(select_flow($actual)),
    refaddr($actual), "$key selector returns the same actual native callback");
  }
  scope(sub { for my $key (@keys) {
   is(refaddr(select_flow($map->{$key})),
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
 my $opaque = set_subname('LinkedSpec::RuleIR::EmitContext::_'.$key, sub { return 'same' });
 my $actual = LinkedSpec::RuleIR::EmitContext->can('_'.$key);
 {
  no strict 'refs'; no warnings 'redefine';
  local *{'LinkedSpec::RuleIR::EmitContext::_'.$key} = $opaque;
  scope(sub { producers(sub {
   my $map = defaults('LinkedSpec::RuleIR::EmitContext');
   is(refaddr($map->{$key}), refaddr($opaque), "$key same-name replacement keeps actual public reference");
   ok(!selected($opaque), "$key same-name replacement remains opaque");
   ok(!selected($actual), "$key replaced native callback is not selected by this factory");
   my @unchanged = grep { $_ ne $key } @keys;
   is_deeply([map {selected($map->{$_})} @unchanged], [(1) x @unchanged], "$key unchanged native defaults remain selected");
   is(refaddr(select_flow($opaque)),
    refaddr($opaque), "$key selector preserves actual opaque reference");
   ok(!selected($opaque), "$key direct selector cannot select an opaque callback");
   select_flow($actual);
   ok(selected($actual), "$key retained actual native reference survives symbol replacement");
  }); });
 }
}

{
 no strict 'refs'; no warnings 'redefine';
 for my $key (@keys) {
  *{'FlowDefaultCustom::_'.$key} = LinkedSpec::RuleIR::EmitContext->can('_'.$key);
 }
 scope(sub { producers(sub {
  my $map = defaults('FlowDefaultCustom');
  is_deeply([sort keys %$map], [sort @keys], 'custom target keeps original key population');
  for my $key (@keys) {
   is(refaddr($map->{$key}), refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$key)), "$key custom target preserves actual native alias");
   ok(!selected($map->{$key}), "$key custom target cannot register its native alias");
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
  local *{'LinkedSpec::RuleIR::EmitContext::_'.$key} = $opaque;
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
 for my $callback (values %{defaults('FlowDefaultCustom')}) {
  ok(!selected($callback), 'new producer scope retains no expired native registration');
 }
}); });
my $outside = defaults('LinkedSpec::RuleIR::EmitContext');
ok(!defined($LinkedSpec::ActionIR::SourceEmissions::_producers), 'outside factory creates no global producer scope');
for my $key (@keys) { ok(!selected($outside->{$key}), "$key outside registration grants no authority") }
is_deeply(observations()->[0], observations()->[1], 'repeated native maps retain complete key/ref reuse observations');

# Reject every other actual facade definition, including the method/contract-only
# references. Equal names are separately exercised with actual opaque calls.
{
 no strict 'refs';
 my %flow = map {refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$_)) => 1} @keys;
 my @other = map { ['LinkedSpec::RuleIR::EmitContext::'.$_, *{'LinkedSpec::RuleIR::EmitContext::'.$_}{CODE}] }
  sort grep {$_ ne '_register_builtin_flow_emission_callback'} keys %LinkedSpec::RuleIR::EmitContext::;
 @other = grep {defined $_->[1] && !$flow{refaddr($_->[1])}} @other;
 scope(sub { producers(sub {
  for my $entry (@other) {
   select_flow($entry->[1]);
   ok(!selected($entry->[1]), $entry->[0].' is outside the exact FlowExpr population');
  }
 }); });
}
my ($expired_scope, $outer_scope);
scope(sub { producers(sub {
 my $outer_defaults = defaults('LinkedSpec::RuleIR::EmitContext');
 $outer_scope = $LinkedSpec::ActionIR::SourceEmissions::_producers;
 my $fatal = bless {}, 'FlowDefaultScopeFatal';
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
 for my $key (@keys) {ok(selected(LinkedSpec::RuleIR::EmitContext->can('_'.$key)), $key.' enclosing registration survives fatal nested exit')}
 weaken($outer_scope);
}); });
ok(!defined $outer_scope, 'completed enclosing producer registry releases');

# Compare all ordinary native observations, including actual factory contexts,
# map identities, symbol replacement, error effects and fatal object identities.
# Authority selection is the one intentional behavioral difference.
my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.1/';
open my $data_file, '<:raw', $prefix.'before-native-data.json.gz' or die $!;
my $compressed = do {local $/; <$data_file>}; close $data_file;
my $json;
gunzip(\$compressed => \$json) or die $IO::Uncompress::Gunzip::GunzipError;
my $native_data = JSON::PP->new->decode($json);
sub ordinary {
 my ($value) = @_;
 if (ref($value) eq 'HASH') {
  return {map { $_ => ordinary($value->{$_}) }
   grep {$_ ne 'selected' && $_ ne 'native_selected' && $_ ne 'registrations'} keys %$value}
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
 my $pid = IPC::Open3::open3(undef, my $output, $error_pipe, $^X, '-Iperl', 't/actionir_flow_default_native.pl', $label eq 'cold' ? ('cold') : ());
 my $stdout = do {local $/; <$output>};
 my $stderr = do {local $/; <$error_pipe>};
 waitpid($pid, 0);
 is($?, 0, $label.' current native diagnostic exits successfully');
 is($stderr, '', $label.' current native diagnostic has exact empty stderr');
 my $current = JSON::PP->new->decode($stdout);
 my $before = $native_data->[$index]{observation};
 is_deeply($current->{keys}, $before->{keys}, $label.' complete nine-default population stays native');
 is(scalar @{$current->{rows}}, scalar @{$before->{rows}}, $label.' complete native row population is reached');
 for my $i (0..$#{$before->{rows}}) {
  is_deeply(ordinary($current->{rows}[$i]), ordinary($before->{rows}[$i]),
   $label.' native row '.$i.' '.$before->{rows}[$i]{label}.' '.$before->{rows}[$i]{context}.' preserves every ordinary observation');
 }
 is($current->{source_emissions_loaded}, $label eq 'warm' ? 1 : 0, $label.' SourceEmissions loading remains native');
 is($current->{trace_loaded}, 0, $label.' Trace stays unloaded');
}
done_testing;

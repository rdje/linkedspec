use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my %owners = (bare => '_lower_source_slot_bare_scalar_read_expr', mutation => '_lower_mutation_slot_value_expr');
my @targets = (['bare', 'trim_action_ir_value'], ['mutation', 'trim_action_ir_value'],
 ['mutation', 'lower_primitive_literal_expr']);
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => ref($value), marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub setup {
 my ($owner, $role, $outcome, $options) = @_;
 $options ||= {};
 my $state = {owner => $owner, role => $role, outcome => $outcome, options => $options,
  input => exists($options->{input}) ? $options->{input} : $role eq 'lower_primitive_literal_expr' ? 'complex()' : 'slot',
  trace => [], events => [], helpers => [], calls => 0, eligible => [],
  reference => {marker => 'actual-result'}};
 my $fatal = bless {}, 'MethodSlotFatal';
 my %deps;
 for my $name (qw(trim_action_ir_value lower_primitive_literal_expr)) {
  $deps{$name} = sub {
   push @{$state->{events}}, $name;
   push @{$state->{trace}}, {role => $name, args => [map {encoded($_)} @_], error => $@,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    original_input_slot => same(\$_[0], \$state->{input})};
   my $result = $name eq 'trim_action_ir_value'
    ? exists($options->{trim}) ? $options->{trim} : $_[0]
    : exists($options->{primitive}) ? $options->{primitive} : 'VALUE';
   $result = $state->{reference} if $name eq 'lower_primitive_literal_expr' && $options->{primitive_reference};
   if ($name eq $role) {
    ++$state->{calls};
    $_[0] .= '!' if defined($_[0]) && !ref($_[0]);
    $state->{mutation} = encoded($_[0]);
    $@ = 'successful slot callback';
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    if ($state->{event}) {
     my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $state->{publication});
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $deps{bare_symbol_kind} = sub {
  push @{$state->{events}}, 'kind';
  push @{$state->{helpers}}, {name => 'kind', input => $_[0],
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
   original_input_slot => same(\$_[0], \$state->{input})};
  $_[0] .= '!' if $options->{kind_mutation};
  return $options->{kind};
 };
 $state->{original} = {%deps};
 return (\%deps, $state, $fatal);
}
sub owner {
 my ($deps, $state, $fatal) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr($state->{input}, $deps)
  if $state->{owner} eq 'bare';
 my $options = $state->{options};
 my $helper = sub {
  my ($name, $input, $map) = @_;
  push @{$state->{events}}, $name;
  push @{$state->{helpers}}, {name => $name, input => $input,
   actual_map => same($map, $deps)};
 };
 no warnings 'redefine';
 no warnings 'once';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub {
  $helper->('bare', @_);
  return $options->{bare} if exists $options->{bare};
  return $state->{role} eq 'trim_action_ir_value' ? 'VALUE' : undef;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
  $helper->('method', @_);
  return $state->{reference} if $options->{method_reference};
  return exists($options->{method}) ? $options->{method} : 'METHOD';
 };
 my $flow = sub {
  $helper->('flow', $_[0], $deps);
  $_[0] .= '!' if $options->{flow_mutation};
  die $fatal if $options->{flow_fatal};
  return $state->{input} if $options->{flow_equal};
  return $options->{flow};
 };
 local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr =
  $options->{flow_noncode} ? 'not code' : $flow;
 return LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr($state->{input}, $deps);
}
sub invoke {
 my ($owner_name, $role, $outcome, $options) = @_;
 my ($deps, $state, $fatal) = setup($owner_name, $role, $outcome, $options);
 my ($value, $error, $success_error);
 {
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_retired_colon_scalar_slot_expr = sub {
   push @{$state->{events}}, 'colon';
   push @{$state->{helpers}}, {name => 'colon', input => $_[0]};
   return 'RETIRED';
  };
  eval {$@ = 'incoming slot error'; $value = owner($deps, $state, $fatal); $success_error = $@; 1} or $error = $@;
 }
 my $map_identity = !grep {!same($deps->{$_}, $state->{original}{$_})} keys %{$state->{original}};
 return {owner => $owner_name, role => $role, outcome => $outcome, value => encoded($value),
  calls => $state->{calls}, trace => $state->{trace}, events => $state->{events}, helpers => $state->{helpers},
  input_after => $state->{input}, mutation => $state->{mutation}, map_identity => $map_identity ? 1 : 0,
  reference_identity => same($value, $state->{reference}), success_error => $success_error,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $fatal)} : $error};
}
sub branch_cases {
 my @cases;
 for my $kind ('array', 'hash', 'scalar', 'other', undef) {
  push @cases, ['kind-'.($kind // 'undefined'), 'bare', {kind => $kind},
   defined($kind) && $kind eq 'array' ? '[@slot]' : defined($kind) && $kind eq 'hash' ? '{%slot}' : '$slot',
   [qw(trim_action_ir_value kind)]];
 }
 push @cases, ['kind-name-mutation', 'bare', {kind => 'array', kind_mutation => 1}, '[@slot!]', [qw(trim_action_ir_value kind)]];
 for my $reserved (qw(undef true false descr STRING info minfo IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS CAPTURE)) {
  push @cases, ['reserved-'.$reserved, 'bare', {input => $reserved}, undef, ['trim_action_ir_value']];
 }
 for my $input (undef, '', '0', 'bad name', 'call()', ':slot') {
  my $label = defined($input) ? length($input) ? $input : 'empty' : 'undefined';
  push @cases, ['source-'.$label, 'bare', {input => $input}, $input && $input eq ':slot' ? 'RETIRED' : undef,
   !defined($input) ? [] : $input eq ':slot' ? [qw(trim_action_ir_value colon)] : ['trim_action_ir_value']];
 }
 for my $input (undef, '', ':slot') {
  push @cases, ['mutation-source-'.($input // 'undefined'), 'mutation', {input => $input},
   defined($input) && $input eq ':slot' ? 'RETIRED' : undef,
   !defined($input) ? [] : $input eq ':slot' ? [qw(trim_action_ir_value colon)] : ['trim_action_ir_value']];
 }
 for my $which (qw(bare mutation)) {
  for my $trim ('', '0') {
   push @cases, ["$which-trim-$trim", $which, {trim => $trim, bare => undef, primitive => undef},
    $which eq 'mutation' && length($trim) ? 'METHOD' : undef,
    $which eq 'mutation' && length($trim) ? [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]
    : ['trim_action_ir_value']];
  }
 }
 for my $bare ('FAST', '0', '', undef) {
  push @cases, ['mutation-bare-'.($bare // 'undefined'), 'mutation', {bare => $bare},
   defined($bare) && length($bare) ? $bare : 'VALUE',
   defined($bare) && length($bare) ? [qw(trim_action_ir_value bare)] : [qw(trim_action_ir_value bare lower_primitive_literal_expr)]];
 }
 for my $literal ('', '0', undef) {
  push @cases, ['mutation-literal-'.($literal // 'undefined'), 'mutation', {input => 'complex()', bare => undef, primitive => $literal},
   defined($literal) ? $literal : 'METHOD', defined($literal) ? [qw(trim_action_ir_value bare lower_primitive_literal_expr)]
   : [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 }
 push @cases, ['mutation-bare-guard', 'mutation', {bare => undef, primitive => undef}, undef,
  [qw(trim_action_ir_value bare lower_primitive_literal_expr)]];
 my %fallback = (input => 'complex()', bare => undef, primitive => undef);
 for my $flow ('FLOW', '0', '', undef) {
  push @cases, ['mutation-flow-'.($flow // 'undefined'), 'mutation', {%fallback, flow => $flow},
   defined($flow) && length($flow) ? $flow : 'METHOD', defined($flow) && length($flow)
   ? [qw(trim_action_ir_value bare lower_primitive_literal_expr flow)]
   : [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 }
 push @cases, ['mutation-flow-equal', 'mutation', {%fallback, flow_equal => 1}, 'METHOD',
  [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 push @cases, ['mutation-flow-noncode', 'mutation', {%fallback, flow_noncode => 1}, 'METHOD',
  [qw(trim_action_ir_value bare lower_primitive_literal_expr method)]];
 push @cases, ['mutation-flow-mutation', 'mutation', {%fallback, flow_mutation => 1}, 'METHOD',
  [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 push @cases, ['mutation-flow-mutated-fallback', 'mutation', {%fallback, flow_mutation => 1, method => undef}, 'complex()!',
  [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 for my $method (undef, '', '0') {
  push @cases, ['mutation-method-'.($method // 'undefined'), 'mutation', {%fallback, method => $method},
   defined($method) && length($method) ? $method : 'complex()',
   [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 }
 push @cases, ['mutation-literal-reference', 'mutation', {input => 'complex()', bare => undef, primitive_reference => 1},
  {type => 'HASH', marker => 'actual-result'}, [qw(trim_action_ir_value bare lower_primitive_literal_expr)]];
 push @cases, ['mutation-method-reference', 'mutation', {%fallback, method_reference => 1},
  {type => 'HASH', marker => 'actual-result'}, [qw(trim_action_ir_value bare lower_primitive_literal_expr flow method)]];
 return \@cases;
}
sub observations {
 return {callbacks => [map {my ($owner, $role) = @$_; map {invoke($owner, $role, $_)} qw(string undefined fatal)} @targets],
  branches => [map {{case => $_->[0], %{invoke($_->[1], 'none', 'string', $_->[2])}}} @{branch_cases()}]};
}
if (@ARGV && $ARGV[0] eq 'observe') {print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0}
for my $target (@targets) {
 my ($which, $role) = @$target;
 my $name = $owners{$which};
 for my $outcome (qw(string undefined fatal)) {
  my $row = invoke($which, $role, $outcome);
  my $label = "$which/$role/$outcome";
  is($row->{calls}, 1, "$label actual required callback executes once");
  is($row->{map_identity}, 1, "$label actual public callback references survive");
  my ($call) = grep {$_->{role} eq $role} @{$row->{trace}};
  is($call->{context}, 'scalar', "$label required scalar context stays native");
  is($call->{original_input_slot}, 0, "$label keeps local scalar argument copy");
  is($call->{error}, 'incoming slot error', "$label incoming error stays native");
  is($row->{input_after}, $role eq 'lower_primitive_literal_expr' ? 'complex()' : 'slot', "$label caller source remains unchanged");
  if ($outcome eq 'fatal') {
   is_deeply($row->{error}, {type => 'MethodSlotFatal', same_fatal => 1}, "$label fatal object retains actual identity");
  } else {
   is($row->{error}, undef, "$label bounded native route completes");
   is($row->{success_error}, 'successful slot callback', "$label successful error effect survives");
   is($row->{value}, $outcome eq 'string' ? $which eq 'bare' ? '$slot' : 'VALUE'
    : $role eq 'lower_primitive_literal_expr' ? 'METHOD' : undef, "$label ordinary result stays native");
  }
 }
 my $baseline = invoke($which, $role, 'string');
 for my $known (0, 1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   my ($deps, $state, $fatal) = setup($which, $role, 'string');
   $state->{event} = $event; $state->{publication} = $baseline->{value};
   my $outer = sub {return owner($deps, $state, $fatal)};
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $deps->{$role}] : [$outer], sub {
    my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
    is($result->{value}, $baseline->{value}, "$name/$role/$known ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$role/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [$known], "$name/$role/$known actual callback has its own identity boundary");
    is($state->{calls}, 1, "$name/$role/$known actual effect count survives");
    is(refaddr($deps->{$role}), refaddr($state->{original}{$role}), "$name/$role/$known public callback stays actual");
   });
  });
 }
}
for my $which (qw(bare mutation)) {
 for my $role ($which eq 'bare' ? ('trim_action_ir_value') : qw(trim_action_ir_value lower_primitive_literal_expr)) {
  for my $bad (undef, 'not code') {
   my ($deps, $state, $fatal) = setup($which, 'none', 'string', {input => undef});
   $deps->{$role} = $bad;
   my $error; eval {owner($deps, $state, $fatal); 1} or $error = $@;
   like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
    "$owners{$which}/$role eager diagnostic precedes undefined-input guard");
   is_deeply($state->{events}, [], "$owners{$which}/$role required validation precedes invocation");
  }
 }
}
my $rows = observations();
my $cases = branch_cases();
for my $index (0..$#$cases) {
 my ($label, $which, $options, $expected, $events) = @{$cases->[$index]};
 my $row = $rows->{branches}[$index];
 is_deeply($row->{value}, $expected, "$label keeps actual bounded branch result");
 is_deeply($row->{events}, $events, "$label keeps exact guard and fallback order");
 is($row->{map_identity}, 1, "$label preserves actual public callbacks");
 is($row->{error}, undef, "$label bounded branch completes");
 for my $helper (grep {exists $_->{actual_map}} @{$row->{helpers}}) {
  is($helper->{actual_map}, 1, "$label secondary helper retains actual dependency map");
 }
 is($row->{reference_identity}, $label =~ /reference$/ ? 1 : 0, "$label preserves direct reference result identity");
 if ($label eq 'mutation-flow-mutation') {
  my ($method) = grep {$_->{name} eq 'method'} @{$row->{helpers}};
  is($method->{input}, 'complex()!', 'legacy flow mutation survives into method fallback');
 }
}
done_testing;

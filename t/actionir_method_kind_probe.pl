package MethodKindProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

my @required = qw(trim_action_ir_value split_action_ir_statements parse_method_function_expr
 normalize_method_args_with_optional_scope lower_direct_nested_access_value_expr
 extract_array_symbol_name extract_hash_symbol_name extract_scalar_symbol_name
 lower_scalar_access_key_expr lower_primitive_literal_expr infer_scalar_container_kind
 split_top_level_csv lower_array_pipeline_expr strip_literal_delimiters);

sub same { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub copied {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => ref($value)} if blessed($value);
 return [map {copied($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_ => copied($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
{
 package MethodKindProbe::Map;
 sub TIEHASH { bless {storage => $_[1], sequence => $_[2], fetches => $_[3]}, $_[0] }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{fetches}}, $key;
  return @{$self->{sequence}} > 1 ? shift @{$self->{sequence}} : $self->{sequence}[0]
   if $key eq 'bare_symbol_kind';
  return $self->{storage}{$key};
 }
 sub STORE { $_[0]{storage}{$_[1]} = $_[2] }
}
{
 package MethodKindProbe::Kind;
 use overload '""' => sub {
  my ($self) = @_;
  ++$self->{state}{coercions};
  die $self->{state}{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}
{
 package MethodKindProbe::Name;
 use overload '""' => sub { $_[0]{name} }, fallback => 1;
}

sub setup {
 my ($owner, $options) = @_;
 my $state = {owner => $owner, options => $options, trace => [], helpers => [], fetches => [],
  eligible => [], coercions => 0, first_calls => 0,
  input => exists($options->{input}) ? $options->{input} : $owner eq 'outer' ? 'COUNT' : 'AST_SET',
  args => ['item'], fatal => bless({}, 'MethodKindProbe::Fatal')};
 $state->{node} = {kind => 'call', name => 'set', source => 'AST_SET',
  args => [{kind => 'call', name => $options->{hash} ? 'hash' : 'array',
   args => [{kind => 'variable', name => 'item'}]},
   {kind => $options->{hash} ? 'hash_literal' : 'array_literal', items => [], entries => [], source => 'SHAPE'}]};
 $state->{node} = copied($options->{node}) if exists $options->{node};
 my %storage;
 my $record = sub {
  my ($role, $slot, $want, $incoming) = @_;
  push @{$state->{trace}}, {role => $role, argument => copied($$slot),
   context => !defined($want) ? 'void' : $want ? 'list' : 'scalar',
   incoming_error => copied($incoming), readonly => Internals::SvREADONLY($$slot) ? 1 : 0,
   caller_slot => same($slot, \$state->{input}), parser_slot => same($slot, \$state->{args}[0]),
   target_slot => ref($state->{node}) eq 'HASH' && ref($state->{node}{args}) eq 'ARRAY'
    && ref($state->{node}{args}[0]) eq 'HASH' && ref($state->{node}{args}[0]{args}) eq 'ARRAY'
    ? same($slot, \$state->{node}{args}[0]{args}[0]{name}) : 0};
 };
 $state->{first} = sub { ++$state->{first_calls}; return 'WRONG' };
 $state->{replacement} = sub {
  $record->('replacement', \$_[0], wantarray, $@);
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
   if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  return 'array';
 };
 $state->{returned} = bless({state => $state, text => 'array',
  fatal => ($options->{outcome} // '') eq 'coercion-fatal'}, 'MethodKindProbe::Kind');
 $state->{actual} = sub {
  $record->('kind', \$_[0], wantarray, $@);
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
   if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  if (($options->{outcome} // '') eq 'effect') {
   eval { $_[0] .= '!'; $state->{written} = $_[0]; 1 } or $state->{write_error} = $@;
  }
  $storage{bare_symbol_kind} = $state->{replacement} if $options->{replace_in_kind};
  $@ = 'successful method kind';
  die $state->{fatal} if ($options->{outcome} // '') eq 'fatal';
  return undef if ($options->{outcome} // '') eq 'undefined';
  return $state->{returned} if ($options->{outcome} // '') =~ /^(?:reference|coercion-fatal)$/;
  if ($state->{event}) {
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'PUBLISHED');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  return exists($options->{kind}) ? $options->{kind} : 'array';
 };
 for my $role (@required, 'lower_declare_initializer_expr') {
  $storage{$role} = sub {
   $record->($role, \$_[0], wantarray, $@);
   if ($role eq 'trim_action_ir_value') {
    $storage{bare_symbol_kind} = $state->{replacement} if $options->{replace_in_trim};
    return exists($options->{trim}) ? $options->{trim} : $_[0];
   }
   return $_[0] if $role eq 'normalize_method_args_with_optional_scope';
   return {method => 'count', args => $state->{args}}
    if $role eq 'parse_method_function_expr' && defined($_[0]) && $_[0] eq 'COUNT';
   return 'item' if $role eq 'extract_array_symbol_name';
   return 'VALUE' if $role eq 'lower_primitive_literal_expr' && defined($_[0]) && $_[0] eq 'item';
   return 'INIT' if $role eq 'lower_declare_initializer_expr';
   return undef;
  };
 }
 $storage{bare_symbol_kind} = $state->{actual};
 $storage{__actionir_ast_value_lowering_compat_bridge} = 1 if $owner eq 'outer';
 $storage{__user_function_scalar_value_names} = $options->{functions} if exists $options->{functions};
 $storage{unrelated} = sub { die 'unrelated method kind callback invoked' };
 $state->{unrelated} = $storage{unrelated};
 my $deps = \%storage;
 delete $storage{bare_symbol_kind} if $options->{missing};
 $storage{bare_symbol_kind} = $options->{bad_kind} if exists $options->{bad_kind};
 delete $storage{$options->{missing_required}} if $options->{missing_required};
 if ($options->{tied}) {
  my $selected = exists($options->{selected}) ? $options->{selected} : $state->{actual};
  my @sequence = ($state->{first}, $selected, $state->{first}, $selected);
  @sequence = ('not CODE') if $options->{tied} eq 'first-bad';
  my %map;
  tie %map, 'MethodKindProbe::Map', \%storage, \@sequence, $state->{fetches};
  $deps = \%map;
 }
 $state->{deps} = $deps;
 $state->{storage} = \%storage;
 return $state;
}

sub owner {
 my ($state) = @_;
 no warnings 'redefine';
 # Only secondary helpers are controlled. Both real optional selections,
 # local kind helper, early guards, AST assignment and callback calls execute.
 my $helper = sub {
  push @{$state->{helpers}}, {name => $_[0], actual_map => same($_[1], $state->{deps})};
  return undef;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  $helper->('ast', $_[1]);
  return $state->{owner} eq 'inner' ? $state->{node} : undef;
 };
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_hash_receiver_value_chain_expr = sub {$helper->('hash_receiver', $_[1])};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_string_receiver_value_chain_expr = sub {$helper->('string_receiver', $_[1])};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_number_receiver_value_chain_expr = sub {$helper->('number_receiver', $_[1])};
 local *LinkedSpec::ActionIR::MethodLowering::_normalize_array_receiver_value_chain_expr = sub {$helper->('array_receiver', $_[1])};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub {$helper->('scalar_read', $_[1])};
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_first_unknown_value_call_name = sub {return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_unsupported_helper_expr = sub {return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr = sub {
  push @{$state->{helpers}}, {name => 'scalar_assignment', target => $_[0], value => $_[1],
   actual_map => same($_[2], $state->{deps})};
  return 'SCALAR';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_mutation_target_is_tracked = sub {return 1};
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub {return $_[4]};
 return LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr($state->{input}, $state->{deps});
}

sub observe {
 my ($id, $which, $options, $known) = @_;
 my $state = setup($which, $options);
 my ($value, $error, $success_error, $packet, $capture);
 my $invoke = sub {
  eval { $@ = 'incoming method kind'; $value = owner($state); $success_error = $@; 1 } or $error = $@;
 };
 if (defined $known) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   $state->{event} = $event;
   my $outer = sub { $invoke->(); die $error if $error; return 'PUBLISHED' };
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $state->{actual}] : [$outer], sub {
    eval { $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer); 1 } or $error = $@;
    $packet = $capture && LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0;
   });
  });
 } else { $invoke->() }
 return {id => $id, owner => $which, value => copied($value),
  error => ref($error) ? {type => ref($error), actual_fatal => same($error, $state->{fatal})} : $error,
  success_error => copied($success_error), caller_after => copied($state->{input}),
  args_after => copied($state->{args}), node_after => copied($state->{node}),
  trace => $state->{trace}, helpers => $state->{helpers}, fetches => $state->{fetches},
  eligible => $state->{eligible}, coercions => $state->{coercions}, first_calls => $state->{first_calls},
  written => $state->{written}, write_error => $state->{write_error}, parent_packet => $packet,
  map_actual => same($state->{storage}{bare_symbol_kind},
   $options->{replace_in_kind} || $options->{replace_in_trim} ? $state->{replacement} : $state->{actual}),
  unrelated => same($state->{storage}{unrelated}, $state->{unrelated})};
}

my $mode = shift @ARGV // '';
die 'use observe or cold-observe' unless $mode eq 'observe' || $mode eq 'cold-observe';
my $loaded_before = $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0;
if ($mode eq 'observe') {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my (@callbacks, @branches, @authority, @symbolic);
for my $which (qw(outer inner)) {
 push @callbacks, observe($which.'/'.$_, $which, {outcome => $_})
  for $mode eq 'observe' ? qw(string effect undefined fatal reference coercion-fatal) : qw(string effect fatal);
 next if $mode ne 'observe';
 my @cases = (
  ['missing', {missing => 1}], ['undefined', {bad_kind => undef}],
  ['string', {bad_kind => 'not CODE'}], ['array', {bad_kind => []}],
  ['hash', {bad_kind => {}}], ['blessed', {bad_kind => bless({}, 'MethodKindProbe::NotCode')}],
  ['tied', {tied => 'ordinary'}], ['tied-first-bad', {tied => 'first-bad'}],
  ['tied-second-bad', {tied => 'ordinary', selected => 'not CODE'}],
  ['replace-in-trim', {replace_in_trim => 1}], ['replace-in-kind', {replace_in_kind => 1}],
  ['empty', {kind => ''}], ['zero', {kind => '0'}], ['scalar', {kind => 'scalar'}],
  ['hash-result', {kind => 'hash'}], ['unknown', {kind => 'unknown'}],
  ['function-present', {functions => {item => 1}}], ['function-false', {functions => {item => 0}}],
  ['function-absent', {functions => {}}], ['function-bad-shape', {functions => []}],
  ['function-tied-bad', {functions => {item => 1}, tied => 'ordinary', selected => 'not CODE'}],
  ['input-undefined', {input => undef}], ['input-empty', {input => ''}], ['input-zero', {input => '0'}],
  ['trim-undefined', {trim => undef}], ['trim-empty', {trim => ''}], ['trim-zero', {trim => '0'}],
  ['required-before-undefined', {input => undef, missing_required => 'infer_scalar_container_kind'}],
 );
 if ($which eq 'inner') {
  push @cases, ['hash-target', {hash => 1}],
   ['invalid-target', {node => {kind => 'call', name => 'set', args => [{kind => 'call', name => 'array', args => []}, {}]}}],
   ['scalar-target', {node => {kind => 'call', name => 'set', args => [{kind => 'variable', name => 'item'}, {}]}}];
 }
 push @branches, observe($which.'/'.$_->[0], $which, $_->[1]) for @cases;
 push @authority, observe($which.'/known-'.$_, $which, {}, $_) for (0, 1);
 for my $variant (qw(qualified unqualified glob blessed-code undefined array hash name-object)) {
  no warnings qw(redefine once);
  my $state;
  # The localized callable delegates to the actual callback of this one row;
  # selecting its symbolic name must never resolve that name for authority.
  local *LinkedSpec::ActionIR::MethodLowering::method_kind_named = sub {return $state->{actual}->(@_)};
  my $selected = $variant eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::method_kind_named'
   : $variant eq 'unqualified' ? 'method_kind_named'
   : $variant eq 'glob' ? \*LinkedSpec::ActionIR::MethodLowering::method_kind_named
   : $variant eq 'blessed-code' ? bless(sub {return $state->{actual}->(@_)}, 'MethodKindProbe::BlessedCode')
   : $variant eq 'array' ? [] : $variant eq 'hash' ? {}
   : $variant eq 'name-object' ? bless({name => 'LinkedSpec::ActionIR::MethodLowering::method_kind_named'}, 'MethodKindProbe::Name')
   : undef;
  # Reuse observe's actual execution without duplicating an owner or resolver.
  local *MethodKindProbe::setup = do {
   my $original = \&setup;
   sub { $state = $original->(@_); return $state }
  };
  push @symbolic, observe($which.'/'.$variant, $which, {tied => 'ordinary', selected => $selected});
 }
}
print JSON::PP->new->canonical->encode({mode => $mode, loaded_before => $loaded_before,
 loaded_after => $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0,
 callbacks => \@callbacks, branches => \@branches, authority => \@authority, symbolic => \@symbolic}), "\n";

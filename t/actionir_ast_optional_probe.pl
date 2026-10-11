package AstOptionalProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

sub same { ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0 }
sub copied {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => ref($value)} if blessed($value);
 return {type => 'HASH', tied => ref(tied(%$value))} if ref($value) eq 'HASH' && tied(%$value);
 return [map {copied($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_ => copied($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
{
 package AstOptionalProbe::Map;
 sub TIEHASH { bless {storage => $_[1], sequence => $_[2], fetches => $_[3], role => $_[4]}, $_[0] }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{fetches}}, $key;
  return @{$self->{sequence}} > 1 ? shift @{$self->{sequence}} : $self->{sequence}[0]
   if $key eq $self->{role};
  return $self->{storage}{$key};
 }
 sub STORE { $_[0]{storage}{$_[1]} = $_[2] }
 sub FIRSTKEY { my $reset = keys %{$_[0]{storage}}; each %{$_[0]{storage}} }
 sub NEXTKEY { each %{$_[0]{storage}} }
}
{
 package AstOptionalProbe::Result;
 use overload '""' => sub {
  my ($self) = @_;
  ++$self->{state}{coercions};
  die $self->{state}{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}
{
 package AstOptionalProbe::Name;
 use overload '""' => sub { $_[0]{name} }, fallback => 1;
}

sub setup {
 my ($which, $options) = @_;
 my $state = {owner => $which, options => $options, trace => [], helpers => [], fetches => [],
  eligible => [], coercions => 0, first_calls => 0, values => [], returned_actual => [],
  args => ['item', 'VALUE'], fatal => bless({}, 'AstOptionalProbe::Fatal')};
 $state->{effective} = $options->{separate_effective} ? ['other', 'PAYLOAD'] : $state->{args};
 $state->{used_effective} = $state->{effective};
 $state->{span} = {start => 2, end => 9};
 $state->{node} = {kind => 'call', name => $which eq 'pipeline' ? 'split' : 'set',
  source => exists($options->{source}) ? $options->{source} : 'SOURCE', source_span => $state->{span}};
 $state->{node}{kind} = $options->{node_kind} if exists $options->{node_kind};
 $state->{node}{name} = $options->{method} if exists $options->{method};
 $state->{node}{source_span} = $options->{span} if exists $options->{span};
 $state->{input} = $options->{wrapper} ? {kind => 'action_stmt', expr => $state->{node}} : $state->{node};
 $state->{input} = $options->{input} if exists $options->{input};
 $state->{expected} = exists($options->{expected}) ? $options->{expected} : 'set';
 $state->{role} = $which eq 'pipeline' ? 'lower_array_pipeline_expr' : 'lower_assign_statement';
 my %storage;
 my $record = sub {
  my ($role, $arguments, $want, $incoming) = @_;
  my @slots;
  for my $index (0 .. $#$arguments) {
   my $slot = \$arguments->[$index];
   push @slots, {readonly => Internals::SvREADONLY($arguments->[$index]) ? 1 : 0,
    node_source => same($slot, \$state->{node}{source}), node_span => same($slot, \$state->{node}{source_span}),
    raw_arg0 => same($slot, \$state->{args}[0]), raw_arg1 => same($slot, \$state->{args}[1]),
    effective_arg0 => ref($state->{used_effective}) eq 'ARRAY' ? same($slot, \$state->{used_effective}[0]) : 0,
    effective_arg1 => ref($state->{used_effective}) eq 'ARRAY' ? same($slot, \$state->{used_effective}[1]) : 0};
  }
  push @{$state->{trace}}, {role => $role, arguments => copied($arguments), slots => \@slots,
   context => !defined($want) ? 'void' : $want ? 'list' : 'scalar', incoming_error => copied($incoming),
   actual_args => ref($arguments->[0]) eq 'ARRAY' ? same($arguments->[0], $state->{args}) : 0,
   actual_span => @$arguments > 1 ? same($arguments->[1], $state->{span}) : 0,
   actual_map => @$arguments > 2 ? same($arguments->[2], $state->{deps}) : 0};
 };
 $state->{first} = sub { ++$state->{first_calls}; return 'WRONG' };
 $state->{returned} = bless({state => $state, text => 'LOWERED',
  fatal => ($options->{outcome} // '') eq 'coercion-fatal'}, 'AstOptionalProbe::Result');
 my $callback = sub {
  my ($role) = @_;
  return sub {
   $record->($role, \@_, wantarray, $@);
   push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
    if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
   if (($options->{outcome} // '') eq 'effect') {
    $_[0] = defined($_[0]) ? $_[0].'!' : 'changed';
    if (ref($_[1]) eq 'HASH') { $_[1]{touch} = 1 }
    else { $_[1] = defined($_[1]) ? $_[1].'!' : 'changed' }
   }
   $_[1] = {start => 20, end => 30} if $options->{replace_span} && $which eq 'pipeline';
   $storage{$state->{role}} = $state->{replacement} if $options->{replace_in_callback} && $role eq 'selected';
   $@ = 'successful AST optional '.$role;
   die $state->{fatal} if ($options->{outcome} // '') eq 'fatal';
   return undef if ($options->{outcome} // '') eq 'undefined';
   return $state->{returned} if ($options->{outcome} // '') =~ /^(?:reference|coercion-fatal)$/;
   if ($state->{event}) {
    my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
    LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'PUBLISHED');
    LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   }
   return exists($options->{result}) ? $options->{result} : 'LOWERED';
  };
 };
 $state->{actual} = $callback->('selected');
 $state->{fallback} = $callback->('fallback');
 $state->{replacement} = $callback->('replacement');
 $storage{$state->{role}} = $state->{actual};
 $storage{normalize_method_args_with_optional_scope} = sub {
  $record->('normalize', \@_, wantarray, $@);
  $storage{$state->{role}} = $state->{replacement} if $options->{replace_in_normalize};
  $state->{used_effective} = exists($options->{normalize}) ? $options->{normalize} : $state->{effective};
  return $state->{used_effective};
 };
 $storage{trim_action_ir_value} = sub {
  $record->('trim', \@_, wantarray, $@);
  return exists($options->{trim}) ? $options->{trim} : $_[0];
 };
 $storage{unrelated} = sub { die 'unrelated AST optional callback invoked' };
 $state->{unrelated} = $storage{unrelated};
 delete $storage{$state->{role}} if $options->{missing};
 $storage{$state->{role}} = $options->{bad_callback} if exists $options->{bad_callback};
 delete $storage{$options->{missing_required}} if $options->{missing_required};
 my $deps = \%storage;
 if ($options->{tied}) {
  my $selected = exists($options->{selected}) ? $options->{selected} : $state->{actual};
  my @sequence = $which eq 'pipeline' ? ($selected) : ($state->{first}, $selected);
  @sequence = ('not CODE') if $options->{tied} eq 'first-bad';
  my %map;
  tie %map, 'AstOptionalProbe::Map', \%storage, \@sequence, $state->{fetches}, $state->{role};
  $deps = \%map;
 }
 $deps = $options->{deps} if exists $options->{deps};
 $state->{deps} = $deps;
 $state->{storage} = \%storage;
 return $state;
}

sub owner {
 my ($state) = @_;
 no warnings 'redefine';
 my $helper = sub {
  my ($name, @values) = @_;
  push @{$state->{helpers}}, {name => $name, values => copied(\@values)};
  return $state->{options}{secondary};
 };
 # Real optional owners, selections, guards, callback invocations and local
 # assignment fallback thunk execute. All downstream lowering is explicit control.
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  $helper->('parse', $_[0]);
  return exists($state->{options}{parsed}) ? $state->{options}{parsed} : $state->{node};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_call_arg_sources = sub {
  $helper->('arg_sources', $_[0]);
  return exists($state->{options}{arg_source}) ? $state->{options}{arg_source} : $state->{args};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub {
  $helper->('value_source', $_[0]);
  return exists($state->{options}{value_source}) ? $state->{options}{value_source} : $_[0]{source};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr = sub {
  push @{$state->{helpers}}, {name => 'component', source => copied($_[0]),
   actual_map => same($_[1], $state->{deps}), actual_span => same($_[1]{actionir_source_span}, $state->{span}),
   keys => [sort keys %{$_[1]}]};
  return 'COMPONENT';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement = sub {$helper->('assignment_operator', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_array_end_mutation_method_statement = sub {$helper->('array_end', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {$helper->('method_value', @_)};
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_mutation_target_is_tracked = sub {return 1};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement = $state->{fallback};
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub {
  push @{$state->{helpers}}, {name => 'guard', target => copied($_[0]), reason => $_[1],
   actual_span => same($_[2], $state->{span}), actual_map => same($_[3], $state->{deps}), value => copied($_[4])};
  return exists($state->{options}{guard}) ? $state->{options}{guard} : $_[4];
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_ast_block_side_effect_statement($state->{input}, $state->{deps})
  if $state->{owner} eq 'pipeline';
 return LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement($state->{input}, $state->{expected}, $state->{deps});
}

sub observe {
 my ($id, $which, $options, $known) = @_;
 my $state = setup($which, $options);
 my ($value, $error, $success_error, $packet, $capture);
 my $invoke = sub {
  eval {
   for (1 .. ($options->{twice} ? 2 : 1)) {
    $@ = 'incoming AST optional'; $value = owner($state); $success_error = $@;
    push @{$state->{values}}, copied($value);
    push @{$state->{returned_actual}}, same($value, $state->{returned});
   }
   1
  } or $error = $@;
 };
 if (defined $known) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   $state->{event} = $event;
   my $outer = sub { $invoke->(); die $error if $error; return 'PUBLISHED' };
   my @known = $known ? ($outer, $state->{actual}, $state->{fallback}) : ($outer);
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(\@known, sub {
    eval { $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer); 1 } or $error = $@;
    $packet = $capture && LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0;
   });
  });
 } else { $invoke->() }
 return {id => $id, owner => $which, value => copied($value), values => $state->{values},
  returned_actual => $state->{returned_actual}, error => ref($error)
   ? {type => ref($error), actual_fatal => same($error, $state->{fatal})} : $error,
  success_error => copied($success_error), input_after => copied($state->{input}), node_after => copied($state->{node}),
  args_after => copied($state->{args}), effective_after => copied($state->{used_effective}), span_after => copied($state->{span}),
  trace => $state->{trace}, helpers => $state->{helpers}, fetches => $state->{fetches}, eligible => $state->{eligible},
  coercions => $state->{coercions}, first_calls => $state->{first_calls}, parent_packet => $packet,
  map_actual => same($state->{storage}{$state->{role}},
   $options->{replace_in_callback} || $options->{replace_in_normalize} ? $state->{replacement} : $state->{actual}),
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
for my $which (qw(pipeline assign)) {
 push @callbacks, observe($which.'/'.$_, $which, {outcome => $_})
  for $mode eq 'observe' ? qw(string effect undefined fatal reference coercion-fatal) : qw(string effect fatal);
 next if $mode ne 'observe';
 my @cases = (
  ['missing', {missing => 1}], ['undefined', {bad_callback => undef}],
  ['string', {bad_callback => 'not CODE'}], ['array', {bad_callback => []}],
  ['hash', {bad_callback => {}}], ['blessed-code', {bad_callback => bless(sub {die 'ordinary blessed callback invoked'}, 'AstOptionalProbe::NotCode')}],
  ['tied', {tied => 'ordinary'}], ['tied-first-bad', {tied => 'first-bad'}],
  ['tied-second-bad', {tied => 'ordinary', selected => 'not CODE'}],
  ['replace-next-call', {replace_in_callback => 1, twice => 1}],
  ['empty', {result => ''}], ['zero', {result => '0'}],
  ['input-undefined', {input => undef, parsed => undef}], ['input-empty', {input => '', parsed => undef}],
  ['bad-kind', {node_kind => 'unknown'}], ['missing-method', {method => undef}],
  ['bad-deps', {deps => []}], ['undefined-deps', {deps => undef}],
 );
 if ($which eq 'pipeline') {
  push @cases, ['wrapped-statement', {wrapper => 1}], ['replace-span-slot', {replace_span => 1}],
   ['source-undefined', {source => undef}], ['source-empty', {source => ''}],
   ['value-source-undefined', {outcome => 'undefined', value_source => undef}],
   ['value-source-empty', {outcome => 'undefined', value_source => ''}],
   ['value-source-zero', {outcome => 'undefined', value_source => '0'}];
  push @cases, ['span-'.($_->[0]), {span => $_->[1]}] for (['undefined', undef], ['array', []], ['string', 'span']);
  push @cases, ["method-$_", {method => $_}] for qw(split split_each trim_each filter_nonempty filter_match lowercase_each uppercase_each uniq return set unknown);
  push @cases, ["secondary-$_", {node_kind => $_, secondary => 'SECONDARY'}]
   for qw(assign_scalar assign_array_append assign_hash_index assign_nested_access fluent_chain receiver_mutation_chain);
 } else {
  push @cases, ['separate-effective', {separate_effective => 1, outcome => 'effect'}],
   ['replace-in-normalize', {replace_in_normalize => 1}], ['expected-mismatch', {expected => 'push'}],
   ['guard-zero', {guard => '0'}], ['guard-empty', {guard => ''}], ['guard-undefined', {guard => undef}];
  push @cases, ['normalize-'.($_->[0]), {normalize => $_->[1]}]
   for (['undefined', undef], ['empty', ''], ['zero', '0'], ['empty-array', []], ['wrong-shape', 'bad']);
  push @cases, ['arg-source-'.($_->[0]), {arg_source => $_->[1]}]
   for (['undefined', undef], ['zero', '0']);
  push @cases, ["missing-required-$_", {missing_required => $_}]
   for qw(normalize_method_args_with_optional_scope trim_action_ir_value);
  push @authority, observe($which.'/fallback-known-'.$_, $which, {missing => 1}, $_) for (0, 1);
 }
 push @branches, observe($which.'/'.$_->[0], $which, $_->[1]) for @cases;
 push @authority, observe($which.'/code/known-'.$_, $which, {}, $_) for (0, 1);
 for my $variant (qw(code qualified unqualified blessed-code glob undefined array hash name-object)) {
  for my $known (undef, 0, 1) {
   next if $variant eq 'code' && !defined $known;
   my $state;
   no warnings qw(redefine once);
   local *LinkedSpec::ActionIR::MethodLowering::ast_optional_named;
   my $original_setup = \&setup;
   local *AstOptionalProbe::setup = sub {
    $state = $original_setup->(@_);
    *LinkedSpec::ActionIR::MethodLowering::ast_optional_named = $state->{actual};
    my $selected = $variant eq 'code' ? $state->{actual}
     : $variant eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::ast_optional_named'
     : $variant eq 'unqualified' ? 'ast_optional_named'
     : $variant eq 'blessed-code' ? bless(sub {return $state->{actual}->(@_)}, 'AstOptionalProbe::BlessedCode')
     : $variant eq 'glob' ? \*LinkedSpec::ActionIR::MethodLowering::ast_optional_named
     : $variant eq 'array' ? [] : $variant eq 'hash' ? {}
     : $variant eq 'name-object' ? bless({name => 'LinkedSpec::ActionIR::MethodLowering::ast_optional_named'}, 'AstOptionalProbe::Name')
     : undef;
    my @sequence = $which eq 'pipeline' ? ($selected) : ($state->{first}, $selected);
    my %deps;
    tie %deps, 'AstOptionalProbe::Map', $state->{storage}, \@sequence, $state->{fetches}, $state->{role};
    $state->{deps} = \%deps;
    return $state;
   };
   my $id = $which.'/tied-'.$variant.(defined($known) ? '/known-'.$known : '');
   my $row = observe($id, $which, {}, $known);
   if (defined $known) { push @authority, $row }
   else { push @symbolic, $row }
  }
 }
}
print JSON::PP->new->canonical->encode({mode => $mode, loaded_before => $loaded_before,
 loaded_after => $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0,
 callbacks => \@callbacks, branches => \@branches, authority => \@authority, symbolic => \@symbolic}), "\n";

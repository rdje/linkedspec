package SourceAssignmentKindProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

my @assignment_required = qw(extract_scalar_symbol_name extract_array_symbol_name
 extract_hash_symbol_name lower_assignment_source_expr lower_declare_initializer_expr
 trim_action_ir_value);
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
 package SourceAssignmentKindProbe::Map;
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
 package SourceAssignmentKindProbe::Kind;
 use overload '""' => sub {
  my ($self) = @_;
  ++$self->{state}{coercions};
  die $self->{state}{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}
{
 package SourceAssignmentKindProbe::Name;
 use overload '""' => sub { $_[0]{name} }, fallback => 1;
}

sub setup {
 my ($owner, $options) = @_;
 my $state = {owner => $owner, options => $options, trace => [], helpers => [], fetches => [],
  eligible => [], coercions => 0, first_calls => 0,
  input => exists($options->{input}) ? $options->{input} : $owner eq 'read' ? 'item' : 'array(item)',
  source => 'SOURCE', fatal => bless({}, 'SourceAssignmentKindProbe::Fatal')};
 my %storage;
 my $record = sub {
  my ($role, $slot, $want, $incoming) = @_;
  push @{$state->{trace}}, {role => $role, argument => copied($$slot),
   context => !defined($want) ? 'void' : $want ? 'list' : 'scalar',
   incoming_error => copied($incoming), readonly => Internals::SvREADONLY($$slot) ? 1 : 0,
   caller_slot => same($slot, \$state->{input}), source_slot => same($slot, \$state->{source})};
 };
 $state->{first} = sub { ++$state->{first_calls}; return 'WRONG' };
 $state->{replacement} = sub {
  $record->('replacement', \$_[0], wantarray, $@);
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
   if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  return $owner eq 'read' ? 'hash' : 'scalar';
 };
 $state->{returned} = bless({state => $state, text => $owner eq 'read' ? 'array' : 'scalar',
  fatal => ($options->{outcome} // '') eq 'coercion-fatal'}, 'SourceAssignmentKindProbe::Kind');
 $state->{actual} = sub {
  $record->('kind', \$_[0], wantarray, $@);
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
   if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
  if (($options->{outcome} // '') eq 'effect') {
   eval { $_[0] .= '!'; $state->{written} = $_[0]; 1 } or $state->{write_error} = $@;
  }
  $storage{bare_symbol_kind} = $state->{replacement} if $options->{replace_in_kind};
  $@ = 'successful source-assignment kind';
  die $state->{fatal} if ($options->{outcome} // '') eq 'fatal';
  return undef if ($options->{outcome} // '') eq 'undefined';
  return $state->{returned} if ($options->{outcome} // '') =~ /^(?:reference|coercion-fatal)$/;
  if ($state->{event}) {
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'PUBLISHED');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  return exists($options->{kind}) ? $options->{kind} : $owner eq 'read' ? 'array' : 'scalar';
 };
 for my $role (@assignment_required) {
  $storage{$role} = sub {
   $record->($role, \$_[0], wantarray, $@);
   if ($role eq 'trim_action_ir_value') {
    $storage{bare_symbol_kind} = $state->{replacement} if $options->{replace_in_trim};
    $_[0] = $options->{trim_mutation} if exists $options->{trim_mutation};
    return exists($options->{trim}) ? $options->{trim} : $_[0];
   }
   return exists($options->{source_result}) ? $options->{source_result} : 'LOWERED'
    if $role eq 'lower_assignment_source_expr';
   return exists($options->{initializer}) ? $options->{initializer} : 'INIT'
    if $role eq 'lower_declare_initializer_expr';
   return exists($options->{$role}) ? $options->{$role} : undef;
  };
 }
 $storage{bare_symbol_kind} = $state->{actual};
 $storage{unrelated} = sub { die 'unrelated source-assignment callback invoked' };
 $state->{unrelated} = $storage{unrelated};
 delete $storage{bare_symbol_kind} if $options->{missing};
 $storage{bare_symbol_kind} = $options->{bad_kind} if exists $options->{bad_kind};
 delete $storage{$options->{missing_required}} if $options->{missing_required};
 my $deps = \%storage;
 if ($options->{tied}) {
  my $selected = exists($options->{selected}) ? $options->{selected} : $state->{actual};
  my @sequence = ($state->{first}, $selected);
  @sequence = ('not CODE') if $options->{tied} eq 'first-bad';
  my %map;
  tie %map, 'SourceAssignmentKindProbe::Map', \%storage, \@sequence, $state->{fetches};
  $deps = \%map;
 }
 $state->{deps} = $deps;
 $state->{storage} = \%storage;
 return $state;
}

sub owner {
 my ($state) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr(
  $state->{input}, $state->{deps}) if $state->{owner} eq 'read';
 no warnings 'redefine';
 # Only assignment's downstream value and tracked-write helpers are controlled.
 # Real eager resolution, trim, target guards, optional selection and fallbacks run.
 local *LinkedSpec::ActionIR::MethodLowering::_lower_value_binding_source_expr = sub {
  push @{$state->{helpers}}, {name => 'binding', source => copied($_[0]),
   actual_map => same($_[1], $state->{deps})};
  return exists($state->{options}{binding}) ? $state->{options}{binding} : 'VALUE';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr = sub {
  push @{$state->{helpers}}, {name => 'tracked', target => copied($_[0]), value => copied($_[1]),
   actual_map => same($_[2], $state->{deps}), flag => $_[3]};
  return 'TRACKED';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement(
  $state->{input}, $state->{source}, $state->{deps});
}

sub observe {
 my ($id, $which, $options, $known) = @_;
 my $state = setup($which, $options);
 my ($value, $error, $success_error, $packet, $capture);
 my $invoke = sub {
  eval { $@ = 'incoming source-assignment kind'; $value = owner($state); $success_error = $@; 1 } or $error = $@;
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
  success_error => copied($success_error), caller_after => copied($state->{input}), source_after => copied($state->{source}),
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
for my $which (qw(read assign)) {
 push @callbacks, observe($which.'/'.$_, $which, {outcome => $_})
  for $mode eq 'observe' ? qw(string effect undefined fatal reference coercion-fatal) : qw(string effect fatal);
 next if $mode ne 'observe';
 my @cases = (
  ['missing', {missing => 1}], ['undefined', {bad_kind => undef}],
  ['string', {bad_kind => 'not CODE'}], ['array', {bad_kind => []}],
  ['hash', {bad_kind => {}}], ['blessed', {bad_kind => bless({}, 'SourceAssignmentKindProbe::NotCode')}],
  ['tied', {tied => 'ordinary'}], ['tied-first-bad', {tied => 'first-bad'}],
  ['tied-second-bad', {tied => 'ordinary', selected => 'not CODE'}],
  ['replace-in-trim', {replace_in_trim => 1}], ['replace-in-kind', {replace_in_kind => 1}],
  ['empty', {kind => ''}], ['zero', {kind => '0'}], ['scalar', {kind => 'scalar'}],
  ['hash-result', {kind => 'hash'}], ['array-result', {kind => 'array'}], ['unknown', {kind => 'unknown'}],
  ['input-undefined', {input => undef}], ['input-empty', {input => ''}], ['input-zero', {input => '0'}],
  ['trim-undefined', {trim => undef}], ['trim-empty', {trim => ''}], ['trim-zero', {trim => '0'}],
  ['colon', {input => ':item'}], ['non-name', {input => 'item!'}],
  ['trim-mutation', {trim_mutation => $which eq 'read' ? 'changed' : 'hash(changed)'}],
 );
 if ($which eq 'read') {
  push @cases, ["reserved-$_", {input => $_, tied => 'ordinary', selected => 'not CODE'}]
   for qw(undef true false descr STRING info minfo IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS CAPTURE);
  push @cases, ['required-before-undefined', {input => undef, missing_required => 'trim_action_ir_value'}];
 } else {
  push @cases, ['bare-target', {input => 'item', tied => 'ordinary', selected => 'not CODE'}],
   ['hash-target', {input => 'hash(item)'}], ['wrapper-spaces', {input => ' hash ( item ) '}],
   ['wrapper-invalid', {input => 'array(item!)', tied => 'ordinary', selected => 'not CODE'}],
   ['other-wrapper', {input => 'codeblock(item)', tied => 'ordinary', selected => 'not CODE'}];
  push @cases, ['binding-'.($_//'undefined'), {binding => $_}] for ('','0',undef);
  push @cases, ["fallback-$_", {kind => 'array', $_ => 'SLOT'}]
   for qw(extract_scalar_symbol_name extract_array_symbol_name extract_hash_symbol_name);
  push @cases, ["required-before-target-$_", {input => undef, missing_required => $_}] for @assignment_required;
 }
 push @branches, observe($which.'/'.$_->[0], $which, $_->[1]) for @cases;
 push @authority, observe($which.'/code/known-'.$_, $which, {}, $_) for (0, 1);
 for my $variant (qw(code qualified unqualified blessed-code glob undefined array hash name-object)) {
  for my $known (undef, 0, 1) {
   next if $variant eq 'code' && !defined $known;
   my $state;
   no warnings qw(redefine once);
   local *LinkedSpec::ActionIR::MethodLowering::source_assignment_kind_named;
   my $original_setup = \&setup;
   local *SourceAssignmentKindProbe::setup = sub {
    $state = $original_setup->(@_);
    *LinkedSpec::ActionIR::MethodLowering::source_assignment_kind_named = $state->{actual};
    my $selected = $variant eq 'code' ? $state->{actual}
     : $variant eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::source_assignment_kind_named'
     : $variant eq 'unqualified' ? 'source_assignment_kind_named'
     : $variant eq 'blessed-code' ? bless(sub {return $state->{actual}->(@_)}, 'SourceAssignmentKindProbe::BlessedCode')
     : $variant eq 'glob' ? \*LinkedSpec::ActionIR::MethodLowering::source_assignment_kind_named
     : $variant eq 'array' ? [] : $variant eq 'hash' ? {}
     : $variant eq 'name-object' ? bless({name => 'LinkedSpec::ActionIR::MethodLowering::source_assignment_kind_named'}, 'SourceAssignmentKindProbe::Name')
     : undef;
    my @sequence = ($state->{first}, $selected);
    my %deps;
    tie %deps, 'SourceAssignmentKindProbe::Map', $state->{storage}, \@sequence, $state->{fetches};
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

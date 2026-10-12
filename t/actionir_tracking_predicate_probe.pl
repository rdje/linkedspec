package TrackingPredicateProbe;
use strict;
use warnings;
use B ();
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
sub target_slot {
 local $@;
 my $cv = B::svref_2object($_[0]);
 my @pads = $cv->PADLIST->ARRAY;
 my @names = $cv->PADLIST->NAMES->ARRAY;
 my @values = $pads[$cv->DEPTH || 1]->ARRAY;
 for my $index (0 .. $#names) {
  next unless $names[$index]->can('PV') && ($names[$index]->PV // '') eq '$target';
  return $values[$index]->object_2svref;
 }
 die 'active predicate target pad unavailable';
}
{
 package TrackingPredicateProbe::Map;
 sub TIEHASH { bless {storage => $_[1], sequence => $_[2], state => $_[3]}, $_[0] }
 sub FETCH {
  my ($self, $key) = @_;
  my $state = $self->{state};
  push @{$state->{fetches}}, $key;
  die $state->{fatal} if $state->{options}{fetch_fatal};
  if ($key eq $state->{role} && @{$self->{sequence}}) {
   return @{$self->{sequence}} > 1 ? shift @{$self->{sequence}} : $self->{sequence}[0];
  }
  return $self->{storage}{$key};
 }
 sub STORE { $_[0]{storage}{$_[1]} = $_[2] }
 sub FIRSTKEY { $_[0]{iteration} = [sort keys %{$_[0]{storage}}]; shift @{$_[0]{iteration}} }
 sub NEXTKEY { shift @{$_[0]{iteration}} }
}
{
 package TrackingPredicateProbe::Boolean;
 use overload 'bool' => sub {
  my ($self) = @_;
  my $state = $self->{state};
  ++$state->{boolean_calls};
  push @{$state->{boolean_trace}}, {incoming_error => $@,
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  $@ = 'successful predicate boolean';
  die $state->{fatal} if $self->{fatal};
  return $self->{value};
 }, fallback => 1;
}
{
 package TrackingPredicateProbe::Target;
 use overload '""' => sub {
  my ($self) = @_;
  ++$self->{state}{target_coercions};
  die $self->{state}{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}

sub setup {
 my ($owner, $path, $options) = @_;
 my $state = {owner => $owner, path => $path, options => $options, trace => [],
  fetches => [], eligible => [], values => [], boolean_calls => 0, boolean_trace => [],
  target_coercions => 0, fatal => bless({}, 'TrackingPredicateProbe::Fatal')};
 $state->{target} = exists($options->{target}) ? $options->{target} : 'item';
 $state->{target} = bless({state => $state, text => 'item', fatal => $options->{target_object} eq 'fatal'},
  'TrackingPredicateProbe::Target') if $options->{target_object};
 $state->{role} = $owner eq 'receiver' ? 'receiver_mutation_target' : 'nested_write_target';
 $state->{helper} = $owner eq 'receiver'
  ? \&LinkedSpec::ActionIR::MethodLowering::_receiver_mutation_target_is_tracked
  : \&LinkedSpec::ActionIR::MethodLowering::_nested_write_target_is_tracked;
 my %storage;
 my $make = sub {
  my ($role) = @_;
  return sub {
   my $incoming = $@;
   my $pad = target_slot($state->{helper});
   my $entry = {role => $role, arguments => copied(\@_), incoming_error => copied($incoming),
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    readonly => Internals::SvREADONLY($_[0]) ? 1 : 0,
    caller_slot => same(\$_[0], \$state->{target}), helper_target_slot => same(\$_[0], $pad),
    helper_target_before => copied($$pad)};
   push @{$state->{trace}}, $entry;
   push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
    if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
   my $outcome = $options->{outcome} // 'true';
   $_[0] .= '!' if $outcome eq 'effect';
   $entry->{helper_target_after} = copied($$pad);
   $entry->{argument_after} = copied($_[0]);
   $storage{$state->{role}} = $state->{replacement} if $options->{replace_next} && $role eq 'selected';
   $@ = 'successful predicate '.$role;
   die $state->{fatal} if $outcome eq 'fatal';
   if ($state->{event}) {
    my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
    LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'PUBLISHED');
    LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   }
   return undef if $outcome eq 'undefined';
   return '' if $outcome eq 'empty';
   return '0' if $outcome eq 'zero';
   return 0 if $outcome eq 'false';
   return 'false' if $outcome eq 'false-word';
   return [] if $outcome eq 'array';
   return {} if $outcome eq 'hash';
   return sub {return $state->{role}} if $outcome eq 'code';
   return bless({state => $state, value => $outcome eq 'bool-false' ? 0 : 1,
    fatal => $outcome eq 'bool-fatal'}, 'TrackingPredicateProbe::Boolean') if $outcome =~ /^bool-/;
   return 1;
  };
 };
 $state->{actual} = $make->('selected');
 $state->{replacement} = $make->('replacement');
 $storage{$state->{role}} = $state->{actual};
 $storage{rule_label} = 'PredicateProbe';
 $storage{unrelated} = sub {die 'unrelated predicate callback invoked'};
 $state->{unrelated} = $storage{unrelated};
 delete $storage{$state->{role}} if $options->{missing};
 if ($options->{bad_callback}) {
  my $kind = $options->{bad_callback};
  $storage{$state->{role}} = $kind eq 'undefined' ? undef : $kind eq 'array' ? [] : $kind eq 'hash' ? {}
   : $kind eq 'blessed-code' ? bless(sub {return $state->{actual}->(@_)}, 'TrackingPredicateProbe::NotCode')
   : $kind eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::predicate_named'
   : $kind eq 'unqualified' ? 'predicate_named' : 'not CODE';
 }
 my $deps = \%storage;
 if ($options->{tied}) {
  my @sequence = $options->{tied} eq 'switch' ? ($state->{actual}, $state->{replacement})
   : $options->{tied} eq 'bad-first' ? ('not CODE', $state->{actual}) : ();
  my %map;
  tie %map, 'TrackingPredicateProbe::Map', \%storage, \@sequence, $state;
  $deps = \%map;
 }
 $deps = $options->{deps} if exists $options->{deps};
 $state->{deps} = $deps;
 $state->{storage} = \%storage;
 return $state;
}

sub owner {
 my ($state) = @_;
 my $options = $state->{options};
 no warnings qw(redefine once);
 local *LinkedSpec::ActionIR::MethodLowering::predicate_named = $state->{actual};
 return $state->{helper}->($state->{target}, $state->{deps}) if $state->{path} eq 'primary';
 my $inner = exists($options->{inner}) ? $options->{inner} : 'INNER';
 if ($state->{owner} eq 'receiver') {
  my $attempt = exists($options->{attempt}) ? $options->{attempt} : 'write';
  my $span = exists($options->{span}) ? $options->{span} : {start => 2, end => 6};
  return LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr(
   $state->{target}, $attempt, $span, $state->{deps}, $inner);
 }
 return LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr(
  $state->{target}, $inner, $state->{deps}, $options->{returns_value} // 0);
}

sub observe {
 my ($id, $owner, $path, $options, $known) = @_;
 my $state = setup($owner, $path, $options);
 my ($value, $error, $success_error, $packet, $capture);
 my $invoke = sub {
  eval {
   for (1 .. ($options->{twice} ? 2 : 1)) {
    $@ = 'incoming predicate';
    my $context = $options->{context} // 'scalar';
    if ($context eq 'list') {my @values = owner($state); $value = \@values}
    elsif ($context eq 'void') {owner($state); $value = undef}
    else {$value = owner($state)}
    $success_error = $@;
    push @{$state->{values}}, copied($value);
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
   my $outer = sub {$invoke->(); die $error if $error; return 'PUBLISHED'};
   my @known = $known ? ($outer, $state->{actual}) : ($outer);
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(\@known, sub {
    eval {$capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer); 1} or $error = $@;
    $packet = $capture && LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0;
   });
  });
 } else {$invoke->()}
 return {id => $id, owner => $owner, path => $path, value => copied($value), values => $state->{values},
  error => ref($error) ? {type => ref($error), actual_fatal => same($error, $state->{fatal})} : $error,
  success_error => copied($success_error), caller_after => copied($state->{target}),
  target_coercions => $state->{target_coercions}, trace => $state->{trace}, fetches => $state->{fetches},
  eligible => $state->{eligible}, parent_packet => $packet, boolean_calls => $state->{boolean_calls},
  boolean_trace => $state->{boolean_trace}, unrelated => same($state->{storage}{unrelated}, $state->{unrelated}),
  map_actual => same($state->{storage}{$state->{role}}, $options->{replace_next} ? $state->{replacement} : $state->{actual})};
}

my $mode = shift @ARGV // '';
die 'use observe or cold-observe' unless $mode eq 'observe' || $mode eq 'cold-observe';
my $loaded_before = $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0;
if ($mode eq 'observe') {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my (@callbacks, @branches, @authority);
for my $owner (qw(receiver nested)) {
 for my $path (qw(primary consumer)) {
  my $prefix = $owner.'/'.$path;
  push @callbacks, observe($prefix.'/'.$_, $owner, $path, {outcome => $_})
   for $mode eq 'observe'
    ? qw(true false undefined empty zero false-word effect fatal bool-true bool-false bool-fatal array hash code)
    : qw(true effect fatal bool-fatal);
  next if $mode ne 'observe';
  my @cases = (['missing', {missing => 1}], ['tied', {tied => 'ordinary'}],
   ['tied-fetch-fatal', {tied => 'ordinary', fetch_fatal => 1}],
   ['tied-switch', {tied => 'switch', twice => 1}], ['tied-bad-first', {tied => 'bad-first', twice => 1}],
   ['replace-next', {replace_next => 1, twice => 1}], ['tied-replace-next', {tied => 'ordinary', replace_next => 1, twice => 1}],
   ['target-object', {target_object => 'ordinary'}], ['target-object-fatal', {target_object => 'fatal'}]);
  push @cases, ['callback-'.$_, {bad_callback => $_}]
   for qw(undefined string qualified unqualified array hash blessed-code);
  push @cases, ['target-'.$_->[0], {target => $_->[1], tied => 'ordinary'}]
   for (['undefined', undef], ['empty', ''], ['zero', '0'], ['digit', '1item'], ['space', ' item'],
    ['sigil', '$item'], ['colon', ':item'], ['newline', "item\n"], ['unicode', 'it'.chr(0xe9).'m'],
    ['array', []], ['hash', {}], ['underscore', '_item'], ['upper-digit', 'A9']);
  push @cases, ['deps-'.$_->[0], {deps => $_->[1]}]
   for (['undefined', undef], ['array', []], ['string', 'map'], ['blessed-hash', bless({}, 'TrackingPredicateProbe::NotHash')]);
  push @cases, ['context-'.$_, {context => $_}] for qw(list void);
  if ($path eq 'consumer') {
   push @cases, ['inner-'.$_->[0], {inner => $_->[1]}] for (['undefined', undef], ['empty', ''], ['zero', '0']);
   if ($owner eq 'receiver') {
    push @cases, ['attempt-'.$_->[0], {attempt => $_->[1]}] for (['undefined', undef], ['empty', '']);
    push @cases, ['span-'.$_->[0], {span => $_->[1]}]
     for (['undefined', undef], ['array', []], ['negative', {start => -1, end => 6}]);
   } else {push @cases, ['returns-value', {returns_value => 1}]}
  }
  push @branches, observe($prefix.'/'.$_->[0], $owner, $path, $_->[1]) for @cases;
  for my $outcome (qw(true false undefined zero bool-true bool-false bool-fatal fatal)) {
   push @authority, observe($prefix.'/'.$outcome.'/known-'.$_, $owner, $path, {outcome => $outcome}, $_) for (0, 1);
  }
  push @authority, observe($prefix.'/tied-code/known-'.$_, $owner, $path, {tied => 'ordinary'}, $_) for (0, 1);
 }
}
print JSON::PP->new->canonical->ascii->encode({mode => $mode, loaded_before => $loaded_before,
 loaded_after => $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0,
 callbacks => \@callbacks, branches => \@branches, authority => \@authority}), "\n";

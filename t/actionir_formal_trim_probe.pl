package FormalTrimProbe;
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
 return [map {copied($_)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_ => copied($value->{$_})} sort keys %$value} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub pads {
 local $@;
 my $cv = B::svref_2object($_[0]);
 my @pads = $cv->PADLIST->ARRAY;
 my @names = $cv->PADLIST->NAMES->ARRAY;
 my @values = $pads[$cv->DEPTH || 1]->ARRAY;
 my %result;
 for my $index (0 .. $#names) {
  next unless $names[$index]->can('PV');
  my $name = $names[$index]->PV // '';
  next unless $name =~ /\A\$(?:expr|trimmed|trim_action_ir_value|receiver|call_expr)\z/;
  $result{$name} = $values[$index]->object_2svref;
 }
 die 'active formal expression/trim pad unavailable'
  unless $result{'$expr'} && $result{'$trim_action_ir_value'} && $result{'$trimmed'};
 return \%result;
}
sub pad_snapshot {
 my ($pads) = @_;
 return {map {$_ => copied(${$pads->{$_}})} grep {$_ ne '$trim_action_ir_value'} sort keys %$pads};
}
{
 package FormalTrimProbe::Text;
 use overload '""' => sub {
  my ($self) = @_;
  my $state = $self->{state};
  push @{$state->{coercions}}, {role => $self->{role}, incoming_error => FormalTrimProbe::copied($@),
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  $@ = 'successful formal coercion';
  die $state->{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}
{
 package FormalTrimProbe::Callable;
 use overload '&{}' => sub {$_[0]{callback}}, fallback => 1;
}

sub setup {
 my ($owner, $options) = @_;
 my $state = {owner => $owner, options => $options, trace => [], coercions => [], eligible => [],
  values => [], fatal => bless({}, 'FormalTrimProbe::Fatal')};
 $state->{input} = exists($options->{input}) ? $options->{input} : $owner eq 'brace' ? '{ PAYLOAD }' : 'item.method()';
 $state->{helper} = $owner eq 'brace'
  ? \&LinkedSpec::ActionIR::MethodLowering::_extract_outer_brace_payload
  : \&LinkedSpec::ActionIR::MethodLowering::_split_receiver_dot_method_expr;
 if ($options->{input_object}) {
  $state->{input} = bless({state => $state, role => 'input', text => $state->{input},
   fatal => $options->{input_object} eq 'fatal'}, 'FormalTrimProbe::Text');
 }
 my $make = sub {
  my ($role) = @_;
  return sub {
   my $incoming = $@;
   my $ordinal = ++$state->{ordinal};
   my $pads = pads($state->{helper});
   my $before = $_[0];
   my $entry = {role => $role, invocation => $state->{invocation}, ordinal => $ordinal,
    arguments => copied(\@_), context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    incoming_error => copied($incoming), readonly => Internals::SvREADONLY($_[0]) ? 1 : 0,
    expr_slot => same(\$_[0], $pads->{'$expr'}), trimmed_slot => same(\$_[0], $pads->{'$trimmed'}),
    caller_slot => same(\$_[0], \$state->{input}),
    formal_initial => same(${$pads->{'$trim_action_ir_value'}}, $state->{initial}),
    formal_actual => same(${$pads->{'$trim_action_ir_value'}}, $state->{actual}),
    pads_before => pad_snapshot($pads)};
   push @{$state->{trace}}, $entry;
   push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
    if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
   my $target = $options->{site} // 1;
   my $outcome = $ordinal == $target ? ($options->{outcome} // 'mirror') : 'mirror';
   $_[0] .= '!' if $outcome eq 'effect' || $outcome eq 'mutated';
   $entry->{argument_after} = copied($_[0]);
   $entry->{pads_after} = pad_snapshot($pads);
   $state->{supplied} = $state->{replacement} if $options->{replace_caller} && $role eq 'selected';
   $@ = 'successful formal '.$role.'/'.$ordinal;
   die $state->{fatal} if $outcome eq 'fatal';
   if ($state->{event} && $ordinal == $target) {
    my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
    LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'PUBLISHED');
    LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   }
   return undef if $outcome eq 'undefined';
   return '' if $outcome eq 'empty';
   return '0' if $outcome eq 'zero';
   return 'false' if $outcome eq 'false-word';
   return $state->{returned_array} = [] if $outcome eq 'array';
   return $state->{returned_hash} = {} if $outcome eq 'hash';
   return $state->{returned_code} = sub {return $role} if $outcome eq 'code';
   if ($outcome eq 'object' || $outcome eq 'coercion-fatal') {
    my $text = $owner eq 'brace' ? '{ OBJECT }' : $ordinal == 1 ? 'object.call()' : 'OBJECT';
    return $state->{returned_object} = bless({state => $state, role => 'result-'.$ordinal,
     text => $text, fatal => $outcome eq 'coercion-fatal'}, 'FormalTrimProbe::Text');
   }
   return $options->{replacement_text} if $outcome eq 'replacement';
   my $result = $outcome eq 'mutated' ? $_[0] : $before;
   unless (ref($result)) { $result =~ s/^\s+//; $result =~ s/\s+$//; }
   return $result;
  };
 };
 $state->{actual} = $make->('selected');
 $state->{replacement} = $make->('replacement');
 my $kind = $options->{callable} // 'code';
 $state->{supplied} = $kind eq 'undefined' ? undef : $kind eq 'array' ? [] : $kind eq 'hash' ? {}
  : $kind eq 'qualified' ? 'LinkedSpec::ActionIR::MethodLowering::formal_named'
  : $kind eq 'unqualified' ? 'formal_named' : $kind eq 'string' ? 'missing_formal_callback'
  : $kind eq 'blessed-code' ? bless(sub {return $state->{actual}->(@_)}, 'FormalTrimProbe::Blessed')
  : $kind eq 'amp-object' ? bless({callback => $state->{actual}}, 'FormalTrimProbe::Callable')
  : $kind eq 'glob' ? \*LinkedSpec::ActionIR::MethodLowering::formal_named : $state->{actual};
 if ($kind eq 'bound') {
  $state->{supplied} = LinkedSpec::ActionIR::MethodLowering::_bind_emission_dependency($state->{actual});
 }
 return $state;
}

sub owner {
 my ($state) = @_;
 ++$state->{invocation};
 $state->{ordinal} = 0;
 $state->{initial} = $state->{supplied};
 no warnings qw(redefine once);
 local *LinkedSpec::ActionIR::MethodLowering::formal_named = $state->{actual};
 return $state->{helper}->($state->{input}, $state->{supplied});
}

sub observe {
 my ($id, $owner, $options, $known) = @_;
 my $state = setup($owner, $options);
 my ($value, $error, $success_error, $packet, $capture);
 my $invoke = sub {
  eval {
   for (1 .. ($options->{twice} ? 2 : 1)) {
    $@ = 'incoming formal';
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
   my @known = ($outer);
   push @known, $state->{actual} if $known;
   push @known, $state->{supplied} if $options->{register_formal};
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(\@known, sub {
    eval {$capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer); 1} or $error = $@;
    $packet = $capture && LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0;
   });
  });
 } else {$invoke->()}
 my $identity = {};
 if (ref($value) eq 'ARRAY') {
  for my $type (qw(array hash code object)) {
   $identity->{$type} = [map {same($_, $state->{'returned_'.$type})} @$value];
  }
 }
 return {id => $id, owner => $owner, value => copied($value), values => $state->{values},
  result_identity => $identity, caller_after => copied($state->{input}),
  error => ref($error) ? {type => ref($error), actual_fatal => same($error, $state->{fatal})} : $error,
  success_error => copied($success_error), trace => $state->{trace}, coercions => $state->{coercions},
  eligible => $state->{eligible}, parent_packet => $packet,
  caller_callback_replaced => same($state->{supplied}, $state->{replacement})};
}

my $mode = shift @ARGV // '';
die 'use observe or cold-observe' unless $mode eq 'observe' || $mode eq 'cold-observe';
my $loaded_before = $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0;
if ($mode eq 'observe') {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my (@callbacks, @branches, @authority, @symbolic);
for my $owner (qw(brace dot)) {
 for my $site ($owner eq 'brace' ? (1) : (1, 2, 3)) {
  my $prefix = $owner.'/site-'.$site;
  push @callbacks, observe($prefix.'/'.$_, $owner, {site => $site, outcome => $_})
   for $mode eq 'observe'
    ? qw(mirror effect mutated undefined empty zero false-word fatal array hash code object coercion-fatal)
    : qw(mirror effect fatal);
  if ($mode eq 'cold-observe') {
   push @callbacks, observe($prefix.'/bound-'.$_, $owner, {site => $site, outcome => $_, callable => 'bound'})
    for qw(mirror effect fatal);
   push @symbolic, observe($prefix.'/'.$_, $owner, {site => $site, callable => $_})
    for qw(qualified unqualified blessed-code amp-object glob);
  }
  next if $mode ne 'observe';
  push @branches, observe($prefix.'/context-'.$_, $owner, {site => $site, context => $_}) for qw(list void);
  push @branches, observe($prefix.'/caller-replacement', $owner, {site => $site, replace_caller => 1, twice => 1});
  for my $known (0, 1) {
   push @authority, observe($prefix.'/code/known-'.$known, $owner, {site => $site}, $known);
   push @authority, observe($prefix.'/bound/known-'.$known, $owner, {site => $site, callable => 'bound'}, $known);
   push @authority, observe($prefix.'/bound-registered/known-'.$known, $owner,
    {site => $site, callable => 'bound', register_formal => 1}, $known);
   push @authority, observe($prefix.'/fatal/known-'.$known, $owner, {site => $site, outcome => 'fatal'}, $known);
   push @authority, observe($prefix.'/effect/known-'.$known, $owner, {site => $site, outcome => 'effect'}, $known);
  }
  for my $kind (qw(qualified unqualified blessed-code amp-object glob)) {
   push @symbolic, observe($prefix.'/'.$kind, $owner, {site => $site, callable => $kind});
   push @symbolic, observe($prefix.'/'.$kind.'/known-'.$_, $owner, {site => $site, callable => $kind}, $_) for (0, 1);
  }
 }
 if ($mode eq 'cold-observe') {
  for my $kind (qw(undefined string array hash)) {
   push @symbolic, observe($owner.'/invalid-'.$kind, $owner, {callable => $kind});
   push @symbolic, observe($owner.'/guarded-'.$kind, $owner, {callable => $kind, input => undef});
   push @symbolic, observe($owner.'/empty-'.$kind, $owner, {callable => $kind, input => ''});
  }
 }
 next if $mode ne 'observe';
 my @inputs = (['undefined', undef], ['empty', ''], ['zero', '0'], ['space', ' '],
  ['ordinary', 'ordinary'], ['nested', $owner eq 'brace' ? '{ { INNER } }' : '(inner.call()).outer()'],
  ['single-quote', $owner eq 'brace' ? q!{ '}' }! : q!'inner.call'.outer()!],
  ['double-quote', $owner eq 'brace' ? q!{ "}" }! : q!"inner.call".outer()!],
  ['escaped-single', $owner eq 'brace' ? q!{ '\\' }! : q!'it\'s.dot'.outer()!],
  ['escaped-double', $owner eq 'brace' ? q!{ "a\"}b" }! : q!"a\".b".outer()!],
  ['unclosed', $owner eq 'brace' ? '{ INNER' : '(inner.call().outer()'],
  ['trailing', $owner eq 'brace' ? '{ INNER } junk' : 'item.method().next()'],
  ['empty-payload', $owner eq 'brace' ? '{}' : '.method()'],
  ['empty-tail', $owner eq 'brace' ? '{ }' : 'item.'],
  ['decimal', $owner eq 'brace' ? '{ 1.25 }' : '1.25.round()'],
  ['bracket', $owner eq 'brace' ? '{ [1, 2] }' : '[inner.call].outer()'],
  ['brace', $owner eq 'brace' ? '{ { x => "}" } }' : '{inner.call}.outer()'],
  ['whitespace', $owner eq 'brace' ? "\n { PAYLOAD } \t" : "\n item . method() \t"],
  ['unicode', $owner eq 'brace' ? '{ '.chr(0xe9).' }' : chr(0xe9).'.method()']);
 push @branches, observe($owner.'/input-'.$_->[0], $owner, {input => $_->[1]}) for @inputs;
 push @branches, observe($owner.'/input-object', $owner, {input_object => 'ordinary'});
 push @branches, observe($owner.'/input-object-fatal', $owner, {input_object => 'fatal'});
 for my $kind (qw(undefined string array hash)) {
  push @symbolic, observe($owner.'/invalid-'.$kind, $owner, {callable => $kind});
  push @symbolic, observe($owner.'/guarded-'.$kind, $owner, {callable => $kind, input => undef});
  push @symbolic, observe($owner.'/empty-'.$kind, $owner, {callable => $kind, input => ''});
 }
}
print JSON::PP->new->canonical->ascii->encode({mode => $mode, loaded_before => $loaded_before,
 loaded_after => $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'} ? 1 : 0,
 callbacks => \@callbacks, branches => \@branches, authority => \@authority, symbolic => \@symbolic}), "\n";

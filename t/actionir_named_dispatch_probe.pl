package NamedDispatchProbe;
use strict;
use warnings;
use B ();
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

my @names = qw(
 _lower_scalar_assignment_operator_statement
 _lower_array_append_operator_statement
 _lower_array_end_mutation_method_statement
 _lower_hash_index_assignment_operator_statement
 _lower_set_key_statement
 _lower_push_statement
);
my $package = 'LinkedSpec::ActionIR::MethodLowering';
my $helper = \&LinkedSpec::ActionIR::MethodLowering::_lower_block_side_effect_statement;
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
 my $cv = B::svref_2object($helper);
 my @frames = $cv->PADLIST->ARRAY;
 my @names = $cv->PADLIST->NAMES->ARRAY;
 my @values = $frames[$cv->DEPTH || 1]->ARRAY;
 my %pads;
 for my $index (0 .. $#names) {
  next unless $names[$index]->can('PV');
  my $name = $names[$index]->PV // '';
  next unless $name =~ /\A\$(?:expr|trimmed|deps|lowerer|lowered)\z/;
  $pads{$name} = $values[$index]->object_2svref;
 }
 die 'active dispatch expression/deps pads unavailable'
  unless $pads{'$expr'} && $pads{'$trimmed'} && $pads{'$deps'};
 return \%pads;
}
sub snapshot {
 my ($pads) = @_;
 my %result;
 for my $name (sort keys %$pads) {
  next if $name eq '$lowerer';
  my $slot = $pads->{$name};
  $result{$name} = copied($$slot);
 }
 return \%result;
}
{
 package NamedDispatchProbe::Text;
 use overload '""' => sub {
  my ($self) = @_;
  push @{$self->{state}{coercions}}, {
   incoming_error => NamedDispatchProbe::copied($@),
   context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  $@ = 'successful dispatch coercion';
  die $self->{state}{fatal} if $self->{fatal};
  return $self->{text};
 }, fallback => 1;
}
sub emit {
 my ($state) = @_;
 return unless $state->{event};
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'PUBLISHED');
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
}
sub setup {
 my ($options) = @_;
 my $state = {options => $options, trace => [], auxiliary => [], coercions => [], eligible => [],
  values => [], fatal => bless({}, 'NamedDispatchProbe::Fatal'), invocation => 0};
 $state->{input} = exists($options->{input}) ? $options->{input} : ' statement ';
 my $trim = sub {
  push @{$state->{auxiliary}}, {role => 'trim', arguments => copied([@_])};
  $@ = 'successful dispatch trim';
  return $options->{trim_result} if exists $options->{trim_result};
  my $value = $_[0];
  return $value if ref($value);
  $value =~ s/^\s+|\s+$//g if defined $value;
  return $value;
 };
 my $parse = sub {
  push @{$state->{auxiliary}}, {role => 'parse', arguments => copied([@_])};
  $@ = 'successful dispatch parse';
  return $state->{call};
 };
 my $normalize = sub {
  push @{$state->{auxiliary}}, {role => 'normalize', arguments => copied([@_]),
   actual_array => same($_[0], $state->{args})};
  $@ = 'successful dispatch normalize';
  return undef if $options->{normalize_undefined};
  return $_[0];
 };
 $state->{args} = ['target', 'value'];
 $state->{call} = exists($options->{method}) ? {method => $options->{method}, args => $state->{args}} : undef;
 $state->{deps} = {marker => 'original', trim_action_ir_value => $trim,
  parse_method_function_expr => $parse, normalize_method_args_with_optional_scope => $normalize};
 delete $state->{deps}{$options->{missing}} if $options->{missing};
 $state->{caller_deps} = $state->{deps};
 $state->{returned_array} = ['actual'];
 $state->{returned_hash} = {marker => 'actual'};
 $state->{returned_code} = sub {return 'actual'};
 $state->{returned_object} = bless({state => $state, text => 'OBJECT'}, 'NamedDispatchProbe::Text');
 my $make = sub {
  my ($index, $role) = @_;
  return sub {
   my $incoming = $@;
   my $pads = pads();
   my $lowerer_slot = $pads->{'$lowerer'};
   my $deps_slot = $pads->{'$deps'};
   my $entry = {index => $index, name => $names[$index], role => $role, invocation => $state->{invocation},
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    incoming_error => copied($incoming), arguments => copied([@_]),
    trimmed_slot => same(\$_[0], $pads->{'$trimmed'}), deps_slot => same(\$_[1], $deps_slot),
    caller_input_slot => same(\$_[0], \$state->{input}), caller_deps_slot => same(\$_[1], \$state->{deps}),
    original_map => same($_[1], $state->{caller_deps}), readonly_first => Internals::SvREADONLY($_[0]) ? 1 : 0,
    selected_actual => $lowerer_slot ? same($$lowerer_slot, $state->{actual}[$index]) : undef,
    pads_before => snapshot($pads)};
   push @{$state->{trace}}, $entry;
   push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0
    if defined &LinkedSpec::ActionIR::SourceEmissions::_eligible_call;
   my $target = $options->{target} // 0;
   my $outcome = $index == $target ? ($options->{outcome} // 'string') : 'undefined';
   if ($index == $target) {
    $_[0] .= '!' if $outcome eq 'effect' || $options->{mutate_trimmed};
    $_[1]{effects} = ($_[1]{effects} // 0) + 1 if $options->{mutate_map};
    $_[1] = {marker => 'replacement'} if $options->{replace_deps};
    if (defined $options->{replace_name}) {
     no strict 'refs';
     no warnings 'redefine';
     *{$package.'::'.$names[$options->{replace_name}]} = $state->{replacement};
    }
    emit($state);
   }
   $entry->{arguments_after} = copied([@_]);
   $entry->{pads_after} = snapshot($pads);
   $@ = 'successful dispatch '.$role.'/'.$index;
   die $state->{fatal} if $outcome eq 'fatal';
   return 'REPLACEMENT' if $role eq 'replacement';
   return undef if $outcome eq 'undefined';
   return '' if $outcome eq 'empty';
   return '0' if $outcome eq 'zero';
   return 'false' if $outcome eq 'false-word';
   return $state->{'returned_'.$outcome} if $outcome =~ /\A(?:array|hash|code|object)\z/;
   return bless({state => $state, text => 'FATAL', fatal => 1}, 'NamedDispatchProbe::Text')
    if $outcome eq 'coercion-fatal';
   return 'PUBLISHED';
  };
 };
 $state->{actual} = [map {$make->($_, 'selected')} 0 .. $#names];
 $state->{replacement} = $make->($options->{replace_name} // 0, 'replacement');
 return $state;
}
sub with_targets {
 my ($state, $invoke) = @_;
 no warnings qw(redefine once);
 local *LinkedSpec::ActionIR::MethodLowering::_lower_scalar_assignment_operator_statement = $state->{actual}[0];
 local *LinkedSpec::ActionIR::MethodLowering::_lower_array_append_operator_statement = $state->{actual}[1];
 local *LinkedSpec::ActionIR::MethodLowering::_lower_array_end_mutation_method_statement = $state->{actual}[2];
 local *LinkedSpec::ActionIR::MethodLowering::_lower_hash_index_assignment_operator_statement = $state->{actual}[3];
 local *LinkedSpec::ActionIR::MethodLowering::_lower_set_key_statement = $state->{actual}[4];
 local *LinkedSpec::ActionIR::MethodLowering::_lower_push_statement = $state->{actual}[5];
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {
  push @{$state->{auxiliary}}, {role => 'ast', arguments => copied([@_])};
  return $state->{options}{ast_result};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement = sub {
  push @{$state->{auxiliary}}, {role => 'assign', arguments => copied([@_])};
  return exists($state->{options}{assign_result}) ? $state->{options}{assign_result} : 'ASSIGN';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr = sub {
  push @{$state->{auxiliary}}, {role => 'component', arguments => copied([@_])};
  die $state->{fatal} if $state->{options}{component_fatal};
  return exists($state->{options}{component_result}) ? $state->{options}{component_result} : 'PUBLISHED';
 };
 return $invoke->();
}
sub observe {
 my ($id, $options, $known) = @_;
 my $state = setup($options);
 my @original = map {$package->can($_)} @names;
 my ($value, $error, $success_error, $packet, $capture);
 my $invoke = sub {
  eval {
   with_targets($state, sub {
    for (1 .. ($options->{twice} ? 2 : 1)) {
     ++$state->{invocation};
     $@ = 'incoming dispatch';
     my $context = $options->{context} // 'scalar';
     if ($context eq 'list') {my @values = $helper->($state->{input}, $state->{deps}); $value = \@values}
     elsif ($context eq 'void') {$helper->($state->{input}, $state->{deps}); $value = undef}
     else {$value = $helper->($state->{input}, $state->{deps})}
     $success_error = $@;
     push @{$state->{values}}, copied($value);
    }
   });
   1;
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
   push @known, @{$state->{actual}} if $known;
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(\@known, sub {
    eval {$capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer); 1} or $error = $@;
    $packet = $capture && LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $outer, $event) ? 1 : 0;
   });
  });
 } else {$invoke->()}
 return {id => $id, value => copied($value), values => $state->{values},
  result_identity => {map {$_ => same($value, $state->{'returned_'.$_})} qw(array hash code object)},
  error => ref($error) ? {type => ref($error), actual_fatal => same($error, $state->{fatal})} : $error,
  success_error => copied($success_error), trace => $state->{trace}, auxiliary => $state->{auxiliary},
  coercions => $state->{coercions}, eligible => $state->{eligible}, parent_packet => $packet,
  caller_input => copied($state->{input}), caller_deps => copied($state->{deps}),
  original_map => copied($state->{caller_deps}),
  names_restored => [map {same($package->can($names[$_]), $original[$_])} 0 .. $#names]};
}
my $mode = shift @ARGV // '';
die 'observe or cold-observe required' unless $mode eq 'observe' || $mode eq 'cold-observe';
my $loaded_before = exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
if ($mode eq 'observe') {
 require LinkedSpec::ActionIR::SourceOrigins;
 require LinkedSpec::ActionIR::SourceEmissions;
}
my (@callbacks, @branches, @authority);
for my $target (0 .. $#names) {
 my @outcomes = $mode eq 'observe'
  ? qw(string effect undefined empty zero false-word fatal array hash code object coercion-fatal)
  : qw(string effect fatal);
 push @callbacks, observe('target-'.$target.'/'.$_, {target => $target, outcome => $_}) for @outcomes;
 next unless $mode eq 'observe';
 for my $context (qw(list void)) {
  push @branches, observe('target-'.$target.'/context-'.$context, {target => $target, context => $context});
 }
 for my $effect (qw(mutate_trimmed mutate_map replace_deps)) {
  push @branches, observe('target-'.$target.'/'.$effect,
   {target => $target, outcome => 'undefined', $effect => 1});
 }
 for my $known (0, 1) {
  push @authority, observe('target-'.$target.'/'.$_.'/known-'.$known,
   {target => $target, outcome => $_}, $known) for qw(string effect undefined fatal object);
 }
}
my @guards = (
 ['input-undefined', {input => undef}], ['input-empty', {input => ''}],
 ['trim-undefined', {trim_result => undef}], ['trim-empty', {trim_result => ''}],
 ['ast-string', {ast_result => 'AST'}], ['ast-zero', {ast_result => '0'}],
 ['parser-return', {method => 'return'}],
 ['component-undefined', {outcome => 'undefined', component_result => undef}],
 ['component-empty', {outcome => 'undefined', component_result => ''}],
 ['component-fatal', {outcome => 'undefined', component_fatal => 1}],
);
if ($mode eq 'observe') {
 push @guards,
  ['set-fallback', {input => 'set(target,value)', method => 'set', outcome => 'undefined'}],
  ['set-assign-empty', {input => 'set(target,value)', method => 'set', outcome => 'undefined', assign_result => ''}],
  ['set-normalize-undefined', {input => 'set(target,value)', method => 'set', outcome => 'undefined', normalize_undefined => 1}],
  ['set-source-mismatch', {input => 'ordinary', method => 'set', outcome => 'undefined'}];
 for my $missing (qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope)) {
  push @guards, ['missing-'.$missing, {input => undef, missing => $missing}];
 }
 for my $index (0, 3, 5) {
  push @branches, observe('snapshot-replace-'.$index,
   {target => 0, outcome => 'undefined', replace_name => $index, twice => 1});
  push @branches, observe('snapshot-fatal-'.$index,
   {target => 0, outcome => 'fatal', replace_name => $index});
 }
}
push @branches, observe($_->[0], $_->[1]) for @guards;
my $payload = {mode => $mode, names => \@names, loaded_before => $loaded_before,
 loaded_after => exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,
 callbacks => \@callbacks, branches => \@branches, authority => \@authority};
print JSON::PP->new->canonical->ascii->encode($payload), "\n";

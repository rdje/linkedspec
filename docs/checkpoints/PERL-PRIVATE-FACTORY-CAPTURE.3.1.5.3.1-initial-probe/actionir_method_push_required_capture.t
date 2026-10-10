use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $owner = '_lower_push_statement';
my @roles = qw(parse_method_function_expr extract_array_symbol_name
 trim_action_ir_value lower_primitive_literal_expr);
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return [map {encoded($_)} @$value] if ref($value) eq 'ARRAY';
 return {type => 'HASH', marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub slot_index {
 my ($slot, $slots) = @_;
 for my $i (0..$#$slots) {return $i if same($slot, $slots->[$i])}
 return undef;
}
sub setup {
 my ($role, $outcome, $options) = @_;
 $options ||= {};
 my $arity = $options->{arity} // 2;
 my $state = {role => $role, outcome => $outcome, options => $options, arity => $arity,
  input => exists($options->{input}) ? $options->{input} : 'push(target,value)',
  args => exists($options->{args}) ? $options->{args} : $arity == 3
   ? ['scope', 'legacy target', 'value expression'] : ['legacy target', 'value expression'],
  trace => [], helpers => [], events => [], eligible => [], calls => 0,
  trim_slots => [], extractor_slots => [], reference => {marker => 'actual-result'}};
 $state->{call} = {method => $options->{method} // 'push', args => $state->{args}};
 $state->{raw_slots} = ref($state->{args}) eq 'ARRAY' ? [map {\$state->{args}[$_]} 0..$#{$state->{args}}] : [];
 my $fatal = bless {}, 'MethodPushRequiredFatal';
 my %deps;
 for my $name (@roles) {
  $deps{$name} = sub {
   my @readonly = map {Internals::SvREADONLY($_) ? 1 : 0} @_;
   push @{$state->{events}}, $name;
   push @{$state->{trace}}, {role => $name, args => [map {encoded($_)} @_], readonly => \@readonly,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    original_input_slot => same(\$_[0], \$state->{input}),
    raw_slot => slot_index(\$_[0], $state->{raw_slots}),
    previous_trim_slot => slot_index(\$_[0], $state->{trim_slots}),
    previous_extractor_slot => slot_index(\$_[0], $state->{extractor_slots})};
   my $result;
   if ($name eq 'parse_method_function_expr') {
    $result = $options->{parse_undefined} ? undef : $state->{call};
   } elsif ($name eq 'trim_action_ir_value') {
    my $ordinal = @{$state->{trim_slots}};
    push @{$state->{trim_slots}}, \$_[0];
    $result = ref($options->{trims}) eq 'HASH' && exists($options->{trims}{$ordinal})
     ? $options->{trims}{$ordinal} : $_[0];
   } elsif ($name eq 'extract_array_symbol_name') {
    my $ordinal = @{$state->{extractor_slots}};
    push @{$state->{extractor_slots}}, \$_[0];
    $result = ref($options->{symbols}) eq 'ARRAY' ? $options->{symbols}[$ordinal]
     : exists($options->{symbol}) ? $options->{symbol} : 'ARRAY_SLOT';
   } else {
    $result = exists($options->{primitive}) ? $options->{primitive} : 'PRIMITIVE';
   }
   if ($name eq $role) {
    ++$state->{calls};
    $_[0] .= '!' if defined($_[0]) && !ref($_[0]) && !$readonly[0];
    $@ = 'successful push required callback';
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    if ($state->{event} && $state->{calls} == 1) {
     my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($state->{event});
     LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $state->{publication});
     LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
    }
   }
   return $result;
  };
 }
 $state->{original} = {%deps};
 return (\%deps, $state, $fatal);
}
sub invoke_owner {
 my ($deps, $state) = @_;
 my $options = $state->{options};
 my $helper = sub {
  my ($name, $args, $map) = @_;
  push @{$state->{events}}, $name;
  my $row = {name => $name, args => [map {encoded($_)} @$args]};
  $row->{actual_map} = same($map, $deps) if defined $map;
  push @{$state->{helpers}}, $row;
 };
 no warnings 'redefine';
 # Exercise the actual owner; its secondary helpers are explicit controls.
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {
  $helper->('ast', [@_], $_[2]);
  return $state->{reference} if $options->{ast_reference};
  return $options->{ast};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
  $helper->('value', [@_], $_[1]);
  $state->{helpers}[-1]{trim_slot} = slot_index(\$_[0], $state->{trim_slots});
  return exists($options->{value}) ? $options->{value} : 'VALUE';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub {
  $helper->('binding', [@_], $_[2]);
  $state->{helpers}[-1]{trim_slot} = slot_index(\$_[0], $state->{trim_slots});
  $state->{helpers}[-1]{extractor_slot} = slot_index(\$_[0], $state->{extractor_slots});
  return $options->{binding};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_push_expr = sub {
  $helper->('push', [@_]);
  return $state->{reference} if $options->{push_reference};
  return exists($options->{push}) ? $options->{push} : 'PUSH';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_ambiguous_push_expr = sub {
  $helper->('ambiguous', [@_]);
  return $state->{reference} if $options->{ambiguous_reference};
  return exists($options->{ambiguous}) ? $options->{ambiguous} : 'AMBIGUOUS';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_push_statement($state->{input}, $deps);
}
sub invoke {
 my ($role, $outcome, $options) = @_;
 my ($deps, $state, $fatal) = setup(@_);
 my ($value, $error, $success_error);
 eval {$@ = 'incoming push required error'; $value = invoke_owner($deps, $state); $success_error = $@; 1} or $error = $@;
 return {role => $role, outcome => $outcome, arity => $state->{arity}, value => encoded($value), calls => $state->{calls},
  trace => $state->{trace}, helpers => $state->{helpers}, events => $state->{events},
  input_after => $state->{input}, args_after => encoded($state->{args}),
  map_identity => (grep {!same($deps->{$_}, $state->{original}{$_})} @roles) ? 0 : 1,
  reference_identity => same($value, $state->{reference}), success_error => $success_error,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $fatal)} : $error};
}
sub branch_cases {
 my @cases;
 my @parsed = qw(ast parse_method_function_expr);
 my @preview = (@parsed, qw(trim_action_ir_value trim_action_ir_value lower_primitive_literal_expr));
 my @target = (@preview, 'trim_action_ir_value');
 my @symbol = (@target, 'extract_array_symbol_name');
 my @value = (@symbol, 'trim_action_ir_value');
 my @full = (@value, qw(value binding));
 my @scoped = (@parsed, qw(trim_action_ir_value extract_array_symbol_name));
 my @three_target = (@scoped, qw(trim_action_ir_value trim_action_ir_value lower_primitive_literal_expr trim_action_ir_value));
 my @three_symbol = (@three_target, 'extract_array_symbol_name');
 my @three_value = (@three_symbol, 'trim_action_ir_value');
 my @three_full = (@three_value, qw(value binding));
 my $plain = 'push @ARRAY_SLOT, VALUE';
 for my $ast ('FAST', '0', '') {
  push @cases, ['ast-'.$ast, {ast => $ast}, length($ast) ? $ast : $plain, length($ast) ? ['ast'] : \@full];
 }
 push @cases, ['ast-reference', {ast_reference => 1}, {type => 'HASH', marker => 'actual-result'}, ['ast']];
 for my $guard (['undefined', {parse_undefined => 1}], ['other-method', {method => 'other'}]) {
  push @cases, ['parser-'.$guard->[0], $guard->[1], undef, \@parsed];
 }
 for my $case (['undefined', undef], ['empty', []], ['one', ['a']], ['four', [qw(a b c d)]]) {
  push @cases, ['args-'.$case->[0], {args => $case->[1]}, undef, \@parsed];
 }
 push @cases, ['two-normal', {}, $plain, \@full];
 push @cases, ['three-normal', {arity => 3}, $plain, \@three_full];
 for my $slot (0..3) {
  for my $value (undef, '', '0') {
   my $stops = (!defined($value) || !length($value)) && $slot >= 2;
   push @cases, ['two-trim-'.$slot.'-'.($value // 'undefined'), {trims => {$slot => $value}},
    $stops ? undef : $plain, $stops ? ($slot == 2 ? \@target : \@value) : \@full];
  }
 }
 for my $slot (0, 3, 4) {
  for my $value (undef, '', '0') {
   my $stops = !defined($value) || !length($value);
   push @cases, ['three-trim-'.$slot.'-'.($value // 'undefined'), {arity => 3, trims => {$slot => $value}},
    $stops ? undef : $plain, $stops ? ($slot == 0 ? [@parsed, 'trim_action_ir_value'] : $slot == 3 ? \@three_target : \@three_value) : \@three_full];
  }
 }
 for my $symbol (undef, '', '0') {
  push @cases, ['symbol-'.($symbol // 'undefined'), {symbol => $symbol},
   defined($symbol) && length($symbol) ? 'push @0, VALUE' : undef,
   defined($symbol) && length($symbol) ? \@full : \@symbol];
 }
 push @cases, ['bare-target-fallback', {args => ['items', 'value expression'], symbol => undef}, 'push @items, VALUE', \@full];
 push @cases, ['word-target-fallback', {args => ['0', 'value expression'], symbol => undef}, 'push @0, VALUE', \@full];
 push @cases, ['scope-undefined-nonbare', {arity => 3, symbol => undef}, undef, \@scoped];
 push @cases, ['scope-undefined-bare', {arity => 3, args => ['scope', 'items', 'value expression'], symbol => undef}, 'push @items, VALUE', \@three_full];
 push @cases, ['scope-undefined-digit', {arity => 3, args => ['scope', '0', 'value expression'], symbol => undef}, undef, \@scoped];
 push @cases, ['scope-empty-defined', {arity => 3, symbol => ''}, undef, \@three_symbol];
 for my $primitive (undef, '', '0') {
  push @cases, ['bare-primitive-'.($primitive // 'undefined'), {args => ['items', 'value'], primitive => $primitive},
   defined($primitive) ? $plain : 'AMBIGUOUS', defined($primitive) ? \@full : [@preview, 'ambiguous']];
 }
 for my $value (undef, '', '0') {
  push @cases, ['value-'.($value // 'undefined'), {value => $value},
   defined($value) && length($value) ? 'push @ARRAY_SLOT, 0' : 'push @ARRAY_SLOT, value expression', \@full];
 }
 for my $binding (undef, '', '0') {
  push @cases, ['binding-'.($binding // 'undefined'), {binding => $binding},
   defined($binding) ? 'PUSH' : $plain, defined($binding) ? [@full, 'push'] : \@full];
 }
 push @cases, ['push-reference', {binding => 'BOUND', push_reference => 1}, {type => 'HASH', marker => 'actual-result'}, [@full, 'push']];
 push @cases, ['push-undefined', {binding => 'BOUND', push => undef}, undef, [@full, 'push']];
 push @cases, ['ambiguous-reference', {args => ['Child', 'items'], primitive => undef, ambiguous_reference => 1}, {type => 'HASH', marker => 'actual-result'}, [@preview, 'ambiguous']];
 push @cases, ['ambiguous-undefined', {args => ['Child', 'items'], primitive => undef, ambiguous => undef}, undef, [@preview, 'ambiguous']];
 push @cases, ['undefined-input', {input => undef}, $plain, \@full];
 return \@cases;
}
sub public_cases {
 return (['append', 'push(items, 1)'], ['child', 'push(Child, items)'],
  ['scoped-append', 'push(Top, items, 1)'], ['removed-selector', 'push(array(items), 1)']);
}
sub observations {
 my @public = map {my ($case, $source) = @$_; my ($value, $error);
  eval {$value = LinkedSpec::call_spec_handler_subst('Top', $source); 1} or $error = $@;
  {case => $case, source => $source, value => $value, error => $error}} public_cases();
 return {callbacks => [map {my $arity = $_; map {my $role = $_; map {invoke($role, $_, {arity => $arity})} qw(string undefined fatal)} @roles} (2, 3)],
  branches => [map {{case => $_->[0], %{invoke('none', 'string', $_->[1])}}} @{branch_cases()}], public => \@public};
}
if (@ARGV && $ARGV[0] eq 'observe') {print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0}
for my $arity (2, 3) {
 for my $role (@roles) {
  for my $outcome (qw(string undefined fatal)) {
   my $row = invoke($role, $outcome, {arity => $arity});
   my $label = "$arity/$role/$outcome";
   my @calls = grep {$_->{role} eq $role} @{$row->{trace}};
   my $count = $outcome eq 'fatal' ? 1 : $role eq 'trim_action_ir_value'
    ? $outcome eq 'undefined' ? ($arity == 3 ? 1 : 3) : ($arity == 3 ? 5 : 4)
    : $role eq 'extract_array_symbol_name' && $arity == 3 && $outcome eq 'string' ? 2 : 1;
   is($row->{calls}, $count, "$label native invocation count");
   ok($row->{map_identity}, "$label public references survive");
   is($row->{input_after}, 'push(target,value)', "$label caller input remains unchanged");
   for my $i (0..$#calls) {
    my $call = $calls[$i];
    is($call->{context}, 'scalar', "$label/$i native scalar context");
    is($call->{error}, $i ? 'successful push required callback' : 'incoming push required error', "$label/$i native incoming error");
    is($call->{original_input_slot}, 0, "$label/$i caller input is a local copy");
    if ($role eq 'trim_action_ir_value') {
     my @raw = $arity == 2 ? (0, 1, 0, 1) : (1, undef, undef, undef, undef);
     my @prior = $arity == 2 ? (undef, undef, 0, 1) : (undef, undef, undef, 1, 2);
     is($call->{raw_slot}, $raw[$i], "$label/$i actual raw versus copied effective slot");
     is($call->{previous_trim_slot}, $prior[$i], "$label/$i repeated trim keeps actual effective slot identity");
    } elsif ($role ne 'parse_method_function_expr') {
     is($call->{raw_slot}, undef, "$label/$i callback receives local scalar rather than raw array slot");
     is($call->{previous_trim_slot}, undef, "$label/$i callback local is distinct from trimmed array slot");
    }
   }
   if ($outcome eq 'fatal') {
    is_deeply($row->{error}, {type => 'MethodPushRequiredFatal', same_fatal => 1}, "$label fatal object retains actual identity");
   } else {
    is($row->{error}, undef, "$label bounded native route completes");
    is($row->{success_error}, 'successful push required callback', "$label successful error effect survives");
    my $rejects = $outcome eq 'undefined' && $role ne 'lower_primitive_literal_expr';
    is($row->{value}, $rejects ? undef : 'push @ARRAY_SLOT, VALUE', "$label native result");
    my $expected_args = $arity == 3 ? ['scope', 'legacy target', 'value expression'] : ['legacy target', 'value expression'];
    if ($role eq 'trim_action_ir_value') {
     $expected_args = $arity == 3 ? ['scope', 'legacy target!', 'value expression']
      : $outcome eq 'undefined' ? ['legacy target!!', 'value expression!'] : ['legacy target!!', 'value expression!!'];
    }
    is_deeply($row->{args_after}, $expected_args, "$label native raw-array mutation boundary");
    if (!$rejects) {
     my ($binding) = grep {$_->{name} eq 'binding'} @{$row->{helpers}};
     is($binding->{trim_slot}, undef, "$label binding receives a local target copy");
     is($binding->{extractor_slot}, $arity == 3 ? 1 : 0, "$label binding shares final extractor target slot");
     my ($value) = grep {$_->{name} eq 'value'} @{$row->{helpers}};
     is($value->{trim_slot}, undef, "$label value helper receives a local value copy");
    }
   }
  }
  my $baseline = invoke($role, 'string', {arity => $arity});
  for my $known (0, 1) {
   LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
    my $event = {raw => 'same'};
    LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event, {event => $event, source => 'same', source_span => {start => 0, end => 4}});
    my ($deps, $state) = setup($role, 'string', {arity => $arity});
    $state->{event} = $event; $state->{publication} = $baseline->{value};
    my $outer = sub {return invoke_owner($deps, $state)};
    LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $deps->{$role}] : [$outer], sub {
     my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
     my $label = "$owner/$arity/$role/$known";
     is($result->{value}, $baseline->{value}, "$label ordinary value survives");
     ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event), "$label required dependency cannot donate nested publication");
     is_deeply($state->{eligible}, [($known) x $baseline->{calls}], "$label actual callback has its own identity boundary");
     is($state->{calls}, $baseline->{calls}, "$label actual effect count survives");
     is(refaddr($deps->{$role}), refaddr($state->{original}{$role}), "$label public callback stays actual");
    });
   });
  }
  for my $bad (undef, 'not code') {
   my ($deps, $state) = setup('none', 'string', {arity => $arity, ast => 'FAST'});
   $deps->{$role} = $bad;
   my $error; eval {invoke_owner($deps, $state); 1} or $error = $@;
   like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
    "$owner/$arity/$role required diagnostic retains native selection");
   is_deeply($state->{events}, [], "$owner/$arity/$role eager validation precedes AST fast path");
  }
 }
}
my $rows = observations();
my $cases = branch_cases();
for my $i (0..$#$cases) {
 my ($label, $options, $value, $events) = @{$cases->[$i]};
 my $row = $rows->{branches}[$i];
 is_deeply($row->{value}, $value, "$label bounded native result");
 is_deeply($row->{events}, $events, "$label exact guard and fallback order");
 is($row->{error}, undef, "$label bounded branch completes");
 ok($row->{map_identity}, "$label actual public references survive");
 is($row->{reference_identity}, $label =~ /reference$/ ? 1 : 0, "$label direct result keeps actual reference identity");
 for my $helper (@{$row->{helpers}}) {is($helper->{actual_map}, 1, "$label actual helper map") if exists $helper->{actual_map}}
}
for my $row (@{$rows->{public}}) {
 if ($row->{case} eq 'removed-selector') {
  is($row->{error}, "aggregate_selector_removed surface=array identifier=items replacement=items\n", 'removed-selector actual public Toolbox diagnostic');
  is($row->{value}, undef, 'removed-selector produces no value');
 } else {
  is($row->{error}, undef, "$row->{case} actual public Toolbox diagnostic");
  ok(defined($row->{value}) && length($row->{value}) && $row->{value} ne $row->{source}, "$row->{case} public Toolbox produces lowering");
 }
}
done_testing;

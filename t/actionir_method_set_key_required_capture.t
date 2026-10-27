use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $owner = '_lower_set_key_statement';
my @roles = qw(parse_method_function_expr normalize_method_args_with_optional_scope
 extract_hash_symbol_name lower_scalar_access_key_expr trim_action_ir_value);
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return [map {encoded($_)} @$value] if ref($value) eq 'ARRAY';
 return {type => 'HASH', marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub argument_slot {
 my ($slot, $array) = @_;
 return undef unless ref($array) eq 'ARRAY';
 for my $i (0..$#$array) {return $i if same($slot, \$array->[$i])}
 return undef;
}
sub setup {
 my ($role, $outcome, $options) = @_;
 $options ||= {};
 my $state = {role => $role, outcome => $outcome, options => $options,
  input => exists($options->{input}) ? $options->{input} : 'set_key(meta,key,value)',
  args => exists($options->{args}) ? $options->{args} : ['legacy target', 'key', 'value'],
  trace => [], helpers => [], events => [], eligible => [], calls => 0,
  reference => {marker => 'actual-result'}};
 $state->{call} = {marker => 'parsed-call', method => $options->{method} // 'set_key', args => $state->{args}};
 my $fatal = bless {}, 'MethodSetKeyRequiredFatal';
 my %deps;
 for my $name (@roles) {
  $deps{$name} = sub {
   my @readonly = map {Internals::SvREADONLY($_) ? 1 : 0} @_;
   push @{$state->{events}}, $name;
   push @{$state->{trace}}, {role => $name, args => [map {encoded($_)} @_], readonly => \@readonly,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    original_input_slot => same(\$_[0], \$state->{input}),
    actual_call_args => same($_[0], $state->{call}{args}),
    parser_slot => argument_slot(\$_[0], $state->{args}),
    normalized_slot => argument_slot(\$_[0], $state->{normalized}),
    target_trim_slot => same(\$_[0], $state->{target_trim_slot}),
    key_trim_slot => same(\$_[0], $state->{key_trim_slot})};
   my $result;
   if ($name eq 'parse_method_function_expr') {
    $result = $options->{parse_undefined} ? undef : $state->{call};
   } elsif ($name eq 'normalize_method_args_with_optional_scope') {
    $result = exists($options->{normalized}) ? $options->{normalized} : $_[0];
    $state->{normalized} = $result;
   } elsif ($name eq 'trim_action_ir_value') {
    my $index = argument_slot(\$_[0], $state->{normalized});
    $state->{target_trim_slot} = \$_[0] if defined($index) && $index == 0;
    $state->{key_trim_slot} = \$_[0] if defined($index) && $index == 1;
    $result = ref($options->{trims}) eq 'ARRAY' ? $options->{trims}[$index] : $_[0];
   } elsif ($name eq 'extract_hash_symbol_name') {
    $result = exists($options->{symbol}) ? $options->{symbol} : 'HASH_SLOT';
   } else {
    $result = exists($options->{key}) ? $options->{key} : 'KEY';
   }
   $state->{extractor_slot} = \$_[0] if $name eq 'extract_hash_symbol_name';
   $state->{key_lower_slot} = \$_[0] if $name eq 'lower_scalar_access_key_expr';
   if ($name eq $role) {
    ++$state->{calls};
    if (ref($_[0]) eq 'ARRAY') {push @{$_[0]}, 'effect'}
    elsif (defined($_[0]) && !ref($_[0]) && !$readonly[0]) {$_[0] .= '!'}
    $@ = 'successful set-key required callback';
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
 # The actual statement owner runs; these secondary helpers are explicit controls.
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {
  $helper->('ast', [@_], $_[2]);
  return $state->{reference} if $options->{ast_reference};
  return $options->{ast};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {
  $helper->('mutation', [@_], $_[1]);
  $state->{helpers}[-1]{normalized_slot} = argument_slot(\$_[0], $state->{normalized});
  return exists($options->{value}) ? $options->{value} : 'VALUE';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub {
  $helper->('binding', [@_], $_[2]);
  $state->{helpers}[-1]{target_trim_slot} = same(\$_[0], $state->{target_trim_slot});
  $state->{helpers}[-1]{extractor_slot} = same(\$_[0], $state->{extractor_slot});
  return $options->{binding};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_hash_index_set_expr = sub {
  $helper->('index', [@_]);
  return $state->{reference} if $options->{index_reference};
  return exists($options->{index}) ? $options->{index} : 'INDEX';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_set_key_statement($state->{input}, $deps);
}
sub invoke {
 my ($role, $outcome, $options) = @_;
 my ($deps, $state, $fatal) = setup(@_);
 my ($value, $error, $success_error);
 eval {$@ = 'incoming set-key required error'; $value = invoke_owner($deps, $state); $success_error = $@; 1} or $error = $@;
 return {role => $role, outcome => $outcome, value => encoded($value), calls => $state->{calls},
  trace => $state->{trace}, helpers => $state->{helpers}, events => $state->{events},
  input_after => $state->{input}, args_after => encoded($state->{args}), normalizer_candidate_after => encoded($state->{normalized}),
  candidate_is_call_args => same($state->{normalized}, $state->{call}{args}),
  map_identity => (grep {!same($deps->{$_}, $state->{original}{$_})} @roles) ? 0 : 1,
  reference_identity => same($value, $state->{reference}), success_error => $success_error,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $fatal)} : $error};
}
sub branch_cases {
 my @cases;
 my @early = qw(ast parse_method_function_expr normalize_method_args_with_optional_scope);
 my @trimmed = (@early, ('trim_action_ir_value') x 3);
 my @hashed = (@trimmed, 'extract_hash_symbol_name');
 my @keyed = (@hashed, 'lower_scalar_access_key_expr');
 my @valued = (@keyed, 'mutation');
 my @full = (@valued, 'binding');
 my $plain = 'do { my $__ls_set_key_key = KEY; my $__ls_set_key_value = VALUE; $HASH_SLOT{$__ls_set_key_key} = $__ls_set_key_value }';
 for my $ast ('FAST', '0', '') {
  push @cases, ['ast-'.$ast, {ast => $ast}, length($ast) ? $ast : $plain, length($ast) ? ['ast'] : \@full];
 }
 push @cases, ['ast-reference', {ast_reference => 1}, {type => 'HASH', marker => 'actual-result'}, ['ast']];
 for my $guard (['undefined', {parse_undefined => 1}], ['other-method', {method => 'other'}]) {
  push @cases, ['parser-'.$guard->[0], $guard->[1], undef, [qw(ast parse_method_function_expr)]];
 }
 for my $normalized (undef, '', '0', []) {
  my $label = ref($normalized) ? 'empty-array' : $normalized // 'undefined';
  push @cases, ['normalized-'.$label, {normalized => $normalized}, undef, ref($normalized) ? \@trimmed : \@early];
 }
 push @cases, ['normalized-distinct-array', {normalized => ['other target', 'other key', 'other value']}, $plain, \@full];
 for my $args (undef, []) {
  push @cases, ['args-'.(defined($args) ? 'empty' : 'undefined'), {args => $args}, undef, \@trimmed];
 }
 for my $slot (0..2) {
  for my $value (undef, '', '0') {
   my @trims = ('legacy target', 'key', 'value');
   $trims[$slot] = $value;
   my $nonempty = defined($value) && length($value);
   push @cases, ['trim-'.$slot.'-'.($value // 'undefined'), {trims => \@trims}, $nonempty ? $plain : undef,
    $nonempty ? \@full : \@trimmed];
  }
 }
 for my $value (undef, '', '0') {
  my $nonempty = defined($value) && length($value);
  push @cases, ['symbol-'.($value // 'undefined'), {symbol => $value}, $nonempty ? 'do { my $__ls_set_key_key = KEY; my $__ls_set_key_value = VALUE; $0{$__ls_set_key_key} = $__ls_set_key_value }' : undef,
   $nonempty ? \@full : \@hashed];
  push @cases, ['key-'.($value // 'undefined'), {key => $value}, $nonempty ? 'do { my $__ls_set_key_key = 0; my $__ls_set_key_value = VALUE; $HASH_SLOT{$__ls_set_key_key} = $__ls_set_key_value }' : undef,
   $nonempty ? \@full : \@keyed];
  push @cases, ['value-'.($value // 'undefined'), {value => $value}, $nonempty ? 'do { my $__ls_set_key_key = KEY; my $__ls_set_key_value = 0; $HASH_SLOT{$__ls_set_key_key} = $__ls_set_key_value }' : undef,
   $nonempty ? \@full : \@valued];
 }
 for my $binding (undef, '', '0') {
  push @cases, ['binding-'.($binding // 'undefined'), {binding => $binding}, defined($binding) ? 'INDEX' : $plain,
   defined($binding) ? [@full, 'index'] : \@full];
 }
 push @cases, ['index-reference', {binding => 'BOUND', index_reference => 1}, {type => 'HASH', marker => 'actual-result'}, [@full, 'index']];
 push @cases, ['index-undefined', {binding => 'BOUND', index => undef}, undef, [@full, 'index']];
 push @cases, ['undefined-input', {input => undef}, $plain, \@full];
 return \@cases;
}
sub public_cases {
 return (['statement', 'set_key(meta, "key", 1)', undef],
  ['pure-return', 'return(set_key(meta, "key", 1))', undef],
  ['removed-selector', 'set_key(hash(meta), "key", 1)',
   "aggregate_selector_removed surface=hash identifier=meta replacement=meta\n"]);
}
sub observations {
 my @public = map {my ($case, $source) = @$_; my ($value, $error);
  eval {$value = LinkedSpec::call_spec_handler_subst('Top', $source); 1} or $error = $@;
  {case => $case, source => $source, value => $value, error => $error}} public_cases();
 return {callbacks => [map {my $role = $_; map {invoke($role, $_)} qw(string undefined fatal)} @roles],
  branches => [map {{case => $_->[0], %{invoke('none', 'string', $_->[1])}}} @{branch_cases()}], public => \@public};
}
if (@ARGV && $ARGV[0] eq 'observe') {print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0}
for my $role (@roles) {
 for my $outcome (qw(string undefined fatal)) {
  my $row = invoke($role, $outcome);
  my $label = "$role/$outcome";
  my @calls = grep {$_->{role} eq $role} @{$row->{trace}};
  is($row->{calls}, $role eq 'trim_action_ir_value' && $outcome ne 'fatal' ? 3 : 1, "$label native invocation count");
  ok($row->{map_identity}, "$label actual public references survive");
  is($row->{input_after}, 'set_key(meta,key,value)', "$label caller input remains unchanged");
  for my $i (0..$#calls) {
   my $call = $calls[$i];
   is($call->{context}, 'scalar', "$label/$i native scalar context");
   is($call->{error}, $i ? 'successful set-key required callback' : 'incoming set-key required error', "$label/$i native incoming error");
   is($call->{original_input_slot}, 0, "$label/$i caller input is a local copy");
   if ($role eq 'normalize_method_args_with_optional_scope') {
    is($call->{actual_call_args}, 1, "$label normalizer receives actual parser argument array");
    is_deeply([@{$call->{args}}[1, 2]], [3, 3], "$label actual arity literals");
    is_deeply([@{$call->{readonly}}[1, 2]], [1, 1], "$label arity literals remain readonly");
   } elsif ($role eq 'trim_action_ir_value') {
    is($call->{normalized_slot}, $i, "$label/$i trim receives actual normalized array slot");
    is($call->{parser_slot}, $i, "$label/$i original parser slot alias survives");
   } elsif ($role =~ /^(?:extract_hash|lower_scalar)/) {
    is($call->{normalized_slot}, undef, "$label lowerer receives local trim-result copy");
    is($call->{target_trim_slot}, 0, "$label local scalar is distinct from target array slot");
    is($call->{key_trim_slot}, 0, "$label local scalar is distinct from key array slot");
   }
  }
  if ($outcome eq 'fatal') {
   is_deeply($row->{error}, {type => 'MethodSetKeyRequiredFatal', same_fatal => 1}, "$label fatal object keeps actual identity");
  } else {
   is($row->{error}, undef, "$label bounded native route completes");
   is($row->{success_error}, 'successful set-key required callback', "$label successful error effect survives");
   is($row->{value}, $outcome eq 'undefined' ? undef : 'do { my $__ls_set_key_key = KEY; my $__ls_set_key_value = VALUE; $HASH_SLOT{$__ls_set_key_key} = $__ls_set_key_value }', "$label native result");
   my $expected_args = $role eq 'normalize_method_args_with_optional_scope'
    ? ['legacy target', 'key', 'value', 'effect'] : $role eq 'trim_action_ir_value'
    ? ['legacy target!', 'key!', 'value!'] : ['legacy target', 'key', 'value'];
   is_deeply($row->{args_after}, $expected_args, "$label mutations keep native parser-array versus local-scalar boundary");
   if ($outcome eq 'string') {
    my ($binding) = grep {$_->{name} eq 'binding'} @{$row->{helpers}};
    is($binding->{target_trim_slot}, 0, "$label binding helper does not receive normalized array slot");
    is($binding->{extractor_slot}, 1, "$label binding helper shares actual extractor local target");
    is($binding->{args}[0], $role eq 'extract_hash_symbol_name' ? 'legacy target!' : 'legacy target', "$label local target mutation reaches binding helper");
    my ($mutation) = grep {$_->{name} eq 'mutation'} @{$row->{helpers}};
    is($mutation->{normalized_slot}, undef, "$label mutation helper receives local value copy");
   }
  }
 }
 my $baseline = invoke($role, 'string');
 for my $known (0, 1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event, {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   my ($deps, $state) = setup($role, 'string');
   $state->{event} = $event; $state->{publication} = $baseline->{value};
   my $outer = sub {return invoke_owner($deps, $state)};
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $deps->{$role}] : [$outer], sub {
    my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
    is($result->{value}, $baseline->{value}, "$owner/$role/$known ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event), "$owner/$role/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [($known) x $baseline->{calls}], "$owner/$role/$known actual callback has its own identity boundary");
    is($state->{calls}, $baseline->{calls}, "$owner/$role/$known actual effect count survives");
    is(refaddr($deps->{$role}), refaddr($state->{original}{$role}), "$owner/$role/$known public callback stays actual");
   });
  });
 }
 for my $bad (undef, 'not code') {
  my ($deps, $state) = setup('none', 'string', {ast => 'FAST'});
  $deps->{$role} = $bad;
  my $error; eval {invoke_owner($deps, $state); 1} or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
   "$owner/$role required diagnostic retains native selection");
  is_deeply($state->{events}, [], "$owner/$role eager validation precedes AST fast path");
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
 if ($label eq 'normalized-distinct-array') {
  is($row->{candidate_is_call_args}, 0, 'explicit different normalized array retains its actual identity');
  is_deeply([map {$_->{normalized_slot}} grep {$_->{role} eq 'trim_action_ir_value'} @{$row->{trace}}], [0, 1, 2],
   'trim aliases the selected normalized array slots');
  is_deeply($row->{args_after}, ['legacy target', 'key', 'value'], 'different normalized array leaves parser array unchanged');
 }
}
my @public = public_cases();
for my $i (0..$#public) {
 my ($name, $source, $error) = @{$public[$i]};
 my $row = $rows->{public}[$i];
 is($row->{error}, $error, "$name actual public Toolbox diagnostic");
 if (defined $error) {is($row->{value}, undef, "$name removed selector produces no value")}
 else {ok(defined($row->{value}) && length($row->{value}) && $row->{value} ne $source, "$name public Toolbox produces lowering")}
}
done_testing;

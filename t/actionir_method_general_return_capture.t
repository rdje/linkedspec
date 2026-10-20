use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my %owners = (payload => '_lower_return_payload_expr', statement => '_lower_return_general_statement');
my @targets = (['payload', 'trim_action_ir_value'], ['statement', 'parse_method_function_expr'],
 ['statement', 'trim_action_ir_value']);
sub same {ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0}
sub encoded {
 my ($value) = @_;
 return $value unless ref($value);
 return {type => 'HASH', marker => $value->{marker}} if ref($value) eq 'HASH';
 return {type => ref($value)};
}
sub setup {
 my ($which, $role, $outcome, $options) = @_;
 $options ||= {};
 my $state = {which => $which, role => $role, outcome => $outcome, options => $options,
  input => exists($options->{input}) ? $options->{input} : $which eq 'payload' ? 'payload' : 'return(payload)',
  args => exists($options->{args}) ? $options->{args} : $role eq 'trim_action_ir_value' && $which eq 'statement'
   ? ['Node', 'payload'] : ['payload'],
  trace => [], helpers => [], events => [], eligible => [], calls => 0, reference => {marker => 'actual-result'}};
 $state->{call} = {method => exists($options->{method}) ? $options->{method} : 'return', args => $state->{args}};
 my $fatal = bless {}, 'MethodGeneralReturnFatal';
 my %deps;
 for my $name (qw(trim_action_ir_value parse_method_function_expr)) {
  $deps{$name} = sub {
   push @{$state->{events}}, $name;
   my $slot = ref($state->{args}) eq 'ARRAY' && @{$state->{args}} ? same(\$_[0], \$state->{args}[0]) : 0;
   my $parser_slot;
   if (ref($state->{args}) eq 'ARRAY') {
    for my $i (0..$#{$state->{args}}) {$parser_slot = $i if same(\$_[0], \$state->{args}[$i])}
   }
   push @{$state->{trace}}, {role => $name, args => [map {encoded($_)} @_], error => $@,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
    original_input_slot => same(\$_[0], \$state->{input}), parser_label_slot => $slot, parser_slot => $parser_slot};
   my $result = $name eq 'trim_action_ir_value'
    ? exists($options->{trim}) ? $options->{trim} : $_[0]
    : $options->{parse_undefined} ? undef : $state->{call};
   $_[0] .= '!' if $name eq 'trim_action_ir_value' && $options->{trim_slot_mutation} && defined($_[0]);
   if ($name eq $role) {
    ++$state->{calls};
    $_[0] .= '!' if defined($_[0]) && !ref($_[0]);
    $@ = 'successful general return callback';
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
sub owner {
 my ($deps, $state) = @_;
 my $options = $state->{options};
 my $helper = sub {
  my ($name, $input, $map, $extra) = @_;
  push @{$state->{events}}, $name;
  push @{$state->{helpers}}, {name => $name, input => encoded($input), actual_map => same($map, $deps), %{$extra || {}}};
 };
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {
  $helper->('ast-statement', $_[0], $_[2], {expected_method => $_[1]});
  return $state->{reference} if $options->{ast_statement_reference};
  return $options->{ast_statement};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  $helper->('ast-value', @_);
  return undef if $options->{ast_undefined};
  return 'not a node' if $options->{ast_nonhash};
  return {kind => exists($options->{ast_kind}) ? $options->{ast_kind} : 'call'};
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
  my ($input, $map) = @_;
  $helper->('method', $input, $map);
  return $state->{reference} if $options->{direct_reference};
  if ($options->{raw_grow} && $input =~ /^trim\((x!*)\)$/) {return "trim($1!)"}
  return $options->{rewritten} if exists($options->{rewritten}) && $input =~ /^(?:trim|and)\(/;
  return $input if $options->{direct_equal};
  return exists($options->{direct}) ? $options->{direct} : 'VALUE';
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub {
  $helper->('bare', @_);
  return $state->{reference} if $options->{bare_reference};
  return $options->{bare};
 };
 if ($state->{which} eq 'payload') {
  return LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr($state->{input}, $deps);
 }
 local *LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr = sub {
  my $index;
  if (ref($state->{args}) eq 'ARRAY') {
   for my $i (0..$#{$state->{args}}) {$index = $i if same(\$_[0], \$state->{args}[$i])}
  }
  $helper->('payload', $_[0], $_[1], {parser_slot => $index});
  return $options->{payloads}{$_[0]} if ref($options->{payloads}) eq 'HASH' && exists($options->{payloads}{$_[0]});
  return exists($options->{payload}) ? $options->{payload} : 'VALUE';
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement($state->{input}, $deps);
}
sub invoke {
 my ($which, $role, $outcome, $options) = @_;
 my ($deps, $state, $fatal) = setup($which, $role, $outcome, $options);
 my ($value, $error, $success_error);
 eval {$@ = 'incoming general return error'; $value = owner($deps, $state); $success_error = $@; 1} or $error = $@;
 my $map_identity = !grep {!same($deps->{$_}, $state->{original}{$_})} keys %{$state->{original}};
 return {owner => $which, role => $role, outcome => $outcome, value => encoded($value), calls => $state->{calls},
  trace => $state->{trace}, events => $state->{events}, helpers => $state->{helpers}, input_after => $state->{input},
  args_after => $state->{args}, map_identity => $map_identity ? 1 : 0,
  reference_identity => same($value, $state->{reference}), success_error => $success_error,
  error => ref($error) ? {type => ref($error), same_fatal => same($error, $fatal)} : $error};
}
sub branch_cases {
 my @cases;
 for my $input (undef, '') {
  push @cases, ['payload-input-'.($input // 'undefined'), 'payload', {input => $input}, undef,
   defined($input) ? ['trim_action_ir_value'] : []];
 }
 for my $trim ('', '0', undef) {
  push @cases, ['payload-trim-'.($trim // 'undefined'), 'payload', {trim => $trim},
   defined($trim) && length($trim) ? 'VALUE' : undef,
   defined($trim) && length($trim) ? [qw(trim_action_ir_value ast-value method)] : ['trim_action_ir_value']];
 }
 for my $kind ('call', 'raw_perl', 'variable', '') {
  push @cases, ['payload-kind-'.$kind, 'payload', {ast_kind => $kind}, 'VALUE', [qw(trim_action_ir_value ast-value method)]];
 }
 for my $guard ('ast_undefined', 'ast_nonhash') {
  push @cases, ['payload-'.$guard, 'payload', {$guard => 1}, 'VALUE', [qw(trim_action_ir_value ast-value method)]];
 }
 for my $value ('', '0', undef) {
  push @cases, ['payload-direct-'.($value // 'undefined'), 'payload', {direct => $value},
   defined($value) && length($value) ? $value : 'payload',
   defined($value) && length($value) ? [qw(trim_action_ir_value ast-value method)] : [qw(trim_action_ir_value ast-value method bare)]];
 }
 for my $source ('payload', 'array(x,y)', 'trim(x)', 'and(x,y)') {
  my $early = $source eq 'array(x,y)' || $source eq 'trim(x)';
  push @cases, ['payload-equal-'.$source, 'payload', {input => $source, ast_kind => 'raw_perl', direct_equal => 1}, $source,
   $early ? [qw(trim_action_ir_value ast-value method)] : $source eq 'payload'
   ? [qw(trim_action_ir_value ast-value method bare)] : [qw(trim_action_ir_value ast-value method bare method)]];
 }
 for my $bare ('BARE', '', '0', undef) {
  push @cases, ['payload-bare-'.($bare // 'undefined'), 'payload', {direct => undef, bare => $bare},
   defined($bare) && length($bare) ? $bare : 'payload', [qw(trim_action_ir_value ast-value method bare)]];
 }
 push @cases, ['payload-direct-reference', 'payload', {direct_reference => 1}, {type => 'HASH', marker => 'actual-result'}, [qw(trim_action_ir_value ast-value method)]];
 push @cases, ['payload-bare-reference', 'payload', {direct => undef, bare_reference => 1}, {type => 'HASH', marker => 'actual-result'}, [qw(trim_action_ir_value ast-value method bare)]];
 for my $source ('raw(trim(x))', 'raw(trim("x(y)"))', 'raw(and(x,y))') {
  push @cases, ['payload-rewrite-'.$source, 'payload', {input => $source, ast_kind => 'raw_perl', direct_equal => 1, rewritten => 'LOWERED'},
   'raw(LOWERED)', [qw(trim_action_ir_value ast-value method bare method)]];
 }
 push @cases, ['payload-rewrite-limit', 'payload', {input => 'raw(trim(x))', ast_kind => 'raw_perl', direct_equal => 1, raw_grow => 1},
  'raw(trim(x'.('!' x 64).'))', [qw(trim_action_ir_value ast-value method bare), ('method') x 64]];
 for my $value ('FAST', '0', '') {
  push @cases, ['statement-ast-'.$value, 'statement', {ast_statement => $value}, length($value) ? $value : 'return VALUE',
   length($value) ? ['ast-statement'] : [qw(ast-statement parse_method_function_expr payload)]];
 }
 push @cases, ['statement-ast-reference', 'statement', {ast_statement_reference => 1}, {type => 'HASH', marker => 'actual-result'}, ['ast-statement']];
 for my $guard (['undefined', {parse_undefined => 1}], ['other-method', {method => 'other'}],
  ['missing-args', {args => undef}], ['nonarray-args', {args => 'not array'}], ['empty-args', {args => []}]) {
  push @cases, ['statement-parser-'.$guard->[0], 'statement', $guard->[1], undef, [qw(ast-statement parse_method_function_expr)]];
 }
 push @cases, ['statement-undefined-input', 'statement', {input => undef}, 'return VALUE',
  [qw(ast-statement parse_method_function_expr payload)]];
 for my $payload ('', '0', undef) {
  push @cases, ['statement-single-'.($payload // 'undefined'), 'statement', {payload => $payload},
   defined($payload) && length($payload) ? 'return '.$payload : undef, [qw(ast-statement parse_method_function_expr payload)]];
 }
 for my $label ('Node', '0', 'bad-label', '', undef) {
  my $valid = defined($label) && $label =~ /^\w+$/;
  push @cases, ['statement-label-'.($label // 'undefined'), 'statement', {args => [$label, 'payload']},
   $valid ? "return ['?$label:',  VALUE]" : undef,
   $valid ? [qw(ast-statement parse_method_function_expr trim_action_ir_value payload)]
   : [qw(ast-statement parse_method_function_expr trim_action_ir_value)]];
 }
 for my $payload ('', '0', undef) {
  push @cases, ['statement-fallback-'.($payload // 'undefined'), 'statement', {args => ['Node', 'payload'], payload => $payload},
   defined($payload) && length($payload) ? "return ['?Node:',  $payload]" : "return ['?Node:',  payload]",
   defined($payload) && length($payload) ? [qw(ast-statement parse_method_function_expr trim_action_ir_value payload)]
   : [qw(ast-statement parse_method_function_expr trim_action_ir_value payload trim_action_ir_value)]];
 }
 push @cases, ['statement-multiple', 'statement', {args => ['Node', 'one', 'two'], payloads => {one => 'ONE', two => 'TWO'}},
  "return ['?Node:',  ONE, TWO]", [qw(ast-statement parse_method_function_expr trim_action_ir_value payload payload)]];
 push @cases, ['statement-fallback-empty', 'statement', {args => ['Node', ''], payload => undef}, undef,
  [qw(ast-statement parse_method_function_expr trim_action_ir_value payload trim_action_ir_value)]];
 push @cases, ['statement-fallback-slot-mutation', 'statement', {args => ['Node', 'payload'], payload => undef, trim_slot_mutation => 1},
  "return ['?Node:',  payload]", [qw(ast-statement parse_method_function_expr trim_action_ir_value payload trim_action_ir_value)]];
 return \@cases;
}
sub public_cases {
 return (['retired-a', 'return_a(Top)', 'return_a(Top)'], ['retired-m', 'return_m(Top)', 'return_m(Top)'],
 ['retired-ma', 'return_ma(Top)', 'return_ma(Top)'], ['retired-imatch', 'return_imatch("tag")', 'return_imatch("tag")'],
 ['retired-im', 'return_im("tag")', 'return_im("tag")'], ['retired-array', 'return_array(Top,1)', 'return_array(Top,1)'],
 ['undefined', 'return_undef()', 'return undef'], ['old-migration', 'return(array_copy(array(Top)))', undef],
 ['current-copy', 'return(array(copy(Top)))', 'return [[@Top]]']);
}
sub public_observations {
 return [map {my ($name, $source) = @$_; my ($value, $error);
  eval {$value = LinkedSpec::call_spec_handler_subst('Top', $source); 1} or $error = $@;
  {case => $name, source => $source, value => $value, error => $error}} public_cases()];
}
sub observations {
 return {callbacks => [map {my ($which, $role) = @$_; map {invoke($which, $role, $_)} qw(string undefined fatal)} @targets],
  branches => [map {{case => $_->[0], %{invoke($_->[1], 'none', 'string', $_->[2])}}} @{branch_cases()}], public => public_observations()};
}
if (@ARGV && $ARGV[0] eq 'observe') {print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0}
for my $target (@targets) {
 my ($which, $role) = @$target;
 my $name = $owners{$which};
 for my $outcome (qw(string undefined fatal)) {
  my $row = invoke($which, $role, $outcome);
  my $label = "$which/$role/$outcome";
  is($row->{calls}, 1, "$label actual required callback executes once");
  ok($row->{map_identity}, "$label actual public callback references survive");
  my ($call) = grep {$_->{role} eq $role} @{$row->{trace}};
  is($call->{context}, 'scalar', "$label required scalar context stays native");
  is($call->{original_input_slot}, 0, "$label caller source remains a local copy");
  is($call->{parser_label_slot}, $which eq 'statement' && $role eq 'trim_action_ir_value' ? 1 : 0, "$label keeps native parser label slot alias");
  is($call->{error}, 'incoming general return error', "$label incoming error stays native");
  is($row->{input_after}, $which eq 'payload' ? 'payload' : 'return(payload)', "$label original source remains unchanged");
  if ($outcome eq 'fatal') {
   is_deeply($row->{error}, {type => 'MethodGeneralReturnFatal', same_fatal => 1}, "$label fatal object retains actual identity");
  } else {
   is($row->{error}, undef, "$label bounded native route completes");
   is($row->{success_error}, 'successful general return callback', "$label successful error effect survives");
   is($row->{value}, $outcome eq 'undefined' ? undef : $which eq 'payload' ? 'VALUE'
    : $role eq 'parse_method_function_expr' ? 'return VALUE' : "return ['?Node:',  VALUE]", "$label ordinary result stays native");
  }
 }
 my $baseline = invoke($which, $role, 'string');
 for my $known (0, 1) {
  LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
   my $event = {raw => 'same'};
   LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
    {event => $event, source => 'same', source_span => {start => 0, end => 4}});
   my ($deps, $state) = setup($which, $role, 'string');
   $state->{event} = $event; $state->{publication} = $baseline->{value};
   my $outer = sub {return owner($deps, $state)};
   LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer, $deps->{$role}] : [$outer], sub {
    my $result = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
    is($result->{value}, $baseline->{value}, "$name/$role/$known ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event), "$name/$role/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [$known], "$name/$role/$known actual callback has its own identity boundary");
    is($state->{calls}, 1, "$name/$role/$known actual effect count survives");
    is(refaddr($deps->{$role}), refaddr($state->{original}{$role}), "$name/$role/$known public callback stays actual");
   });
  });
 }
}
for my $target (@targets) {
 my ($which, $role) = @$target;
 for my $bad (undef, 'not code') {
  my ($deps, $state) = setup($which, 'none', 'string', {args => ['Node', 'payload']});
  $deps->{$role} = $bad;
  my $error; eval {owner($deps, $state); 1} or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$role\E'/,
   "$owners{$which}/$role required diagnostic retains native selection");
 }
}
{
 my ($deps, $state) = setup('payload', 'none', 'string', {input => undef});
 $deps->{trim_action_ir_value} = undef;
 is(owner($deps, $state), undef, 'undefined payload bypasses required trim validation');
 is_deeply($state->{events}, [], 'undefined payload stops before all callbacks and helpers');
 for my $args ([], ['payload']) {
  ($deps, $state) = setup('statement', 'none', 'string', {args => $args});
  $deps->{trim_action_ir_value} = undef;
  my $error; eval {owner($deps, $state); 1} or $error = $@;
  is($error, undef, 'unreachable label trim is not required for zero or one argument');
 }
 ($deps, $state) = setup('statement', 'none', 'string', {ast_statement => 'FAST'});
 $deps->{parse_method_function_expr} = undef;
 my $error; eval {owner($deps, $state); 1} or $error = $@;
 like($error, qr/missing dependency callback 'parse_method_function_expr'/, 'statement eagerly validates parser before AST fast path');
 is_deeply($state->{events}, [], 'invalid eager parser stops before AST helper');
}
my $rows = observations();
my $cases = branch_cases();
for my $index (0..$#$cases) {
 my ($label, $which, $options, $value, $events) = @{$cases->[$index]};
 my $row = $rows->{branches}[$index];
 is_deeply($row->{value}, $value, "$label keeps bounded native branch value");
 is_deeply($row->{events}, $events, "$label keeps exact guard and fallback order");
 ok($row->{map_identity}, "$label preserves actual public callbacks");
 is($row->{error}, undef, "$label bounded branch completes");
 is($row->{reference_identity}, $label =~ /reference$/ ? 1 : 0, "$label direct reference identity stays native");
 for my $helper (@{$row->{helpers}}) {is($helper->{actual_map}, 1, "$label secondary helper retains actual dependency map")}
 if ($label eq 'statement-multiple') {
  is_deeply([map {$_->{parser_slot}} grep {$_->{name} eq 'payload'} @{$row->{helpers}}], [1, 2], 'multiple payload iteration keeps actual parser array slots');
 }
 if ($label eq 'statement-fallback-slot-mutation') {
  is_deeply([map {$_->{parser_slot}} grep {$_->{role} eq 'trim_action_ir_value'} @{$row->{trace}}], [0, 1],
   'label and fallback trim retain actual parser array scalar slots');
  is_deeply($row->{args_after}, ['Node!', 'payload!'], 'actual trim mutations survive in both parser array slots');
 }
}
sub public_return_observation {
 my ($source) = @_;
 my @Top = (1, 'two');
 my $execute = eval 'sub { ' . $source . ' }';
 return {error => "compile: $@"} unless ref($execute) eq 'CODE';
 my $value;
 my $ok = eval { $value = $execute->(); 1 };
 return $ok ? {value => $value} : {error => "execute: $@"};
}
my @public = public_cases();
for my $i (0..$#public) {
 my ($name, $source, $expected) = @{$public[$i]};
 my $row = $rows->{public}[$i];
 if ($name eq 'current-copy') {
  is_deeply(public_return_observation($row->{value}), {value => [[1, 'two']]},
   'current-copy public Toolbox preserves the evaluated nested return value');
 } else { is($row->{value}, $expected, "$name public Toolbox keeps actual return surface") }
 if ($name eq 'old-migration') {
  is($row->{error}, "aggregate_selector_removed surface=array identifier=Top replacement=Top\n", 'obsolete migration recipe has the exact current public selector diagnostic');
 } else {is($row->{error}, undef, "$name public Toolbox lowering completes")}
}
done_testing;

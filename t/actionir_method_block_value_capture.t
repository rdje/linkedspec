use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @keys = qw(trim_action_ir_value split_action_ir_statements parse_method_function_expr normalize_method_args_with_optional_scope);
my @invoked = @keys[0..2];
my $name = '_lower_block_value_expr';
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', $_[0]) }
sub event {
 my $event = {raw => 'same'};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => 'same', source_span => {start => 0, end => 4}});
 return $event
}
sub emit {
 my ($event) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'do { VALUE }');
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub setup {
 my ($target, $outcome, $event) = @_;
 my $state = {trace => [], eligible => [], calls => {}, statements => ['source'], helpers => []};
 my $fatal = bless {}, 'MethodBlockValueFatal';
 my (%deps, %actual);
 for my $key (@keys) {
  my $callback = sub {
   ++$state->{calls}{$key};
   die 'validation-only normalizer invoked' if $key eq $keys[3];
   my $first = $_[0];
   push @{$state->{trace}}, {key => $key,
    context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', error => $@,
    args => [@_], split_slot => @{$state->{statements}} && refaddr(\$_[0]) == refaddr(\$state->{statements}[0]) ? 1 : 0};
   $_[0] .= '!' if defined $_[0];
   $@ = 'successful '.$key;
   if ($key eq $target) {
    push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    die $fatal if $outcome eq 'fatal';
    return undef if $outcome eq 'undefined';
    # Exactly one publication distinguishes dependency isolation from the
    # existing rejection of ambiguous multiple publications on the trim path.
    emit($event) if $event && $state->{calls}{$key} == 1;
   }
   return $first if $key eq $keys[0];
   return $state->{statements} if $key eq $keys[1];
   return {method => $first =~ /^return/ ? 'return' : 'noop'} if $key eq $keys[2];
   die 'unknown fixture callback'
  };
  $deps{$key} = $actual{$key} = $callback;
 }
 return (\%deps, \%actual, $state, $fatal)
}
sub owner {
 my ($input, $deps, $state, $options) = @_;
 $options ||= {};
 no warnings 'redefine';
 # The actual outer-brace/fat-arrow helpers and required caller execute.
 # AST and secondary lowerers have explicit controlled results only.
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {
  push @{$state->{helpers}}, {name => 'ast', input => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return $options->{ast}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {
  push @{$state->{helpers}}, {name => 'bridge', input => $_[0], copied_map => refaddr($_[1]) != refaddr($deps) ? 1 : 0,
   guard => $_[1]{__actionir_ast_block_value_bridge},
   callbacks => [map {refaddr($_[1]{$_}) == refaddr($deps->{$_}) ? 1 : 0} @keys]};
  return $options->{bridge}
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_local_return_payload_expr = sub {
  push @{$state->{helpers}}, {name => 'return', input => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists $options->{return} ? $options->{return} : '"RETURN"'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_side_effect_statement = sub {
  push @{$state->{helpers}}, {name => 'side', input => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return 'push @guard_effects, "SIDE"'
 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr = sub {
  push @{$state->{helpers}}, {name => 'component', input => $_[0], deps_identity => refaddr($_[1]) == refaddr($deps) ? 1 : 0};
  return exists $options->{component} ? $options->{component} : 'VALUE'
 };
 return LinkedSpec::ActionIR::MethodLowering::_lower_block_value_expr($input, $deps)
}
sub callbacks {
 my @rows;
 for my $key (@invoked) {
  for my $outcome (qw(string undefined fatal)) {
   my ($deps, $actual, $state, $fatal) = setup($key, $outcome);
   my $input = '{source}';
   my ($value, $error, $success_error);
   eval { $@ = 'incoming block value error'; $value = owner($input, $deps, $state); $success_error = $@; 1 }
    or $error = $@;
   push @rows, {key => $key, outcome => $outcome, input => $input,
    trace => $state->{trace}, calls => $state->{calls}, statements => $state->{statements}, helpers => $state->{helpers},
    success_error => $success_error, value => $value,
    error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error,
    map_identity => [map {refaddr($deps->{$_}) == refaddr($actual->{$_}) ? 1 : 0} @keys]};
  }
 }
 return \@rows
}
sub branches {
 my @cases = (
  ['ast-string', {ast => {kind => 'block_value'}, bridge => 'AST'}],
  ['ast-zero', {ast => {kind => 'block_value'}, bridge => '0'}],
  ['ast-reference', {ast => {kind => 'block_value'}, bridge => {marker => 1}}],
  ['ast-undefined', {ast => {kind => 'block_value'}, bridge => undef}],
  ['ast-empty', {ast => {kind => 'block_value'}, bridge => ''}],
  ['ast-other', {ast => {kind => 'other'}, bridge => 'UNUSED'}],
  ['bridge-guard', {}, ['source'], 1],
  ['nonfinal-return', {component => '"LAST"'}, ['return(payload)', 'side()', 'last()']],
  ['final-return', {}, ['side()', 'return(payload)']],
  ['ordinary', {component => '"LAST"'}, ['side()', 'last()']],
  ['brace-component', {component => '{ marker => 1 }'}],
  ['invalid-return', {return => undef}, ['return(payload)']],
  ['empty-payload', {}, ['source'], 0, '{}'],
  ['fat-arrow', {}, ['source'], 0, '{a => b}'],
  ['malformed-brace', {}, ['source'], 0, '{source}tail'],
  ['empty-split', {}, []],
 );
 my @rows;
 for my $case (@cases) {
  my ($label, $options, $statements, $guard, $input) = @$case;
  $input = '{source}' unless defined $input;
  my ($deps, $actual, $state) = setup('', 'string');
  $state->{statements} = $statements if defined $statements;
  $deps->{__actionir_ast_block_value_bridge} = 1 if $guard;
  $@ = 'incoming branch error';
  my $value = owner($input, $deps, $state, $options);
  my ($evaluated, $eval_error, @guard_effects);
  if ($label =~ /^(?:nonfinal-return|final-return|ordinary)$/) {
   # Independent Perl execution observes the generated guard, not a second
   # string-building implementation of the block lowerer.
   $evaluated = eval $value;
   $eval_error = $@;
  }
  push @rows, {case => $label, value => ref($value) ? {type => ref($value), same_bridge => refaddr($value) == refaddr($options->{bridge}) ? 1 : 0} : $value,
   trace => $state->{trace}, helpers => $state->{helpers}, calls => $state->{calls}, statements => $state->{statements},
   guard => $deps->{__actionir_ast_block_value_bridge} // 0,
   map_identity => [map {refaddr($deps->{$_}) == refaddr($actual->{$_}) ? 1 : 0} @keys],
   evaluated => $evaluated, eval_error => $eval_error, effects => \@guard_effects};
 }
 return \@rows
}
sub observations { return {callbacks => callbacks(), branches => branches()} }
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n"; exit 0
}
for my $row (@{callbacks()}) {
 my $label = join '/', $name, @{$row}{qw(key outcome)};
 is_deeply($row->{map_identity}, [1, 1, 1, 1], "$label actual public callback references stay exact");
 is($row->{input}, '{source}', "$label top-level scalar input keeps existing copy behavior");
 ok(@{$row->{trace}} && !grep({$_->{context} ne 'scalar'} @{$row->{trace}}), "$label actual required calls retain scalar context");
 is($row->{trace}[0]{error}, 'incoming block value error', "$label native incoming error survives");
 is($row->{calls}{$row->{key}}, $row->{key} eq $keys[0] && $row->{outcome} eq 'string' ? 3 : 1,
  "$label target callback keeps native invocation count");
 is($row->{calls}{$keys[3]} // 0, 0, "$label validated normalizer has no local invocation");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'MethodBlockValueFatal', same_fatal => 1}, "$label fatal object retains actual identity");
 } else {
  like($row->{success_error}, qr/^successful /, "$label native successful error effect survives");
 }
 is($row->{value}, $row->{outcome} eq 'string' || ($row->{key} eq $keys[2] && $row->{outcome} eq 'undefined') ? 'do { VALUE }' : undef,
  "$label actual caller ordinary result stays native");
 my $reached_slot = $row->{key} eq $keys[2] || $row->{outcome} eq 'string';
 is_deeply($row->{statements}, [$reached_slot ? 'source!' : 'source'], "$label mutation reaches actual split-array slot only on native path");
 my @trim = grep {$_->{key} eq $keys[0]} @{$row->{trace}};
 is_deeply([map {$_->{split_slot}} @trim], $reached_slot ? [0, 0, 1] : $row->{key} eq $keys[0] ? [0] : [0, 0],
  "$label actual split-array alias keeps native identity");
}
for my $key (@invoked) {
 for my $known (0, 1) {
  scope(sub {
   my $event = event();
   my ($deps, $actual, $state) = setup($key, 'string', $event);
   my $outer = sub { return owner('{source}', $deps, $state) };
   producers($known ? [$outer, $actual->{$key}] : [$outer], sub {
    my $result = capture($outer);
    is($result->{value}, 'do { VALUE }', "$name/$key/$known actual ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$name/$key/$known required dependency cannot donate nested publication");
    is_deeply($state->{eligible}, [($known) x ($key eq $keys[0] ? 3 : 1)], "$name/$key/$known actual callback has its own identity boundary");
    is($state->{calls}{$key}, $key eq $keys[0] ? 3 : 1, "$name/$key/$known actual native effect count survives");
    is_deeply([map {refaddr($deps->{$_})} @keys], [map {refaddr($actual->{$_})} @keys],
     "$name/$key/$known original public map keeps all actual callbacks");
   });
  });
 }
}
for my $key (@keys) {
 for my $bad (undef, 'not code') {
  my ($deps, $actual, $state) = setup('', 'string'); $deps->{$key} = $bad;
  my $error; eval { owner('{source}', $deps, $state); 1 } or $error = $@;
  like($error, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback '\Q$key\E'/,
   "$name/$key required dependency diagnostic remains exact");
 }
}
for my $row (@{branches()}) {
 my $label = $row->{case};
 is_deeply($row->{map_identity}, [1, 1, 1, 1], "$label keeps actual public callbacks");
 is($row->{calls}{$keys[3]} // 0, 0, "$label validation-only normalizer remains uninvoked");
 is($row->{guard}, $label eq 'bridge-guard' ? 1 : 0, "$label original map retains its bridge guard");
 if ($label =~ /^ast-(?:string|zero|reference|undefined|empty)$/) {
  is_deeply($row->{helpers}[1], {name => 'bridge', input => '{source}', copied_map => 1, guard => 1, callbacks => [1, 1, 1, 1]},
   "$label AST path receives copied guard map and actual callbacks");
 }
 if ($label =~ /^ast-(?:string|zero|reference)$/) {
  is_deeply($row->{value}, $label eq 'ast-string' ? 'AST' : $label eq 'ast-zero' ? '0' : {type => 'HASH', same_bridge => 1},
   "$label preserves actual early result including zero and reference identity");
  is_deeply($row->{trace}, [], "$label returns before any local dependency invocation");
 } elsif ($label =~ /^(?:nonfinal-return|final-return|ordinary)$/) {
  is($row->{eval_error}, '', "$label generated controlled Perl executes successfully");
  is($row->{evaluated}, $label eq 'ordinary' ? 'LAST' : 'RETURN', "$label independent execution preserves return value");
  is_deeply($row->{effects}, $label eq 'nonfinal-return' ? [] : ['SIDE'], "$label independent execution preserves guarded side effects");
 } else {
  is($row->{value}, $label =~ /^(?:invalid-return|empty-payload|fat-arrow|malformed-brace|empty-split)$/ ? undef
    : $label eq 'brace-component' ? 'do { +{ marker => 1 } }' : 'do { VALUE }', "$label keeps bounded native fallback result");
 }
 if ($label eq 'bridge-guard') {
  ok(!grep({$_->{name} eq 'ast' || $_->{name} eq 'bridge'} @{$row->{helpers}}), 'existing bridge guard skips AST parse and bridge');
 } else {
  is_deeply($row->{helpers}[0], {name => 'ast', input => $label eq 'empty-payload' ? '{}' : $label eq 'fat-arrow' ? '{a => b}' : $label eq 'malformed-brace' ? '{source}tail' : '{source}', deps_identity => 1},
   "$label AST-first parse receives the original map");
 }
}
done_testing;

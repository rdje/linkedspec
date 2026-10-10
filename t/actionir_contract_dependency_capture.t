use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr weaken);
use JSON::PP ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my @required = qw(
 lower_return_general_statement lower_assign_method_statement
 lower_scalar_assignment_operator_statement lower_array_append_operator_statement
 lower_array_end_mutation_method_statement lower_hash_index_assignment_operator_statement
 lower_set_key_statement lower_push_statement lower_regex_subst_statement
 lower_array_pipeline_expr lower_if_flow_statement lower_elseif_flow_statement
 lower_else_flow_statement lower_endif_flow_statement lower_while_flow_statement
 lower_switch_flow_statement lower_case_flow_statement lower_default_flow_statement
 lower_endcase_flow_statement lower_endswitch_flow_statement lower_say_statement
 lower_print_statement lower_print_each_statement lower_exit_now_statement
 lower_return_undef_statement lower_method_value_expr
);
my @keys = (@required, 'lower_dropped_value_statement');
sub dependencies { my ($callback) = @_; return {map { $_ => $callback } @keys} }
sub bindings { LinkedSpec::ActionIR::Contracts::_require_lowering_deps(@_) }
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub source_scope { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins(@_) }
sub emit {
 my ($event, $text) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, $text);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}
sub event {
 my ($source) = @_;
 my $event = {raw => $source};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
  {event => $event, source => $source, source_span => {start => 0, end => length($source)}});
 return $event
}

sub observations {
 my @rows;
 for my $context (qw(scalar list void)) {
  for my $outcome (qw(string reference undefined values fatal)) {
   my ($first, $last) = ('first', 'last');
   my $shared = {calls => 0};
   my $fatal = bless {}, 'ContractDependencyFatal';
   my (@trace, @values, $value, $error, $success_error);
   my $actual = sub {
    push @trace, {context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
     error => $@, shared_identity => refaddr($_[1]) == refaddr($shared) ? 1 : 0};
    $_[0] .= '!'; $_[2] .= '?'; ++$_[1]{calls};
    $@ = 'successful dependency error';
    die $fatal if $outcome eq 'fatal';
    return $shared if $outcome eq 'reference';
    return undef if $outcome eq 'undefined';
    return ('left', $shared, 'right') if $outcome eq 'values';
    return 'same'
   };
   my $deps = dependencies($actual);
   my $bound = bindings($deps)->{lower_method_value_expr};
   eval {
    $@ = 'incoming dependency error';
    if ($context eq 'void') { $bound->($first, $shared, $last) }
    elsif ($context eq 'list') { @values = $bound->($first, $shared, $last) }
    else { $value = $bound->($first, $shared, $last) }
    $success_error = $@;
    1
   } or $error = $@;
   my $normalize = sub {
    my ($item) = @_;
    return {reference => ref($item), same_shared => refaddr($item) == refaddr($shared) ? 1 : 0}
     if ref($item);
    return $item
   };
   push @rows, {context => $context, outcome => $outcome, first => $first, last => $last,
    shared => $shared, trace => \@trace, value => $normalize->($value),
    values => [map { $normalize->($_) } @values], success_error => $success_error,
    map_identity => refaddr($deps->{lower_method_value_expr}) == refaddr($actual) ? 1 : 0,
    error => ref($error) ? {reference => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
  }
 }
 return \@rows
}

# This branch uses the existing private binding API on the unchanged activation
# revision too. Compare complete normalized observations across actual processes.
if (@ARGV && $ARGV[0] eq 'observe') {
 print JSON::PP->new->canonical->encode(observations()), "\n";
 exit 0
}

for my $row (@{observations()}) {
 my $label = join '/', @{$row}{qw(context outcome)};
 is(scalar @{$row->{trace}}, 1, "$label actual injected callback executes once");
 is($row->{trace}[0]{context}, $row->{context}, "$label native dependency context survives");
 is_deeply([$row->{first}, $row->{last}], ['first!', 'last?'], "$label first and extra caller aliases survive");
 is($row->{trace}[0]{shared_identity}, 1, "$label actual shared reference survives");
 is($row->{shared}{calls}, 1, "$label shared effect occurs once");
 is($row->{trace}[0]{error}, 'incoming dependency error', "$label native incoming error survives");
 is($row->{map_identity}, 1, "$label public map retains its actual callback");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {reference => 'ContractDependencyFatal', same_fatal => 1}, "$label fatal object identity survives");
 } else {
  is($row->{success_error}, 'successful dependency error', "$label native successful error effect survives");
 }
 my $ordinary = $row->{outcome} eq 'reference' ? {reference => 'HASH', same_shared => 1}
  : $row->{outcome} eq 'undefined' ? undef : $row->{outcome} eq 'values' ? 'right' : 'same';
 my $expected_value = $row->{context} eq 'scalar' && $row->{outcome} ne 'fatal' ? $ordinary : undef;
 my $expected_values = $row->{context} ne 'list' || $row->{outcome} eq 'fatal' ? []
  : $row->{outcome} eq 'values' ? ['left', {reference => 'HASH', same_shared => 1}, 'right'] : [$ordinary];
 is_deeply($row->{value}, $expected_value, "$label scalar return remains native");
 is_deeply($row->{values}, $expected_values, "$label list return remains native");
}

for my $key (@keys) {
 source_scope('same', sub {
  my $event = event('same');
  my ($calls, $eligible) = (0, undef);
  my $actual = sub {
   ++$calls; $eligible = LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
   emit($event, 'same'); return 'same'
  };
  my $deps = dependencies($actual);
  my $d = bindings($deps);
  my $outer = sub { return $d->{$key}->('same') };
  producers([$outer], sub {
   my $result = capture($outer);
   is($result->{value}, 'same', "$key ordinary value survives");
   ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
    "$key opaque dependency cannot donate nested publication");
   is($eligible, 0, "$key actual callback has its own opaque boundary");
   is($calls, 1, "$key actual callback executes once");
   is_deeply([map { refaddr($deps->{$_}) } @keys], [(refaddr($actual)) x scalar(@keys)],
    "$key caller map and actual callback fields stay unchanged");
  });
 });
}

source_scope('same', sub {
 my $event = event('same');
 my $actual = sub { emit($event, 'do { same; undef }'); return 'same' };
 my $deps = dependencies($actual); delete $deps->{lower_dropped_value_statement};
 my $outer = bindings($deps)->{lower_dropped_value_statement};
 producers([$outer], sub {
  my $result = capture($outer, 'original');
  is($result->{value}, 'do { same; undef }', 'fallback dropped ordinary value remains native');
  ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
   'fallback dropped required dependency cannot donate nested publication');
 });
});

source_scope('input_slice(0, 1)', sub {
 my $event = event('input_slice(0, 1)');
 my (@effects, $context);
 my $actual = sub {
  push @effects, 'opaque'; $context = defined(wantarray) && !wantarray ? 'scalar' : 'changed';
  emit($event, 'same'); push @effects, 'builder'; return 'same'
 };
 my $deps = dependencies($actual);
 my $contracts = LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts('Top', $deps);
 my ($contract) = grep { $_->{id} eq 'input_slice' } @$contracts;
 my $outer = $contract->{lower};
 producers([$outer], sub {
  my $result = capture($outer, 'input_slice(0, 1)');
  is($result->{value}, 'same', 'actual input_slice factory preserves ordinary equal value');
  ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
   'actual input_slice opaque dependency cannot donate nested publication');
  is_deeply(\@effects, ['opaque', 'builder'], 'actual input_slice effects keep native order and count');
  is($context, 'scalar', 'actual input_slice dependency retains scalar context');
  is(refaddr($deps->{lower_method_value_expr}), refaddr($actual), 'actual input_slice public dependency reference stays exact');
 });
});

for my $indexed (0, 1) {
 my $source = 'push @out, call(child)'.($indexed ? '->[2]' : '');
 my $expected = 'push @out, &{$$descr{spec}{child}{handler}}($descr, $STRING, $minfo)'.($indexed ? '->[2]' : '');
 source_scope($source, sub {
  my $event = event($source);
  my (@seen, $eligible);
  my $actual = sub {
   push @seen, [$_[0], !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'];
   $eligible = LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
   emit($event, $expected); return 'array'
  };
  my $deps = dependencies(sub { return undef }); $deps->{bare_symbol_kind} = $actual;
  my $contracts = LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts('Top', $deps);
  my $id = $indexed ? 'push_child_call_indexed_builtin' : 'push_child_call_builtin';
  my ($contract) = grep { $_->{id} eq $id } @$contracts;
  my $outer = $contract->{lower};
  producers([$outer], sub {
   my $result = capture($outer, $source);
   is($result->{value}, $expected, "$id ordinary generated text remains native");
   ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
    "$id bare dependency cannot donate nested publication");
   is_deeply(\@seen, [['out', 'scalar']], "$id actual bare callback keeps argument context and count");
   is($eligible, 0, "$id actual bare callback is independently opaque");
   is(refaddr($deps->{bare_symbol_kind}), refaddr($actual), "$id public bare reference remains exact");
  });
 });
}

source_scope('same', sub {
 producers([], sub {
  my @registered;
  my $register = \&LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer;
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer = sub {
   push @registered, $_[0]; return $register->(@_)
  };
  my $deps = LinkedSpec::ActionIR::Contracts::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
  is_deeply([sort keys %$deps], [sort @keys], 'native default public map has exactly the original keys');
  is_deeply([sort { $a <=> $b } map { refaddr($_) } @registered],
   [sort { $a <=> $b } map { refaddr($deps->{$_}) } @keys], 'native default selects each actual definition-owned reference once');
  is_deeply([map { refaddr($deps->{$_}) } @keys],
   [map { refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$_)) } @keys], 'native default public callbacks remain exact native references');
  {
   my $opaque = sub { return 'same' };
   local *LinkedSpec::RuleIR::EmitContext::_lower_method_value_expr = $opaque;
   @registered = ();
   my $changed = LinkedSpec::ActionIR::Contracts::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
   is(refaddr($changed->{lower_method_value_expr}), refaddr($opaque), 'same-name default replacement preserves its actual public reference');
   ok(!grep({ refaddr($_) == refaddr($opaque) } @registered), 'same-name default replacement remains opaque');
   is(scalar @registered, 26, 'unchanged native defaults remain selectable around a replacement');
  }
  {
   no strict 'refs';
   local @ContractDependencyCustomTarget::ISA;
   for my $key (@keys) { *{'ContractDependencyCustomTarget::_'.$key} = $deps->{$key} }
   @registered = ();
   my $custom = LinkedSpec::ActionIR::Contracts::default_deps_for_package('ContractDependencyCustomTarget');
   is_deeply(\@registered, [], 'custom default target cannot register even aliased native callbacks');
   is_deeply([map { refaddr($custom->{$_}) } @keys], [map { refaddr($deps->{$_}) } @keys],
    'custom default target preserves its actual aliased public references');
  }
 });
});

{
 my $identity = {};
 my $actual = sub { return $identity ? 'same' : undef };
 my $weak = $actual; weaken($weak);
 my $deps = dependencies($actual);
 my $d = bindings($deps);
 undef $deps; undef $actual;
 ok(defined($weak), 'private bindings retain the actual dependency while in use');
 undef $d;
 ok(!defined($weak), 'private binding release leaves no global callback cache');
}

done_testing;

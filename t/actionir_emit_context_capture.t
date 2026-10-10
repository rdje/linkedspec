use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use JSON::PP ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

sub producers { LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers(@_) }
sub capture { LinkedSpec::ActionIR::SourceEmissions::_capture_emission(@_) }
sub select_builtin { LinkedSpec::RuleIR::EmitContext::_register_builtin_contract_emission_callback(@_) }
my $json = JSON::PP->new->canonical;

sub observations {
 my @rows;
 for my $with_deps (0, 1) {
  for my $context (qw(scalar list void)) {
   for my $outcome (qw(string reference undefined values fatal)) {
    my ($first, $last) = ('first', 'last');
    my $shared = {calls => 0};
    my $deps = {};
    my $fatal = bless {}, 'EmitContextCaptureFatal';
    my (@trace, @factory, @values, $value, $error, $success, $success_error);
    my $callback = sub {
     my $native_context = !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
     push @trace, {context => $native_context, error => $@,
      shared_identity => refaddr($_[1]) == refaddr($shared) ? 1 : 0,
      deps_identity => $with_deps ? (refaddr($_[3]) == refaddr($deps) ? 1 : 0) : undef};
     $_[0] .= '!'; $_[2] .= '?';
     ++$_[1]{calls};
     $_[3]{seen} = 1 if $with_deps;
     $@ = 'successful owner error';
     die $fatal if $outcome eq 'fatal';
     return $shared if $outcome eq 'reference';
     return undef if $outcome eq 'undefined';
     return ('left', $shared, 'right') if $outcome eq 'values';
     return 'same'
    };
    my $factory = sub {
     push @factory, [!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $_[0], $@];
     $@ = 'successful factory error';
     return $deps
    };
    no warnings 'redefine';
    local *LinkedSpec::RuleIR::EmitContext::_actionir_owner_callback = sub {
     return $_[1] eq 'default_deps_for_package' ? $factory : $callback
    };
    my $bridge = $with_deps ? \&LinkedSpec::RuleIR::EmitContext::_call_actionir_owner_with_deps
     : \&LinkedSpec::RuleIR::EmitContext::_call_actionir_owner;
    eval {
     $@ = 'incoming owner error';
     if ($context eq 'void') { $bridge->('method_lowering', 'controlled', $first, $shared, $last) }
     elsif ($context eq 'list') { @values = $bridge->('method_lowering', 'controlled', $first, $shared, $last) }
     else { $value = $bridge->('method_lowering', 'controlled', $first, $shared, $last) }
     $success_error = $@; $success = 1;
     1
    } or $error = $@;
    my $normalize = sub {
     my ($value) = @_;
     return {reference => ref($value), same_shared => refaddr($value) == refaddr($shared) ? 1 : 0}
      if ref($value);
     return $value
    };
    push @rows, {with_deps => $with_deps, context => $context, outcome => $outcome,
     first => $first, last => $last, shared => $shared, deps => $deps,
     trace => \@trace, factory => \@factory,
     value => $normalize->($value), values => [map { $normalize->($_) } @values],
     success => $success ? 1 : 0, success_error => $success_error,
     error => ref($error) ? {reference => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
   }
  }
 }
 return \@rows
}

# The same instrument can observe the unchanged activation revision without
# invoking the newly added selector. Its JSON ledgers compare across processes.
if (@ARGV && $ARGV[0] eq 'observe') {
 print $json->encode(observations()), "\n";
 exit 0
}

for my $row (@{observations()}) {
 my $label = join '/', @{$row}{qw(with_deps context outcome)};
 is(scalar @{$row->{trace}}, 1, "$label actual owner executes once");
 is($row->{trace}[0]{context}, $row->{context}, "$label owner retains native context");
 is_deeply([$row->{first}, $row->{last}], ['first', 'last'], "$label bridge retains its existing caller argument copies");
 is($row->{trace}[0]{shared_identity}, 1, "$label owner receives the actual shared reference");
 is($row->{shared}{calls}, 1, "$label actual shared effects occur once");
 is($row->{trace}[0]{error}, 'incoming owner error', "$label owner observes native incoming error");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {reference => 'EmitContextCaptureFatal', same_fatal => 1}, "$label fatal object identity survives");
 } else {
  is($row->{success_error}, 'incoming owner error', "$label existing bridge restores caller error");
 }
 if ($row->{with_deps}) {
  is_deeply($row->{factory}, [['scalar', 'LinkedSpec::RuleIR::EmitContext', 'incoming owner error']], "$label actual factory retains scalar context and once-only native call");
  is($row->{trace}[0]{deps_identity}, 1, "$label owner receives the exact factory map");
  is_deeply($row->{deps}, {seen => 1}, "$label actual factory map effects are preserved");
 }
}

my @names = qw(
 _lower_return_general_statement _lower_assign_method_statement
 _lower_scalar_assignment_operator_statement _lower_array_append_operator_statement
 _lower_array_end_mutation_method_statement _lower_hash_index_assignment_operator_statement
 _lower_set_key_statement _lower_push_statement _lower_regex_subst_statement
 _lower_array_pipeline_expr _lower_if_flow_statement _lower_elseif_flow_statement
 _lower_else_flow_statement _lower_endif_flow_statement _lower_while_flow_statement
 _lower_switch_flow_statement _lower_case_flow_statement _lower_default_flow_statement
 _lower_endcase_flow_statement _lower_endswitch_flow_statement _lower_say_statement
 _lower_print_statement _lower_print_each_statement _lower_exit_now_statement
 _lower_return_undef_statement _lower_method_value_expr _lower_dropped_value_statement
 _bare_symbol_kind
);
my %native = map { $_ => LinkedSpec::RuleIR::EmitContext->can($_) } @names;
my $source = 'same';
sub source_scope (&) { LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, $_[0]) }
sub event {
 my $event = {raw => $source};
 LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event, {
  event => $event, source => $source, source_span => {start => 0, end => 4}});
 return $event
}
sub emit {
 my ($event) = @_;
 my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
 LinkedSpec::ActionIR::SourceEmissions::_append_source($builder, 'same', 0, 4);
 return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
}

source_scope {
 producers([], sub {
  my @registered;
  my $actual_register = \&LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer;
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer = sub {
   push @registered, $_[0];
   return $actual_register->(@_)
  };
  for my $name (@names) {
   @registered = ();
   my $callback = $native{$name};
   is(refaddr(select_builtin($callback)), refaddr($callback), "$name selection returns the actual callback");
   is_deeply([map { refaddr($_) } @registered], [refaddr($callback)], "$name actual definition-owned reference reaches registration once");
  }
  my $opaque = sub { return 'same' };
  local *LinkedSpec::RuleIR::EmitContext::_lower_method_value_expr = $opaque;
  @registered = ();
  is(refaddr(select_builtin(LinkedSpec::RuleIR::EmitContext->can('_lower_method_value_expr'))), refaddr($opaque),
   'same public name replacement preserves its actual callback value');
  is_deeply(\@registered, [], 'same public name replacement cannot enter the definition-owned selection');
  my $copy = {id => '_lower_method_value_expr', lower => $opaque};
  select_builtin($copy->{lower});
  is_deeply(\@registered, [], 'copied metadata cannot register an opaque callback');
  my $retained = {lower => $native{_lower_method_value_expr}};
  select_builtin($retained->{lower});
  is_deeply([map { refaddr($_) } @registered], [refaddr($native{_lower_method_value_expr})],
   'retaining the same actual native reference remains selectable after symbol replacement');
 });
};

# Actual facade execution resolves controlled dependencies. Observe eligibility
# before invocation, then require every opaque invocation to have its own slot.
for my $mode (qw(owner factory)) {
 for my $context (qw(scalar list void)) {
  source_scope {
   my $event = event();
   my (@before_call, @dependency_call, $returned_map);
   my $owner = sub {
    push @dependency_call, ['owner', LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0];
    emit($event) if $mode eq 'owner';
    return 'same'
   };
   my $factory = sub {
    push @dependency_call, ['factory', LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0];
    emit($event) if $mode eq 'factory';
    $returned_map = {};
    return $returned_map
   };
   no warnings 'redefine';
   local *LinkedSpec::RuleIR::EmitContext::_actionir_owner_callback = sub {
    push @before_call, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
    return $_[1] eq 'default_deps_for_package' ? $factory : $owner
   };
   producers([], sub {
    my $facade = $native{_lower_method_value_expr};
    select_builtin($facade);
    # The canonical capture is scalar; the native facade also supports callers
    # in list/void contexts through an explicitly registered enclosing producer.
    my $outer = $context eq 'scalar' ? $facade : sub {
     if ($context eq 'list') { my @values = $facade->('same'); return $values[0] }
     $facade->('same'); return 'same'
    };
    LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($outer) unless $context eq 'scalar';
    my $result = capture($outer, 'same');
    is($result->{value}, 'same', "$mode/$context actual facade ordinary value survives");
    ok(!LinkedSpec::ActionIR::SourceEmissions::_emission_for($result, $outer, $event),
     "$mode/$context opaque resolved call cannot donate nested publication");
    is_deeply(\@before_call, [1, 1], "$mode/$context selected actual facade executes in the eligible outer scope");
    is_deeply(\@dependency_call, [['factory', 0], ['owner', 0]], "$mode/$context each actual resolved call is independently opaque");
    is_deeply($returned_map, {}, "$mode/$context public factory map stays unchanged");
   });
  };
 }
}

done_testing;

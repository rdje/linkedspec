package LinkedSpec::PipelineCaptureProbe;
use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(refaddr weaken);
use LinkedSpec::ActionIR::RewritePipeline ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();
use LinkedSpec::ActionIR::MethodExpr ();

sub same {
 return ref($_[0]) && ref($_[1]) && refaddr($_[0]) == refaddr($_[1]) ? 1 : 0
}
sub context { return !defined($_[0]) ? 'void' : $_[0] ? 'list' : 'scalar' }

# The ordinary ledger observes native calls only. Private collectors have their
# own ledger; their intentional new availability must not mask public changes.
sub exercise {
 my ($context, $supplied, $outcome, $fail_at, $mutate) = @_;
 my (@trace, @private, @captures, @values, $value, $success_error, $caught);
 my ($event, $rules, $lower, $contracts, $deps);
 my $source = 'cat("λ😀", ,"λ😀")';
 my $fatal = bless {}, 'LinkedSpec::PipelineCaptureProbe::Fatal';
 my %callbacks;
 my (@weak_scopes, @weak_callbacks);
 my $record = sub {
  my ($role, $context, @args) = @_;
  push @trace, [$role, $context, $@, @args];
  my $token = LinkedSpec::ActionIR::SourceOrigins::_invocation_token();
  my $producers = $LinkedSpec::ActionIR::SourceEmissions::_producers;
  my $inputs = $LinkedSpec::ActionIR::SourceEmissions::_inputs;
  my $call = $LinkedSpec::ActionIR::SourceEmissions::_call;
  push @private, {
   role => $role,
   source_active => ref($token) eq 'HASH' ? 1 : 0,
   producers_match => ref($producers) eq 'HASH' && same($producers->{source_token}, $token) ? 1 : 0,
   inputs_match => ref($inputs) eq 'HASH' && same($inputs->{source_token}, $token) ? 1 : 0,
   actual_callback => ref($call) eq 'HASH' && same($call->{callback}, $callbacks{$role}) ? 1 : 0,
  };
  for my $scope ($token, $producers, $inputs) {
   next unless ref($scope);
   push @weak_scopes, $scope;
   weaken($weak_scopes[-1]);
  }
  if ($fail_at eq $role) {
   die $fatal if $outcome eq 'fatal';
   die "intentional $role failure\n";
  }
 };
 $lower = sub {
  $record->('apply', context(wantarray), $_[0],
   same($_[1]{event}, $event), same($_[1]{rewrite_rules}, $rules),
   [sort keys %{$_[1]}]);
  $_[0] .= ':apply' if $mutate;
  $@ = 'apply successful error';
  return undef if $outcome eq 'undefined';
  return '' if $outcome eq 'empty';
  return $_[0] if $outcome eq 'same';
  return '0' if $outcome eq 'zero';
  return [] if $outcome eq 'reference';
  my $grant = LinkedSpec::ActionIR::SourceEmissions::_event_input_for($event);
  my $parser = \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr;
  my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_method_input($grant, $parser, $_[0]);
  my @arguments;
  if (ref($capture->{value}) eq 'HASH') {
   my $args = $capture->{value}{args};
   for my $index (0 .. $#$args) {
    my $child = LinkedSpec::ActionIR::SourceEmissions::_argument_input_for(
     $capture, $parser, $event, $args, $index);
    push @arguments, LinkedSpec::ActionIR::SourceEmissions::_input_description($child);
   }
  }
  push @private, {role => 'arguments', descriptions => \@arguments};
  my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
  LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'LOWERED');
  return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
 };
 $callbacks{apply} = $lower;
 my $make_contracts = sub {
  return [{id => 'probe', ir_node => 'PROBE', diag_name => 'probe', lower => $lower,
   compatibility_surface => 0, exclusive_statement => 0, unresolved_pattern => undef}]
 };
 $callbacks{factory} = sub {
  $record->('factory', context(wantarray), $_[0]);
  $_[0] .= ':factory' if $mutate;
  LinkedSpec::ActionIR::SourceEmissions::_register_emission_producer($lower);
  $contracts = $make_contracts->();
  $@ = 'factory successful error';
  return $contracts
 };
 $callbacks{collect} = sub {
  $rules = $_[1];
  $record->('collect', context(wantarray), $_[0], same($rules->[0]{apply}, $lower),
   [sort keys %{$rules->[0]}]);
  $_[0] .= ':collect' if $mutate;
  $@ = 'collect successful error';
  return {helper_action_ir_count => 1, helper_action_ir_hits => {probe => 1},
   helper_action_ir_nodes => [], helper_action_ir_events => []}
 };
 $callbacks{canonical} = sub {
  $record->('canonical', context(wantarray), $_[0], $_[1]);
  $_[0] .= ':canonical' if $mutate;
  $event = {raw => $_[1], kind => 'PROBE', contract_id => 'probe'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event => $event, source => $source, source_span => {start => 0, end => length($source)}});
  $@ = 'canonical successful error';
  return {canonical_action_ir_events => [$event], canonical_action_ir_count => 1,
   canonical_action_ir_hits => {probe => 1}, canonical_action_ir_fallback_count => 0}
 };
 $callbacks{find} = sub {
  $record->('find', context(wantarray), $_[0], same($_[1], $rules));
  $_[0] .= ':find' if $mutate;
  $@ = 'find successful error';
  return {unresolved_helper_count => 0, unresolved_helpers => []}
 };
 $deps = {build_action_lowering_contracts => $callbacks{factory},
  collect_action_helper_ir_nodes => $callbacks{collect},
  build_canonical_action_ir_events => $callbacks{canonical},
  find_unresolved_action_helpers => $callbacks{find}};
 my $provided = $supplied ? [{id => 'probe', ir_node => 'PROBE', diag_name => 'probe',
  apply => $lower, compatibility_surface => 0, exclusive_statement => 0,
  unresolved_pattern => undef}] : undef;
 my $capture_native = \&LinkedSpec::ActionIR::SourceEmissions::_capture_emission;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::SourceEmissions::_capture_emission = sub {
  my $callback = $_[0];
  my $capture = $capture_native->(@_);
  my $error = $@;
  my ($role) = grep { same($callback, $callbacks{$_}) } sort keys %callbacks;
  if (defined $role) {
   my $packet = $role eq 'apply'
    ? LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $callback, $event) : undef;
   push @captures, {role => $role, packet => $packet};
  }
  $@ = $error;
  return $capture
 };
 my $ok = eval {
  $@ = 'incoming error';
  if ($context eq 'list') {
   @values = LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
    'ProbeLabel', $source, $provided, $deps);
  } elsif ($context eq 'scalar') {
   $value = LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
    'ProbeLabel', $source, $provided, $deps);
  } else {
   LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
    'ProbeLabel', $source, $provided, $deps);
  }
  $success_error = $@;
  1
 };
 $caught = $@ unless $ok;
 my $ordinary = {
  context => $context, supplied => $supplied, outcome => $outcome, fail_at => $fail_at,
  mutate => $mutate, trace => \@trace, values => \@values, value => $value,
  success => $ok ? 1 : 0, success_error => $success_error,
  error => ref($caught) ? {class => ref($caught), actual_fatal => same($caught, $fatal)} : $caught,
  dependency_identity => same($deps->{build_action_lowering_contracts}, $callbacks{factory})
   && same($deps->{collect_action_helper_ir_nodes}, $callbacks{collect})
   && same($deps->{build_canonical_action_ir_events}, $callbacks{canonical})
   && same($deps->{find_unresolved_action_helpers}, $callbacks{find}) ? 1 : 0,
  dependency_keys => [sort keys %$deps],
 };
 # Reference returns stringify with an address in native replacement. Retain
 # identity separately and normalize only that documented address spelling.
 for my $row (@trace) {
  for my $cell (@$row) { $cell =~ s/ARRAY\(0x[0-9a-f]+\)/ARRAY(<actual>)/g if defined($cell) && !ref($cell) }
 }
 for my $text (@values, $value) {
  $text =~ s/ARRAY\(0x[0-9a-f]+\)/ARRAY(<actual>)/g if defined($text) && !ref($text);
 }
 return {ordinary => $ordinary, private => \@private, captures => \@captures,
  scopes_released => (grep { defined $_ } @weak_scopes) ? 0 : 1}
}

sub observations {
 my @rows;
 for my $context (qw(list scalar void)) {
  for my $supplied (0, 1) {
   for my $outcome (qw(normal undefined empty same zero reference)) {
    push @rows, exercise($context, $supplied, $outcome, '', 0);
   }
   push @rows, exercise($context, $supplied, 'normal', '', 1);
   for my $role (qw(factory collect canonical apply find)) {
    next if $supplied && $role eq 'factory';
    push @rows, exercise($context, $supplied, 'string', $role, 0);
    push @rows, exercise($context, $supplied, 'fatal', $role, 0);
   }
  }
 }
 return \@rows
}

unless (caller) {
 binmode STDOUT, ':encoding(UTF-8)';
 print JSON::PP->new->canonical->encode(observations()), "\n";
}
1;

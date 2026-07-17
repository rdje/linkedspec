#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;

use Encode qw(decode);
use File::Basename qw(dirname);
use File::Spec;
use IPC::Open3 qw(open3);
use JSON::PP ();
use Scalar::Util qw(refaddr);
use Symbol qw(gensym);

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 unshift @INC, File::Spec->catdir($repo_root, 'perl');
}

use LinkedSpec;
use LinkedSpec::RuntimeDiagnosticOutput ();

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $contract_path = File::Spec->catfile(
 $repo_root,
 qw(capability_conformance diagnostic_output_contract.json),
);

open my $contract_fh, '<:encoding(UTF-8)', $contract_path
 or die "cannot read $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

is($contract->{format}, 1, 'diagnostic-output contract format is pinned');
is($contract->{contract_id}, 'linkedspec-diagnostic-output-v1', 'diagnostic-output contract id is pinned');
is($LinkedSpec::RuntimeDiagnosticOutput::CONTRACT_ID, $contract->{contract_id}, 'Perl seam names the neutral contract');

my %program = map { $_->{id} => $_ } @{$contract->{programs}};
my %scenario = map { $_->{id} => $_ } @{$contract->{scenarios}};
my $generated_package_counter = 0;

sub perl_reference_spec {
 my ($source) = @_;
 $source =~ s/\n E \{/\n -> Done {/ or die "neutral program has no E block";
 return $source."\nDone::\n /x/\n"
}

sub compile_program {
 my ($id) = @_;
 my $source = perl_reference_spec($program{$id}{spec_source});
 my $generated_source = '';
 my $runtime_ctx = {};
 my $parser = LinkedSpec::Get(
  \$source,
  runtime_ctx_ref => $runtime_ctx,
  dump_parser_source => 1,
  parser_source_ref => \$generated_source,
  generated_source_identity => "diagnostic-output/$id.spec",
 );
 ok(ref($parser) eq 'CODE', "$id compiles through the Perl reference path")
  or diag(JSON::PP->new->canonical(1)->encode($runtime_ctx->{last_error} // {}));
 return {
  parser => $parser,
  source => $source,
  generated_source => $generated_source,
  runtime_ctx => $runtime_ctx,
 }
}

sub input_for_program {
 my ($id) = @_;
 return $program{$id}{input}.'x'
}

sub event_rows {
 my ($events) = @_;
 return [map { +{%$_} } @$events]
}

sub capture_host_output {
 my ($callback) = @_;
 my ($stdout, $stderr) = ('', '');
 open my $stdout_fh, '>', \$stdout or die "cannot capture stdout: $!";
 open my $stderr_fh, '>', \$stderr or die "cannot capture stderr: $!";
 my ($result, $failure, $ok);
 {
  local *STDOUT = $stdout_fh;
  local *STDERR = $stderr_fh;
  $ok = eval {
   $result = $callback->();
   1
  };
  $failure = $@ unless $ok;
 }
 return ($result, $stdout, $stderr, $ok, $failure)
}

sub load_generated_source {
 my ($source, $suffix) = @_;
 ++$generated_package_counter;
 my $package = 'LinkedSpec::DiagnosticOutputGenerated::'.$suffix.$generated_package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $failure = $@;
 ok($loaded, "$suffix generated source compiles independently") or diag($failure);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  get => *{"${package}::Get"}{CODE},
 }
}

sub typed_value {
 my ($record) = @_;
 my $kind = $record->{kind};
 return $record->{value} if $kind eq 'string' || $kind eq 'number' || $kind eq 'boolean';
 return undef if $kind eq 'null';
 return [map { typed_value($_) } @{$record->{items}}] if $kind eq 'array';
 return {map { $_ => typed_value($record->{entries}{$_}) } keys %{$record->{entries}}}
  if $kind eq 'harray';
 return {kind => 'codeblock_literal', id => $record->{id}} if $kind eq 'codeblock';
 die "unknown typed fixture kind '$kind'"
}

sub run_command {
 my (@command) = @_;
 my $stderr_fh = gensym;
 my $pid = open3(my $stdin_fh, my $stdout_fh, $stderr_fh, @command);
 close $stdin_fh or die "cannot close command stdin: $!";
 local $/;
 my $stdout = <$stdout_fh> // '';
 my $stderr = <$stderr_fh> // '';
 waitpid($pid, 0);
 return ($? >> 8, $stdout, $stderr)
}

subtest 'scalar rendering and typed event schema' => sub {
 my @events;
 my $descriptor = {};
 my $sink_slot = LinkedSpec::RuntimeDiagnosticOutput::sink_slot_name();
 $descriptor->{$sink_slot} = sub { push @events, $_[0] };

 foreach my $case (@{$contract->{scalar_render_cases}}) {
  LinkedSpec::RuntimeDiagnosticOutput::emit(
   $descriptor,
   'RenderRule',
   'print',
   [typed_value($case->{value})],
  );
  my $event = pop @events;
  isa_ok($event, 'LinkedSpec::RuntimeDiagnosticOutputEvent', "$case->{id} event");
  is_deeply(
   [sort keys %$event],
   [sort @{$contract->{event_schema}{fields}}],
   "$case->{id} event has exactly the neutral fields",
  );
  is($event->{helper_name}, 'print', "$case->{id} helper name is exact");
  is($event->{rule_label}, 'RenderRule', "$case->{id} rule label is exact");
  is($event->{message}, $case->{expected}, "$case->{id} diagnostic text is exact");
 }
};

my $ordered = compile_program('ordered_unicode');

subtest 'invocation options and sink type are validated before parsing' => sub {
 my @cases = (
  ['non-hash invocation options', 'invalid_invocation_options', 'diagnostics'],
  ['non-code diagnostic sink', 'invalid_diagnostic_sink', {diagnostic_sink => 'stdout'}],
 );
 foreach my $case (@cases) {
  my ($label, $expected_code, $options) = @$case;
  my $input = input_for_program('ordered_unicode');
  my $ok = eval { $ordered->{parser}->(\$input, $options); 1 };
  my $caught = $@;
  ok(!$ok, "$label is rejected");
  isa_ok($caught, 'LinkedSpec::RuntimeDiagnosticOutput::Error');
  is($caught->{code}, $expected_code, "$label reports the exact error code");
  is($ordered->{runtime_ctx}{last_error}, undef, "$label does not masquerade as a parser failure");
 }
};

subtest 'ordered Unicode events, one-time eager effects, result neutrality, and quiet default' => sub {
 my @events;
 my $input = input_for_program('ordered_unicode');
 my $result = $ordered->{parser}->(
  \$input,
  {diagnostic_sink => sub { push @events, $_[0] }},
 );
 my $expected = $scenario{ordered_unicode_with_sink}{expected};
 is_deeply($result, $expected->{outcome}{value}, 'eventful parse returns the exact structural value');
 is_deeply($result, $expected->{evaluation_order}, 'valid arguments evaluate exactly once from left to right');
 is_deeply(event_rows(\@events), $expected->{events}, 'event grouping, order, labels, and Unicode text are exact');
 ok(
  !(grep { ref($_) ne 'LinkedSpec::RuntimeDiagnosticOutputEvent' } @events),
  'every delivered event has the Perl native event type',
 );
 is($ordered->{runtime_ctx}{last_error}, undef, 'successful event delivery leaves no runtime error');

 my $quiet_input = input_for_program('ordered_unicode');
 my ($quiet_result, $stdout, $stderr, $ok, $failure) = capture_host_output(sub {
  return $ordered->{parser}->(\$quiet_input)
 });
 ok($ok, 'quiet parse succeeds') or diag($failure);
 is_deeply($quiet_result, $scenario{ordered_unicode_quiet}{expected}{outcome}{value}, 'quiet parse preserves the structural value');
 is($stdout, '', 'quiet parse writes no host stdout');
 is($stderr, '', 'quiet parse writes no host stderr');
};

my $wrong_kind = compile_program('wrong_kind');

subtest 'empty and wrong-kind print_each targets remain eager but eventless' => sub {
 my @events;
 my $input = input_for_program('wrong_kind');
 my $result = $wrong_kind->{parser}->(
  \$input,
  {diagnostic_sink => sub { push @events, $_[0] }},
 );
 my $expected = $scenario{wrong_kind_no_events}{expected};
 is_deeply($result, $expected->{evaluation_order}, 'all valid-call arguments evaluate once despite eventless targets');
 is_deeply(event_rows(\@events), $expected->{events}, 'empty and wrong-kind targets emit no events');
};

{
 package LinkedSpec::DiagnosticOutputSinkFailureProbe;
 sub new { return bless {error_id => $_[1]}, $_[0] }
}

subtest 'synchronous sink failure preserves identity and aborts later delivery' => sub {
 my $sink_failure = compile_program('sink_failure');
 my $expected = $scenario{synchronous_sink_failure}{expected};
 my @events;
 my $failure = LinkedSpec::DiagnosticOutputSinkFailureProbe->new(
  $scenario{synchronous_sink_failure}{sink}{error_id},
 );
 my $input = input_for_program('sink_failure');
 my $ok = eval {
  $sink_failure->{parser}->(
   \$input,
   {diagnostic_sink => sub {
    push @events, $_[0];
    die $failure if @events == $scenario{synchronous_sink_failure}{sink}{invocation};
   }},
  );
  1
 };
 my $caught = $@;
 ok(!$ok, 'caller sink failure aborts the parse');
 is(refaddr($caught), refaddr($failure), 'caller sink failure propagates by object identity');
 is_deeply(event_rows(\@events), $expected->{events}, 'no event after the failing callback is delivered');
 is($sink_failure->{runtime_ctx}{last_error}, undef, 'caller sink failure is not rewritten as parser last_error');
};

subtest 'print_each sink failure stops the current item loop and later arguments' => sub {
 my $expected = $scenario{print_each_sink_failure}{expected};
 my @events;
 my $failure = LinkedSpec::DiagnosticOutputSinkFailureProbe->new(
  $scenario{print_each_sink_failure}{sink}{error_id},
 );
 my $input = input_for_program('ordered_unicode');
 my $ok = eval {
  $ordered->{parser}->(
   \$input,
   {diagnostic_sink => sub {
    push @events, $_[0];
    die $failure if @events == $scenario{print_each_sink_failure}{sink}{invocation};
   }},
  );
  1
 };
 my $caught = $@;
 ok(!$ok, 'item sink failure aborts the parse');
 is(refaddr($caught), refaddr($failure), 'item sink failure preserves caller identity');
 is_deeply(event_rows(\@events), $expected->{events}, 'item delivery stops at the failing invocation');
};

my $exit_program = compile_program('immediate_exit');

subtest 'typed exit follows preceding events and prevents later actions' => sub {
 my @events;
 my $input = input_for_program('immediate_exit');
 my $ok = eval {
  $exit_program->{parser}->(
   \$input,
   {diagnostic_sink => sub { push @events, $_[0] }},
  );
  1
 };
 my $caught = $@;
 ok(!$ok, 'exit_now aborts the parse immediately');
 isa_ok($caught, 'LinkedSpec::RuntimeExitNow');
 is($caught->status, $scenario{event_before_immediate_exit}{expected}{outcome}{status}, 'typed exit preserves exact status');
 is_deeply(event_rows(\@events), $scenario{event_before_immediate_exit}{expected}{events}, 'preceding event is delivered and later event is absent');
 is($exit_program->{runtime_ctx}{last_error}, undef, 'typed exit is not rewritten as parser last_error');
};

subtest 'neutral invalid arities lower before argument evaluation' => sub {
 foreach my $case (@{$contract->{invalid_arity_cases}}) {
  my @args = map { '{ push(seen, "ARGUMENT_EVALUATED"); return("x") }' } 1 .. $case->{actual_arity};
  my $call = $case->{helper_name}.'('.join(', ', @args).')';
  my $lowered = LinkedSpec::call_spec_handler_subst('ArityRule', $call);
  like($lowered, qr/RuntimeDiagnosticOutput::helper_arity_mismatch/, "$case->{id} lowers to the typed arity seam");
  like($lowered, qr/\Q'$case->{helper_name}'\E/, "$case->{id} identifies the helper");
  like($lowered, qr/, \Q$case->{actual_arity}\E, /, "$case->{id} records actual arity");
  like($lowered, qr/\Q'$case->{expected_arity}'\E/, "$case->{id} records expected arity");
  unlike($lowered, qr/ARGUMENT_EVALUATED/, "$case->{id} emits no argument evaluation code");
 }

 my $source = <<'SPEC';
Top::
 /x/ -> Done {
   seen = []
   print_each(
     { push(seen, "first"); return([]) },
     { push(seen, "second"); return("p") },
     { push(seen, "third"); return("s") },
     { push(seen, "fourth"); return("extra") }
   )
 }

Done::
 /x/
SPEC
 my $parser = LinkedSpec::Get(\$source);
 ok(ref($parser) eq 'CODE', 'representative invalid-arity handler compiles');
 my $input = 'xx';
 my $ok = eval { $parser->(\$input); 1 };
 my $caught = $@;
 ok(!$ok, 'representative invalid arity fails at runtime');
 isa_ok($caught, 'LinkedSpec::RuntimeDiagnosticOutput::Error');
 is($caught->{code}, 'helper_arity_mismatch', 'runtime arity error code is exact');
 is($caught->{helper_name}, 'print_each', 'runtime arity error helper is exact');
 is($caught->{actual_arity}, 4, 'runtime arity error actual count is exact');
 is($caught->{expected_arity}, '2 or 3 positional arguments', 'runtime arity error expected text is exact');
 is($caught->{arguments_evaluated}, 0, 'runtime arity error confirms no argument evaluation');
};

subtest 'generated entrypoints propagate sinks and preserve caller control outcomes' => sub {
 like($ordered->{generated_source}, qr/LinkedSpec::RuntimeDiagnosticOutput::emit/, 'dumped handler routes diagnostic helpers through the runtime seam');
 unlike($ordered->{generated_source}, qr/\bprint\s+["']/, 'dumped handler contains no raw host print statement');
 unlike($ordered->{generated_source}, qr/\bsay\s+["']/, 'dumped handler contains no raw host say statement');
 like($exit_program->{generated_source}, qr/LinkedSpec::RuntimeDiagnosticOutput::terminate/, 'dumped handler routes exit_now through typed control');
 unlike($exit_program->{generated_source}, qr/(?<!::)\bexit\s*\(/, 'dumped handler contains no raw host exit call');

 my $generated = load_generated_source($ordered->{generated_source}, 'Ordered');
 my $input = input_for_program('ordered_unicode');
 my ($result, $stdout, $stderr, $ok, $failure) = capture_host_output(sub {
  return $generated->{execute}->(\$input)
 });
 ok($ok, 'independently loaded generated handler executes quietly') or diag($failure);
 is_deeply($result, $scenario{ordered_unicode_quiet}{expected}{outcome}{value}, 'generated handler preserves the structural value');
 is($stdout, '', 'generated handler writes no host stdout');
 is($stderr, '', 'generated handler writes no host stderr');

 my @events;
 my $eventful_input = input_for_program('ordered_unicode');
 my $eventful = $generated->{execute}->(
  \$eventful_input,
  {diagnostic_sink => sub { push @events, $_[0] }},
 );
 is_deeply(
  $eventful,
  $scenario{ordered_unicode_with_sink}{expected}{outcome}{value},
  'generated Execute preserves the direct value with a sink',
 );
 is_deeply(
  event_rows(\@events),
  $scenario{ordered_unicode_with_sink}{expected}{events},
  'generated Execute delivers the exact neutral event sequence',
 );

 my @traced_events;
 my $traced_input = input_for_program('ordered_unicode');
 my $traced = $generated->{execute_with_trace}->(
  \$traced_input,
  {trace_level => 'none'},
  {diagnostic_sink => sub { push @traced_events, $_[0] }},
 );
 is_deeply($traced, $eventful, 'generated ExecuteWithTrace preserves the direct value');
 is_deeply(event_rows(\@traced_events), event_rows(\@events), 'generated trace role propagates the same sink');

 my @get_events;
 my $get_input = input_for_program('ordered_unicode');
 is_deeply(
  $generated->{get}->(
   \$get_input,
   {diagnostic_sink => sub { push @get_events, $_[0] }},
  ),
  $eventful,
  'generated Get compatibility role preserves the direct value',
 );
 is_deeply(event_rows(\@get_events), event_rows(\@events), 'generated Get propagates the same sink');

 my $sink_program = compile_program('sink_failure');
 my $sink_generated = load_generated_source($sink_program->{generated_source}, 'SinkFailure');
 my @sink_events;
 my $caller_failure = LinkedSpec::DiagnosticOutputSinkFailureProbe->new('generated-caller-failure');
 my $sink_input = input_for_program('sink_failure');
 my $sink_ok = eval {
  $sink_generated->{execute}->(
   \$sink_input,
   {diagnostic_sink => sub {
    push @sink_events, $_[0];
    die $caller_failure if @sink_events == 2;
   }},
  );
  1
 };
 my $sink_error = $@;
 ok(!$sink_ok, 'generated caller sink failure aborts execution');
 is(refaddr($sink_error), refaddr($caller_failure), 'generated caller sink failure preserves exact identity');
 is_deeply(
  event_rows(\@sink_events),
  $scenario{synchronous_sink_failure}{expected}{events},
  'generated caller sink failure stops later delivery',
 );

 my $exit_generated = load_generated_source($exit_program->{generated_source}, 'Exit');
 my @exit_events;
 my $exit_input = input_for_program('immediate_exit');
 my $exit_ok = eval {
  $exit_generated->{execute}->(
   \$exit_input,
   {diagnostic_sink => sub { push @exit_events, $_[0] }},
  );
  1
 };
 my $exit_error = $@;
 ok(!$exit_ok, 'generated exit handler aborts immediately');
 isa_ok($exit_error, 'LinkedSpec::RuntimeExitNow');
 is($exit_error->status, 23, 'generated entrypoint preserves the typed exit status');
 is_deeply(
  event_rows(\@exit_events),
  $scenario{event_before_immediate_exit}{expected}{events},
  'generated entrypoint delivers the preceding event only',
 );
};

subtest 'primary command observes quiet helpers and no host-status exit' => sub {
 my $bin = File::Spec->catfile($repo_root, 'bin', 'linkedspec');
 my ($status, $stdout, $stderr) = run_command(
  $^X,
  $bin,
  '--inline-spec', $ordered->{source},
  '--input', input_for_program('ordered_unicode'),
 );
 is($status, 0, 'primary command succeeds without installing a rich sink');
 is($stderr, '', 'primary command receives no raw diagnostic stderr');
 unlike(decode('UTF-8', $stdout), qr/pré🙂|élément:/, 'primary stdout contains no raw diagnostic helper text');

 my ($exit_status, $exit_stdout, $exit_stderr) = run_command(
  $^X,
  $bin,
  '--inline-spec', $exit_program->{source},
  '--input', input_for_program('immediate_exit'),
 );
 is($exit_status, 1, 'typed exit is normalized as a primary runtime failure rather than host status 23');
 is($exit_stdout, '', 'typed exit produces no raw helper stdout');
 unlike(decode('UTF-8', $exit_stderr), qr/^before/m, 'typed exit stderr contains no preceding raw helper text');
};

done_testing;

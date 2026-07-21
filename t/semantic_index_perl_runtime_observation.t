#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use JSON::PP ();
use Scalar::Util qw(refaddr);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::SpecLoader ();
use LinkedSpec::Trace ();

my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my $ROOT = File::Spec->rel2abs(File::Spec->catdir($Bin, '..'));
my $CONTRACT_ID = 'linkedspec-semantic-execution-observation-v1';
my $generated_package_counter = 0;

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

sub read_json {
 my ($path) = @_;
 return $JSON->decode(read_bytes($path))
}

sub clone_plain {
 my ($value) = @_;
 return $JSON->decode($JSON->encode($value))
}

sub canonical_digest {
 my ($value) = @_;
 return sha256_hex($JSON->encode($value))
}

sub write_bytes {
 my ($path, $bytes) = @_;
 open my $fh, '>:raw', $path or die "cannot write $path: $!";
 print {$fh} $bytes;
 close $fh or die "cannot close $path: $!";
 return $path
}

sub load_generated_source {
 my ($source, $suffix) = @_;
 my $package = 'LinkedSpec::SemanticRuntimeGenerated::'
  . ++$generated_package_counter . $suffix;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, "$suffix generated source loads independently") or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  get => *{"${package}::Get"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
  validate_plan => *{"${package}::ValidateGeneratedPlan"}{CODE},
 }
}

sub event_rows {
 my ($events) = @_;
 return [map { +{%$_} } @$events]
}

sub normalized_trace {
 my ($trace) = @_;
 $trace =~ s/\A\x{FEFF}//;
 $trace =~ s/\[20\d\d-\d\d-\d\d \d\d:\d\d:\d\d\]//g;
 return $trace
}

my $contract = read_json(File::Spec->catfile(
 $ROOT,
 qw(capability_conformance semantic_introspection_contract.json),
));
my ($runtime_case) = grep { $_->{id} eq 'runtime_events' } @{$contract->{query_cases}};
ok($runtime_case, 'canonical runtime query case exists');

my $source_path = File::Spec->catfile(
 $ROOT,
 qw(capability_conformance semantic_introspection runtime.spec),
);
my $input_path = File::Spec->catfile(
 $ROOT,
 qw(capability_conformance semantic_introspection runtime.input),
);
my $source = read_bytes($source_path);
my $canonical_input = read_bytes($input_path);
is($canonical_input, "ab\n", 'canonical runtime input bytes are exact');

my $base_index = LinkedSpec::semantic_index(
 \$source,
 logical_name => 'runtime.spec',
 source_detail_ceiling => 'text',
);
isa_ok($base_index, 'LinkedSpec::SemanticIndex', 'runtime source builds a native semantic index');

my $captured_source = '';
my $direct_parser = LinkedSpec::Get(
 \$source,
 dump_parser_source => 1,
 parser_source_ref => \$captured_source,
 generated_source_identity => 'semantic-introspection/runtime.spec',
);
ok(ref($direct_parser) eq 'CODE', 'runtime source builds a direct parser');
my $emitted_source = LinkedSpec::emit_generated_source(
 \$source,
 source_identity => 'semantic-introspection/runtime.spec',
);
is($captured_source, $emitted_source, 'captured and public emitted generated source are byte-identical');

my $scratch = tempdir('linkedspec-semantic-runtime-XXXXXX', TMPDIR => 1, CLEANUP => 1);
my $loaded_path = write_bytes(File::Spec->catfile($scratch, 'runtime.spec'), $source);
my $loaded_parser = LinkedSpec::get_parser($loaded_path);
ok(ref($loaded_parser) eq 'CODE', 'runtime source builds through the loaded-spec route');
my $loader_result = LinkedSpec::SpecLoader::load_and_compile_spec(
 LinkedSpec::SpecLoader::path_request('runtime.spec'),
 LinkedSpec::SpecLoader::load_options(cwd => $scratch),
);
ok(ref($loader_result->compiled) eq 'CODE', 'portable spec loader exposes the compiled route');

my $captured_generated = load_generated_source($captured_source, 'Captured');
my $emitted_generated = load_generated_source($emitted_source, 'Emitted');
my $reconstructed_plan = $emitted_generated->{plan}->();
is_deeply(
 $reconstructed_plan,
 [{label => 'Top', family => 'rep_acode'}],
 'generated source reconstructs the exact validated plan',
);
ok(
 $emitted_generated->{validate_plan}->($reconstructed_plan),
 'reconstructed generated plan validates before execution',
);

my @expected_events = (
 {
  contract_id => $CONTRACT_ID,
  event_kind => 'regex_slot_selected',
  rule_label => 'Top',
  target_rule => 'Top',
  regex_index => 0,
  position => 1,
  input_identity => undef,
  status => undef,
 },
 {
  contract_id => $CONTRACT_ID,
  event_kind => 'regex_slot_selected',
  rule_label => 'Top',
  target_rule => 'Top',
  regex_index => 1,
  position => 2,
  input_identity => undef,
  status => undef,
 },
 {
  contract_id => $CONTRACT_ID,
  event_kind => 'rule_result',
  rule_label => 'Top',
  target_rule => undef,
  regex_index => undef,
  position => 2,
  input_identity => 'input:sha256:' . sha256_hex($canonical_input),
  status => 'succeeded',
 },
);

my @routes = (
 [direct => sub { $direct_parser->(@_) }],
 [loaded_spec => sub { $loaded_parser->(@_) }],
 [spec_loader => sub { $loader_result->compiled->(@_) }],
 [captured_generated_direct => sub { $captured_generated->{execute}->(@_) }],
 [captured_generated_get => sub { $captured_generated->{get}->(@_) }],
 [loaded_generated_direct => sub { $emitted_generated->{execute}->(@_) }],
 [loaded_generated_traced => sub {
  my ($input_ref, $options) = @_;
  return $emitted_generated->{execute_with_trace}->(
   $input_ref,
   {trace_level => 'none'},
   $options,
  )
 }],
 [reconstructed_plan => sub {
  my ($input_ref, $options) = @_;
  $emitted_generated->{validate_plan}->($reconstructed_plan);
  return $emitted_generated->{execute}->($input_ref, $options)
 }],
);

my @route_observations;
foreach my $route (@routes) {
 my ($name, $callback) = @$route;
 my @events;
 my $input = $canonical_input;
 my $result = $callback->(
  \$input,
  {semantic_observation_sink => sub { push @events, $_[0] }},
 );
 is_deeply($result, ['A', 'B'], "$name observer preserves the exact parser result");
 is($input, $canonical_input, "$name observer preserves the exact input bytes");
 is(pos($input), 2, "$name observer preserves the final cursor");
 is_deeply(event_rows(\@events), \@expected_events, "$name emits the exact typed observation sequence");
 ok(
  !(grep { ref($_) ne 'LinkedSpec::RuntimeSemanticObservationEvent' } @events),
  "$name delivers only native typed observation events",
 );
 push @route_observations, [$name, \@events];
}

ok(
 $base_index->can('with_execution_observation'),
 'opaque native index can derive a runtime snapshot from a completed observation',
);
if ($base_index->can('with_execution_observation')) {
 my $base_response = $base_index->query(clone_plain($runtime_case->{request}));
 ok(!$base_response->{snapshot}{has_execution}, 'base index remains static after caller capture');
 is_deeply($base_response->{records}, [], 'base index does not acquire caller observation records');

 foreach my $route (@route_observations) {
  my ($name, $events) = @$route;
  next unless @$events == @expected_events;
  my $runtime_index = $base_index->with_execution_observation($events);
  isa_ok($runtime_index, 'LinkedSpec::SemanticIndex', "$name derives the same opaque index type");
  isnt(refaddr($runtime_index), refaddr($base_index), "$name derives a new immutable index object");
  my $response = $runtime_index->query(clone_plain($runtime_case->{request}));
  ok($response->{snapshot}{has_execution}, "$name runtime snapshot advertises execution");
  is_deeply(
   [map { $_->{id} } @{$response->{records}}],
   $runtime_case->{expected}{record_ids},
   "$name runtime record ids are exact",
  );
  is(canonical_digest($response), $runtime_case->{expected}{response_sha256}, "$name exact runtime response digest matches");

  $events->[0]{position} = 999;
  $response->{records}[0]{facts}{status} = 'mutated';
  is(
   canonical_digest($runtime_index->query(clone_plain($runtime_case->{request}))),
   $runtime_case->{expected}{response_sha256},
   "$name caller mutations cannot alter the derived snapshot",
  );
  $events->[0]{position} = 1;
 }
}

subtest 'derived queries never execute and malformed observations fail structurally' => sub {
 return pass('runtime derivation unavailable in RED state')
  unless $base_index->can('with_execution_observation');
 my @valid_events;
 my $input = $canonical_input;
 is_deeply(
  $direct_parser->(
   \$input,
   {semantic_observation_sink => sub { push @valid_events, $_[0] }},
  ),
  ['A', 'B'],
  'fresh completed observation is available for validation cases',
 );
 my $runtime_index = $base_index->with_execution_observation(\@valid_events);
 my $response;
 {
  no warnings qw(redefine once);
  local *LinkedSpec::Runtime::run_get = sub { die "derived query attempted execution\n" };
  $response = $runtime_index->query(clone_plain($runtime_case->{request}));
 }
 is(
  canonical_digest($response),
  $runtime_case->{expected}{response_sha256},
  'derived query remains exact when parser execution is unavailable',
 );

 my @plain_events = @{event_rows(\@valid_events)};
 my @missing_final = @valid_events[0, 1];
 my @foreign_slot = @valid_events;
 $foreign_slot[0] = bless {%{$valid_events[0]}, target_rule => 'Missing'}, ref($valid_events[0]);
 my @cases = (
  [empty => []],
  [non_native => \@plain_events],
  [missing_final => \@missing_final],
  [foreign_slot => \@foreign_slot],
 );
 foreach my $case (@cases) {
  my ($name, $observation) = @$case;
  my $ok = eval {
   $base_index->with_execution_observation($observation);
   1
  };
  my $caught = $@;
  ok(!$ok, "$name observation is rejected");
  isa_ok($caught, 'LinkedSpec::SemanticIndex::Error', "$name observation returns a typed index error");
  is(
   ref($caught) && $caught->can('code') ? $caught->code : undef,
   'semantic_index_invalid_observation',
   "$name observation uses the stable error code",
  );
 }
};

subtest 'observer failures preserve exact identity at slot and final-result delivery' => sub {
 {
  package LinkedSpec::SemanticObservationFailureProbe;
  sub new { return bless {id => $_[1]}, $_[0] }
 }
 foreach my $route (
  [direct_slot => $direct_parser, 'regex_slot_selected'],
  [direct_result => $direct_parser, 'rule_result'],
  [generated_slot => $emitted_generated->{execute}, 'regex_slot_selected'],
  [generated_result => $emitted_generated->{execute}, 'rule_result'],
 ) {
  my ($name, $callback, $failure_kind) = @$route;
  my $failure = LinkedSpec::SemanticObservationFailureProbe->new($name);
  my @events;
  my $input = $canonical_input;
  my $ok = eval {
   $callback->(
    \$input,
    {semantic_observation_sink => sub {
     my ($event) = @_;
     push @events, $event;
     die $failure if ($event->{event_kind} // '') eq $failure_kind;
    }},
   );
   1
  };
  my $caught = $@;
  ok(!$ok, "$name observer failure aborts synchronously");
  is(refaddr($caught), refaddr($failure), "$name observer failure preserves exact identity");
  ok(@events >= 1, "$name failure occurs only after typed event delivery");
 }
};

subtest 'observer type validation happens before parsing' => sub {
 my $input = $canonical_input;
 my $ok = eval {
  $direct_parser->(\$input, {semantic_observation_sink => 'events'});
  1
 };
 my $caught = $@;
 ok(!$ok, 'non-code semantic observation sink is rejected');
 isa_ok($caught, 'LinkedSpec::RuntimeSemanticObservation::Error');
 is(
  ref($caught) ? $caught->{code} : undef,
  'invalid_semantic_observation_sink',
  'sink type error code is exact',
 );
 ok(
  !defined(pos($input)) || pos($input) == 0,
  'sink validation failure occurs before parsing advances the cursor',
 );
};

subtest 'trace bytes and diagnostic events are independent of semantic observation' => sub {
 my @trace_paths = map { File::Spec->catfile($scratch, "runtime-$_.trace") } qw(quiet observed);
 my @semantic_events;
 my @trace_results;
 for my $index (0, 1) {
  my $input = $canonical_input;
  my $options = $index
   ? {semantic_observation_sink => sub { push @semantic_events, $_[0] }}
   : undef;
  push @trace_results, $emitted_generated->{execute_with_trace}->(
   \$input,
   {
    trace_level => 'debug',
    trace_log_file => $trace_paths[$index],
    trace_log_mode => 'route',
    trace_reset_log => 1,
    trace_topic_spacing => 0,
   },
   $options,
  );
 }
 is_deeply($trace_results[1], $trace_results[0], 'semantic observer does not change traced result');
 is(
  normalized_trace(read_bytes($trace_paths[1])),
  normalized_trace(read_bytes($trace_paths[0])),
  'semantic observer does not add, remove, or alter trace events',
 );
 is_deeply(event_rows(\@semantic_events), \@expected_events, 'traced observer still receives exact semantic events');
 LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

 my $diagnostic_contract = read_json(File::Spec->catfile(
  $ROOT,
  qw(capability_conformance diagnostic_output_contract.json),
 ));
 my ($program) = grep { $_->{id} eq 'ordered_unicode' } @{$diagnostic_contract->{programs}};
 my $diagnostic_source = $program->{spec_source};
 $diagnostic_source =~ s/\n E \{/\n -> Done {/ or die 'diagnostic fixture has no E block';
 $diagnostic_source .= "\nDone::\n /x/\n";
 my $diagnostic_parser = LinkedSpec::Get(\$diagnostic_source);
 ok(ref($diagnostic_parser) eq 'CODE', 'diagnostic neutrality fixture compiles');
 my (@quiet_diagnostics, @observed_diagnostics, @diagnostic_semantic_events);
 my $quiet_input = $program->{input} . 'x';
 my $quiet_result = $diagnostic_parser->(
  \$quiet_input,
  {diagnostic_sink => sub { push @quiet_diagnostics, $_[0] }},
 );
 my $observed_input = $program->{input} . 'x';
 my $observed_result = $diagnostic_parser->(
  \$observed_input,
  {
   diagnostic_sink => sub { push @observed_diagnostics, $_[0] },
   semantic_observation_sink => sub { push @diagnostic_semantic_events, $_[0] },
  },
 );
 is_deeply($observed_result, $quiet_result, 'semantic observer preserves diagnostic-program result');
 is_deeply(
  event_rows(\@observed_diagnostics),
  event_rows(\@quiet_diagnostics),
  'semantic observer does not add, remove, or alter diagnostic events',
 );
 ok(@diagnostic_semantic_events, 'semantic and diagnostic sinks remain independently active');
};

done_testing;

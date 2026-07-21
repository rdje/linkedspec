#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use Encode qw(decode FB_CROAK LEAVE_SRC);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::Trace ();

my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my $ROOT = File::Spec->rel2abs(File::Spec->catdir($Bin, '..'));
my $CONTRACT_PATH = File::Spec->catfile(
 $ROOT,
 qw(capability_conformance semantic_introspection_contract.json),
);
my $FIXTURE_ROOT = File::Spec->catdir(
 $ROOT,
 qw(capability_conformance semantic_introspection),
);
my $CONSUMER_PATH = 't/semantic_introspection_perl_admission.t';
my $CANONICAL_DRIVER = 'tools/run_ci_local.sh';
my @ROLES = qw(
 source_normalization
 compiled_snapshots
 failed_snapshot
 runtime_direct
 runtime_loaded
 runtime_generated
 runtime_traced
 native_and_neutral_json
 exact_twenty_queries
 privacy_page_budget_error_explain
 query_non_interference
 stale_host_leak_denial
);

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

sub fixture_bytes {
 my ($fixture) = @_;
 return read_bytes(File::Spec->catfile($FIXTURE_ROOT, "$fixture.spec"))
}

my $contract = read_json($CONTRACT_PATH);
my %case = map { $_->{id} => $_ } @{$contract->{query_cases}};
my %snapshot_input = (
 graph => {fixture => 'graph', logical_name => 'graph.spec', ceiling => 'text'},
 calls => {fixture => 'calls_and_staging', logical_name => 'calls_and_staging.spec', ceiling => 'text'},
 failed => {fixture => 'failed', logical_name => 'failed.spec', ceiling => 'span'},
 runtime => {fixture => 'runtime', logical_name => 'runtime.spec', ceiling => 'text'},
 privacy => {fixture => 'privacy', logical_name => 'privacy.spec', ceiling => 'text'},
 privacy_limited => {fixture => 'privacy', logical_name => 'privacy.spec', ceiling => 'identity'},
);
my (%index, %construction_output, %response);
my ($runtime_index, $runtime_parser, $generated_module, $scratch, $direct_event_rows);
my $runtime_input = read_bytes(File::Spec->catfile($FIXTURE_ROOT, 'runtime.input'));
my $runtime_source = fixture_bytes('runtime');
my $generated_package_counter = 0;

sub index_for {
 my ($id) = @_;
 return $index{$id} if $index{$id};
 my $input = $snapshot_input{$id};
 my $source = fixture_bytes($input->{fixture});
 my ($stdout, $stderr) = ('', '');
 {
  local *STDOUT;
  local *STDERR;
  open STDOUT, '>', \$stdout or die "cannot capture constructor stdout: $!";
  open STDERR, '>', \$stderr or die "cannot capture constructor stderr: $!";
  $index{$id} = LinkedSpec::semantic_index(
   \$source,
   logical_name => $input->{logical_name},
   source_detail_ceiling => $input->{ceiling},
  );
 }
 $construction_output{$id} = [$stdout, $stderr];
 return $index{$id}
}

sub load_generated_source {
 my ($source) = @_;
 my $package = 'LinkedSpec::SemanticAdmissionGenerated::' . ++$generated_package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, 'semantic admission generated source loads independently') or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
 }
}

sub event_rows {
 my ($events) = @_;
 return [map { +{%$_} } @$events]
}

sub capture_runtime_route {
 my ($name, $callback) = @_;
 my @events;
 my $input = $runtime_input;
 my $result = $callback->(
  \$input,
  {semantic_observation_sink => sub { push @events, $_[0] }},
 );
 is_deeply($result, ['A', 'B'], "$name preserves the exact parser result");
 is($input, $runtime_input, "$name preserves exact input bytes");
 is(pos($input), 2, "$name preserves the exact final cursor");
 is(scalar(@events), 3, "$name emits exactly two slots and one final result");
 ok(!(grep { ref($_) ne 'LinkedSpec::RuntimeSemanticObservationEvent' } @events), "$name emits only typed events");
 is_deeply(
  [map { $_->{event_kind} } @events],
  [qw(regex_slot_selected regex_slot_selected rule_result)],
  "$name preserves event order",
 );
 my $derived = index_for('runtime')->with_execution_observation(\@events);
 my $answer = $derived->query(clone_plain($case{runtime_events}{request}));
 is(
  canonical_digest($answer),
  $case{runtime_events}{expected}{response_sha256},
  "$name derives the exact runtime response",
 );
 return ($derived, \@events, $answer)
}

my %role = (
 source_normalization => sub {
  my $raw = fixture_bytes('privacy');
  my $decoded = decode('UTF-8', $raw, FB_CROAK | LEAVE_SRC);
  my $raw_index = LinkedSpec::semantic_index(
   \$raw,
   logical_name => 'privacy.spec',
   source_detail_ceiling => 'text',
  );
  my $decoded_index = LinkedSpec::semantic_index(
   \$decoded,
   logical_name => 'privacy.spec',
   source_detail_ceiling => 'text',
  );
  my $request = clone_plain($case{privacy_text_and_digest}{request});
  my $raw_answer = $raw_index->query(clone_plain($request));
  my $decoded_answer = $decoded_index->query(clone_plain($request));
  is_deeply($raw_answer, $decoded_answer, 'strict bytes and decoded text converge on one semantic response');
  is(canonical_digest($raw_answer), $case{privacy_text_and_digest}{expected}{response_sha256}, 'normalized Unicode response is exact');
 },
 compiled_snapshots => sub {
  for my $id (qw(graph calls privacy privacy_limited)) {
   my $native = index_for($id);
   isa_ok($native, 'LinkedSpec::SemanticIndex', "$id constructs an opaque native index");
   is($construction_output{$id}[1], '', "$id construction keeps stderr empty");
  }
  my $graph = index_for('graph')->query(clone_plain($case{graph_list_rules}{request}));
  my $calls = index_for('calls')->query(clone_plain($case{calls_symbols_and_shapes}{request}));
  ok(!$graph->{snapshot}{has_execution} && !$calls->{snapshot}{has_execution}, 'compiled snapshots remain static');
  is(canonical_digest($graph), $case{graph_list_rules}{expected}{response_sha256}, 'graph compiled snapshot is exact');
  is(canonical_digest($calls), $case{calls_symbols_and_shapes}{expected}{response_sha256}, 'calls compiled snapshot is exact');
 },
 failed_snapshot => sub {
  my $failed = index_for('failed');
  isa_ok($failed, 'LinkedSpec::SemanticIndex', 'language failure remains an opaque queryable index');
  like($construction_output{failed}[0], qr/CRITICAL ERROR/, 'failed construction preserves existing compiler output');
  is($construction_output{failed}[1], '', 'failed construction keeps stderr empty');
  my $answer = $failed->query(clone_plain($case{failed_diagnostic}{request}));
  is($answer->{snapshot}{state}, 'failed_compilation', 'failed snapshot reports exact state');
  is(canonical_digest($answer), $case{failed_diagnostic}{expected}{response_sha256}, 'failed snapshot response is exact');
 },
 runtime_direct => sub {
  $runtime_parser = LinkedSpec::Get(\$runtime_source);
  ok(ref($runtime_parser) eq 'CODE', 'runtime direct parser compiles');
  my ($derived, $events, $answer) = capture_runtime_route('direct', sub { $runtime_parser->(@_) });
  $runtime_index = $derived;
  $response{runtime_events} = $answer;
  $direct_event_rows = event_rows($events);
  is($events->[2]{input_identity}, 'input:sha256:' . sha256_hex($runtime_input), 'direct final event hashes all exact input bytes');
 },
 runtime_loaded => sub {
  $scratch ||= tempdir('linkedspec-semantic-admission-XXXXXX', TMPDIR => 1, CLEANUP => 1);
  my $path = write_bytes(File::Spec->catfile($scratch, 'runtime.spec'), $runtime_source);
  my $parser = LinkedSpec::get_parser($path);
  ok(ref($parser) eq 'CODE', 'runtime loaded parser compiles');
  capture_runtime_route('loaded', sub { $parser->(@_) });
 },
 runtime_generated => sub {
  my $generated = LinkedSpec::emit_generated_source(
   \$runtime_source,
   source_identity => 'semantic-introspection/runtime.spec',
  );
  ok(defined($generated) && length($generated), 'runtime generated source emits');
  $generated_module = load_generated_source($generated);
  ok(ref($generated_module->{execute}) eq 'CODE', 'generated direct route is callable');
  capture_runtime_route('generated', sub { $generated_module->{execute}->(@_) });
 },
 runtime_traced => sub {
  $scratch ||= tempdir('linkedspec-semantic-admission-XXXXXX', TMPDIR => 1, CLEANUP => 1);
  my $trace_path = File::Spec->catfile($scratch, 'semantic-admission.trace');
  my ($derived, $events) = capture_runtime_route('generated traced', sub {
   my ($input_ref, $options) = @_;
   return $generated_module->{execute_with_trace}->(
    $input_ref,
    {
     trace_level => 'debug',
     trace_log_file => $trace_path,
     trace_log_mode => 'route',
     trace_reset_log => 1,
     trace_topic_spacing => 0,
    },
    $options,
   )
  });
  like(read_bytes($trace_path), qr/GENERATED_SOURCE generated_family_decision/, 'traced route preserves independent generated trace');
  is_deeply(event_rows($events), $direct_event_rows, 'traced route preserves the exact direct semantic event sequence');
  isa_ok($derived, 'LinkedSpec::SemanticIndex', 'traced observation derives the native index type');
  LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');
 },
 native_and_neutral_json => sub {
  my $native = index_for('graph')->capabilities;
  my $queried = index_for('graph')->query(clone_plain($case{capabilities}{request}));
  is_deeply($native, $queried, 'native capabilities and neutral query are identical');
  is_deeply($JSON->decode($JSON->encode($native)), $native, 'native answer round-trips through neutral JSON');
  $native->{records}[0]{facts}{record_kinds}[0] = 'host_private_kind';
  is(canonical_digest(index_for('graph')->capabilities), $case{capabilities}{expected}{response_sha256}, 'native answers are immutable across caller mutation');
 },
 exact_twenty_queries => sub {
  is(scalar(@{$contract->{query_cases}}), 20, 'contract declares exactly twenty canonical queries');
  for my $query_case (@{$contract->{query_cases}}) {
   my $id = $query_case->{id};
   my $native = $id eq 'runtime_events' ? $runtime_index : index_for($query_case->{snapshot});
   my $request = clone_plain($query_case->{request});
   my $before = clone_plain($request);
   my $answer = $native->query($request);
   is_deeply($request, $before, "$id keeps its request immutable");
   is($answer->{ok} ? 1 : 0, $query_case->{expected}{ok} ? 1 : 0, "$id status is exact");
   is_deeply([map { $_->{id} } @{$answer->{records}}], $query_case->{expected}{record_ids}, "$id records are exact");
   is_deeply([map { $_->{id} } @{$answer->{relations}}], $query_case->{expected}{relation_ids}, "$id relations are exact");
   is_deeply([map { $_->{code} } @{$answer->{diagnostics}}], $query_case->{expected}{diagnostic_codes}, "$id diagnostics are exact");
   is(canonical_digest($answer), $query_case->{expected}{response_sha256}, "$id full response digest is exact");
   $response{$id} = $answer;
  }
 },
 privacy_page_budget_error_explain => sub {
  is($response{privacy_none}{records}[0]{source}, undef, 'privacy none removes source identity');
  is_deeply($response{privacy_none}{records}[0]{redactions}, ['/facts/pattern'], 'privacy none reports exact redaction');
  is($response{privacy_text_and_digest}{records}[0]{facts}{pattern}, 'é', 'privacy text retains Unicode semantic text');
  like($response{privacy_text_and_digest}{records}[0]{source}{content_digest}, qr/^sha256:[0-9a-f]{64}\z/, 'privacy text returns governed digest');
  ok(!$response{source_ceiling_forbidden}{ok}, 'source ceiling rejects escalation');
  is(
   $response{pagination_after_id}{page}{complete} ? 1 : 0,
   $case{pagination_after_id}{expected}{complete} ? 1 : 0,
   'pagination reports the exact completion state',
  );
  is($response{page_boundary}{page}{complete} ? 1 : 0, $case{page_boundary}{expected}{complete} ? 1 : 0, 'page boundary completion is exact');
  is($response{budget_prefix}{diagnostics}[0]{code}, 'semantic_query_budget_exceeded', 'record budget uses portable diagnostic');
  is($response{relation_budget_prefix}{diagnostics}[0]{code}, 'semantic_query_budget_exceeded', 'relation budget uses portable diagnostic');
  is($response{unsupported_contract}{diagnostics}[0]{code}, 'semantic_query_contract_unsupported', 'unsupported contract is portable');
  is($response{invalid_operation_combination}{diagnostics}[0]{code}, 'semantic_query_invalid', 'invalid operation is portable');
  ok(grep({ $_->{kind} eq 'explanation_step' } @{$response{graph_explain_entry}{records}}), 'explain returns governed explanation steps');
 },
 query_non_interference => sub {
  my ($stdout, $stderr) = ('', '');
  my $answer;
  {
   no warnings qw(redefine once);
   local *LinkedSpec::Runtime::run_get = sub { die "admission query attempted compilation\n" };
   local *STDOUT;
   local *STDERR;
   open STDOUT, '>', \$stdout or die "cannot capture query stdout: $!";
   open STDERR, '>', \$stderr or die "cannot capture query stderr: $!";
   $answer = index_for('graph')->query(clone_plain($case{graph_explain_entry}{request}));
  }
  is($stdout, '', 'query emits no stdout');
  is($stderr, '', 'query emits no stderr or trace');
  is(canonical_digest($answer), $case{graph_explain_entry}{expected}{response_sha256}, 'query remains exact without compilation authority');
  $answer->{records}[0]{facts}{outcome} = 'mutated';
  is(canonical_digest(index_for('graph')->query(clone_plain($case{graph_explain_entry}{request}))), $case{graph_explain_entry}{expected}{response_sha256}, 'response mutation cannot alter retained state');
 },
 stale_host_leak_denial => sub {
  my $encoded = join("\n", map { $JSON->encode($response{$_}) } sort keys %response);
  unlike($encoded, qr{(?:/Users/|/private/tmp/|CODE\(|Regexp\(|SCALAR\(0x|HASH\(0x)}, 'all canonical answers deny paths and host object identities');
  unlike($encoded, qr{(?:ActionIR|LinkedSpec::SemanticSourceMap|generated_implementation_source)}, 'all canonical answers deny backend IR and implementation owners');
 },
);

is_deeply([sort keys %role], [sort @ROLES], 'Perl semantic admission consumer implements every declared role exactly once');
my %completed;
for my $name (@ROLES) {
 subtest "Perl semantic admission role: $name" => sub {
  $role{$name}->();
  $completed{$name}++;
 };
}
is_deeply(\%completed, {map { $_ => 1 } @ROLES}, 'Perl semantic admission consumer completes every role once');

my ($perl_admission) = grep { $_->{backend} eq 'perl' && $_->{runtime} eq 'perl' } @{$contract->{target_admissions}};
is($perl_admission->{status}, 'complete', 'Perl native semantic admission is complete');
is_deeply(
 $perl_admission->{consumer},
 {path => $CONSUMER_PATH, canonical_driver => $CANONICAL_DRIVER, roles => \@ROLES},
 'neutral contract declares the exact Perl consumer topology',
);
my ($perl_rollout) = grep { $_->{capability} eq 'perl_reference' } @{$contract->{rollout}};
is($perl_rollout->{status}, 'complete', 'only the Perl rollout leg is promoted');
ok(
 grep({ $_ eq $CONSUMER_PATH } @{$contract->{canonical_ci}{required_tracked_files}}),
 'canonical CI requires the composed Perl consumer',
);

done_testing;

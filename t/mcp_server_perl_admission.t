#!/usr/bin/env perl
# FUTURE-PARITY-BACKLOG.10.9.7.1.1.2 — all-twenty MCP/native identity.
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use Encode qw(encode FB_CROAK LEAVE_SRC);
use File::Spec;
use FindBin qw($Bin);
use JSON::PP ();
use Scalar::Util qw(weaken);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::MCPContractRuntime ();
use LinkedSpec::MCPServer;

my $SEMANTIC_JSON = JSON::PP->new->canonical(1)->utf8(1);
my $PLAIN_JSON = JSON::PP->new->canonical(1);

my @ROLE_ORDER = qw(
 contract_inventory
 canonical_static_dispatch
 native_capabilities_identity
 native_query_identity
 raw_input_outcomes
 lifecycle_outcomes
 handle_state_indistinguishability
 policy_overlay
 cancellation_emission
 shutdown_and_io
 hostile_output_and_log_privacy
 authority_surface_fences
);
my @roles_seen;

{
 package Local::AdmissionFailingInput;
 use Errno qw(EIO);
 sub TIEHANDLE { return bless {}, shift }
 sub BINMODE { return 1 }
 sub READ { $! = EIO; return undef }
 sub FILENO { return -1 }
}

{
 package Local::AdmissionFailingOutput;
 sub TIEHANDLE { return bless {}, shift }
 sub BINMODE { return 1 }
 sub PRINT { return 0 }
 sub FLUSH { return 1 }
 sub FILENO { return -1 }
}

{
 package Local::AdmissionChunkThenFail;
 use Errno qw(EIO);
 sub TIEHANDLE { return bless {chunk => $_[1], delivered => 0}, $_[0] }
 sub BINMODE { return 1 }
 sub READ {
  my ($self, undef, $length) = @_;
  if (!$self->{delivered}) {
   $self->{delivered} = 1;
   my $chunk = substr($self->{chunk}, 0, $length);
   $_[1] = $chunk;
   return length($chunk)
  }
  $! = EIO;
  return undef
 }
 sub FILENO { return -1 }
}

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

sub canonical {
 return LinkedSpec::MCPContractRuntime::canonical_json($_[0])
}

sub clone_plain {
 return $PLAIN_JSON->decode(canonical($_[0]))
}

sub response_digest {
 return sha256_hex(encode('UTF-8', canonical($_[0]), FB_CROAK | LEAVE_SRC))
}

sub frame_bytes {
 return encode('UTF-8', canonical($_[0]), FB_CROAK | LEAVE_SRC) . "\n"
}

sub raw_fixture_bytes {
 my ($row) = @_;
 return pack('H*', $row->{data}) if $row->{encoding} eq 'hex';
 return encode('UTF-8', $row->{data}, FB_CROAK | LEAVE_SRC) if $row->{encoding} eq 'utf8';
 return pack('H*', $row->{byte}) x $row->{count} . pack('H*', $row->{suffix})
  if $row->{encoding} eq 'repeat_hex';
 return ('[' x $row->{depth}) . '0' . (']' x $row->{depth}) . "\n"
  if $row->{encoding} eq 'nested_json';
 die "unknown raw fixture encoding $row->{encoding}"
}

sub test_server {
 my (%args) = @_;
 my $now_ref = $args{now_ref} || do { my $now = 10_000; \$now };
 my @entropy = @{$args{entropy} || [('A' x 32)]};
 my $last = $entropy[-1];
 my @options = (
  entropy => sub { return @entropy ? shift(@entropy) : $last },
  now_ms => sub { return $$now_ref },
 );
 push @options, max_handles => $args{max_handles} if exists $args{max_handles};
 return LinkedSpec::MCPServer->_new_for_test(@options)
}

sub run_stream {
 my ($server, $bytes, %options) = @_;
 my ($output_bytes, $log_bytes) = ('', '');
 open my $input, '<:raw', \$bytes or die "cannot open scalar input: $!";
 open my $output, '>:raw', \$output_bytes or die "cannot open scalar output: $!";
 my @serve = (
  input => $input,
  output => $output,
  authorization_context => ($options{authorization_context} // 'principal'),
 );
 my $log;
 if ($options{log}) {
  open $log, '>:raw', \$log_bytes or die "cannot open scalar log: $!";
  push @serve, log => $log;
 }
 my $status = $server->serve_stdio(@serve);
 close $input or die "cannot close scalar input: $!";
 close $output or die "cannot close scalar output: $!";
 close $log or die "cannot close scalar log: $!" if $log;
 return ($status, $output_bytes, $log_bytes)
}

sub with_handle {
 my ($frame_id, $handle) = @_;
 my $request = LinkedSpec::MCPContractRuntime::frame($frame_id);
 $request->{params}{arguments}{handle} = $handle;
 return $request
}

sub admission_role {
 my ($id, $callback) = @_;
 push @roles_seen, $id;
 subtest $id => $callback;
 return
}

my $corpus = LinkedSpec::MCPContractRuntime::corpus();
my %raw_by_id = map { $_->{id} => $_ } @{$corpus->{raw_inputs}};
my @raw_ids = qw(
 invalid_utf8 utf8_bom malformed_json duplicate_key overlong_line json_batch non_object
 invalid_boolean_id nesting_depth_65 valid_crlf_discovery
);
my @lifecycle_ids = qw(
 ready_at_stream_loop_start cancel_before_response_emission cancel_unknown_request
 cancel_after_sync_completion legacy_initialized_notification stdout_discipline stderr_default
 registry_capacity graceful_eof unexpected_io_failure
);
my @handle_states = qw(unknown expired revoked unauthorized);
my @policy_ids = qw(
 default_capabilities_identity restricted_capabilities_projection allowed_query_identity
 above_policy_pre_dispatch_denial
);

my $semantic_fixture_root = File::Spec->catdir(
 $Bin,
 '..',
 qw(capability_conformance semantic_introspection),
);
my $semantic_contract = $SEMANTIC_JSON->decode(read_bytes(File::Spec->catfile(
 $Bin,
 '..',
 qw(capability_conformance semantic_introspection_contract.json),
)));
my %semantic_case = map { $_->{id} => $_ } @{$semantic_contract->{query_cases}};
my %snapshot_input = (
 graph => {fixture => 'graph', logical_name => 'graph.spec', ceiling => 'text'},
 calls => {fixture => 'calls_and_staging', logical_name => 'calls_and_staging.spec', ceiling => 'text'},
 failed => {fixture => 'failed', logical_name => 'failed.spec', ceiling => 'span'},
 runtime => {fixture => 'runtime', logical_name => 'runtime.spec', ceiling => 'text'},
 privacy => {fixture => 'privacy', logical_name => 'privacy.spec', ceiling => 'text'},
 privacy_limited => {fixture => 'privacy', logical_name => 'privacy.spec', ceiling => 'identity'},
);
my %semantic_index;

sub semantic_fixture_bytes {
 my ($name) = @_;
 return read_bytes(File::Spec->catfile($semantic_fixture_root, "$name.spec"))
}

sub semantic_index_for {
 my ($snapshot) = @_;
 return $semantic_index{$snapshot} if $semantic_index{$snapshot};
 my $input = $snapshot_input{$snapshot} or die "unknown semantic snapshot $snapshot";
 my $source = semantic_fixture_bytes($input->{fixture});
 my $index;
 {
  local *STDOUT;
  local *STDERR;
  my ($stdout, $stderr) = ('', '');
  open STDOUT, '>', \$stdout or die "cannot capture semantic constructor stdout: $!";
  open STDERR, '>', \$stderr or die "cannot capture semantic constructor stderr: $!";
  $index = LinkedSpec::semantic_index(
   \$source,
   logical_name => $input->{logical_name},
   source_detail_ceiling => $input->{ceiling},
  );
 }
 if ($snapshot eq 'runtime') {
  my $parser = LinkedSpec::Get(\$source);
  my $runtime_input = read_bytes(File::Spec->catfile($semantic_fixture_root, 'runtime.input'));
  my $input_bytes = $runtime_input;
  my @events;
  my $result = $parser->(
   \$input_bytes,
   {semantic_observation_sink => sub { push @events, $_[0] }},
  );
  is_deeply($result, ['A', 'B'], 'MCP runtime snapshot executes the governed fixture');
  is($input_bytes, $runtime_input, 'MCP runtime snapshot preserves exact input bytes');
  is(scalar(@events), 3, 'MCP runtime snapshot captures the governed observation sequence');
  $index = $index->with_execution_observation(\@events);
 }
 $semantic_index{$snapshot} = $index;
 return $index
}

my $index = semantic_index_for('graph');
my $native_capabilities = LinkedSpec::SemanticIndex->can('capabilities');
my $native_query = LinkedSpec::SemanticIndex->can('query');

admission_role(
 'contract_inventory',
 sub {
  my @frame_ids = map { $_->{id} } @{$corpus->{frames}};
  is_deeply($corpus->{canonical_order}, \@frame_ids, 'all 35 canonical frames retain exact order');
  is(scalar(@frame_ids), 35, 'canonical frame inventory is exact');
  my $canonical_path = File::Spec->catfile(
   $Bin,
   '..',
   qw(capability_conformance mcp_semantic_transport canonical_frames.jsonl),
  );
  my $canonical_bytes = read_bytes($canonical_path);
  my $source_sha = LinkedSpec::MCPContractRuntime::source_sha256();
  is(sha256_hex($canonical_bytes), $source_sha->{canonical_frames}, 'the exact canonical JSONL artifact is unchanged');
  my @canonical_lines = split /\n/, $canonical_bytes;
  is(scalar(@canonical_lines), 35, 'canonical JSONL has exactly 35 complete LF frames');
  foreach my $index (0 .. $#frame_ids) {
   is(canonical(LinkedSpec::MCPContractRuntime::frame($frame_ids[$index])), $canonical_lines[$index], "$frame_ids[$index] is consumed unchanged");
  }
  is_deeply([map { $_->{id} } @{$corpus->{raw_inputs}}], \@raw_ids, 'all ten raw cases retain exact order');
  is_deeply([map { $_->{id} } @{$corpus->{lifecycle_cases}}], \@lifecycle_ids, 'all ten lifecycle cases retain exact order');
  is_deeply([map { $_->{state} } @{$corpus->{handle_cases}}], \@handle_states, 'all four handle cases retain exact order');
  is_deeply([map { $_->{id} } @{$corpus->{policy_cases}}], \@policy_ids, 'all four policy cases retain exact order');

  my $validator_path = File::Spec->catfile(
   $Bin,
   '..',
   qw(capability_conformance mcp_semantic_transport validator_cases.json),
  );
  my $validator_bytes = read_bytes($validator_path);
  is(sha256_hex($validator_bytes), $source_sha->{validator_cases}, 'the exact validator-case artifact is unchanged');
  my $validator = JSON::PP->new->utf8(1)->decode($validator_bytes);
  is(scalar(@{$validator->{mutation_order}}), 76, 'all 76 independent validator mutations remain present');
 }
);

admission_role(
 'canonical_static_dispatch',
 sub {
  my $server = LinkedSpec::MCPServer->new;
  foreach my $case (
   ['discover_request', 'discover_response_perl'],
   ['tools_list_request', 'tools_list_response_perl'],
   ['unsupported_version_request', 'unsupported_version_response'],
   ['missing_metadata_request', 'missing_metadata_response'],
   ['legacy_initialize_request', 'legacy_initialize_response'],
   ['unknown_method_request', 'unknown_method_response'],
   ['unknown_tool_request', 'unknown_tool_response'],
   ['malformed_arguments_request', 'malformed_arguments_response'],
  ) {
   is(
    canonical($server->dispatch(
     LinkedSpec::MCPContractRuntime::frame($case->[0]),
     authorization_context => 'principal',
    )),
    canonical(LinkedSpec::MCPContractRuntime::frame($case->[1])),
    "$case->[0] produces its exact canonical Perl response",
   );
  }
  is(
   $server->dispatch(
    LinkedSpec::MCPContractRuntime::frame('legacy_initialized_notification'),
    authorization_context => 'principal',
   ),
   undef,
   'legacy initialized notification is ignored',
  );
  $server->shutdown;
 }
);

admission_role(
 'native_capabilities_identity',
 sub {
  my $server = test_server(entropy => [('B' x 32)]);
  my $handle = $server->register_index($index, authorization_context => 'principal');
  my $native = $index->capabilities;
  my $response = $server->dispatch(
   with_handle('capabilities_call_request', $handle),
   authorization_context => 'principal',
  );
  is_deeply($response->{result}{structuredContent}, $native, 'MCP structured capabilities are the native object');
  is($response->{result}{content}[0]{text}, canonical($native), 'MCP capability text is exact native canonical JSON');
  is_deeply($PLAIN_JSON->decode($response->{result}{content}[0]{text}), $native, 'MCP capability text decodes to the native object');
  is(response_digest($native), $semantic_case{capabilities}{expected}{response_sha256}, 'MCP capability preserves the governed response digest');
  is(canonical($response), canonical(LinkedSpec::MCPContractRuntime::frame('capabilities_call_response')), 'complete capability envelope is exact');
  $server->shutdown;
 }
);

admission_role(
 'native_query_identity',
 sub {
  my @query_cases = grep { $_->{id} ne 'capabilities' } @{$semantic_contract->{query_cases}};
  is(scalar(@query_cases), 19, 'the MCP consumer covers all nineteen governed query responses');
  my $server = test_server(entropy => [map { chr(67 + $_) x 32 } 0 .. 5]);
  my %handle;
  foreach my $snapshot (qw(graph calls failed runtime privacy privacy_limited)) {
   $handle{$snapshot} = $server->register_index(
    semantic_index_for($snapshot),
    authorization_context => 'principal',
   );
  }
  foreach my $ordinal (0 .. $#query_cases) {
   my $query_case = $query_cases[$ordinal];
   my $id = $query_case->{id};
   my $native_index = semantic_index_for($query_case->{snapshot});
   my $native_request = clone_plain($query_case->{request});
   my $native = $native_index->query($native_request);
   my $request = with_handle('query_call_request', $handle{$query_case->{snapshot}});
   $request->{id} = 100 + $ordinal unless $id eq 'graph_list_rules';
   $request->{params}{arguments}{request} = clone_plain($query_case->{request});
   my $response = $server->dispatch($request, authorization_context => 'principal');
   is_deeply($response->{result}{structuredContent}, $native, "$id MCP structured content is the direct native object");
   is($response->{result}{content}[0]{text}, canonical($native), "$id MCP text is exact direct canonical JSON");
   is_deeply($PLAIN_JSON->decode($response->{result}{content}[0]{text}), $native, "$id MCP text decodes to the direct native object");
   is(response_digest($native), $query_case->{expected}{response_sha256}, "$id preserves the governed response digest");
  }
  $server->shutdown;
 }
);

admission_role(
 'raw_input_outcomes',
 sub {
  foreach my $id (@raw_ids) {
   my ($status, $output, $log) = run_stream(test_server(), raw_fixture_bytes($raw_by_id{$id}));
   is($status, 0, "$id reaches graceful EOF");
   is($log, '', "$id is silent by default");
   my $expected;
   if ($id eq 'valid_crlf_discovery') {
    $expected = frame_bytes(LinkedSpec::MCPContractRuntime::discover_response(1));
   } else {
    my $kind = $raw_by_id{$id}{expected}{code} == -32700 ? 'parse_error' : 'invalid_request';
    $expected = frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, $kind));
   }
   is($output, $expected, "$id produces the exact contract outcome");
  }
 }
);

admission_role(
 'lifecycle_outcomes',
 sub {
  my %expected = map { $_->{id} => $_->{expected} } @{$corpus->{lifecycle_cases}};
  is($expected{ready_at_stream_loop_start}, 'dispatch_without_handshake', 'ready case remains exact');
  my ($status, $output, $log) = run_stream(
   test_server(),
   frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_request')),
   log => 1,
  );
  is($status, 0, 'ready stream and graceful EOF return zero');
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_response_perl')), 'first request dispatches without a handshake');
  is($log, '', 'normal stream proves stderr_default');

  my $server = test_server();
  my $prepared_request = LinkedSpec::MCPContractRuntime::frame('discover_request');
  my ($prepared, $key) = $server->_dispatch_for_wire($prepared_request, authorization_context => 'principal');
  ok(defined($prepared) && defined($key), 'response reaches the preparation/emission seam');
  my $cancel = LinkedSpec::MCPContractRuntime::frame('cancelled_notification');
  $cancel->{params}{requestId} = $prepared_request->{id};
  $server->dispatch($cancel, authorization_context => 'principal');
  ok(!$server->_wire_response_ready($key), 'cancel_before_response_emission suppresses output');
  $server->shutdown;

  my $unknown = LinkedSpec::MCPContractRuntime::frame('cancelled_notification');
  $unknown->{params}{requestId} = 'unknown';
  (undef, $output) = run_stream(test_server(), frame_bytes($unknown));
  is($output, '', 'cancel_unknown_request is ignored without output');

  my $request = LinkedSpec::MCPContractRuntime::frame('discover_request');
  $cancel->{params}{requestId} = $request->{id};
  (undef, $output) = run_stream(test_server(), frame_bytes($request) . frame_bytes($cancel));
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_response_perl')), 'cancel_after_sync_completion cannot retract output');
  (undef, $output) = run_stream(test_server(), frame_bytes(LinkedSpec::MCPContractRuntime::frame('legacy_initialized_notification')));
  is($output, '', 'legacy_initialized_notification is ignored');
  unlike(frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_response_perl')), qr/[^\n]\z/, 'stdout_discipline ends its sole frame with LF');

  my $now = 1_000;
  $server = test_server(now_ref => \$now, max_handles => 1, entropy => [('D' x 32), ('E' x 32)]);
  $server->register_index($index, authorization_context => 'principal', lifetime_ms => 1);
  $now = 1_001;
  like($server->register_index($index, authorization_context => 'principal'), qr/\A[A-Za-z0-9_-]{43}\z/, 'registry_capacity prunes expired entries first');
  $server->shutdown;

  my $held_source = semantic_fixture_bytes('graph');
  my $held = LinkedSpec::semantic_index(\$held_source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
  my $weak = $held;
  weaken($weak);
  $server = test_server(entropy => [('F' x 32)]);
  $server->register_index($held, authorization_context => 'principal');
  undef $held;
  ($status, $output, $log) = run_stream($server, '', log => 1);
  is($status, 0, 'graceful_eof returns zero');
  ok(!defined($weak), 'graceful_eof clears and releases the registry');

  my ($output_bytes, $log_bytes) = ('', '');
  tie *ADMISSION_LIFECYCLE_INPUT, 'Local::AdmissionFailingInput';
  open my $output_handle, '>:raw', \$output_bytes or die "cannot open output: $!";
  open my $log_handle, '>:raw', \$log_bytes or die "cannot open log: $!";
  $server = test_server();
  $status = $server->serve_stdio(
   input => \*ADMISSION_LIFECYCLE_INPUT,
   output => $output_handle,
   authorization_context => 'principal',
   log => $log_handle,
  );
  close $output_handle or die "cannot close output: $!";
  close $log_handle or die "cannot close log: $!";
  untie *ADMISSION_LIFECYCLE_INPUT;
  is($status, 1, 'unexpected_io_failure returns nonzero');
  is($log_bytes, "linkedspec_mcp_io_failure\n", 'unexpected_io_failure emits only the fixed sanitized record');
 }
);

admission_role(
 'handle_state_indistinguishability',
 sub {
  my $expected = canonical(LinkedSpec::MCPContractRuntime::tool_error_response(11, 'handle_unavailable'));
  my $unknown = test_server();
  is(canonical($unknown->dispatch(
   LinkedSpec::MCPContractRuntime::frame('handle_unavailable_request'),
   authorization_context => 'principal',
  )), $expected, 'unknown handle is indistinguishable');
  $unknown->shutdown;

  my $now = 2_000;
  my $expired = test_server(now_ref => \$now, entropy => [('G' x 32)]);
  my $handle = $expired->register_index($index, authorization_context => 'principal', lifetime_ms => 1);
  $now = 2_001;
  is(canonical($expired->dispatch(with_handle('handle_unavailable_request', $handle), authorization_context => 'principal')), $expected, 'expired handle is indistinguishable');
  $expired->shutdown;

  my $revoked = test_server(entropy => [('H' x 32)]);
  $handle = $revoked->register_index($index, authorization_context => 'principal');
  $revoked->revoke_handle($handle);
  is(canonical($revoked->dispatch(with_handle('handle_unavailable_request', $handle), authorization_context => 'principal')), $expected, 'revoked handle is indistinguishable');
  $revoked->shutdown;

  my $unauthorized = test_server(entropy => [('I' x 32)]);
  $handle = $unauthorized->register_index($index, authorization_context => 'principal');
  is(canonical($unauthorized->dispatch(with_handle('handle_unavailable_request', $handle), authorization_context => 'wrong')), $expected, 'unauthorized handle is indistinguishable');
  $unauthorized->shutdown;
 }
);

admission_role(
 'policy_overlay',
 sub {
  my ($capability_calls, $query_calls) = (0, 0);
  no warnings 'redefine';
  local *LinkedSpec::SemanticIndex::capabilities = sub {
   ++$capability_calls;
   return $native_capabilities->(@_)
  };
  local *LinkedSpec::SemanticIndex::query = sub {
   ++$query_calls;
   return $native_query->(@_)
  };

  my $default = test_server(entropy => [('J' x 32)]);
  my $handle = $default->register_index($index, authorization_context => 'principal');
  my $before = $capability_calls;
  my $response = $default->dispatch(with_handle('capabilities_call_request', $handle), authorization_context => 'principal');
  is(canonical($response), canonical(LinkedSpec::MCPContractRuntime::frame('capabilities_call_response')), 'default_capabilities_identity is exact');
  is($capability_calls, $before + 1, 'default capabilities invoke native exactly once');
  my $query = with_handle('query_call_request', $handle);
  $before = $query_calls;
  $response = $default->dispatch($query, authorization_context => 'principal');
  is_deeply($response->{result}{structuredContent}, $index->query($query->{params}{arguments}{request}), 'allowed_query_identity is exact');
  is($query_calls, $before + 2, 'MCP and explicit comparison each invoke native once');
  $default->shutdown;

  my $restricted = test_server(entropy => [('K' x 32)]);
  $handle = $restricted->register_index(
   $index,
   authorization_context => 'principal',
   policy => {
    source_detail_ceiling => 'identity',
    page_max => 50,
    budget_maxima => {max_records => 100, max_relations => 200, max_depth => 2},
   },
  );
  $response = $restricted->dispatch(with_handle('restricted_capabilities_request', $handle), authorization_context => 'principal');
  my $projection = LinkedSpec::MCPContractRuntime::tool_success_response(
   10,
   LinkedSpec::MCPContractRuntime::payload('capabilities_restricted'),
  );
  is(canonical($response), canonical($projection), 'restricted_capabilities_projection is exact');
  my $denied = with_handle('policy_denied_request', $handle);
  $before = $query_calls;
  $response = $restricted->dispatch($denied, authorization_context => 'principal');
  is(canonical($response), canonical(LinkedSpec::MCPContractRuntime::frame('policy_denied_response')), 'above_policy_pre_dispatch_denial is exact');
  is($query_calls, $before, 'above-policy denial performs no native query');
  $restricted->shutdown;
 }
);

admission_role(
 'cancellation_emission',
 sub {
  my $server = test_server(entropy => [('L' x 32)]);
  my $handle = $server->register_index($index, authorization_context => 'principal');
  my $request = with_handle('capabilities_call_request', $handle);
  my ($response, $key) = $server->_dispatch_for_wire($request, authorization_context => 'principal');
  ok(defined($response) && $server->_wire_response_ready($key), 'prepared response remains active before emission');
  my $cancel = LinkedSpec::MCPContractRuntime::frame('cancelled_notification');
  $cancel->{params}{requestId} = $request->{id};
  $server->dispatch($cancel, authorization_context => 'principal');
  ok(!$server->_wire_response_ready($key), 'observed pre-emission cancellation suppresses readiness');
  $server->shutdown;

  $server = test_server(entropy => [('M' x 32)]);
  $handle = $server->register_index($index, authorization_context => 'principal');
  $request = with_handle('capabilities_call_request', $handle);
  (undef, my $output) = run_stream($server, frame_bytes($request) . frame_bytes($cancel));
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::frame('capabilities_call_response')), 'later cancellation cannot retract a flushed synchronous response');
 }
);

admission_role(
 'shutdown_and_io',
 sub {
  my $complete = frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_request'));
  my ($output_bytes, $log_bytes) = ('', '');
  tie *ADMISSION_PARTIAL_INPUT, 'Local::AdmissionChunkThenFail', $complete;
  open my $output, '>:raw', \$output_bytes or die "cannot open output: $!";
  open my $log, '>:raw', \$log_bytes or die "cannot open log: $!";
  my $server = test_server();
  my $status = $server->serve_stdio(
   input => \*ADMISSION_PARTIAL_INPUT,
   output => $output,
   authorization_context => 'principal',
   log => $log,
  );
  close $output or die "cannot close output: $!";
  close $log or die "cannot close log: $!";
  untie *ADMISSION_PARTIAL_INPUT;
  is($status, 1, 'input failure after a frame returns nonzero');
  is($output_bytes, frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_response_perl')), 'complete frame is flushed before later input failure');
  is($log_bytes, "linkedspec_mcp_io_failure\n", 'later input failure has one sanitized log');

  my $input_bytes = $complete;
  open my $input, '<:raw', \$input_bytes or die "cannot open input: $!";
  $log_bytes = '';
  open $log, '>:raw', \$log_bytes or die "cannot open log: $!";
  tie *ADMISSION_BROKEN_OUTPUT, 'Local::AdmissionFailingOutput';
  $server = test_server();
  $status = $server->serve_stdio(
   input => $input,
   output => \*ADMISSION_BROKEN_OUTPUT,
   authorization_context => 'principal',
   log => $log,
  );
  close $input or die "cannot close input: $!";
  close $log or die "cannot close log: $!";
  untie *ADMISSION_BROKEN_OUTPUT;
  is($status, 1, 'output failure returns nonzero');
  is($log_bytes, "linkedspec_mcp_io_failure\n", 'output failure has one sanitized log');
 }
);

admission_role(
 'hostile_output_and_log_privacy',
 sub {
  my $server = test_server(entropy => [('N' x 32)]);
  my $handle = $server->register_index($index, authorization_context => 'principal');
  my $request = with_handle('capabilities_call_request', $handle);
  $request->{id} = 20;
  my ($status, $output, $log);
  {
   no warnings 'redefine';
   local *LinkedSpec::SemanticIndex::capabilities = sub {
    die "host=/private/secret handle=$handle auth=principal source=graph.spec query=response"
   };
   ($status, $output, $log) = run_stream($server, frame_bytes($request), log => 1);
  }
  is($status, 0, 'sanitized native failure still reaches graceful EOF');
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::frame('sanitized_internal_error_response')), 'hostile native failure becomes the exact sanitized frame');
  is($log, '', 'native failure does not create an operational log channel');
  unlike($output . $log, qr/private|secret|handle=|principal|graph[.]spec|query=response/i, 'protocol and log bytes contain no hostile host detail');
 }
);

admission_role(
 'authority_surface_fences',
 sub {
  ok(LinkedSpec::MCPServer->can('register_index'), 'public server registers only an existing native index');
  ok(LinkedSpec::MCPServer->can('dispatch'), 'public decoded dispatch remains available');
  ok(LinkedSpec::MCPServer->can('serve_stdio'), 'public strict stdio adapter remains available');
  foreach my $forbidden (qw(load_source open_source compile execute trace cache semantic_index_from_path)) {
   ok(!LinkedSpec::MCPServer->can($forbidden), "public server exposes no $forbidden authority");
  }

  foreach my $path (
   [qw(perl LinkedSpec MCPContractRuntime.pm)],
   [qw(perl LinkedSpec MCPServer.pm)],
   [qw(perl LinkedSpec MCPWire.pm)],
  ) {
   my $relative = File::Spec->catfile(@$path);
   my $bytes = read_bytes(File::Spec->catfile($Bin, '..', @$path));
   unlike($bytes, qr/LinkedSpec::Get\s*\(|get_parser\s*\(|return_descriptor\s*\(|call_spec_handler|dump_parser_source|LINKEDSPEC_TRACE_LEVEL/, "$relative has no source/compile/execute/trace owner call");
  }
  my $server_source = read_bytes(File::Spec->catfile($Bin, '..', qw(perl LinkedSpec MCPServer.pm)));
  my @absolute_literals = $server_source =~ /['"](\/[A-Za-z0-9_.\/-]+)['"]/g;
  is_deeply(\@absolute_literals, ['/dev/urandom'], 'the sole absolute production input is documented OS entropy');
  my $primary = read_bytes(File::Spec->catfile($Bin, '..', qw(bin linkedspec)));
  unlike($primary, qr/MCPServer|serve_stdio/, 'primary parser CLI has no MCP bootstrap');
 }
);

is_deeply(\@roles_seen, \@ROLE_ORDER, 'all twelve exact admission roles execute once in order');
done_testing;

#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Encode qw(encode FB_CROAK LEAVE_SRC);
use File::Spec;
use FindBin qw($Bin);
use Scalar::Util qw(weaken);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::MCPContractRuntime ();
use LinkedSpec::MCPServer;

{
 package Local::FailingInput;
 use Errno qw(EIO);
 sub TIEHANDLE { return bless {}, shift }
 sub BINMODE { return 1 }
 sub READ { $! = EIO; return undef }
 sub FILENO { return -1 }
}

{
 package Local::FailingOutput;
 sub TIEHANDLE { return bless {}, shift }
 sub BINMODE { return 1 }
 sub PRINT { return 0 }
 sub FLUSH { return 1 }
 sub FILENO { return -1 }
}

{
 package Local::ChunkThenFailInput;
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

sub frame_bytes {
 return encode('UTF-8', canonical($_[0]), FB_CROAK | LEAVE_SRC) . "\n"
}

sub request_bytes {
 return frame_bytes($_[0])
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
 my (@entropy) = @_;
 @entropy = ('A' x 32) unless @entropy;
 my $last = $entropy[-1];
 return LinkedSpec::MCPServer->_new_for_test(
  entropy => sub { return @entropy ? shift(@entropy) : $last },
  now_ms => sub { return 10_000 },
 )
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

sub throws_code {
 my ($code, $label, $callback) = @_;
 my $ok = eval { $callback->(); 1 };
 my $error = $@;
 ok(!$ok, "$label fails closed");
 isa_ok($error, 'LinkedSpec::MCPServer::Error', "$label error");
 is($error->{code}, $code, "$label has the sanitized typed code");
 return
}

my $corpus = LinkedSpec::MCPContractRuntime::corpus();
my %raw_by_id = map { $_->{id} => $_ } @{$corpus->{raw_inputs}};
my @expected_raw_ids = qw(
 invalid_utf8 utf8_bom malformed_json duplicate_key overlong_line json_batch non_object
 invalid_boolean_id nesting_depth_65 valid_crlf_discovery
);
my @expected_lifecycle_ids = qw(
 ready_at_stream_loop_start cancel_before_response_emission cancel_unknown_request
 cancel_after_sync_completion legacy_initialized_notification stdout_discipline stderr_default
 registry_capacity graceful_eof unexpected_io_failure
);

subtest 'embedded raw and lifecycle inventories are exact' => sub {
 is_deeply([map { $_->{id} } @{$corpus->{raw_inputs}}], \@expected_raw_ids, 'all ten raw cases remain ordered');
 is_deeply([map { $_->{id} } @{$corpus->{lifecycle_cases}}], \@expected_lifecycle_ids, 'all ten lifecycle cases remain ordered');
};

subtest 'all ten neutral raw cases have exact wire outcomes' => sub {
 foreach my $id (@expected_raw_ids) {
  my ($status, $output, $log) = run_stream(test_server(), raw_fixture_bytes($raw_by_id{$id}));
  is($status, 0, "$id reaches graceful EOF");
  is($log, '', "$id emits no default log bytes");
  my $expected;
  if ($id eq 'valid_crlf_discovery') {
   $expected = frame_bytes(LinkedSpec::MCPContractRuntime::discover_response(1));
  } else {
   my $kind = $raw_by_id{$id}{expected}{code} == -32700 ? 'parse_error' : 'invalid_request';
   $expected = frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, $kind));
  }
  is($output, $expected, "$id emits the exact canonical contract bytes");
 }
};

subtest 'decoded-key, Unicode, depth, and line boundaries fail at the exact layer' => sub {
 my $discover = LinkedSpec::MCPContractRuntime::frame('discover_request');
 $discover->{id} = 1;
 my $base = canonical($discover);
 my @parse_errors = (
  ['escape-equivalent duplicate', '{"\\u0069d":1,"id":2,"jsonrpc":"2.0","method":"server/discover","params":{}}' . "\n"],
  ['nested duplicate', '{"id":1,"jsonrpc":"2.0","method":"server/discover","params":{"x":{"a":1,"\\u0061":2}}}' . "\n"],
  ['lone surrogate', '{"id":"\\uD800","jsonrpc":"2.0","method":"server/discover","params":{}}' . "\n"],
  ['non-finite number', '{"id":NaN,"jsonrpc":"2.0","method":"server/discover","params":{}}' . "\n"],
  ['empty line', "\n"],
 );
 foreach my $case (@parse_errors) {
  my (undef, $output) = run_stream(test_server(), $case->[1]);
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'parse_error')), "$case->[0] is a parse error");
 }

 my $depth_64 = ('[' x 64) . '0' . (']' x 64) . "\n";
 my (undef, $depth_output) = run_stream(test_server(), $depth_64);
 is($depth_output, frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'invalid_request')), 'depth 64 parses before non-object rejection');

 my $max_line = $base . (' ' x (1_048_576 - length($base))) . "\r\n";
 my (undef, $max_output) = run_stream(test_server(), $max_line);
 is($max_output, frame_bytes(LinkedSpec::MCPContractRuntime::discover_response(1)), 'exact maximum payload bytes plus CRLF are accepted');
};

subtest 'request ids retain lexical number kind, safe range, and UTF-8 byte limits' => sub {
 my @invalid = (
  ['fractional integer-lookalike', '1.0'],
  ['exponent integer-lookalike', '1e0'],
  ['positive unsafe integer', '9007199254740992'],
  ['negative unsafe integer', '-9007199254740992'],
  ['null id', 'null'],
 );
 foreach my $case (@invalid) {
  my $bytes = '{"id":' . $case->[1] . ',"jsonrpc":"2.0","method":"server/discover","params":{}}' . "\n";
  my (undef, $output) = run_stream(test_server(), $bytes);
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'invalid_request')), "$case->[0] returns invalid request with null id");
 }
 foreach my $id (-9_007_199_254_740_991, 9_007_199_254_740_991) {
  my $request = LinkedSpec::MCPContractRuntime::frame('discover_request');
  $request->{id} = $id;
  my (undef, $output) = run_stream(test_server(), request_bytes($request));
  is($output, frame_bytes(LinkedSpec::MCPContractRuntime::discover_response($id)), "safe endpoint id $id round-trips exactly");
 }
 my $accepted_id = 'é' x 64;
 my $accepted = LinkedSpec::MCPContractRuntime::frame('discover_request');
 $accepted->{id} = $accepted_id;
 my (undef, $accepted_output) = run_stream(test_server(), request_bytes($accepted));
 is($accepted_output, frame_bytes(LinkedSpec::MCPContractRuntime::discover_response($accepted_id)), '128-byte Unicode string id is accepted');
 unlike($accepted_output, qr/\\u00e9/i, 'canonical response preserves non-ASCII UTF-8');

 my $rejected_id = 'é' x 65;
 my $rejected = LinkedSpec::MCPContractRuntime::frame('discover_request');
 $rejected->{id} = $rejected_id;
 my (undef, $rejected_output) = run_stream(test_server(), request_bytes($rejected));
 is($rejected_output, frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'invalid_request')), '130-byte Unicode string id is rejected with null id');
};

subtest 'stream is ready immediately and emits only canonical LF frames' => sub {
 my $first = LinkedSpec::MCPContractRuntime::frame('discover_request');
 $first->{id} = 'réq';
 my $list = LinkedSpec::MCPContractRuntime::frame('tools_list_request');
 my $input = request_bytes($first) . request_bytes($list)
  . request_bytes(LinkedSpec::MCPContractRuntime::frame('legacy_initialized_notification'));
 my ($status, $output, $log) = run_stream(test_server(), $input, log => 1);
 my $expected = frame_bytes(LinkedSpec::MCPContractRuntime::discover_response('réq'))
  . frame_bytes(LinkedSpec::MCPContractRuntime::tools_list_response($list->{id}));
 is($status, 0, 'first modern request dispatches without handshake and EOF is graceful');
 is($output, $expected, 'two requests emit exactly two ordered canonical frames');
 unlike($output, qr/\r/, 'output uses LF rather than CRLF');
 unlike($output, qr/\\u00e9/i, 'output keeps non-ASCII text as UTF-8');
 is($log, '', 'normal stream and graceful EOF remain silent even with a log handle');

 my $unterminated = encode('UTF-8', canonical($first), FB_CROAK | LEAVE_SRC);
 my (undef, $unterminated_output) = run_stream(test_server(), $unterminated);
 is($unterminated_output, frame_bytes(LinkedSpec::MCPContractRuntime::discover_response('réq')), 'EOF processes one complete final frame without a delimiter');

 my $parse_then_valid = "{\n" . request_bytes($list);
 my (undef, $continued_output) = run_stream(test_server(), $parse_then_valid);
 is(
  $continued_output,
  frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'parse_error'))
   . frame_bytes(LinkedSpec::MCPContractRuntime::tools_list_response($list->{id})),
  'a rejected frame is drained exactly and the next complete frame still dispatches',
 );

 my $overlong_then_valid = ('x' x 1_048_577) . "\n" . request_bytes($list);
 my (undef, $overlong_output) = run_stream(test_server(), $overlong_then_valid);
 is(
  $overlong_output,
  frame_bytes(LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'parse_error'))
   . frame_bytes(LinkedSpec::MCPContractRuntime::tools_list_response($list->{id})),
  'an overlong frame is memory-bounded, drained, and followed by valid dispatch',
 );
};

my $source = read_bytes(File::Spec->catfile(
 $Bin,
 '..',
 qw(capability_conformance semantic_introspection graph.spec),
));

subtest 'prepared cancellation is suppressed while later cancellation cannot retract output' => sub {
 my $original_capabilities = LinkedSpec::SemanticIndex->can('capabilities');
 my $index = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 my $prepared_server = test_server('I' x 32);
 my $prepared_handle = $prepared_server->register_index($index, authorization_context => 'principal');
 my $prepared_request = with_handle('capabilities_call_request', $prepared_handle);
 my ($prepared_response, $prepared_key) = $prepared_server->_dispatch_for_wire(
  $prepared_request,
  authorization_context => 'principal',
 );
 ok(defined($prepared_response) && defined($prepared_key), 'wire dispatch retains a prepared response until emission');
 my $prepared_cancel = LinkedSpec::MCPContractRuntime::frame('cancelled_notification');
 $prepared_cancel->{params}{requestId} = $prepared_request->{id};
 $prepared_server->dispatch($prepared_cancel, authorization_context => 'principal');
 ok(!$prepared_server->_wire_response_ready($prepared_key), 'cancellation in the preparation/emission interval suppresses readiness');
 $prepared_server->shutdown;

 my $server = test_server('B' x 32);
 my $handle = $server->register_index($index, authorization_context => 'principal');
 my $request = with_handle('capabilities_call_request', $handle);
 my $cancel = LinkedSpec::MCPContractRuntime::frame('cancelled_notification');
 $cancel->{params}{requestId} = $request->{id};
 {
  no warnings 'redefine';
  local *LinkedSpec::SemanticIndex::capabilities = sub {
   $server->dispatch($cancel, authorization_context => 'principal');
   return $original_capabilities->(@_)
  };
  my ($status, $output) = run_stream($server, request_bytes($request));
  is($status, 0, 'reentrant cancellation still reaches graceful EOF');
  is($output, '', 'cancellation observed before emission suppresses the prepared frame');
 }

 $index = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 $server = test_server('C' x 32);
 $handle = $server->register_index($index, authorization_context => 'principal');
 $request = with_handle('capabilities_call_request', $handle);
 $cancel->{params}{requestId} = $request->{id};
 my ($status, $output) = run_stream($server, request_bytes($request) . request_bytes($cancel));
 is($status, 0, 'request then cancellation reaches graceful EOF');
 is($output, frame_bytes(LinkedSpec::MCPContractRuntime::frame('capabilities_call_response')), 'synchronous response emitted before the next cancellation remains valid');

 my $unknown = LinkedSpec::MCPContractRuntime::frame('cancelled_notification');
 $unknown->{params}{requestId} = 'unknown';
 my (undef, $unknown_output) = run_stream(test_server(), request_bytes($unknown));
 is($unknown_output, '', 'unknown cancellation is ignored without output');
};

subtest 'wire tool calls preserve exact decoded and native payload identity' => sub {
 my $index = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 my $server = test_server('J' x 32);
 my $handle = $server->register_index($index, authorization_context => 'principal');
 my $capabilities = with_handle('capabilities_call_request', $handle);
 my $query = with_handle('query_call_request', $handle);
 my ($status, $output, $log) = run_stream(
  $server,
  request_bytes($capabilities) . request_bytes($query),
  log => 1,
 );
 my $expected_query = LinkedSpec::MCPContractRuntime::tool_success_response(
  $query->{id},
  LinkedSpec::MCPContractRuntime::payload('graph_list_rules'),
 );
 is($status, 0, 'two authorized tool calls complete and shut down cleanly');
 is(
  $output,
  frame_bytes(LinkedSpec::MCPContractRuntime::frame('capabilities_call_response'))
   . frame_bytes($expected_query),
  'wire capabilities/query bytes equal their exact decoded/native Perl responses',
 );
 is($log, '', 'authorized tool dispatch remains operationally silent');
};

subtest 'registry capacity remains prune-first under the lifecycle composition' => sub {
 my $now = 1_000;
 my @entropy = ('D' x 32, 'E' x 32);
 my $server = LinkedSpec::MCPServer->_new_for_test(
  entropy => sub { shift @entropy },
  now_ms => sub { $now },
  max_handles => 1,
 );
 my $first = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 my $second = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 $server->register_index($first, authorization_context => 'principal', lifetime_ms => 1);
 $now = 1_001;
 like($server->register_index($second, authorization_context => 'principal'), qr/\A[A-Za-z0-9_-]{43}\z/, 'expired entry is pruned before capacity refusal');
 $server->shutdown;
};

subtest 'EOF and I/O failures release indexes with silent or sanitized channels' => sub {
 my $index = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 my $weak = $index;
 weaken($weak);
 my $server = test_server('F' x 32);
 $server->register_index($index, authorization_context => 'principal');
 undef $index;
 ok(defined($weak), 'registry retains the index before EOF');
 my ($status, $output, $log) = run_stream($server, '', log => 1);
 is($status, 0, 'clean EOF returns zero');
 is($output, '', 'clean EOF emits no protocol bytes');
 is($log, '', 'clean EOF emits no operational log');
 ok(!defined($weak), 'clean EOF releases the retained index');

 $index = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 $weak = $index;
 weaken($weak);
 $server = test_server('G' x 32);
 $server->register_index($index, authorization_context => 'principal');
 undef $index;
 my ($output_bytes, $log_bytes) = ('', '');
 tie *BROKEN_INPUT, 'Local::FailingInput';
 open my $output_handle, '>:raw', \$output_bytes or die "cannot open output: $!";
 open my $log_handle, '>:raw', \$log_bytes or die "cannot open log: $!";
 $status = $server->serve_stdio(
  input => \*BROKEN_INPUT,
  output => $output_handle,
  authorization_context => 'principal',
  log => $log_handle,
 );
 close $output_handle or die "cannot close output: $!";
 close $log_handle or die "cannot close log: $!";
 untie *BROKEN_INPUT;
 is($status, 1, 'input failure returns nonzero');
 is($output_bytes, '', 'input failure emits no protocol bytes');
 is($log_bytes, "linkedspec_mcp_io_failure\n", 'input failure emits one fixed sanitized log record');
 ok(!defined($weak), 'input failure releases the retained index');

 my $complete_request = request_bytes(LinkedSpec::MCPContractRuntime::frame('discover_request'));
 $output_bytes = '';
 $log_bytes = '';
 tie *PARTIAL_INPUT, 'Local::ChunkThenFailInput', $complete_request;
 open $output_handle, '>:raw', \$output_bytes or die "cannot open output: $!";
 open $log_handle, '>:raw', \$log_bytes or die "cannot open log: $!";
 $server = test_server();
 $status = $server->serve_stdio(
  input => \*PARTIAL_INPUT,
  output => $output_handle,
  authorization_context => 'principal',
  log => $log_handle,
 );
 close $output_handle or die "cannot close output: $!";
 close $log_handle or die "cannot close log: $!";
 untie *PARTIAL_INPUT;
 is($status, 1, 'input failure after a complete frame returns nonzero');
 is($output_bytes, frame_bytes(LinkedSpec::MCPContractRuntime::frame('discover_response_perl')), 'complete response remains flushed before a later input failure');
 is($log_bytes, "linkedspec_mcp_io_failure\n", 'later input failure still emits only one fixed log record');

 $index = LinkedSpec::semantic_index(\$source, logical_name => 'graph.spec', source_detail_ceiling => 'text');
 $weak = $index;
 weaken($weak);
 $server = test_server('H' x 32);
 $server->register_index($index, authorization_context => 'principal');
 undef $index;
 my $input_bytes = request_bytes(LinkedSpec::MCPContractRuntime::frame('discover_request'));
 open my $input_handle, '<:raw', \$input_bytes or die "cannot open input: $!";
 $log_bytes = '';
 open $log_handle, '>:raw', \$log_bytes or die "cannot open log: $!";
 tie *BROKEN_OUTPUT, 'Local::FailingOutput';
 $status = $server->serve_stdio(
  input => $input_handle,
  output => \*BROKEN_OUTPUT,
  authorization_context => 'principal',
  log => $log_handle,
 );
 close $input_handle or die "cannot close input: $!";
 close $log_handle or die "cannot close log: $!";
 untie *BROKEN_OUTPUT;
 is($status, 1, 'output failure returns nonzero');
 is($log_bytes, "linkedspec_mcp_io_failure\n", 'output failure emits one fixed sanitized log record');
 ok(!defined($weak), 'output failure releases the retained index');
 unlike($log_bytes, qr/graph|handle|principal|source|request|response|path|object|exception/i, 'sanitized log carries no private classification or content');
};

subtest 'public stdio options reject missing or aliased authority' => sub {
 my $server = test_server();
 my ($input_bytes, $output_bytes) = ('', '');
 open my $input, '<:raw', \$input_bytes or die "cannot open input: $!";
 open my $output, '>:raw', \$output_bytes or die "cannot open output: $!";
 throws_code('linkedspec_mcp_invalid_stdio', 'missing output', sub {
  $server->serve_stdio(input => $input, authorization_context => 'principal')
 });
 throws_code('linkedspec_mcp_invalid_stdio', 'protocol/log alias', sub {
  $server->serve_stdio(
   input => $input,
   output => $output,
   log => $output,
   authorization_context => 'principal',
  )
 });
 throws_code('linkedspec_mcp_invalid_options', 'unsupported stdio option', sub {
  $server->serve_stdio(
   input => $input,
   output => $output,
   authorization_context => 'principal',
   source_path => 'forbidden.spec',
  )
 });
 close $input or die "cannot close input: $!";
 close $output or die "cannot close output: $!";
 $server->shutdown;
};

done_testing;

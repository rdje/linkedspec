#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use File::Spec;
use FindBin qw($Bin);
use Scalar::Util qw(weaken);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::MCPContractRuntime ();
use LinkedSpec::MCPServer;

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

sub clone_frame {
 return LinkedSpec::MCPContractRuntime::frame($_[0])
}

sub canonical {
 return LinkedSpec::MCPContractRuntime::canonical_json($_[0])
}

sub with_handle {
 my ($frame_id, $handle) = @_;
 my $request = clone_frame($frame_id);
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
 return $error
}

my $source = read_bytes(File::Spec->catfile(
 $Bin,
 '..',
 qw(capability_conformance semantic_introspection graph.spec),
));
my $index = LinkedSpec::semantic_index(
 \$source,
 logical_name => 'graph.spec',
 source_detail_ceiling => 'text',
);
my $identity_index = LinkedSpec::semantic_index(
 \$source,
 logical_name => 'graph.spec',
 source_detail_ceiling => 'identity',
);
my $original_capabilities = LinkedSpec::SemanticIndex->can('capabilities');
my $original_query = LinkedSpec::SemanticIndex->can('query');
my ($capability_calls, $query_calls) = (0, 0);
my @servers;

sub test_server {
 my (%args) = @_;
 my $now_ref = $args{now_ref} || do { my $now = 1_000; \$now };
 my @entropy = @{$args{entropy} || [("A" x 32)]};
 my $last = @entropy ? $entropy[-1] : ("A" x 32);
 my @options = (
  entropy => sub { return @entropy ? shift(@entropy) : $last },
  now_ms => sub { return $$now_ref },
 );
 push @options, max_handles => $args{max_handles} if exists $args{max_handles};
 push @options, handle_attempts => $args{handle_attempts} if exists $args{handle_attempts};
 my $server = LinkedSpec::MCPServer->_new_for_test(@options);
 push @servers, $server;
 return ($server, $now_ref)
}

{
 no warnings 'redefine';
 local *LinkedSpec::SemanticIndex::capabilities = sub {
  ++$capability_calls;
  return $original_capabilities->(@_)
 };
 local *LinkedSpec::SemanticIndex::query = sub {
  ++$query_calls;
  return $original_query->(@_)
 };

 subtest 'public construction and exact decoded static dispatch' => sub {
  my $server = LinkedSpec::MCPServer->new;
  push @servers, $server;
  throws_code(
   'linkedspec_mcp_invalid_constructor',
   'production dependency injection',
   sub { LinkedSpec::MCPServer->new(entropy => sub { 'x' x 32 }) },
  );
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
   my ($request_id, $response_id) = @$case;
   is(
    canonical($server->dispatch(clone_frame($request_id), authorization_context => 'auth')),
    canonical(clone_frame($response_id)),
    "$request_id produces the exact canonical response",
   );
  }
  is($server->dispatch(clone_frame('legacy_initialized_notification'), authorization_context => 'auth'), undef, 'legacy initialized notification is ignored');
  my $unknown_notification = {jsonrpc => '2.0', method => 'notifications/host_private'};
  is($server->dispatch($unknown_notification, authorization_context => 'auth'), undef, 'unknown notification is ignored without response');
 };

 subtest 'default capabilities and query retain direct native identity' => sub {
  my ($server) = test_server(entropy => [('B' x 32)]);
  my $before_registration = $capability_calls;
  my $handle = $server->register_index($index, authorization_context => 'principal');
  like($handle, qr/\A[A-Za-z0-9_-]{43}\z/, 'registration returns an exact unpadded 256-bit handle');
  is($capability_calls, $before_registration + 1, 'registration validates capabilities exactly once');

  my $request = with_handle('capabilities_call_request', $handle);
  my $before_call = $capability_calls;
  my $response = $server->dispatch($request, authorization_context => 'principal');
  is(canonical($response), canonical(clone_frame('capabilities_call_response')), 'default capabilities response is exact');
  is($capability_calls, $before_call + 1, 'capabilities tool invokes native capabilities once');

  $request = with_handle('query_call_request', $handle);
  my $request_before = canonical($request->{params}{arguments}{request});
  my $before_query = $query_calls;
  $response = $server->dispatch($request, authorization_context => 'principal');
  my $expected = LinkedSpec::MCPContractRuntime::tool_success_response(
   8,
   LinkedSpec::MCPContractRuntime::payload('graph_list_rules'),
  );
  is(canonical($response), canonical($expected), 'allowed query preserves the exact native payload in the Perl result shell');
  is($query_calls, $before_query + 1, 'allowed query invokes native query once');
  is(canonical($request->{params}{arguments}{request}), $request_before, 'server does not mutate the caller query');
 };

 subtest 'omitted and partial overlays preserve native portable diagnostics' => sub {
  my ($default_server) = test_server(entropy => [('b' x 32)]);
  my $default_handle = $default_server->register_index(
   $identity_index,
   authorization_context => 'default-policy-principal',
  );
  my $source_request = with_handle('query_call_request', $default_handle);
  $source_request->{params}{arguments}{request}{source}{detail} = 'span';
  my $before = $query_calls;
  my $source_response = $default_server->dispatch(
   $source_request,
   authorization_context => 'default-policy-principal',
  );
  is(
   $source_response->{result}{structuredContent}{diagnostics}[0]{code},
   'semantic_query_source_detail_forbidden',
   'an omitted source overlay preserves the native source-ceiling diagnostic',
  );
  is($query_calls, $before + 1, 'default source ceiling dispatches exactly one native query');

  my $unsupported = with_handle('query_call_request', $default_handle);
  $unsupported->{params}{arguments}{request}{contract} = 'linkedspec-semantic-query-v2';
  $before = $query_calls;
  my $unsupported_response = $default_server->dispatch(
   $unsupported,
   authorization_context => 'default-policy-principal',
  );
  is(
   $unsupported_response->{result}{structuredContent}{diagnostics}[0]{code},
   'semantic_query_contract_unsupported',
   'a bounded future contract reaches the native portable diagnostic',
  );
  is($query_calls, $before + 1, 'unsupported contract dispatches exactly one native query');

  my ($partial_server) = test_server(entropy => [('c' x 32)]);
  my $partial_handle = $partial_server->register_index(
   $identity_index,
   authorization_context => 'partial-policy-principal',
   policy => {page_max => 50},
  );
  my $partial_request = with_handle('query_call_request', $partial_handle);
  $partial_request->{params}{arguments}{request}{page}{limit} = 50;
  $partial_request->{params}{arguments}{request}{source}{detail} = 'span';
  $before = $query_calls;
  my $partial_response = $partial_server->dispatch(
   $partial_request,
   authorization_context => 'partial-policy-principal',
  );
  is(
   $partial_response->{result}{structuredContent}{diagnostics}[0]{code},
   'semantic_query_source_detail_forbidden',
   'a page-only overlay does not preempt the native source diagnostic',
  );
  is($query_calls, $before + 1, 'partial unrelated overlay dispatches exactly one native query');
 };

 subtest 'lowering-only policy projects capabilities and denies every ceiling pre-dispatch' => sub {
  my ($server) = test_server(entropy => [('C' x 32)]);
  my $handle = $server->register_index(
   $index,
   authorization_context => 'policy-principal',
   policy => {
    source_detail_ceiling => 'identity',
    page_max => 50,
    budget_maxima => {max_records => 100, max_relations => 200, max_depth => 2},
   },
  );
  my $request = with_handle('restricted_capabilities_request', $handle);
  my $response = $server->dispatch($request, authorization_context => 'policy-principal');
  my $expected = LinkedSpec::MCPContractRuntime::tool_success_response(
   10,
   LinkedSpec::MCPContractRuntime::payload('capabilities_restricted'),
  );
  is(canonical($response), canonical($expected), 'restricted capabilities are the exact schema-preserving projection');

  my $base = with_handle('query_call_request', $handle);
  $base->{params}{arguments}{request}{page}{limit} = 50;
  $base->{params}{arguments}{request}{budget} = {
   max_records => 100,
   max_relations => 200,
   max_depth => 2,
  };
  my @denied;
  my $source_case = LinkedSpec::MCPContractRuntime::clone_data($base);
  $source_case->{params}{arguments}{request}{source}{detail} = 'span';
  push @denied, ['source detail', $source_case];
  my $digest_case = LinkedSpec::MCPContractRuntime::clone_data($base);
  $digest_case->{params}{arguments}{request}{source}{include_content_digest} = JSON::PP::true;
  push @denied, ['content digest', $digest_case];
  my $page_case = LinkedSpec::MCPContractRuntime::clone_data($base);
  $page_case->{params}{arguments}{request}{page}{limit} = 51;
  push @denied, ['page', $page_case];
  foreach my $row ([max_records => 101], [max_relations => 201], [max_depth => 3]) {
   my $budget_case = LinkedSpec::MCPContractRuntime::clone_data($base);
   $budget_case->{params}{arguments}{request}{budget}{$row->[0]} = $row->[1];
   push @denied, [$row->[0], $budget_case];
  }
  foreach my $row (@denied) {
   my $before = $query_calls;
   my $denied_response = $server->dispatch($row->[1], authorization_context => 'policy-principal');
   my $denied_expected = LinkedSpec::MCPContractRuntime::tool_error_response(8, 'policy_denied');
   is(canonical($denied_response), canonical($denied_expected), "$row->[0] ceiling returns the exact policy error");
   is($query_calls, $before, "$row->[0] ceiling is denied before native query");
  }
  foreach my $invalid (
   {source_detail_ceiling => 'host'},
   {source_detail_ceiling => 'text', extra => 1},
   {page_max => 1001},
   {budget_maxima => {max_records => 10001}},
   {budget_maxima => {host_budget => 1}},
  ) {
   throws_code(
    'linkedspec_mcp_invalid_policy',
    'invalid or elevating policy',
    sub { $server->register_index($index, authorization_context => 'policy-principal', policy => $invalid) },
   );
  }
 };

 subtest 'unknown, expired, revoked, and unauthorized handles are externally identical' => sub {
  my $expected = LinkedSpec::MCPContractRuntime::tool_error_response(11, 'handle_unavailable');
  my $unknown_request = clone_frame('handle_unavailable_request');
  my ($unknown_server) = test_server(entropy => [('D' x 32)]);
  my $before = $capability_calls;
  is(canonical($unknown_server->dispatch($unknown_request, authorization_context => 'principal')), canonical($expected), 'unknown handle is unavailable');
  is($capability_calls, $before, 'unknown handle performs no native dispatch');

  my ($unauthorized_server) = test_server(entropy => [('E' x 32)]);
  my $unauthorized = $unauthorized_server->register_index($index, authorization_context => 'principal');
  is(canonical($unauthorized_server->dispatch(with_handle('handle_unavailable_request', $unauthorized), authorization_context => 'wrong')), canonical($expected), 'unauthorized handle is unavailable');

  my $expired_now = 1_000;
  my ($expired_server) = test_server(entropy => [('F' x 32)], now_ref => \$expired_now);
  my $expired = $expired_server->register_index($index, authorization_context => 'principal', lifetime_ms => 1);
  $expired_now = 1_001;
  is(canonical($expired_server->dispatch(with_handle('handle_unavailable_request', $expired), authorization_context => 'principal')), canonical($expected), 'expired handle is unavailable');

  my ($revoked_server) = test_server(entropy => [('G' x 32)]);
  my $revoked = $revoked_server->register_index($index, authorization_context => 'principal');
  is($revoked_server->revoke_handle($revoked), 1, 'host revocation succeeds');
  is($revoked_server->revoke_handle($revoked), 1, 'repeated revocation does not classify the handle');
  is(canonical($revoked_server->dispatch(with_handle('handle_unavailable_request', $revoked), authorization_context => 'principal')), canonical($expected), 'revoked handle is unavailable');
 };

 subtest 'entropy, clock, authorization, lifetime, collision, and capacity fail closed' => sub {
  my ($short_entropy) = test_server(entropy => [('x' x 31)]);
  throws_code('linkedspec_mcp_entropy_failure', 'short entropy', sub {
   $short_entropy->register_index($index, authorization_context => 'principal')
  });
  my $bad_clock = LinkedSpec::MCPServer->_new_for_test(
   entropy => sub { 'H' x 32 },
   now_ms => sub { die 'host path /private/secret' },
  );
  push @servers, $bad_clock;
  throws_code('linkedspec_mcp_clock_failure', 'clock failure', sub {
   $bad_clock->register_index($index, authorization_context => 'principal')
  });
  my ($collision) = test_server(
   entropy => [('I' x 32), ('I' x 32), ('I' x 32)],
   max_handles => 2,
   handle_attempts => 2,
  );
  $collision->register_index($index, authorization_context => 'principal');
  throws_code('linkedspec_mcp_entropy_failure', 'bounded handle collision', sub {
   $collision->register_index($index, authorization_context => 'principal')
  });

  my $capacity_now = 2_000;
  my ($capacity) = test_server(
   entropy => [('J' x 32), ('K' x 32)],
   now_ref => \$capacity_now,
   max_handles => 1,
  );
  $capacity->register_index($index, authorization_context => 'principal', lifetime_ms => 1);
  my $before_capacity = $capability_calls;
  throws_code('linkedspec_mcp_registry_full', 'live registry capacity', sub {
   $capacity->register_index($index, authorization_context => 'principal')
  });
  is($capability_calls, $before_capacity, 'capacity refusal occurs before native validation');
  $capacity_now = 2_001;
  like($capacity->register_index($index, authorization_context => 'principal'), qr/\A[A-Za-z0-9_-]{43}\z/, 'expired entries are pruned before capacity refusal');

  my ($validation) = test_server(entropy => [('L' x 32)]);
  throws_code('linkedspec_mcp_invalid_authorization', 'empty authorization', sub {
   $validation->register_index($index, authorization_context => '')
  });
  throws_code('linkedspec_mcp_invalid_authorization', 'oversize authorization', sub {
   $validation->register_index($index, authorization_context => ('x' x 4097))
  });
  throws_code('linkedspec_mcp_invalid_registration', 'zero lifetime', sub {
   $validation->register_index($index, authorization_context => 'principal', lifetime_ms => 0)
  });
  throws_code('linkedspec_mcp_invalid_index', 'non-native index', sub {
   $validation->register_index({}, authorization_context => 'principal')
  });

  my $production = LinkedSpec::MCPServer->new;
  push @servers, $production;
  like($production->register_index($index, authorization_context => 'principal'), qr/\A[A-Za-z0-9_-]{43}\z/, 'production registration obtains an exact OS-entropy handle');
 };

 subtest 'unexpected native failures are sanitized and prepared responses honor cancellation' => sub {
  my ($server) = test_server(entropy => [('M' x 32)]);
  my $handle = $server->register_index($index, authorization_context => 'principal');
  my $request = with_handle('capabilities_call_request', $handle);
  {
   local *LinkedSpec::SemanticIndex::capabilities = sub { die 'host secret /private/path' };
   my $response = $server->dispatch($request, authorization_context => 'principal');
   my $expected = LinkedSpec::MCPContractRuntime::json_rpc_error(7, 'internal_error');
   is(canonical($response), canonical($expected), 'unexpected native exception becomes the exact internal error');
   unlike(canonical($response), qr/host secret|private|path/, 'internal response leaks no host exception text');
  }
  {
   local *LinkedSpec::SemanticIndex::capabilities = sub { return {host_private => 1} };
   my $expected = LinkedSpec::MCPContractRuntime::json_rpc_error(7, 'internal_error');
   is(canonical($server->dispatch($request, authorization_context => 'principal')), canonical($expected), 'invalid native response becomes the exact internal error');
  }
  my $cancel = clone_frame('cancelled_notification');
  $cancel->{params}{requestId} = 7;
  {
   local *LinkedSpec::SemanticIndex::capabilities = sub {
    $server->dispatch($cancel, authorization_context => 'principal');
    return $original_capabilities->(@_)
   };
   is($server->dispatch($request, authorization_context => 'principal'), undef, 'cancellation observed before emission suppresses the prepared response');
  }
  my $completed = $server->dispatch($request, authorization_context => 'principal');
  ok(defined($completed), 'ordinary synchronous response completes');
  is($server->dispatch($cancel, authorization_context => 'principal'), undef, 'cancellation after completion is ignored');
  is(canonical($completed), canonical(clone_frame('capabilities_call_response')), 'completed response remains valid after later cancellation');
  $cancel->{params}{requestId} = 'unknown-request';
  is($server->dispatch($cancel, authorization_context => 'principal'), undef, 'unknown cancellation is ignored');
 };
}

subtest 'shutdown is idempotent and releases retained native indexes' => sub {
 my $weak = $index;
 weaken($weak);
 undef $index;
 ok(defined($weak), 'registries retain the live native index before shutdown');
 foreach my $server (@servers) {
  is($server->shutdown, 1, 'shutdown succeeds');
  is($server->shutdown, 1, 'shutdown is idempotent');
 }
 ok(!defined($weak), 'shutdown releases every retained native index reference');
 my ($stopped) = @servers;
 my $response = $stopped->dispatch(clone_frame('discover_request'), authorization_context => 'principal');
 is($response->{error}{code}, -32603, 'stopped server accepts no new work');
};

done_testing;

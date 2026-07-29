#------------------------------------------------------------------------------
# Package: LinkedSpec::MCPServer
# Purpose: Own the secure in-process Perl MCP handle registry and decoded
#          discovery/list/tool/cancellation dispatch over SemanticIndex.
#------------------------------------------------------------------------------
package LinkedSpec::MCPServer;

use 5.010;
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256);
use Errno qw(EINTR);
use Fcntl qw(O_RDONLY);
use JSON::PP ();
use MIME::Base64 qw(encode_base64url);
use Scalar::Util qw(looks_like_number refaddr);
use Time::HiRes qw(CLOCK_MONOTONIC clock_gettime);

use LinkedSpec::MCPContractRuntime ();
use LinkedSpec::SemanticIndex ();

my %STATE_BY_ADDRESS;
my %SOURCE_RANK = (none => 0, identity => 1, span => 2, text => 3);
my $DUMMY_AUTH_DIGEST = "\0" x 32;
my $HANDLE_ATTEMPTS = 16;
my $CONTRACT_PROFILE = LinkedSpec::MCPContractRuntime::contract();
my $REGISTRY_PROFILE = $CONTRACT_PROFILE->{handle_registry};
my $ENTROPY_BYTES = int($REGISTRY_PROFILE->{entropy_bits} / 8);
my $HANDLE_CHARACTERS = $REGISTRY_PROFILE->{encoded_characters};

{
 package LinkedSpec::MCPServer::Error;
 use overload '""' => sub { $_[0]{code} . ': ' . $_[0]{message} }, fallback => 1;
}

sub new {
 my ($class, @args) = @_;
 _throw('linkedspec_mcp_invalid_constructor', 'Production MCP construction accepts no arguments.') if @args;
 return _construct($class, {
  entropy => \&_os_entropy,
  now_ms => \&_monotonic_ms,
  max_handles => $REGISTRY_PROFILE->{default_maximum_live_handles},
 })
}

# Private by name and intentionally absent from the documented host surface.
sub _new_for_test {
 my ($class, @pairs) = @_;
 my $options = _options(
  'test constructor',
  {map { $_ => 1 } qw(entropy now_ms max_handles handle_attempts)},
  @pairs,
 );
 _throw('linkedspec_mcp_invalid_constructor', 'Test entropy must be a callback.')
  unless ref($options->{entropy}) eq 'CODE';
 _throw('linkedspec_mcp_invalid_constructor', 'Test monotonic time must be a callback.')
  unless ref($options->{now_ms}) eq 'CODE';
 my $maximum = exists($options->{max_handles})
  ? $options->{max_handles}
  : $REGISTRY_PROFILE->{default_maximum_live_handles};
 _throw('linkedspec_mcp_invalid_constructor', 'Test registry capacity must be a positive integer.')
  unless _is_integer($maximum) && $maximum >= 1
   && $maximum <= $REGISTRY_PROFILE->{default_maximum_live_handles};
 my $attempts = exists($options->{handle_attempts}) ? $options->{handle_attempts} : $HANDLE_ATTEMPTS;
 _throw('linkedspec_mcp_invalid_constructor', 'Test collision bound must be a positive integer.')
  unless _is_integer($attempts) && $attempts >= 1 && $attempts <= $HANDLE_ATTEMPTS;
 return _construct($class, {
  entropy => $options->{entropy},
  now_ms => $options->{now_ms},
  max_handles => 0 + $maximum,
  handle_attempts => 0 + $attempts,
 })
}

sub _construct {
 my ($class, $dependencies) = @_;
 my $token = 0;
 my $self = bless \$token, $class;
 $STATE_BY_ADDRESS{refaddr($self)} = {
  entries => {},
  active => {},
  stopped => 0,
  entropy => $dependencies->{entropy},
  now_ms => $dependencies->{now_ms},
  max_handles => $dependencies->{max_handles},
  handle_attempts => $dependencies->{handle_attempts} || $HANDLE_ATTEMPTS,
 };
 return $self
}

sub register_index {
 my ($self, $index, @pairs) = @_;
 my $state = _state($self);
 _throw('linkedspec_mcp_server_shutdown', 'The MCP server has shut down.') if $state->{stopped};
 _throw('linkedspec_mcp_invalid_index', 'MCP registration requires a native Perl semantic index.')
  unless ref($index) eq 'LinkedSpec::SemanticIndex';
 my $options = _options(
  'registration',
  {map { $_ => 1 } qw(authorization_context lifetime_ms policy)},
  @pairs,
 );
 _throw('linkedspec_mcp_invalid_registration', 'Registration requires an authorization context.')
  unless exists $options->{authorization_context};
 my $authorization = _authorization_bytes($options->{authorization_context});
 my $lifetime = exists($options->{lifetime_ms})
  ? $options->{lifetime_ms}
  : $REGISTRY_PROFILE->{default_lifetime_ms};
 _throw('linkedspec_mcp_invalid_registration', 'Registration lifetime is outside the contract bounds.')
  unless _is_integer($lifetime) && $lifetime >= 1
   && $lifetime <= $REGISTRY_PROFILE->{maximum_lifetime_ms};
 my $now = _now_ms($state);
 _prune_expired($state, $now);
 _throw('linkedspec_mcp_registry_full', 'The MCP handle registry is at capacity.')
  if keys(%{$state->{entries}}) >= $state->{max_handles};

 my $capabilities = eval { $index->capabilities };
 _throw('linkedspec_mcp_invalid_index', 'The semantic index did not provide valid capabilities.')
  if $@ || !LinkedSpec::MCPContractRuntime::validate_named('semanticQueryResponse', $capabilities);
 my $native = _native_limits($capabilities);
 my $policy = _effective_policy($options->{policy}, $native);
 my $handle = _unique_handle($state);
 $state->{entries}{$handle} = {
  index => $index,
  auth_digest => sha256($authorization),
  expires_ms => $now + $lifetime,
  policy => $policy,
 };
 return $handle
}

sub revoke_handle {
 my ($self, $handle) = @_;
 my $state = _state($self);
 _throw('linkedspec_mcp_invalid_handle', 'MCP handle syntax is invalid.') unless _valid_handle($handle);
 delete $state->{entries}{$handle};
 return 1
}

sub dispatch {
 my ($self, $request, @pairs) = @_;
 my $state = _state($self);
 my $options = _options('dispatch', {authorization_context => 1}, @pairs);
 _throw('linkedspec_mcp_invalid_dispatch', 'Dispatch requires an authorization context.')
  unless exists $options->{authorization_context};
 my $authorization = _authorization_bytes($options->{authorization_context});

 my $copy = eval { LinkedSpec::MCPContractRuntime::clone_data($request) };
 return LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'invalid_request') if $@;
 my $id = _valid_request_id(ref($copy) eq 'HASH' ? $copy->{id} : undef)
  ? $copy->{id}
  : undef;
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'internal_error') if $state->{stopped};
 return LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'invalid_request')
  unless ref($copy) eq 'HASH'
   && _is_json_string($copy->{jsonrpc}) && $copy->{jsonrpc} eq '2.0'
   && _is_json_string($copy->{method});

 my $method = $copy->{method};
 if (!exists $copy->{id}) {
  if ($method eq 'notifications/cancelled'
      && LinkedSpec::MCPContractRuntime::validate_named('cancelledNotification', $copy)) {
   my $key = LinkedSpec::MCPContractRuntime::canonical_json($copy->{params}{requestId});
   $state->{active}{$key}{cancelled} = 1 if exists $state->{active}{$key};
  }
  return undef
 }
 return LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'invalid_request') unless defined $id;
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'legacy_initialize')
  if $method eq 'initialize';
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'invalid_request')
  if $method eq 'notifications/cancelled';
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'method_not_found')
  unless $method eq 'server/discover' || $method eq 'tools/list' || $method eq 'tools/call';

 my $protocol = _requested_protocol($copy);
 if (defined($protocol) && _is_json_string($protocol)
     && $protocol ne LinkedSpec::MCPContractRuntime::protocol_version()) {
  return LinkedSpec::MCPContractRuntime::json_rpc_error(
   $id,
   'unsupported_version',
   requested => $protocol,
  )
 }
 if ($method eq 'server/discover') {
  return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'invalid_params')
   unless LinkedSpec::MCPContractRuntime::validate_named('discoverRequest', $copy);
  return _prepare_response($state, $id, sub {
   LinkedSpec::MCPContractRuntime::discover_response($id)
  })
 }
 if ($method eq 'tools/list') {
  return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'invalid_params')
   unless LinkedSpec::MCPContractRuntime::validate_named('toolsListRequest', $copy);
  return _prepare_response($state, $id, sub {
   LinkedSpec::MCPContractRuntime::tools_list_response($id)
  })
 }

 my $name = ref($copy->{params}) eq 'HASH' ? $copy->{params}{name} : undef;
 my ($definition, $operation);
 if (_is_json_string($name) && $name eq 'linkedspec_semantic_capabilities') {
  ($definition, $operation) = ('capabilitiesCallRequest', 'capabilities');
 } elsif (_is_json_string($name) && $name eq 'linkedspec_semantic_query') {
  ($definition, $operation) = ('semanticQueryCallRequest', 'query');
 } else {
  return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'invalid_params')
 }
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'invalid_params')
  unless LinkedSpec::MCPContractRuntime::validate_named($definition, $copy);

 return _prepare_response($state, $id, sub {
  my $arguments = $copy->{params}{arguments};
  my $entry = _authorized_entry($state, $arguments->{handle}, $authorization);
  return LinkedSpec::MCPContractRuntime::tool_error_response($id, 'handle_unavailable')
   unless $entry;
  if ($operation eq 'query' && !_request_within_policy($arguments->{request}, $entry->{policy})) {
   return LinkedSpec::MCPContractRuntime::tool_error_response($id, 'policy_denied')
  }
  my $response;
  if ($operation eq 'capabilities') {
   $response = $entry->{index}->capabilities;
   $response = _project_capabilities($response, $entry->{policy});
  } else {
   $response = $entry->{index}->query($arguments->{request});
  }
  return LinkedSpec::MCPContractRuntime::tool_success_response($id, $response)
 })
}

sub shutdown {
 my ($self) = @_;
 my $state = _state($self);
 $state->{stopped} = 1;
 %{$state->{entries}} = ();
 %{$state->{active}} = ();
 return 1
}

sub _prepare_response {
 my ($state, $id, $builder) = @_;
 my $key = LinkedSpec::MCPContractRuntime::canonical_json($id);
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'internal_error')
  if exists $state->{active}{$key};
 $state->{active}{$key} = {cancelled => 0};
 my $response = eval { $builder->() };
 my $failed = $@ ? 1 : 0;
 my $cancelled = $state->{active}{$key}{cancelled} ? 1 : 0;
 delete $state->{active}{$key};
 return undef if $cancelled;
 return LinkedSpec::MCPContractRuntime::json_rpc_error($id, 'internal_error') if $failed;
 return $response
}

sub _requested_protocol {
 my ($request) = @_;
 return undef unless ref($request->{params}) eq 'HASH';
 return undef unless ref($request->{params}{_meta}) eq 'HASH';
 return $request->{params}{_meta}{'io.modelcontextprotocol/protocolVersion'}
}

sub _authorized_entry {
 my ($state, $handle, $authorization) = @_;
 my $entry = $state->{entries}{$handle};
 my $expected = $entry ? $entry->{auth_digest} : $DUMMY_AUTH_DIGEST;
 my $equal = _fixed_digest_equal($expected, sha256($authorization));
 my $now = _now_ms($state);
 if ($entry && $now >= $entry->{expires_ms}) {
  delete $state->{entries}{$handle};
  $entry = undef;
 }
 return undef unless $entry && $equal;
 return $entry
}

sub _fixed_digest_equal {
 my ($left, $right) = @_;
 my $different = 0;
 for my $index (0 .. 31) {
  $different |= ord(substr($left, $index, 1)) ^ ord(substr($right, $index, 1));
 }
 return $different == 0 ? 1 : 0
}

sub _native_limits {
 my ($response) = @_;
 my @records = grep { ref($_) eq 'HASH' && ($_->{kind} || '') eq 'capabilities' }
  @{$response->{records} || []};
 _throw('linkedspec_mcp_invalid_index', 'The semantic index capabilities record is invalid.')
  unless @records == 1 && ref($records[0]{facts}) eq 'HASH';
 my $facts = $records[0]{facts};
 my $snapshot = $response->{snapshot};
 _throw('linkedspec_mcp_invalid_index', 'The semantic index capability limits are invalid.')
  unless exists($SOURCE_RANK{$facts->{source_detail_ceiling} || ''})
   && ref($snapshot) eq 'HASH'
   && exists($SOURCE_RANK{$snapshot->{source_detail_ceiling} || ''})
   && _is_positive_integer($facts->{page_default})
   && _is_positive_integer($facts->{page_max})
   && $facts->{page_default} <= $facts->{page_max}
   && _valid_budget($facts->{budget_defaults})
   && _valid_budget($facts->{budget_maxima});
 foreach my $name (qw(max_records max_relations max_depth)) {
  _throw('linkedspec_mcp_invalid_index', 'The semantic index capability limits are invalid.')
   if $facts->{budget_defaults}{$name} > $facts->{budget_maxima}{$name};
 }
 return {
  source_detail_ceiling => $facts->{source_detail_ceiling},
  content_digest_available => $snapshot->{content_digest_available} ? 1 : 0,
  page_default => 0 + $facts->{page_default},
  page_max => 0 + $facts->{page_max},
  budget_defaults => {map { $_ => 0 + $facts->{budget_defaults}{$_} } qw(max_records max_relations max_depth)},
  budget_maxima => {map { $_ => 0 + $facts->{budget_maxima}{$_} } qw(max_records max_relations max_depth)},
 }
}

sub _effective_policy {
 my ($supplied, $native) = @_;
 my $effective = LinkedSpec::MCPContractRuntime::clone_data($native);
 $effective->{project} = defined($supplied) ? 1 : 0;
 return $effective unless defined $supplied;
 _throw('linkedspec_mcp_invalid_policy', 'MCP deployment policy must be an object.')
  unless ref($supplied) eq 'HASH';
 my %allowed = map { $_ => 1 } qw(source_detail_ceiling page_max budget_maxima);
 _throw('linkedspec_mcp_invalid_policy', 'MCP deployment policy contains an unsupported field.')
  if grep { !$allowed{$_} } keys %$supplied;
 if (exists $supplied->{source_detail_ceiling}) {
  my $value = $supplied->{source_detail_ceiling};
  _throw('linkedspec_mcp_invalid_policy', 'MCP source-detail policy is invalid or elevating.')
   unless defined($value) && !ref($value) && exists($SOURCE_RANK{$value})
    && $SOURCE_RANK{$value} <= $SOURCE_RANK{$native->{source_detail_ceiling}};
  $effective->{source_detail_ceiling} = "$value";
  $effective->{content_digest_available} = 0 if $value ne 'text';
 }
 if (exists $supplied->{page_max}) {
  my $value = $supplied->{page_max};
  _throw('linkedspec_mcp_invalid_policy', 'MCP page policy is invalid or elevating.')
   unless _is_positive_integer($value) && $value <= $native->{page_max};
  $effective->{page_max} = 0 + $value;
  $effective->{page_default} = $value if $effective->{page_default} > $value;
 }
 if (exists $supplied->{budget_maxima}) {
  my $budget = $supplied->{budget_maxima};
  _throw('linkedspec_mcp_invalid_policy', 'MCP budget policy must be an object.')
   unless ref($budget) eq 'HASH';
  my %allowed_budget = map { $_ => 1 } qw(max_records max_relations max_depth);
  _throw('linkedspec_mcp_invalid_policy', 'MCP budget policy contains an unsupported field.')
   if grep { !$allowed_budget{$_} } keys %$budget;
  foreach my $name (keys %$budget) {
   my $value = $budget->{$name};
   _throw('linkedspec_mcp_invalid_policy', 'MCP budget policy is invalid or elevating.')
    unless _is_integer($value) && $value >= 0 && $value <= $native->{budget_maxima}{$name};
   $effective->{budget_maxima}{$name} = 0 + $value;
   $effective->{budget_defaults}{$name} = $value
    if $effective->{budget_defaults}{$name} > $value;
  }
 }
 return $effective
}

sub _project_capabilities {
 my ($response, $policy) = @_;
 _throw('linkedspec_mcp_invalid_index', 'The semantic index returned an invalid response.')
  unless LinkedSpec::MCPContractRuntime::validate_named('semanticQueryResponse', $response);
 return $response unless $policy->{project};
 my $projected = LinkedSpec::MCPContractRuntime::clone_data($response);
 my @records = grep { ($_->{kind} || '') eq 'capabilities' } @{$projected->{records}};
 die 'capabilities response lost its capabilities record' unless @records == 1;
 my $facts = $records[0]{facts};
 $facts->{source_detail_ceiling} = $policy->{source_detail_ceiling};
 $facts->{page_max} = $policy->{page_max};
 $facts->{page_default} = $policy->{page_default};
 $facts->{budget_maxima} = LinkedSpec::MCPContractRuntime::clone_data($policy->{budget_maxima});
 $facts->{budget_defaults} = LinkedSpec::MCPContractRuntime::clone_data($policy->{budget_defaults});
 $projected->{snapshot}{source_detail_ceiling} = $policy->{source_detail_ceiling};
 $projected->{snapshot}{content_digest_available} = JSON::PP::false
  unless $policy->{content_digest_available} && $policy->{source_detail_ceiling} eq 'text';
 return $projected
}

sub _request_within_policy {
 my ($request, $policy) = @_;
 return 0 if $SOURCE_RANK{$request->{source}{detail}} > $SOURCE_RANK{$policy->{source_detail_ceiling}};
 return 0 if $request->{source}{include_content_digest}
  && (!$policy->{content_digest_available} || $policy->{source_detail_ceiling} ne 'text');
 return 0 if $request->{page}{limit} > $policy->{page_max};
 foreach my $name (qw(max_records max_relations max_depth)) {
  return 0 if $request->{budget}{$name} > $policy->{budget_maxima}{$name};
 }
 return 1
}

sub _unique_handle {
 my ($state) = @_;
 for (1 .. $state->{handle_attempts}) {
  my $bytes = eval { $state->{entropy}->() };
  _throw('linkedspec_mcp_entropy_failure', 'Operating-system entropy is unavailable.')
   if $@ || !defined($bytes) || ref($bytes) || utf8::is_utf8($bytes)
    || length($bytes) != $ENTROPY_BYTES;
  my $handle = encode_base64url($bytes);
  _throw('linkedspec_mcp_entropy_failure', 'Operating-system entropy produced an invalid handle.')
   unless _valid_handle($handle);
  return $handle unless exists $state->{entries}{$handle};
 }
 _throw('linkedspec_mcp_entropy_failure', 'A unique MCP handle could not be generated.')
}

sub _os_entropy {
 sysopen my $fh, '/dev/urandom', O_RDONLY
  or _throw('linkedspec_mcp_entropy_failure', 'Operating-system entropy is unavailable.');
 binmode($fh, ':raw')
  or _throw('linkedspec_mcp_entropy_failure', 'Operating-system entropy is unavailable.');
 my $bytes = '';
 while (length($bytes) < $ENTROPY_BYTES) {
  my $count = sysread(
   $fh,
   $bytes,
   $ENTROPY_BYTES - length($bytes),
   length($bytes),
  );
  next if !defined($count) && $! == EINTR;
  if (!defined($count) || $count == 0) {
   close $fh;
   _throw('linkedspec_mcp_entropy_failure', 'Operating-system entropy is unavailable.');
  }
 }
 close($fh) or _throw('linkedspec_mcp_entropy_failure', 'Operating-system entropy is unavailable.');
 return $bytes
}

sub _monotonic_ms {
 return int(clock_gettime(CLOCK_MONOTONIC) * 1000)
}

sub _now_ms {
 my ($state) = @_;
 my $value = eval { $state->{now_ms}->() };
 _throw('linkedspec_mcp_clock_failure', 'Monotonic time is unavailable.')
  if $@ || !_is_integer($value) || $value < 0;
 return 0 + $value
}

sub _prune_expired {
 my ($state, $now) = @_;
 foreach my $handle (keys %{$state->{entries}}) {
  delete $state->{entries}{$handle} if $now >= $state->{entries}{$handle}{expires_ms};
 }
 return
}

sub _authorization_bytes {
 my ($value) = @_;
 _throw('linkedspec_mcp_invalid_authorization', 'Authorization context must be 1 through 4096 opaque bytes.')
  if !defined($value) || ref($value) || utf8::is_utf8($value)
   || length($value) < 1 || length($value) > 4096;
 return "$value"
}

sub _valid_handle {
 my ($value) = @_;
 return defined($value) && !ref($value) && !utf8::is_utf8($value)
  && length($value) == $HANDLE_CHARACTERS
  && $value =~ /\A[A-Za-z0-9_-]+\z/ ? 1 : 0
}

sub _valid_request_id {
 my ($value) = @_;
 return 0 unless defined $value;
 return LinkedSpec::MCPContractRuntime::validate_named('requestId', $value)
}

sub _is_json_string {
 my ($value) = @_;
 return 0 if !defined($value) || ref($value);
 my $encoded = eval { LinkedSpec::MCPContractRuntime::canonical_json($value) };
 return !$@ && $encoded =~ /\A"/ ? 1 : 0
}

sub _is_integer {
 my ($value) = @_;
 return 0 if !defined($value) || ref($value) || !looks_like_number($value);
 return 0 unless int($value) == $value;
 my $encoded = eval { LinkedSpec::MCPContractRuntime::canonical_json($value) };
 return !$@ && $encoded =~ /\A-?(?:0|[1-9][0-9]*)\z/ ? 1 : 0
}

sub _is_positive_integer {
 my ($value) = @_;
 return _is_integer($value) && $value >= 1
}

sub _valid_budget {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless keys(%$value) == 3;
 foreach my $name (qw(max_records max_relations max_depth)) {
  return 0 unless exists($value->{$name}) && _is_integer($value->{$name}) && $value->{$name} >= 0;
 }
 return 1
}

sub _options {
 my ($context, $allowed, @pairs) = @_;
 _throw('linkedspec_mcp_invalid_options', "MCP $context options must be key/value pairs.") if @pairs % 2;
 my %options;
 while (@pairs) {
  my ($name, $value) = splice(@pairs, 0, 2);
  _throw('linkedspec_mcp_invalid_options', "MCP $context option names must be nonempty strings.")
   unless defined($name) && !ref($name) && length($name);
  _throw('linkedspec_mcp_invalid_options', "MCP $context option '$name' is unsupported.")
   unless $allowed->{$name};
  _throw('linkedspec_mcp_invalid_options', "MCP $context option '$name' was repeated.")
   if exists $options{$name};
  $options{$name} = $value;
 }
 return \%options
}

sub _state {
 my ($self) = @_;
 my $address = ref($self) ? refaddr($self) : undef;
 _throw('linkedspec_mcp_invalid_server', 'MCP server object is invalid.')
  unless defined($address) && exists $STATE_BY_ADDRESS{$address};
 return $STATE_BY_ADDRESS{$address}
}

sub _throw {
 my ($code, $message) = @_;
 die bless {code => $code, message => $message}, 'LinkedSpec::MCPServer::Error'
}

sub DESTROY {
 my ($self) = @_;
 my $address = refaddr($self);
 if (defined($address) && exists $STATE_BY_ADDRESS{$address}) {
  %{$STATE_BY_ADDRESS{$address}{entries}} = ();
  %{$STATE_BY_ADDRESS{$address}{active}} = ();
  delete $STATE_BY_ADDRESS{$address};
 }
 return
}

1;

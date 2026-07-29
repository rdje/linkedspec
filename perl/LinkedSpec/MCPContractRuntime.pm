#------------------------------------------------------------------------------
# Package: LinkedSpec::MCPContractRuntime
# Purpose: Decode, clone, validate, and instantiate the generated neutral MCP
#          contract without filesystem or semantic-index authority.
#------------------------------------------------------------------------------
package LinkedSpec::MCPContractRuntime;

use 5.010;
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use Encode qw(encode FB_CROAK LEAVE_SRC);
use JSON::PP ();

use LinkedSpec::MCPContract ();

my $JSON = JSON::PP->new->allow_nonref(1)->canonical(1)->max_depth(256);
my ($BUNDLE, %PAYLOAD_BY_ID);

sub _initialize {
 return if $BUNDLE;
 my $json = LinkedSpec::MCPContract::bundle_json();
 my $bytes = encode('UTF-8', $json, FB_CROAK | LEAVE_SRC);
 die 'generated MCP contract digest mismatch'
  unless sha256_hex($bytes) eq LinkedSpec::MCPContract::bundle_sha256();
 my $decoded = eval { $JSON->decode($json) };
 die 'generated MCP contract cannot be decoded' if $@ || ref($decoded) ne 'HASH';
 die 'unsupported generated MCP contract binding'
  unless $decoded->{binding_format} && $decoded->{binding_format} == 1;
 $BUNDLE = $decoded;
 my $rows = $BUNDLE->{semantic_payloads}{payloads};
 die 'generated MCP semantic payload inventory is invalid' unless ref($rows) eq 'ARRAY';
 %PAYLOAD_BY_ID = map { $_->{id} => $_->{response} } @$rows;
 die 'generated MCP semantic payload ids repeat' unless keys(%PAYLOAD_BY_ID) == @$rows;
 return
}

sub canonical_json {
 my ($value) = @_;
 my $encoded = eval { $JSON->encode($value) };
 die 'value is not canonical JSON data' if $@;
 return $encoded
}

sub clone_data {
 my ($value) = @_;
 return $JSON->decode(canonical_json($value))
}

sub contract {
 _initialize();
 return clone_data($BUNDLE->{contract})
}

sub source_sha256 {
 _initialize();
 return clone_data($BUNDLE->{source_sha256})
}

sub corpus {
 _initialize();
 return clone_data($BUNDLE->{corpus})
}

sub protocol_version {
 _initialize();
 return $BUNDLE->{contract}{protocol_version}
}

sub frame {
 my ($id) = @_;
 _initialize();
 return undef unless defined($id) && !ref($id) && exists $BUNDLE->{canonical_frames}{$id};
 return clone_data($BUNDLE->{canonical_frames}{$id})
}

sub payload {
 my ($id) = @_;
 _initialize();
 return undef unless defined($id) && !ref($id) && exists $PAYLOAD_BY_ID{$id};
 return clone_data($PAYLOAD_BY_ID{$id})
}

sub validate_named {
 my ($name, $value) = @_;
 _initialize();
 return 0 unless defined($name) && !ref($name) && exists $BUNDLE->{schema}{'$defs'}{$name};
 return _matches($value, $BUNDLE->{schema}{'$defs'}{$name}, 0)
}

sub validate_frame {
 my ($value) = @_;
 _initialize();
 return _matches($value, $BUNDLE->{schema}, 0)
}

sub _matches {
 my ($value, $schema, $depth) = @_;
 return eval { _validate($value, $schema, $depth); 1 } ? 1 : 0
}

sub _validate {
 my ($value, $schema, $depth) = @_;
 die 'schema validation depth exceeded' if $depth > 256;
 return if !ref($schema) && $schema;
 die 'false schema' unless ref($schema) eq 'HASH';

 if (exists $schema->{'$ref'}) {
  my $ref = $schema->{'$ref'};
  die 'unsupported schema reference' unless defined($ref) && $ref =~ m{\A\#/\$defs/([^/]+)\z};
  my $definition = $BUNDLE->{schema}{'$defs'}{$1};
  die 'unresolved schema reference' unless ref($definition) eq 'HASH';
  _validate($value, $definition, $depth + 1);
 }
 if (exists $schema->{type}) {
  my @types = ref($schema->{type}) eq 'ARRAY' ? @{$schema->{type}} : ($schema->{type});
  die 'schema type mismatch' unless grep { _has_type($value, $_) } @types;
 }
 die 'schema const mismatch'
  if exists($schema->{const}) && !_same_json($value, $schema->{const});
 if (exists $schema->{enum}) {
  die 'schema enum mismatch' unless grep { _same_json($value, $_) } @{$schema->{enum}};
 }
 if (exists $schema->{oneOf}) {
  my $matches = grep { _matches($value, $_, $depth + 1) } @{$schema->{oneOf}};
  die 'schema oneOf mismatch' unless $matches == 1;
 }
 if (exists $schema->{allOf}) {
  _validate($value, $_, $depth + 1) foreach @{$schema->{allOf}};
 }

 if (ref($value) eq 'HASH') {
  my $properties = ref($schema->{properties}) eq 'HASH' ? $schema->{properties} : {};
  die 'schema maximum properties exceeded'
   if exists($schema->{maxProperties}) && keys(%$value) > $schema->{maxProperties};
  foreach my $name (@{$schema->{required} || []}) {
   die 'schema required property missing' unless exists $value->{$name};
  }
  foreach my $name (keys %$value) {
   _validate($name, $schema->{propertyNames}, $depth + 1)
    if ref($schema->{propertyNames}) eq 'HASH';
   if (exists $properties->{$name}) {
    _validate($value->{$name}, $properties->{$name}, $depth + 1);
   } elsif (exists($schema->{additionalProperties}) && !$schema->{additionalProperties}) {
    die 'schema additional property rejected';
   } elsif (ref($schema->{additionalProperties}) eq 'HASH') {
    _validate($value->{$name}, $schema->{additionalProperties}, $depth + 1);
   }
  }
 }

 if (ref($value) eq 'ARRAY') {
  my $prefix = ref($schema->{prefixItems}) eq 'ARRAY' ? $schema->{prefixItems} : [];
  for my $index (0 .. $#$prefix) {
   last if $index > $#$value;
   _validate($value->[$index], $prefix->[$index], $depth + 1);
  }
  if (ref($schema->{items}) eq 'HASH') {
   my $start = @$prefix ? scalar(@$prefix) : 0;
   for my $index ($start .. $#$value) {
    _validate($value->[$index], $schema->{items}, $depth + 1);
   }
  }
  die 'schema minimum items not met'
   if exists($schema->{minItems}) && @$value < $schema->{minItems};
  die 'schema maximum items exceeded'
   if exists($schema->{maxItems}) && @$value > $schema->{maxItems};
 }

 if (_has_type($value, 'string')) {
  my $length = length($value);
  die 'schema minimum string length not met'
   if exists($schema->{minLength}) && $length < $schema->{minLength};
  die 'schema maximum string length exceeded'
   if exists($schema->{maxLength}) && $length > $schema->{maxLength};
  if (exists $schema->{'x-linkedspec-maxUtf8Bytes'}) {
   my $bytes = eval { encode('UTF-8', $value, FB_CROAK | LEAVE_SRC) };
   die 'schema string is not valid Unicode' if $@;
   die 'schema maximum UTF-8 bytes exceeded'
    if length($bytes) > $schema->{'x-linkedspec-maxUtf8Bytes'};
  }
  if (exists $schema->{pattern}) {
   my $pattern = $schema->{pattern};
   die 'schema string pattern mismatch' unless $value =~ /\A(?:$pattern)\z/;
  }
  if (($schema->{format} || '') eq 'uri') {
   die 'schema URI format mismatch' unless $value =~ /\A[A-Za-z][A-Za-z0-9+.-]*:/;
  }
 }
 if (_has_type($value, 'integer')) {
  die 'schema numeric minimum not met'
   if exists($schema->{minimum}) && $value < $schema->{minimum};
  die 'schema numeric maximum exceeded'
   if exists($schema->{maximum}) && $value > $schema->{maximum};
 }
 return
}

sub _has_type {
 my ($value, $type) = @_;
 return !defined($value) if $type eq 'null';
 return ref($value) eq 'JSON::PP::Boolean' if $type eq 'boolean';
 return ref($value) eq 'ARRAY' if $type eq 'array';
 return ref($value) eq 'HASH' if $type eq 'object';
 return 0 if !defined($value) || ref($value);
 my $encoded = eval { $JSON->encode($value) };
 return 0 if $@;
 return $encoded =~ /\A"/ ? 1 : 0 if $type eq 'string';
 return $encoded =~ /\A-?(?:0|[1-9][0-9]*)\z/ ? 1 : 0 if $type eq 'integer';
 return 0
}

sub _same_json {
 my ($left, $right) = @_;
 my ($left_json, $right_json);
 return 0 unless eval {
  $left_json = $JSON->encode($left);
  $right_json = $JSON->encode($right);
  1
 };
 return $left_json eq $right_json
}

sub discover_response {
 my ($id) = @_;
 my $response = frame('discover_response_perl');
 $response->{id} = clone_data($id);
 return $response
}

sub tools_list_response {
 my ($id) = @_;
 my $response = frame('tools_list_response_perl');
 $response->{id} = clone_data($id);
 return $response
}

sub tool_success_response {
 my ($id, $payload) = @_;
 die 'native semantic response violates the MCP schema'
  unless validate_named('semanticQueryResponse', $payload);
 my $response = frame('capabilities_call_response');
 $response->{id} = clone_data($id);
 $response->{result}{structuredContent} = clone_data($payload);
 $response->{result}{content}[0]{text} = canonical_json($payload);
 return $response
}

sub tool_error_response {
 my ($id, $error_id) = @_;
 die 'unknown MCP tool error'
  unless $error_id eq 'handle_unavailable' || $error_id eq 'policy_denied';
 # The policy fixture is the canonical Perl-identity tool-error shell.  Only
 # the embedded error text differs for the indistinguishable handle path.
 my $response = frame('policy_denied_response');
 if ($error_id eq 'handle_unavailable') {
  my $payload_frame = frame('handle_unavailable_response');
  $response->{result}{content} = $payload_frame->{result}{content};
 }
 $response->{id} = clone_data($id);
 return $response
}

sub json_rpc_error {
 my ($id, $kind, %fields) = @_;
 _initialize();
 my %owner = (
  parse_error => 'invalid_utf8',
  invalid_request => 'invalid_envelope',
  method_not_found => 'unknown_method',
  invalid_params => 'method_params',
  internal_error => 'sanitized_unexpected_failure',
  unsupported_version => 'unsupported_protocol_version',
 );
 my ($code, $message);
 if ($kind eq 'legacy_initialize') {
  $code = $BUNDLE->{contract}{legacy_diagnostic}{code};
  $message = $BUNDLE->{contract}{legacy_diagnostic}{message};
 } else {
  die 'unknown MCP JSON-RPC error' unless exists $owner{$kind};
  my ($row) = grep {
   my %owned = map { $_ => 1 } @{$_->{owns} || []};
   $owned{$owner{$kind}}
  } @{$BUNDLE->{contract}{json_rpc_errors} || []};
  die 'generated MCP JSON-RPC error inventory is invalid' unless ref($row) eq 'HASH';
  ($code, $message) = @{$row}{qw(code message)};
 }
 my $error = {code => 0 + $code, message => "$message"};
 if ($kind eq 'unsupported_version') {
  $error->{data} = {
   requested => defined($fields{requested}) && !ref($fields{requested}) ? "$fields{requested}" : '',
   supported => [protocol_version()],
  };
 }
 return {jsonrpc => '2.0', id => defined($id) ? clone_data($id) : undef, error => $error}
}

1;

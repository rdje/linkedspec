#------------------------------------------------------------------------------
# Package: LinkedSpec::MCPWire
# Purpose: Own strict MCP UTF-8 JSON-line framing and canonical stdio I/O.
#------------------------------------------------------------------------------
package LinkedSpec::MCPWire;

use 5.010;
use strict;
use warnings;
use utf8;

use Encode qw(decode encode FB_CROAK LEAVE_SRC);
use Errno qw(EINTR);
use IO::Handle ();
use JSON::PP ();
use Scalar::Util qw(blessed);

use LinkedSpec::MCPContractRuntime ();

my $CONTRACT = LinkedSpec::MCPContractRuntime::contract();
my $LIMITS = $CONTRACT->{request_limits};
my $MAX_LINE_BYTES = $LIMITS->{line_bytes_excluding_delimiter};
my $MAX_JSON_DEPTH = $LIMITS->{json_nesting_depth};
my $JSON = JSON::PP->new->allow_nonref(1)->allow_bignum(1)->max_depth(256);
my $STRING_JSON = JSON::PP->new->allow_nonref(1)->max_depth(8);
my $BOM = "\xEF\xBB\xBF";
my $IO_LOG_RECORD = "linkedspec_mcp_io_failure\n";

sub serve {
 my (%args) = @_;
 my $server = $args{server};
 my $input = $args{input};
 my $output = $args{output};
 my $authorization = $args{authorization_context};
 my $log = $args{log};

 return _io_failure($server, $log) unless _raw_handle($input) && _raw_handle($output);
 return _io_failure($server, undef) if defined($log) && !_raw_handle($log);

 my $buffer = '';
 my $overlong = 0;
 local $SIG{PIPE} = 'IGNORE';
 while (1) {
  my $chunk = '';
  my $count = eval { read($input, $chunk, 65_536) };
  return _io_failure($server, $log) if $@;
  next if !defined($count) && $! == EINTR;
  return _io_failure($server, $log) unless defined $count;
  if ($count == 0) {
   if ($overlong) {
    my $response = LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'parse_error');
    return _io_failure($server, $log) unless _emit_response($server, $output, $response, undef);
   } elsif (length $buffer) {
    my ($response, $prepared) = _process_payload($server, $buffer, $authorization);
    return _io_failure($server, $log)
     unless _emit_response($server, $output, $response, $prepared);
   }
   $server->shutdown;
   return 0
  }

  my $offset = 0;
  while ($offset < length($chunk)) {
   my $newline = index($chunk, "\n", $offset);
   my $ends_line = $newline >= 0 ? 1 : 0;
   my $end = $ends_line ? $newline : length($chunk);
   my $piece = substr($chunk, $offset, $end - $offset);
   if (!$overlong) {
    if (length($buffer) + length($piece) > $MAX_LINE_BYTES + 1) {
     $buffer = '';
     $overlong = 1;
    } else {
     $buffer .= $piece;
    }
   }
   last unless $ends_line;

   my ($response, $prepared);
   if ($overlong) {
    $response = LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'parse_error');
   } else {
    my $payload = $buffer;
    chop $payload if length($payload) && substr($payload, -1) eq "\r";
    if (length($payload) > $MAX_LINE_BYTES) {
     $response = LinkedSpec::MCPContractRuntime::json_rpc_error(undef, 'parse_error');
    } else {
     ($response, $prepared) = _process_payload($server, $payload, $authorization);
    }
   }
   return _io_failure($server, $log)
    unless _emit_response($server, $output, $response, $prepared);
   $buffer = '';
   $overlong = 0;
   $offset = $newline + 1;
  }
 }
}

sub _process_payload {
 my ($server, $payload, $authorization) = @_;
 my ($request, $failure) = _decode_payload($payload);
 return (LinkedSpec::MCPContractRuntime::json_rpc_error(undef, $failure), undef) if $failure;
 my ($response, $prepared);
 my $ok = eval {
  ($response, $prepared) = $server->_dispatch_for_wire(
   $request,
   authorization_context => $authorization,
  );
  1
 };
 return (LinkedSpec::MCPContractRuntime::json_rpc_error(
  _validated_id($request),
  'internal_error',
 ), undef) unless $ok;
 return (undef, undef) unless defined $response;
 return ($response, $prepared) if LinkedSpec::MCPContractRuntime::validate_frame($response);
 $server->_wire_response_emitted($prepared);
 return (
  LinkedSpec::MCPContractRuntime::json_rpc_error(_validated_id($request), 'internal_error'),
  undef,
 )
}

sub _decode_payload {
 my ($payload) = @_;
 return (undef, 'parse_error')
  if !defined($payload) || ref($payload) || length($payload) > $MAX_LINE_BYTES
   || substr($payload, 0, 3) eq $BOM;
 my $text = eval { decode('UTF-8', $payload, FB_CROAK | LEAVE_SRC) };
 return (undef, 'parse_error') if $@;
 my $scanner = {
  text => $text,
  length => length($text),
  offset => 0,
  id_token => undef,
 };
 my $scanned = eval {
  _skip_ws($scanner);
  _parse_value($scanner, 0, 1);
  _skip_ws($scanner);
  die 'trailing JSON data' unless $scanner->{offset} == $scanner->{length};
  1
 };
 return (undef, 'parse_error') unless $scanned;
 my $value = eval { $JSON->decode($text) };
 return (undef, 'parse_error') if $@;
 return (undef, 'parse_error') unless eval { _unicode_tree($value); 1 };
 return (undef, 'invalid_request') unless ref($value) eq 'HASH';
 if (exists $value->{id}) {
  return (undef, 'invalid_request') unless _valid_wire_id($value->{id}, $scanner->{id_token});
 }
 _replace_non_data_numbers($value);
 return ($value, undef)
}

sub _parse_value {
 my ($scanner, $depth, $root) = @_;
 _skip_ws($scanner);
 die 'missing JSON value' if $scanner->{offset} >= $scanner->{length};
 my $character = substr($scanner->{text}, $scanner->{offset}, 1);
 if ($character eq '{') {
  _parse_object($scanner, $depth + 1, $root);
 } elsif ($character eq '[') {
  _parse_array($scanner, $depth + 1);
 } elsif ($character eq '"') {
  _parse_string($scanner);
 } elsif ($character eq 't') {
  _parse_literal($scanner, 'true');
 } elsif ($character eq 'f') {
  _parse_literal($scanner, 'false');
 } elsif ($character eq 'n') {
  _parse_literal($scanner, 'null');
 } elsif ($character eq '-' || $character =~ /[0-9]/) {
  _parse_number($scanner);
 } else {
  die 'invalid JSON token';
 }
 return
}

sub _parse_object {
 my ($scanner, $depth, $root) = @_;
 die 'JSON nesting depth exceeded' if $depth > $MAX_JSON_DEPTH;
 ++$scanner->{offset};
 _skip_ws($scanner);
 if (_take($scanner, '}')) {
  return
 }
 my %keys;
 while (1) {
  die 'JSON object key is not a string'
   unless substr($scanner->{text}, $scanner->{offset}, 1) eq '"';
  my ($key) = _parse_string($scanner);
  die 'duplicate JSON object key' if exists $keys{$key};
  $keys{$key} = 1;
  _skip_ws($scanner);
  die 'JSON object colon is missing' unless _take($scanner, ':');
  _skip_ws($scanner);
  my $start = $scanner->{offset};
  my $kind = _token_kind($scanner);
  _parse_value($scanner, $depth, 0);
  if ($root && $key eq 'id') {
   $scanner->{id_token} = {
    kind => $kind,
    raw => substr($scanner->{text}, $start, $scanner->{offset} - $start),
   };
  }
  _skip_ws($scanner);
  last if _take($scanner, '}');
  die 'JSON object comma is missing' unless _take($scanner, ',');
  _skip_ws($scanner);
 }
 return
}

sub _parse_array {
 my ($scanner, $depth) = @_;
 die 'JSON nesting depth exceeded' if $depth > $MAX_JSON_DEPTH;
 ++$scanner->{offset};
 _skip_ws($scanner);
 return if _take($scanner, ']');
 while (1) {
  _parse_value($scanner, $depth, 0);
  _skip_ws($scanner);
  last if _take($scanner, ']');
  die 'JSON array comma is missing' unless _take($scanner, ',');
  _skip_ws($scanner);
 }
 return
}

sub _parse_string {
 my ($scanner) = @_;
 my $start = $scanner->{offset};
 ++$scanner->{offset};
 while ($scanner->{offset} < $scanner->{length}) {
  my $character = substr($scanner->{text}, $scanner->{offset}, 1);
  if ($character eq '"') {
   ++$scanner->{offset};
   my $token = substr($scanner->{text}, $start, $scanner->{offset} - $start);
   my $value = eval { $STRING_JSON->decode($token) };
   die 'invalid JSON string' if $@ || ref($value);
   encode('UTF-8', $value, FB_CROAK | LEAVE_SRC);
   return ($value, $token)
  }
  die 'unescaped JSON control character' if ord($character) < 0x20;
  if ($character eq '\\') {
   ++$scanner->{offset};
   die 'truncated JSON escape' if $scanner->{offset} >= $scanner->{length};
   my $escape = substr($scanner->{text}, $scanner->{offset}, 1);
   if ($escape eq 'u') {
    my $hex = substr($scanner->{text}, $scanner->{offset} + 1, 4);
    die 'invalid JSON Unicode escape' unless length($hex) == 4 && $hex =~ /\A[0-9A-Fa-f]{4}\z/;
    $scanner->{offset} += 5;
    next
   }
   die 'invalid JSON escape' unless $escape =~ /["\\\/bfnrt]/;
  }
  ++$scanner->{offset};
 }
 die 'unterminated JSON string'
}

sub _parse_literal {
 my ($scanner, $literal) = @_;
 die 'invalid JSON literal'
  unless substr($scanner->{text}, $scanner->{offset}, length($literal)) eq $literal;
 $scanner->{offset} += length($literal);
 return
}

sub _parse_number {
 my ($scanner) = @_;
 my $remaining = substr($scanner->{text}, $scanner->{offset});
 die 'invalid JSON number'
  unless $remaining =~ /\A(-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)/;
 $scanner->{offset} += length($1);
 return
}

sub _token_kind {
 my ($scanner) = @_;
 my $character = substr($scanner->{text}, $scanner->{offset}, 1);
 return 'string' if $character eq '"';
 return 'object' if $character eq '{';
 return 'array' if $character eq '[';
 return 'boolean' if $character eq 't' || $character eq 'f';
 return 'null' if $character eq 'n';
 return 'number' if $character eq '-' || $character =~ /[0-9]/;
 return 'invalid'
}

sub _valid_wire_id {
 my ($value, $token) = @_;
 return 0 unless ref($token) eq 'HASH';
 if ($token->{kind} eq 'number') {
  return 0 unless $token->{raw} =~ /\A-?(?:0|[1-9][0-9]*)\z/;
  return 0 unless _safe_id_integer($token->{raw});
 }
 return LinkedSpec::MCPContractRuntime::validate_named('requestId', $value)
}

sub _safe_id_integer {
 my ($raw) = @_;
 my $digits = $raw;
 $digits =~ s/^-//;
 $digits =~ s/^0+(?=[0-9])//;
 my $limit = '9007199254740991';
 return 1 if length($digits) < length($limit);
 return 0 if length($digits) > length($limit);
 return $digits le $limit ? 1 : 0
}

sub _validated_id {
 my ($request) = @_;
 return undef unless ref($request) eq 'HASH' && exists $request->{id};
 return LinkedSpec::MCPContractRuntime::validate_named('requestId', $request->{id})
  ? $request->{id}
  : undef
}

sub _replace_non_data_numbers {
 my ($value) = @_;
 if (ref($value) eq 'HASH') {
  foreach my $key (keys %$value) {
   my $child = $value->{$key};
   if (blessed($child) && ref($child) ne 'JSON::PP::Boolean') {
    $value->{$key} = undef;
   } else {
    _replace_non_data_numbers($child);
   }
  }
 } elsif (ref($value) eq 'ARRAY') {
  for my $index (0 .. $#$value) {
   my $child = $value->[$index];
   if (blessed($child) && ref($child) ne 'JSON::PP::Boolean') {
    $value->[$index] = undef;
   } else {
    _replace_non_data_numbers($child);
   }
  }
 }
 return
}

sub _unicode_tree {
 my ($value) = @_;
 if (ref($value) eq 'HASH') {
  foreach my $key (keys %$value) {
   encode('UTF-8', $key, FB_CROAK | LEAVE_SRC);
   _unicode_tree($value->{$key});
  }
 } elsif (ref($value) eq 'ARRAY') {
  _unicode_tree($_) foreach @$value;
 } elsif (!ref($value) && defined($value)) {
  encode('UTF-8', $value, FB_CROAK | LEAVE_SRC);
 }
 return
}

sub _skip_ws {
 my ($scanner) = @_;
 while ($scanner->{offset} < $scanner->{length}) {
  my $character = substr($scanner->{text}, $scanner->{offset}, 1);
  last unless $character eq ' ' || $character eq "\t" || $character eq "\r" || $character eq "\n";
  ++$scanner->{offset};
 }
 return
}

sub _take {
 my ($scanner, $character) = @_;
 return 0 unless $scanner->{offset} < $scanner->{length}
  && substr($scanner->{text}, $scanner->{offset}, 1) eq $character;
 ++$scanner->{offset};
 return 1
}

sub _raw_handle {
 my ($handle) = @_;
 return 0 unless ref($handle);
 return eval { binmode($handle, ':raw') ? 1 : 0 } ? 1 : 0
}

sub _emit {
 my ($output, $response) = @_;
 return 0 unless LinkedSpec::MCPContractRuntime::validate_frame($response);
 my $text = eval { LinkedSpec::MCPContractRuntime::canonical_json($response) };
 return 0 if $@;
 my $bytes = eval { encode('UTF-8', $text, FB_CROAK | LEAVE_SRC) . "\n" };
 return 0 if $@;
 my $printed = eval { print {$output} $bytes };
 return 0 if $@ || !$printed;
 my $flushed = eval { $output->flush };
 return !$@ && $flushed ? 1 : 0
}

sub _emit_response {
 my ($server, $output, $response, $prepared) = @_;
 return 1 unless defined $response;
 return 1 unless $server->_wire_response_ready($prepared);
 return 0 unless _emit($output, $response);
 $server->_wire_response_emitted($prepared);
 return 1
}

sub _io_failure {
 my ($server, $log) = @_;
 eval { $server->shutdown };
 if (defined $log) {
  eval {
   print {$log} $IO_LOG_RECORD;
   die 'log flush failed' unless $log->flush;
  };
 }
 return 1
}

1;

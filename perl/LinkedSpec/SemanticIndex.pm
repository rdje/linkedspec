#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticIndex
# Purpose: Own immutable Perl semantic-index construction, strict source
#          normalization, source mapping, compiled/failed outcomes, and the
#          public lazy capabilities/query gateway.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticIndex;

use 5.010;
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use Encode qw(decode encode FB_CROAK LEAVE_SRC);
use JSON::PP ();
use Scalar::Util qw(refaddr);

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::SemanticSourceMap ();
use LinkedSpec::SemanticStaticProjection ();

my %STATE_BY_ADDRESS;
my %SOURCE_DETAIL = map { $_ => 1 } qw(none identity span text);

sub create {
 my ($source_ref, @option_pairs) = @_;
 _throw_error(
  stage => 'validate_source',
  code => 'semantic_index_invalid_source',
  summary => 'Semantic index source must be a scalar reference',
 ) unless ref($source_ref) eq 'SCALAR';
 _throw_error(
  stage => 'validate_options',
  code => 'semantic_index_invalid_option',
  summary => 'Semantic index options must be key/value pairs',
 ) if @option_pairs % 2;

 my %options;
 while (@option_pairs) {
  my ($key, $value) = splice(@option_pairs, 0, 2);
  _throw_error(
   stage => 'validate_options',
   code => 'semantic_index_invalid_option',
   summary => 'Semantic index option names must be non-empty scalars',
  ) if !defined($key) || ref($key) || !length($key);
  _throw_error(
   stage => 'validate_options',
   code => 'semantic_index_invalid_option',
   summary => "Semantic index option '$key' was supplied more than once",
   fields => { option => $key },
  ) if exists $options{$key};
  $options{$key} = $value;
 }

 my %allowed = map { $_ => 1 } qw(logical_name source_detail_ceiling top_rule);
 foreach my $key (sort keys %options) {
  _throw_error(
   stage => 'validate_options',
   code => 'semantic_index_invalid_option',
   summary => "Unsupported semantic index option '$key'",
   fields => { option => $key },
  ) unless $allowed{$key};
 }

 _throw_error(
  stage => 'validate_options',
  code => 'semantic_index_invalid_option',
  summary => "Semantic index option 'logical_name' is required",
  fields => { option => 'logical_name' },
 ) unless exists $options{logical_name};
 _throw_error(
  stage => 'validate_options',
  code => 'semantic_index_invalid_option',
  summary => "Semantic index option 'source_detail_ceiling' is required",
  fields => { option => 'source_detail_ceiling' },
 ) unless exists $options{source_detail_ceiling};

 my ($source_text, $source_bytes) = _normalize_utf8_scalar(
  $$source_ref,
  stage => 'decode_source',
  code => 'semantic_index_invalid_utf8',
  summary => 'Semantic index source is not valid strict UTF-8',
 );
 my ($logical_name) = _normalize_utf8_scalar(
  $options{logical_name},
  stage => 'validate_options',
  code => 'semantic_index_invalid_option',
  summary => "Semantic index option 'logical_name' is not valid strict UTF-8",
  option => 'logical_name',
 );
 _throw_error(
  stage => 'validate_options',
  code => 'semantic_index_invalid_option',
  summary => "Semantic index option 'logical_name' must be non-empty and single-line",
  fields => { option => 'logical_name' },
 ) if !length($logical_name) || $logical_name =~ /[\x{00}-\x{1F}\x{7F}]/u;

 my $source_detail_ceiling = $options{source_detail_ceiling};
 _throw_error(
  stage => 'validate_options',
  code => 'semantic_index_invalid_option',
  summary => "Semantic index option 'source_detail_ceiling' must be none, identity, span, or text",
  fields => { option => 'source_detail_ceiling' },
 ) unless defined($source_detail_ceiling)
  && !ref($source_detail_ceiling)
  && $SOURCE_DETAIL{$source_detail_ceiling};

 my $top_rule;
 if (exists $options{top_rule}) {
  ($top_rule) = _normalize_utf8_scalar(
   $options{top_rule},
   stage => 'validate_options',
   code => 'semantic_index_invalid_option',
   summary => "Semantic index option 'top_rule' is not valid strict UTF-8",
   option => 'top_rule',
  );
  _throw_error(
   stage => 'validate_options',
   code => 'semantic_index_invalid_option',
   summary => "Semantic index option 'top_rule' must be non-empty when supplied",
   fields => { option => 'top_rule' },
  ) unless length $top_rule;
 }

 my $source_map = LinkedSpec::SemanticSourceMap->new(
  source_text => $source_text,
  source_bytes => $source_bytes,
 );
 my $runtime_ctx = {};
 my %compile_options = (
  return_descriptor => 1,
  runtime_ctx_ref => $runtime_ctx,
 );
 $compile_options{top_rule} = $top_rule if defined $top_rule;
 my $descriptor = LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::Runtime',
  'run_get',
  \$source_text,
  \%compile_options,
 );
 my $state_name = ref($descriptor) eq 'HASH' ? 'compiled' : 'failed_compilation';
 my $compilation_error = ref($runtime_ctx->{last_error}) eq 'HASH'
  ? _clone_plain_data($runtime_ctx->{last_error})
  : undef;
 if ($state_name eq 'failed_compilation' && ref($compilation_error) ne 'HASH') {
  $compilation_error = {
   code => 'semantic_index_compilation_failed',
   stage => 'compile',
   summary => 'Semantic index compilation failed without a structured runtime diagnostic',
  };
 }

 my $snapshot = {
  id => 'snapshot:0',
  state => $state_name,
  has_execution => 0,
  source_detail_ceiling => "$source_detail_ceiling",
  content_digest_available => $source_detail_ceiling eq 'text' ? 1 : 0,
 };
 my $content_digest = 'sha256:' . sha256_hex($source_bytes);
 my $static_projection = LinkedSpec::SemanticStaticProjection::build(
  source_text => $source_text,
  source_map => $source_map,
  logical_name => $logical_name,
  content_digest => $content_digest,
  snapshot => $snapshot,
  descriptor => $state_name eq 'compiled' ? $descriptor : undef,
  compilation_error => $compilation_error,
  selected_top_rule => $runtime_ctx->{top_rule},
  requested_top_rule => $top_rule,
 );

 my $token = 0;
 my $self = bless \$token, __PACKAGE__;
 $STATE_BY_ADDRESS{refaddr($self)} = {
  source_text => "$source_text",
  source_bytes => "$source_bytes",
  logical_name => "$logical_name",
  source_detail_ceiling => "$source_detail_ceiling",
  content_digest => $content_digest,
  content_digest_available => $source_detail_ceiling eq 'text' ? 1 : 0,
  source_map => $source_map,
  compilation_state => $state_name,
  compilation_error => $compilation_error,
  descriptor_authority => $state_name eq 'compiled' ? $descriptor : undef,
  static_projection => $static_projection,
  top_rule => defined($top_rule) ? "$top_rule" : undef,
 };
 return $self
}

# Internal foundation methods are intentionally not part of the public v1 host
# surface. Projection/query owners consume them without exposing compiler
# objects, decoded source, or mutable state to callers.
sub _foundation_snapshot {
 my ($self) = @_;
 my $state = _state($self);
 return {
  id => 'snapshot:0',
  state => $state->{compilation_state},
  has_execution => 0,
  source_detail_ceiling => $state->{source_detail_ceiling},
  content_digest_available => $state->{content_digest_available} ? 1 : 0,
 }
}

sub _static_projection {
 my ($self) = @_;
 return _clone_plain_data(_state($self)->{static_projection})
}

# Public v1 host surface. The evaluator is lazy and receives only a cloned
# private plain-data projection, never descriptor/source-map authority.
sub capabilities {
 my ($self) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::SemanticQuery',
  'capabilities',
  _clone_plain_data(_state($self)->{static_projection}),
 )
}

sub query {
 my ($self, $request) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::SemanticQuery',
  'evaluate',
  _clone_plain_data(_state($self)->{static_projection}),
  $request,
 )
}

sub _foundation_source_identity {
 my ($self) = @_;
 my $state = _state($self);
 return {
  source_id => 'source:0',
  logical_name => $state->{logical_name},
  byte_length => $state->{source_map}->byte_length,
  character_length => $state->{source_map}->character_length,
  content_digest => $state->{content_digest_available} ? $state->{content_digest} : undef,
 }
}

sub _foundation_compilation_error {
 my ($self) = @_;
 my $error = _state($self)->{compilation_error};
 return defined($error) ? _clone_plain_data($error) : undef
}

sub _foundation_compiled_authority_present {
 my ($self) = @_;
 return ref(_state($self)->{descriptor_authority}) eq 'HASH' ? 1 : 0
}

sub _foundation_span_for_bytes {
 my ($self, $start_byte, $end_byte) = @_;
 return _state($self)->{source_map}->span_from_byte_range($start_byte, $end_byte)
}

sub _foundation_excerpt_for_bytes {
 my ($self, $start_byte, $end_byte) = @_;
 return _state($self)->{source_map}->excerpt_for_byte_range($start_byte, $end_byte)
}

sub _foundation_locate_exact {
 my ($self, $needle, %args) = @_;
 return _state($self)->{source_map}->locate_exact($needle, %args)
}

sub _normalize_utf8_scalar {
 my ($value, %error) = @_;
 _throw_error(
  %error,
  fields => { defined($error{option}) ? (option => $error{option}) : () },
 ) if !defined($value) || ref($value);
 my ($text, $bytes);
 if (utf8::is_utf8($value)) {
  $text = "$value";
  $bytes = eval { encode('UTF-8', $text, FB_CROAK | LEAVE_SRC) };
 } else {
  $bytes = "$value";
  $text = eval { decode('UTF-8', $bytes, FB_CROAK | LEAVE_SRC) };
 }
 if ($@) {
  my $detail = "$@";
  $detail =~ s/\s+\z//;
  _throw_error(
   %error,
   detail => $detail,
   fields => { defined($error{option}) ? (option => $error{option}) : () },
  );
 }
 return ($text, $bytes)
}

sub _clone_plain_data {
 my ($value) = @_;
 return $value unless ref $value;
 return $value ? JSON::PP::true : JSON::PP::false if ref($value) eq 'JSON::PP::Boolean';
 return [map { _clone_plain_data($_) } @$value] if ref($value) eq 'ARRAY';
 if (ref($value) eq 'HASH') {
  return { map { $_ => _clone_plain_data($value->{$_}) } keys %$value }
 }
 die "(LinkedSpec::SemanticIndex::_clone_plain_data) -E- non-plain internal value cannot cross the semantic boundary\n"
}

sub _state {
 my ($self) = @_;
 _throw_error(
  stage => 'validate_index',
  code => 'semantic_index_invalid_object',
  summary => 'Invalid semantic index object',
 ) unless ref($self) && $self->isa(__PACKAGE__);
 my $state = $STATE_BY_ADDRESS{refaddr($self)};
 _throw_error(
  stage => 'validate_index',
  code => 'semantic_index_invalid_object',
  summary => 'Expired semantic index object',
 ) unless ref($state) eq 'HASH';
 return $state
}

sub _throw_error {
 my (%args) = @_;
 die LinkedSpec::SemanticIndex::Error->new(%args)
}

sub DESTROY {
 my ($self) = @_;
 delete $STATE_BY_ADDRESS{refaddr($self)} if ref($self);
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticIndex::Error
# Purpose: Stable typed failures for semantic-index construction validation.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticIndex::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %args) = @_;
 return bless {
  stage => defined($args{stage}) ? "$args{stage}" : 'semantic_index',
  code => defined($args{code}) ? "$args{code}" : 'semantic_index_error',
  summary => defined($args{summary}) ? "$args{summary}" : 'Semantic index error',
  detail => defined($args{detail}) ? "$args{detail}" : undef,
  fields => ref($args{fields}) eq 'HASH'
   ? LinkedSpec::SemanticIndex::_clone_plain_data($args{fields})
   : {},
 }, $class
}

sub stage { return $_[0]{stage} }
sub code { return $_[0]{code} }
sub summary { return $_[0]{summary} }
sub detail { return $_[0]{detail} }
sub fields { return LinkedSpec::SemanticIndex::_clone_plain_data($_[0]{fields}) }

sub as_string {
 my ($self) = @_;
 return "LinkedSpec semantic index error [$self->{code}] at $self->{stage}: $self->{summary}\n"
}

1;

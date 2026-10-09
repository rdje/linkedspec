# Private construction sidecars. Ordinary lowerer results remain scalar strings;
# only an explicitly selected producer in the actual invocation may publish a
# fragment packet. Integration at the producer seams is separately owned.
package LinkedSpec::ActionIR::SourceEmissions;

use 5.010;
use strict;
use warnings;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use Scalar::Util ();
use LinkedSpec::ActionIR::SourceOrigins ();

our ($_producers, $_call, $_inputs);

sub _same_reference {
 my ($left, $right) = @_;
 return ref($left) && ref($right)
  && Scalar::Util::refaddr($left) == Scalar::Util::refaddr($right)
}

sub _current_source_token {
 return LinkedSpec::ActionIR::SourceOrigins::_invocation_token()
}

# Load only when the private input scope/captures are used. The standalone
# emission foundation does not otherwise depend on the parser modules.
sub _load_input_collectors {
 my $error = $@;
 require LinkedSpec::ActionIR::AST::Parser;
 require LinkedSpec::ActionIR::MethodExpr;
 $@ = $error;
 return
}

sub _with_source_inputs {
 my ($work) = @_;
 _load_input_collectors();
 local $_inputs = {source_token => _current_source_token(), captures => {}, grants => {}};
 my $collect = sub { LinkedSpec::ActionIR::MethodExpr::_with_input_captures($work) };
 if (!defined wantarray) {
  LinkedSpec::ActionIR::AST::Parser::_with_node_constructions($collect);
  return
 }
 return LinkedSpec::ActionIR::AST::Parser::_with_node_constructions($collect)
}

sub _eligible_input_scope {
 return ref($_inputs) eq 'HASH'
  && _same_reference($_inputs->{source_token}, _current_source_token())
}

sub _copy_input_description {
 my ($frame) = @_;
 return {source => $frame->{source}, raw => $frame->{raw}, source_span => {%{$frame->{source_span}}}}
}

sub _retain_input_grant {
 my ($record) = @_;
 my $tag = '';
 my $grant = bless \$tag, 'LinkedSpec::ActionIR::SourceEmissions::Input';
 $record->{grant} = $grant;
 $_inputs->{grants}{Scalar::Util::refaddr($grant)} = $record;
 return $grant
}

sub _event_input_for {
 my ($event) = @_;
 return undef unless _eligible_input_scope();
 my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
 return undef unless $origin;
 return _retain_input_grant({kind => 'event', event => $event, frame => _copy_input_description($origin)})
}

sub _capture_input_record {
 my ($capture, $callback, $event) = @_;
 return undef unless _eligible_input_scope() && ref($capture) eq 'HASH';
 my $record = $_inputs->{captures}{Scalar::Util::refaddr($capture)};
 return undef unless $record && _same_reference($record->{capture}, $capture)
  && _same_reference($record->{callback}, $callback) && _same_reference($record->{event}, $event)
  && _same_reference($record->{value}, $capture->{value});
 return $record
}

sub _native_input_for {
 my ($capture, $node, $arguments, $index) = @_;
 return LinkedSpec::ActionIR::AST::Parser::_input_frame_for(
  $capture->{native}, $capture->{callback}, $node) if $capture->{mode} eq 'ast';
 return LinkedSpec::ActionIR::MethodExpr::_argument_input_for(
  $capture->{native}, $capture->{callback}, $arguments, $index)
}

# Native offsets are descriptions of the actual captured input. Only the
# retained actual parent grant selects the original compiler-event occurrence.
sub _rebase_input_frame {
 my ($native, $parent) = @_;
 return undef unless ref($native) eq 'HASH' && ref($native->{source_span}) eq 'HASH'
  && defined($native->{source}) && !ref($native->{source}) && $native->{source} eq $parent->{raw}
  && defined($native->{raw}) && !ref($native->{raw});
 my ($start, $end) = @{$native->{source_span}}{qw(start end)};
 return undef unless _valid_span({start => 0, end => length($parent->{raw})}, $start, $end)
  && substr($parent->{raw}, $start, $end - $start) eq $native->{raw};
 return {source => $parent->{source}, raw => $native->{raw}, source_span => {
  start => $parent->{source_span}{start} + $start, end => $parent->{source_span}{start} + $end}}
}

# Revalidate on every use, including already selected descendants. Nothing in a
# detached description, equal copy or expired/nested registry can select a grant.
sub _input_record {
 my ($grant) = @_;
 return undef unless _eligible_input_scope()
  && ref($grant) eq 'LinkedSpec::ActionIR::SourceEmissions::Input';
 my $record = $_inputs->{grants}{Scalar::Util::refaddr($grant)};
 return undef unless $record && _same_reference($record->{grant}, $grant);
 my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($record->{event});
 my $frame = $record->{frame};
 return undef unless $origin && $frame->{source} eq $origin->{source}
  && _valid_span($origin->{source_span}, @{$frame->{source_span}}{qw(start end)})
  && substr($frame->{source}, $frame->{source_span}{start}, length($frame->{raw})) eq $frame->{raw}
  && $frame->{source_span}{end} - $frame->{source_span}{start} == length($frame->{raw});
 if ($record->{kind} ne 'event') {
  my $capture = $record->{capture};
  return undef unless _same_reference($capture,
   _capture_input_record($capture->{capture}, $capture->{callback}, $record->{event}));
  my $parent = _input_record($capture->{parent});
  return undef unless $parent;
  my $current = _rebase_input_frame(
   _native_input_for($capture, @{$record}{qw(node arguments index)}), $parent->{frame});
  return undef unless $current && $current->{raw} eq $frame->{raw}
   && $current->{source_span}{start} == $frame->{source_span}{start}
   && $current->{source_span}{end} == $frame->{source_span}{end};
 }
 return $record
}

sub _input_description {
 my $record = _input_record($_[0]);
 return $record ? _copy_input_description($record->{frame}) : undef
}

sub _capture_source_input {
 my $mode = shift;
 my $parent = shift;
 my $callback = shift;
 my $source = @_ && !ref($_[0]) ? $_[0] : undef;
 _load_input_collectors();
 my $native = $mode eq 'ast'
  ? LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions($callback, @_)
  : $mode eq 'method'
   ? LinkedSpec::ActionIR::MethodExpr::_capture_method_input($callback, @_)
   : LinkedSpec::ActionIR::MethodExpr::_capture_csv_input($callback, @_);
 my $error = $@;
 my $capture = {value => $native->{value}};
 my $input = _input_record($parent);
 # The native AST collector does not retain opaque callback returns. Register
 # only eligible actual AST roots, preserving that ordinary release behavior.
 my $root = $mode eq 'ast'
  ? LinkedSpec::ActionIR::AST::Parser::_input_frame_for($native, $callback, $native->{value}) : undef;
 if ($input && defined($source) && $source eq $input->{frame}{raw}
     && ($mode ne 'ast' || _rebase_input_frame($root, $input->{frame}))) {
  $_inputs->{captures}{Scalar::Util::refaddr($capture)} = {
   capture => $capture, native => $native, callback => $callback, mode => $mode,
   value => $capture->{value}, parent => $parent, event => $input->{event},
  };
 }
 $@ = $error;
 return $capture
}

sub _capture_ast_input { return _capture_source_input('ast', @_) }
sub _capture_method_input { return _capture_source_input('method', @_) }
sub _capture_csv_input { return _capture_source_input('csv', @_) }

sub _derived_input_for {
 my ($capture, $callback, $event, $mode, $node, $arguments, $index) = @_;
 my $record = _capture_input_record($capture, $callback, $event);
 return undef unless $record && ($mode eq 'ast' ? $record->{mode} eq 'ast' : $record->{mode} ne 'ast');
 my $parent = _input_record($record->{parent});
 return undef unless $parent;
 my $frame = _rebase_input_frame(_native_input_for($record, $node, $arguments, $index), $parent->{frame});
 return undef unless $frame;
 return _retain_input_grant({kind => $mode, event => $event, frame => $frame,
                            capture => $record, node => $node, arguments => $arguments, index => $index})
}

sub _ast_input_for {
 my ($capture, $callback, $event, $node) = @_;
 return _derived_input_for($capture, $callback, $event, 'ast', $node, undef, undef)
}

sub _argument_input_for {
 my ($capture, $callback, $event, $arguments, $index) = @_;
 return _derived_input_for($capture, $callback, $event, 'argument', undef, $arguments, $index)
}

# The caller supplies actual known callbacks at their factory seam. Strong
# retention prevents refaddr reuse; nested producer/source scopes cannot borrow
# the enclosing registration. This is private authority, not a public registry.
sub _with_emission_producers {
 my ($callbacks, $work) = @_;
 my %known;
 for my $callback (@{ref($callbacks) eq 'ARRAY' ? $callbacks : []}) {
  $known{Scalar::Util::refaddr($callback)} = $callback if ref($callback) eq 'CODE';
 }
 local $_producers = {source_token => _current_source_token(), known => \%known, captures => {}};
 local $_call;
 if (!defined wantarray) { $work->(); return }
 return $work->()
}

sub _eligible_call {
 return ref($_call) eq 'HASH' && $_call->{known}
  && _same_reference($_call->{source_token}, _current_source_token())
  && _same_reference($_call->{producer_scope}, $_producers)
}

sub _copy_packet {
 my ($packet) = @_;
 return {
  text => $packet->{text},
  fragments => [map { +{kind => $_->{kind}, output_span => {%{$_->{output_span}}},
                  exists($_->{source_span}) ? (source_span => {%{$_->{source_span}}}) : ()} }
                @{$packet->{fragments}}],
  consumed => [map { +{source_span => {%{$_->{source_span}}}} } @{$packet->{consumed}}],
 }
}

# Always call once in scalar context, as the existing canonical apply seam does.
# shift preserves aliases of the remaining @_ entries as well as reference
# identity. No eval shields or extra calls may change callback error effects.
sub _capture_emission {
 my $callback = shift;
 my $source_token = _current_source_token();
 my $known = ref($_producers) eq 'HASH'
  && _same_reference($_producers->{source_token}, $source_token)
  && ref($callback) eq 'CODE'
  && _same_reference($_producers->{known}{Scalar::Util::refaddr($callback)}, $callback);
 local $_call = {source_token => $source_token, producer_scope => $_producers,
                 callback => $callback, known => $known, builders => {}, publications => []};
 my $value = $callback->(@_);
 my $callback_error = $@;
 my ($packet, $published);
 if (_eligible_call() && @{$_call->{publications}} == 1 && defined($value) && !ref($value)) {
  my $record = $_call->{publications}[0];
  if (!$record->{invalid} && $value eq $record->{text}
      && ${$record->{builder}} eq $record->{text}) {
   $packet = {
    text => $value,
    fragments => $record->{fragments}, consumed => $record->{consumed},
   };
   $published = $record;
  }
 }
 my $capture = {value => $value, emission => $packet ? _copy_packet($packet) : undef};
 if ($packet) {
  $_producers->{captures}{Scalar::Util::refaddr($capture)} = {
   capture => $capture, callback => $callback, event => $published->{event},
   origin => $published->{origin}, packet => _copy_packet($packet),
  };
 }
 $@ = $callback_error;
 return $capture
}

# Mapping must retrieve the retained packet for the actual capture/callback/event
# triple. Detached descriptive packets cannot grant authority in another call.
sub _emission_for {
 my ($capture, $callback, $event) = @_;
 return undef unless ref($_producers) eq 'HASH'
  && _same_reference($_producers->{source_token}, _current_source_token())
  && ref($capture) eq 'HASH';
 my $entry = $_producers->{captures}{Scalar::Util::refaddr($capture)};
 return undef unless $entry && _same_reference($entry->{capture}, $capture)
  && _same_reference($entry->{callback}, $callback) && _same_reference($entry->{event}, $event)
  && defined($capture->{value}) && !ref($capture->{value})
  && $capture->{value} eq $entry->{packet}{text};
 my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
 return undef unless $origin && $origin->{source} eq $entry->{origin}{source}
  && $origin->{source_span}{start} == $entry->{origin}{source_span}{start}
  && $origin->{source_span}{end} == $entry->{origin}{source_span}{end};
 return _copy_packet($entry->{packet})
}

# Builder text works without a collector or source authority. Metadata lives in
# the actual call's sidecar, so copied/foreign/stale builder objects have none.
sub _new_builder {
 my ($event) = @_;
 my $text = '';
 my $builder = bless \$text, 'LinkedSpec::ActionIR::SourceEmissions::Builder';
 if (_eligible_call()) {
  my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
  $_call->{builders}{Scalar::Util::refaddr($builder)} = {
   builder => $builder, event => $event, origin => $origin, text => '',
   fragments => [], consumed => [],
  } if $origin;
 }
 return $builder
}

sub _builder_record {
 my ($builder) = @_;
 return undef unless _eligible_call() && ref($builder) eq 'LinkedSpec::ActionIR::SourceEmissions::Builder';
 my $record = $_call->{builders}{Scalar::Util::refaddr($builder)};
 return $record && _same_reference($record->{builder}, $builder) ? $record : undef
}

sub _valid_span {
 my ($span, $start, $end) = @_;
 return defined($start) && !ref($start) && $start =~ /\A[0-9]+\z/o
  && defined($end) && !ref($end) && $end =~ /\A[0-9]+\z/o
  && $span->{start} <= $start && $start <= $end && $end <= $span->{end}
}

sub _append_piece {
 my ($builder, $text, $start, $end) = @_;
 die "private emission piece must be a scalar string\n" unless defined($text) && !ref($text);
 my $record = _builder_record($builder);
 if ($record) {
  $record->{invalid} = 1 if $record->{published} || $$builder ne $record->{text};
  my $offset = length($record->{text});
  my $fragment = {kind => 'generated', output_span => {start => $offset, end => $offset + length($text)}};
  my $origin = $record->{origin};
  if (_valid_span($origin->{source_span}, $start, $end)
      && substr($origin->{source}, $start, $end - $start) eq $text) {
   $fragment->{kind} = 'source';
   $fragment->{source_span} = {start => 0 + $start, end => 0 + $end};
  }
  push @{$record->{fragments}}, $fragment if length($text);
  $record->{text} .= $text;
 }
 $$builder .= $text;
 return $builder
}

sub _append_generated {
 my ($builder, $text) = @_;
 return _append_piece($builder, $text, undef, undef)
}

# Explicit construction coordinates validate a selected original frame. Equal
# text alone does not grant a frame or choose an occurrence.
sub _append_source {
 return _append_piece(@_)
}

sub _append_input {
 my ($builder, $text, $grant) = @_;
 my $record = _builder_record($builder);
 my $input = _input_record($grant);
 if ($record && $input && _same_reference($record->{event}, $input->{event})) {
  return _append_source($builder, $text, @{$input->{frame}{source_span}}{qw(start end)})
 }
 return _append_generated($builder, $text)
}

sub _consume_input {
 my ($builder, $grant) = @_;
 my $record = _builder_record($builder);
 return $builder unless $record;
 $record->{invalid} = 1 if $record->{published};
 my $input = _input_record($grant);
 return $builder unless $input && _same_reference($record->{event}, $input->{event});
 push @{$record->{consumed}}, {event => $input->{event}, source_span => {%{$input->{frame}{source_span}}}};
 return $builder
}

sub _consume_source {
 my ($builder, $event) = @_;
 my $record = _builder_record($builder);
 return $builder unless $record;
 $record->{invalid} = 1 if $record->{published};
 my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
 return $builder unless $origin && $origin->{source} eq $record->{origin}{source};
 my ($start, $end) = @{$origin->{source_span}}{qw(start end)};
 return $builder unless _valid_span($record->{origin}{source_span}, $start, $end);
 push @{$record->{consumed}}, {event => $event, source_span => {start => $start, end => $end}};
 return $builder
}

sub _finish_emission {
 my ($builder) = @_;
 my $record = _builder_record($builder);
 if ($record) {
  $record->{invalid} = 1 if $record->{published} || $$builder ne $record->{text};
  $record->{published} = 1;
  push @{$_call->{publications}}, $record;
 }
 return $$builder
}

1;

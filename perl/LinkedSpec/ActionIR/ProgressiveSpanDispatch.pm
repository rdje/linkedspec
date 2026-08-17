#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::ProgressiveSpanDispatch
# Purpose: Own the private progressive span-dispatch ActionIR contract, exact
#          authored-statement scanner, static operands, and runtime lowering.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::ProgressiveSpanDispatch;

use 5.010;
use strict;
use warnings;

use JSON::PP ();

my $PARSER_ID_PATTERN = qr/\A[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*\z/o;
my $TOP_RULE_PATTERN = qr/\A[A-Za-z_][A-Za-z0-9_]*\z/o;
my $BARE_BINDING_PATTERN = qr/\A[A-Za-z_][A-Za-z0-9_]*\z/o;

sub build_contracts {
 my ($label) = @_;
 return [
  {
   id                 => 'progressive_span_dispatch',
   ir_node            => 'PROGRESSIVE_DISPATCH_SPAN',
   diag_name          => 'dispatch_span',
   exclusive_statement => 1,
   unresolved_pattern => qr/\bdispatch_span\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $args = ref($ctx) eq 'HASH' && ref($ctx->{event}) eq 'HASH'
     ? $ctx->{event}{args}
     : undef;
    return _lower_statement($code, $args, $label)
   },
  },
 ]
}

sub try_scan_contract_ir_events {
 my ($id, $code) = @_;
 return undef unless defined($id) && $id eq 'progressive_span_dispatch';

 my @events;
 for my $statement (@{_split_action_ir_statements($code)}) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw)
   && $raw =~ /\A(?<result>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<source>dispatch_span\s*\(.*\))\z/so;
  my ($result, $source) = ($+{result}, $+{source});
  my $call = _parse_method_function_expr($source);
  next unless ref($call) eq 'HASH' && ($call->{method} // '') eq 'dispatch_span';
  my $operands = ref($call->{args}) eq 'ARRAY' ? $call->{args} : [];
  my @normalized = map {
   my $value = _trim_action_ir_value($_);
   defined($value) ? $value : ''
  } @$operands;
  my %args = (
   result => $result,
   argument_count => scalar(@normalized),
   parser_operand => @normalized > 0 ? $normalized[0] : '',
   top_rule_operand => @normalized > 1 ? $normalized[1] : '',
   span_operand => @normalized > 2 ? $normalized[2] : '',
  );
  my $validated = validate_static_operands(\%args);
  @args{qw/parser_id top_rule span_binding/} =
   @{$validated}{qw/parser_id top_rule span_binding/}
    if ref($validated) eq 'HASH' && $validated->{ok};
  push @events, {raw => $raw, args => \%args};
 }
 return \@events
}

sub validate_static_operands {
 my ($args) = @_;
 $args = {} unless ref($args) eq 'HASH';
 my $argument_count = $args->{argument_count};
 $argument_count = 0 unless defined($argument_count) && $argument_count =~ /\A\d+\z/o;

 my ($parser_literal, $parser_id) = decode_string_literal($args->{parser_operand});
 return {
  ok => 0,
  code => 'progressive_parser_identity_literal_required',
  operand => _operand_or_missing($args->{parser_operand}),
 } unless $parser_literal;
 return {
  ok => 0,
  code => 'progressive_parser_identity_invalid',
  parser_id => $parser_id,
 } unless defined($parser_id) && $parser_id =~ $PARSER_ID_PATTERN;

 my ($top_literal, $top_rule) = decode_string_literal($args->{top_rule_operand});
 return {
  ok => 0,
  code => 'progressive_top_rule_literal_required',
  operand => _operand_or_missing($args->{top_rule_operand}),
 } unless $top_literal;
 return {
  ok => 0,
  code => 'progressive_top_rule_invalid',
  top_rule => $top_rule,
 } unless defined($top_rule) && $top_rule =~ $TOP_RULE_PATTERN;

 my $span_binding = $args->{span_operand};
 return {
  ok => 0,
  code => 'progressive_span_binding_required',
  operand => $argument_count == 3
   ? _operand_or_missing($span_binding)
   : '<arity:'.$argument_count.'>',
 } unless $argument_count == 3
  && defined($span_binding)
  && !ref($span_binding)
  && $span_binding =~ $BARE_BINDING_PATTERN;

 return {
  ok => 1,
  parser_id => $parser_id,
  top_rule => $top_rule,
  span_binding => $span_binding,
 }
}

sub decode_string_literal {
 my ($operand) = @_;
 return (0, undef) unless defined($operand) && !ref($operand);
 if ($operand =~ /\A"(?:\\.|[^"\\])*"\z/s) {
  my $decoded = eval { JSON::PP->new->decode($operand) };
  return $@ ? (0, undef) : (1, $decoded)
 }
 return (0, undef) unless $operand =~ /\A'((?:\\.|[^'\\])*)'\z/s;
 my $decoded = $1;
 $decoded =~ s/\\([\\'])/$1/g;
 return (1, $decoded)
}

sub _lower_statement {
 my ($code, $args, $label) = @_;
 return $code unless ref($args) eq 'HASH';
 my $result = $args->{result};
 return $code unless defined($result) && $result =~ $BARE_BINDING_PATTERN;
 my $validated = validate_static_operands($args);
 return '$'.$result.' = undef'
  unless ref($validated) eq 'HASH' && $validated->{ok};
 return '$'.$result.' = LinkedSpec::ProgressiveSpanDispatchRuntime::dispatch('
  .'$descr, $'.$validated->{span_binding}.', '
  ._quote_perl_string($validated->{parser_id}).', '
  ._quote_perl_string($validated->{top_rule}).', '
  ._quote_perl_string(($label // '<rule>').':dispatch_span').')'
}

sub _quote_perl_string {
 my ($value) = @_;
 $value = '' unless defined $value;
 $value =~ s/\\/\\\\/g;
 $value =~ s/'/\\'/g;
 $value =~ s/\r/\\r/g;
 $value =~ s/\n/\\n/g;
 return "'$value'"
}

sub _operand_or_missing {
 my ($operand) = @_;
 return '<missing>' unless defined($operand) && !ref($operand) && length($operand);
 return $operand
}

1;

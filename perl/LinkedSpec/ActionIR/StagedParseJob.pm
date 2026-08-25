#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::StagedParseJob
# Purpose: Own the private general parse-job annotation contract, its exact
#          assignment scanner, literal options, typed text plan, and inert
#          marker lowering. Parser resolution and scheduling live elsewhere.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::StagedParseJob;

use 5.010;
use strict;
use warnings;

use JSON::PP ();

my $IDENTIFIER_PATTERN = qr/\A[a-z][a-z0-9_]*\z/o;
my $PARSER_ID_PATTERN = qr/\A[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*\z/o;
my $TOP_RULE_PATTERN = qr/\A[A-Za-z_][A-Za-z0-9_]*\z/o;
my $FIELD_PATTERN = qr/\A[A-Za-z_][A-Za-z0-9_]*\z/o;
my $CAPABILITY_PATTERN = qr/\A[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*\z/o;
my %REQUIRED_OPTION = map { ($_ => 1) } qw(node_kind payload_kind spec result_policy on_error);
my %OPTION = map { ($_ => 1) } (keys(%REQUIRED_OPTION), qw(top into required_capabilities));
my %RESULT_POLICY = map { ($_ => 1) } qw(replace_marker replace_field sibling_field append_child);
my %FAILURE_POLICY = map { ($_ => 1) } qw(fail keep_text diagnostic_node);
my %DIRECT_TEXT_SOURCE = map { ($_ => 1) } qw(entry_text entry_group match_text match_group);

sub build_contracts {
 my ($label) = @_;
 return [
  {
   id                  => 'staged_parse_job',
   ir_node             => 'STAGED_PARSE_JOB_MARKER',
   diag_name           => 'parse_job',
   exclusive_statement => 1,
   unresolved_pattern  => qr/\bparse_job\s*\(/o,
   lower               => sub {
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
 return undef unless defined($id) && $id eq 'staged_parse_job';

 my @events;
 for my $statement (@{_split_action_ir_statements($code)}) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw)
   && $raw =~ /\A(?<target>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<source>parse_job\s*\(.*\))\z/so;
  my ($target, $source) = ($+{target}, $+{source});
  my $call = _parse_method_function_expr($source);
  next unless ref($call) eq 'HASH' && ($call->{method} // '') eq 'parse_job';
  my $operands = ref($call->{args}) eq 'ARRAY' ? $call->{args} : [];
  my @normalized = map {
   my $value = _trim_action_ir_value($_);
   defined($value) ? $value : ''
  } @$operands;
  my %args = (
   target => $target,
   argument_count => scalar(@normalized),
   text_operand => @normalized ? $normalized[0] : '',
   options_operand => @normalized > 1 ? $normalized[1] : '',
  );
  my $validation = _parse_static_operands(\%args);
  $args{validation} = $validation;
  if (ref($validation) eq 'HASH' && $validation->{ok}) {
   $args{text_plan} = $validation->{text_plan};
   $args{options} = $validation->{options};
  }
  push @events, {raw => $raw, args => \%args};
 }
 return \@events
}

sub validate_static_operands {
 my ($args) = @_;
 return _invalid(
  'staged_parse_job_options_required',
  operand => '<invalid-event>',
 ) unless ref($args) eq 'HASH';
 my $validation = $args->{validation};
 return _invalid(
  'staged_parse_job_options_required',
  operand => '<unvalidated-event>',
 ) unless ref($validation) eq 'HASH';
 return {%$validation} unless $validation->{ok};
 return _invalid(
  'staged_source_provenance_invalid',
  source_id => '<runtime>',
  provenance => '<missing-text-plan>',
 ) unless _valid_text_plan($args->{text_plan});
 return _invalid(
  'staged_parse_job_options_required',
  operand => '<missing-options>',
 ) unless _valid_normalized_options($args->{options});
 return {
  ok => 1,
  text_plan => _clone_plain($args->{text_plan}),
  options => _clone_plain($args->{options}),
 }
}

sub _parse_static_operands {
 my ($args) = @_;
 my $count = $args->{argument_count};
 return _invalid(
  'staged_parse_job_options_required',
  operand => '<arity:'.(defined($count) ? $count : 0).'>',
 ) unless defined($count) && $count == 2;

 my $options = _parse_options_operand($args->{options_operand});
 return $options unless $options->{ok};
 my $text = _parse_text_plan($args->{text_operand});
 return $text unless $text->{ok};
 return {
  ok => 1,
  options => $options->{options},
  text_plan => $text->{text_plan},
 }
}

sub _parse_options_operand {
 my ($operand) = @_;
 my $call = _parse_method_function_expr($operand);
 return _invalid(
  'staged_parse_job_options_required',
  operand => _operand_or_missing($operand),
 ) unless ref($call) eq 'HASH' && ($call->{method} // '') eq 'hash';
 my $pairs = ref($call->{args}) eq 'ARRAY' ? $call->{args} : [];
 return _invalid(
  'staged_parse_job_options_required',
  operand => _operand_or_missing($operand),
 ) unless @$pairs && @$pairs % 2 == 0;

 my %values;
 for (my $index = 0; $index < @$pairs; $index += 2) {
  my ($key_literal, $value_operand) = @$pairs[$index, $index + 1];
  my ($key_ok, $key) = decode_string_literal(_trim_action_ir_value($key_literal));
  return _invalid(
   'staged_parse_job_options_required',
   operand => _operand_or_missing($key_literal),
  ) unless $key_ok && defined($key) && length($key);
  return _invalid('staged_parse_job_option_unknown', option => $key)
   unless $OPTION{$key};
  return _invalid(
   'staged_parse_job_options_required',
   operand => 'duplicate:'.$key,
  ) if exists($values{$key});
  $values{$key} = _trim_action_ir_value($value_operand);
 }

 for my $required (sort keys %REQUIRED_OPTION) {
  return _invalid(
   'staged_parse_job_options_required',
   operand => '<missing:'.$required.'>',
  ) unless exists($values{$required});
 }

 my %options;
 for my $name (qw(node_kind payload_kind spec result_policy on_error top into)) {
  next unless exists($values{$name});
  my ($ok, $value) = decode_string_literal($values{$name});
  return _invalid(
   'staged_parse_job_options_required',
   operand => $name,
  ) unless $ok;
  $options{$name} = $value;
 }

 return _invalid(
  'staged_parse_job_options_required',
  operand => 'node_kind',
 ) unless defined($options{node_kind}) && $options{node_kind} =~ $IDENTIFIER_PATTERN;
 return _invalid(
  'staged_parse_job_options_required',
  operand => 'payload_kind',
 ) unless defined($options{payload_kind}) && $options{payload_kind} =~ $IDENTIFIER_PATTERN;
 return _invalid(
  'staged_parser_identity_invalid',
  parser_spec_id => defined($options{spec}) ? $options{spec} : '',
 ) unless defined($options{spec}) && $options{spec} =~ $PARSER_ID_PATTERN;
 return _invalid(
  'staged_top_rule_invalid',
  top_rule => defined($options{top}) ? $options{top} : '',
 ) if exists($options{top}) && $options{top} !~ $TOP_RULE_PATTERN;
 return _invalid(
  'staged_result_policy_invalid',
  result_policy => defined($options{result_policy}) ? $options{result_policy} : '',
 ) unless defined($options{result_policy}) && $RESULT_POLICY{$options{result_policy}};
 return _invalid(
  'staged_failure_policy_invalid',
  failure_policy => defined($options{on_error}) ? $options{on_error} : '',
 ) unless defined($options{on_error}) && $FAILURE_POLICY{$options{on_error}};

 my $into = exists($options{into}) ? $options{into} : undef;
 my $into_valid = defined($into) && $into =~ $FIELD_PATTERN;
 if (
  ($options{result_policy} eq 'replace_marker' && defined($into))
  || ($options{result_policy} ne 'replace_marker' && !$into_valid)
 ) {
  return _invalid(
   'staged_result_target_invalid',
   result_policy => $options{result_policy},
   into => defined($into) ? $into : '',
  )
 }

 my @capabilities;
 if (exists($values{required_capabilities})) {
  my $cap_call = _parse_method_function_expr($values{required_capabilities});
  return _invalid(
   'staged_parse_job_options_required',
   operand => 'required_capabilities',
  ) unless ref($cap_call) eq 'HASH' && ($cap_call->{method} // '') eq 'array';
  my $items = ref($cap_call->{args}) eq 'ARRAY' ? $cap_call->{args} : [];
  my %seen;
  for my $item (@$items) {
   my ($ok, $value) = decode_string_literal(_trim_action_ir_value($item));
   return _invalid(
    'staged_parse_job_options_required',
    operand => 'required_capabilities',
   ) unless $ok && defined($value) && $value =~ $CAPABILITY_PATTERN && !$seen{$value}++;
   push @capabilities, $value;
  }
 }
 $options{required_capabilities} = [sort @capabilities];
 return {ok => 1, options => \%options}
}

sub _parse_text_plan {
 my ($operand) = @_;
 my $call = _parse_method_function_expr($operand);
 return _provenance_invalid($operand)
  unless ref($call) eq 'HASH' && defined($call->{method});
 my $name = $call->{method};
 my $args = ref($call->{args}) eq 'ARRAY' ? $call->{args} : [];

 if ($DIRECT_TEXT_SOURCE{$name}) {
  if ($name eq 'entry_text' || $name eq 'match_text') {
   return _provenance_invalid($operand) unless @$args == 0;
   return {
    ok => 1,
    text_plan => {kind => 'direct_span', source => $name},
   }
  }
  return _provenance_invalid($operand) unless @$args == 1;
  my $index = _trim_action_ir_value($args->[0]);
  return _provenance_invalid($operand)
   unless defined($index) && $index =~ /\A(?:0|[1-9][0-9]*)\z/o;
  return {
   ok => 1,
   text_plan => {kind => 'direct_span', source => $name, index => 0 + $index},
  }
 }

 if ($name eq 'cat') {
  return _provenance_invalid($operand) unless @$args;
  my @segments;
  for my $arg (@$args) {
   my $child = _parse_text_plan(_trim_action_ir_value($arg));
   return $child unless $child->{ok};
   my $plan = $child->{text_plan};
   if (($plan->{kind} // '') eq 'derived_text') {
    push @segments, @{$plan->{segments}}
   } else {
    push @segments, $plan
   }
  }
  return {
   ok => 1,
   text_plan => {
    kind => 'derived_text',
    policy => 'concatenate_in_order',
    segments => \@segments,
   },
  }
 }

 return _provenance_invalid($operand)
}

sub _valid_text_plan {
 my ($plan) = @_;
 return 0 unless ref($plan) eq 'HASH';
 if (($plan->{kind} // '') eq 'direct_span') {
  my $source = $plan->{source};
  return 0 unless defined($source) && $DIRECT_TEXT_SOURCE{$source};
  return !exists($plan->{index}) if $source eq 'entry_text' || $source eq 'match_text';
  return exists($plan->{index}) && defined($plan->{index})
   && !ref($plan->{index}) && $plan->{index} =~ /\A(?:0|[1-9][0-9]*)\z/o
 }
 return 0 unless ($plan->{kind} // '') eq 'derived_text'
  && ($plan->{policy} // '') eq 'concatenate_in_order'
  && ref($plan->{segments}) eq 'ARRAY'
  && @{$plan->{segments}};
 return !grep { !_valid_text_plan($_) || ($_->{kind} // '') ne 'direct_span' } @{$plan->{segments}}
}

sub _valid_normalized_options {
 my ($options) = @_;
 return 0 unless ref($options) eq 'HASH';
 for my $required (keys %REQUIRED_OPTION) {
  return 0 unless exists($options->{$required})
 }
 return 0 unless ref($options->{required_capabilities}) eq 'ARRAY';
 return 1
}

sub _lower_statement {
 my ($code, $args, $label) = @_;
 return $code unless ref($args) eq 'HASH';
 my $target = $args->{target};
 return $code unless defined($target) && $target =~ $FIELD_PATTERN;
 my $validated = validate_static_operands($args);
 return '$'.$target.' = undef' unless $validated->{ok};
 my $payload = JSON::PP->new->canonical(1)->encode({
  text_plan => $validated->{text_plan},
  options => $validated->{options},
 });
 my $needs_match_info = _plan_uses_match_info($validated->{text_plan});
 my $match_info = $needs_match_info
  ? '(ref($minfo) eq "HASH" ? $minfo : undef)'
  : 'undef';
 return '$'.$target.' = do { require LinkedSpec::StagedParseJob; '
  .'LinkedSpec::StagedParseJob::construct_marker('
  .'$STRING, $info, '.$match_info.', '
  ._quote_perl_string(($label // '<rule>').':parse_job').', '
  ._quote_perl_string($payload).') }'
}

sub _plan_uses_match_info {
 my ($plan) = @_;
 return 0 unless ref($plan) eq 'HASH';
 if (($plan->{kind} // '') eq 'direct_span') {
  return (($plan->{source} // '') =~ /\Amatch_(?:text|group)\z/o) ? 1 : 0
 }
 return scalar grep { _plan_uses_match_info($_) } @{$plan->{segments} // []}
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

sub _invalid {
 my ($code, %context) = @_;
 return {ok => 0, code => $code, %context}
}

sub _provenance_invalid {
 my ($operand) = @_;
 return _invalid(
  'staged_source_provenance_invalid',
  source_id => '<runtime>',
  provenance => _operand_or_missing($operand),
 )
}

sub _operand_or_missing {
 my ($operand) = @_;
 return '<missing>' unless defined($operand) && !ref($operand) && length($operand);
 return $operand
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

sub _clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode(JSON::PP->new->canonical(1)->encode($value))
}

1;

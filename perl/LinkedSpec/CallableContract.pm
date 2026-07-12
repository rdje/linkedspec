package LinkedSpec::CallableContract;

use 5.010;
use strict;
use warnings;

# One metadata seam for contextual final-codeblock acceptance. Parsers may
# recognize attached syntax generically; lowering/runtime must consult these
# contracts (or a typed user-function definition) before promoting braces.

my %BUILTIN = (
 helper => {
  with => {
   min_before_codeblock => 0,
   max_before_codeblock => 1,
   final_parameter => { name => 'callback', kind => 'codeblock' },
  },
 },
 receiver => {
  with => {
   min_before_codeblock => 0,
   max_before_codeblock => 0,
   final_parameter => { name => 'callback', kind => 'codeblock' },
  },
  walk_leaves => {
   min_before_codeblock => 0,
   max_before_codeblock => 0,
   final_parameter => { name => 'callback', kind => 'codeblock' },
  },
  map_leaves => {
   min_before_codeblock => 0,
   max_before_codeblock => 0,
   final_parameter => { name => 'callback', kind => 'codeblock' },
  },
  reduce_leaves => {
   min_before_codeblock => 1,
   max_before_codeblock => 1,
   final_parameter => { name => 'callback', kind => 'codeblock' },
  },
 },
);

sub _clone_contract {
 my ($contract) = @_;
 return undef unless ref($contract) eq 'HASH';
 return {
  min_before_codeblock => 0 + $contract->{min_before_codeblock},
  max_before_codeblock => 0 + $contract->{max_before_codeblock},
  final_parameter => { %{$contract->{final_parameter}} },
 }
}

sub builtin_contract {
 my ($surface, $name) = @_;
 return undef unless defined($surface) && defined($name);
 return undef unless ref($BUILTIN{$surface}) eq 'HASH';
 my $contract = $BUILTIN{$surface}{$name};
 return _clone_contract($contract)
}

sub user_function_contract {
 my ($definition) = @_;
 return undef unless ref($definition) eq 'HASH'
  && ($definition->{kind} // '') eq 'user_function_definition';
 my $params = $definition->{params};
 my $arity = $definition->{arity};
 return undef unless ref($params) eq 'ARRAY'
  && defined($arity) && !ref($arity) && $arity =~ /\A\d+\z/
  && $arity == @$params && @$params;
 my $kinds = $definition->{parameter_kinds};
 return undef unless ref($kinds) eq 'HASH';
 my $name = $params->[-1];
 return undef unless ($kinds->{$name} // '') eq 'codeblock';
 return undef unless keys(%$kinds) == 1;
 return {
  min_before_codeblock => $arity - 1,
  max_before_codeblock => $arity - 1,
  final_parameter => { name => $name, kind => 'codeblock' },
 }
}

sub accepts_argument_count {
 my ($contract, $before_count) = @_;
 return 0 unless ref($contract) eq 'HASH'
  && defined($before_count) && !ref($before_count) && $before_count =~ /\A\d+\z/;
 return 0 unless ref($contract->{final_parameter}) eq 'HASH'
  && ($contract->{final_parameter}{kind} // '') eq 'codeblock';
 return $before_count >= $contract->{min_before_codeblock}
  && $before_count <= $contract->{max_before_codeblock} ? 1 : 0
}

sub contextual_argument_from_block {
 my ($block) = @_;
 return undef unless ref($block) eq 'HASH' && ($block->{kind} // '') eq 'block_value';
 my $source = $block->{source} // '';
 my $span = $block->{source_span};
 my $body = $block->{block};
 return undef unless ref($body) eq 'HASH' && ($body->{kind} // '') eq 'action_block';
 return {
  kind => 'codeblock_argument',
  version => 1,
  signature => {
   kind => 'callable_signature',
   version => 1,
   positional_params => [],
   rest_param => undef,
   min_arity => 0,
   max_arity => 0,
  },
  body_source => $body->{source} // '',
  body_ast => $body,
  source_text => $source,
  source_span => ref($span) eq 'HASH' ? { %$span } : { start => 0, end => length($source) },
  body_span => ref($body->{source_span}) eq 'HASH' ? { %{$body->{source_span}} } : { start => 0, end => length($body->{source} // '') },
  block => $body,
  source => $source,
 }
}

sub runtime_record_from_argument {
 my ($argument) = @_;
 return undef unless ref($argument) eq 'HASH' && ($argument->{kind} // '') eq 'codeblock_argument';
 return {
  kind => 'codeblock_literal',
  version => 1,
  signature => $argument->{signature},
  body_source => $argument->{body_source},
  body_ast => $argument->{body_ast},
  source_text => $argument->{source_text},
  source_span => $argument->{source_span},
  body_span => $argument->{body_span},
 }
}

1;

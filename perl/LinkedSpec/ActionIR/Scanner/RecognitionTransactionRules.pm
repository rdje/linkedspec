#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules
# Purpose: Scan the four authored recognition-transaction statement shapes.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules;

use 5.010;
use strict;
use warnings;

use LinkedSpec::UnicodeXIDContinue ();

sub try_scan_contract_ir_events {
 my ($id, $code) = @_;
 my %dispatch = (
  observe_recognition    => \&_scan_observation,
  recognition_checkpoint => \&_scan_checkpoint,
  recognize_once         => \&_scan_attempt,
  recognition_commit     => \&_scan_commit,
  recognition_rollback   => \&_scan_rollback,
 );
 my $scanner = $dispatch{$id};
 return undef unless ref($scanner) eq 'CODE';
 return $scanner->($code)
}

# Only the unevaluated call's rule label uses the pinned rule-name class.
# Result, token and observation-target variables keep their own grammar.
sub _static_rule_callee {
 my ($operand) = @_;
 return undef unless defined($operand) && !ref($operand)
  && $operand =~ /\Acall\s*\(\s*(.*?)\s*\)\z/s;
 my $callee = $1;
 return LinkedSpec::UnicodeXIDContinue::is_xid_continue_string($callee)
  ? $callee : undef
}

sub _scan_observation {
 my ($code) = @_;
 my @events;
 my $scan = _statement_scan_input($code);
 my $statement_index = 0;
 for my $statement (@{$scan->{statements}}) {
  my $frame = $scan->{source_frames}[$statement_index++];
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw)
   && $raw =~ /\A(?<result>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<source>observe_recognition\s*\(.*\))\z/so;
  my ($result, $source) = ($+{result}, $+{source});
  my $call = _parse_method_function_expr($source);
  next unless ref($call) eq 'HASH' && ($call->{method} // '') eq 'observe_recognition';
  my $args = $call->{args};
  my $target = ref($args) eq 'ARRAY' && @$args ? _trim_action_ir_value($args->[0]) : undef;
  my $operand = ref($args) eq 'ARRAY' && @$args > 1 ? _trim_action_ir_value($args->[1]) : undef;
  my $callee = _static_rule_callee($operand);
  my $operand_kind = !defined($operand) ? 'missing'
   : $operand =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o ? 'bare_value'
   : $operand =~ /\Acall\s*\(/o ? 'call_expression'
   : 'value_expression';
  push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({
   raw => $raw,
   args => {
    result => $result,
    target => defined($target) ? $target : '',
    operand => defined($operand) ? $operand : '',
    ((ref($args) ne 'ARRAY' || @$args != 2)
     ? (argument_count => ref($args) eq 'ARRAY' ? scalar(@$args) : 0) : ()),
    (!defined($callee) ? (operand_kind => $operand_kind) : ()),
    (defined($callee) ? (callee => $callee) : ()),
   },
  }, $frame);
 }
 return \@events
}

sub _statements {
 my ($code) = @_;
 return @{_split_action_ir_statements($code)}
}

sub _statement_scan_input {
 my ($code) = @_;
 return {statements => [_statements($code)], source_frames => []}
  unless ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE';
 my $framed = LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(
  \&_split_action_ir_statements, $code,
 );
 # Preserve the original list snapshot before any trim/operand callback runs.
 return {statements => [@{$framed->{statements}}], source_frames => $framed->{source_frames}}
}

sub _scan_checkpoint {
 my ($code) = @_;
 my @events;
 my $scan = _statement_scan_input($code);
 my $statement_index = 0;
 for my $statement (@{$scan->{statements}}) {
  my $frame = $scan->{source_frames}[$statement_index++];
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\A(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*recognition_checkpoint\s*\(\s*\)\z/o;
  push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event(
   {raw => $raw, args => {token => $+{token}}}, $frame,
  );
 }
 return \@events
}

sub _scan_attempt {
 my ($code) = @_;
 my @events;
 my $scan = _statement_scan_input($code);
 my $statement_index = 0;
 for my $statement (@{$scan->{statements}}) {
  my $frame = $scan->{source_frames}[$statement_index++];
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\A(?<matched>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*recognize_once\s*\(\s*(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*,\s*(?<operand>.+)\s*\)\z/so;
  my ($matched, $token, $raw_operand) = ($+{matched}, $+{token}, $+{operand});
  my $operand = _trim_action_ir_value($raw_operand);
  my $callee = _static_rule_callee($operand);
  push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({
   raw => $raw,
   args => {
    matched => $matched,
    token   => $token,
    operand => $operand,
    (defined($callee) ? (callee => $callee) : ()),
   },
  }, $frame);
 }
 return \@events
}

sub _scan_commit {
 my ($code) = @_;
 my @events;
 my $scan = _statement_scan_input($code);
 my $statement_index = 0;
 for my $statement (@{$scan->{statements}}) {
  my $frame = $scan->{source_frames}[$statement_index++];
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\A(?<payload>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*recognition_commit\s*\(\s*(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*\)\z/o;
  push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event(
   {raw => $raw, args => {payload => $+{payload}, token => $+{token}}}, $frame,
  );
 }
 return \@events
}

sub _scan_rollback {
 my ($code) = @_;
 my @events;
 my $scan = _statement_scan_input($code);
 my $statement_index = 0;
 for my $statement (@{$scan->{statements}}) {
  my $frame = $scan->{source_frames}[$statement_index++];
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\Arecognition_rollback\s*\(\s*(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*\)\z/o;
  push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event(
   {raw => $raw, args => {token => $+{token}}}, $frame,
  );
 }
 return \@events
}

1;

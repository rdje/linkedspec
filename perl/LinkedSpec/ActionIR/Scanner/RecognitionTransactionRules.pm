#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules
# Purpose: Scan the four authored recognition-transaction statement shapes.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules;

use 5.010;
use strict;
use warnings;

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

sub _scan_observation {
 my ($code) = @_;
 my @events;
 for my $statement (_statements($code)) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw)
   && $raw =~ /\A(?<result>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<source>observe_recognition\s*\(.*\))\z/so;
  my ($result, $source) = ($+{result}, $+{source});
  my $call = _parse_method_function_expr($source);
  next unless ref($call) eq 'HASH' && ($call->{method} // '') eq 'observe_recognition';
  my $args = $call->{args};
  my $target = ref($args) eq 'ARRAY' && @$args ? _trim_action_ir_value($args->[0]) : undef;
  my $operand = ref($args) eq 'ARRAY' && @$args > 1 ? _trim_action_ir_value($args->[1]) : undef;
  my $callee = defined($operand)
   && $operand =~ /\Acall\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)\z/o
   ? $1
   : undef;
  my $operand_kind = !defined($operand) ? 'missing'
   : $operand =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o ? 'bare_value'
   : $operand =~ /\Acall\s*\(/o ? 'call_expression'
   : 'value_expression';
  push @events, {
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
  };
 }
 return \@events
}

sub _statements {
 my ($code) = @_;
 return @{_split_action_ir_statements($code)}
}

sub _scan_checkpoint {
 my ($code) = @_;
 my @events;
 for my $statement (_statements($code)) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\A(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*recognition_checkpoint\s*\(\s*\)\z/o;
  push @events, {raw => $raw, args => {token => $+{token}}};
 }
 return \@events
}

sub _scan_attempt {
 my ($code) = @_;
 my @events;
 for my $statement (_statements($code)) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\A(?<matched>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*recognize_once\s*\(\s*(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*,\s*(?<operand>.+)\s*\)\z/so;
  my ($matched, $token, $raw_operand) = ($+{matched}, $+{token}, $+{operand});
  my $operand = _trim_action_ir_value($raw_operand);
  my $callee = defined($operand) && $operand =~ /\Acall\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)\z/o
   ? $1
   : undef;
  push @events, {
   raw => $raw,
   args => {
    matched => $matched,
    token   => $token,
    operand => $operand,
    (defined($callee) ? (callee => $callee) : ()),
   },
  };
 }
 return \@events
}

sub _scan_commit {
 my ($code) = @_;
 my @events;
 for my $statement (_statements($code)) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\A(?<payload>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*recognition_commit\s*\(\s*(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*\)\z/o;
  push @events, {raw => $raw, args => {payload => $+{payload}, token => $+{token}}};
 }
 return \@events
}

sub _scan_rollback {
 my ($code) = @_;
 my @events;
 for my $statement (_statements($code)) {
  my $raw = _trim_action_ir_value($statement);
  next unless defined($raw) && $raw =~ /\Arecognition_rollback\s*\(\s*(?<token>[A-Za-z_][A-Za-z0-9_]*)\s*\)\z/o;
  push @events, {raw => $raw, args => {token => $+{token}}};
 }
 return \@events
}

1;

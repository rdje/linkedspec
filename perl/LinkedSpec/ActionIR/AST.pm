package LinkedSpec::ActionIR::AST;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::AST
# Purpose : Additive ActionIR AST facade. The parser seam is intentionally
#           read-only at introduction time; existing RewritePipeline lowering
#           remains authoritative until later migration leaves switch consumers.
#------------------------------------------------------------------------------

sub source_span {
 my ($start, $end) = @_;
 $start = 0 unless defined $start;
 $end = $start unless defined $end;
 return {
  start => 0 + $start,
  end   => 0 + $end,
 }
}

sub node {
 my ($kind, %fields) = @_;
 die "(LinkedSpec::ActionIR::AST::node) -E- missing AST node kind"
  unless defined($kind) && length($kind);
 return {
  kind => $kind,
  %fields,
 }
}

sub parse_action_block {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::ActionIR::AST::Parser',
  'parse_action_block',
  @args,
 )
}

sub parse_action_statement {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::ActionIR::AST::Parser',
  'parse_action_statement',
  @args,
 )
}

sub parse_action_expr {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::ActionIR::AST::Parser',
  'parse_action_expr',
  @args,
 )
}

1;

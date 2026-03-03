package LinkedSpec::Runtime;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::BootstrapSpec ();
use LinkedSpec::Compiler ();
use LinkedSpec::SpecEntry ();

#------------------------------------------------------------------------------
# Runtime parser state (bootstrap descriptor + mutable top-rule tracking)
#------------------------------------------------------------------------------
my ($spec_descr, $bootstrap_rule_index_ref, $gdata) = LinkedSpec::BootstrapSpec::build_bootstrap_spec();
my %bootstrap_rule_index = %$bootstrap_rule_index_ref;
my $top_rule;

our $PARSER_SOURCE_EMIT_CB;

sub _emit_parser_source_line {
 my ($chunk) = @_;
 return unless ref($PARSER_SOURCE_EMIT_CB) eq 'CODE';
 $PARSER_SOURCE_EMIT_CB->($chunk);
 return
}

#------------------------------------------------------------------------------
# Function: run_get
# Purpose : Own `Get` entrypoint orchestration glue for parser-source capture
#           and compiler pipeline invocation against runtime bootstrap state.
# Args    : ($spec_content_ref, $option_hashref)
# Returns : parser coderef | descriptor hashref | undef
#------------------------------------------------------------------------------
sub run_get {
 my ($spec_content_ref, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 my @parser_source_chunks;
 local $PARSER_SOURCE_EMIT_CB = $option->{dump_parser_source} ? sub {
  my ($chunk) = @_;
  push @parser_source_chunks, $chunk;
 } : undef;
 return LinkedSpec::Compiler::run_get_pipeline(
  $spec_content_ref,
  $option,
  {
   spec_descr => $spec_descr,
   bootstrap_rule_index => \%bootstrap_rule_index,
   gdata => $gdata,
   emit_parser_source_line => \&_emit_parser_source_line,
   top_rule_ref => \$top_rule,
   parser_source_chunks_ref => \@parser_source_chunks,
  }
 )
}

#------------------------------------------------------------------------------
# Function: run_get_from_args
# Purpose : Normalize raw `Get` entrypoint arguments and delegate to run_get.
# Args    : ($spec_content_ref, %options)
# Returns : parser coderef | descriptor hashref | undef
#------------------------------------------------------------------------------
sub run_get_from_args {
 my @args = @_;
 my $spec_content_ref = $args[0];
 my %option = @args[1 .. $#args];
 return run_get($spec_content_ref, \%option)
}

#------------------------------------------------------------------------------
# Function: compile_spec_entry
# Purpose : Own spec_entry orchestration glue including top-rule propagation.
# Args    : ($einfo)
# Returns : ($label, $rule_info_hashref) or undef
#------------------------------------------------------------------------------
sub compile_spec_entry {
 my ($einfo) = @_;
 my ($label, $info, $top_rule_candidate) = LinkedSpec::SpecEntry::compile_spec_entry(
  $einfo,
  {
   emit_parser_source_line => \&_emit_parser_source_line,
  }
 );
 return undef unless defined($label) && ref($info) eq 'HASH';
 $top_rule = $top_rule_candidate if defined $top_rule_candidate;
 return ($label, $info)
}

1;

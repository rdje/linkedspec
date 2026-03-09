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
# Runtime parser state helpers (per-run mutable context only)
#------------------------------------------------------------------------------
sub _emit_parser_source_line {
 my ($runtime_ctx, $chunk) = @_;
 my $emit = (ref($runtime_ctx) eq 'HASH') ? $runtime_ctx->{emit_parser_source_line} : undef;
 return unless ref($emit) eq 'CODE';
 $emit->($chunk);
 return
}

sub _build_runtime_context {
 my ($option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 my @parser_source_chunks;
 my $ctx = {
  top_rule => undef,
  parser_source_chunks_ref => \@parser_source_chunks,
 };
 if ($option->{dump_parser_source}) {
  $ctx->{emit_parser_source_line} = sub {
   my ($chunk) = @_;
   push @parser_source_chunks, $chunk;
  };
 }
 return $ctx
}

#------------------------------------------------------------------------------
# Function: run_get
# Purpose : Own `Get` entrypoint orchestration glue for parser-source capture
#           and compiler pipeline invocation against injected bootstrap parsing.
# Args    : ($spec_content_ref, $option_hashref)
# Returns : parser coderef | descriptor hashref | undef
#------------------------------------------------------------------------------
sub run_get {
 my ($spec_content_ref, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 my $runtime_ctx = _build_runtime_context($option);
 return LinkedSpec::Compiler::run_get_pipeline(
  $spec_content_ref,
  $option,
  {
   bootstrap_parse => \&LinkedSpec::BootstrapSpec::run_bootstrap_parse,
   compile_spec_entry => sub { return LinkedSpec::SpecEntry::compile_spec_entry($_[0], { runtime_ctx => $runtime_ctx }) },
   runtime_ctx => $runtime_ctx,
  }
 )
}

#------------------------------------------------------------------------------
# Function: run_get_from_args
# Purpose : Compatibility wrapper that normalizes raw `Get` entrypoint
#           arguments and delegates to `run_get(...)`.
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
# Purpose : Compatibility wrapper around `LinkedSpec::SpecEntry` injected-state
#           compilation for callers that still route through Runtime.
# Args    : ($einfo, $runtime_ctx)
# Returns : ($label, $rule_info_hashref) or undef
#------------------------------------------------------------------------------
sub compile_spec_entry {
 my ($einfo, $runtime_ctx) = @_;
 my ($label, $info, $top_rule_candidate) = LinkedSpec::SpecEntry::compile_spec_entry($einfo, { runtime_ctx => $runtime_ctx });
 return undef unless defined($label) && ref($info) eq 'HASH';
 return ($label, $info)
}

1;

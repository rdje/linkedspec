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
# Runtime parser state (cached bootstrap descriptor + per-run mutable context)
#------------------------------------------------------------------------------
my ($bootstrap_spec_descr, $bootstrap_rule_index_ref, $bootstrap_gdata) = LinkedSpec::BootstrapSpec::build_bootstrap_spec();
my $BOOTSTRAP_STATE = {
 spec_descr => $bootstrap_spec_descr,
 bootstrap_rule_index => { %$bootstrap_rule_index_ref },
 gdata => $bootstrap_gdata,
};

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
#           and compiler pipeline invocation against runtime bootstrap state.
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
   spec_descr => $BOOTSTRAP_STATE->{spec_descr},
   bootstrap_rule_index => $BOOTSTRAP_STATE->{bootstrap_rule_index},
   gdata => $BOOTSTRAP_STATE->{gdata},
   compile_spec_entry => sub { return compile_spec_entry($_[0], $runtime_ctx) },
   emit_parser_source_line => sub { return _emit_parser_source_line($runtime_ctx, @_) },
   top_rule_ref => \$runtime_ctx->{top_rule},
   parser_source_chunks_ref => $runtime_ctx->{parser_source_chunks_ref},
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
# Args    : ($einfo, $runtime_ctx)
# Returns : ($label, $rule_info_hashref) or undef
#------------------------------------------------------------------------------
sub compile_spec_entry {
 my ($einfo, $runtime_ctx) = @_;
 my ($label, $info, $top_rule_candidate) = LinkedSpec::SpecEntry::compile_spec_entry(
  $einfo,
  {
   emit_parser_source_line => sub { return _emit_parser_source_line($runtime_ctx, @_) },
  }
 );
 return undef unless defined($label) && ref($info) eq 'HASH';
 if (ref($runtime_ctx) eq 'HASH' && defined $top_rule_candidate) {
  $runtime_ctx->{top_rule} = $top_rule_candidate;
 }
 return ($label, $info)
}

1;

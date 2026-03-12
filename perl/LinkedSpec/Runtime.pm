package LinkedSpec::Runtime;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::Runtime::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

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
 return _call_preserving_err(sub {
  _require_pkg('LinkedSpec::Compiler') unless LinkedSpec::Compiler->can('run_get_pipeline');
  return LinkedSpec::Compiler::run_get_pipeline(
   $spec_content_ref,
   $option,
   {
    runtime_ctx => $runtime_ctx,
   }
  )
 })
}

1;

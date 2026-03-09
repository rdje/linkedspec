package LinkedSpec::ParserFactory;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ParserFactory::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _require_value_dep {
 my ($deps, $name) = @_;
 die "(LinkedSpec::ParserFactory::_require_value_dep) -E- missing dependency value '$name'"
  unless ref($deps) eq 'HASH' && exists $deps->{$name};
 return $deps->{$name}
}

#------------------------------------------------------------------------------
# Function: run_get_parser
# Purpose : Orchestrate public parser-factory flow: trace setup, spec validation,
#           resolution/loading and compilation via injected runtime compile callback.
# Args    : ($spec_name, $option_hashref, $deps)
# Returns : parser coderef or undef
#------------------------------------------------------------------------------
sub run_get_parser {
 my ($spec_name, $option, $deps) = @_;
 my %opt_hash = (ref($option) eq 'HASH') ? %{$option} : ();

 my $apply_trace_options = _require_dep($deps, 'apply_trace_options');
 my $trace_enter = _require_dep($deps, 'trace_enter');
 my $trace_exit = _require_dep($deps, 'trace_exit');
 my $trace_decision = _require_dep($deps, 'trace_decision');
 my $validate_spec_name = _require_dep($deps, 'validate_spec_name');
 my $resolve_spec_path = _require_dep($deps, 'resolve_spec_path');
 my $load_spec_content = _require_dep($deps, 'load_spec_content');
 my $compile_spec = _require_dep($deps, 'compile_spec');
 my $dump_low = _require_value_dep($deps, 'dump_low');
 my $dump_medium = _require_value_dep($deps, 'dump_medium');

 $apply_trace_options->(\%opt_hash) if %opt_hash;
 my $trace_scope = $trace_enter->('LinkedSpec::get_parser', {
  spec_name => $spec_name,
  option_keys => [sort keys %opt_hash],
 }, $dump_low);

 unless ($validate_spec_name->($spec_name, $trace_scope)) {
  return undef
 }

 my $spec_path = $resolve_spec_path->($spec_name, $trace_scope);
 return undef unless defined $spec_path;

 my $content = $load_spec_content->($spec_path, $trace_scope);
 return undef unless defined $content;
 my %forward_opt_hash = %opt_hash;
 delete $forward_opt_hash{trace_reset_log} if exists $forward_opt_hash{trace_reset_log};
 my $parser = $compile_spec->(\$content, \%forward_opt_hash);
 $trace_decision->('get_parser_compilation_result', defined($parser) ? 1 : 0, defined($parser) ? 'parser coderef generated' : 'Get() returned undef', $dump_medium);
 $trace_exit->(
  $trace_scope,
  {
   status => defined($parser) ? 'ok' : 'error',
   spec_path => $spec_path,
   parser_ref => ref($parser) || '',
  },
  $dump_low
 );
 return $parser;
}

1;

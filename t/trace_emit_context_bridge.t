#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use File::Temp qw(tempdir);
use IPC::Open3;
use Symbol qw(gensym);

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 my $perl_lib = File::Spec->catdir($repo_root, 'perl');
 unshift @INC, $perl_lib unless grep { defined($_) && $_ eq $perl_lib } @INC;
}

use LinkedSpec;
use LinkedSpec::RuleIR::EmitContext;
use LinkedSpec::Trace;

sub _slurp {
 my ($path) = @_;
 open(my $fh, '<', $path) or die "cannot read '$path': $!";
 local $/;
 my $content = <$fh>;
 close($fh);
 return defined($content) ? $content : '';
}

sub _debug_trace_path {
 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'trace.log');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'debug',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );
 return $trace_path;
}

sub _empty_rule_ir {
 my (%overrides) = @_;
 return {
  label => 'Top',
  node_type => 'AND',
  REs => ['a'],
  code_blocks => {
   ICODE => [],
   ECODE => [],
   EXCODE => [],
   ITCODE => [],
   LXCODE => [],
   LSCODE => [],
   LECODE => [],
  },
  acode_entries => [],
  bcode_entries => [],
  and_icode_entries => [],
  %overrides,
 };
}

subtest 'compat rewrite traces retired colon scalar-slot diagnostic' => sub {
 plan tests => 6;

 my $trace_path = _debug_trace_path();
 my $rewritten = LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat('Top', ':name');

 like($rewritten, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read/, 'retired colon scalar slot emits the migration diagnostic');
 my $trace = _slurp($trace_path);
 like($trace, qr/ENTER LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat:Top/, 'trace enters the compat rewrite boundary');
 like($trace, qr/EXIT LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat:Top/, 'trace exits the compat rewrite boundary');
 like($trace, qr/DECISION emit_context:rewrite_action_code_for_compat:Top:compat_bare_type_memory => TAKEN/, 'trace reports compat bare-type memory collection');
 like($trace, qr/DECISION emit_context:rewrite_action_code_for_compat:Top:retired_colon_scalar_slot => TAKEN/, 'trace reports the retired colon diagnostic path');
 unlike($trace, qr/scalar_slot_fallback/, 'trace no longer reports the removed scalar-slot fallback path');
};

subtest 'compat rewrite hard-rejects removed aggregate selectors and preserves canonical paths' => sub {
 plan tests => 9;

 my $aggregate_trace_path = _debug_trace_path();
 my $aggregate = eval {
  LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat('Top', 'array(items)')
 };
 my $aggregate_error = $@;
 ok(!defined($aggregate), 'removed aggregate selector has no compatibility lowering result');
 like($aggregate_error, qr/aggregate_selector_removed/, 'removed aggregate selector reports the neutral code');
 like($aggregate_error, qr/surface=array identifier=items replacement=items/, 'removed aggregate selector reports all neutral fields');
 my $aggregate_trace = _slurp($aggregate_trace_path);
 like($aggregate_trace, qr/DECISION emit_context:rewrite_action_code_for_compat:Top:retired_colon_scalar_slot => SKIPPED/, 'trace reports skipped retired-colon path for aggregate wrapper');
 like($aggregate_trace, qr/DECISION actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:aggregate_selector_removed => TAKEN/, 'trace reports hard rejection at the canonical ActionIR boundary');
 unlike($aggregate_trace, qr/aggregate_wrapper_fallback/, 'removed aggregate compatibility fallback is absent');

 my $pipeline_trace_path = _debug_trace_path();
 my $pipeline = LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat('Top', 'return(name)');
 is($pipeline, 'return $name', 'canonical rewrite pipeline still lowers bare return(name)');
 my $pipeline_trace = _slurp($pipeline_trace_path);
 like($pipeline_trace, qr/ENTER LinkedSpec::RuleIR::EmitContext::rewrite_action_code_with_diagnostics:Top/, 'trace enters the diagnostic rewrite boundary');
 like($pipeline_trace, qr/DECISION emit_context:rewrite_action_code_for_compat:Top:canonical_rewrite_pipeline => TAKEN/, 'trace reports canonical pipeline use');
};

subtest 'rule emit context traces rewrite orchestration and dependency injections' => sub {
 plan tests => 10;

 my $trace_path = _debug_trace_path();
 my $rule_ir = _empty_rule_ir(
  acode_entries => [{ code => 'return(name)', relabel => 'Top', reidx => 0 }],
  function_registry => { helper_x => { params => [], body => 'return("x")' } },
 );
 my $emit_ctx = LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($rule_ir);

 is($emit_ctx->{label}, 'Top', 'emit context still preserves the label');
 is($emit_ctx->{ACODEs}[0], 'return $name', 'emit context still rewrites ACODE entries');
 is($emit_ctx->{action_rewriter_meta}{language_agnostic_action_ir_ready}, 1, 'emit context metadata still reports ActionIR-ready code');

 my $trace = _slurp($trace_path);
 like($trace, qr/ENTER LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context:Top/, 'trace enters the rule emit-context build boundary');
 like($trace, qr/DECISION emit_context:build_rule_ir_emit_context:Top:function_registry_available => TAKEN/, 'trace reports current function registry availability');
 like($trace, qr/DECISION emit_context:build_rule_ir_emit_context:Top:bare_type_memory_collected => TAKEN/, 'trace reports bare-type memory collection');
 like($trace, qr/DECISION emit_context:build_rule_ir_emit_context:Top:rewrite_rules_built => TAKEN/, 'trace reports rewrite-rule construction');
 like($trace, qr/DECISION emit_context:owner_deps:method_lowering:inject_function_registry => TAKEN/, 'trace reports function-registry injection into method lowering');
 like($trace, qr/DECISION emit_context:rewrite_action_code_with_diagnostics:Top:canonical_raw_perl_fallback => SKIPPED/, 'trace reports canonical fallback status for rewritten code');
 like($trace, qr/EXIT LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context:Top/, 'trace exits the rule emit-context build boundary');
};

subtest 'EmitContext remains Trace-lazy until trace is explicitly loaded' => sub {
 plan tests => 4;

 my ($exit_code, $out, $err) = _run_perl_snippet(<<'PERL');
require LinkedSpec::RuleIR::EmitContext;
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_EAGER__\n" : "__TRACE_STILL_LAZY__\n";
my $rewritten = LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat("Top", ":name");
print $rewritten =~ /colon_scalar_slot_use_bare_read/ ? "__REWRITE_OK__\n" : "__REWRITE_BAD__$rewritten\n";
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_AFTER_REWRITE__\n" : "__TRACE_STILL_UNLOADED_AFTER_REWRITE__\n";
PERL

 is($exit_code, 0, 'subprocess exits cleanly');
 like($out, qr/__TRACE_STILL_LAZY__/, 'require keeps Trace unloaded');
 like($out, qr/__REWRITE_OK__\n__TRACE_STILL_UNLOADED_AFTER_REWRITE__/, 'compat rewrite stays Trace-lazy without explicit trace configuration');
 is($err, '', 'subprocess does not emit stderr');
};

sub _run_perl_snippet {
 my ($snippet) = @_;
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 my $perl_lib = File::Spec->catdir($repo_root, 'perl');
 my $err = gensym();
 my $pid = open3(undef, my $out_fh, $err, $^X, '-I', $perl_lib, '-e', $snippet);
 my ($out, $stderr);
 {
  local $/;
  $out = <$out_fh>;
 }
 {
  local $/;
  $stderr = <$err>;
 }
 waitpid($pid, 0);
 my $exit_code = $? >> 8;
 return ($exit_code, $out // '', $stderr // '');
}

LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

done_testing();

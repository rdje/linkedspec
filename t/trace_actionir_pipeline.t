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

sub _rewrite_with_trace {
 my ($code) = @_;
 my $trace_path = _debug_trace_path();
 my ($rewritten, $diag) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top', $code, undef);
 return ($rewritten, $diag, _slurp($trace_path));
}

subtest 'canonical return traces scanner, canonical queue, and rewrite decisions' => sub {
 plan tests => 9;

 my ($rewritten, $diag, $trace) = _rewrite_with_trace('return(:name)');

 is($rewritten, 'return $name', 'return(:name) still lowers through the canonical pipeline');
 is($diag->{helper_action_ir_count}, 1, 'helper event count is unchanged');
 is($diag->{canonical_action_ir_fallback_count}, 0, 'canonical return has no raw fallback');
 like($trace, qr/ENTER LinkedSpec::ActionIR::RewritePipeline::rewrite_action_code_with_diagnostics:Top/, 'trace enters the ActionIR rewrite-pipeline owner boundary');
 like($trace, qr/EXIT LinkedSpec::ActionIR::RewritePipeline::rewrite_action_code_with_diagnostics:Top/, 'trace exits the ActionIR rewrite-pipeline owner boundary');
 like($trace, qr/DECISION actionir:scanner_core:scan_contract_ir_events:return_general:events_found => TAKEN/, 'trace reports scanner-core helper event discovery');
 like($trace, qr/DECISION actionir:diagnostics:collect_action_helper_ir_nodes:action_code:helper_ir_events_found => TAKEN/, 'trace reports diagnostic helper-node collection');
 like($trace, qr/DECISION actionir:canonical_events:build_canonical_action_ir_events:Top:statement_queue_match => TAKEN/, 'trace reports canonical queue matching');
 like($trace, qr/DECISION actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:statement_rewritten => TAKEN/, 'trace reports canonical statement rewriting');
};

subtest 'raw Perl fallback traces canonical and rewrite fallback decisions' => sub {
 plan tests => 5;

 my ($rewritten, $diag, $trace) = _rewrite_with_trace('my $x = 1');

 is($rewritten, 'my $x = 1', 'raw Perl fallback still preserves host code');
 is($diag->{canonical_action_ir_fallback_count}, 1, 'raw fallback count is unchanged');
 like($trace, qr/DECISION actionir:canonical_events:build_canonical_action_ir_events:Top:raw_perl_fallback => TAKEN/, 'trace reports canonical RAW_PERL fallback creation');
 like($trace, qr/DECISION actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:raw_perl_fallback => TAKEN/, 'trace reports rewrite RAW_PERL fallback preservation');
 like($trace, qr/DECISION actionir:rewrite_pipeline:rewrite_action_code_with_diagnostics:Top:canonical_raw_perl_fallback => TAKEN/, 'trace reports the rewrite-pipeline fallback summary');
};

subtest 'unsupported helper diagnostics trace unresolved-helper handoff' => sub {
 plan tests => 5;

 my ($rewritten, $diag, $trace) = _rewrite_with_trace('return(mystery(:name))');

 like($rewritten, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:mystery/, 'unsupported helper sentinel is still emitted');
 is($diag->{unresolved_helper_count}, 1, 'unresolved helper count is unchanged');
 like($trace, qr/DECISION actionir:scanner_core:scan_contract_ir_events:return_general:events_found => TAKEN/, 'trace still reports the enclosing return helper event');
 like($trace, qr/DECISION actionir:diagnostics:find_unresolved_action_helpers:action_code:unsupported_ast_helper_call => TAKEN/, 'trace reports the unsupported AST helper diagnostic');
 like($trace, qr/DECISION actionir:rewrite_pipeline:rewrite_action_code_with_diagnostics:Top:unresolved_helpers_found => TAKEN/, 'trace reports the rewrite-pipeline unresolved-helper summary');
};

subtest 'attached if traces unmatched helper events and implicit closure insertion' => sub {
 plan tests => 6;

 my $code = qq{if(true) { return("yes") }\nreturn("no")};
 my ($rewritten, $diag, $trace) = _rewrite_with_trace($code);

 is($rewritten, qq{if (1) { return "yes";\n} return "no"}, 'attached if still inserts the implicit close before the next statement');
 is($diag->{canonical_action_ir_fallback_count}, 0, 'attached if has no raw fallback');
 is($diag->{unresolved_helper_count}, 0, 'attached if has no unresolved helpers');
 like($trace, qr/DECISION actionir:canonical_events:build_canonical_action_ir_events:Top:unmatched_helper_event => TAKEN/, 'trace reports unmatched nested helper events');
 like($trace, qr/DECISION actionir:rewrite_pipeline:implicit_if:Top:closure_inserted_before_statement => TAKEN/, 'trace reports implicit closure insertion');
 like($trace, qr/DECISION actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:source_span_missing => TAKEN/, 'trace reports skipped unmatched nested event replacement');
};

subtest 'ActionIR trace helper keeps LinkedSpec::Trace lazy until explicitly loaded' => sub {
 plan tests => 4;

 my ($exit_code, $out, $err) = _run_perl_snippet(<<'PERL');
require LinkedSpec::ActionIR::Scanner;
require LinkedSpec::ActionIR::CanonicalEvents;
require LinkedSpec::ActionIR::Diagnostics;
require LinkedSpec::ActionIR::RewritePipeline;
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_EAGER__\n" : "__TRACE_STILL_LAZY__\n";
require LinkedSpec::RuleIR::EmitContext;
my $rewritten = LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat("Top", "return(:name)");
print $rewritten eq 'return $name' ? "__REWRITE_OK__\n" : "__REWRITE_BAD__$rewritten\n";
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_AFTER_REWRITE__\n" : "__TRACE_STILL_UNLOADED_AFTER_REWRITE__\n";
PERL

 is($exit_code, 0, 'subprocess exits cleanly');
 like($out, qr/__TRACE_STILL_LAZY__/, 'requiring ActionIR owners keeps Trace unloaded');
 like($out, qr/__REWRITE_OK__\n__TRACE_STILL_UNLOADED_AFTER_REWRITE__/, 'ActionIR rewrite stays Trace-lazy without explicit trace configuration');
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

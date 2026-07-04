#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use File::Temp qw(tempdir);

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 my $perl_lib = File::Spec->catdir($repo_root, 'perl');
 unshift @INC, $perl_lib unless grep { defined($_) && $_ eq $perl_lib } @INC;
}

use LinkedSpec;
use LinkedSpec::RuleIR;
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

sub _capture_stdout (&) {
 my ($code) = @_;
 my $stdout = '';
 open(my $capture, '>', \$stdout) or die "cannot capture stdout: $!";
 {
  local *STDOUT = $capture;
  $code->();
 }
 close($capture);
 return $stdout;
}

subtest 'RuleIR execution metadata traces handler variant and execution shape' => sub {
 plan tests => 8;

 my $trace_path = _debug_trace_path();
 my $meta = LinkedSpec::RuleIR::_build_rule_execution_meta(
  label => 'Top',
  node_type => 'AND',
  regex_count => 2,
  acode_count => 2,
  bcode_count => 0,
 );

 is($meta->{handler_variant}, 'AND_ACODE', 'metadata still selects the AND_ACODE handler variant');
 is($meta->{action_mode}, 'action', 'metadata still reports action mode');
 is($meta->{execution_shape}, 'and_sequence_loop', 'metadata still reports AND sequence execution shape');
 ok($meta->{uses_loop}, 'metadata still reports loop execution for AND_ACODE');

 my $trace = _slurp($trace_path);
 like($trace, qr/DECISION rule_ir:select:Top:handler_variant_AND_ACODE => TAKEN/, 'trace reports selected handler variant');
 like($trace, qr/handler_variant=AND_ACODE/, 'trace includes handler variant context');
 like($trace, qr/DECISION rule_ir:meta:Top:action_mode_action => TAKEN/, 'trace reports planned action mode');
 like($trace, qr/DECISION rule_ir:meta:Top:execution_shape_and_sequence_loop => TAKEN/, 'trace reports planned execution shape');
};

subtest 'RuleIR collection traces lifecycle routing and split-boundary markers' => sub {
 plan tests => 13;

 my $trace_path = _debug_trace_path();
 my $rule_ir = LinkedSpec::RuleIR::_collect_rule_ir([
  [ 'ELABEL_INITIAL', 'Seq', 'AND', undef, undef ],
  [ 'RE', 'foo' ],
  [ 'ICODE', 'return("A")' ],
  [ 'LXCODE', 'return("MISS")' ],
  [ 'MOVE_POS' ],
  [ 'MARK_POS', { name => 'body_start' } ],
 ]);

 is($rule_ir->{label}, 'Seq', 'RuleIR still collects the rule label');
 is($rule_ir->{top_rule}, 'Seq', 'RuleIR still records the top rule');
 is(scalar(@{$rule_ir->{and_icode_entries}}), 1, 'AND per-regex lifecycle code still routes to and_icode_entries');
 is(scalar(@{$rule_ir->{code_blocks}{LXCODE}}), 1, 'standalone LXCODE still routes to lifecycle code');
 is(scalar(@{$rule_ir->{code_blocks}{LECODE}}), 2, 'move and mark markers still append LECODE entries');

 my $trace = _slurp($trace_path);
 like($trace, qr/DECISION rule_ir:collect:Seq:entry_label => TAKEN/, 'trace reports label collection');
 like($trace, qr/DECISION rule_ir:collect:Seq:entry_top_rule => TAKEN/, 'trace reports top-rule collection');
 like($trace, qr/DECISION rule_ir:collect:Seq:regex_entry => TAKEN/, 'trace reports regex collection');
 like($trace, qr/DECISION rule_ir:collect:Seq:per_regex_lifecycle_and_icode => TAKEN/, 'trace reports AND per-regex lifecycle routing');
 like($trace, qr/DECISION rule_ir:collect:Seq:standalone_lifecycle => TAKEN/, 'trace reports standalone lifecycle routing');
 like($trace, qr/DECISION rule_ir:collect:Seq:move_pos_lecode => TAKEN/, 'trace reports MOVE_POS lowering');
 like($trace, qr/DECISION rule_ir:collect:Seq:mark_pos_lecode => TAKEN/, 'trace reports MARK_POS lowering');
 like($trace, qr/mark_name=body_start/, 'trace includes named-mark context');
};

subtest 'RuleIR collection traces REP and OR per-regex lifecycle ACODE routing' => sub {
 plan tests => 6;

 my $trace_path = _debug_trace_path();
 my $rep_ir = LinkedSpec::RuleIR::_collect_rule_ir([
  [ 'ELABEL', 'Plus', 'REP_', 1, undef ],
  [ 'RE', 'a' ],
  [ 'ICODE', 'return("A")' ],
 ]);
 my $or_ir = LinkedSpec::RuleIR::_collect_rule_ir([
  [ 'ELABEL', 'Choice', 'OR', undef, undef ],
  [ 'RE', 'b' ],
  [ 'ICODE', 'return("B")' ],
 ]);

 is(scalar(@{$rep_ir->{acode_entries}}), 1, 'REP per-regex lifecycle code still routes to ACODE');
 is(scalar(@{$or_ir->{acode_entries}}), 1, 'OR per-regex lifecycle code still routes to ACODE');

 my $trace = _slurp($trace_path);
 like($trace, qr/DECISION rule_ir:collect:Plus:per_regex_lifecycle_acode => TAKEN/, 'trace reports REP lifecycle ACODE routing');
 like($trace, qr/node_type=REP_/, 'trace includes REP node type context');
 like($trace, qr/DECISION rule_ir:collect:Choice:per_regex_lifecycle_acode => TAKEN/, 'trace reports OR lifecycle ACODE routing');
 like($trace, qr/node_type=OR/, 'trace includes OR node type context');
};

subtest 'RuleIR validation traces valid and mixed action-mode decisions' => sub {
 plan tests => 7;

 my $trace_path = _debug_trace_path();
 my $valid = LinkedSpec::RuleIR::_validate_rule_ir_or_exit(
  { label => 'Good' },
  { action_mode => 'action', acode_count => 1, bcode_count => 0 },
 );
 my $mixed;
 my $stdout = _capture_stdout {
  $mixed = LinkedSpec::RuleIR::_validate_rule_ir_or_exit(
   { label => 'Bad' },
   { action_mode => 'mixed', acode_count => 1, bcode_count => 1 },
  );
 };

 ok($valid, 'valid action mode is still accepted');
 ok(!$mixed, 'mixed action mode is still rejected');
 like($stdout, qr/Use either ACTION blocks OR BLIND CALL blocks/, 'mixed action diagnostic still prints guidance');

 my $trace = _slurp($trace_path);
 like($trace, qr/DECISION rule_ir:validate:Good:action_mode_valid => TAKEN/, 'trace reports valid action-mode decision');
 like($trace, qr/action_mode=action/, 'trace includes valid action mode context');
 like($trace, qr/DECISION rule_ir:validate:Bad:mixed_action_mode => SKIPPED/, 'trace reports rejected mixed action-mode decision');
 like($trace, qr/acode_count=1.*bcode_count=1/s, 'trace includes mixed action counts');
};

subtest 'RuleIR planning decisions appear through normal descriptor compilation trace' => sub {
 plan tests => 5;

 my $trace_path = _debug_trace_path();
 my $spec = <<'SPEC';
Top::&
 /a/ -> Top { return("A") }
SPEC

 my $descriptor = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
  trace_level => 'debug',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );
 ok(ref($descriptor) eq 'HASH', 'descriptor compile still succeeds with debug trace enabled');
 is($descriptor->{spec}{Top}{meta}{handler_variant}, 'AND_SINGLE_ACODE', 'descriptor metadata still records the planned handler variant');

 my $trace = _slurp($trace_path);
 like($trace, qr/DECISION rule_ir:collect:Top:explicit_acode => TAKEN/, 'compile trace includes RuleIR action-edge collection decisions');
 like($trace, qr/DECISION rule_ir:select:Top:handler_variant_AND_SINGLE_ACODE => TAKEN/, 'compile trace includes RuleIR handler-variant selection');
 like($trace, qr/DECISION rule_ir:meta:Top:execution_shape_single_match => TAKEN/, 'compile trace includes RuleIR execution-shape planning');
};

LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

done_testing();

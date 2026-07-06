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

sub _owner_call_with_trace {
 my ($owner, $method, @args) = @_;
 my $trace_path = _debug_trace_path();
 my $result = LinkedSpec::RuleIR::EmitContext::_call_actionir_owner_with_deps($owner, $method, @args);
 return ($result, _slurp($trace_path));
}

subtest 'FlowExpr and ValueExpr trace compact expression decisions' => sub {
 plan tests => 9;

 my ($flow, $flow_trace) = _owner_call_with_trace(
	  'flow_expr',
	  '_lower_flow_composite_expr',
	  q{and(is_defined(name), str_eq(name, "x"))},
 );
 my ($direct, $direct_trace) = _owner_call_with_trace(
  'value_expr',
  '_lower_direct_nested_access_value_expr',
  q{items[0][idx]["name"]},
 );
 my ($source, $source_trace) = _owner_call_with_trace(
	  'value_expr',
	  '_lower_assignment_source_expr',
	  q{name},
 );

 like($flow, qr/\A\(\(defined\(\$name\)\) && /, 'flow composite still lowers logical defined/string comparison expression');
 like($flow_trace, qr/DECISION actionir:flow_expr:lower_flow_composite_expr:expr:is_defined => TAKEN/, 'trace reports is_defined branch');
 like($flow_trace, qr/DECISION actionir:flow_expr:lower_flow_composite_expr:expr:logical_and => TAKEN/, 'trace reports logical and branch');
 is($direct, '$items->[0]->[$idx]->{"name"}', 'direct nested access still lowers array index and literal key segments');
 like($direct_trace, qr/DECISION actionir:value_expr:lower_direct_nested_access_value_expr:expr:bare_index_segment => TAKEN/, 'trace reports bare index segment');
 like($direct_trace, qr/DECISION actionir:value_expr:lower_direct_nested_access_value_expr:expr:literal_key_segment => TAKEN/, 'trace reports literal key segment');
 like($direct_trace, qr/DECISION actionir:value_expr:lower_direct_nested_access_value_expr:expr:direct_access_lowered => TAKEN/, 'trace reports direct-access success');
 is($source, '$name', 'assignment source bare read still lowers to scalar read');
 like($source_trace, qr/DECISION actionir:value_expr:lower_assignment_source_expr:source:bare_scalar_read => TAKEN/, 'trace reports assignment-source scalar read');
};

subtest 'ArrayPipeline and DeclareMethod trace plan and declaration decisions' => sub {
 plan tests => 10;

 my ($array, $array_trace) = _owner_call_with_trace(
  'array_pipeline',
  '_lower_array_pipeline_expr',
  q{filter_match(trim_each(items), /^a/)},
 );
 my ($decl, $decl_trace) = _owner_call_with_trace(
	  'declare_method',
	  '_lower_declare_method_statement',
	  q{declare(array, items = ["a", name])},
 );
 my ($set, $set_trace) = _owner_call_with_trace(
	  'declare_method',
	  '_lower_assign_method_statement',
	  q{set(name, "x")},
 );

 is($array, '@items = grep { $_ =~ /^a/ } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } @items', 'array pipeline lowering is unchanged');
 like($array_trace, qr/DECISION actionir:array_pipeline:build_array_pipeline_plan_from_expr:expr:append_unary_op => TAKEN/, 'trace reports unary pipeline op');
 like($array_trace, qr/DECISION actionir:array_pipeline:build_array_pipeline_plan_from_expr:expr:append_filter_match_op => TAKEN/, 'trace reports filter-match op');
 like($array_trace, qr/DECISION actionir:array_pipeline:lower_array_pipeline_expr:expr:pipeline_lowered => TAKEN/, 'trace reports pipeline lowering success');
 is($decl, 'my @items = ("a", $name)', 'array declaration initializer lowering is unchanged');
 like($decl_trace, qr/DECISION actionir:declare_method:extract_declare_statement_from_method_expr:expr:declare_statement => TAKEN/, 'trace reports declare(...) parsing');
 like($decl_trace, qr/DECISION actionir:declare_method:lower_declare_initializer_expr:array:array_shape => TAKEN/, 'trace reports array shape initializer');
 like($decl_trace, qr/DECISION actionir:declare_method:lower_declare_method_statement:expr:typed_declare_lowered => TAKEN/, 'trace reports typed declaration lowering');
 is($set, '$name = "x"', 'set assignment lowering is unchanged');
 like($set_trace, qr/DECISION actionir:declare_method:lower_assign_method_statement:expr:ast_set_lowered => TAKEN/, 'trace reports AST set assignment lowering');
};

subtest 'ControlFlow traces attached if and inline switch decisions' => sub {
 plan tests => 5;

 my %if_ctx = (if_stack => [], switch_stack => [], switch_counter => 0, while_counter => 0, rewrite_rules => []);
 my ($if_stmt, $if_trace) = _owner_call_with_trace(
  'control_flow',
  '_lower_if_flow_statement',
  q{if(true) { return("yes") }},
  \%if_ctx,
 );
 my %switch_ctx = (if_stack => [], switch_stack => [], switch_counter => 0, while_counter => 0, rewrite_rules => []);
 my ($switch_stmt, $switch_trace) = _owner_call_with_trace(
	  'control_flow',
	  '_lower_switch_flow_statement',
	  q{switch(Top, name, case("x", return("x")), default(return("d")))},
  \%switch_ctx,
 );

 is($if_stmt, 'if (1) { return("yes")', 'attached if lowering is unchanged');
 like($if_trace, qr/DECISION actionir:control_flow:lower_if_flow_statement:if:attached_if => TAKEN/, 'trace reports attached if branch');
 like($if_trace, qr/DECISION actionir:control_flow:lower_flow_branch_single_statement:branch:passthrough_no_rule_match => TAKEN/, 'trace reports branch statement passthrough');
 like($switch_stmt, qr/\Ado \{ my \$__ls_switch_value_1 = \$name; my \$__ls_switch_hit_1 = 0;/, 'inline switch lowering is unchanged');
 like($switch_trace, qr/DECISION actionir:control_flow:lower_switch_flow_statement:switch:inline_switch => TAKEN/, 'trace reports inline switch branch');
};

subtest 'compact lowerer trace hooks keep LinkedSpec::Trace lazy until explicitly loaded' => sub {
 plan tests => 4;

 my ($exit_code, $out, $err) = _run_perl_snippet(<<'PERL');
require LinkedSpec::ActionIR::ValueExpr;
require LinkedSpec::ActionIR::FlowExpr;
require LinkedSpec::ActionIR::ArrayPipeline;
require LinkedSpec::ActionIR::DeclareMethod;
require LinkedSpec::ActionIR::ControlFlow;
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_EAGER__\n" : "__TRACE_STILL_LAZY__\n";
require LinkedSpec::RuleIR::EmitContext;
my $lowered = LinkedSpec::RuleIR::EmitContext::_call_actionir_owner_with_deps("flow_expr", "_lower_flow_composite_expr", "true");
print $lowered eq "1" ? "__FLOW_OK__\n" : "__FLOW_BAD__$lowered\n";
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_AFTER_LOWER__\n" : "__TRACE_STILL_UNLOADED_AFTER_LOWER__\n";
PERL

 is($exit_code, 0, 'subprocess exits cleanly');
 like($out, qr/__TRACE_STILL_LAZY__/, 'requiring compact ActionIR owners keeps Trace unloaded');
 like($out, qr/__FLOW_OK__\n__TRACE_STILL_UNLOADED_AFTER_LOWER__/, 'compact lowerer call stays Trace-lazy without explicit trace configuration');
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

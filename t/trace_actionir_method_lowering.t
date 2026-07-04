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

subtest 'MethodLowering traces value helper family and unsupported helper decisions' => sub {
 plan tests => 6;

 my ($trim, $trim_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_method_value_expr',
  q{trim(:name)},
 );
 my ($unsupported, $unsupported_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_method_value_expr',
  q{unknown_helper(:name)},
 );

 is(
  $trim,
  q{do { my $__ls_trim = $name; if (defined($__ls_trim)) { $__ls_trim =~ s/^\s+|\s+$//g; } $__ls_trim }},
  'trim helper lowering is unchanged',
 );
 like($trim_trace, qr/DECISION actionir:method_lowering:lower_method_value_expr:expr:helper_family_string => TAKEN/, 'trace reports string helper family');
 like($trim_trace, qr/DECISION actionir:method_lowering:lower_method_value_expr:expr:ast_value_lowered => TAKEN/, 'trace reports AST value lowering success');
 is(
  $unsupported,
  q{do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:unknown_helper"; undef }},
  'unknown helper still lowers to the unsupported-helper sentinel',
 );
 like($unsupported_trace, qr/DECISION actionir:method_lowering:lower_method_value_expr:expr:helper_family_unknown => TAKEN/, 'trace reports unknown helper family');
 like($unsupported_trace, qr/DECISION actionir:method_lowering:unsupported_helper_expr:helper:unsupported_helper => TAKEN/, 'trace reports unsupported helper exit');
};

subtest 'MethodLowering traces receiver-chain family transitions' => sub {
 plan tests => 15;

 my ($string_chain, $string_trace) = _owner_call_with_trace(
  'method_lowering',
  '_normalize_string_receiver_value_chain_expr',
  q{name.trim().split(",").count()},
 );
 my ($number_chain, $number_trace) = _owner_call_with_trace(
  'method_lowering',
  '_normalize_number_receiver_value_chain_expr',
  q{count.add(1).gt(5)},
 );
 my ($hash_chain, $hash_trace) = _owner_call_with_trace(
  'method_lowering',
  '_normalize_hash_receiver_value_chain_expr',
  q{meta.sorted_keys().join_values(",")},
 );
 my ($array_chain, $array_trace) = _owner_call_with_trace(
  'method_lowering',
  '_normalize_array_receiver_value_chain_expr',
  q{items.sorted().join_values(",")},
 );
 my ($fluent, $fluent_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_method_value_expr',
  q{name.trim().split(",").count()},
 );

 is($string_chain, q{count(split(trim(:name), ","))}, 'string receiver chain normalization is unchanged');
 like($string_trace, qr/DECISION actionir:method_lowering:normalize_string_receiver_value_chain_expr:receiver_chain:string_receiver_chain => TAKEN/, 'trace reports string receiver chain');
 like($string_trace, qr/DECISION actionir:method_lowering:normalize_string_receiver_value_chain_expr:receiver_chain:string_chain_step => TAKEN/, 'trace reports string chain step');
 is($number_chain, q{num_gt(num_add(:count, 1), 5)}, 'number receiver chain normalization is unchanged');
 like($number_trace, qr/DECISION actionir:method_lowering:normalize_number_receiver_value_chain_expr:receiver_chain:number_receiver_chain => TAKEN/, 'trace reports number receiver chain');
 like($number_trace, qr/DECISION actionir:method_lowering:normalize_number_receiver_value_chain_expr:receiver_chain:number_chain_step => TAKEN/, 'trace reports number chain step');
 is($hash_chain, q{join_values(",", sorted_keys(hash(meta)))}, 'hash receiver chain normalization is unchanged');
 like($hash_trace, qr/DECISION actionir:method_lowering:normalize_hash_receiver_value_chain_expr:receiver_chain:hash_receiver_chain => TAKEN/, 'trace reports hash receiver chain');
 like($hash_trace, qr/DECISION actionir:method_lowering:normalize_hash_receiver_value_chain_expr:receiver_chain:hash_chain_step => TAKEN/, 'trace reports hash chain step');
 is($array_chain, q{join_values(",", sorted(items))}, 'array receiver chain normalization is unchanged');
 like($array_trace, qr/DECISION actionir:method_lowering:normalize_array_receiver_value_chain_expr:receiver_chain:array_receiver_chain => TAKEN/, 'trace reports array receiver chain');
 like($array_trace, qr/DECISION actionir:method_lowering:normalize_array_receiver_value_chain_expr:receiver_chain:array_chain_step => TAKEN/, 'trace reports array chain step');
 like($fluent, qr/\Ado \{ my \$__ls_count = do \{ my \$__ls_split_value = do \{ my \$__ls_trim = \$name;/, 'AST fluent receiver chain lowering is unchanged');
 like($fluent_trace, qr/DECISION actionir:method_lowering:lower_ast_fluent_chain_node:fluent_chain:ast_string_receiver_chain => TAKEN/, 'trace reports AST string receiver-chain lowering');
 like($fluent_trace, qr/DECISION actionir:method_lowering:lower_method_value_expr:expr:ast_value_lowered => TAKEN/, 'trace reports lowered AST fluent-chain value');
};

subtest 'MethodLowering traces assignment and mutation decisions' => sub {
 plan tests => 14;

 my ($assign, $assign_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_assign_statement',
  'items',
  q{["a", :name]},
 );
 my ($scalar, $scalar_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_scalar_assignment_operator_statement',
  q{name = "x"},
 );
 my ($append, $append_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_array_append_operator_statement',
  q{items += :name},
 );
 my ($hash_assign, $hash_assign_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_hash_index_assignment_operator_statement',
  q{meta["k"] = :name},
 );
 my ($array_end, $array_end_trace) = _owner_call_with_trace(
  'method_lowering',
  '_lower_array_end_mutation_method_statement',
  q{items.push_back(:name)},
 );

 is($assign, q{@items = ("a", $name)}, 'bare array-shape assignment lowering is unchanged');
 like($assign_trace, qr/ENTER LinkedSpec::ActionIR::MethodLowering::lower_assign_statement:assignment/, 'trace reports lower_assign_statement enter scope');
 like($assign_trace, qr/DECISION actionir:method_lowering:lower_assign_statement:assignment:bare_target_array_shape => TAKEN/, 'trace reports bare target array-shape assignment decision');
 like($assign_trace, qr/EXIT LinkedSpec::ActionIR::MethodLowering::lower_assign_statement:assignment/, 'trace reports lower_assign_statement exit scope');
 is($scalar, q{$name = "x"}, 'scalar assignment operator lowering is unchanged');
 like($scalar_trace, qr/DECISION actionir:method_lowering:lower_scalar_assignment_operator_statement:assignment:ast_scalar_assignment_operator => TAKEN/, 'trace reports AST scalar assignment operator');
 is($append, q{push @items, $name}, 'array append operator lowering is unchanged');
 like($append_trace, qr/DECISION actionir:method_lowering:lower_array_append_operator_statement:assignment:ast_array_append_operator => TAKEN/, 'trace reports AST array append operator');
 like($append_trace, qr/DECISION actionir:method_lowering:lower_mutation_slot_value_expr:value:bare_scalar_read => TAKEN/, 'trace reports mutation slot scalar read');
 is($hash_assign, q{$meta{"k"} = $name}, 'hash-index assignment operator lowering is unchanged');
 like($hash_assign_trace, qr/DECISION actionir:method_lowering:lower_hash_index_assignment_operator_statement:assignment:ast_hash_index_assignment => TAKEN/, 'trace reports AST hash-index assignment');
 is($array_end, q{push @items, $name}, 'array end-mutation method lowering is unchanged');
 like($array_end_trace, qr/DECISION actionir:method_lowering:lower_ast_array_end_mutation_method_statement:fluent_chain:ast_array_end_push_back => TAKEN/, 'trace reports AST array end-mutation method');
 like($array_end_trace, qr/DECISION actionir:method_lowering:lower_array_end_mutation_method_statement:fluent_chain:ast_array_end_mutation => TAKEN/, 'trace reports lowered array end-mutation wrapper');
};

subtest 'MethodLowering trace hooks keep LinkedSpec::Trace lazy until explicitly loaded' => sub {
 plan tests => 4;

 my ($exit_code, $out, $err) = _run_perl_snippet(<<'PERL');
require LinkedSpec::ActionIR::MethodLowering;
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_EAGER__\n" : "__TRACE_STILL_LAZY__\n";
require LinkedSpec::RuleIR::EmitContext;
my $lowered = LinkedSpec::RuleIR::EmitContext::_call_actionir_owner_with_deps("method_lowering", "_lower_method_value_expr", "trim(:name)");
print $lowered =~ /__ls_trim/ ? "__METHOD_OK__\n" : "__METHOD_BAD__$lowered\n";
print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_AFTER_LOWER__\n" : "__TRACE_STILL_UNLOADED_AFTER_LOWER__\n";
PERL

 is($exit_code, 0, 'subprocess exits cleanly');
 like($out, qr/__TRACE_STILL_LAZY__/, 'requiring MethodLowering keeps Trace unloaded');
 like($out, qr/__METHOD_OK__\n__TRACE_STILL_UNLOADED_AFTER_LOWER__/, 'MethodLowering call stays Trace-lazy without explicit trace configuration');
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

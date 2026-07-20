#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempdir tempfile);
use FindBin qw($Bin);
use IPC::Open3 qw(open3);
use JSON::PP ();
use Symbol qw(gensym);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::Trace ();

my $CONTRACT_ID = 'linkedspec-explicit-repetition-action-result-v1';
my $contract_path = "$Bin/../capability_conformance/repeated_action_result_contract.json";
open my $contract_fh, '<:encoding(UTF-8)', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

my %case_by_id = map { $_->{id} => $_ } (@{$contract->{mode_cases}}, @{$contract->{special_cases}});
my $json = JSON::PP->new->allow_nonref(1)->canonical(1);
my $generated_source = '';
my $generated_module;
my $generated_package_counter = 0;

sub read_text {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 my $text = do { local $/; <$fh> };
 close $fh or die "cannot close $path: $!";
 return defined($text) ? $text : ''
}

sub execute_parser {
 my ($parser, $input_text) = @_;
 my $input = $input_text;
 my $result = eval { $parser->(\$input) };
 my $error = $@ // '';
 return ($result, $error, pos($input))
}

sub compile_case {
 my ($case) = @_;
 my $source = $case->{source};
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 ok(ref($parser) eq 'CODE', "$case->{id} compiles")
  or diag($json->encode($runtime_ctx{last_error} // {}));
 return $parser
}

sub assert_case_result {
 my ($case, $parser, $label) = @_;
 my ($result, $error, $position) = execute_parser($parser, $case->{input});
 is($error, '', "$label executes without die");
 is_deeply($result, $case->{expected_result}, "$label returns the exact contract value");
 is($position, $case->{expected_position}, "$label preserves the expected cursor");
}

sub load_generated_source {
 my ($source) = @_;
 my $package = 'LinkedSpec::RepeatedActionResult::Generated' . ++$generated_package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, 'generated source loads in an isolated package') or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
 }
}

sub run_primary_command {
 my (@arguments) = @_;
 my $stderr_fh = gensym();
 my $pid = open3(
  my $stdin_fh,
  my $stdout_fh,
  $stderr_fh,
  $^X,
  "-I$Bin/../perl",
  "$Bin/../bin/linkedspec",
  @arguments,
 );
 close $stdin_fh or die "cannot close primary-command stdin: $!";
 my $stdout = do { local $/; <$stdout_fh> } // '';
 my $stderr = do { local $/; <$stderr_fh> } // '';
 waitpid($pid, 0);
 return ($? >> 8, $stdout, $stderr)
}

sub role_neutral_contract {
 is($contract->{contract_id}, $CONTRACT_ID, 'consumer reads the neutral contract identity');
 is_deeply(
  [map { $_->{id} } @{$contract->{mode_cases}}],
  [qw(
   compact_star_two_hits
   compact_plus_two_hits
   compact_optional_one_hit
   explicit_or_two_hits
   explicit_or_plus_two_hits
   bounded_exact_two_hits
   bounded_up_to_two_hits
   pipe_distinct_scalar
  )],
  'consumer locks all eight mode cases in authored order',
 );
 is(scalar(@{$contract->{special_cases}}), 10, 'consumer locks all ten specialized cases');
 is($contract->{semantics}{repeated_action_return}, 'one_typed_iteration_value_per_successful_hit', 'action returns are iteration values');
 is($contract->{semantics}{lifecycle_return}, 'whole_rule_return', 'lifecycle returns retain rule authority');
 is($contract->{scope}{unadorned_default_handler_in_scope}, JSON::PP::false, 'unadorned default handler stays out of scope');
}

sub role_live_mode_matrix {
 for my $case (@{$contract->{mode_cases}}) {
  my $parser = compile_case($case);
  next unless ref($parser) eq 'CODE';
  assert_case_result($case, $parser, "live $case->{id}");
 }
}

sub role_live_special_cases {
 for my $case (@{$contract->{special_cases}}) {
  my $parser = compile_case($case);
  next unless ref($parser) eq 'CODE';
  assert_case_result($case, $parser, "live $case->{id}");
 }
}

sub role_loaded {
 my $case = $case_by_id{fluent_return_collects};
 my ($fh, $path) = tempfile(SUFFIX => '.spec');
 print {$fh} $case->{source} or die "cannot write $path: $!";
 close $fh or die "cannot close $path: $!";
 my $parser = LinkedSpec::get_parser($path);
 ok(ref($parser) eq 'CODE', 'file-loaded route returns a parser');
 assert_case_result($case, $parser, 'file-loaded fluent repetition');
}

sub role_descriptor {
 my $or_case = $case_by_id{explicit_or_two_hits};
 my $or_source = $or_case->{source};
 my $or_descriptor = LinkedSpec::Get(\$or_source, return_descriptor => 1);
 ok(ref($or_descriptor) eq 'HASH', 'bare OR descriptor compiles');
 my $or_meta = $or_descriptor->{spec}{Top}{meta};
 is($or_meta->{family}, $contract->{descriptor_contract}{family}, 'bare OR descriptor keeps OR/default family');
 is($or_meta->{cursor_policy}, $contract->{descriptor_contract}{cursor_policy}, 'bare OR descriptor keeps seek cursor');
 is($or_meta->{execution_shape}, $contract->{descriptor_contract}{bare_or}{execution_shape}, 'bare OR descriptor reports repeat loop');
 is($or_meta->{rep_min}, $contract->{descriptor_contract}{bare_or}{rep_min}, 'bare OR descriptor reports minimum one');
 is($or_meta->{rep_max}, $contract->{descriptor_contract}{perl_unbounded_sentinel}, 'bare OR descriptor reports Perl unbounded sentinel');
 is(lc($or_meta->{handler_variant}), $contract->{descriptor_contract}{bare_or}{handler_family}, 'bare OR descriptor reports repeated action family');
 ok($or_meta->{uses_loop}, 'bare OR descriptor reports loop use');

 my $pipe_case = $case_by_id{pipe_distinct_scalar};
 my $pipe_source = $pipe_case->{source};
 my $pipe_descriptor = LinkedSpec::Get(\$pipe_source, return_descriptor => 1);
 ok(ref($pipe_descriptor) eq 'HASH', 'pipe descriptor compiles');
 my $pipe_meta = $pipe_descriptor->{spec}{Top}{meta};
 is($pipe_meta->{execution_shape}, $contract->{descriptor_contract}{pipe}{execution_shape}, 'pipe descriptor reports single-choice dispatch');
 ok(!defined($pipe_meta->{rep_min}) && !defined($pipe_meta->{rep_max}), 'pipe descriptor has no repetition bounds');
 is(lc($pipe_meta->{handler_variant}), $contract->{descriptor_contract}{pipe}{handler_family}, 'pipe descriptor reports direct action family');
 ok(!$pipe_meta->{uses_loop}, 'pipe descriptor reports no loop');
}

sub role_emitted_source {
 my $case = $case_by_id{explicit_or_two_hits};
 my $source = $case->{source};
 $generated_source = LinkedSpec::emit_generated_source(
  \$source,
  source_identity => 'repeated-action-result/perl-admission.spec',
 );
 ok(defined($generated_source) && length($generated_source), 'public emitter returns repeated-action source');
 like($generated_source, qr/contract_id: linkedspec-generated-source-v2/, 'emitted source remains generated-source v2');
 like($generated_source, qr/format_version: 2/, 'emitted source remains format 2');
 like($generated_source, qr/family\s*=>\s*'rep_acode'/, 'bare OR emitted plan uses repeated action family');
 like($generated_source, qr/push \@Top_collect, \$Top/, 'emitted handler collects the iteration action value');
 like($generated_source, qr/branch => 'regex_slot_selected'/, 'emitted handler retains selected-slot trace');
}

sub role_generated_direct {
 $generated_module = load_generated_source($generated_source);
 my $case = $case_by_id{explicit_or_two_hits};
 assert_case_result($case, $generated_module->{execute}, 'standalone generated bare OR');
 is_deeply($generated_module->{plan}->(), [{label => 'Top', family => 'rep_acode'}], 'generated v2 plan is exact repeated action family');
 is($generated_module->{metadata}->()->{contract_id}, $contract->{generated_source_v2}{contract_id}, 'generated metadata preserves v2 identity');
}

sub role_generated_trace {
 my $case = $case_by_id{explicit_or_two_hits};
 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'repeated-action-result.trace');
 my $input = $case->{input};
 my $result = $generated_module->{execute_with_trace}->(
  \$input,
  {
   trace_level => 'debug',
   trace_log_file => $trace_path,
   trace_log_mode => 'route',
   trace_reset_log => 1,
   trace_topic_spacing => 0,
  },
 );
 is_deeply($result, $case->{expected_result}, 'generated traced result equals generated direct result');
 is(pos($input), $case->{expected_position}, 'generated traced route consumes both hits');
 my $trace = read_text($trace_path);
 my $selection_count = () = $trace =~ /regex_slot_selected => TAKEN/g;
 is($selection_count, scalar(@{$case->{expected_selected_slots}}), 'generated trace records one slot selection per accepted hit');
 like($trace, qr/regex_index=0.*regex_slot_selected => TAKEN.*regex_index=1/s, 'generated trace records both distinct selected slots');
 like($trace, qr/iteration_result => TAKEN/, 'generated trace records successful iteration result');
 LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');
}

sub role_primary_cli {
 for my $case_id (qw(explicit_or_two_hits pipe_distinct_scalar)) {
  my $case = $case_by_id{$case_id};
  my ($exit, $stdout, $stderr) = run_primary_command(
   '--inline-spec', $case->{source},
   '--input', $case->{input},
  );
  is($exit, 0, "primary $case_id exits successfully");
  is($stdout, $json->encode($case->{expected_result}) . "\n", "primary $case_id emits canonical contract JSON");
  is($stderr, '', "primary $case_id keeps stderr empty");
 }
}

sub role_corpus_bundle {
 my $bundle = $contract->{corpus_bundle};
 my $source_path = "$Bin/../$bundle->{source}";
 my $input_text = read_text("$Bin/../$bundle->{input}");
 my $expected = $json->decode(read_text("$Bin/../$bundle->{expected}"));
 my $parser = LinkedSpec::get_parser($source_path);
 ok(ref($parser) eq 'CODE', 'checked-in corpus bundle loads through get_parser');
 my ($result, $error, $position) = execute_parser($parser, $input_text);
 is($error, '', 'checked-in corpus bundle executes without die');
 is_deeply($result, $expected, 'checked-in corpus bundle returns its exact JSON oracle');
 is($position, 2, 'checked-in corpus bundle consumes both authored hits before trailing newline');
}

my @roles = (
 [neutral_contract => \&role_neutral_contract],
 [live_mode_matrix => \&role_live_mode_matrix],
 [live_special_cases => \&role_live_special_cases],
 [loaded => \&role_loaded],
 [descriptor => \&role_descriptor],
 [emitted_source => \&role_emitted_source],
 [generated_direct => \&role_generated_direct],
 [generated_trace => \&role_generated_trace],
 [primary_cli => \&role_primary_cli],
 [corpus_bundle => \&role_corpus_bundle],
);

subtest $_->[0] => $_->[1] for @roles;
done_testing();

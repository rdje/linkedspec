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
use LinkedSpec::HandlerVariantEmitter ();
use LinkedSpec::Trace;

sub _slurp {
 my ($path) = @_;
 open(my $fh, '<', $path) or die "cannot read '$path': $!";
 local $/;
 my $content = <$fh>;
 close($fh);
 return defined($content) ? $content : '';
}

sub _build_parser_quiet {
 my ($spec, %opts) = @_;
 LinkedSpec::Trace::configure_trace(
  trace_level => 'none',
  trace_log_file => '',
  trace_log_mode => 'stdout',
  trace_topic_spacing => 0,
 );
 return LinkedSpec::Get(\$spec, parse_mode => 'consume', %opts);
}

sub _run_with_routed_debug_trace {
 my ($spec, $input, %opts) = @_;
 my $parser = _build_parser_quiet($spec, %opts);
 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'trace.log');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'debug',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );

 my $result = eval { $parser->(\$input) };
 my $error = $@ // '';
 my $trace = _slurp($trace_path);
 return ($result, $error, $trace);
}

sub _trace_lines_for_rule {
 my ($trace, $rule) = @_;
 my @lines = $trace =~ /^(.*DECISION generated_handler_branch:[^\n]*:\Q$rule\E:[^\n]*)$/mg;
 return join("\n", @lines);
}

sub _emit_rep_source {
 my ($kind) = @_;
 my %common = (
  node_type => 'REP_PLUS',
  rep_min => 1,
  rep_max => 3,
 );

 my $ir;
 if ($kind eq 'rep_bcode') {
  $ir = LinkedSpec::HandlerVariantEmitter::_build_rep_bcode_variant(
   %common,
   label => 'RepB',
   bcodes_ref => { Child => '$RepB = ["C"];' },
   bcalls_ref => [ 'Child' ],
  );
 } elsif ($kind eq 'rep_and_bcode') {
  $ir = LinkedSpec::HandlerVariantEmitter::_build_rep_and_bcode_variant(
   %common,
   label => 'RepAB',
   bcodes_ref => {
    First => '$RepAB = ["A"];',
    Second => '$RepAB = ["B"];',
   },
   bcalls_ref => [ 'First', 'Second' ],
  );
 } elsif ($kind eq 'rep_and_acode') {
  $ir = LinkedSpec::HandlerVariantEmitter::_build_rep_and_acode_variant(
   %common,
   label => 'RepAA',
   acodes_ref => [
    '$RepAA = "A";',
    '$RepAA = "B";',
   ],
  );
 } elsif ($kind eq 'rep_acode') {
  $ir = LinkedSpec::HandlerVariantEmitter::_build_rep_acode_variant(
   %common,
   label => 'RepA',
   acodes_ref => [ 'return("A");' ],
  );
 } else {
  die "unknown REP kind '$kind'";
 }

 return LinkedSpec::HandlerVariantEmitter::_emit_handler($ir);
}

subtest 'REP_ACODE traces loop, match, min, iteration, acode index, and max decisions' => sub {
 my $spec = <<'SPEC';
Top::
 -> Plus

Plus:+
 /a/ -> Plus { return("A") }
SPEC

 my ($result, $error, $trace) = _run_with_routed_debug_trace($spec, 'a', top_rule => 'Plus');
 my $lines = _trace_lines_for_rule($trace, 'Plus');
 is($error, '', 'REP_ACODE plus run does not die');
 is_deeply($result, [ 'A' ], 'REP_ACODE plus run preserves collected action result');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Plus:loop_enter => TAKEN/, 'REP_ACODE traces loop entry');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Plus:match => TAKEN/, 'REP_ACODE traces successful regex match');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Plus:acode_index_0 => TAKEN/, 'REP_ACODE traces selected acode index');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Plus:iteration_result => TAKEN/, 'REP_ACODE traces successful iteration result');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Plus:max_continue => TAKEN/, 'REP_ACODE traces max-bound continue decision');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Plus:miss_min_satisfied => TAKEN/, 'REP_ACODE traces satisfied-min stop on trailing miss');

 my ($miss_result, $miss_error, $miss_trace) = _run_with_routed_debug_trace($spec, 'z', top_rule => 'Plus');
 my $miss_lines = _trace_lines_for_rule($miss_trace, 'Plus');
 is($miss_error, '', 'REP_ACODE below-min miss does not die');
 is($miss_result, undef, 'REP_ACODE below-min miss preserves undef result');
 like($miss_lines, qr/DECISION generated_handler_branch:rep_acode:Plus:match => SKIPPED/, 'REP_ACODE traces skipped match');
 like($miss_lines, qr/DECISION generated_handler_branch:rep_acode:Plus:miss_min_satisfied => SKIPPED/, 'REP_ACODE traces below-min miss decision');
};

subtest 'REP_ACODE optional form traces max cutoff as skipped' => sub {
 my $spec = <<'SPEC';
Top::
 -> Opt

Opt:?
 /a/ -> Opt { return("A") }
SPEC

 my ($result, $error, $trace) = _run_with_routed_debug_trace($spec, 'a', top_rule => 'Opt');
 my $lines = _trace_lines_for_rule($trace, 'Opt');
 is($error, '', 'REP_ACODE optional run does not die');
 is_deeply($result, [ 'A' ], 'REP_ACODE optional run preserves collected action result');
 like($lines, qr/DECISION generated_handler_branch:rep_acode:Opt:max_continue => SKIPPED/, 'REP_ACODE traces max-bound cutoff');
};

subtest 'REP_AND_ACODE traces ordered iteration success and min-satisfied stop' => sub {
 my $spec = <<'SPEC';
Top::
 -> Many

Many:AND+
 /a/ -> Many[0] { return("A") }
 /b/ -> Many[1] { return("B") }
SPEC

 my ($result, $error, $trace) = _run_with_routed_debug_trace($spec, 'ab', top_rule => 'Many');
 my $lines = _trace_lines_for_rule($trace, 'Many');
 is($error, '', 'REP_AND_ACODE run does not die');
 is_deeply($result, [ 'A' ], 'REP_AND_ACODE preserves existing collected result behavior');
 like($lines, qr/DECISION generated_handler_branch:rep_and_acode:Many:loop_enter => TAKEN/, 'REP_AND_ACODE traces loop entry');
 like($lines, qr/DECISION generated_handler_branch:rep_and_acode:Many:iteration_result => TAKEN/, 'REP_AND_ACODE traces successful iteration');
 like($lines, qr/DECISION generated_handler_branch:rep_and_acode:Many:max_continue => TAKEN/, 'REP_AND_ACODE traces max-bound continue decision');
 like($lines, qr/DECISION generated_handler_branch:rep_and_acode:Many:iteration_result => SKIPPED/, 'REP_AND_ACODE traces failed trailing iteration');
 like($lines, qr/DECISION generated_handler_branch:rep_and_acode:Many:miss_min_satisfied => TAKEN/, 'REP_AND_ACODE traces satisfied-min stop');
};

subtest 'REP emitter templates contain their owned branch trace calls' => sub {
 my %expected = (
  rep_bcode => [
   qw(loop_enter iteration_result miss_min_satisfied zero_progress zero_progress_min_satisfied max_continue),
  ],
  rep_and_bcode => [
   qw(loop_enter iteration_result miss_min_satisfied zero_progress zero_progress_min_satisfied max_continue),
  ],
  rep_and_acode => [
   qw(loop_enter iteration_result miss_min_satisfied max_continue),
  ],
  rep_acode => [
   qw(loop_enter match acode_index_0 miss_min_satisfied iteration_result max_continue),
  ],
 );

 foreach my $kind (sort keys %expected) {
  my $source = _emit_rep_source($kind);
  ok(defined($source) && length($source), "$kind emits source");
  like($source, qr/trace_generated_handler_branch/, "$kind source routes through the generated-branch helper");
  foreach my $branch (@{$expected{$kind}}) {
   like($source, qr/branch => '\Q$branch\E'/, "$kind source traces $branch");
  }
 }

 my $rep_bcode_source = _emit_rep_source('rep_bcode');
 unlike($rep_bcode_source, qr/branch => 'bcode_call_Child'/, 'REP_BCODE keeps nested OR_BCODE helper calls quiet');

 my $rep_and_bcode_source = _emit_rep_source('rep_and_bcode');
 unlike($rep_and_bcode_source, qr/branch => 'bcode_call_First'/, 'REP_AND_BCODE keeps nested AND_BCODE helper calls quiet');
};

LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

done_testing();

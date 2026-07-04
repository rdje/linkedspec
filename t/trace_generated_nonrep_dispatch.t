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

subtest 'default handler traces match, miss/LX, and acode index dispatch' => sub {
 plan tests => 8;

 my $spec = <<'SPEC';
Top::
 /a/ -> Top { return("A") }
LX { return("MISS") }
SPEC

 my ($match_result, $match_error, $match_trace) = _run_with_routed_debug_trace($spec, 'a');
 my $match_lines = _trace_lines_for_rule($match_trace, 'Top');
 is($match_error, '', 'default match run does not die');
 is($match_result, 'A', 'default match run returns the acode payload');
 like($match_lines, qr/DECISION generated_handler_branch:default:Top:match => TAKEN/, 'default match branch is traced as taken');
 like($match_lines, qr/DECISION generated_handler_branch:default:Top:acode_index_0 => TAKEN/, 'default acode index branch is traced as taken');

 my ($miss_result, $miss_error, $miss_trace) = _run_with_routed_debug_trace($spec, 'z');
 my $miss_lines = _trace_lines_for_rule($miss_trace, 'Top');
 is($miss_error, '', 'default miss run does not die');
 is($miss_result, 'MISS', 'default miss run returns the LX/default path payload');
 like($miss_lines, qr/DECISION generated_handler_branch:default:Top:match => SKIPPED/, 'default match branch is traced as skipped on miss');
 like($miss_lines, qr/DECISION generated_handler_branch:default:Top:no_match_lx => TAKEN/, 'default no-match LX branch is traced as taken');
};

subtest 'bcode handlers trace child-call dispatch and child-result branches' => sub {
 plan tests => 8;

 my $and_spec = <<'SPEC';
Top::&
 => A
 => B
A:
 /a/ I { return("A") }
B:
 /b/ I { return("B") }
SPEC

 my ($and_result, $and_error, $and_trace) = _run_with_routed_debug_trace($and_spec, 'ab');
 my $and_lines = _trace_lines_for_rule($and_trace, 'Top');
 is($and_error, '', 'AND_BCODE run does not die');
 is_deeply($and_result, [ 'A', 'B' ], 'AND_BCODE run preserves collected child results');
 like($and_lines, qr/DECISION generated_handler_branch:and_bcode:Top:bcode_call_A => TAKEN/, 'AND_BCODE dispatch traces the first child call as taken');
 like($and_lines, qr/DECISION generated_handler_branch:and_bcode:Top:bcode_call_B => TAKEN/, 'AND_BCODE dispatch traces the second child call as taken');
 like($and_lines, qr/DECISION generated_handler_branch:and_bcode:Top:bcode_child_result => TAKEN/, 'AND_BCODE traces successful child results');

 my $or_spec = <<'SPEC';
Top::|
 => A
 => B
A:
 /a/ I { return("A") }
B:
 /b/ I { return("B") }
SPEC

 my ($or_result, $or_error, $or_trace) = _run_with_routed_debug_trace($or_spec, 'ab');
 my $or_lines = _trace_lines_for_rule($or_trace, 'Top');
 is($or_error, '', 'OR_BCODE run does not die');
 is($or_result, 'A', 'OR_BCODE run preserves first-match result');
 like($or_lines, qr/DECISION generated_handler_branch:or_bcode:Top:bcode_child_result => TAKEN/, 'OR_BCODE traces the successful child result');
};

subtest 'non-repetition acode variants trace sequence and choice branches' => sub {
 plan tests => 13;

 my $single_spec = <<'SPEC';
Top::&
 /a/ -> Top { return("A") }
SPEC

 my ($single_result, $single_error, $single_trace) = _run_with_routed_debug_trace($single_spec, 'a');
 my $single_lines = _trace_lines_for_rule($single_trace, 'Top');
 is($single_error, '', 'AND_SINGLE_ACODE run does not die');
 is($single_result, 'A', 'AND_SINGLE_ACODE run preserves action payload result');
 like($single_lines, qr/DECISION generated_handler_branch:and_single_acode:Top:match => TAKEN/, 'AND_SINGLE_ACODE traces regex match branch');
 like($single_lines, qr/DECISION generated_handler_branch:and_single_acode:Top:required_index_0 => TAKEN/, 'AND_SINGLE_ACODE traces required index branch');
 like($single_lines, qr/DECISION generated_handler_branch:and_single_acode:Top:acode_index_0 => TAKEN/, 'AND_SINGLE_ACODE traces acode dispatch branch');

 my $and_spec = <<'SPEC';
Top::&
 /a/ -> Top[0] { return("A") }
 /b/ -> Top[1] { return("B") }
SPEC

 my ($and_result, $and_error, $and_trace) = _run_with_routed_debug_trace($and_spec, 'ab');
 my $and_lines = _trace_lines_for_rule($and_trace, 'Top');
 is($and_error, '', 'AND_ACODE run does not die');
 is($and_result, 'A', 'AND_ACODE run preserves existing first-return behavior');
 like($and_lines, qr/DECISION generated_handler_branch:and_acode_seq:Top:match => TAKEN/, 'AND_ACODE traces regex match branch');
 like($and_lines, qr/DECISION generated_handler_branch:and_acode_seq:Top:required_sequence_index => TAKEN/, 'AND_ACODE traces required sequence index branch');
 like($and_lines, qr/DECISION generated_handler_branch:and_acode_seq:Top:acode_index_0 => TAKEN/, 'AND_ACODE traces selected acode index branch');

 my $or_spec = <<'SPEC';
Top::|
 /a/ -> Top[0] { return("A") }
 /b/ -> Top[1] { return("B") }
SPEC

 my ($or_result, $or_error, $or_trace) = _run_with_routed_debug_trace($or_spec, 'b');
 my $or_lines = _trace_lines_for_rule($or_trace, 'Top');
 is($or_error, '', 'OR_ACODE run does not die');
 is($or_result, 'B', 'OR_ACODE run preserves selected action result');
 like($or_lines, qr/DECISION generated_handler_branch:or_acode:Top:acode_index_1 => TAKEN/, 'OR_ACODE traces selected acode choice branch');
};

subtest 'repetition handler bodies are instrumented by TRACE-OBSERVABILITY.3.3' => sub {
 plan tests => 6;

 my $spec = <<'SPEC';
Top::
 -> Plus

Plus:+
 /a/ -> Plus { return("A") }
SPEC

 my %ctx;
 my $source = '';
 my $parser = _build_parser_quiet(
  $spec,
  top_rule => 'Top',
  dump_parser_source => 1,
  parser_source_ref => \$source,
  runtime_ctx_ref => \%ctx,
 );
 ok(defined($parser) && ref($parser) eq 'CODE', 'repetition source probe still builds a parser');
 like($source, qr/Top => sub \{/, 'parser source includes the non-repetition top wrapper');
 like($source, qr/Plus => sub \{/, 'parser source includes the repetition rule body');
 like($source, qr/Top => sub \{.*trace_generated_handler_branch/s, 'non-repetition wrapper source is instrumented');

 my ($plus_body) = $source =~ /Plus => sub \{(.*?^\s+\},)/ms;
 like($plus_body // '', qr/trace_generated_handler_branch/, 'REP_ACODE rule body is instrumented in .3.3');
 like($plus_body // '', qr/branch => 'max_continue'/, 'REP_ACODE rule body traces repetition max-bound decisions');
};

LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

done_testing();

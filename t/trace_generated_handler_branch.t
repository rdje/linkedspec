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

use LinkedSpec::Trace;

sub _slurp {
 my ($path) = @_;
 open(my $fh, '<', $path) or die "cannot read '$path': $!";
 local $/;
 my $content = <$fh>;
 close($fh);
 return defined($content) ? $content : '';
}

subtest 'generated handler branch helper is quiet and lazy when trace is disabled' => sub {
 plan tests => 4;

 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'trace.log');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'none',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );

 my $details_called = 0;
 my $taken = LinkedSpec::Trace::trace_generated_handler_branch(
  rule_label => 'Top',
  handler_kind => 'default',
  branch => 'match',
  taken => 1,
  details => sub {
   ++$details_called;
   return 'expensive_details=1';
  },
 );

 is($taken, 1, 'helper returns the original true branch decision');
 is($details_called, 0, 'lazy details are not evaluated when trace is disabled');
 ok(-f $trace_path, 'trace file exists after reset');
 is(_slurp($trace_path), '', 'trace file remains empty when trace is disabled');
};

subtest 'generated handler branch helper emits structured decisions when enabled' => sub {
 plan tests => 8;

 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'trace.log');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'debug',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );

 my $details_called = 0;
 my $taken = LinkedSpec::Trace::trace_generated_handler_branch(
  rule_label => 'Top',
  handler_kind => 'default',
  branch => 'acode_index',
  taken => 0,
  match_index => 2,
  pos => 7,
  details => sub {
   ++$details_called;
   return 'expected_index=0';
  },
 );

 my $trace = _slurp($trace_path);
 is($taken, 0, 'helper returns the original false branch decision');
 is($details_called, 1, 'lazy details are evaluated when trace is enabled');
 like($trace, qr/DECISION generated_handler_branch:default:Top:acode_index => SKIPPED/, 'trace includes the generated-handler branch decision name');
 like($trace, qr/rule=Top/, 'trace context includes the rule label');
 like($trace, qr/handler_kind=default/, 'trace context includes the handler kind');
 like($trace, qr/branch=acode_index/, 'trace context includes the branch name');
 like($trace, qr/match_index=2/, 'trace context includes emitted-handler branch metadata');
 like($trace, qr/expected_index=0/, 'trace context includes lazy details');
};

subtest 'generated handler branch details errors do not perturb branch result' => sub {
 plan tests => 4;

 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'trace.log');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'debug',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );

 my $taken = eval {
  LinkedSpec::Trace::trace_generated_handler_branch(
   rule_label => 'Child',
   handler_kind => 'or_bcode',
   branch => 'child_call',
   taken => 1,
   call => 'atom',
   details => sub { die "detail boom\n" },
  );
 };
 my $err = $@ // '';
 my $trace = _slurp($trace_path);

 is($err, '', 'details errors are captured instead of escaping');
 is($taken, 1, 'helper still returns the original true branch decision');
 like($trace, qr/DECISION generated_handler_branch:or_bcode:Child:child_call => TAKEN/, 'trace still emits the branch decision');
 like($trace, qr/details_error=detail boom/, 'trace records the captured details error');
};

LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');

done_testing();

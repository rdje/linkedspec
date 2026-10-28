use strict;
use warnings;
use Test::More;
use JSON::PP ();
use POSIX ();
use Scalar::Util qw(reftype refaddr);
use Time::HiRes qw(time sleep);
use LinkedSpec ();
use LinkedSpec::RecognitionTransactionRuntime ();

# TYPE-REFERENCE-BOOK.1.2.23.3.39.6.2. Only test processes have timeouts.
my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $sequence = 0;

sub error_summary {
 my ($error) = @_;
 return undef unless defined($error) && (ref($error) || length($error));
 if (ref($error) && (reftype($error) // '') eq 'HASH') {
  return {class => ref($error), code => exists($error->{code}) ? $error->{code} : undef,
   detail => exists($error->{detail}) ? $error->{detail} : "$error"};
 }
 return {class => ref($error), detail => "$error"};
}

sub bounded_run {
 my ($body) = @_;
 pipe(my $reader, my $writer) or die "pipe: $!";
 my $pid = fork();
 die "fork: $!" unless defined $pid;
 if (!$pid) {
  close $reader;
  my $value = eval {$body->()};
  my $error = error_summary($@);
  print {$writer} $json->encode({value => $value, harness_error => $error});
  close $writer;
  POSIX::_exit(0);
 }
 close $writer;
 my $deadline = time() + 5;
 my $waited;
 while (($waited = waitpid($pid, POSIX::WNOHANG())) == 0 && time() < $deadline) {sleep(0.01)}
 if ($waited == 0) {
  kill 'KILL', $pid;
  waitpid($pid, 0);
  close $reader;
  return {timeout => 1};
 }
 my $status = $?;
 local $/;
 my $bytes = <$reader>;
 close $reader;
 return {harness_error => "child status $status"} if $waited != $pid || $status;
 my $decoded = eval {$json->decode($bytes)};
 return {harness_error => 'invalid child result'} unless ref($decoded) eq 'HASH';
 return $decoded;
}

sub route_values {
 my ($parser, $ctx, $cases) = @_;
 my @rows;
 for my $case (@$cases) {
  my $text = $case->[0];
  my ($value, $thrown);
  if ($case->[3] && $case->[3] eq 'matcher') {
   no warnings qw(redefine once);
   local *LinkedRE::or = sub {die "EMITTED_RULE_PROGRESS_MATCHER_FAILURE\n"};
   $value = eval {$parser->(\$text)};
   $thrown = $@;
  } else {
   $value = eval {$parser->(\$text)};
   $thrown = $@;
  }
  push @rows, {value => $value, cursor => pos($text), error => error_summary($thrown || $ctx->{last_error})};
 }
 return \@rows;
}

sub check_source {
 my ($name, $source, $cases) = @_;
 subtest $name => sub {
  my %ctx;
  my $native = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
  ok(ref($native) eq 'CODE', 'native builds');
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'rule-progress.spec');
  diag('EMITTED_RULE_PROGRESS_SOURCE ' . $name . ' ' . $json->encode({source => $source, emitted => $emitted}));
  my $package = 'LinkedSpec::EmittedRuleProgressTest' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'independent emitted package loads') or diag($@);
  return unless $loaded && ref($native) eq 'CODE';
  no strict 'refs';
  my $fresh = *{$package . '::Execute'}{CODE};
  my $metadata = &{$package . '::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version}, 2, 'format remains two');
  is($metadata->{contract_id}, 'linkedspec-generated-source-v2', 'contract unchanged');
  is_deeply(&{$package . '::LinkedSpecGeneratedPlan'}(), $metadata->{plan}, 'loaded plan agrees');
  is_deeply([sort keys %$_], [qw(family label)], 'plan row stays minimal') for @{$metadata->{plan}};
  my %observed;
  for my $route ([native => $native, \%ctx], [fresh => $fresh, {}]) {
   my ($label, $parser, $context) = @$route;
   my $result = bounded_run(sub {route_values($parser, $context, $cases)});
   $observed{$label} = $result;
   ok(!$result->{timeout}, "$label completes within the test bound");
   ok(!$result->{timeout} && !$result->{harness_error} && ref($result->{value}) eq 'ARRAY', "$label child result is complete");
   next if $result->{timeout} || $result->{harness_error};
   is(scalar(@{$result->{value}}), scalar(@$cases), "$label reaches every input");
   for my $i (0 .. $#$cases) {
    my ($input, $expected, $position, $error) = @{$cases->[$i]};
    my $actual = $result->{value}[$i];
    is($json->encode($actual->{value}), $json->encode($expected), "$label $input exact value and kinds");
    is($actual->{cursor}, $position, "$label $input exact cursor");
    if ($error) {
     ok($actual->{error}, "$label $input retains an error instead of an ordinary cut");
     if ($error eq 'matcher') {
      like($actual->{error}{detail}, qr/EMITTED_RULE_PROGRESS_MATCHER_FAILURE/, "$label original matcher failure retained");
     } else {
      is($actual->{error}{code}, $error, "$label portable rejection code retained");
     }
    } else {
     is($actual->{error}, undef, "$label $input has no execution error");
    }
   }
  }
  diag('EMITTED_RULE_PROGRESS_ACTUAL ' . $name . ' ' . $json->encode({routes => \%observed, metadata => $metadata}));
 };
}

check_source('ordinary direct cycle and repeated invocation',
 "Top::\n I {return(call(Top))}\n", [['x', undef, 0], ['y', undef, 0]]);
check_source('ordinary mutual cycle',
 "Top::\n I {return(call(Child))}\nChild:\n I {return(call(Top))}\n", [['x', undef, 0]]);

my $single = "Value:AND\n /H/\n /cat/ -> Value[1] {return(\"BODY\")}\n";
check_source('blind push retains parent call semantics',
 "Top::\n => Value .push\n LX {return(copy(Top))}\n" . $single, [['Hcat', ['BODY'], 4]]);
check_source('blind push with protected sparse structural capture', <<'SPEC', [['AxxBC', ['xxB'], 5]]);
Top::
 => Value .push
 LX {return(copy(Top))}
Value:AND
 /A/ -> Value[0] {start_capture_slice()}
 /xxB/
 /C/ -> Value[2] {return(capture_slice())}
SPEC
check_source('blind push with repeated sparse groups', <<'SPEC', [['HcatHcat', [[['cat'], ['cat']]], 8]]);
Top::
 => Value .push
 LX {return(copy(Top))}
Value:AND{2}
 I {pairs=[];pair=[]}
 /H/
 /cat/
 -> Value[1] {push(pair,match_text())}
 IT {push(pairs,copy(pair));pair=[]}
 E {return(copy(pairs))}
SPEC
check_source('blind without suffix remains a normal child collection',
 "Top::\n => Value\n" . $single, [['Hcat', ['BODY'], 4]]);
check_source('consuming recursion preserves nested results',
 "Top::\n -> Letter {return([match_text(),call(Top)])}\nLetter:\n /a/\n",
 [['aaa', ['a', ['a', ['a', undef]]], 3]]);
check_source('early return releases the entry for reuse',
 "Top::\n I {return(7)}\n", [['x', 7, 0], ['y', 7, 0]]);
check_source('matcher exception releases the entry before retry',
 "Top::\n /a/ -> Top {return(1)}\n", [['a', undef, 0, 'matcher'], ['a', 1, 1]]);

check_source('recursive observation preserves direct rejection',
 "Top::\n I {value=observe_recognition(top_observation,call(Child));return(value)}\n" .
 "Child:\n I {value=observe_recognition(observation,call(Child));return(value)}\n",
 [['x', undef, 0, 'source_location_nonprogress_direct_recursion']]);
check_source('recursive observation preserves mutual rejection',
 "Top::\n I {value=observe_recognition(top_observation,call(Child));return(value)}\n" .
 "Child:\n I {value=observe_recognition(observation,call(Other));return(value)}\n" .
 "Other:\n I {value=observe_recognition(observation,call(Child));return(value)}\n",
 [['x', undef, 0, 'source_location_nonprogress_mutual_recursion']]);
check_source('recognition preserves its typed zero progress rejection',
 "Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Child));recognition_rollback(tx);return(matched)}\n /never/\n" .
 "Child::\n I {return(call(Child))}\n /(?=c)/\n",
 [['c', undef, 0, 'recognition_zero_progress_recursive_cycle']]);

subtest 'wrapper preserves call context argument aliases and opaque exceptions' => sub {
 my $wrap = LinkedSpec::RecognitionTransactionRuntime->can('guard_rule_handler');
 plan skip_all => 'emitted wrapper does not exist before wiring' unless $wrap;
 my ($descriptor, $text, $argument) = ({}, 'x', 'original');
 my @contexts;
 my $handler = $wrap->('Top', sub {
  push @contexts, wantarray;
  $_[2] = 'changed';
  return wantarray ? (2, 3) : 5;
 });
 is(scalar($handler->($descriptor, \$text, $argument)), 5, 'scalar context preserved');
 is_deeply([$handler->($descriptor, \$text, $argument)], [2, 3], 'list context preserved');
 $handler->($descriptor, \$text, $argument);
 is_deeply(\@contexts, ['', 1, undef], 'void context also reaches the original handler');
 is($argument, 'changed', 'argument aliases reach the original handler');
 my $error = bless {}, 'LinkedSpec::EmittedRuleProgressTestError';
 my $fail = 1;
 my $throwing = $wrap->('Top', sub {die $error if $fail;return(8)});
 eval {$throwing->($descriptor, \$text)};
 is(refaddr($@), refaddr($error), 'same opaque thrown object escapes');
 $fail = 0;
 is($throwing->($descriptor, \$text), 8, 'exception cleanup permits reuse');
};

done_testing();

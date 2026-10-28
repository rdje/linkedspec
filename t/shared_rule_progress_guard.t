use strict;
use warnings;
use Test::More;
use JSON::PP ();
use POSIX ();
use LinkedSpec ();
use LinkedSpec::RecognitionTransactionRuntime ();

# TYPE-REFERENCE-BOOK.1.2.23.3.39.6.1: preserve native recursion behavior
# while extracting its ordinary guard for reuse by standalone handlers.
my $json = JSON::PP->new->canonical->ascii->allow_nonref;
my $runtime = 'LinkedSpec::RecognitionTransactionRuntime';

sub native_case {
 my ($name, $source, $cases) = @_;
 subtest $name => sub {
  my %ctx;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
  ok(ref($parser) eq 'CODE', 'native parser builds');
  return unless ref($parser) eq 'CODE';
  for my $case (@$cases) {
   my ($text, $expected, $position, $want_error, $error_code) = @$case;
   local $SIG{ALRM} = sub {POSIX::_exit(124)};
   alarm(5);
   my $value = eval {$parser->(\$text)};
   my $error = $@ || $ctx{last_error};
   alarm(0);
   is($json->encode($value), $json->encode($expected), 'exact native result');
   is(pos($text), $position, 'exact native cursor');
   is($error ? 1 : 0, $want_error ? 1 : 0, 'error delivery remains distinct from an ordinary cut');
   is(ref($error) ? $error->{code} : undef, $error_code, 'typed scope rejection keeps its code')
    if defined $error_code;
  }
 };
}

native_case('direct cycle cuts and the same parser remains reusable',
 "Top::\n I {return(call(Top))}\n", [['x', undef, 0], ['y', undef, 0]]);
native_case('mutual cycle cuts without consuming',
 "Top::\n I {return(call(Child))}\nChild:\n I {return(call(Top))}\n", [['x', undef, 0]]);
native_case('consume before recursion keeps the complete result',
 "Top::\n -> Letter {return([match_text(),call(Top)])}\nLetter:\n /a/\n",
 [['aaa', ['a', ['a', ['a', undef]]], 3]]);
subtest 'a matcher error releases the entry before another parse' => sub {
 my $source = "Top::\n /a/ -> Top {return(1)}\n";
 my %ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
 ok(ref($parser) eq 'CODE', 'native parser builds');
 return unless ref($parser) eq 'CODE';
 my $text = 'a';
 {
  no warnings qw(redefine once);
  local *LinkedRE::or = sub {die "SHARED_RULE_PROGRESS_MATCHER_FAILURE\n"};
  is($parser->(\$text), undef, 'existing native failure channel returns undef');
 }
 is($ctx{last_error}{type}, 'runtime_handler', 'native structured error channel is preserved');
 like($ctx{last_error}{detail}, qr/SHARED_RULE_PROGRESS_MATCHER_FAILURE/, 'original matcher error is retained');
 pos($text) = 0;
 is($parser->(\$text), 1, 'same parser and position work after the exception');
 is(pos($text), 1, 'successful retry consumes the input');
 ok(!$ctx{last_error}, 'successful invocation clears the prior native error');
};
native_case('ordinary early returns release the entry',
 "Top::\n I {return(7)}\n", [['x', 7, 0], ['xx', 7, 0]]);

native_case('recursive observation retains direct typed rejection',
 "Top::\n I {value=observe_recognition(top_observation,call(Child));return(value)}\n" .
 "Child:\n I {value=observe_recognition(observation,call(Child));return(value)}\n",
 [['x', undef, 0, 1, 'source_location_nonprogress_direct_recursion']]);
native_case('recursive observation retains mutual typed rejection',
 "Top::\n I {value=observe_recognition(top_observation,call(Child));return(value)}\n" .
 "Child:\n I {value=observe_recognition(observation,call(Other));return(value)}\n" .
 "Other:\n I {value=observe_recognition(observation,call(Child));return(value)}\n",
 [['x', undef, 0, 1, 'source_location_nonprogress_mutual_recursion']]);
native_case('recognition retains its zero progress error instead of an ordinary cut',
 "Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Child));recognition_rollback(tx);return(matched)}\n /never/\n" .
 "Child::\n I {return(call(Child))}\n /(?=c)/\n",
 [['c', undef, 0, 1, 'recognition_zero_progress_recursive_cycle']]);

sub shared_entry {
 my ($descriptor, $text, $rule) = @_;
 return $runtime->can('enter_rule_progress')->($descriptor, $text, $rule);
}
sub shared_case {
 my ($name, $body) = @_;
 subtest $name => sub {
  plan skip_all => 'shared entry does not exist before the extraction'
   unless $runtime->can('enter_rule_progress');
  $body->();
 };
}

shared_case('native dispatch actually uses the shared owner', sub {
 my $original = $runtime->can('enter_rule_progress');
 my $calls = 0;
 no warnings qw(redefine once);
 local *LinkedSpec::RecognitionTransactionRuntime::enter_rule_progress = sub {
  ++$calls;
  return $original->(@_);
 };
 my $source = "Top::\n I {return(call(Top))}\n";
 my $parser = LinkedSpec::Get(\$source);
 $calls = 0; # Bootstrap parsing during Get also uses native rule handlers.
 my $text = 'x';
 local $SIG{ALRM} = sub {POSIX::_exit(124)};
 alarm(5);
 is($parser->(\$text), undef, 'public native cycle remains a cut');
 alarm(0);
 is($calls, 2, 'both the outer entry and rejected re-entry use the shared owner');
});
shared_case('guard identity distinguishes descriptors rules and consumed positions', sub {
 my ($one, $two, $text) = ({}, {}, 'ab');
 pos($text) = 0;
 my $a = shared_entry($one, \$text, 'Top');
 ok($a, 'first entry accepted');
 ok(!shared_entry($one, \$text, 'Top'), 'same active key is cut');
 my $b = shared_entry($two, \$text, 'Top');
 my $c = shared_entry($one, \$text, 'Child');
 ok($b && $c, 'different descriptor and rule enter independently');
 pos($text) = 1;
 my $d = shared_entry($one, \$text, 'Top');
 ok($d, 'consuming recursion enters');
 pos($text) = 0;
 ok(!shared_entry($one, \$text, 'Top'), 'rewinding to the active ancestor is cut');
 undef $a;
 my $e = shared_entry($one, \$text, 'Top');
 ok($e, 'released ancestor key can be used again');
});
shared_case('release is idempotent and cannot remove a later entry', sub {
 my ($descriptor, $text) = ({}, 'x');
 my $a = shared_entry($descriptor, \$text, 'Top');
 $a->finish();
 my $b = shared_entry($descriptor, \$text, 'Top');
 ok($b, 'explicit release permits reuse');
 $a->finish();
 undef $a;
 ok(!shared_entry($descriptor, \$text, 'Top'), 'old token cannot release the new active entry');
 undef $b;
 ok(shared_entry($descriptor, \$text, 'Top'), 'new token destruction releases its own entry');
});
shared_case('destruction preserves caller error and thrown object identity', sub {
 my ($descriptor, $text) = ({}, 'x');
 my $a = shared_entry($descriptor, \$text, 'Top');
 $@ = "preserved error\n";
 undef $a;
 is($@, "preserved error\n", 'normal destruction preserves caller error');
 my $error = bless {}, 'LinkedSpec::SharedRuleProgressTestError';
 eval {my $guard = shared_entry($descriptor, \$text, 'Top');die $error};
 is($@, $error, 'unwinding preserves the same thrown object');
 ok(shared_entry($descriptor, \$text, 'Top'), 'exception unwinding releases the key');
});

done_testing();

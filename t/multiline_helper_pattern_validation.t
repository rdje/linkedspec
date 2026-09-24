use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../perl";
use LinkedSpec ();
use LinkedSpec::Validation ();

sub source_for {
 my ($action, $separator, $input_pattern) = @_;
 $separator //= "\n";
 $input_pattern //= 'x';
 my $source = "Top::\n -> Done { $action }\nDone:\n /$input_pattern/\n";
 $source =~ s/\n/$separator/g;
 return $source;
}

for my $separator ("\n", "\r\n") {
 subtest $separator eq "\n" ? 'LF helper pattern' : 'CRLF helper pattern' => sub {
  my $escaped_separator = $separator eq "\n" ? '\n' : '\r\n';
  my $action = 'return(matches(cat("x", "' . $escaped_separator . '", "y"), /(x)' . "\n" . 'y/))';
  my $source = source_for($action, $separator);
  my $original = $source;
  ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), 'whole source validates');
  is($source, $original, 'validation preserves authored source');
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  ok($parser, 'public parser builds');
  my $input = 'x';
  is($parser ? $parser->(\$input) : undef, 1, 'public helper executes');
  is($context{last_error}, undef, 'no deferred handler error');
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  ok(exists($descriptor->{spec}{Done}), 'following rule retains its descriptor');
 };
}

subtest 'protected payload versus real structure' => sub {
 for my $payload ('Fake:', '@capture_gaps', 'head=/x/', '-> Missing', '=> Missing', '}') {
  my $source = source_for('return(matches("x", /start' . "\n$payload\n" . 'end/))');
  ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), "pattern protects $payload");
 }
 for my $suffix ("Broken:::\n", "Done:\n /z/\n", " }\n", " \@capture_gaps\n \@capture_gaps\n") {
  my $source = source_for('return(matches("x", /start' . "\n" . 'end/))') . $suffix;
  ok(!LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), 'real malformed trailing structure rejects');
 }
};

subtest 'division newline compatibility' => sub {
 for my $tail ('note = 1', '# pattern/' . "\n" . 'note = 1') {
  my $source = source_for("out = /(14,2)\n$tail; return(out)");
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  is($parser ? $parser->(\$input) : undef, 7, "division before $tail");
  is($context{last_error}, undef, 'no handler error');
 }
 for my $tail ('rx = q/;/', 'rx = qr/}/', 'rx = q|/;|', 'rx = s/a;b/c;d/') {
  my $lowered = LinkedSpec::call_spec_handler_subst('Top', "out = /(14,2)\n$tail; return(out)");
  my $run = eval "sub { no strict; $lowered }";
  is($@, '', 'host compatibility lowering compiles');
  local $_ = 'x';
  is($run ? $run->() : undef, 7, "isolated division before $tail");
 }
};

subtest 'helper families and nested action contexts' => sub {
 my @cases = (
  ['split', 'return(split("aX\nYb", /X' . "\n" . 'Y/))', ['a', 'b']],
  ['receiver filter', 'return(["x\ny", "z"].filter_match(/x' . "\n" . 'y/))', ["x\ny"]],
  ['substitution', 'text = match_text(); regex_subst(text, /x' . "\n" . 'y/, "ok", g); return(text)', 'ok', "x\ny"],
  ['following statement', 'hit = matches("x\ny", /x' . "\n" . 'y/)' . "\n" . 'note = 7; return(array(hit, note))', [1, 7]],
  ['escaped delimiter', 'return(matches("a/\nb", /a\/' . "\n" . 'b/))', 1],
  ['argument on next line', 'return(matches("x\ny",' . "\n" . '/x' . "\n" . 'y/))', 1],
 );
 for my $case (@cases) {
  my ($name, $action, $expected, $subject) = @$case;
  my $source = source_for($action, undef, defined($subject) ? '[\s\S]+' : 'x');
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = $subject // 'x';
  is_deeply($parser ? $parser->(\$input) : undef, $expected, $name) or diag(explain(\%context));
  is($context{last_error}, undef, "$name has no error");
 }
 # Structural validation remains independently covered alongside execution.
 for my $action (
  'text = "x\ny"; regex_subst(text, /x' . "\n" . 'y/, "ok", g); return(text)',
  'hit = matches("x\ny", /x' . "\n" . 'y/)' . "\n" . 'note = 7; return(array(hit, note))',
  'if(true); hit = matches("x\ny", /x' . "\n" . 'y/); endif',
 ) {
  my $source = source_for($action);
  ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), 'helper structure validates independently of lowering');
 }
 for my $prefix ('Top:: I { ', "Top::\n I { ", "Top::\n I { if(true); ") {
  my $suffix = $prefix =~ /if/ ? '; endif }' : ' }';
  my $source = $prefix . 'hit = matches("x\ny", /x' . "\n" . 'y/)' . $suffix
   . "\n -> Done { return(hit) }\nDone:\n /x/\n";
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  is($parser ? $parser->(\$input) : undef, 1, "lifecycle and nested control execute: $prefix") or diag(explain(\%context));
  is($context{last_error}, undef, 'lifecycle has no error');
 }
};

subtest 'real diagnostics retain authored line context' => sub {
 my $source = "Top::\n I { hit = matches(\"x\", /start\nend/) } broken garbage\n -> Done\nDone:\n /x/\n";
 my %failure;
 ok(!LinkedSpec::Validation::validate_dsl_syntax(\$source, {
  on_failure => sub { %failure = @_ },
 }), 'unsupported lifecycle remainder rejects');
 is($failure{summary}, 'Unsupported lifecycle block remainder', 'correct failure owner');
 like($failure{detail}, qr/DSL Error at line 3:/, 'original physical line number');
 like($failure{detail}, qr{Line: end/\) \} broken garbage}, 'original pattern and remainder in diagnostic');
 my $repeated = source_for('return(matches("x", /start' . "\nBroken:::\n" . 'end/))')
  . "Broken:::\n";
 %failure = ();
 ok(!LinkedSpec::Validation::validate_dsl_syntax(\$repeated, {
  on_failure => sub { %failure = @_ },
 }), 'real malformed header after identical pattern payload rejects');
 like($failure{detail}, qr/DSL Error at line 7:/, 'reports the real header occurrence, not the protected payload');
 for my $action ('return(matches("x", /start' . "\n" . 'end))',
                 'return(matches("x", /start' . "\n" . 'end/)',
                 'return(matches("x", /(start' . "\n" . 'end/))') {
  my $source = source_for($action);
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  if ($parser) { my $input = 'x'; $parser->(\$input) }
  ok($context{last_error}, 'unterminated pattern, action or invalid regex still rejects');
 }
};

subtest 'pattern tokens preserve subsequent statements and generated execution' => sub {
 my $serial = 0;
 for my $separator ('', "\n", "\r\n") {
  for my $word (qw(y s m q tr qr qq qx)) {
   my $literal = length($separator) ? 'start' . $separator . $word : $word;
   # Input captures isolate pattern boundaries from string-literal lowering.
   my $action = 'text = match_text(); regex_subst(text, /' . $literal
    . '/, "ok", g); hit = matches(match_text(), /' . $literal
    . '/); return(array(text, hit))';
   my $source = source_for($action, undef, '[\s\S]+');
   my %context;
   my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
   my $input = $literal;
   is_deeply($parser ? $parser->(\$input) : undef, ['ok', 1], "literal ends in $word, separator length " . length($separator))
    or diag(explain(\%context));
   is($context{last_error}, undef, 'no deferred failure');
   # Independently evaluate emitted source for each line-ending family.
   if ($word eq 'y') {
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'helper-pattern.spec');
    my $package = 'HelperPatternGenerated' . ++$serial;
    my $loaded = eval "package $package; $emitted; 1";
    ok($loaded, 'emitted source loads') or diag($@);
    my $execute = $package->can('Execute');
    my $input = $literal;
    is_deeply($execute ? $execute->(\$input) : undef, ['ok', 1], 'emitted source executes preserved helper tokens');
   }
  }
 }
 for my $case (
  ['a[;#{}]b', 'a;b'], ['(a)b', 'ab'], ['a\/b', 'a/b'],
 ) {
  my ($pattern, $subject) = @$case;
  my $source = source_for('hit = matches(match_text(), /' . $pattern
   . '/); note = 7; return(array(hit, note))', undef, '[\s\S]+');
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = $subject;
  is_deeply($parser ? $parser->(\$input) : undef, [1, 7], "pattern punctuation retains continuation: $pattern");
  is($context{last_error}, undef, 'punctuation has no handler error');
 }
 {
  my $source = source_for('text = "y"; regex_subst(text, /y/, "yy", g); return(text)');
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  is($parser ? $parser->(\$input) : undef, 'yy', 'mutation executes exactly once');
  is($context{last_error}, undef, 'once-only mutation has no handler error');
 }
 for my $expression ('/(14, 2)', 'add(/(14, 2), 1)', 'add(1, /(14, 2))') {
  my $source = source_for("value = $expression\nnote = 1; return(value)");
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  my $expected = $expression =~ /^add/ ? 8 : 7;
  is($parser ? $parser->(\$input) : undef, $expected, 'division stays numeric inside helper arguments');
  is($context{last_error}, undef, 'numeric operand has no error');
 }
};

subtest 'physical multiline quoted operands retain structure and values' => sub {
 my $serial = 0;
 for my $quote (q{'}, q{"}) {
  for my $separator ("\n", "\r\n") {
   my $quoted = $quote . "x\ny" . $quote;
   my $mutation = 'text = ' . $quoted . '; regex_subst(text, /x' . "\n" . 'y/, "ok", g)';
   my @cases = (
    ['literal return', source_for('return(' . $quoted . ')'), "x${separator}y"],
    ['leading newline', source_for('return(' . $quote . "\ny" . $quote . ')'), "${separator}y"],
    ['trailing newline', source_for('return(' . $quote . "x\n" . $quote . ')'), "x${separator}"],
    ['inline subject', source_for('return(matches(' . $quoted . ', /x' . "\n" . 'y/))'), 1],
    ['assigned subject', source_for($mutation . '; return(text)'), 'ok'],
    ['member lifecycle', "Top::\n I { $mutation }\n -> Done { return(text) }\nDone:\n /x/\n", 'ok'],
    ['inline lifecycle', "Top:: I { $mutation }\n -> Done { return(text) }\nDone:\n /x/\n", 'ok'],
   );
   for my $case (@cases) {
    my ($name, $source, $expected) = @$case;
    $source =~ s/\n/$separator/g;
    my $original = $source;
    ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), "$name validates with $quote and separator length " . length($separator));
    is($source, $original, 'authored source is unchanged');
    my %context;
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
    my $input = 'x';
    is_deeply($parser ? $parser->(\$input) : undef, $expected, 'public execution preserves exact quoted value')
     or diag(explain(\%context));
    is($context{last_error}, undef, 'no deferred handler error');
    if ($name eq 'assigned subject') {
     my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'quoted-subject.spec') };
     ok(defined($emitted), 'quoted subject emits source') or diag(explain($@));
     if (defined $emitted) {
      my $package = 'QuotedSubjectGenerated' . ++$serial;
      my $loaded = eval "package $package; $emitted; 1";
      ok($loaded, 'emitted quoted subject loads') or diag($@);
      my $execute = $package->can('Execute');
      $input = 'x';
      is($execute ? $execute->(\$input) : undef, 'ok', 'independent generated execution preserves quoted subject');
     }
    }
   }
  }
 }
};

subtest 'quoted payload cannot masquerade as real rule structure' => sub {
 for my $quote (q{'}, q{"}) {
  for my $payload ('Fake:', '@capture_gaps', 'head=/x/', '-> Missing', '=> Missing', '}') {
   my $source = source_for('text = ' . $quote . "start\n$payload\nend" . $quote . '; return(text)');
   ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), "$quote protects $payload");
  }
  my $escaped = source_for('text = ' . $quote . 'start\\' . $quote . "\nFake:\nend" . $quote . '; return(text)');
  ok(LinkedSpec::Validation::validate_dsl_syntax(\$escaped, {}), 'escaped quote does not end multiline token');
  my $source = source_for('text = ' . $quote . "start\nBroken:::\nend" . $quote . '; return(text)')
   . "Broken:::\n";
  my %failure;
  ok(!LinkedSpec::Validation::validate_dsl_syntax(\$source, {
   on_failure => sub { %failure = @_ },
  }), 'real malformed header after identical quoted text rejects');
  is($failure{summary}, 'Malformed rule label syntax', 'real malformed header owns the error');
  like($failure{detail}, qr/DSL Error at line 7:/, 'diagnostic reports the real occurrence');
  for my $placement ('', 'Top::' . "\n") {
   my $outside = $placement . $quote . "start\nend" . $quote . "\nDone:\n /x/\n";
   ok(!LinkedSpec::Validation::validate_dsl_syntax(\$outside, {}), 'multiline string outside action syntax stays invalid');
  }
  for my $action ('text = ' . $quote . "start\nend", 'text = ' . $quote . "start\nend" . $quote . '; return(text)') {
   my $malformed = "Top::\n I { $action\n";
   my %context;
   my $parser = LinkedSpec::Get(\$malformed, runtime_ctx_ref => \%context);
   if ($parser) { my $input = 'x'; $parser->(\$input) }
   ok($context{last_error}, 'unclosed string or real action block still rejects');
  }
 }
};

subtest 'grouped regex operands preserve calls, continuations and generated values' => sub {
 my $serial = 0;
 for my $separator ("\n", "\r\n") {
  for my $case (['(x).*y', 'xy'], ['(x),y', 'x,y']) {
   my ($pattern, $subject) = @$case;
   for my $spelling ('literal', 'string', 'binding') {
    my $operand = $spelling eq 'literal' ? "/$pattern/"
     : $spelling eq 'string' ? qq{"$pattern"} : 'pattern';
    for my $continuation (0, 1) {
     my $call = "matches(match_text(), $operand)";
     my $action = $continuation ? "hit = $call\nnote = 7; return(array(hit, note))" : "return($call)";
     $action = qq{pattern = "$pattern"; $action} if $spelling eq 'binding';
     my $source = source_for($action, $separator, '[\s\S]+');
     my $original = $source;
     my %context;
     my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
     my $input = $subject;
     my $expected = $continuation ? [1, 7] : 1;
     is_deeply($parser ? $parser->(\$input) : undef, $expected,
      "$spelling $pattern, continuation $continuation, separator length " . length($separator));
     is($context{last_error}, undef, 'no deferred error');
     is($source, $original, 'authored bytes preserved');
     if ($spelling eq 'literal' && $continuation) {
      my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'grouped-helper-pattern.spec') };
      ok(defined($emitted) && length($emitted), 'generated source emits') or diag($@);
      my $package = 'GroupedHelperGenerated' . ++$serial;
      my $loaded = defined($emitted) ? eval("package $package; $emitted; 1") : undef;
      ok($loaded, 'generated source loads') or diag($@);
      my $execute = $package->can('Execute');
      my $generated_input = $subject;
      is_deeply($execute ? $execute->(\$generated_input) : undef, $expected, 'generated continuation agrees');
     }
    }
   }
  }
 }
 for my $case (
  ['flags', 'return(matches(match_text(), /(x),y/i))', 'X,Y', 1],
  ['quoted payload', q{return(matches('x,"', /(x),"/))}, 'x', 1],
  ['hash payload', 'return(matches(match_text(), /(x),#y/))', 'x,#y', 1],
  ['class payload', 'return(matches(match_text(), /(x),[;#{}]y/))', 'x,;y', 1],
  ['escaped closer', 'return(matches(match_text(), /(x),\)y/))', 'x,)y', 1],
  ['nested array', 'return(array(matches(match_text(), /(x),y/), matches(match_text(), /(x).*y/)))', 'x,y', [1,1]],
  ['conditional', 'if(true); hit = matches(match_text(), /(x),y/); endif; return(hit)', 'x,y', 1],
  ['operator-like variable', 's = match_text(); return(matches(s, /(x),y/))', 'x,y', 1],
  ['index q', 'q = [5,9]; return(q[matches("x,y", /(x),y/)])', 'x', 9],
  ['index m', 'm = [5,9]; return(m[matches("x,y", /(x),y/)])', 'x', 9],
  ['index qr', 'qr = [5,9]; return(qr[matches("x,y", /(x),y/)])', 'x', 9],
  ['split', 'return(split("ax,yb", /(x),y/))', 'x', ['a','x','b']],
  ['filter', 'return(["x,y", "z"].filter_match(/(x),y/))', 'x', ['x,y']],
  ['substitution', 'text = match_text(); regex_subst(text, /(x),y/, "ok", g); return(text)', 'x,y', 'ok'],
  ['quoted substitution', 'text = match_text(); regex_subst(text, /(x),"/, "ok", g); return(text)', 'x,"', 'ok'],
  ['fake helper in string', q{return('matches("x,y", /(x),y/)')}, 'x', 'matches("x,y", /(x),y/)'],
 ) {
  my ($name, $action, $subject, $expected) = @$case;
  my $source = source_for($action, undef, '[\s\S]+');
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = $subject;
  is_deeply($parser ? $parser->(\$input) : undef, $expected, $name) or diag(explain(\%context));
  is($context{last_error}, undef, "$name has no deferred error");
  if ($name eq 'index q') {
   my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'indexed-helper-pattern.spec') };
   my $loaded = defined($emitted) ? eval("package IndexedHelperGenerated; $emitted; 1") : undef;
   ok($loaded, 'indexed helper source emits and loads') or diag($@);
   my $execute = IndexedHelperGenerated->can('Execute');
   my $generated_input = $subject;
   is($execute ? $execute->(\$generated_input) : undef, 9, 'generated indexed helper retains the DSL variable');
  }
 }
};

subtest 'grouped pattern recognition preserves numeric and host interpretations' => sub {
 for my $case (
  ['host arithmetic', q{return(array(/(14,2), 14/cos))}, [7,14]],
  ['quoted argument', q{return(array(/(14,2), "a/)"))}, [7,'a/)']],
  ['receiver', q{return(array(/(14,2).floor(), 1))}, [7,1]],
  ['receiver and quote', q{return(array(/(14,2).floor().add(1), "a/)"))}, [8,'a/)']],
  ['outside comment', "value = add(/(14,2),1)\n# pattern/)\nreturn(value)", 8],
  ['wrong arity and quote', q{return(array(/(14), "a/)"))}, [undef,'a/)']],
  ['numeric pattern operand', q{return(matches("7", /(14,2)))}, 1],
  ['extra quoted pattern argument', q{return(matches("7", /(14,2), "a/)"))}, undef],
  ['host q pipe', q{return(q|matches("x,y", /(x),y/)|)}, undef, 'validate_dsl_syntax'],
  ['host q numeric', q{return(array(/(14,2), q|matches("xy", /(x).*y/)|))}, undef, 'validate_dsl_syntax'],
  ['host q brace', q{return(array(/(14,2), q{matches("xy", /(x).*y/)}))}, undef, 'validate_dsl_syntax'],
  ['host qq pipe', q{return(qq|matches("xy", /(x).*y/)|)}, undef, 'validate_dsl_syntax'],
  ['host quote rejection', q{return(array(/(14,2), q/)/))}, undef, 'validate_dsl_syntax'],
  ['inside comment rejection', "return(array(/(14,2),\n# pattern/)\n1))", undef, 'rule_handler_compile'],
  ['host arithmetic rejection', q{i = 2; return(array(/(14,2), 14/i))}, undef, 'rule_handler_eval'],
 ) {
  my ($name, $action, $expected, $stage) = @$case;
  my $source = source_for($action);
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  is_deeply($parser ? $parser->(\$input) : undef, $expected, "$name retains its value");
  if (defined($stage)) {
   is(($context{last_error} || {})->{stage}, $stage, "$name retains its failure owner");
  } else {
   is($context{last_error}, undef, "$name has no error");
  }
 }
};

subtest 'final slash calls before physical-line-ending block closers' => sub {
 my @cases = (
  ['compact', 'I {out=/(14,2)}'],
  ['spaces', 'I { out = /(14,2)   }'],
  ['bare lifecycle', '{ out=/(14,2) }'],
  ['nested if', 'I { if(1) { out=/(14,2) } }'],
  ['value block', 'I { out={ /(14,2) } }'],
  ['variables', 'I { a=14; b=2; out=/(a,b) }'],
  ['nested arguments', 'I { out=/(add(12,2),2) }'],
  ['quoted arguments', 'I { out=/("14","2") }'],
  ['semicolon control', 'I { out=/(14,2); }'],
  ['named control', 'I { out=div(14,2) }'],
  ['receiver control', 'I { out=/(14,2).floor() }'],
 );
 my $number = 0;
 for my $separator ("\n", "\r\n") {
  for my $case (@cases) {
   my ($name, $initial) = @$case;
   my $source = join($separator, 'Top::', " $initial", ' /x/ E { return(out) }', '');
   my $original = $source;
   my %context;
   my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
   ok($parser, "$name final call validates and compiles");
   my $input = 'x';
   is($parser ? $parser->(\$input) : undef, 7, "$name final call returns seven");
   is($context{last_error}, undef, "$name has no deferred error");
   is($source, $original, "$name retains exact authored bytes");
   my $emitted = eval { LinkedSpec::emit_generated_source(\$source) };
   my $emit_error = $@;
   ok(defined($emitted), "$name emits independently executable source") or diag(explain($emit_error));
   next unless defined($emitted);
   my $package = 'FinalSlashCall' . ++$number;
   my $loaded = eval "package $package; $emitted; 1";
   ok($loaded, "$name emitted source loads") or diag($@);
   my $execute = $package->can('Execute');
   $input = 'x';
   is($execute ? $execute->(\$input) : undef, 7, "$name emitted result is exact");
  }
 }
 for my $action (
  'out=/(14,2)',
  'out=/(14,2 }',
  'out=/(14,2) }}',
  'rx=qr/(14,2) }',
  'rx=m/(14,2) }',
 ) {
  my $source = "Top::\n I { $action\n /x/ E { return(out) }\n";
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  ok(!$parser, 'malformed structure or explicit unclosed host quote rejects');
  is(($context{last_error} || {})->{stage}, 'validate_dsl_syntax', 'failure remains structural validation');
 }
};

subtest 'full-source slash retry preserves regexes and publishes only selected diagnostics' => sub {
 for my $separator ("\n", "\r\n") {
  for my $case (
   ['assigned brace', "rx = /(14,2) }\ntext/; return(7)", undef, undef],
   ['assigned brace and spaces', "rx = /(14,2) }  \ntext/; return(7)", undef, undef],
   ['escaped brace', "rx = /(14,2) \\}\ntext/; return(7)", 7, undef],
   ['helper brace', "return(matches(\"14,2 }\\ntext\", /(14,2) }\ntext/))", undef, 'rule_handler_compile'],
   ['explicit host brace', "rx = qr/(14,2) }\ntext/; return(7)", undef, 'rule_handler_compile'],
  ) {
   my ($name, $action, $expected, $stage) = @$case;
   my $source = source_for($action, $separator);
   my $original = $source;
   my @failures;
   ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {
    on_failure => sub { push @failures, { @_ } },
   }), "$name keeps its accepted full-source regex structure");
   is_deeply(\@failures, [], "$name publishes no spurious structural failure");
   my %context;
   my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
   ok($parser, "$name retains its public build boundary");
   my $input = 'x';
   # The unescaped brace forms still have the independently owned .54.1
   # bootstrap defect. This repair must not move it to structural validation.
   is($parser ? $parser->(\$input) : undef, $expected, "$name retains its measured value");
   is(($context{last_error} || {})->{stage}, $stage, "$name retains its error owner");
   is($source, $original, "$name retains authored bytes");
  }
 }

 require LinkedSpec::Trace;
 my @events;
 no warnings 'redefine';
 local *LinkedSpec::Trace::log_output = sub { push @events, ['trace', @_]; return };
 my $valid = "Top::\n I { out=/(14,2) }\n /x/ E { return(out) }\n";
 ok(LinkedSpec::Validation::validate_dsl_syntax(\$valid, {
  on_failure => sub { push @events, ['failure', { @_ }] },
 }), 'successful final-call retry validates');
 is(scalar(grep { $_->[0] eq 'failure' } @events), 0, 'discarded regex attempt never notifies the caller');
 is(scalar(grep { $_->[0] eq 'trace' && ($_->[3] // '') eq 'DSL validation failed' } @events),
  0, 'discarded regex attempt never writes a validation error trace');

 @events = ();
 my $invalid = "Top::\n I { out=/(14,2) }\n stray=1\n";
 my $nested_valid;
 ok(!LinkedSpec::Validation::validate_dsl_syntax(\$invalid, {
  on_failure => sub {
   push @events, ['failure', { @_ }];
   $nested_valid = LinkedSpec::Validation::validate_dsl_syntax(\$valid, {});
  },
 }), 'both invalid interpretations reject');
 my @failures = grep { $_->[0] eq 'failure' } @events;
 is(scalar(@failures), 1, 'only the original failure reaches the callback');
 like($failures[0][1]{summary}, qr/Unclosed rule block/, 'both-failed retry retains the original diagnostic');
 is(scalar(grep { $_->[0] eq 'trace' && ($_->[3] // '') eq 'DSL validation failed' } @events),
  1, 'only one validation error reaches tracing');
 ok($nested_valid, 'failure callback can reenter validation after trial state is restored');
};

done_testing;

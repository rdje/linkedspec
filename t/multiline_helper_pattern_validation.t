use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../perl";
use LinkedSpec ();
use LinkedSpec::Validation ();

sub source_for {
 my ($action, $separator) = @_;
 $separator //= "\n";
 my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
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
  ['escaped delimiter', 'return(matches("a/\nb", /a\/' . "\n" . 'b/))', 1],
  ['argument on next line', 'return(matches("x\ny",' . "\n" . '/x' . "\n" . 'y/))', 1],
 );
 for my $case (@cases) {
  my ($name, $action, $expected) = @$case;
  my $source = source_for($action);
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  is_deeply($parser ? $parser->(\$input) : undef, $expected, $name) or diag(explain(\%context));
  is($context{last_error}, undef, "$name has no error");
 }
 # .86.4.6 owns lowering/execution of these already-valid helper operands.
 for my $action (
  'text = "x\ny"; regex_subst(text, /x' . "\n" . 'y/, "ok", g); return(text)',
  'hit = matches("x\ny", /x' . "\n" . 'y/)' . "\n" . 'note = 7; return(array(hit, note))',
  'if(true); hit = matches("x\ny", /x' . "\n" . 'y/); endif',
 ) {
  my $source = source_for($action);
  ok(LinkedSpec::Validation::validate_dsl_syntax(\$source, {}), 'helper structure validates independently of lowering');
 }
 for my $prefix ('Top:: I { ', "Top::\n I { ") {
  my $suffix = ' }';
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

done_testing;

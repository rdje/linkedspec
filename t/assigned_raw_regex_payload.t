use strict;
use warnings;
use Test::More;
use LinkedSpec ();
use LinkedSpec::ActionIR::StatementSplit ();

my $trim = sub { my $s = shift; $s =~ s/^\s+|\s+$//g; $s };
for my $newline ("\n", "\r\n") {
    my $literal = '/(14,2) \\}' . $newline . 'tail/';
    my $body = "rx = $literal; return(rx)";
    my $parts = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
        $body, {trim_action_ir_value => $trim});
    is_deeply($parts, ["rx = $literal", 'return(rx)'], 'raw multiline assignment stays one payload');
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', $body);
    ok(index($lowered, $literal) >= 0, 'lowering preserves exact authored pattern bytes');
    my $source = "Top::\n -> Done { $body }\nDone:\n /x/\n";
    my %context;
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
    my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'raw-pattern.spec');
    my $loaded = eval "package LinkedSpec::RawPatternGenerated; no warnings 'redefine'; $emitted; 1";
    ok($loaded, 'fresh raw pattern parser compiles') or diag($@);
    for my $semicolon ('', ';') {
        my $subject = 'x14,2 }' . $semicolon . $newline . 'tail';
        my $expected = $semicolon eq '' ? 1 : 0;
        # Independent literal oracle: use authored host-regex semantics, with no DSL transformation.
        my $oracle = eval 'sub { local $_ = shift; ' . $literal . ' ? 1 : 0 }';
        is($oracle->($subject), $expected, 'authored regex distinguishes inserted semicolon');
        local $_ = $subject;
        my $input = $subject;
        is($parser->(\$input) ? 1 : 0, $expected, 'native matches authored payload');
        if ($loaded) {
            my $fresh_input = $subject;
            is(LinkedSpec::RawPatternGenerated::Execute(\$fresh_input) ? 1 : 0,
                $expected, 'fresh parser matches authored payload');
        }
    }
    is($context{last_error}, undef, 'native raw pattern execution has no error');
}

for my $tail ('rx = qr/;/', 'rx = q/;/', 'rx = m/;/', 'rx = /i;/') {
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', "out = /(14,2)\n$tail; return(out)");
    my $run = eval "sub { no strict; $lowered }";
    ok($run, 'numeric slash and later quote retain compilation') or diag($@);
    local $_ = 'x';
    is($run ? $run->() : undef, 7, 'numeric slash retains division precedence');
}
my $payload = '/a[;]\\/b\\}' . "\n" . 'set(marker,7)/';
my $lowered = LinkedSpec::call_spec_handler_subst('Top', "marker=1; rx=$payload; return(marker)");
ok(index($lowered,$payload) >= 0, 'escapes, class, delimiter and helper-looking payload stay literal');
my $run = eval "sub { no strict; $lowered }";
ok($run, 'helper-looking pattern compiles') or diag($@);
local $_ = 'nomatch';
is($run ? $run->() : undef, 1, 'payload does not mutate a DSL binding');

done_testing() unless caller;
1;

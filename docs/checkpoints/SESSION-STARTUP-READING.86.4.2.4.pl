#!/usr/bin/env perl
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use JSON::PP ();

# Read-only language audit: fixed, side-effect-free action examples.
my @cases = (
    ['matches_literal', 'return(matches("abc", /b/))'],
    ['matches_string', 'return(matches("abc", "b"))'],
    ['matches_multiline', 'return(matches(cat("x", "\n", "y"), /(x)' . "\n" . 'y/))'],
    ['split_literal', 'return(split("a,b", /,/))'],
    ['filter_literal', 'return(filter_match(["ax", "by"], /^a/))'],
    ['filter_receiver', 'return(["ax", "by"].filter_match(/^a/))'],
    ['substitute_literal', 'text = "abc"; regex_subst(text, /b/, "B", g); return(text)'],
    ['assigned_literal', 'rx = /b/; return(rx)'],
    ['returned_literal', 'return(/b/)'],
    ['assigned_pattern_use', 'rx = /b/; return(matches("abc", rx))'],
    ['assigned_string_use', 'rx = "b"; return(matches("abc", rx))'],
    ['callable_operand', 'matcher = {|text| return(matches(text, /b/)) }; return(matcher("abc"))'],
    ['callable_string', 'matcher = {|text| return(matches(text, "b")) }; return(matcher("abc"))'],
);
my $json = JSON::PP->new->canonical;
for my $case (@cases) {
    my ($id, $action) = @$case;
    my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
    my @direct;
    for my $implicit ('abc', 'zzz') {
        my $run = eval "sub { no strict; $lowered }";
        my $compile_error = "$@";
        local $_ = $implicit;
        my $value = $run ? eval { $run->() } : undef;
        my $runtime_error = "$@";
        push @direct, { implicit => $implicit, value => $value,
            host_ref => ref($value), compile_error => $compile_error, error => $runtime_error };
    }
    my %context;
    my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    my $build_error = "$@";
    my $input = 'x';
    my $value = $parser ? eval { $parser->(\$input) } : undef;
    my $runtime_error = "$@";
    if (ref($context{last_error}) eq 'HASH' && ref($context{last_error}{detail})) {
        $context{last_error}{detail} = "$context{last_error}{detail}";
    }
    print $json->encode({ id => $id, action => $action, lowered => $lowered,
        direct => \@direct, public_value => $value, host_ref => ref($value),
        build_error => $build_error, runtime_error => $runtime_error, last_error => $context{last_error} }), "\n";
}
print $json->encode({ id => 'syntax_node',
    expression => LinkedSpec::ActionIR::AST::parse_action_expr('/b/') }), "\n";

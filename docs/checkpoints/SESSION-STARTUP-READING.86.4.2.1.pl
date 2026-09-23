#!/usr/bin/env perl
use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();

# Diagnostic only. Select the accepted or isolated archived implementation with
# the caller's -I path. The fixed inputs have no filesystem/process side effects.
for my $action (
    "out = /(14,2)\nrx = q/; num = 14/ + (2); return(out)",
    "out = /(14,2)\n# pattern/;\nreturn(out)",
) {
    my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
    my $run = eval "sub { no strict; $lowered }";
    my $compile_error = "$@";
    local $_ = 'x';
    my $action_value = $run ? eval { $run->() } : undef;
    my $action_error = "$@";
    my %context;
    my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
    my $build_error = "$@";
    my $input = 'x';
    my $public_value = $parser ? eval { $parser->(\$input) } : undef;
    my $runtime_error = "$@";
    print JSON::PP->new->canonical->encode({
        action => $action, lowered => $lowered,
        compile_error => $compile_error, action_error => $action_error,
        action_value => $action_value, build_error => $build_error,
        public_value => $public_value, runtime_error => $runtime_error,
        last_error => $context{last_error},
    }), "\n";
}

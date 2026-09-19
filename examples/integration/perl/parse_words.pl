#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(getcwd);
use Encode qw(decode FB_CROAK LEAVE_SRC);
use JSON::PP ();
use Scalar::Util qw(blessed);
use LinkedSpec::SpecLoader ();

my $json = JSON::PP->new->utf8->canonical->allow_nonref;
binmode STDOUT, ':raw' or die "Cannot configure stdout: $!\n";
binmode STDERR, ':raw' or die "Cannot configure stderr: $!\n";

# This is the example application's JSON projection, not a runtime error schema.
sub project_fields {
    my ($record, @fields) = @_;
    return { map {
        my $value = $record->{$_};
        $_ => ref($value) ? { class => ref($value), detail => "$value" } : $value
    } grep { defined $record->{$_} } @fields };
}

sub main {
    my @arguments = map { decode('UTF-8', $_, FB_CROAK | LEAVE_SRC) } @ARGV;
    my $diagnostics = @arguments && $arguments[0] eq '--diagnostics';
    shift @arguments if $diagnostics;
    shift @arguments if @arguments && $arguments[0] eq '--';
    die "Usage: parse_words.pl [--diagnostics] [--] GRAMMAR INPUT [INPUT ...]\n"
        unless @arguments >= 2;
    my $grammar = shift @arguments;
    my $cwd = decode('UTF-8', getcwd(), FB_CROAK | LEAVE_SRC);

    # This standalone JSON adapter owns its output channels. Native tracing is
    # separate from diagnostic_sink events and can emit even at level zero.
    local %ENV = %ENV;
    delete @ENV{qw(LINKEDSPEC_TRACE_LEVEL LINKEDSPEC_DUMP_VERBOSITY LINKEDSPEC_TRACE_FILE
        LINKEDSPEC_TRACE_MIRROR_STDOUT LINKEDSPEC_TRACE_RESET_FILE LINKEDSPEC_TRACE_EMOJI)};

    # Compile once. The exact path is relative to the caller's working directory.
    my $loaded = LinkedSpec::SpecLoader::load_and_compile_spec(
        LinkedSpec::SpecLoader::path_request($grammar),
        LinkedSpec::SpecLoader::load_options(cwd => $cwd, search_roots => []),
        { top_rule => 'Top', trace_level => -1, trace_log_file => '',
          trace_log_mode => 'route', trace_emoji => 0 },
    );
    my $parser = $loaded->compiled;
    my $options = $diagnostics ? { diagnostic_sink => sub {
        my ($event) = @_;
        print STDERR $json->encode({ type => 'diagnostic', event => {%$event} }), "\n"
            or die "Cannot write diagnostic: $!\n";
    }} : {};

    for my $argument (@arguments) {
        # Each invocation receives an independent input scalar and parser state.
        my $input = $argument;
        my $value;
        my $ok = eval { $value = $parser->(\$input, $options); 1 };
        my $exception = $@; # Snapshot before another eval can replace it.
        my $context = $loaded->runtime_ctx->{last_error};
        if (ref($context) eq 'HASH') {
            my $record = { type => 'runtime_error', context => project_fields($context,
                qw(type stage code summary detail owner_stage rule_label handler_source_label)) };
            $record->{exception} = { class => ref($exception), detail => "$exception" } unless $ok;
            die bless($record, 'IntegrationExample::Failure');
        }
        die $exception unless $ok; # Includes typed exit and caller sink failures.
        print STDOUT $json->encode($value), "\n" or die "Cannot write result: $!\n";
    }
}

my $ok = eval { main(); 1 };
unless ($ok) {
    my $error = $@;
    my $record;
    if (blessed($error) && $error->isa('LinkedSpec::SpecLoader::Error')) {
        $record = $error->to_hash;
    } elsif (blessed($error) && $error->isa('LinkedSpec::RuntimeExitNow')) {
        $record = { type => 'runtime_exit_now', status => $error->status,
                    rule_label => $error->{rule_label} };
    } elsif (blessed($error) && $error->isa('LinkedSpec::RuntimeDiagnosticOutput::Error')) {
        $record = project_fields($error, qw(kind code summary detail rule_label helper_name
            actual_arity expected_arity arguments_evaluated));
        $record->{type} = 'runtime_diagnostic_output_error';
    } elsif (blessed($error) && $error->isa('IntegrationExample::Failure')) {
        $record = {%$error};
    } else {
        $record = { type => 'consumer_error', class => ref($error), detail => "$error" };
    }
    print STDERR $json->encode($record), "\n";
    exit 1;
}

1;

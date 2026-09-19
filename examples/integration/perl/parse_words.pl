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

sub main {
    die "Usage: parse_words.pl GRAMMAR INPUT [INPUT ...]\n" unless @ARGV >= 2;
    my @arguments = map { decode('UTF-8', $_, FB_CROAK | LEAVE_SRC) } @ARGV;
    my $grammar = shift @arguments;
    my $cwd = decode('UTF-8', getcwd(), FB_CROAK | LEAVE_SRC);

    # Compile once. The exact path is relative to the caller's working directory.
    my $loaded = LinkedSpec::SpecLoader::load_and_compile_spec(
        LinkedSpec::SpecLoader::path_request($grammar),
        LinkedSpec::SpecLoader::load_options(cwd => $cwd, search_roots => []),
        { top_rule => 'Top' },
    );
    my $parser = $loaded->compiled;

    for my $argument (@arguments) {
        # Each invocation receives an independent input scalar and parser state.
        my $input = $argument;
        my $value = $parser->(\$input);
        print STDOUT $json->encode($value), "\n" or die "Cannot write result: $!\n";
    }
}

my $ok = eval { main(); 1 };
unless ($ok) {
    my $error = $@;
    my $record = blessed($error) && $error->isa('LinkedSpec::SpecLoader::Error')
        ? $error->to_hash
        : { type => 'consumer_error', detail => "$error" };
    print STDERR $json->encode($record), "\n";
    exit 1;
}

1;

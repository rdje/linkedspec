#!/usr/bin/env perl
# Fixed .86.5.3 slot-identity intake; run through tools/project_data_run.sh.
use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
my $json = JSON::PP->new->canonical;
for my $case (
 ['separate', " I { out=div(14,2) }\n slot=/x/\n"],
 ['after_init', " I { out=div(14,2) } slot=/x/\n"],
 ['before_exit', " slot=/x/ E { return(42) }\n"],
 ['between', " I { out=div(14,2) } slot=/x/ E { return(42) }\n"],
 ['anonymous_between', " I { out=div(14,2) } /x/ E { return(42) }\n", 1],
) {
 my ($id, $body, $anonymous) = @$case;
 my $selector = $anonymous ? '0' : 'slot';
 my $source = "Top::\n -> Done[$selector] { return(8) }\nDone:\n$body";
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my @values;
 for my $text ('x', 'y') {
  my $input = $text;
  push @values, $parser ? $parser->(\$input) : undef;
 }
 my %descriptor_context;
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%descriptor_context);
 print $json->encode({
  id => $id, source => $source, parser_ready => $parser ? 1 : 0, values => \@values,
  last_error => $context{last_error}, descriptor_error => $descriptor_context{last_error},
  slots => $descriptor ? $descriptor->{spec}{Done}{meta}{regex_slots} : undef,
 }), "\n";
}

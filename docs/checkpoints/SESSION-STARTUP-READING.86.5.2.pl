#!/usr/bin/env perl
# Same-line member intake. Run through tools/project_data_run.sh from repository root.
# No-edge I/E results retain the known .27 defect; use the .86.5.2.1 edge control
# to distinguish an authored return from leaked lifecycle assignment values.
use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
my $json = JSON::PP->new->canonical;
for my $case (
 ['regex', '/x/ E { return(out) }'],
 ['regex_compact', '/x/E{return(out)}'],
 ['lifecycle', 'E { return(out) }'],
 ['quoted_slash', 'E { return("/") }'],
 ['named_slot', 'slot=/x/ E { return(out) }'],
 ['named_slot_end', 'slot=/x/', " E { return(out) }\n"],
 ['another_init', 'I { out=add(out,1) } /x/ E { return(out) }'],
 ['nested_init', 'I { nested={ out } } /x/ E { return(out) }'],
 ['edge', '-> Done { return(out) }', "Done:\n /x/\n"],
 ['unsupported_tail', 'stray=1'],
) {
 for my $call ('/(14,2)', '/(14,2);', 'div(14,2)') {
  my ($id, $tail, $suffix) = @$case;
  my $source = "Top::\n I { out=$call } $tail\n" . ($suffix // '');
  my %context;
  my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
  my $build_error = "$@";
  my $input = 'x';
  my $value = $parser ? eval { $parser->(\$input) } : undef;
  my $runtime_error = "$@";
  print $json->encode({
   id => $id, call => $call, source => $source, parser_ready => $parser ? 1 : 0,
   value => $value, last_error => $context{last_error}, build_error => $build_error,
   runtime_error => $runtime_error,
  }), "\n";
 }
}

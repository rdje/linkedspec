#!/usr/bin/env perl
use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();

# Original Perl compatibility/negative sources from the .86.2 intake.
# Assignment patterns are host-compatibility observations, not regex values.
# Run from the repository root through tools/project_data_run.sh.
my @cases = (
 ['division_newline', "out = /(14,2)\nnote = 1; return(out)"],
 ['assigned_group', 'rx = /(x)/; return(7)'],
 ['assigned_escaped_close', 'rx = /(\))/; return(7)'],
 ['invalid_quoted_close', 'rx = /(")")/; return(7)'],
 ['assigned_multiline', "rx = /(x)\ny/; return(7)"],
 ['assigned_numeric_multiline', "rx = /(14,2)\ntext/; return(7)"],
 ['assigned_numeric_next', "rx = /(14,2)\nnext = /; return(7)"],
 ['assigned_crlf', "rx = /(x)\r\ny/; return(7)"],
 ['slash_eof', 'out = /(14,2)', 1],
 ['slash_eof_space', 'out = /(14,2) ', 1],
 ['slash_eof_semicolon', 'out = /(14,2);', 1],
 ['named_eof', 'out = div(14,2)', 1],
);
my $json = JSON::PP->new->canonical;
for my $case (@cases) {
 my ($id, $action, $lifecycle) = @$case;
 my $source = $lifecycle
  ? "Top::\n I { $action }\n /x/ E { return(out) }\n"
  : "Top::\n -> Done { $action }\nDone:\n /x/\n";
 my $original = $source;
 my %context;
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
 my $build_error = "$@";
 my $input = 'x';
 my $value = $parser ? eval { $parser->(\$input) } : undef;
 my $runtime_error = "$@";
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
 print $json->encode({
  id => $id, action => $action, source => $original,
  source_unchanged => $source eq $original ? 1 : 0,
  parser_ready => ref($parser) eq 'CODE' ? 1 : 0,
  value => $value, build_error => $build_error, runtime_error => $runtime_error,
  last_error => $context{last_error}, lowered => $lowered,
 }), "\n";
}

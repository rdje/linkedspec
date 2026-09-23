#!/usr/bin/env perl
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::Validation ();
use JSON::PP ();

# Fixed comment-boundary intake for existing repair owner .34.1.
# This source does not implement a comment or numeric precedence change.
my $json = JSON::PP->new->canonical;
for my $receiver ('', '.floor()') {
 for my $placement ('none', 'inline', 'standalone') {
  my $head = 'hit = matches("7", /(14,2)' . $receiver . ');';
  my $action = $head . ($placement eq 'none' ? ''
   : $placement eq 'inline' ? ' # pattern/)' : "\n# pattern/)") . "\nreturn(hit)";
  my ($first_line) = split /\n/, $action;
  my $scan = LinkedSpec::Validation::_scan_rule_edges_in_fragment(' -> Done { ' . $first_line, 0);
  my $next = LinkedSpec::Validation::_scan_rule_edges_in_fragment('return(hit) }', $scan->{depth});
  my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
  my $run = eval "sub { no strict; $lowered }";
  my $compile_error = "$@";
  my $direct = $run ? eval { $run->() } : undef;
  my $direct_error = "$@";
  my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  my $public = $parser ? $parser->(\$input) : undef;
  print $json->encode({ receiver => $receiver, placement => $placement, action => $action,
   first_line_scan => $scan, final_line_scan => $next, lowered => $lowered,
   compile_error => $compile_error, direct => $direct, direct_error => $direct_error,
   public => $public, last_error => $context{last_error} }), "\n";
 }
}

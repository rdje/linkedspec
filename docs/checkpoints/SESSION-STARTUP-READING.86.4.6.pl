#!/usr/bin/env perl
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::Validation ();
use JSON::PP ();

# Side-effect-free reproduction of the separate string findings from .86.4.6.
# Structural quote repair: .86.4.7. Escape fidelity: SUPPORTING-SOURCE-READING.2.4.
my @cases = (
 ['physical_subject', 'text = "x' . "\n" . 'y"; regex_subst(text, /x' . "\n" . 'y/, "ok", g); return(text)'],
 ['escaped_return', 'return("x\ny")'],
 ['escaped_assignment', 'text = "x\ny"; return(text)'],
 ['escaped_cat_assignment', 'text = cat("x", "\n", "y"); return(text)'],
 ['escaped_inline_helper', 'return(matches(cat("x", "\n", "y"), /x' . "\n" . 'y/))'],
);
my $json = JSON::PP->new->canonical;
for my $case (@cases) {
 my ($id, $action) = @$case;
 my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
 my $run = eval "sub { no strict; $lowered }";
 my $compile_error = "$@";
 my $direct = $run ? eval { $run->() } : undef;
 my $direct_error = "$@";
 my %context;
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref => \%context) };
 my $build_error = "$@";
 my $input = 'x';
 my $value = $parser ? eval { $parser->(\$input) } : undef;
 my $runtime_error = "$@";
 my @scans;
 if ($id eq 'physical_subject') {
  my $view = LinkedSpec::Validation::_helper_pattern_validation_view($source);
  my $depth = 0;
  for my $line (split /\n/, $view) {
   my $scan = LinkedSpec::Validation::_scan_rule_edges_in_fragment($line, $depth);
   push @scans, { line => $line, incoming_depth => $depth, scan => $scan };
   $depth = $scan->{depth} // 0;
  }
 }
 print $json->encode({ id => $id, action => $action, lowered => $lowered,
  direct => $direct, compile_error => $compile_error, direct_error => $direct_error,
  public_value => $value, build_error => $build_error, runtime_error => $runtime_error,
  last_error => $context{last_error}, validation_scans => \@scans }), "\n";
}

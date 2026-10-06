package LinkedSpec::ActionIR::BoundaryLabels;

use 5.010;
use strict;
use warnings;

# Callers have already recognized the boundary helper's quoted-or-word grammar.
# Consume its atoms before decoding quotes; commas inside an atom are label data.
# This function's match scope also preserves the caller's original helper match.
sub _decode_recognized_labels {
 my ($payload) = @_;
 my @labels;
 while ($payload =~ /\G\s*("(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+)\s*(?:,|\z)/g) {
  my $label = $1;
  if ($label =~ /\A(["'])(.*)\1\z/s) {
   $label = $2;
   $label =~ s/\\(["'\\])/$1/g;
  }
  push @labels, $label if length($label);
 }
 return \@labels
}

1;

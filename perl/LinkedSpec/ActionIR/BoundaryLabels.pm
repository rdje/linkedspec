package LinkedSpec::ActionIR::BoundaryLabels;

use 5.010;
use strict;
use warnings;

# Callers have already recognized the boundary helper's quoted-or-word grammar.
# Consume its atoms before decoding quotes; commas inside an atom are label data.
# This function's match scope also preserves the caller's original helper match.
sub _decode_recognized_label_atoms {
 my ($payload) = @_;
 my @labels;
 while ($payload =~ /\G\s*("(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+)\s*(?:,|\z)/g) {
  my $label = $1;
  if ($label =~ /\A(["'])(.*)\1\z/s) {
   $label = $2;
   $label =~ s/\\(["'\\])/$1/g;
  }
  push @labels, $label;
 }
 return \@labels
}

sub _decode_recognized_labels {
 my ($payload) = @_;
 return [grep { length($_) } @{_decode_recognized_label_atoms($payload)}]
}

# Preserve the existing outer grammar, including its nonempty argument list.
# Unlike runtime labels, these atoms retain empty quoted slots for AST comparison.
sub _recognized_call_label_atoms {
 my ($source) = @_;
 return undef unless defined($source) && !ref($source);
 return undef unless $source =~ /\Acapture_until_boundary\s*\(\s*((?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+)(?:\s*,\s*(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+))*)\s*\)\z/;
 return _decode_recognized_label_atoms($1)
}

1;

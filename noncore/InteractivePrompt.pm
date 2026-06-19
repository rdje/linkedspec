#------------------------------------------------------------------------------
# Package: InteractivePrompt
# Purpose: Package-backed owner for interactive prompt helpers that are being
#          graduated out of legacy `.plg` / `Plugin::*` scaffolding.
#------------------------------------------------------------------------------
package InteractivePrompt;

use 5.010;

#------------------------------------------------------------------------------
# Function: yes_no
# Purpose : Ask one yes/no question, defaulting an empty answer to yes, and run
#           the optional branch callback for the selected answer.
# Args    : ($prompt, $yes_callback, $no_callback)
# Returns : 1 for yes, 0 for no, undef on EOF
#------------------------------------------------------------------------------
sub yes_no {
 shift @_ if @_ && ref($_[0]);
 my ($prompt, $yes_callback, $no_callback) = @_;

 while (1) {
  print defined($prompt) ? "$prompt [y] " : "[y] ";
  my $ui = <STDIN>;
  return unless defined $ui;

  chomp($ui);
  $ui =~ s/\s+//go;
  $ui = lc $ui;

  if (!length($ui) || index('yes', $ui) == 0) {
   _invoke_response_callback($yes_callback, 'yes');
   return 1
  }

  if (index('no', $ui) == 0) {
   _invoke_response_callback($no_callback, 'no');
   return 0
  }
 }
}

sub _invoke_response_callback {
 my ($callback, $answer) = @_;

 return unless $callback;

 if (ref($callback) eq 'CODE') {
  $callback->();
  return
 }

 if (ref($callback) eq 'ARRAY') {
  my ($code, @args) = @$callback;
  die "(InteractivePrompt::yes_no) -E- invalid $answer callback array; first element must be CODE"
   unless ref($code) eq 'CODE';
  $code->(@args);
  return
 }

 die "(InteractivePrompt::yes_no) -E- invalid $answer callback; expected CODE or ARRAY"
}

1;

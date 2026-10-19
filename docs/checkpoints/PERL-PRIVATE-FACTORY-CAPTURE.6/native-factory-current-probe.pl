use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::ActionIR::SourceEmissions ();
use LinkedSpec::ActionIR::SourceOrigins ();

my @actual;
my $native = \&LinkedSpec::ActionIR::SourceEmissions::_capture_emission;
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::SourceEmissions::_capture_emission = sub {
  my ($callback, $raw, $context) = @_;
  if (ref($context) eq 'HASH' && ref($context->{event}) eq 'HASH'
      && ref($context->{rewrite_rules}) eq 'ARRAY') {
   my $event = $context->{event};
   my %rules = map { $_->{id} => $_ } @{$context->{rewrite_rules}};
   my $selected = $rules{$event->{contract_id}}{apply};
   my $producers = $LinkedSpec::ActionIR::SourceEmissions::_producers;
   my $inputs = $LinkedSpec::ActionIR::SourceEmissions::_inputs;
   my $token = LinkedSpec::ActionIR::SourceOrigins::_invocation_token();
   my $registered = ref($producers) eq 'HASH' && ref($callback) eq 'CODE'
    ? $producers->{known}{refaddr($callback)} : undef;
   push @actual, {
    contract => $event->{contract_id}, raw => $raw,
    actual_public_apply => ref($selected) && refaddr($selected) == refaddr($callback) ? 1 : 0,
    registered_actual => ref($registered) && refaddr($registered) == refaddr($callback) ? 1 : 0,
    producer_token => ref($producers) eq 'HASH' && ref($producers->{source_token}) && ref($token)
     && refaddr($producers->{source_token}) == refaddr($token) ? 1 : 0,
    input_token => ref($inputs) eq 'HASH' && ref($inputs->{source_token}) && ref($token)
     && refaddr($inputs->{source_token}) == refaddr($token) ? 1 : 0,
    actual_origin => LinkedSpec::ActionIR::SourceOrigins::_origin_for($event) ? 1 : 0,
   };
  }
  return $native->(@_)
 };
 my $code = 'return(array("λ😀", "λ😀"))';
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $code);
 binmode STDOUT, ':encoding(UTF-8)';
 print JSON::PP->new->canonical->encode({source => $code, lowered => $lowered,
  canonical_calls => \@actual, modules => {map { $_ => $INC{$_} } sort keys %INC},
  scopes_restored => !defined($LinkedSpec::ActionIR::SourceEmissions::_producers)
   && !defined($LinkedSpec::ActionIR::SourceEmissions::_inputs)
   && !defined(LinkedSpec::ActionIR::SourceOrigins::_invocation_token()) ? 1 : 0}), "\n";
}

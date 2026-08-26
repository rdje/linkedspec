#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedASTEnrichmentRuntime
# Purpose: Bind one fresh private staged-AST scheduler to a completed top-level
#          parse without placing registry or resource authority in artifacts.
#------------------------------------------------------------------------------
package LinkedSpec::StagedASTEnrichmentRuntime;

use 5.010;
use strict;
use warnings;

use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::OwnerDispatch ();
use LinkedSpec::StagedASTEnrichment ();

my $OPTION_KEY = 'staged_ast_enrichment';
my @CONFIG_FIELDS = qw(
 snapshot declaring_spec_id caller_capabilities caller_policy_modes
 caller_ceilings required_source_detail required_versions cancellation_token
 cancelled clock deadline remaining_steps required_steps max_depth max_calls
);
my @IDENTITY_FIELDS = qw(cancellation_token cancelled clock);
my %IDENTITY_FIELD = map { ($_ => 1) } @IDENTITY_FIELDS;
my $JSON = JSON::PP->new->canonical(1)->allow_nonref(1);

sub option_key { return $OPTION_KEY }

sub begin_invocation {
 my ($input_ref, $options) = @_;
 return undef unless defined $options;
 _internal_error('invocation options must be a hash reference')
  unless ref($options) eq 'HASH';
 return undef unless exists $options->{$OPTION_KEY};

 my $config = $options->{$OPTION_KEY};
 _internal_error("$OPTION_KEY options must be a hash reference")
  unless ref($config) eq 'HASH';
 _internal_error("$OPTION_KEY option fields drifted")
  unless _has_exact_keys($config, \@CONFIG_FIELDS);
 _internal_error('parser input must be a scalar reference')
  unless ref($input_ref) eq 'SCALAR' || ref($input_ref) eq 'REF';

 my $authority = LinkedSpec::StagedASTEnrichment->new(
  snapshot => $config->{snapshot},
 );
 my %args;
 for my $field (@CONFIG_FIELDS) {
  next if $field eq 'snapshot';
  $args{$field} = $IDENTITY_FIELD{$field}
   ? $config->{$field}
   : _clone_plain($config->{$field});
 }
 return {
  authority => $authority,
  input_address => refaddr($input_ref),
  args => \%args,
 }
}

sub complete_invocation {
 my ($state, $descriptor, $input_ref, $ast) = @_;
 return $ast unless defined $state;
 _internal_error('invocation state must be a staged-AST runtime state')
  unless ref($state) eq 'HASH'
   && blessed($state->{authority})
   && $state->{authority}->isa('LinkedSpec::StagedASTEnrichment')
   && ref($state->{args}) eq 'HASH';
 _internal_error('descriptor must be a hash reference')
  unless ref($descriptor) eq 'HASH';
 _internal_error('parser input changed during staged-AST invocation')
  unless (ref($input_ref) eq 'SCALAR' || ref($input_ref) eq 'REF')
   && refaddr($input_ref) == $state->{input_address};

 my $transaction_active_cb = LinkedSpec::OwnerDispatch::require_pkg_cb(
  __PACKAGE__,
  'LinkedSpec::RecognitionTransactionRuntime',
  'transaction_active',
 );
 my %args = %{$state->{args}};
 $args{transaction_active} = $transaction_active_cb->($descriptor, $input_ref)
  ? 1
  : 0;
 return $state->{authority}->enrich_recursively($ast, %args)
}

sub with_invocation {
 my ($descriptor, $input_ref, $options, $callback) = @_;
 _internal_error('descriptor must be a hash reference')
  unless ref($descriptor) eq 'HASH';
 _internal_error('execution callback must be a code reference')
  unless ref($callback) eq 'CODE';
 my $state = begin_invocation($input_ref, $options);
 my $ast = $callback->();
 return complete_invocation($state, $descriptor, $input_ref, $ast)
}

sub is_error {
 return LinkedSpec::StagedASTEnrichment::is_error(@_)
}

sub _has_exact_keys {
 my ($value, $fields) = @_;
 return 0 unless ref($value) eq 'HASH';
 my %expected = map { ($_ => 1) } @$fields;
 return 0 unless keys(%$value) == keys(%expected);
 return !grep { !$expected{$_} } keys %$value
}

sub _clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode($JSON->encode($value))
}

sub _internal_error {
 my ($message) = @_;
 die "(LinkedSpec::StagedASTEnrichmentRuntime) -E- $message\n"
}

1;

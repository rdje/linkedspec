#------------------------------------------------------------------------------
# Package: LinkedSpec::ProgressiveSpanDispatch
# Purpose: Own the private immutable parser registry and create bounded
#          progressive span-dispatch invocation authorities.
#------------------------------------------------------------------------------
package LinkedSpec::ProgressiveSpanDispatch;

use 5.010;
use strict;
use warnings;
use utf8;

use Hash::Util ();
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);

my %REGISTRY_STATE_BY_ADDRESS;
my %INVOCATION_STATE_BY_ADDRESS;
my %VIEW_STATE_BY_ADDRESS;

my $PARSER_ID_RE = qr/\A[a-z][a-z0-9]*(?:[._:-][a-z0-9]+)*\z/;
my $TOP_RULE_RE = qr/\A[A-Za-z_][A-Za-z0-9_]*\z/;
my $FINGERPRINT_RE = qr/\Asha256:[0-9a-f]{64}\z/;
my @ENTRY_FIELDS = qw(
 parser_id compiled_authority fingerprint allowed_top_rules capabilities ceilings
);
my @SPAN_FIELDS = qw(source_id start end provenance);
my @SOURCE_DETAILS = qw(none identity span text);
my %SOURCE_DETAIL_RANK = map { ($SOURCE_DETAILS[$_] => $_) } 0 .. $#SOURCE_DETAILS;
my @NUMERIC_CEILINGS = qw(max_steps max_result_nodes max_diagnostic_bytes);
my @LIVE_RESULT_FIELD_TOKENS = qw(
 authority handle parser registry transaction cancellation path source_text host
);

sub new {
 my ($class, %args) = @_;
 my $entries = $args{entries};
 _internal_error('entries must be a nonempty array reference')
  unless ref($entries) eq 'ARRAY' && @$entries;

 my %entry_by_id;
 for my $entry (@$entries) {
  my $owned = _validated_entry($entry);
  my $parser_id = $owned->{parser_id};
  _internal_error("duplicate progressive parser identity '$parser_id'")
   if exists $entry_by_id{$parser_id};
  Hash::Util::lock_hashref_recurse($owned);
  $entry_by_id{$parser_id} = $owned;
 }

 my $token = 0;
 my $self = bless \$token, $class;
 $REGISTRY_STATE_BY_ADDRESS{refaddr($self)} = {
  entries => \%entry_by_id,
 };
 return $self
}

sub start_invocation {
 my ($self, %args) = @_;
 my $registry = _registry_state($self);
 my $sources = $args{sources};
 _internal_error('invocation sources must be a nonempty hash reference')
  unless ref($sources) eq 'HASH' && keys %$sources;

 my %owned_sources;
 for my $source_id (keys %$sources) {
  _internal_error('source ids must be nonempty scalars')
   unless defined($source_id) && !ref($source_id) && length($source_id);
  my $text = $sources->{$source_id};
  _internal_error("source '$source_id' must be decoded scalar text")
   unless defined($text) && !ref($text);
  my $owned = "$text";
  utf8::upgrade($owned);
  $owned_sources{$source_id} = $owned;
 }

 my $source_id = _required_scalar($args{source_id}, 'invocation source_id');
 _internal_error("invocation source '$source_id' is unavailable")
  unless exists $owned_sources{$source_id};
 my $cancelled = $args{cancelled};
 my $clock = $args{clock};
 _internal_error('cancelled must be a callback') unless ref($cancelled) eq 'CODE';
 _internal_error('clock must be a callback') unless ref($clock) eq 'CODE';

 my $cancellation_token = $args{cancellation_token};
 _internal_error('cancellation_token must be defined') unless defined $cancellation_token;
 my $deadline_tick = _nonnegative_number($args{deadline_tick}, 'deadline_tick');
 my $remaining_steps = _nonnegative_integer($args{remaining_steps}, 'remaining_steps');
 my $max_depth = _positive_integer($args{max_depth}, 'max_depth');
 my $max_calls = _positive_integer($args{max_calls}, 'max_calls');
 my $total_calls = _nonnegative_integer($args{total_calls}, 'total_calls');
 my $active_chain = _validated_chain($args{active_chain}, \%owned_sources);

 my $token = 0;
 my $invocation = bless \$token, 'LinkedSpec::ProgressiveSpanDispatch::Invocation';
 $INVOCATION_STATE_BY_ADDRESS{refaddr($invocation)} = {
  registry_address => refaddr($self),
  registry => $registry,
  sources => \%owned_sources,
  source_id => $source_id,
  cancellation_token => $cancellation_token,
  cancelled => $cancelled,
  clock => $clock,
  deadline_tick => $deadline_tick,
  remaining_steps => $remaining_steps,
  max_depth => $max_depth,
  max_calls => $max_calls,
  total_calls => $total_calls,
  active_chain => $active_chain,
  active => 1,
 };
 return $invocation
}

sub register {
 my ($self, %args) = @_;
 _registry_state($self);
 _throw(
  code => 'progressive_registry_mutation_forbidden',
  origin => 'registry:register',
  parser_id => _diagnostic_scalar($args{parser_id}),
 )
}

sub load {
 my ($self, %args) = @_;
 _registry_state($self);
 _throw(
  code => 'progressive_implicit_load_forbidden',
  origin => 'registry:load',
  parser_id => _diagnostic_scalar($args{parser_id}),
 )
}

sub is_error {
 my ($value) = @_;
 return blessed($value) && $value->isa('LinkedSpec::ProgressiveSpanDispatch::Error') ? 1 : 0
}

sub _validated_entry {
 my ($entry) = @_;
 _internal_error('registry entry must be a hash reference') unless ref($entry) eq 'HASH';
 _internal_error('registry entry fields drifted') unless _has_exact_keys($entry, \@ENTRY_FIELDS);

 my $parser_id = _required_scalar($entry->{parser_id}, 'registry parser_id');
 _internal_error("invalid registry parser identity '$parser_id'") unless $parser_id =~ $PARSER_ID_RE;
 my $compiled_authority = $entry->{compiled_authority};
 _internal_error("compiled authority for '$parser_id' must be a callback")
  unless ref($compiled_authority) eq 'CODE';
 my $fingerprint = _required_scalar($entry->{fingerprint}, 'registry fingerprint');
 _internal_error("invalid registry fingerprint for '$parser_id'")
  unless $fingerprint =~ $FINGERPRINT_RE;
 my $allowed_top_rules = _ordered_unique_strings(
  $entry->{allowed_top_rules},
  "allowed top rules for '$parser_id'",
  $TOP_RULE_RE,
 );
 my $capabilities = _ordered_unique_strings(
  $entry->{capabilities},
  "capabilities for '$parser_id'",
 );
 my $ceilings = _validated_ceilings($entry->{ceilings}, "ceilings for '$parser_id'");

 return {
  parser_id => $parser_id,
  compiled_authority => $compiled_authority,
  fingerprint => $fingerprint,
  allowed_top_rules => $allowed_top_rules,
  capabilities => $capabilities,
  ceilings => $ceilings,
 }
}

sub _validated_ceilings {
 my ($ceilings, $context) = @_;
 _internal_error("$context must be a hash reference") unless ref($ceilings) eq 'HASH';
 _internal_error("$context fields drifted")
  unless _has_exact_keys($ceilings, [qw(
   source_detail policy_modes max_steps max_result_nodes max_diagnostic_bytes
  )]);
 my $source_detail = _required_scalar($ceilings->{source_detail}, "$context source_detail");
 _internal_error("$context has invalid source_detail '$source_detail'")
  unless exists $SOURCE_DETAIL_RANK{$source_detail};
 my $policy_modes = _ordered_unique_strings($ceilings->{policy_modes}, "$context policy_modes");
 my %out = (
  source_detail => $source_detail,
  policy_modes => $policy_modes,
 );
 for my $name (@NUMERIC_CEILINGS) {
  $out{$name} = _positive_integer($ceilings->{$name}, "$context $name");
 }
 return \%out
}

sub _ordered_unique_strings {
 my ($values, $context, $pattern) = @_;
 _internal_error("$context must be a nonempty array reference")
  unless ref($values) eq 'ARRAY' && @$values;
 my %seen;
 my @out;
 for my $value (@$values) {
  _internal_error("$context must contain nonempty scalars")
   unless defined($value) && !ref($value) && length($value);
  _internal_error("$context contains invalid value '$value'")
   if defined($pattern) && $value !~ $pattern;
  _internal_error("$context contains duplicate '$value'") if $seen{$value}++;
  push @out, "$value";
 }
 return \@out
}

sub _validated_chain {
 my ($chain, $sources) = @_;
 _internal_error('active_chain must be an array reference') unless ref($chain) eq 'ARRAY';
 my @out;
 for my $row (@$chain) {
  _internal_error('active_chain rows must have five fields')
   unless ref($row) eq 'ARRAY' && @$row == 5;
  my ($parser_id, $top_rule, $source_id, $start, $end) = @$row;
  _internal_error('active_chain parser identity is invalid')
   unless defined($parser_id) && !ref($parser_id) && $parser_id =~ $PARSER_ID_RE;
  _internal_error('active_chain top rule is invalid')
   unless defined($top_rule) && !ref($top_rule) && $top_rule =~ $TOP_RULE_RE;
  _internal_error("active_chain source '$source_id' is unavailable")
   unless defined($source_id) && !ref($source_id) && exists $sources->{$source_id};
  $start = _nonnegative_integer($start, 'active_chain start');
  $end = _nonnegative_integer($end, 'active_chain end');
  _internal_error('active_chain span is invalid')
   if $start > $end || $end > length($sources->{$source_id});
  push @out, [$parser_id, $top_rule, $source_id, $start, $end];
 }
 return \@out
}

sub _registry_state {
 my ($registry) = @_;
 _internal_error('invalid progressive registry authority')
  unless blessed($registry) && $registry->isa(__PACKAGE__);
 my $state = $REGISTRY_STATE_BY_ADDRESS{refaddr($registry)};
 _internal_error('progressive registry authority is unavailable') unless ref($state) eq 'HASH';
 return $state
}

sub _invocation_state {
 my ($invocation) = @_;
 _internal_error('invalid progressive invocation authority')
  unless blessed($invocation)
   && $invocation->isa('LinkedSpec::ProgressiveSpanDispatch::Invocation');
 my $state = $INVOCATION_STATE_BY_ADDRESS{refaddr($invocation)};
 _internal_error('progressive invocation authority is unavailable')
  unless ref($state) eq 'HASH' && $state->{active};
 return $state
}

sub _view_state {
 my ($view) = @_;
 _internal_error('invalid progressive source view')
  unless blessed($view) && $view->isa('LinkedSpec::ProgressiveSpanDispatch::SourceView');
 my $state = $VIEW_STATE_BY_ADDRESS{refaddr($view)};
 _internal_error('progressive source view is outside its child execution')
  unless ref($state) eq 'HASH' && $state->{active};
 return $state
}

sub _new_view {
 my (%args) = @_;
 my $token = 0;
 my $view = bless \$token, 'LinkedSpec::ProgressiveSpanDispatch::SourceView';
 $VIEW_STATE_BY_ADDRESS{refaddr($view)} = {
  active => 1,
  source_id => $args{source_id},
  text => $args{text},
  start => $args{start},
  end => $args{end},
  provenance => $args{provenance},
  origin => $args{origin},
 };
 return $view
}

sub _invalidate_view {
 my ($view) = @_;
 my $state = $VIEW_STATE_BY_ADDRESS{refaddr($view)};
 $state->{active} = 0 if ref($state) eq 'HASH';
 return
}

sub _has_exact_keys {
 my ($value, $fields) = @_;
 return 0 unless ref($value) eq 'HASH';
 my %expected = map { ($_ => 1) } @$fields;
 return 0 unless keys(%$value) == keys(%expected);
 return !grep { !$expected{$_} } keys %$value
}

sub _required_scalar {
 my ($value, $context) = @_;
 _internal_error("$context must be a nonempty scalar")
  unless defined($value) && !ref($value) && length($value);
 return "$value"
}

sub _nonnegative_integer {
 my ($value, $context) = @_;
 _internal_error("$context must be a nonnegative integer")
  unless _is_nonnegative_integer_scalar($value);
 return 0 + $value
}

sub _positive_integer {
 my ($value, $context) = @_;
 _internal_error("$context must be a positive integer")
  unless _is_nonnegative_integer_scalar($value) && $value > 0;
 return 0 + $value
}

sub _nonnegative_number {
 my ($value, $context) = @_;
 _internal_error("$context must be a nonnegative number")
  unless _is_nonnegative_number_scalar($value);
 return 0 + $value
}

sub _is_nonnegative_integer_scalar {
 my ($value) = @_;
 return 0 unless defined($value) && !ref($value);
 my $encoded = eval { JSON::PP->new->allow_nonref(1)->encode($value) };
 return defined($encoded) && $encoded =~ /\A(?:0|[1-9][0-9]*)\z/ ? 1 : 0
}

sub _is_nonnegative_number_scalar {
 my ($value) = @_;
 return 0 unless defined($value) && !ref($value);
 my $encoded = eval { JSON::PP->new->allow_nonref(1)->encode($value) };
 return 0 unless defined($encoded)
  && $encoded =~ /\A(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?\z/;
 return $value >= 0 ? 1 : 0
}

sub _diagnostic_scalar {
 my ($value) = @_;
 return '<missing>' unless defined $value;
 return '<reference>' if ref $value;
 return "$value"
}

sub _same_token {
 my ($left, $right) = @_;
 return 0 unless defined($left) && defined($right);
 if (ref($left) || ref($right)) {
  return 0 unless ref($left) && ref($right);
  return refaddr($left) == refaddr($right) ? 1 : 0
 }
 return "$left" eq "$right" ? 1 : 0
}

sub _throw {
 my (%fields) = @_;
 die bless \%fields, 'LinkedSpec::ProgressiveSpanDispatch::Error'
}

sub _internal_error {
 my ($message) = @_;
 die "(LinkedSpec::ProgressiveSpanDispatch) -E- $message\n"
}

sub DESTROY {
 my ($self) = @_;
 delete $REGISTRY_STATE_BY_ADDRESS{refaddr($self)} if ref $self;
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::ProgressiveSpanDispatch::Invocation
# Purpose: Own one shared cancellation/budget/chain authority and execute
#          isolated child callbacks over bounded source views.
#------------------------------------------------------------------------------
package LinkedSpec::ProgressiveSpanDispatch::Invocation;

use 5.010;
use strict;
use warnings;

sub dispatch {
 my ($self, %args) = @_;
 my $state = LinkedSpec::ProgressiveSpanDispatch::_invocation_state($self);
 my $origin = defined($args{origin}) && !ref($args{origin}) && length($args{origin})
  ? "$args{origin}"
  : 'dispatch_span';

 my $parser_id = $args{parser_id};
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_parser_identity_literal_required',
  origin => $origin,
  operand => LinkedSpec::ProgressiveSpanDispatch::_diagnostic_scalar($parser_id),
 ) unless defined($parser_id) && !ref($parser_id) && length($parser_id);
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_parser_identity_invalid',
  origin => $origin,
  parser_id => "$parser_id",
 ) unless $parser_id =~ $PARSER_ID_RE;

 my $top_rule = $args{top_rule};
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_top_rule_literal_required',
  origin => $origin,
  operand => LinkedSpec::ProgressiveSpanDispatch::_diagnostic_scalar($top_rule),
 ) unless defined($top_rule) && !ref($top_rule) && length($top_rule);
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_top_rule_invalid',
  origin => $origin,
  top_rule => "$top_rule",
 ) unless $top_rule =~ $TOP_RULE_RE;

 my $span = $args{span};
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_span_binding_required',
  origin => $origin,
  operand => LinkedSpec::ProgressiveSpanDispatch::_diagnostic_scalar($span),
 ) unless ref($span) eq 'HASH';
 _validate_span_shape($span, $origin);
 my ($source_id, $start, $end, $provenance) = @{$span}{@SPAN_FIELDS};
 if ($source_id ne $state->{source_id}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_span_source_mismatch',
   origin => $origin,
   expected_source_id => $state->{source_id},
   actual_source_id => $source_id,
  );
 }
 my $source_text = $state->{sources}{$source_id};
 my $source_length = defined($source_text) ? length($source_text) : 0;
 if (!defined($source_text) || $start < 0 || $end > $source_length) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_span_out_of_bounds',
   origin => $origin,
   source_id => $source_id,
   start => $start,
   end => $end,
   source_length => $source_length,
  );
 }
 if ($start > $end) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_span_reversed',
   origin => $origin,
   source_id => $source_id,
   start => $start,
   end => $end,
  );
 }

 if ($args{transaction_active}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_transaction_forbidden',
   origin => $origin,
   effect => 'parser_registry_or_staged_dispatch',
  );
 }

 my $entry = $state->{registry}{entries}{$parser_id};
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_registry_missing',
  origin => $origin,
  parser_id => $parser_id,
 ) unless ref($entry) eq 'HASH';
 my %allowed_top_rule = map { ($_ => 1) } @{$entry->{allowed_top_rules}};
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_top_rule_forbidden',
  origin => $origin,
  parser_id => $parser_id,
  top_rule => $top_rule,
 ) unless $allowed_top_rule{$top_rule};

 my $effective = _effective_authority($entry, \%args, $origin);
 _check_chain($state, $parser_id, $top_rule, $source_id, $start, $end, $origin);
 my $cost = _dispatch_cost($args{cost});
 _check_safe_point($state, $args{child_token}, $parser_id, $cost, $origin);

 ++$state->{total_calls};
 $state->{remaining_steps} -= $cost;
 my $view = LinkedSpec::ProgressiveSpanDispatch::_new_view(
  source_id => $source_id,
  text => substr($source_text, $start, $end - $start),
  start => $start,
  end => $end,
  provenance => $provenance,
  origin => $origin,
 );
 my $chain_row = [$parser_id, $top_rule, $source_id, $start, $end];
 push @{$state->{active_chain}}, $chain_row;
 my $request = {
  parser_id => $parser_id,
  top_rule => $top_rule,
  fingerprint => $entry->{fingerprint},
  source_view => $view,
  effective => _clone_plain($effective),
  cancellation_token => $state->{cancellation_token},
  deadline_tick => $state->{deadline_tick},
  remaining_steps => $state->{remaining_steps},
 };

 my ($child_result, $child_ok, $child_error);
 $child_ok = eval {
  $child_result = $entry->{compiled_authority}->($request, $self);
  1
 };
 $child_error = $@;
 pop @{$state->{active_chain}};
 LinkedSpec::ProgressiveSpanDispatch::_invalidate_view($view);

 unless ($child_ok && defined($child_result)) {
  my $diagnostic = $child_ok
   ? '<undefined child result>'
   : LinkedSpec::ProgressiveSpanDispatch::is_error($child_error)
    ? $child_error->{code}
    : "$child_error";
  $diagnostic =~ s/\s+\z//;
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_child_failed',
   origin => $origin,
   parser_id => $parser_id,
   top_rule => $top_rule,
   source_id => $source_id,
   span => "$start:$end",
   child_diagnostic => $diagnostic,
  );
 }

 _check_cancel_deadline($state, $parser_id, $origin);
 return _detach_result($child_result, $parser_id, $origin, '<result>', {})
}

sub remaining_steps {
 my ($self) = @_;
 return LinkedSpec::ProgressiveSpanDispatch::_invocation_state($self)->{remaining_steps}
}

sub total_calls {
 my ($self) = @_;
 return LinkedSpec::ProgressiveSpanDispatch::_invocation_state($self)->{total_calls}
}

sub _validate_span_shape {
 my ($span, $origin) = @_;
 my $shape_ok = LinkedSpec::ProgressiveSpanDispatch::_has_exact_keys($span, \@SPAN_FIELDS)
  && defined($span->{source_id}) && !ref($span->{source_id}) && length($span->{source_id})
  && defined($span->{provenance}) && !ref($span->{provenance}) && length($span->{provenance})
  && LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_integer_scalar($span->{start})
  && LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_integer_scalar($span->{end});
 return if $shape_ok;
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_span_shape_invalid',
  origin => $origin,
  fields => join(',', sort keys %$span),
 )
}

sub _effective_authority {
 my ($entry, $args, $origin) = @_;
 my $caller_capabilities = _string_set($args->{caller_capabilities}, 'caller_capabilities');
 my $required_capabilities = _string_set($args->{required_capabilities}, 'required_capabilities', 1);
 my %entry_capability = map { ($_ => 1) } @{$entry->{capabilities}};
 my @capabilities = sort grep { $entry_capability{$_} } keys %$caller_capabilities;
 my %effective_capability = map { ($_ => 1) } @capabilities;
 for my $required (sort keys %$required_capabilities) {
  next if $effective_capability{$required};
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_capability_denied',
   origin => $origin,
   parser_id => $entry->{parser_id},
   capability => $required,
  );
 }

 my $caller = $args->{caller_ceilings};
 my $caller_ceilings = LinkedSpec::ProgressiveSpanDispatch::_validated_ceilings(
  $caller,
  'caller ceilings',
 );
 my %entry_policy = map { ($_ => 1) } @{$entry->{ceilings}{policy_modes}};
 my @policy_modes = sort grep { $entry_policy{$_} } @{$caller_ceilings->{policy_modes}};
 unless (@policy_modes) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_policy_denied',
   origin => $origin,
   parser_id => $entry->{parser_id},
   policy => join(',', @{$caller_ceilings->{policy_modes}}),
  );
 }

 my $source_rank = $SOURCE_DETAIL_RANK{$caller_ceilings->{source_detail}}
  < $SOURCE_DETAIL_RANK{$entry->{ceilings}{source_detail}}
  ? $SOURCE_DETAIL_RANK{$caller_ceilings->{source_detail}}
  : $SOURCE_DETAIL_RANK{$entry->{ceilings}{source_detail}};
 my $source_detail = $SOURCE_DETAILS[$source_rank];
 my $required_detail = defined($args->{required_source_detail})
  && !ref($args->{required_source_detail})
  && exists($SOURCE_DETAIL_RANK{$args->{required_source_detail}})
  ? $args->{required_source_detail}
  : LinkedSpec::ProgressiveSpanDispatch::_internal_error('required_source_detail is invalid');
 if ($source_rank < $SOURCE_DETAIL_RANK{$required_detail}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_source_detail_denied',
   origin => $origin,
   required => $required_detail,
   effective => $source_detail,
  );
 }

 my %effective = (
  capabilities => \@capabilities,
  source_detail => $source_detail,
  policy_modes => \@policy_modes,
 );
 for my $name (@NUMERIC_CEILINGS) {
  $effective{$name} = $caller_ceilings->{$name} < $entry->{ceilings}{$name}
   ? $caller_ceilings->{$name}
   : $entry->{ceilings}{$name};
 }
 return \%effective
}

sub _string_set {
 my ($values, $context, $allow_empty) = @_;
 LinkedSpec::ProgressiveSpanDispatch::_internal_error("$context must be an array reference")
  unless ref($values) eq 'ARRAY' && ($allow_empty || @$values);
 my %seen;
 for my $value (@$values) {
  LinkedSpec::ProgressiveSpanDispatch::_internal_error("$context contains an invalid value")
   unless defined($value) && !ref($value) && length($value);
  LinkedSpec::ProgressiveSpanDispatch::_internal_error("$context contains duplicate '$value'")
   if $seen{$value}++;
 }
 return \%seen
}

sub _dispatch_cost {
 my ($cost) = @_;
 LinkedSpec::ProgressiveSpanDispatch::_internal_error('dispatch cost must be a nonnegative integer')
  unless LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_integer_scalar($cost);
 return 0 + $cost
}

sub _check_safe_point {
 my ($state, $child_token, $parser_id, $cost, $origin) = @_;
 unless (LinkedSpec::ProgressiveSpanDispatch::_same_token(
  $state->{cancellation_token},
  $child_token,
 )) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_cancellation_authority_mismatch',
   origin => $origin,
   parser_id => $parser_id,
  );
 }
 _check_cancel_deadline($state, $parser_id, $origin);
 if ($state->{remaining_steps} <= 0 || $cost > $state->{remaining_steps}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_budget_exhausted',
   origin => $origin,
   parser_id => $parser_id,
   remaining => $state->{remaining_steps},
  );
 }
 return
}

sub _check_cancel_deadline {
 my ($state, $parser_id, $origin) = @_;
 my $cancelled = $state->{cancelled}->() ? 1 : 0;
 if ($cancelled) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_cancelled',
   origin => $origin,
   parser_id => $parser_id,
  );
 }
 my $now = $state->{clock}->();
 LinkedSpec::ProgressiveSpanDispatch::_internal_error('clock callback returned an invalid tick')
  unless LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_number_scalar($now);
 if ($now >= $state->{deadline_tick}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_deadline_exceeded',
   origin => $origin,
   parser_id => $parser_id,
   deadline => $state->{deadline_tick},
  );
 }
 return
}

sub _check_chain {
 my ($state, $parser_id, $top_rule, $source_id, $start, $end, $origin) = @_;
 if (@{$state->{active_chain}} >= $state->{max_depth}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_depth_exceeded',
   origin => $origin,
   depth => scalar @{$state->{active_chain}},
   maximum => $state->{max_depth},
  );
 }
 if ($state->{total_calls} >= $state->{max_calls}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_call_limit_exceeded',
   origin => $origin,
   calls => $state->{total_calls},
   maximum => $state->{max_calls},
  );
 }
 for my $active (@{$state->{active_chain}}) {
  next unless $active->[0] eq $parser_id
   && $active->[1] eq $top_rule
   && $active->[2] eq $source_id;
  my ($active_start, $active_end) = @$active[3, 4];
  my $contained = $active_start <= $start && $start <= $end && $end <= $active_end;
  my $smaller = $end - $start < $active_end - $active_start;
  next if $contained && $smaller;
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_cycle_non_decreasing',
   origin => $origin,
   parser_id => $parser_id,
   top_rule => $top_rule,
   source_id => $source_id,
   span => "$start:$end",
   active_span => "$active_start:$active_end",
  );
 }
 return
}

sub _detach_result {
 my ($value, $parser_id, $origin, $path, $active) = @_;
 return $value unless ref $value;
 if (JSON::PP::is_bool($value)) {
  return $value ? JSON::PP::true : JSON::PP::false
 }
 my $type = ref($value);
 if ($type eq 'ARRAY' || $type eq 'HASH') {
  my $address = Scalar::Util::refaddr($value);
  if ($active->{$address}) {
   LinkedSpec::ProgressiveSpanDispatch::_throw(
    code => 'progressive_result_not_detached',
    origin => $origin,
    parser_id => $parser_id,
    field => $path,
   );
  }
  local $active->{$address} = 1;
  if ($type eq 'ARRAY') {
   return [map {
    _detach_result($value->[$_], $parser_id, $origin, "$path/$_", $active)
   } 0 .. $#$value]
  }
  my %copy;
  for my $key (sort keys %$value) {
   my $lower = lc $key;
   if (grep { index($lower, $_) >= 0 } @LIVE_RESULT_FIELD_TOKENS) {
    LinkedSpec::ProgressiveSpanDispatch::_throw(
     code => 'progressive_result_not_detached',
     origin => $origin,
     parser_id => $parser_id,
     field => "$path/$key",
    );
   }
   $copy{$key} = _detach_result($value->{$key}, $parser_id, $origin, "$path/$key", $active);
  }
  return \%copy
 }
 LinkedSpec::ProgressiveSpanDispatch::_throw(
  code => 'progressive_result_not_detached',
  origin => $origin,
  parser_id => $parser_id,
  field => $path,
 )
}

sub _clone_plain {
 my ($value) = @_;
 return $value unless ref $value;
 return $value ? JSON::PP::true : JSON::PP::false if JSON::PP::is_bool($value);
 return [map { _clone_plain($_) } @$value] if ref($value) eq 'ARRAY';
 if (ref($value) eq 'HASH') {
  return {map { ($_ => _clone_plain($value->{$_})) } keys %$value}
 }
 LinkedSpec::ProgressiveSpanDispatch::_internal_error('plain clone encountered a live reference')
}

sub DESTROY {
 my ($self) = @_;
 if (ref $self) {
  my $state = delete $INVOCATION_STATE_BY_ADDRESS{Scalar::Util::refaddr($self)};
  $state->{active} = 0 if ref($state) eq 'HASH';
 }
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::ProgressiveSpanDispatch::SourceView
# Purpose: Expose only bounded decoded text plus local-to-global rebasing while
#          one child callback is active.
#------------------------------------------------------------------------------
package LinkedSpec::ProgressiveSpanDispatch::SourceView;

use 5.010;
use strict;
use warnings;

sub text {
 my ($self) = @_;
 return '' . LinkedSpec::ProgressiveSpanDispatch::_view_state($self)->{text}
}

sub source_id {
 my ($self) = @_;
 return LinkedSpec::ProgressiveSpanDispatch::_view_state($self)->{source_id}
}

sub local_to_global {
 my ($self, $offset) = @_;
 my $state = LinkedSpec::ProgressiveSpanDispatch::_view_state($self);
 _local_offset($state, $offset, 'local_to_global');
 return $state->{start} + $offset
}

sub rebase_position {
 my ($self, $offset) = @_;
 my $state = LinkedSpec::ProgressiveSpanDispatch::_view_state($self);
 _local_offset($state, $offset, 'rebase_position');
 return {
  source_id => $state->{source_id},
  offset => $state->{start} + $offset,
 }
}

sub rebase_span {
 my ($self, $span) = @_;
 my $state = LinkedSpec::ProgressiveSpanDispatch::_view_state($self);
 LinkedSpec::ProgressiveSpanDispatch::Invocation::_validate_span_shape($span, $state->{origin});
 if ($span->{source_id} ne $state->{source_id}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_span_source_mismatch',
   origin => $state->{origin},
   expected_source_id => $state->{source_id},
   actual_source_id => $span->{source_id},
  );
 }
 _local_offset($state, $span->{start}, 'rebase_span start');
 _local_offset($state, $span->{end}, 'rebase_span end');
 if ($span->{start} > $span->{end}) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_span_reversed',
   origin => $state->{origin},
   source_id => $state->{source_id},
   start => $span->{start},
   end => $span->{end},
  );
 }
 return {
  source_id => $state->{source_id},
  start => $state->{start} + $span->{start},
  end => $state->{start} + $span->{end},
  provenance => $span->{provenance},
 }
}

sub rebase_diagnostic {
 my ($self, $diagnostic) = @_;
 my $state = LinkedSpec::ProgressiveSpanDispatch::_view_state($self);
 LinkedSpec::ProgressiveSpanDispatch::_internal_error('diagnostic must be a hash reference')
  unless ref($diagnostic) eq 'HASH';
 my %copy;
 for my $key (keys %$diagnostic) {
  my $value = $diagnostic->{$key};
  if ($key eq 'span' && ref($value) eq 'HASH') {
   $copy{$key} = $self->rebase_span($value);
  } elsif ($key =~ /(?:\A|_)(?:offset|start|end)\z/
   && LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_integer_scalar($value)) {
   _local_offset($state, $value, "diagnostic $key");
   $copy{$key} = $state->{start} + $value;
  } elsif (ref $value) {
   $copy{$key} = LinkedSpec::ProgressiveSpanDispatch::Invocation::_clone_plain($value);
  } else {
   $copy{$key} = $value;
  }
 }
 $copy{source_id} = $state->{source_id};
 return \%copy
}

sub _local_offset {
 my ($state, $offset, $context) = @_;
 my $view_length = length($state->{text});
 if (!defined($offset)
  || !LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_integer_scalar($offset)
  || $offset > $view_length) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_span_out_of_bounds',
   origin => $state->{origin},
   source_id => $state->{source_id},
   start => LinkedSpec::ProgressiveSpanDispatch::_diagnostic_scalar($offset),
   end => LinkedSpec::ProgressiveSpanDispatch::_diagnostic_scalar($offset),
   source_length => $view_length,
  );
 }
 return
}

sub DESTROY {
 my ($self) = @_;
 delete $VIEW_STATE_BY_ADDRESS{Scalar::Util::refaddr($self)} if ref $self;
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::ProgressiveSpanDispatch::Error
# Purpose: Carry one portable progressive diagnostic and required context.
#------------------------------------------------------------------------------
package LinkedSpec::ProgressiveSpanDispatch::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub as_string {
 my ($self) = @_;
 my $code = defined($self->{code}) ? $self->{code} : 'progressive_internal_error';
 my @context = map {
  $_ . '=' . (defined($self->{$_}) && !ref($self->{$_}) ? $self->{$_} : '<value>')
 } sort grep { $_ ne 'code' } keys %$self;
 return 'LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:' . $code
  . (@context ? ':' . join(',', @context) : '')
}

1;

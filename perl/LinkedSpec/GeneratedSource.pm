#------------------------------------------------------------------------------
# Package: LinkedSpec::GeneratedSource
# Purpose: Shared generated-source v2 plan validation, structured errors, and
#          semantic trace-role events for independently loaded Perl source.
#------------------------------------------------------------------------------
package LinkedSpec::GeneratedSource;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

our $CONTRACT_ID = 'linkedspec-generated-source-v2';
our $FORMAT_VERSION = 2;

my @FAMILY_ORDER = qw(
 default
 or_acode
 or_bcode
 rep_acode
 rep_bcode
 and_single_acode
 and_acode_seq
 and_bcode
 rep_and_acode
 rep_and_bcode
);
my %FAMILY_CURSOR_POLICY = (
 default => 'seek',
 or_acode => 'seek',
 or_bcode => 'seek',
 rep_acode => 'seek',
 rep_bcode => 'seek',
 and_single_acode => 'consume',
 and_acode_seq => 'consume',
 and_bcode => 'consume',
 rep_and_acode => 'consume',
 rep_and_bcode => 'consume',
);

sub family_cursor_policy {
 my ($family) = @_;
 return undef unless defined $family;
 return $FAMILY_CURSOR_POLICY{$family}
}

sub family_cursor_policy_rows {
 return [map {
  {
   family => $_,
   cursor_policy => $FAMILY_CURSOR_POLICY{$_},
  }
 } @FAMILY_ORDER]
}

sub trace_mark_event {
 my (%args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return undef unless exists $INC{'LinkedSpec/Trace.pm'};
  return undef unless LinkedSpec::Trace::should_dump(300);
  return LinkedSpec::Trace::trace_mark_event(%args, caller_depth => 4);
 })
}

sub emit_source {
 my ($spec_content_ref, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';
 my %emit_option = %$option;
 my $source_identity = delete $emit_option{source_identity};
 $source_identity = $emit_option{generated_source_identity}
  unless defined($source_identity) && length($source_identity);
 $source_identity = '<inline>' unless defined($source_identity) && length($source_identity);

 my $source = '';
 my $runtime_ctx = {};
 $emit_option{generate_only} = 1;
 $emit_option{dump_parser_source} = 1;
 $emit_option{parser_source_ref} = \$source;
 $emit_option{runtime_ctx_ref} = $runtime_ctx;
 $emit_option{generated_source_identity} = $source_identity;

 my $result = LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::Runtime',
  'run_get',
  $spec_content_ref,
  \%emit_option,
 );
 return $source if !defined($result) && length($source);

 my $last_error = (ref($runtime_ctx->{last_error}) eq 'HASH')
  ? $runtime_ctx->{last_error}
  : {};
 die new_error(
  stage => 'prepare_options',
  code => 'parse_mode_override_removed',
  summary => 'Parser cursor override has been removed',
  source_identity => $source_identity,
  option_name => 'parse_mode',
  detail => 'parse_mode has been removed; cursor policy is derived from each rule (OR/default=seek, AND=consume)',
 ) if ($last_error->{code} // '') eq 'parse_mode_override_removed';
 die new_error(
  stage => 'emit_source',
  code => 'generated_source_emit_failed',
  summary => 'Generated parser source emission failed',
  source_identity => $source_identity,
  defined($last_error->{rule_label}) ? (rule_label => $last_error->{rule_label}) : (),
  detail => defined($last_error->{detail}) && length($last_error->{detail})
   ? $last_error->{detail}
   : 'LinkedSpec compilation did not produce generated source',
 )
}

sub clone_plan {
 my ($plan) = @_;
 return [] unless ref($plan) eq 'ARRAY';
 return [map {
  ref($_) eq 'HASH'
   ? { label => $_->{label}, family => $_->{family} }
   : $_
 } @$plan]
}

sub new_error {
 my (%args) = @_;
 my $error = {
  type => 'generated_source_error',
  stage => defined($args{stage}) ? $args{stage} : '',
  code => defined($args{code}) ? $args{code} : '',
  summary => defined($args{summary}) ? $args{summary} : '',
  source_identity => defined($args{source_identity}) ? $args{source_identity} : '',
 };
 $error->{rule_label} = $args{rule_label} if defined $args{rule_label};
 $error->{handler_family} = $args{handler_family} if defined $args{handler_family};
 $error->{option_name} = $args{option_name} if defined $args{option_name};
 $error->{expected_contract} = $args{expected_contract} if defined $args{expected_contract};
 $error->{actual_contract} = $args{actual_contract} if defined $args{actual_contract};
 $error->{detail} = $args{detail} if defined $args{detail};
 return $error
}

sub _reject_plan {
 my (%args) = @_;
 die new_error(
  stage => 'validate_generated_plan',
  source_identity => $args{source_identity},
  code => $args{code},
  summary => $args{summary},
  defined($args{rule_label}) ? (rule_label => $args{rule_label}) : (),
  defined($args{handler_family}) ? (handler_family => $args{handler_family}) : (),
  defined($args{expected_contract}) ? (expected_contract => $args{expected_contract}) : (),
  defined($args{actual_contract}) ? (actual_contract => $args{actual_contract}) : (),
  defined($args{detail}) ? (detail => $args{detail}) : (),
 )
}

sub _caller_generated_contract {
 my $caller_package = caller(1);
 return undef unless defined($caller_package) && length($caller_package);
 no strict 'refs';
 my $slot = $caller_package . '::LINKEDSPEC_GENERATED_SOURCE_CONTRACT';
 return undef unless defined ${$slot};
 return ${$slot}
}

sub validate_plan {
 my (%args) = @_;
 my $expected = $args{expected};
 my $actual = $args{actual};
 my $source_identity = defined($args{source_identity}) ? $args{source_identity} : '';
 my $expected_contract = defined($args{expected_contract})
  ? $args{expected_contract}
  : $CONTRACT_ID;
 my $actual_contract = defined($args{actual_contract})
  ? $args{actual_contract}
  : _caller_generated_contract();
 $actual_contract = $expected_contract unless defined($actual_contract) && length($actual_contract);

 _reject_plan(
  source_identity => $source_identity,
  code => 'generated_source_contract_version_mismatch',
  summary => 'Generated source contract does not match the active validator',
  expected_contract => $expected_contract,
  actual_contract => $actual_contract,
  detail => 'regenerate the generated artifact from its .spec source',
 ) unless defined($expected_contract)
  && defined($actual_contract)
  && $expected_contract eq $CONTRACT_ID
  && $actual_contract eq $expected_contract;

 _reject_plan(
  source_identity => $source_identity,
  code => 'generated_plan_row_count_mismatch',
  summary => 'Generated rule plan row count does not match compiled rules',
  detail => 'expected and actual generated plans must both be arrays',
 ) unless ref($expected) eq 'ARRAY' && ref($actual) eq 'ARRAY';

 _reject_plan(
  source_identity => $source_identity,
  code => 'generated_plan_row_count_mismatch',
  summary => 'Generated rule plan row count does not match compiled rules',
  detail => 'expected=' . scalar(@$expected) . ' actual=' . scalar(@$actual),
 ) unless @$expected == @$actual;

 for my $index (0 .. $#$expected) {
  my $expected_row = $expected->[$index];
  my $actual_row = $actual->[$index];
  _reject_plan(
   source_identity => $source_identity,
   code => 'generated_plan_family_mismatch',
   summary => 'Generated rule plan row is malformed',
   detail => "row=$index expected/actual rows must be objects",
  ) unless ref($expected_row) eq 'HASH' && ref($actual_row) eq 'HASH';

  my $expected_label = $expected_row->{label};
  my $actual_label = $actual_row->{label};
  _reject_plan(
   source_identity => $source_identity,
   code => 'generated_plan_label_mismatch',
   summary => 'Generated rule plan label does not match compiled rule',
   rule_label => defined($expected_label) ? $expected_label : '',
   detail => 'row=' . $index . ' expected=' . (defined($expected_label) ? $expected_label : '<undef>')
    . ' actual=' . (defined($actual_label) ? $actual_label : '<undef>'),
  ) unless defined($expected_label) && defined($actual_label) && $expected_label eq $actual_label;

  my $expected_family = $expected_row->{family};
  my $actual_family = $actual_row->{family};
  _reject_plan(
   source_identity => $source_identity,
   code => 'generated_plan_unknown_family',
   summary => 'Generated rule plan contains an unknown family',
   rule_label => $expected_label,
   handler_family => defined($actual_family) ? $actual_family : '',
   detail => 'row=' . $index,
  ) unless defined($actual_family) && defined family_cursor_policy($actual_family);

  _reject_plan(
   source_identity => $source_identity,
   code => 'generated_plan_family_mismatch',
   summary => 'Generated rule plan family does not match compiled rule',
   rule_label => $expected_label,
   handler_family => $actual_family,
   detail => 'row=' . $index . ' expected=' . (defined($expected_family) ? $expected_family : '<undef>')
    . ' actual=' . $actual_family,
  ) unless defined($expected_family) && $expected_family eq $actual_family;
 }

 return 1
}

sub trace_role {
 my (%args) = @_;
 return undef unless exists $INC{'LinkedSpec/Trace.pm'};
 my $role = defined($args{role}) ? $args{role} : '<unknown_role>';
 my @context = (
  'source_identity=' . (defined($args{source_identity}) ? $args{source_identity} : ''),
  'rule=' . (defined($args{rule_label}) ? $args{rule_label} : ''),
 );
 push @context, 'family=' . $args{handler_family} if defined $args{handler_family};
 push @context, 'status=' . $args{status} if defined $args{status};
 return LinkedSpec::Trace::log_output(
  500,
  "GENERATED_SOURCE $role",
  join("\n", @context),
  { caller_depth => 3 },
 )
}

1;

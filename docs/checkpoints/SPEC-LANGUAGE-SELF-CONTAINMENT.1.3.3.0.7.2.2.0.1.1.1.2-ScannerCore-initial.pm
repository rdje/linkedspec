package LinkedSpec::ActionIR::ScannerCore;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ActionIR::Trace ();
use Scalar::Util ();

our $_source_event_recorder;

# Called only by a provenance-aware producer. Keep the ordinary split callback
# at its existing call site when recording is inactive.
sub _split_scanner_statements_with_source_frames {
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::StatementSplit::Core');
 return LinkedSpec::ActionIR::StatementSplit::Core::_split_with_source_frames(@_)
}

# A later trim callback may transform the statement. Preserve its event and
# decline an origin unless the exact original frame still describes its raw.
sub _record_statement_source_event {
 my ($event, $frame) = @_;
 return $event unless ref($_source_event_recorder) eq 'CODE'
  && ref($frame) eq 'HASH' && defined($event->{raw}) && !ref($event->{raw})
  && $event->{raw} eq $frame->{raw};
 return _record_scanned_source_event($event, $frame->{source},
  $frame->{source_span}{start}, $frame->{source_span}{end})
}

# A producer records the exact match before passing its event to the caller.
# Ordinary scans return the same event object without collecting source data.
sub _record_scanned_source_event {
 my ($event, $source, $start, $end) = @_;
 return $event unless ref($_source_event_recorder) eq 'CODE';
 die "(LinkedSpec::ActionIR::ScannerCore source provenance) -E- invalid source coordinates"
  unless ref($event) eq 'HASH' && defined($source) && !ref($source)
   && defined($start) && !ref($start) && $start =~ /\A[0-9]+\z/
   && defined($end) && !ref($end) && $end =~ /\A[0-9]+\z/
   && $start <= $end && $end <= length($source);
 die "(LinkedSpec::ActionIR::ScannerCore source provenance) -E- raw source mismatch"
  unless defined($event->{raw}) && !ref($event->{raw})
   && substr($source, $start, $end - $start) eq $event->{raw};
 $_source_event_recorder->({
  event => $event,
  source => $source,
  source_span => {start => 0 + $start, end => 0 + $end},
 });
 return $event
}

# Private invocation-local sidecar. Instrumented producers retain their own
# source frames; origins follow the selected event stream, never a lexical sort.
# Contracts without producer hooks still return their ordinary events, with no
# fabricated origins. Opaque dispatcher returns retain their original identity.
sub _scan_contract_ir_events_with_provenance {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my @recorded;
  local $_source_event_recorder = sub { push @recorded, $_[0] };
  my $events = scan_contract_ir_events(@args);
  my @origins;
  if (ref($events) eq 'ARRAY') {
   my %by_event;
   foreach my $origin (@recorded) {
    push @{$by_event{Scalar::Util::refaddr($origin->{event})}}, $origin;
   }
   foreach my $event (@$events) {
    next unless ref($event) eq 'HASH';
    my $queue = $by_event{Scalar::Util::refaddr($event)};
    push @origins, shift @$queue if $queue && @$queue;
   }
  }
  return {events => $events, source_origins => \@origins}
 })
}

#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::ScannerCore
# Purpose : ActionIR scanner core owner that binds shared scanner-rule deps and
#           dispatches contract scanning across the rule-family scanners.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function: _scanner_rule_family_packages
# Purpose : Return the ordered scanner-rule family package list used for both
#           lazy loading and shared dependency rebinding.
# Args    : none
# Returns : ordered package-name list
#------------------------------------------------------------------------------
sub _scanner_rule_family_packages {
 return (
  'LinkedSpec::ActionIR::StagedParseJob',
  'LinkedSpec::ActionIR::ProgressiveSpanDispatch',
  'LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules',
  'LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules',
  'LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules',
  'LinkedSpec::ActionIR::Scanner::FlowRules',
  'LinkedSpec::ActionIR::Scanner::LegacyRules',
 )
}

#------------------------------------------------------------------------------
# Function: _scanner_dep_specs
# Purpose : Return the canonical scanner dependency contract shared by the
#           scanner owner and the scanner-core rebinding path.
# Args    : none
# Returns : ordered list of dependency spec hashes
#------------------------------------------------------------------------------
sub _scanner_dep_specs {
 return (
  { dep_name => 'split_action_ir_statements', binding_symbol => '_split_action_ir_statements' },
  { dep_name => 'trim_action_ir_value', binding_symbol => '_trim_action_ir_value' },
  { dep_name => 'parse_method_function_expr', binding_symbol => '_parse_method_function_expr', provider_pkg => 'LinkedSpec::ActionIR::MethodExpr' },
  { dep_name => 'normalize_method_args_with_optional_scope', binding_symbol => '_normalize_method_args_with_optional_scope', provider_pkg => 'LinkedSpec::ActionIR::MethodExpr' },
  { dep_name => 'build_array_pipeline_plan_from_expr', binding_symbol => '_build_array_pipeline_plan_from_expr' },
 )
}

#------------------------------------------------------------------------------
# Function: _scanner_rule_dep_bindings
# Purpose : Normalize the dependency callback bundle into the exact symbol map
#           rebound into each scanner-rule family package.
# Args    : ($deps)
# Returns : hashref of helper-symbol => callback bindings
#------------------------------------------------------------------------------
sub _scanner_rule_dep_bindings {
 my ($deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ScannerCore::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb
 };
 my %bindings;
 foreach my $spec (_scanner_dep_specs()) {
  $bindings{$spec->{binding_symbol}} = $require_dep->($spec->{dep_name});
 }
 return \%bindings
}

#------------------------------------------------------------------------------
# Function: _scanner_dispatchers
# Purpose : Lazy-load the scanner-rule families and return their public
#           dispatcher callbacks in the canonical family order.
# Args    : none
# Returns : ordered list of dispatcher coderefs
#------------------------------------------------------------------------------
sub _scanner_dispatchers {
 my @dispatchers;
 no strict 'refs';
 foreach my $pkg (_scanner_rule_family_packages()) {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
  push @dispatchers, \&{"${pkg}::try_scan_contract_ir_events"};
 }
 return @dispatchers
}

#------------------------------------------------------------------------------
# Function: _with_scanner_rule_family_deps
# Purpose : Rebind the shared helper symbols from the canonical scanner
#           dependency contract into one scanner-rule family for the duration
#           of one callback body.
# Args    : ($pkg, $bindings, $body)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _with_scanner_rule_family_deps {
 my ($pkg, $bindings, $body) = @_;
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- scanner-rule package must be provided"
  unless defined($pkg) && length($pkg);
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- scanner dep bindings must be HASH"
  unless ref($bindings) eq 'HASH';
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- body callback must be CODE"
  unless ref($body) eq 'CODE';

 my $runner = $body;
 my @binding_symbols = map { $_->{binding_symbol} } _scanner_dep_specs();
 foreach my $symbol (reverse @binding_symbols) {
  my $cb = $bindings->{$symbol};
  die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- missing bound scanner helper '$symbol'"
   unless ref($cb) eq 'CODE';
  my $next = $runner;
  $runner = sub {
   no strict 'refs';
   local *{"${pkg}::$symbol"} = $cb;
   return $next->();
  };
 }

 return $runner->()
}

#------------------------------------------------------------------------------
# Function: _with_scanner_rule_deps
# Purpose : Rebind the shared helper symbols into all scanner-rule families for
#           the duration of one callback body.
# Args    : ($bindings, $body)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _with_scanner_rule_deps {
 my ($bindings, $body) = @_;
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps) -E- scanner dep bindings must be HASH"
  unless ref($bindings) eq 'HASH';
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps) -E- body callback must be CODE"
  unless ref($body) eq 'CODE';

 my $runner = $body;
 foreach my $pkg (reverse _scanner_rule_family_packages()) {
  my $next = $runner;
  $runner = sub {
   return _with_scanner_rule_family_deps($pkg, $bindings, $next)
  };
 }

 return $runner->()
}

#------------------------------------------------------------------------------
# Function: scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code, $deps)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub scan_contract_ir_events {
 my ($contract, $code, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $id = $contract->{id} // '';
 my $scope = LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => 'scanner_core',
  phase => 'scan_contract_ir_events',
  label => $id,
  details => {
   contract_id => $id,
   code_len => defined($code) ? length($code) : 0,
  },
 );
 my $bindings = _scanner_rule_dep_bindings($deps);
 return _with_scanner_rule_deps($bindings, sub {
  my $dispatcher_index = 0;
  foreach my $scanner (_scanner_dispatchers()) {
   ++$dispatcher_index;
   my $events = $scanner->($id, $code);
   if (defined $events) {
    my $event_count = ref($events) eq 'ARRAY' ? scalar(@$events) : 0;
    if ($event_count) {
     LinkedSpec::ActionIR::Trace::decision(
      owner => 'scanner_core',
      phase => 'scan_contract_ir_events',
      label => $id,
      decision => 'events_found',
      taken => 1,
      context => {
       contract_id => $id,
       dispatcher_index => $dispatcher_index,
       event_count => $event_count,
      },
     );
    }
    LinkedSpec::ActionIR::Trace::exit_scope(
     $scope,
     {
      status => 'ok',
      contract_id => $id,
      dispatcher_index => $dispatcher_index,
      event_count => $event_count,
     },
    );
    return $events;
   }
  }

  LinkedSpec::ActionIR::Trace::exit_scope(
   $scope,
   {
    status => 'ok',
    contract_id => $id,
    event_count => 0,
   },
  );
  return []
 })
}

1;

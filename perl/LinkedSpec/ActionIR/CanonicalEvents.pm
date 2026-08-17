#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::CanonicalEvents
# Purpose: Canonical ActionIR event owner for helper-hit normalization and
#          fallback event assembly.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::CanonicalEvents;

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

sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'trim_action_ir_value',
   'split_action_ir_statements',
  ],
 )
}

sub _canonicalize_helper_action_ir_event {
 my ($label, $event, $deps) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::CanonicalEvents::Core');
  return LinkedSpec::ActionIR::CanonicalEvents::Core::canonicalize_helper_action_ir_event($label, $event)
 })
}

sub _user_function_registry_by_name {
 my ($deps) = @_;
 return undef unless ref($deps) eq 'HASH';
 my $registry = $deps->{user_function_registry};
 return undef unless ref($registry) eq 'HASH';
 return ref($registry->{by_name}) eq 'HASH' ? $registry->{by_name} : undef
}

sub _registered_user_function_definition_for_name {
 my ($deps, $name) = @_;
 return undef unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 my $by_name = _user_function_registry_by_name($deps);
 return undef unless ref($by_name) eq 'HASH';
 my $definition = $by_name->{$name};
 return undef unless ref($definition) eq 'HASH'
              && ($definition->{kind} // '') eq 'user_function_definition';
 return $definition
}

sub _statement_is_registered_user_function_value_drop {
 my ($statement, $deps) = @_;
 return 0 unless defined($statement) && length($statement);
 return 0 unless ref(_user_function_registry_by_name($deps)) eq 'HASH';

 my $node = eval {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::AST::Parser');
  LinkedSpec::ActionIR::AST::Parser::parse_action_expr($statement, { deps => $deps });
 };
 return 0 unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'call') {
  return ref(_registered_user_function_definition_for_name($deps, $node->{name})) eq 'HASH' ? 1 : 0
 }

 if ($kind eq 'fluent_chain') {
  my $receiver = $node->{receiver};
  return 0 unless ref($receiver) eq 'HASH' && ($receiver->{kind} // '') eq 'call';
  return ref(_registered_user_function_definition_for_name($deps, $receiver->{name})) eq 'HASH' ? 1 : 0
 }

 return 0
}

sub _statement_is_bound_codeblock_value_drop {
 my ($statement, $deps) = @_;
 return 0 unless defined($statement) && length($statement);
 return 0 unless ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE';

 my $node = eval {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::AST::Parser');
  LinkedSpec::ActionIR::AST::Parser::parse_action_expr($statement, { deps => $deps });
 };
 return 0 unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';
 my $call = $kind eq 'call' ? $node
  : $kind eq 'fluent_chain' && ref($node->{receiver}) eq 'HASH'
  && ($node->{receiver}{kind} // '') eq 'call' ? $node->{receiver}
  : undef;
 return 0 unless ref($call) eq 'HASH';
 my $name = $call->{name};
 return 0 unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return (($deps->{bare_symbol_kind}->($name) // '') eq 'scalar') ? 1 : 0
}

sub _registered_user_function_value_drop_event {
 my ($statement) = @_;
 return {
  kind        => 'VALUE_DROP',
  source      => 'registered_user_function_value_drop',
  contract_id => 'value_drop_statement',
  raw         => $statement,
  args        => { value => $statement },
 }
}

sub _build_canonical_action_ir_events {
 my ($label, $code, $helper_events, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $scope = LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => 'canonical_events',
  phase => 'build_canonical_action_ir_events',
  label => $label,
  details => {
   label => defined($label) ? $label : '<undef>',
   code_len => defined($code) ? length($code) : 0,
   helper_event_count => ref($helper_events) eq 'ARRAY' ? scalar(@$helper_events) : 0,
  },
 );
 my $trim_action_ir_value = (ref($deps->{trim_action_ir_value}) eq 'CODE')
  ? $deps->{trim_action_ir_value}
  : undef;
 die "(LinkedSpec::ActionIR::CanonicalEvents::_require_dep) -E- missing dependency callback 'trim_action_ir_value'"
  unless ref($trim_action_ir_value) eq 'CODE';
 my $split_action_ir_statements = (ref($deps->{split_action_ir_statements}) eq 'CODE')
  ? $deps->{split_action_ir_statements}
  : undef;
 die "(LinkedSpec::ActionIR::CanonicalEvents::_require_dep) -E- missing dependency callback 'split_action_ir_statements'"
  unless ref($split_action_ir_statements) eq 'CODE';

 my %helper_event_queue;
 foreach my $helper_event (@$helper_events) {
  my $raw_key = $trim_action_ir_value->($helper_event->{raw});
  next unless defined($raw_key) && length($raw_key);
  my $canonical_event = _canonicalize_helper_action_ir_event($label, $helper_event, $deps);
  push @{$helper_event_queue{$raw_key}}, $canonical_event;
  LinkedSpec::ActionIR::Trace::decision(
   owner => 'canonical_events',
   phase => 'build_canonical_action_ir_events',
   label => $label,
   decision => 'queue_helper_event',
   taken => 1,
   context => {
    raw => $raw_key,
    kind => ref($canonical_event) eq 'HASH' ? ($canonical_event->{kind} // '') : '',
    contract_id => ref($canonical_event) eq 'HASH' ? ($canonical_event->{contract_id} // '') : '',
   },
  );
 }

 my @canonical_events;
 my $fallback_count = 0;
 foreach my $statement (@{$split_action_ir_statements->($code)}) {
  if (exists $helper_event_queue{$statement} && @{$helper_event_queue{$statement}}) {
   my $event = shift @{$helper_event_queue{$statement}};
   my $exclusive_statement = delete $event->{_exclusive_statement};
   delete $helper_event_queue{$statement} if $exclusive_statement;
   push @canonical_events, $event;
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'canonical_events',
    phase => 'build_canonical_action_ir_events',
    label => $label,
    decision => 'statement_queue_match',
    taken => 1,
    context => {
     raw => $statement,
     kind => ref($event) eq 'HASH' ? ($event->{kind} // '') : '',
     contract_id => ref($event) eq 'HASH' ? ($event->{contract_id} // '') : '',
    },
   );
  } elsif (_statement_is_registered_user_function_value_drop($statement, $deps)) {
   push @canonical_events, _registered_user_function_value_drop_event($statement);
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'canonical_events',
    phase => 'build_canonical_action_ir_events',
    label => $label,
    decision => 'registered_value_drop',
    taken => 1,
    context => {
     raw => $statement,
    },
   );
  } elsif (_statement_is_bound_codeblock_value_drop($statement, $deps)) {
   push @canonical_events, _registered_user_function_value_drop_event($statement);
   $canonical_events[-1]{source} = 'bound_codeblock_value_drop';
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'canonical_events',
    phase => 'build_canonical_action_ir_events',
    label => $label,
    decision => 'bound_codeblock_value_drop',
    taken => 1,
    context => { raw => $statement },
   );
  } else {
   push @canonical_events, {
    kind        => 'RAW_PERL',
    source      => 'fallback_non_helper_statement',
    contract_id => undef,
    raw         => $statement,
    args        => {code => $statement},
   };
   ++$fallback_count;
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'canonical_events',
    phase => 'build_canonical_action_ir_events',
    label => $label,
    decision => 'raw_perl_fallback',
    taken => 1,
    context => {
     raw => $statement,
     fallback_count => $fallback_count,
    },
   );
  }
 }

 foreach my $raw_key (keys %helper_event_queue) {
  while (@{$helper_event_queue{$raw_key}}) {
   my $event = shift @{$helper_event_queue{$raw_key}};
   delete $event->{_exclusive_statement};
   $event->{source} = 'unmatched_helper_scan_event';
   push @canonical_events, $event;
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'canonical_events',
    phase => 'build_canonical_action_ir_events',
    label => $label,
    decision => 'unmatched_helper_event',
    taken => 1,
    context => {
     raw => $raw_key,
     kind => ref($event) eq 'HASH' ? ($event->{kind} // '') : '',
     contract_id => ref($event) eq 'HASH' ? ($event->{contract_id} // '') : '',
    },
   );
  }
 }

 my %hits;
 my $count = 0;
 foreach my $event (@canonical_events) {
  my $kind = $event->{kind} // 'UNKNOWN';
  $hits{$kind} += 1;
  ++$count;
 }

 my $diag = {
  canonical_action_ir_count => $count,
  canonical_action_ir_hits  => \%hits,
  canonical_action_ir_nodes => [sort keys %hits],
  canonical_action_ir_events => \@canonical_events,
  canonical_action_ir_fallback_count => $fallback_count,
 };
 LinkedSpec::ActionIR::Trace::exit_scope(
  $scope,
  {
   status => 'ok',
   label => defined($label) ? $label : '<undef>',
   canonical_action_ir_count => $count,
   fallback_count => $fallback_count,
  },
 );
 return $diag
}

1;

#------------------------------------------------------------------------------
# Package: LinkedSpec::CompilerState
# Purpose: Internal compiled-spec / gdata / descriptor state model owner for
#          the LinkedSpec compiler pipeline.
#------------------------------------------------------------------------------
package LinkedSpec::CompilerState;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub new_compiled_spec_state {
 return {
  kind => 'compiled_spec_state',
  version => 1,
  definition_order => [],
  rule_order => [],
  rules_by_label => {},
  duplicate_rule_labels => [],
 }
}

sub is_compiled_spec_state {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_spec_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{definition_order}) eq 'ARRAY';
 return 0 unless ref($value->{rule_order}) eq 'ARRAY';
 return 0 unless ref($value->{rules_by_label}) eq 'HASH';
 return 0 unless ref($value->{duplicate_rule_labels}) eq 'ARRAY';
 return 1
}

sub compiled_spec_state_rule_count {
 my ($state) = @_;
 return 0 unless is_compiled_spec_state($state);
 return scalar(@{$state->{rule_order}})
}

sub compiled_spec_state_rules_by_label {
 my ($state) = @_;
 return undef unless is_compiled_spec_state($state);
 return $state->{rules_by_label}
}

sub compiled_spec_state_rule_order {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 return $state->{rule_order}
}

sub compiled_spec_state_definition_order {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 return $state->{definition_order}
}

sub compiled_spec_state_duplicate_rule_labels {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 return $state->{duplicate_rule_labels}
}

sub compiled_spec_state_to_legacy_spec {
 my ($state) = @_;
 return undef unless is_compiled_spec_state($state);
 return { %{$state->{rules_by_label}} }
}

sub compiled_spec_state_meta {
 my ($state) = @_;
 return {} unless is_compiled_spec_state($state);
 return {
  descriptor_model => 'compiled_spec_state_v1',
  definition_order => [map { $_->{label} } @{compiled_spec_state_definition_order($state)}],
  rule_order => [@{$state->{rule_order}}],
  duplicate_rule_labels => [@{$state->{duplicate_rule_labels}}],
 }
}

sub record_compiled_spec_rule {
 my ($state, $label, $info, $duplicate_seen) = @_;
 die "(LinkedSpec::CompilerState::record_compiled_spec_rule) -E- compiled spec state is invalid"
  unless is_compiled_spec_state($state);

 my $is_duplicate = exists $state->{rules_by_label}{$label};
 push @{$state->{definition_order}}, {
  label => $label,
  info => $info,
 };
 push @{$state->{rule_order}}, $label unless $is_duplicate;
 if ($is_duplicate && ref($duplicate_seen) eq 'HASH' && !$duplicate_seen->{$label}++) {
  push @{$state->{duplicate_rule_labels}}, $label;
 }
 $state->{rules_by_label}{$label} = $info;
 return $is_duplicate
}

sub new_compiled_gdata_state {
 my (%args) = @_;
 my $compiled_spec_state = $args{compiled_spec_state};
 my $compiled_gdata_by_label = $args{compiled_gdata_by_label};

 die "(LinkedSpec::CompilerState::new_compiled_gdata_state) -E- compiled spec state is invalid"
  unless is_compiled_spec_state($compiled_spec_state);
 die "(LinkedSpec::CompilerState::new_compiled_gdata_state) -E- compiled gdata map must be HASH ref"
  unless ref($compiled_gdata_by_label) eq 'HASH';

 my $source_rule_order = [@{compiled_spec_state_rule_order($compiled_spec_state)}];
 my %seen_compiled;
 my @compiled_label_order = grep {
  exists($compiled_gdata_by_label->{$_}) && !$seen_compiled{$_}++
 } @$source_rule_order;

 return {
  kind => 'compiled_gdata_state',
  version => 1,
  source_rule_order => $source_rule_order,
  compiled_label_order => \@compiled_label_order,
  gdata_by_label => { %$compiled_gdata_by_label },
 }
}

sub is_compiled_gdata_state {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_gdata_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{source_rule_order}) eq 'ARRAY';
 return 0 unless ref($value->{compiled_label_order}) eq 'ARRAY';
 return 0 unless ref($value->{gdata_by_label}) eq 'HASH';
 return 1
}

sub compiled_gdata_state_gdata_by_label {
 my ($state) = @_;
 return {} unless is_compiled_gdata_state($state);
 return $state->{gdata_by_label}
}

sub compiled_gdata_state_to_legacy_gdata {
 my ($state) = @_;
 return undef unless is_compiled_gdata_state($state);
 return { %{compiled_gdata_state_gdata_by_label($state)} }
}

sub new_compiled_descriptor_state {
 my (%args) = @_;
 my $compiled_spec_state = $args{compiled_spec_state};
 my $compiled_gdata_state = $args{compiled_gdata_state};
 my $meta = (ref($args{meta}) eq 'HASH') ? $args{meta} : {};

 die "(LinkedSpec::CompilerState::new_compiled_descriptor_state) -E- compiled spec state is invalid"
  unless is_compiled_spec_state($compiled_spec_state);
 die "(LinkedSpec::CompilerState::new_compiled_descriptor_state) -E- compiled gdata state is invalid"
  unless is_compiled_gdata_state($compiled_gdata_state);

 return {
  kind => 'compiled_descriptor_state',
  version => 1,
  compiled_spec_state => $compiled_spec_state,
  compiled_gdata_state => $compiled_gdata_state,
  meta => { %$meta },
 }
}

sub is_compiled_descriptor_state {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_descriptor_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless is_compiled_spec_state($value->{compiled_spec_state});
 return 0 unless is_compiled_gdata_state($value->{compiled_gdata_state});
 return 0 unless ref($value->{meta}) eq 'HASH';
 return 1
}

sub compiled_descriptor_state_spec_state {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return $state->{compiled_spec_state}
}

sub compiled_descriptor_state_gdata_state {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return $state->{compiled_gdata_state}
}

sub compiled_descriptor_state_gdata_by_label {
 my ($state) = @_;
 return {} unless is_compiled_descriptor_state($state);
 return compiled_gdata_state_gdata_by_label(compiled_descriptor_state_gdata_state($state))
}

sub compiled_descriptor_state_rules_by_label {
 my ($state) = @_;
 return {} unless is_compiled_descriptor_state($state);
 return compiled_spec_state_rules_by_label(compiled_descriptor_state_spec_state($state))
}

sub compiled_descriptor_state_meta {
 my ($state) = @_;
 return {} unless is_compiled_descriptor_state($state);
 return $state->{meta}
}

sub compiled_descriptor_state_to_legacy_descr {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return {
  spec => compiled_spec_state_to_legacy_spec(compiled_descriptor_state_spec_state($state)),
  gdata => compiled_gdata_state_to_legacy_gdata(compiled_descriptor_state_gdata_state($state)),
  meta => { %{compiled_descriptor_state_meta($state)} },
 }
}

sub normalize_compiled_spec_input {
 my ($value, %args) = @_;
 my $on_invalid = $args{on_invalid};
 return $value if is_compiled_spec_state($value);

 unless (ref($value) eq 'HASH') {
  my $detail = defined($on_invalid) && ref($on_invalid) eq 'CODE'
   ? $on_invalid->($value)
   : undef;
  die(($detail =~ /\n\z/) ? $detail : "$detail\n") if defined($detail) && length($detail);
  die "(LinkedSpec::CompilerState::normalize_compiled_spec_input) -E- expected HASH or compiled_spec_state";
 }

 my $state = new_compiled_spec_state();
 foreach my $label (sort keys %$value) {
  record_compiled_spec_rule($state, $label, $value->{$label}, {});
 }
 return $state
}

sub normalize_compiled_gdata_output {
 my ($value, $compiled_spec_state, %args) = @_;
 my $on_invalid = $args{on_invalid};
 return $value if is_compiled_gdata_state($value);

 unless (ref($value) eq 'HASH') {
  my $detail = defined($on_invalid) && ref($on_invalid) eq 'CODE'
   ? $on_invalid->($value)
   : undef;
  die(($detail =~ /\n\z/) ? $detail : "$detail\n") if defined($detail) && length($detail);
  die "(LinkedSpec::CompilerState::normalize_compiled_gdata_output) -E- expected HASH or compiled_gdata_state";
 }

 return new_compiled_gdata_state(
  compiled_spec_state => $compiled_spec_state,
  compiled_gdata_by_label => $value,
 )
}

1;

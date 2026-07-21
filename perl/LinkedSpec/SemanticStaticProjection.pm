#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticStaticProjection
# Purpose: Project clone-safe static semantic records and relations from the
#          accepted source, compiled descriptor, and compilation diagnostic.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticStaticProjection;

use 5.010;
use strict;
use warnings;
use utf8;

use Encode qw(encode FB_CROAK LEAVE_SRC);
use JSON::PP ();

my @RECORD_KINDS = qw(
 capabilities spec source rule regex_slot edge lifecycle function helper
 binding call staged_artifact generated_artifact diagnostic decision execution
 event explanation_step
);
my @RELATION_KINDS = qw(
 declares contains depends_on dispatches_to selects_regex calls resolves_to
 reads writes consumes produces lowered_from staged_by generated_as diagnoses
 observed_as explained_by
);
my %RECORD_RANK = map { $RECORD_KINDS[$_] => $_ } 0 .. $#RECORD_KINDS;
my %RELATION_RANK = map { $RELATION_KINDS[$_] => $_ } 0 .. $#RELATION_KINDS;

sub build {
 my (%args) = @_;
 my $source_text = $args{source_text};
 my $source_map = $args{source_map};
 my $logical_name = $args{logical_name};
 my $content_digest = $args{content_digest};
 die "(LinkedSpec::SemanticStaticProjection::build) -E- source_text must be a scalar\n"
  if !defined($source_text) || ref($source_text);
 die "(LinkedSpec::SemanticStaticProjection::build) -E- source_map is required\n"
  unless ref($source_map) && $source_map->can('span_from_character_range');
 die "(LinkedSpec::SemanticStaticProjection::build) -E- logical_name must be a scalar\n"
  if !defined($logical_name) || ref($logical_name);
 die "(LinkedSpec::SemanticStaticProjection::build) -E- content_digest must be a scalar\n"
  if !defined($content_digest) || ref($content_digest);

 my $snapshot = { %{$args{snapshot} || {}} };
 $snapshot->{has_execution} = _boolean($snapshot->{has_execution});
 $snapshot->{content_digest_available} = _boolean($snapshot->{content_digest_available});
 $args{snapshot} = $snapshot;

 my $scan = _scan_source($source_text);
 my $projection = ref($args{descriptor}) eq 'HASH'
  ? _build_compiled(
     %args,
     source_text => $source_text,
     source_map => $source_map,
     logical_name => $logical_name,
     content_digest => $content_digest,
     scan => $scan,
    )
  : _build_failed(
     %args,
     source_text => $source_text,
     source_map => $source_map,
     logical_name => $logical_name,
     content_digest => $content_digest,
     scan => $scan,
    );
 return _canonicalize($projection)
}

sub _build_compiled {
 my (%args) = @_;
 my $descriptor = $args{descriptor};
 my $meta = ref($descriptor->{meta}) eq 'HASH' ? $descriptor->{meta} : {};
 my @definition_order = ref($meta->{definition_order}) eq 'ARRAY'
  ? @{$meta->{definition_order}}
  : sort keys %{$descriptor->{spec} || {}};
 my @compiled_order = ref($meta->{compiled_rule_order}) eq 'ARRAY'
  ? @{$meta->{compiled_rule_order}}
  : @definition_order;
 my %definition_index = map { $definition_order[$_] => $_ } 0 .. $#definition_order;
 my %rule_ids = map { $_ => _rule_id($_) } @definition_order;
 my $selected_rule = $args{selected_top_rule};
 $selected_rule = $compiled_order[0] unless defined($selected_rule) && length($selected_rule);
 my $entry_basis = defined($args{requested_top_rule}) && length($args{requested_top_rule})
  ? 'explicit_selector'
  : (_first_marker(\@definition_order, $args{scan}) ? 'first_marker' : 'first_rule');

 my (@records, @relations);
 my %source_refs;
 push @records, _record(
  id => 'spec:0',
  kind => 'spec',
  name => _spec_name($args{logical_name}),
  owner_id => undef,
  order => 0,
  source => undef,
  facts => {
   definition_order => [map { $rule_ids{$_} } @definition_order],
   compiled_rule_order => [map { _rule_id($_) } @compiled_order],
   entry_rule_id => defined($selected_rule) ? _rule_id($selected_rule) : undef,
   entry_selection_basis => $entry_basis,
  },
 );
 push @records, _source_record();

 my %components;
 foreach my $label (@definition_order) {
  my $rule = ref($descriptor->{spec}{$label}) eq 'HASH' ? $descriptor->{spec}{$label} : {};
  my $rule_meta = ref($rule->{meta}) eq 'HASH' ? $rule->{meta} : {};
  my $section = $args{scan}{by_label}{$label};
  $components{$label} = _compiled_components($label, $rule_meta, $section);
 }

 foreach my $label (@definition_order) {
  my $rule = ref($descriptor->{spec}{$label}) eq 'HASH' ? $descriptor->{spec}{$label} : {};
  my $rule_meta = ref($rule->{meta}) eq 'HASH' ? $rule->{meta} : {};
  my $component = $components{$label};
  my $rule_id = $rule_ids{$label};
  my $header_source = _register_source(
   \%source_refs,
   "source_ref:$rule_id",
   $component->{header},
   \%args,
  );
  my ($rep_min, $rep_max) = _neutral_bounds($rule_meta->{rep_min}, $rule_meta->{rep_max});
  my $is_repetition = defined($rep_min) || defined($rep_max) ? 1 : 0;
  my $rule_shape = _rule_value_shape($is_repetition, $component->{edges}, $component->{lifecycles});
  push @records, _record(
   id => $rule_id,
   kind => 'rule',
   name => $label,
   owner_id => 'spec:0',
   order => $definition_index{$label},
   source => $header_source,
   facts => {
    family => ($rule_meta->{family} // '') eq 'and' ? 'and' : 'or',
    cursor_policy => ($rule_meta->{cursor_policy} // '') eq 'consume' ? 'contiguous' : 'seek',
    is_entry_marker => _boolean($component->{is_marker}),
    is_repetition => _boolean($is_repetition),
    rep_min => $rep_min,
    rep_max => $rep_max,
    edge_ownership => _neutral_ownership($rule_meta->{edge_ownership}),
    value_shape => $rule_shape,
   },
  );

  foreach my $slot (@{$component->{regex_slots}}) {
   my $slot_id = "regex:$rule_id:$slot->{order}";
   my $source = _register_source(
    \%source_refs,
    "source_ref:$slot_id",
    $slot->{range},
    \%args,
   );
   push @records, _record(
    id => $slot_id,
    kind => 'regex_slot',
    name => undef,
    owner_id => $rule_id,
    order => $slot->{order},
    source => $source,
    facts => {
     authored_index => $slot->{order},
     pattern => $slot->{pattern},
     flags => $slot->{flags},
     combined_owner_ids => [$rule_id],
     target_shape => _target_shape('regex_slot'),
    },
   );
  }

  foreach my $edge (@{$component->{edges}}) {
   my $edge_id = "edge:$rule_id:$edge->{order}";
   my $source = _register_source(
    \%source_refs,
    "source_ref:$edge_id",
    $edge->{range},
    \%args,
   );
   push @records, _record(
    id => $edge_id,
    kind => 'edge',
    name => undef,
    owner_id => $rule_id,
    order => $edge->{order},
    source => $source,
    facts => {
     ownership => _neutral_ownership($edge->{ownership}),
     source_form => defined($edge->{target_index}) ? 'indexed' : 'direct',
     has_block => _boolean($edge->{has_block}),
     fluent_call_ids => [],
     value_shape => $edge->{value_shape},
     target_shape => _target_shape(defined($edge->{target_index}) ? 'regex_slot' : 'rule'),
    },
   );
  }

  foreach my $lifecycle (@{$component->{lifecycles}}) {
   my $lifecycle_id = "lifecycle:$rule_id:$lifecycle->{marker}:$lifecycle->{order}";
   my $source = _register_source(
    \%source_refs,
    "source_ref:$lifecycle_id",
    $lifecycle->{range},
    \%args,
   );
   push @records, _record(
    id => $lifecycle_id,
    kind => 'lifecycle',
    name => $lifecycle->{marker},
    owner_id => $rule_id,
    order => $lifecycle->{order},
    source => $source,
    facts => {
     marker => $lifecycle->{marker},
     whole_rule_return => _boolean($lifecycle->{marker} eq 'E'),
     value_shape => $lifecycle->{value_shape},
    },
   );
  }
 }

 foreach my $index (0 .. $#definition_order) {
  my $rule_id = $rule_ids{$definition_order[$index]};
  push @relations, _relation('declares', 'spec:0', $rule_id, $index, undef, []);
 }
 push @relations, _relation('contains', 'spec:0', 'source:0', 0, undef, []);

 foreach my $label (@definition_order) {
  my $component = $components{$label};
  my $rule_id = $rule_ids{$label};
  my $contains_order = 0;
  foreach my $slot (@{$component->{regex_slots}}) {
   my $slot_id = "regex:$rule_id:$slot->{order}";
   push @relations, _relation(
    'contains', $rule_id, $slot_id, $contains_order++, "source_ref:$slot_id", [],
   );
  }
  foreach my $edge (@{$component->{edges}}) {
   my $edge_id = "edge:$rule_id:$edge->{order}";
   push @relations, _relation(
    'contains', $rule_id, $edge_id, $contains_order++, "source_ref:$edge_id", [],
   );
  }
  foreach my $lifecycle (@{$component->{lifecycles}}) {
   my $lifecycle_id = "lifecycle:$rule_id:$lifecycle->{marker}:$lifecycle->{order}";
   push @relations, _relation(
    'contains', $rule_id, $lifecycle_id, $contains_order++, "source_ref:$lifecycle_id", [],
   );
  }
  foreach my $edge (@{$component->{edges}}) {
   next unless defined($edge->{target}) && exists($rule_ids{$edge->{target}});
   my $edge_id = "edge:$rule_id:$edge->{order}";
   my $target_rule_id = $rule_ids{$edge->{target}};
   push @relations, _relation(
    'dispatches_to', $edge_id, $target_rule_id, $edge->{order}, "source_ref:$edge_id", [],
   ) unless $target_rule_id eq $rule_id && defined($edge->{target_index});
   if (defined $edge->{target_index}) {
    my $slot_id = "regex:$target_rule_id:$edge->{target_index}";
    push @relations, _relation(
     'selects_regex', $edge_id, $slot_id, $edge->{order}, "source_ref:$edge_id", [],
    );
   }
  }
 }

 # A multi-rule selection has a non-trivial choice worth retaining as ordered
 # evidence. Single-rule selection remains fully represented by the spec facts.
 if (@definition_order > 1 && defined($selected_rule) && exists($rule_ids{$selected_rule})) {
  _add_entry_explanation(
   records => \@records,
   relations => \@relations,
   source_refs => \%source_refs,
   source_args => \%args,
   selected_rule => $selected_rule,
   selected_rule_id => $rule_ids{$selected_rule},
   selected_header => $components{$selected_rule}{header},
   basis => $entry_basis,
   explicit => defined($args{requested_top_rule}) && length($args{requested_top_rule}) ? 1 : 0,
  );
 }

 return {
  snapshot => $args{snapshot},
  source_refs => \%source_refs,
  records => \@records,
  relations => \@relations,
 }
}

sub _build_failed {
 my (%args) = @_;
 my @sections = @{$args{scan}{rules}};
 my @labels = map { $_->{label} } @sections;
 my %sections = map { $_->{label} => $_ } @sections;
 my $error = ref($args{compilation_error}) eq 'HASH' ? $args{compilation_error} : {};
 my $label = defined($error->{rule_label}) && length($error->{rule_label})
  ? $error->{rule_label}
  : $labels[0];
 my $section = defined($label) ? $sections{$label} : undef;
 my $header = ref($section) eq 'HASH' ? $section->{header} : undef;
 my $header_facts = _header_facts(ref($section) eq 'HASH' ? $section->{header_text} : '');
 my $rule_id = defined($label) ? _rule_id($label) : 'rule:unknown';
 my $target = $error->{target};
 my $missing_member = _find_target_member($section, $target);
 my $ownership = ref($missing_member) eq 'HASH'
  ? ($header_facts->{family} eq 'and' ? 'blind' : 'action')
  : 'none';
 my (@records, @relations);
 my %source_refs;

 push @records, _record(
  id => 'spec:0',
  kind => 'spec',
  name => _spec_name($args{logical_name}),
  owner_id => undef,
  order => 0,
  source => undef,
  facts => {
   definition_order => [map { _rule_id($_) } @labels],
   compiled_rule_order => [],
   entry_rule_id => undef,
   entry_selection_basis => undef,
  },
 );
 push @records, _source_record();
 my $header_source = _register_source(
  \%source_refs,
  "source_ref:$rule_id",
  $header,
  \%args,
 );
 push @records, _record(
  id => $rule_id,
  kind => 'rule',
  name => $label,
  owner_id => 'spec:0',
  order => 0,
  source => $header_source,
  facts => {
   family => $header_facts->{family},
   cursor_policy => $header_facts->{cursor_policy},
   is_entry_marker => _boolean($header_facts->{is_entry_marker}),
   is_repetition => _boolean($header_facts->{is_repetition}),
   rep_min => $header_facts->{rep_min},
   rep_max => $header_facts->{rep_max},
   edge_ownership => $ownership,
   value_shape => _value_shape('unknown'),
  },
 );

 my $diagnostic_id = 'diagnostic:compile:0';
 my $diagnostic_source = _register_source(
  \%source_refs,
  "source_ref:$diagnostic_id",
  ref($missing_member) eq 'HASH' ? $missing_member->{range} : undef,
  \%args,
 );
 my $missing_id = defined($target) ? _rule_id($target) : 'rule:unknown';
 my $portable_code = ($error->{code} // '') eq 'bare_edge_target_undefined'
  ? 'unknown_rule_reference'
  : ($error->{code} // 'compilation_failed');
 my $message = $portable_code eq 'unknown_rule_reference'
  ? "Rule $label references unknown rule $target."
  : ($error->{summary} // 'Spec compilation failed.');
 my $fields = $portable_code eq 'unknown_rule_reference'
  ? { rule_id => $rule_id, missing_rule_id => $missing_id }
  : { rule_id => $rule_id };
 push @records, _record(
  id => $diagnostic_id,
  kind => 'diagnostic',
  name => $portable_code,
  owner_id => 'spec:0',
  order => 0,
  source => $diagnostic_source,
  facts => {
   code => $portable_code,
   stage => 'compile',
   severity => 'error',
   message => $message,
   fields => $fields,
  },
 );

 my $decision_id = "decision:compile:$rule_id";
 push @records, _record(
  id => $decision_id,
  kind => 'decision',
  name => "compile rule $label",
  owner_id => $rule_id,
  order => 0,
  source => $diagnostic_source,
  facts => { decision_kind => 'dependency_resolution', outcome => $diagnostic_id },
 );
 my $explanation_id = "explanation:$decision_id:0";
 push @records, _record(
  id => $explanation_id,
  kind => 'explanation_step',
  name => undef,
  owner_id => $decision_id,
  order => 0,
  source => $diagnostic_source,
  facts => {
   rule_code => 'dependency_target_missing',
   summary => "The authored dependency $target has no declared rule.",
   input_ids => [$rule_id],
   output_fact => { record_id => $decision_id, path => '/facts/outcome', value => $diagnostic_id },
  },
 );

 push @relations, _relation('contains', 'spec:0', 'source:0', 0, undef, []);
 push @relations, _relation('contains', 'spec:0', $diagnostic_id, 1, $diagnostic_source, []);
 push @relations, _relation('diagnoses', $diagnostic_id, $rule_id, 0, $diagnostic_source, []);
 push @relations, _relation('explained_by', $decision_id, $explanation_id, 0, $diagnostic_source, [$diagnostic_id]);

 return {
  snapshot => $args{snapshot},
  source_refs => \%source_refs,
  records => \@records,
  relations => \@relations,
 }
}

sub _compiled_components {
 my ($label, $rule_meta, $section) = @_;
 $section = { members => [] } unless ref($section) eq 'HASH';
 my @edge_members = grep { ref($_->{edge}) eq 'HASH' } @{$section->{members} || []};
 my @resolved = ref($rule_meta->{resolved_edges}) eq 'ARRAY' ? @{$rule_meta->{resolved_edges}} : ();
 my @edges;
 foreach my $index (0 .. $#resolved) {
  my $descriptor_edge = $resolved[$index];
  my $member = $edge_members[$index];
  my $source_edge = ref($member) eq 'HASH' ? $member->{edge} : {};
  push @edges, {
   order => $index,
   ownership => $descriptor_edge->{ownership},
   target => $descriptor_edge->{target},
   target_index => $source_edge->{target_index},
   has_block => $descriptor_edge->{block} ? 1 : 0,
   value_shape => ref($member) eq 'HASH' ? _infer_return_shape($member->{text}) : _value_shape('unknown'),
   range => ref($member) eq 'HASH' ? $member->{range} : undef,
  };
 }

 my @regex_slots;
 foreach my $member (@{$section->{members} || []}) {
  next unless ref($member->{regex}) eq 'HASH';
  my $edge = $member->{edge};
  next if ref($edge) eq 'HASH'
   && !(defined($edge->{target}) && $edge->{target} eq $label && defined($edge->{target_index}));
  push @regex_slots, {
   order => scalar(@regex_slots),
   pattern => $member->{regex}{pattern},
   flags => $member->{regex}{flags},
   range => $member->{range},
  };
 }

 my %marker_order;
 my @lifecycles;
 foreach my $member (@{$section->{members} || []}) {
  next unless defined $member->{lifecycle_marker};
  my $marker = $member->{lifecycle_marker};
  push @lifecycles, {
   marker => $marker,
   order => $marker_order{$marker} // 0,
   value_shape => _infer_return_shape($member->{text}),
   range => $member->{range},
  };
  ++$marker_order{$marker};
 }

 return {
  header => $section->{header},
  is_marker => $section->{is_marker} ? 1 : 0,
  regex_slots => \@regex_slots,
  edges => \@edges,
  lifecycles => \@lifecycles,
 }
}

sub _add_entry_explanation {
 my (%args) = @_;
 my $decision_id = 'decision:entry:spec:0';
 my $source = _register_source(
  $args{source_refs},
  "source_ref:$decision_id",
  $args{selected_header},
  $args{source_args},
 );
 push @{$args{records}}, _record(
  id => $decision_id,
  kind => 'decision',
  name => 'entry selection',
  owner_id => 'spec:0',
  order => 0,
  source => $source,
  facts => { decision_kind => 'entry_selection', outcome => $args{selected_rule_id} },
 );
 my $first_id = "explanation:$decision_id:0";
 push @{$args{records}}, _record(
  id => $first_id,
  kind => 'explanation_step',
  name => undef,
  owner_id => $decision_id,
  order => 0,
  source => $source,
  facts => {
   rule_code => $args{explicit} ? 'entry_explicit_selector' : 'entry_explicit_selector_absent',
   summary => $args{explicit}
    ? "The caller selected $args{selected_rule}."
    : 'No caller selector was supplied.',
   input_ids => ['spec:0'],
   output_fact => { record_id => 'spec:0', path => '/facts/entry_selection_basis', value => $args{basis} },
  },
 );
 my $second_id = "explanation:$decision_id:1";
 my $rule_code = $args{basis} eq 'first_marker' ? 'entry_first_marker'
  : $args{basis} eq 'first_rule' ? 'entry_first_rule'
  : 'entry_explicit_rule';
 my $summary = $args{basis} eq 'first_marker'
  ? "The first authored entry marker selects $args{selected_rule}."
  : $args{basis} eq 'first_rule'
   ? "The first authored rule selects $args{selected_rule}."
   : "The explicit selector resolves to $args{selected_rule}.";
 push @{$args{records}}, _record(
  id => $second_id,
  kind => 'explanation_step',
  name => undef,
  owner_id => $decision_id,
  order => 1,
  source => $source,
  facts => {
   rule_code => $rule_code,
   summary => $summary,
   input_ids => [$args{selected_rule_id}],
   output_fact => { record_id => 'spec:0', path => '/facts/entry_rule_id', value => $args{selected_rule_id} },
  },
 );
 push @{$args{relations}}, _relation('explained_by', $decision_id, $first_id, 0, $source, [$args{selected_rule_id}]);
 push @{$args{relations}}, _relation('explained_by', $decision_id, $second_id, 1, $source, [$args{selected_rule_id}]);
 return
}

sub _scan_source {
 my ($source_text) = @_;
 my @lines = _source_lines($source_text);
 my @rules;
 my %by_label;
 my ($current_rule, $current_member);

 foreach my $line (@lines) {
  my $trimmed = _trimmed_line($source_text, $line);
  if (ref($current_member) eq 'HASH') {
   $current_member->{end} = $trimmed->{end} if $trimmed->{end} > $current_member->{end};
   $current_member->{depth} += _nesting_delta($trimmed->{text});
   if ($current_member->{depth} <= 0) {
    _finish_member($source_text, $current_rule, $current_member);
    $current_member = undef;
   }
   next;
  }
  next unless length $trimmed->{text};
  next if $trimmed->{text} =~ /\A#/;

  my $header = _parse_header($trimmed->{text});
  if (ref($header) eq 'HASH') {
   $current_rule = {
    label => $header->{label},
    is_marker => $header->{is_marker},
    header_text => $trimmed->{text},
    header => { start => $trimmed->{start}, end => $trimmed->{end} },
    members => [],
   };
   push @rules, $current_rule;
   $by_label{$header->{label}} = $current_rule;
   next;
  }
  next unless ref($current_rule) eq 'HASH';
  $current_member = {
   start => $trimmed->{start},
   end => $trimmed->{end},
   depth => _nesting_delta($trimmed->{text}),
  };
  if ($current_member->{depth} <= 0) {
   _finish_member($source_text, $current_rule, $current_member);
   $current_member = undef;
  }
 }
 _finish_member($source_text, $current_rule, $current_member)
  if ref($current_member) eq 'HASH';
 return { rules => \@rules, by_label => \%by_label }
}

sub _source_lines {
 my ($text) = @_;
 my @lines;
 my $start = 0;
 my $length = length($text);
 while ($start < $length) {
  my $newline = index($text, "\n", $start);
  my $end = $newline < 0 ? $length : $newline;
  push @lines, { start => $start, end => $end };
  last if $newline < 0;
  $start = $newline + 1;
 }
 return @lines
}

sub _trimmed_line {
 my ($text, $line) = @_;
 my $value = substr($text, $line->{start}, $line->{end} - $line->{start});
 my ($left) = $value =~ /\A(\s*)/;
 my ($right) = $value =~ /(\s*)\z/;
 my $start = $line->{start} + length($left // '');
 my $end = $line->{end} - length($right // '');
 $end = $start if $end < $start;
 return { start => $start, end => $end, text => substr($text, $start, $end - $start) }
}

sub _parse_header {
 my ($text) = @_;
 return undef unless $text =~ /\A(\w+)\s*(::|:)(.*)\z/s;
 return { label => $1, is_marker => $2 eq '::' ? 1 : 0, tail => $3 }
}

sub _finish_member {
 my ($source_text, $rule, $member) = @_;
 return unless ref($rule) eq 'HASH' && ref($member) eq 'HASH';
 my $text = substr($source_text, $member->{start}, $member->{end} - $member->{start});
 my $regex = _leading_regex($text);
 my $edge = _edge_fields($text);
 my $lifecycle_marker;
 $lifecycle_marker = $1 if $text =~ /\A(?:\s*)(I|E|EX|IT|LX|LS|LE)\s*\{/s;
 push @{$rule->{members}}, {
  text => $text,
  range => { start => $member->{start}, end => $member->{end} },
  regex => $regex,
  edge => $edge,
  lifecycle_marker => $lifecycle_marker,
 };
 return
}

sub _leading_regex {
 my ($text) = @_;
 return undef unless $text =~ /\A\s*\/((?:\\.|[^\/])*)\/([A-Za-z]*)/s;
 return { pattern => $1, flags => $2 // '' }
}

sub _edge_fields {
 my ($text) = @_;
 if ($text =~ /(?:->|=>)\s*(\w+)(?:\s*\[\s*(\d+)\s*\])?/s) {
  return {
   target => $1,
   target_index => defined($2) ? 0 + $2 : undef,
   ownership => index($&, '->') >= 0 ? 'action' : 'blind',
  }
 }
 if ($text =~ /\A\s*(\w+)\b/s && $text !~ /\A\s*(?:I|E|EX|IT|LX|LS|LE)\s*\{/s) {
  return { target => $1, target_index => undef, ownership => undef }
 }
 return undef
}

sub _nesting_delta {
 my ($text) = @_;
 my ($delta, $quote, $escaped) = (0, undef, 0);
 my $length = length($text);
 for (my $index = 0; $index < $length; ++$index) {
  my $character = substr($text, $index, 1);
  if (defined $quote) {
   if ($escaped) {
    $escaped = 0;
   } elsif ($character eq '\\') {
    $escaped = 1;
   } elsif ($character eq $quote) {
    $quote = undef;
   }
   next;
  }
  if ($character eq q{'} || $character eq q{"}) {
   $quote = $character;
   next;
  }
  if ($character eq '/') {
   my $previous = $index == 0 ? '' : substr($text, 0, $index);
   $previous =~ s/\s+\z//;
   if (!length($previous) || substr($previous, -1) =~ /[\(\[=,:]/) {
    ++$index;
    while ($index < $length) {
     my $inner = substr($text, $index, 1);
     if ($inner eq '\\') {
      $index += 2;
      next;
     }
     last if $inner eq '/';
     ++$index;
    }
    next;
   }
  }
  ++$delta if $character eq '{' || $character eq '(' || $character eq '[';
  --$delta if $character eq '}' || $character eq ')' || $character eq ']';
 }
 return $delta
}

sub _header_facts {
 my ($header_text) = @_;
 my $parsed = _parse_header($header_text) || { is_marker => 0, tail => '' };
 my $tail = $parsed->{tail} // '';
 $tail =~ s/\A\s+//;
 my $mode = '';
 $mode = $1 if $tail =~ /\A(AND\s*\{[^}]+\}|OR\s*\{[^}]+\}|AND\+|OR\+|AND|OR|[&|+*?])/;
 my $compact = $mode;
 $compact =~ s/\s+//g;
 my $family = $compact =~ /\A(?:AND|&)/ ? 'and' : 'or';
 my ($rep_min, $rep_max);
 if ($compact eq '+' || $compact eq 'AND+' || $compact eq 'OR+') {
  ($rep_min, $rep_max) = (1, undef);
 } elsif ($compact eq '*') {
  ($rep_min, $rep_max) = (0, undef);
 } elsif ($compact eq '?') {
  ($rep_min, $rep_max) = (0, 1);
 } elsif ($compact =~ /\A(?:AND|OR)\{(\d+)\}\z/) {
  ($rep_min, $rep_max) = (0 + $1, 0 + $1);
 } elsif ($compact =~ /\A(?:AND|OR)\{(\d*),(\d*)\}\z/) {
  ($rep_min, $rep_max) = (length($1) ? 0 + $1 : 0, length($2) ? 0 + $2 : undef);
 }
 return {
  family => $family,
  cursor_policy => $family eq 'and' ? 'contiguous' : 'seek',
  is_entry_marker => $parsed->{is_marker} ? 1 : 0,
  is_repetition => defined($rep_min) || defined($rep_max) ? 1 : 0,
  rep_min => $rep_min,
  rep_max => $rep_max,
 }
}

sub _find_target_member {
 my ($section, $target) = @_;
 return undef unless ref($section) eq 'HASH';
 foreach my $member (@{$section->{members} || []}) {
  return $member if ref($member->{edge}) eq 'HASH'
   && defined($member->{edge}{target})
   && defined($target)
   && $member->{edge}{target} eq $target;
 }
 return undef
}

sub _first_marker {
 my ($definition_order, $scan) = @_;
 foreach my $label (@$definition_order) {
  my $section = $scan->{by_label}{$label};
  return $label if ref($section) eq 'HASH' && $section->{is_marker};
 }
 return undef
}

sub _neutral_bounds {
 my ($minimum, $maximum) = @_;
 $minimum = 0 + $minimum if defined $minimum;
 $maximum = undef if defined($maximum) && $maximum >= 1_000_000_000;
 $maximum = 0 + $maximum if defined $maximum;
 return ($minimum, $maximum)
}

sub _neutral_ownership {
 my ($ownership) = @_;
 return 'action' if defined($ownership) && $ownership eq 'action';
 return 'blind' if defined($ownership) && ($ownership eq 'blind' || $ownership eq 'blind_call');
 return 'none'
}

sub _rule_value_shape {
 my ($is_repetition, $edges, $lifecycles) = @_;
 my ($exit) = grep { $_->{marker} eq 'E' && $_->{value_shape}{kind} ne 'unknown' } @$lifecycles;
 return $exit->{value_shape} if ref($exit) eq 'HASH';
 my ($known_edge) = grep { $_->{value_shape}{kind} ne 'unknown' } @$edges;
 my $element = ref($known_edge) eq 'HASH' ? $known_edge->{value_shape} : _value_shape('unknown');
 return _array_shape($element) if $is_repetition;
 return $element
}

sub _infer_return_shape {
 my ($text) = @_;
 my $expression = _return_expression($text);
 return _value_shape('unknown') unless defined $expression;
 $expression =~ s/\A\s+|\s+\z//g;
 return _value_shape('string') if $expression =~ /\A(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*')\z/s;
 return _value_shape('null') if $expression =~ /\A(?:null|undef)\z/;
 return _value_shape('boolean') if $expression =~ /\A(?:true|false)\z/;
 return _value_shape('number') if $expression =~ /\A-?(?:\d+(?:\.\d*)?|\.\d+)\z/;
 if ($expression =~ /\A\[(.*)\]\z/s) {
  my $body = $1;
  return _array_shape(_value_shape('unknown')) unless $body =~ /\S/;
  return _array_shape(_value_shape('string')) if $body =~ /(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*')/s;
  return _array_shape(_value_shape('number')) if $body =~ /\A\s*-?(?:\d+(?:\.\d*)?|\.\d+)\s*(?:,|\z)/s;
  return _array_shape(_value_shape('unknown'));
 }
 return _value_shape('unknown')
}

sub _return_expression {
 my ($text) = @_;
 return undef unless defined $text;
 my $start;
 if ($text =~ /\breturn\s*\(/g) {
  $start = pos($text);
 } else {
  return undef;
 }
 my ($depth, $quote, $escaped) = (1, undef, 0);
 for (my $index = $start; $index < length($text); ++$index) {
  my $character = substr($text, $index, 1);
  if (defined $quote) {
   if ($escaped) {
    $escaped = 0;
   } elsif ($character eq '\\') {
    $escaped = 1;
   } elsif ($character eq $quote) {
    $quote = undef;
   }
   next;
  }
  if ($character eq q{'} || $character eq q{"}) {
   $quote = $character;
   next;
  }
  ++$depth if $character eq '(';
  if ($character eq ')') {
   --$depth;
   return substr($text, $start, $index - $start) if $depth == 0;
  }
 }
 return undef
}

sub _value_shape {
 my ($kind) = @_;
 return { kind => $kind, element => undef, key => undef, value => undef, signature => undef, members => [] }
}

sub _boolean {
 return $_[0] ? JSON::PP::true : JSON::PP::false
}

sub _array_shape {
 my ($element) = @_;
 my $shape = _value_shape('array');
 $shape->{element} = $element;
 return $shape
}

sub _target_shape {
 my ($kind) = @_;
 return _value_shape($kind)
}

sub _register_source {
 my ($source_refs, $key, $range, $args) = @_;
 return undef unless ref($range) eq 'HASH';
 my $start = $range->{start};
 my $end = $range->{end};
 return undef unless defined($start) && defined($end);
 $source_refs->{$key} = {
  source_id => 'source:0',
  logical_name => $args->{logical_name},
  span => $args->{source_map}->span_from_character_range($start, $end),
  excerpt => substr($args->{source_text}, $start, $end - $start),
  content_digest => $args->{content_digest},
  provenance_ids => [],
 };
 return $key
}

sub _source_record {
 return _record(
  id => 'source:0',
  kind => 'source',
  name => undef,
  owner_id => 'spec:0',
  order => 0,
  source => undef,
  facts => { logical_kind => 'spec', origin_kind => 'authored' },
 )
}

sub _record {
 my (%args) = @_;
 return {
  id => $args{id},
  kind => $args{kind},
  name => $args{name},
  owner_id => $args{owner_id},
  order => 0 + ($args{order} // 0),
  source => $args{source},
  facts => $args{facts},
  redactions => [],
 }
}

sub _relation {
 my ($kind, $from_id, $to_id, $order, $source, $evidence_ids) = @_;
 return {
  id => "relation:$kind:$from_id:$to_id:$order",
  kind => $kind,
  from_id => $from_id,
  to_id => $to_id,
  order => 0 + $order,
  source => $source,
  facts => {},
  evidence_ids => $evidence_ids,
 }
}

sub _canonicalize {
 my ($projection) = @_;
 my @records = sort {
  $RECORD_RANK{$a->{kind}} <=> $RECORD_RANK{$b->{kind}}
   || $a->{order} <=> $b->{order}
   || $a->{id} cmp $b->{id}
 } @{$projection->{records}};
 my %record_rank = map { $records[$_]{id} => $_ } 0 .. $#records;
 my @relations = sort {
  $record_rank{$a->{from_id}} <=> $record_rank{$b->{from_id}}
   || $RELATION_RANK{$a->{kind}} <=> $RELATION_RANK{$b->{kind}}
   || $record_rank{$a->{to_id}} <=> $record_rank{$b->{to_id}}
   || $a->{id} cmp $b->{id}
 } @{$projection->{relations}};
 return {
  snapshot => $projection->{snapshot},
  source_refs => $projection->{source_refs},
  records => \@records,
  relations => \@relations,
 }
}

sub _rule_id {
 my ($label) = @_;
 return 'rule:' . _escape_name($label)
}

sub _escape_name {
 my ($name) = @_;
 my $bytes = encode('UTF-8', $name, FB_CROAK | LEAVE_SRC);
 my $escaped = '';
 foreach my $byte (unpack('C*', $bytes)) {
  my $character = chr($byte);
  $escaped .= $character =~ /[A-Za-z0-9._~-]/ ? $character : sprintf('%%%02X', $byte);
 }
 return $escaped
}

sub _spec_name {
 my ($logical_name) = @_;
 my $name = "$logical_name";
 $name =~ s/\.spec\z//;
 return $name
}

1;

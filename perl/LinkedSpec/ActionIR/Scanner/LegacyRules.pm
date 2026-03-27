package LinkedSpec::ActionIR::Scanner::LegacyRules;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $action_ir_dir = File::Basename::dirname($module_dir);
 my $linked_spec_dir = File::Basename::dirname($action_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub try_scan_contract_ir_events {
 my ($id, $code) = @_;
 my %dispatch = (
  'call' => \&_scan_contract_call,
  'push_single_arg' => \&_scan_contract_push_single_arg,
  'push_target_arg' => \&_scan_contract_push_target_arg,
  'push_scope_target_arg' => \&_scan_contract_push_scope_target_arg,
  'return_a' => \&_scan_contract_return_a,
  'return_general' => \&_scan_contract_return_general,
  'return' => \&_scan_contract_return,
  'return_ma' => \&_scan_contract_return_ma,
  'return_m' => \&_scan_contract_return_m,
  'capture_macro' => \&_scan_contract_capture_macro,
  'capture' => \&_scan_contract_capture,
  'capture_if' => \&_scan_contract_capture_if,
  'capture_if_macro' => \&_scan_contract_capture_if_macro,
  'capture_from_rule_start' => \&_scan_contract_capture_from_rule_start,
  'capture_len_from_rule_start' => \&_scan_contract_capture_len_from_rule_start,
  'capture_from_mark' => \&_scan_contract_capture_from_mark,
  'capture_len_from_mark' => \&_scan_contract_capture_len_from_mark,
  'capture_take_from_mark' => \&_scan_contract_capture_take_from_mark,
  'capture_between_marks' => \&_scan_contract_capture_between_marks,
  'capture_len_between_marks' => \&_scan_contract_capture_len_between_marks,
  'capture_take_between_marks' => \&_scan_contract_capture_take_between_marks,
  'mark_here' => \&_scan_contract_mark_here,
  'mark_match_start' => \&_scan_contract_mark_match_start,
  'mark_copy' => \&_scan_contract_mark_copy,
  'clear_mark' => \&_scan_contract_clear_mark,
  'mark_exists' => \&_scan_contract_mark_exists,
  'mark_pos' => \&_scan_contract_mark_pos,
  'cursor_pos' => \&_scan_contract_cursor_pos,
  'cursor_line' => \&_scan_contract_cursor_line,
  'entry_text' => \&_scan_contract_entry_text,
  'entry_group' => \&_scan_contract_entry_group,
  'entry_groups' => \&_scan_contract_entry_groups,
  'entry_named' => \&_scan_contract_entry_named,
  'entry_has' => \&_scan_contract_entry_has,
  'entry_map' => \&_scan_contract_entry_map,
  'entry_named_map' => \&_scan_contract_entry_named_map,
  'entry_line' => \&_scan_contract_entry_line,
  'entry_len' => \&_scan_contract_entry_len,
  'entry_start_pos' => \&_scan_contract_entry_start_pos,
  'entry_end_pos' => \&_scan_contract_entry_end_pos,
  'match_line' => \&_scan_contract_match_line,
  'match_text' => \&_scan_contract_match_text,
  'match_group' => \&_scan_contract_match_group,
  'match_groups' => \&_scan_contract_match_groups,
  'match_named' => \&_scan_contract_match_named,
  'match_has' => \&_scan_contract_match_has,
  'match_map' => \&_scan_contract_match_map,
  'match_named_map' => \&_scan_contract_match_named_map,
  'match_len' => \&_scan_contract_match_len,
  'match_start_pos' => \&_scan_contract_match_start_pos,
  'match_end_pos' => \&_scan_contract_match_end_pos,
  'ibacktrack_macro' => \&_scan_contract_ibacktrack_macro,
  'backtrack_macro' => \&_scan_contract_backtrack_macro,
  'ibacktrack' => \&_scan_contract_ibacktrack,
  'backtrack' => \&_scan_contract_backtrack,
 );
 my $handler = $dispatch{$id};
 return undef unless $handler;
 return $handler->($code)
}

sub _scan_contract_call {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcall\s*\(\s*(?<callee>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {callee => $+{callee}}};
}
 return \@events
}

sub _scan_contract_push_single_arg {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s*\(\s*(?<source>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {source => $+{source}}};
}
 return \@events
}

sub _scan_contract_push_target_arg {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s*\(\s*(?<source>\w+)\s*,\s*(?<target>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {source => $+{source}, target => $+{target}}};
}
 return \@events
}

sub _scan_contract_push_scope_target_arg {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s*\(\s*(?<scope>\w+)\s*,\s*(?<source>\w+)\s*,\s*(?<target>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {scope => $+{scope}, source => $+{source}, target => $+{target}}};
}
 return \@events
}

sub _scan_contract_return_a {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn_a\s*\(\s*(?<label>\w+)(?:\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+))?\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
}
 return \@events
}

sub _scan_contract_return_general {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call && $call->{method} eq 'return';
 my $args = $call->{args} || [];
 next unless ref($args) eq 'ARRAY' && @$args == 1;
 push @events, {raw => $+{expr}, args => {payload => _trim_action_ir_value($args->[0])}};
}
 return \@events
}

sub _scan_contract_return {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn\s*\(\s*(?<label>\w+)\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
}
 return \@events
}

sub _scan_contract_return_ma {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn_ma\s*\(\s*(?<label>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}}};
}
 return \@events
}

sub _scan_contract_return_m {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn_m\s*\(\s*(?<label>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}}};
}
 return \@events
}

sub _scan_contract_capture_macro {
 my ($code) = @_;
 my @events;
while ($code =~ /\$CAPTURE\b/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_capture {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture\s*\(\s*(?<label>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}}};
}
 return \@events
}

sub _scan_contract_capture_if {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_if\s*\(\s*(?<label>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}}};
}
 return \@events
}

sub _scan_contract_capture_if_macro {
 my ($code) = @_;
 my @events;
while ($code =~ /\bCAPTURE_IF\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_capture_from_rule_start {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_from_rule_start\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_capture_len_from_rule_start {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_len_from_rule_start\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_capture_from_mark {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_from\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_capture_len_from_mark {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_len_from\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_capture_take_from_mark {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_take\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_capture_between_marks {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {start => $+{start}, end => $+{end}}};
}
 return \@events
}

sub _scan_contract_capture_len_between_marks {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_len_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {start => $+{start}, end => $+{end}}};
}
 return \@events
}

sub _scan_contract_capture_take_between_marks {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcapture_take_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {start => $+{start}, end => $+{end}}};
}
 return \@events
}

sub _scan_contract_mark_here {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmark_here\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_mark_match_start {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmark_match_start\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_mark_copy {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmark_copy\s*\(\s*(?<target>\w+)\s*,\s*(?<source>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {target => $+{target}, source => $+{source}}};
}
 return \@events
}

sub _scan_contract_clear_mark {
 my ($code) = @_;
 my @events;
while ($code =~ /\bclear_mark\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_mark_exists {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmark_exists\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_mark_pos {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmark_pos\s*\(\s*(?<mark>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {mark => $+{mark}}};
}
 return \@events
}

sub _scan_contract_cursor_pos {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcursor_pos\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_cursor_line {
 my ($code) = @_;
 my @events;
while ($code =~ /\bcursor_line\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_text {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_text\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_group {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_group\s*\(\s*(?<index>\d+)\s*\)/g) {
 push @events, {raw => $&, args => {index => $+{index}}};
}
 return \@events
}

sub _scan_contract_entry_groups {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_groups\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_named {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_named\s*\(\s*(?<name>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {name => $+{name}}};
}
 return \@events
}

sub _scan_contract_entry_has {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_has\s*\(\s*(?<name>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {name => $+{name}}};
}
 return \@events
}

sub _scan_contract_entry_map {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_map\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_named_map {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_named_map\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_line {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_line\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_len {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_len\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_start_pos {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_start_pos\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_entry_end_pos {
 my ($code) = @_;
 my @events;
while ($code =~ /\bentry_end_pos\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_text {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_text\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_group {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_group\s*\(\s*(?<index>\d+)\s*\)/g) {
 push @events, {raw => $&, args => {index => $+{index}}};
}
 return \@events
}

sub _scan_contract_match_groups {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_groups\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_named {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_named\s*\(\s*(?<name>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {name => $+{name}}};
}
 return \@events
}

sub _scan_contract_match_has {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_has\s*\(\s*(?<name>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {name => $+{name}}};
}
 return \@events
}

sub _scan_contract_match_map {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_map\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_named_map {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_named_map\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_len {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_len\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_start_pos {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_start_pos\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_end_pos {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_end_pos\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_match_line {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmatch_line\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_ibacktrack_macro {
 my ($code) = @_;
 my @events;
while ($code =~ /\bIBACKTRACK\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_backtrack_macro {
 my ($code) = @_;
 my @events;
while ($code =~ /\bBACKTRACK\s*\(\s*\)/g) {
 push @events, {raw => $&, args => {}};
}
 return \@events
}

sub _scan_contract_ibacktrack {
 my ($code) = @_;
 my @events;
while ($code =~ /\bibacktrack\s*\(\s*(?<label>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}}};
}
 return \@events
}

sub _scan_contract_backtrack {
 my ($code) = @_;
 my @events;
while ($code =~ /\bbacktrack\s*\(\s*(?<label>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {label => $+{label}}};
}
 return \@events
}

1;

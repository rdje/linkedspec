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
  'capture_from_mark' => \&_scan_contract_capture_from_mark,
  'capture_len_from_mark' => \&_scan_contract_capture_len_from_mark,
  'capture_take_from_mark' => \&_scan_contract_capture_take_from_mark,
  'capture_between_marks' => \&_scan_contract_capture_between_marks,
  'capture_take_between_marks' => \&_scan_contract_capture_take_between_marks,
  'mark_here' => \&_scan_contract_mark_here,
  'mark_match_start' => \&_scan_contract_mark_match_start,
  'clear_mark' => \&_scan_contract_clear_mark,
  'mark_exists' => \&_scan_contract_mark_exists,
  'mark_pos' => \&_scan_contract_mark_pos,
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

package LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $action_ir_dir = File::Basename::dirname($module_dir);
 my $linked_spec_dir = File::Basename::dirname($action_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::ActionIR::ScannerCore ();

sub try_scan_contract_ir_events {
 my ($id, $code) = @_;
 my %dispatch = (
  'assign_call_my' => \&_scan_contract_assign_call_my,
  'assign_call' => \&_scan_contract_assign_call,
  'push_child_call_indexed_builtin' => \&_scan_contract_push_child_call_indexed_builtin,
  'push_child_call_builtin' => \&_scan_contract_push_child_call_builtin,
  'return_call' => \&_scan_contract_return_call,
  'return_bare' => \&_scan_contract_return_bare,
  'exit_bare' => \&_scan_contract_exit_bare,
  'linecount_prefix_newline_matches' => \&_scan_contract_linecount_prefix_newline_matches,
  'print_capture_substr' => \&_scan_contract_print_capture_substr,
  'my_declare_bare' => \&_scan_contract_my_declare_bare,
  'assign_match_my' => \&_scan_contract_assign_match_my,
  'destructure_imatch_list_my' => \&_scan_contract_destructure_imatch_list_my,
  'regex_subst_assignment' => \&_scan_contract_regex_subst_assignment,
  'next_bare' => \&_scan_contract_next_bare,
  'ref_field_assign' => \&_scan_contract_ref_field_assign,
  'position_tracking' => \&_scan_contract_position_tracking,
  'entry_slot' => sub { _scan_contract_zero_arg_gap_helper('entry_slot', @_) },
  'gap_span' => sub { _scan_contract_zero_arg_gap_helper('gap_span', @_) },
  'gap_text' => sub { _scan_contract_zero_arg_gap_helper('gap_text', @_) },
  'gap_kind' => sub { _scan_contract_zero_arg_gap_helper('gap_kind', @_) },
 );
 my $handler = $dispatch{$id};
 return undef unless $handler;
 return $handler->($code)
}

sub _scan_contract_zero_arg_gap_helper {
 my ($name, $code) = @_;
 my @events;
 while ($code =~ /\b(?<expr>\Q$name\E\s*\(\s*\))/g) {
  my ($source_start, $source_end) = ($-[0], $+[0]);
  push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event(
   {raw => $+{expr}, args => {}}, $code, $source_start, $source_end);
 }
 return \@events
}

sub _scan_contract_assign_call_my {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmy\s+(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
 my ($source_start, $source_end) = ($-[0], $+[0]);
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event(
  {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'my'}},
  $code, $source_start, $source_end);
}
 return \@events
}

sub _scan_contract_assign_call {
 my ($code) = @_;
 my @events;
while ($code =~ /(?<!\bmy\s)(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
 my ($source_start, $source_end) = ($-[0], $+[0]);
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event(
  {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'existing'}},
  $code, $source_start, $source_end);
}
 return \@events
}

sub _scan_contract_push_child_call_indexed_builtin {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)\s*->\s*\[\s*(?<index>\d+)\s*\]/g) {
 my ($source_start, $source_end) = ($-[0], $+[0]);
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event(
  {raw => $&, args => {target => $+{target}, callee => $+{callee}, index => $+{index}}},
  $code, $source_start, $source_end);
}
 return \@events
}

sub _scan_contract_push_child_call_builtin {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)(?!\s*->\s*\[)/g) {
 my ($source_start, $source_end) = ($-[0], $+[0]);
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event(
  {raw => $&, args => {target => $+{target}, callee => $+{callee}}},
  $code, $source_start, $source_end);
}
 return \@events
}

sub _scan_contract_return_call {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn\s+call\s*\(\s*(?<callee>\w+)\s*\)/g) {
 my ($source_start, $source_end) = ($-[0], $+[0]);
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_scanned_source_event(
  {raw => $&, args => {callee => $+{callee}, context => 'return'}},
  $code, $source_start, $source_end);
}
 return \@events
}

sub _scan_contract_return_bare {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^return(?:\s+.+)?$/o;
 next if $trimmed =~ /^return\s*\(/o;
 next if $trimmed =~ /^return_/o;
 next if $trimmed =~ /^return\s+call\s*\(/o;
 my $payload = $trimmed;
 $payload =~ s/^return//o;
 $payload = _trim_action_ir_value($payload // '');
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {payload => $payload}}, $frame);
}
 return \@events
}

sub _scan_contract_exit_bare {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^exit(?:\b|(?=\())/o;
 my $payload = $trimmed;
 $payload =~ s/^exit//o;
 $payload = _trim_action_ir_value($payload // '');
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {payload => $payload}}, $frame);
}
 return \@events
}

sub _scan_contract_linecount_prefix_newline_matches {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+\@(?<target>\w+)\s*=\s*substr\(\s*\$\$STRING\s*,\s*0\s*,\s*(?<upto>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\)\s*=~\s*\/\\n\/g$/o;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {target => $+{target}, upto => _trim_action_ir_value($+{upto})}}, $frame);
}
 return \@events
}

sub _scan_contract_print_capture_substr {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^print\s*"<"\s*\.\s*substr\(\s*\$\$STRING\s*,\s*\$IPOS\s*,\s*\$LSPOS\s*-\s*\$IPOS\s*-\s*1\s*\)\s*\.\s*">\\n"\s*$/o;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {source => 'capture_substr'}}, $frame);
}
 return \@events
}

sub _scan_contract_my_declare_bare {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+(?<sigil>[\$\@\%])(?<name>\w+)$/o;
 my $declaration_type = $+{sigil} eq '$' ? 'scalar' : $+{sigil} eq '@' ? 'array' : 'hash';
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {declaration_type => $declaration_type, names => [$+{name}], scope => 'my'}}, $frame);
}
 return \@events
}

sub _scan_contract_assign_match_my {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+\$(?<target>\w+)\s*=\s*\$(?<source>CAPTURE|IMATCH|LMATCH)$/o;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {target => $+{target}, source => $+{source}, scope => 'my'}}, $frame);
}
 return \@events
}

sub _scan_contract_destructure_imatch_list_my {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s*\((?<targets>[^()]+)\)\s*=\s*\@IMATCH_LIST$/o;
 my @targets = grep { defined($_) && length($_) } map { _trim_action_ir_value($_) } split /\s*,\s*/o, $+{targets};
 next unless @targets;
 next if grep { $_ !~ /^\$\w+$/o } @targets;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({
  raw  => $trimmed,
  args => {
   targets => [map { my $name = $_; $name =~ s/^\$//o; $name } @targets],
   source  => 'IMATCH_LIST',
   scope   => 'my',
  },
 }, $frame);
}
 return \@events
}

sub _scan_contract_regex_subst_assignment {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^\$(?<target>\w+)\s*=~\s*s\/(?<pattern>(?:\\.|[^\/])*)\/(?<replacement>(?:\\.|[^\/])*)\/(?<flags>[a-z]*)$/o;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {target => $+{target}, pattern => '/'.$+{pattern}.'/', replacement => '/'.$+{replacement}.'/', flags => ($+{flags} // ''), scope => undef}}, $frame);
}
 return \@events
}

sub _scan_contract_next_bare {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^next\s+\w+$/o;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {}}, $frame);
}
 return \@events
}

sub _scan_contract_ref_field_assign {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^(?<decl>my\s+)?\$(?<target>\w+)\s*=\s*\$(?<source>\w+)\s*->\s*(?<path>(?:\{[^{}]+\}|\[[^\[\]]+\])(?:\s*(?:\{[^{}]+\}|\[[^\[\]]+\]))*)$/o;
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {target => $+{target}, source => $+{source}, path => _trim_action_ir_value($+{path}), scope => ($+{decl} ? 'my' : 'existing')}}, $frame);
}
 return \@events
}

sub _scan_contract_position_tracking {
 my ($code) = @_;
 my @events;
 my $framed = ref($LinkedSpec::ActionIR::ScannerCore::_source_event_recorder) eq 'CODE'
  ? LinkedSpec::ActionIR::ScannerCore::_split_scanner_statements_with_source_frames(\&_split_action_ir_statements, $code)
  : undef;
 my $statements = $framed ? $framed->{statements} : _split_action_ir_statements($code);
 my $statement_index = 0;
foreach my $statement (@$statements) {
 my $frame = $framed ? $framed->{source_frames}[$statement_index++] : undef;
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless (
  $trimmed =~ /^\$\w+\s*=\s*pos(?:\s*\(\s*\$\$STRING\s*\)|\s+\$\$STRING)\s*$/o ||
  $trimmed =~ /^my\s+\$\w+\s*=\s*\$IPOS\s*$/o ||
  $trimmed =~ /^my\s+\$shift\s*=\s*\$LSPOS\s*-\s*\$last_pos\s*-\s*length(?:\s*\(\s*\$LMATCH\s*\)|\s+\$LMATCH)\s*$/o ||
  $trimmed =~ /^push\s+\@\w+\s*,\s*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)\s*if\s*\$shift\s*$/o ||
  $trimmed =~ /^push\s+\@\w+\s*,\s*\{[^{}]*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)[^{}]*\}\s*if\s*\$shift\s*$/o
 );
 push @events, LinkedSpec::ActionIR::ScannerCore::_record_statement_source_event({raw => $trimmed, args => {category => 'position_tracking'}}, $frame);
}
 return \@events
}

1;

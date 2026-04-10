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
 );
 my $handler = $dispatch{$id};
 return undef unless $handler;
 return $handler->($code)
}

sub _scan_contract_assign_call_my {
 my ($code) = @_;
 my @events;
while ($code =~ /\bmy\s+(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'my'}};
}
 return \@events
}

sub _scan_contract_assign_call {
 my ($code) = @_;
 my @events;
while ($code =~ /(?<!\bmy\s)(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'existing'}};
}
 return \@events
}

sub _scan_contract_push_child_call_indexed_builtin {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)\s*->\s*\[\s*(?<index>\d+)\s*\]/g) {
 push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, index => $+{index}}};
}
 return \@events
}

sub _scan_contract_push_child_call_builtin {
 my ($code) = @_;
 my @events;
while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)(?!\s*->\s*\[)/g) {
 push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}}};
}
 return \@events
}

sub _scan_contract_return_call {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn\s+call\s*\(\s*(?<callee>\w+)\s*\)/g) {
 push @events, {raw => $&, args => {callee => $+{callee}, context => 'return'}};
}
 return \@events
}

sub _scan_contract_return_bare {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^return(?:\s+.+)?$/o;
 next if $trimmed =~ /^return\s*\(/o;
 next if $trimmed =~ /^return_/o;
 next if $trimmed =~ /^return\s+call\s*\(/o;
 my $payload = $trimmed;
 $payload =~ s/^return//o;
 $payload = _trim_action_ir_value($payload // '');
 push @events, {raw => $trimmed, args => {payload => $payload}};
}
 return \@events
}

sub _scan_contract_exit_bare {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^exit(?:\b|(?=\())/o;
 my $payload = $trimmed;
 $payload =~ s/^exit//o;
 $payload = _trim_action_ir_value($payload // '');
 push @events, {raw => $trimmed, args => {payload => $payload}};
}
 return \@events
}

sub _scan_contract_linecount_prefix_newline_matches {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+\@(?<target>\w+)\s*=\s*substr\(\s*\$\$STRING\s*,\s*0\s*,\s*(?<upto>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\)\s*=~\s*\/\\n\/g$/o;
 push @events, {raw => $trimmed, args => {target => $+{target}, upto => _trim_action_ir_value($+{upto})}};
}
 return \@events
}

sub _scan_contract_print_capture_substr {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^print\s*"<"\s*\.\s*substr\(\s*\$\$STRING\s*,\s*\$IPOS\s*,\s*\$LSPOS\s*-\s*\$IPOS\s*-\s*1\s*\)\s*\.\s*">\\n"\s*$/o;
 push @events, {raw => $trimmed, args => {source => 'capture_substr'}};
}
 return \@events
}

sub _scan_contract_my_declare_bare {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+(?<sigil>[\$\@\%])(?<name>\w+)$/o;
 my $declaration_type = $+{sigil} eq '$' ? 'scalar' : $+{sigil} eq '@' ? 'array' : 'hash';
 push @events, {raw => $trimmed, args => {declaration_type => $declaration_type, names => [$+{name}], scope => 'my'}};
}
 return \@events
}

sub _scan_contract_assign_match_my {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+\$(?<target>\w+)\s*=\s*\$(?<source>CAPTURE|IMATCH|LMATCH)$/o;
 push @events, {raw => $trimmed, args => {target => $+{target}, source => $+{source}, scope => 'my'}};
}
 return \@events
}

sub _scan_contract_destructure_imatch_list_my {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s*\((?<targets>[^()]+)\)\s*=\s*\@IMATCH_LIST$/o;
 my @targets = grep { defined($_) && length($_) } map { _trim_action_ir_value($_) } split /\s*,\s*/o, $+{targets};
 next unless @targets;
 next if grep { $_ !~ /^\$\w+$/o } @targets;
 push @events, {
  raw  => $trimmed,
  args => {
   targets => [map { my $name = $_; $name =~ s/^\$//o; $name } @targets],
   source  => 'IMATCH_LIST',
   scope   => 'my',
  },
 };
}
 return \@events
}

sub _scan_contract_regex_subst_assignment {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^\$(?<target>\w+)\s*=~\s*s\/(?<pattern>(?:\\.|[^\/])*)\/(?<replacement>(?:\\.|[^\/])*)\/(?<flags>[a-z]*)$/o;
 push @events, {raw => $trimmed, args => {target => $+{target}, pattern => '/'.$+{pattern}.'/', replacement => '/'.$+{replacement}.'/', flags => ($+{flags} // ''), scope => undef}};
}
 return \@events
}

sub _scan_contract_next_bare {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^next(?:\s+\w+)?$/o;
 push @events, {raw => $trimmed, args => {}};
}
 return \@events
}

sub _scan_contract_ref_field_assign {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^(?<decl>my\s+)?\$(?<target>\w+)\s*=\s*\$(?<source>\w+)\s*->\s*(?<path>(?:\{[^{}]+\}|\[[^\[\]]+\])(?:\s*(?:\{[^{}]+\}|\[[^\[\]]+\]))*)$/o;
 push @events, {raw => $trimmed, args => {target => $+{target}, source => $+{source}, path => _trim_action_ir_value($+{path}), scope => ($+{decl} ? 'my' : 'existing')}};
}
 return \@events
}

sub _scan_contract_position_tracking {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless (
  $trimmed =~ /^\$\w+\s*=\s*pos(?:\s*\(\s*\$\$STRING\s*\)|\s+\$\$STRING)\s*$/o ||
  $trimmed =~ /^my\s+\$\w+\s*=\s*\$IPOS\s*$/o ||
  $trimmed =~ /^my\s+\$shift\s*=\s*\$LSPOS\s*-\s*\$last_pos\s*-\s*length(?:\s*\(\s*\$LMATCH\s*\)|\s+\$LMATCH)\s*$/o ||
  $trimmed =~ /^push\s+\@\w+\s*,\s*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)\s*if\s*\$shift\s*$/o ||
  $trimmed =~ /^push\s+\@\w+\s*,\s*\{[^{}]*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)[^{}]*\}\s*if\s*\$shift\s*$/o
 );
 push @events, {raw => $trimmed, args => {category => 'position_tracking'}};
}
 return \@events
}

1;

package LinkedSpec::Trace;

use 5.010;

# UVM-style verbosity levels
use constant {
 DUMP_NONE   => 0,    # No dumps
 DUMP_LOW    => 100,  # Essential dumps only (errors, final results)
 DUMP_MEDIUM => 200,  # Standard dumps (parse results, generated spec)
 DUMP_HIGH   => 300,  # Detailed dumps (rule info, handlers)
 DUMP_FULL   => 400,  # Very detailed dumps (DSL transformations)
 DUMP_DEBUG  => 500   # Maximum detail (everything)
};

our $DUMP_VERBOSITY = DUMP_NONE;
our $TRACE_LOG_FILE;
our $TRACE_LOG_MODE = 'stdout'; # stdout | route | mirror
our $TRACE_EMOJI = 0;
our $TRACE_INDENT_LEVEL = 0;
our $TRACE_INDENT_WIDTH = 2;
our $TRACE_TOPIC_SPACING = 1;
our $TRACE_INITIALIZED = 0;

sub _require_data_dumper_pkg {
 require Data::Dumper;
 return 1
}

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

sub _trace_trim {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s+|\s+$//go;
 return $value
}

sub _trace_truthy {
 my ($value) = @_;
 return 0 unless defined $value;
 return 1 if $value =~ /^(?:1|true|yes|on)$/io;
 return 0 if $value =~ /^(?:0|false|no|off)$/io;
 return $value ? 1 : 0
}

sub _trace_parse_level {
 my ($level) = @_;
 return undef unless defined $level;
 return int($level) if !ref($level) && $level =~ /^-?\d+$/o;

 my $name = lc(_trace_trim($level) // '');
 return DUMP_NONE   if $name eq 'none' || $name eq 'quiet';
 return DUMP_LOW    if $name eq 'low';
 return DUMP_MEDIUM if $name eq 'medium' || $name eq 'med';
 return DUMP_HIGH   if $name eq 'high';
 return DUMP_FULL   if $name eq 'full';
 return DUMP_DEBUG  if $name eq 'debug' || $name eq 'verbose';
 return undef
}

sub _trace_level_name {
 my ($level) = @_;
 return 'none'   if !defined($level) || $level <= DUMP_NONE;
 return 'low'    if $level <= DUMP_LOW;
 return 'medium' if $level <= DUMP_MEDIUM;
 return 'high'   if $level <= DUMP_HIGH;
 return 'full'   if $level <= DUMP_FULL;
 return 'debug'
}

sub _trace_emoji_prefix {
 my ($level) = @_;
 return '' unless $TRACE_EMOJI;
 return "\x{1F6D1} " if $level <= DUMP_NONE;
 return "\x{2139}\x{FE0F} " if $level <= DUMP_LOW;
 return "\x{1F50E} " if $level <= DUMP_MEDIUM;
 return "\x{1F9ED} " if $level <= DUMP_HIGH;
 return "\x{1F41E} " if $level <= DUMP_FULL;
 return "\x{1F525} "
}

sub _trace_stringify {
 my ($value) = @_;
 return undef unless defined $value;
 return $value unless ref($value);

 return _call_preserving_err(sub {
  _require_data_dumper_pkg();
  local $Data::Dumper::Terse = 1;
  local $Data::Dumper::Indent = 0;
  local $Data::Dumper::Sortkeys = 1;
  my $dump = Data::Dumper::Dumper($value);
  $dump =~ s/\s+$//o;
  return $dump
 })
}

sub _trace_timestamp {
 my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
 return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year + 1900, $mon + 1, $mday, $hour, $min, $sec)
}

sub _trace_visible_char {
 my ($ch) = @_;
 return ('\\n', 2) if defined($ch) && $ch eq "\n";
 return ('\\r', 2) if defined($ch) && $ch eq "\r";
 return ('\\t', 2) if defined($ch) && $ch eq "\t";
 return ('\\0', 2) if defined($ch) && $ch eq "\0";
 my $ord = defined($ch) ? ord($ch) : 0;
 if (!defined($ch) || $ord < 32 || $ord == 127) {
  my $visible = sprintf('\\x{%02X}', $ord);
  return ($visible, length($visible))
 }
 return ($ch, 1)
}

sub _trace_mark_excerpt {
 my (%args) = @_;
 my $string_ref = $args{string_ref};
 return undef unless ref($string_ref) eq 'SCALAR';

 my $string = defined($$string_ref) ? $$string_ref : '';
 my $len = length($string);
 my $mark_pos = defined($args{mark_pos}) ? int($args{mark_pos}) : 0;
 $mark_pos = 0 if $mark_pos < 0;
 $mark_pos = $len if $mark_pos > $len;

 my $radius = defined($args{radius}) && $args{radius} =~ /^\d+$/o ? $args{radius} : 24;
 my $start = $mark_pos - $radius;
 $start = 0 if $start < 0;
 my $end = $mark_pos + $radius;
 $end = $len if $end > $len;

 my $raw_excerpt = substr($string, $start, $end - $start);
 my $excerpt = '';
 my $caret_col = 0;

 if ($start > 0) {
  $excerpt .= '...';
  $caret_col += 3;
 }

 for (my $i = 0; $i < length($raw_excerpt); ++$i) {
  my $ch = substr($raw_excerpt, $i, 1);
  my ($visible, $visible_width) = _trace_visible_char($ch);
  $caret_col += $visible_width if ($start + $i) < $mark_pos;
  $excerpt .= $visible;
 }

 $excerpt .= '...' if $end < $len;

 return "input: $excerpt\nmark : ".(' ' x $caret_col)."^ pos=$mark_pos"
}

sub _trace_location {
 my ($caller_depth) = @_;
 my $depth = defined($caller_depth) ? $caller_depth : 1;
 my (undef, $file, $line, $subname) = caller($depth);
 while (defined($file) && $file =~ /LinkedSpec[\\\/]Trace\.pm$/o && $depth < 64) {
  ++$depth;
  (undef, $file, $line, $subname) = caller($depth);
 }
 $file ||= '<unknown>';
 $file =~ s{.*[\\\/]}{}o;
 $subname ||= '<anon>';
 $subname =~ s/.*:://o;
 $line ||= 0;
 return ($file, $subname, $line)
}

sub _trace_build_prefix {
 my ($level, $caller_depth, $tag) = @_;
 my $timestamp = _trace_timestamp();
 my ($file, $subname, $line) = _trace_location($caller_depth);
 my $lvl_name = uc(_trace_level_name($level));
 my $indent = ' ' x ($TRACE_INDENT_LEVEL * $TRACE_INDENT_WIDTH);
 my $emoji = _trace_emoji_prefix($level);
 my $tag_prefix = defined($tag) && length($tag) ? "[$tag]" : '';
 return '['.$timestamp.']['.$lvl_name.']'.$tag_prefix.'['.$file.']['.$subname.':'.$line.'] '.$indent.$emoji
}

sub _trace_write_raw {
 my ($payload) = @_;
 return unless defined $payload;

 my $path = defined($TRACE_LOG_FILE) && length($TRACE_LOG_FILE)
  ? $TRACE_LOG_FILE
  : (defined($main::LOG_FILE) && length($main::LOG_FILE) ? $main::LOG_FILE : undef);

 my $mode = $TRACE_LOG_MODE || 'stdout';
 if ((!defined($TRACE_LOG_FILE) || !length($TRACE_LOG_FILE)) && defined($main::LOG_FILE) && length($main::LOG_FILE) && $mode eq 'stdout') {
  $mode = 'mirror';
 }

 print $payload unless $mode eq 'route';

 if (defined($path) && length($path) && ($mode eq 'route' || $mode eq 'mirror')) {
  if (open(my $log_fh, '>>', $path)) {
   print $log_fh $payload;
   close($log_fh);
  }
 }
}

sub _trace_emit {
 my (%args) = @_;
 my $level = $args{level};
 my $message = defined($args{message}) ? $args{message} : '';
 my $context = $args{context};
 my $caller_depth = defined($args{caller_depth}) ? $args{caller_depth} : 1;
 my $tag = $args{tag};
 my $prefix = _trace_build_prefix($level, $caller_depth, $tag);

 my @lines = split(/\n/, $message, -1);
 @lines = ('') unless @lines;

 my $payload = '';
 foreach my $line (@lines) {
  $payload .= $prefix.$line."\n";
 }

 if (defined $context) {
  my $ctx_txt = _trace_stringify($context);
  my @ctx_lines = split(/\n/, $ctx_txt // '', -1);
  @ctx_lines = ('') unless @ctx_lines;
  foreach my $line (@ctx_lines) {
   $payload .= $prefix.'  Context: '.$line."\n";
  }
 }

 _trace_write_raw($payload);
 return undef
}

sub _trace_initialize {
 return if $TRACE_INITIALIZED;

 my $env_level = _trace_parse_level($ENV{LINKEDSPEC_TRACE_LEVEL});
 $env_level = _trace_parse_level($ENV{LINKEDSPEC_DUMP_VERBOSITY}) unless defined $env_level;
 $DUMP_VERBOSITY = $env_level if defined $env_level;

 $TRACE_EMOJI = _trace_truthy($ENV{LINKEDSPEC_TRACE_EMOJI}) if exists $ENV{LINKEDSPEC_TRACE_EMOJI};

 if (exists $ENV{LINKEDSPEC_TRACE_FILE}) {
  my $trace_file = _trace_trim($ENV{LINKEDSPEC_TRACE_FILE});
  $TRACE_LOG_FILE = (defined($trace_file) && length($trace_file)) ? $trace_file : undef;
  $TRACE_LOG_MODE = _trace_truthy($ENV{LINKEDSPEC_TRACE_MIRROR_STDOUT}) ? 'mirror' : 'route';
 }

 if ((!defined($TRACE_LOG_FILE) || !length($TRACE_LOG_FILE)) && defined($main::LOG_FILE) && length($main::LOG_FILE)) {
  $TRACE_LOG_FILE = $main::LOG_FILE;
  $TRACE_LOG_MODE = 'mirror' if $TRACE_LOG_MODE eq 'stdout';
 }

 if (_trace_truthy($ENV{LINKEDSPEC_TRACE_RESET_FILE}) && defined($TRACE_LOG_FILE) && length($TRACE_LOG_FILE)) {
  if (open(my $reset_fh, '>', $TRACE_LOG_FILE)) {
   close($reset_fh);
  }
 }

 $TRACE_INITIALIZED = 1;
 return undef
}

sub configure_trace {
 my (%opts) = @_;
 _trace_initialize();

 my $level_candidate =
    exists($opts{trace_level})     ? $opts{trace_level}
  : exists($opts{dump_verbosity})  ? $opts{dump_verbosity}
  : exists($opts{DUMP_VERBOSITY})  ? $opts{DUMP_VERBOSITY}
  : undef;
 my $parsed_level = _trace_parse_level($level_candidate);
 $DUMP_VERBOSITY = $parsed_level if defined $parsed_level;
 $DUMP_VERBOSITY = DUMP_DEBUG if exists($opts{debug}) && _trace_truthy($opts{debug});
 $DUMP_VERBOSITY = DUMP_NONE  if exists($opts{quiet}) && _trace_truthy($opts{quiet});

 if (exists $opts{trace_emoji}) {
  $TRACE_EMOJI = _trace_truthy($opts{trace_emoji}) ? 1 : 0;
 }

 if (exists $opts{trace_indent_width} && defined $opts{trace_indent_width} && $opts{trace_indent_width} =~ /^\d+$/o) {
  $TRACE_INDENT_WIDTH = $opts{trace_indent_width};
 }

 if (exists $opts{trace_topic_spacing}) {
  $TRACE_TOPIC_SPACING = _trace_truthy($opts{trace_topic_spacing}) ? 1 : 0;
 }

 if (exists $opts{trace_log_file}) {
  my $trace_file = _trace_trim($opts{trace_log_file});
  if (defined($trace_file) && length($trace_file)) {
   $TRACE_LOG_FILE = $trace_file;
   $TRACE_LOG_MODE = 'route' unless exists $opts{trace_log_mode};
  } else {
   $TRACE_LOG_FILE = undef;
   $TRACE_LOG_MODE = 'stdout' unless exists $opts{trace_log_mode};
  }
 }

 if (exists $opts{trace_log_mode}) {
  my $mode = lc(_trace_trim($opts{trace_log_mode}) // '');
  $mode = 'stdout' unless $mode eq 'route' || $mode eq 'mirror' || $mode eq 'stdout';
  $TRACE_LOG_MODE = $mode;
 }

 if (exists $opts{trace_reset_log} && _trace_truthy($opts{trace_reset_log}) && defined($TRACE_LOG_FILE) && length($TRACE_LOG_FILE)) {
  if (open(my $reset_fh, '>', $TRACE_LOG_FILE)) {
   close($reset_fh);
  }
 }

 return {
  trace_level      => _trace_level_name($DUMP_VERBOSITY),
  dump_verbosity   => $DUMP_VERBOSITY,
  trace_log_file   => $TRACE_LOG_FILE,
  trace_log_mode   => $TRACE_LOG_MODE,
  trace_emoji      => $TRACE_EMOJI ? 1 : 0,
  trace_indent     => $TRACE_INDENT_LEVEL,
  trace_indent_width => $TRACE_INDENT_WIDTH,
  trace_topic_spacing => $TRACE_TOPIC_SPACING ? 1 : 0,
 }
}

sub _apply_trace_options {
 my ($option) = @_;
 return unless ref($option) eq 'HASH';
 my %trace_opts;
 foreach my $key (qw/
  trace_level
  dump_verbosity
  DUMP_VERBOSITY
  trace_emoji
  trace_indent_width
  trace_topic_spacing
  trace_log_file
  trace_log_mode
  trace_reset_log
  debug
  quiet
 /) {
  $trace_opts{$key} = $option->{$key} if exists $option->{$key};
 }
 configure_trace(%trace_opts) if %trace_opts;
 return undef
}

sub trace_enter {
 my ($topic, $details, $level) = @_;
 _trace_initialize();
 $level = DUMP_HIGH unless defined $level;
 $level = _trace_parse_level($level) // DUMP_HIGH;

 my $scope = {
  topic  => defined($topic) ? $topic : '<scope>',
  level  => $level,
  active => 0,
 };

 return $scope unless should_dump($level);

 _trace_write_raw("\n") if $TRACE_TOPIC_SPACING;
 my $ctx = _trace_stringify($details);
 log_output($level, "ENTER $scope->{topic}", $ctx, { caller_depth => 2 });
 ++$TRACE_INDENT_LEVEL;
 $scope->{active} = 1;
 return $scope
}

sub trace_exit {
 my ($scope, $details, $level) = @_;
 return undef unless $scope && ref($scope) eq 'HASH';
 return undef unless $scope->{active};

 my $effective_level = defined($level) ? (_trace_parse_level($level) // $scope->{level}) : $scope->{level};
 $TRACE_INDENT_LEVEL-- if $TRACE_INDENT_LEVEL > 0;
 my $ctx = _trace_stringify($details);
 log_output($effective_level, "EXIT $scope->{topic}", $ctx, { caller_depth => 2 });
 _trace_write_raw("\n") if $TRACE_TOPIC_SPACING;
 $scope->{active} = 0;
 return undef
}

sub trace_decision {
 my ($decision_name, $taken, $reason, $level) = @_;
 _trace_initialize();
 $level = DUMP_DEBUG unless defined $level;
 $level = _trace_parse_level($level) // DUMP_DEBUG;
 my $status = $taken ? 'TAKEN' : 'SKIPPED';
 log_output($level, 'DECISION '.($decision_name // '<decision>')." => $status", $reason, { caller_depth => 2 });
 return $taken ? 1 : 0
}

sub trace_mark_event {
 my (%args) = @_;
 _trace_initialize();

 my $level = exists($args{level}) ? (_trace_parse_level($args{level}) // DUMP_HIGH) : DUMP_HIGH;
 return undef unless should_dump($level);

 my $operation = defined($args{operation}) && length($args{operation}) ? $args{operation} : 'mark';
 my $mark_name = defined($args{mark_name}) && length($args{mark_name}) ? $args{mark_name} : '<mark>';
 my $mark_pos = defined($args{mark_pos}) ? int($args{mark_pos}) : undef;

 my $message = 'MARK '.$operation.'('.$mark_name.')';
 $message .= " => pos=$mark_pos" if defined $mark_pos;

 my @context;
 push @context, 'rule=' . $args{rule_label} if defined($args{rule_label}) && length($args{rule_label});
 push @context, 'match_left_edge=' . $args{left_edge} if defined $args{left_edge};
 push @context, 'parser_pos=' . $args{parser_pos} if defined $args{parser_pos};
 my $excerpt = _trace_mark_excerpt(%args);
 push @context, $excerpt if defined $excerpt && length $excerpt;

 my $caller_depth = defined($args{caller_depth}) ? $args{caller_depth} : 2;
 log_output($level, $message, @context ? join("\n", @context) : undef, { caller_depth => $caller_depth });
 return $mark_pos
}

sub log_output {
 my ($level, $message, $context, $opts) = @_;
 _trace_initialize();
 $level = DUMP_NONE unless defined $level;
 $level = _trace_parse_level($level) // DUMP_NONE;
 return if $level > $DUMP_VERBOSITY;

 my $caller_depth = 1;
 if (ref($opts) eq 'HASH' && exists $opts->{caller_depth}) {
  $caller_depth = $opts->{caller_depth};
 }

 _trace_emit(
  level => $level,
  message => $message,
  context => $context,
  caller_depth => $caller_depth,
 );
 return undef
}

sub log_dump {
 my ($message, $opts) = @_;
 _trace_initialize();

 my $level = DUMP_DEBUG;
 if (ref($opts) eq 'HASH' && exists($opts->{level})) {
  $level = _trace_parse_level($opts->{level}) // DUMP_DEBUG;
 }
 if (ref($opts) eq 'HASH' && $opts->{enforce_level}) {
  return if $level > $DUMP_VERBOSITY;
 }

 my $caller_depth = 1;
 if (ref($opts) eq 'HASH' && exists $opts->{caller_depth}) {
  $caller_depth = $opts->{caller_depth};
 }

 _trace_emit(
  level => $level,
  message => $message,
  caller_depth => $caller_depth,
  tag => 'DUMP',
 );
 return undef
}

sub should_dump {
 my ($level) = @_;
 _trace_initialize();
 $level = DUMP_NONE unless defined $level;
 $level = _trace_parse_level($level) // DUMP_NONE;
 return $DUMP_VERBOSITY >= $level
}

1;

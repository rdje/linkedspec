use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.1.10 — finite capture/mark Number source intake.
$| = 1;
my @cases = (
 ['producers', q{return([capture_len_between(begin,finish),capture_rest_len_from(begin),mark_pos(finish),mark_line(finish),mark_col(finish),capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_rest_len()])}],
 ['named_bridge', q{n=capture_len_between(begin,finish);p=mark_pos(finish);a=capture_rest_len();return([n.coalesce(0).add(1),p.coalesce(0).sub(1),a.coalesce(0).cat("!")])}],
 ['length_bridge', q{return(capture_len_between(begin,finish).coalesce(0).add(1))}],
 ['mark_bridge', q{return(mark_pos(finish).coalesce(0).sub(1))}],
 ['anonymous_bridge', q{return(capture_rest_len().coalesce(0).cat("!"))}],
 ['missing_bridge', q{return([capture_len_between(absent,finish).coalesce(7).add(1),mark_pos(absent).coalesce(0).add(2)])}],
 ['anonymous_calibration', q{order="";raw=[capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len(),capture_slice_length(),capture_len_from_rule_start(),capture_rest_length()];width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();return([raw,snapshot,capture_slice_pos(),order])}],
);

sub diagnostic {
 my ($error) = @_;
 return undef unless defined($error) && (ref($error) || length($error));
 return {map {$_ => $error->{$_}}
  grep {exists $error->{$_}} qw(type stage code detail summary helper_name name)}
  if (reftype($error) // '') eq 'HASH';
 return "$error";
}
my @rows;
my $sequence = 0;
for my $case (@cases) {
 next if @ARGV && !grep {$_ eq $case->[0]} @ARGV;
 my ($id, $body) = @$case;
 my $action = 'mark_input_start(begin);mark_input_end(finish);' . $body;
 my $source = "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>..)/\n /:/\n /cat/\n -> Value[2] {$action}\n";
 my %context;
 my $parser = eval {LinkedSpec::Get(\$source, runtime_ctx_ref => \%context)};
 my $error = $@ || $context{last_error};
 my $native;
 if (ref($parser) eq 'CODE') {
  my $input = "\x{03b1}\x{03b2}:cat";
  $native = eval {$parser->(\$input)};
  $error = $@ || $context{last_error};
 }
 my $descriptor = eval {LinkedSpec::Get(\$source, return_descriptor => 1)};
 my $descriptor_error = $@;
 my $meta = $descriptor->{spec}{Value}{meta}{action_rewriter};
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'capture-number-results.spec')};
 my $emission_error = $@;
 my $package = 'LinkedSpec::CaptureNumberFlow' . ++$sequence;
 my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
 my $load_error = $@;
 my ($fresh, $fresh_error);
 if ($loaded) {
  my $input = "\x{03b1}\x{03b2}:cat";
  no strict 'refs';
  $fresh = eval {&{$package . '::Execute'}(\$input)};
  $fresh_error = $@;
 }
 push @rows, {
  id => $id, source => $source, native => $native, error => diagnostic($error),
  fresh => $fresh, loaded => $loaded ? 1 : 0,
  emission_error => diagnostic($emission_error), load_error => diagnostic($load_error),
  fresh_error => diagnostic($fresh_error), descriptor_error => diagnostic($descriptor_error),
  metadata => {map {$_ => $meta->{$_}} qw(raw_perl_dependency_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)},
  substitution => LinkedSpec::call_spec_handler_subst('Value', $action),
 };
}
print JSON::PP->new->canonical->encode({
 scope => 'six finite capture/mark Number source distinctions and separate readonly/alias/bound-snapshot producer calibration; no frozen new semantics, implementation or completeness claim',
 cases => \@rows,
}), "\n";

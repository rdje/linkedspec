use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.1.8: six finite ordinary scalar-source distinctions.
my @cases = (
 ['producers', q{return([entry_text(),entry_group(0),entry_named("head"),match_text(),match_group(0),match_named("value"),entry_len(),match_len(),entry_start_pos(),entry_end_pos(),match_start_pos(),match_end_pos(),entry_line(),entry_col(),match_end_line(),match_end_col()])}],
 ['text_defaults', q{return([entry_text().coalesce("x").split(/a/)[-1].uppercase(),match_text().coalesce("x").split(/l/)[-1].uppercase(),entry_group(9).coalesce("missing").uppercase(),match_named("absent").coalesce("fallback").split(/a/)[-1].uppercase()])}],
 ['number_defaults', q{return([entry_len().coalesce(0).add(1),match_len().coalesce(0).cat("!"),entry_start_pos().coalesce(0).add(1),match_end_col().coalesce(0).sub(1)])}],
 ['named_number_control', q{a=entry_len();b=match_len();c=entry_start_pos();d=match_end_col();return([a.coalesce(0).add(1),b.coalesce(0).cat("!"),c.coalesce(0).add(1),d.coalesce(0).sub(1)])}],
 ['with_actual_kinds', q{value="outer";a=entry_text().with(){return(["a","b"])}.last().uppercase();b=match_len().with(){return({"n":[false]})}.sorted_values().first().first();return([a,b,value])}],
 ['normalized_result_guards', q{order="";a=entry_text().coalesce("x").take({order=cat(order,"A");1});b=match_len().coalesce(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([a,b,order])}],
);
push @cases,
 ['numeric_entry_len', q{return(entry_len().coalesce(0).add(1))}],
 ['numeric_match_end_col', q{return(match_end_col().coalesce(0).sub(1))}],
 ['with_entry_hash', q{value="outer";result=entry_text().with(){return({"n":[false]})}.sorted_values().first().first();return([result,value])}],
 ['with_literal_hash', q{value="outer";result="a".with(){return({"n":[false]})}.sorted_values().first().first();return([result,value])}],
 ['with_bound_hash', q{value="outer";text="a";result=text.with(){return({"n":[false]})}.sorted_values().first().first();return([result,value])}];

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
 my ($id, $action) = @$case;
 my $source = "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n";
 my %context;
 my $parser = eval {LinkedSpec::Get(\$source, runtime_ctx_ref => \%context)};
 my $error = $@ || $context{last_error};
 my $native;
 if (ref($parser) eq 'CODE') {
  my $input = 'name=Alpha';
  $native = eval {$parser->(\$input)};
  $error = $@ || $context{last_error};
 }
 my $descriptor = eval {LinkedSpec::Get(\$source, return_descriptor => 1)};
 my $descriptor_error = $@;
 my $meta = $descriptor->{spec}{Value}{meta}{action_rewriter};
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'entry-match-scalar-flow.spec')};
 my $emission_error = $@;
 my $package = 'LinkedSpec::EntryMatchScalarFlow' . ++$sequence;
 my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
 my $load_error = $@;
 my ($fresh, $fresh_error);
 if ($loaded) {
  my $input = 'name=Alpha';
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
 scope => 'six authored ordinary entry/match scalar producer/default/with/normalized-prefix distinctions; no legacy first-consumer reinterpretation or complete population claim',
 cases => \@rows,
}), "\n";

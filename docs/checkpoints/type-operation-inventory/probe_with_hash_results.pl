use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.31.0 — ordinary eager with result distinctions.
my @cases = (
 ['literal_hash', q{return("a".with(){return({"n":[false]})}.sorted_values().first().first())}],
 ['bound_hash', q{text="a";return(text.with(){return({"n":[false]})}.sorted_values().first().first())}],
 ['capture_hash', q{return(entry_text().with(){return({"n":[false]})}.sorted_values().first().first())}],
 ['helper_hash', q{return(with("a"){return({"n":[false]})}.sorted_values().first().first())}],
 ['prefixed_hash', q{return(" a ".trim().with(){return({"n":[false]})}.sorted_values().first().first())}],
 ['hash_default_dispatch_twin', q{return("a".with(){return({"n":[false]})}.coalesce(null).sorted_values().first().first())}],
 ['hash_terminal', q{value="outer";order="";result="a".with(){order=cat(order,"W");return({"n":[false]})};return([result,value,order])}],
 ['array_and_scalar', q{value="outer";return(["a".with(){return(["a","b"])}.last().uppercase(),"a".with(){return(3)}.add(1),"a".with(){return(false)}.coalesce(true),"a".with(){return(null)}.coalesce("fallback"),value])}],
);

sub diagnostic {
 my ($error) = @_;
 return undef unless defined($error) && (ref($error) || length($error));
 return {map {$_ => $error->{$_}}
  grep {exists $error->{$_}} qw(type stage code detail summary helper_name name)}
  if (reftype($error) // '') eq 'HASH';
 return "$error";
}
require LinkedSpec::ActionIR::AST;
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
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'with-hash-results.spec')};
 my $emission_error = $@;
 my $package = 'LinkedSpec::WithHashIntake' . ++$sequence;
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
  ast => LinkedSpec::ActionIR::AST::parse_action_block($action),
  fresh => $fresh, loaded => $loaded ? 1 : 0,
  emission_error => diagnostic($emission_error), load_error => diagnostic($load_error),
  fresh_error => diagnostic($fresh_error), descriptor_error => diagnostic($descriptor_error),
  metadata => {map {$_ => $meta->{$_}} qw(raw_perl_dependency_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)},
  substitution => LinkedSpec::call_spec_handler_subst('Value', $action),
 };
}
print JSON::PP->new->canonical->encode({
 scope => 'eight finite ordinary eager with result/source/scope distinctions; no deferred rights or completeness claim',
 cases => \@rows,
}), "\n";

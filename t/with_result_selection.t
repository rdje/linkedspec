use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();
use LinkedSpec::ActionIR::MethodLowering ();

# TYPE-REFERENCE-BOOK.1.2.23.3.32.1 — immediate contextual helper result reads.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
sub read_file {
 my ($path) = @_;
 open my $fh, '<', $path or die "cannot read $path: $!";
 local $/; my $text = <$fh>; close $fh or die "cannot close $path: $!";
 return $text;
}
sub selected { return !@ARGV || grep {$_ eq $_[0]} @ARGV }
sub routes {
 my ($source) = @_;
 my %context; my ($native, $native_error);
 eval {
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x'; $native = $parser->(\$input); 1;
 } or $native_error = $@;
 $native_error ||= $context{last_error}{detail};
 my $emission = LinkedSpec::emit_generated_source(\$source, source_identity => 'with-result-selection.spec');
 my $package = 'LinkedSpec::WithResultSelection' . ++$sequence;
 my ($fresh, $fresh_error);
 my $loaded = eval "package $package; $emission; 1";
 if ($loaded) {
  no strict 'refs'; my $input = 'x';
  eval {$fresh = &{$package . '::Execute'}(\$input); 1} or $fresh_error = $@;
 } else { $fresh_error = $@ }
 return ([native => $native, $native_error], [fresh => $fresh, $fresh_error]);
}
sub detail {
 my ($error) = @_;
 while ((reftype($error) // '') eq 'HASH' && ($error->{type} // '') eq 'generated_source_error') {
  $error = $error->{detail};
 }
 return $error;
}
sub success {
 my ($label, $source, $expected) = @_;
 return unless selected($label);
 subtest $label => sub {
  for my $row (routes($source)) {
   my ($route, $value, $error) = @$row;
   ok(!$error, "$route executes without error") or diag(defined($error) ? "$error" : '');
   is($json->encode($value), $json->encode($expected), "$route exact values and kinds");
  }
 };
}
success('frozen immediate with selection target', read_file('tests/fixtures/with_result_selection_values.spec'),
 $json->decode(read_file('tests/fixtures/with_result_selection_values.json')));
success('ordinary nested immediate with body', q{Top:: I {value="outer";result=with("outside"){return(with("inside"){return([value])}[0])};return([result,value]);}}, ['inside','outer']);
success('pure function local with source', "fn pure(text){return(with(text){return([uppercase(value)])}[0])}\nTop:: I {return(pure(\"ok\"))}", 'OK');

if (selected('typed helper source roles')) {
 subtest 'typed helper source roles' => sub {
  for my $source ('with("x"){return([1])}[0]', 'with(){return([1])}[0]', 'with("x",{return([1])})[0]') {
   my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source);
   is($node->{kind}, 'value_access', "$source uses existing read node");
   is($node->{receiver}{kind}, 'call', 'typed helper receiver is retained');
   is($node->{receiver}{name}, 'with', 'canonical helper name is retained');
  }
  for my $source ('with("x",cb)[0]', 'with("x",{|item|return([item])})[0]', 'with("x","extra"){return([1])}[0]') {
   is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source)->{kind}, 'raw_perl', "$source keeps its old source boundary");
  }
  is(LinkedSpec::ActionIR::MethodLowering::_actionir_ast_known_value_call_method('with'), undef,
   'global known-value-name ownership remains unchanged');
  my $source = 'with("🙂"){return([1])}[0]';
  my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source, {base_start => 17});
  is($node->{source}, $source, 'authored source is retained');
  is_deeply($node->{source_span}, {start => 17, end => 17+length($source)}, 'source span counts Unicode scalars');
 };
}
for my $case (
 ['explicit literal boundary', q{Top:: I {cb={||return(with("x"){return(["yes"])}[0])};return(cb());}}],
 ['registered contextual boundary', "fn apply(callback: codeblock){return(callback())}\n".q{Top:: I {return(apply(){return(with("x"){return(["yes"])}[0])})}}],
) {
 next unless selected($case->[0]);
 subtest $case->[0] => sub {
  for my $row (routes($case->[1])) {
   my ($route, $value, $error) = @$row;
   is($value, undef, "$route unsupported body has no value");
   my $detail = detail($error);
   is_deeply((reftype($detail) // '') eq 'HASH' ? {map {$_ => $detail->{$_}} qw(code kind)} : undef,
    {code => 'unsupported_codeblock_actionir', kind => 'raw_perl'}, "$route keeps exact deferred error");
  }
  my $descriptor = LinkedSpec::Get(\$case->[1], return_descriptor => 1);
  my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
  is($metadata->{raw_perl_dependency_count}, 1, 'deferred raw dependency stays');
  is_deeply($metadata->{unresolved_helpers}, [], 'no unrelated helper appears');
  ok(!$metadata->{language_agnostic_action_ir_ready}, 'unsupported deferred body stays unready');
 };
}
for my $case (
 ['bound final helper boundary', q{Top:: I {cb={|item|return([item])};return(with("yes",cb)[0]);}}, []],
 ['malformed helper role boundary', q{Top:: I {return(with("x","extra"){return(["yes"])}[0]);}}, ['return']],
) {
 next unless selected($case->[0]);
 subtest $case->[0] => sub {
  for my $row (routes($case->[1])) {
   my ($route, $value, $error) = @$row;
   is($value, undef, "$route unsupported source has no value");
   like(defined($error) ? "$error" : '', qr/syntax error/, "$route keeps old compile-error boundary");
  }
  my $descriptor = LinkedSpec::Get(\$case->[1], return_descriptor => 1);
  my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
  is($metadata->{raw_perl_dependency_count}, 1, 'old raw dependency stays');
  is_deeply($metadata->{unresolved_helpers}, $case->[2], 'old helper diagnostics stay');
  ok(!$metadata->{language_agnostic_action_ir_ready}, 'excluded source stays unready');
 };
}
for my $case (
 ['specific function-state fence', "fn forbidden(){return(with(\"x\"){return([entry_len()])}[0].uppercase())}\nTop:: I {return(forbidden())}", 'entry_len'],
 ['unknown with body fence', q{Top:: I {return(with("x"){return([missing()])}[0].uppercase())}}, 'missing'],
 ['unknown with value-source fence', q{Top:: I {return(with(missing_source()){return([1])}[0].uppercase())}}, 'missing_source'],
) {
 next unless selected($case->[0]);
 subtest $case->[0] => sub {
  my $descriptor = LinkedSpec::Get(\$case->[1], return_descriptor => 1);
  my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
  ok(!$metadata->{language_agnostic_action_ir_ready}, 'forbidden source/body stays unready');
  my %found = map {$_ => 1} @{$metadata->{unresolved_helpers} // []};
  ok($found{$case->[2]}, "specific $case->[2] diagnosis is retained");
 };
}
done_testing;

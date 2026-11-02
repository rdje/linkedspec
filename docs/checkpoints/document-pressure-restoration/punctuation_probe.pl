use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $body = <<'ACTION';
values=["a"]; order="";
bare={order=cat(order,"B");values}.contains;
parens={order=cat(order,"P");values}.contains();
valid=values.contains("a");
return([bare,parens,order,valid]);
ACTION
my @cases = (
 ['healthy', $body],
 ['rejected_alias_admitted', $body =~ s/\.contains;/\.contains("a");/r],
 ['valid_needle_removed', $body =~ s/valid=values\.contains\("a"\)/valid=values.contains()/r],
);
for my $case (@cases) {
 my ($name, $action) = @$case;
 my $spec = 'Top:: I {'.$action.'}';
 my %ctx;
 my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%ctx);
 die 'probe parser did not build' unless ref($parser) eq 'CODE';
 my $input = 'x';
 my $value = eval { $parser->(\$input) };
 my $thrown = "$@";
 print $json->encode({case=>$name, route=>'native', spec=>$spec,
  value=>$value, thrown=>$thrown, error=>$ctx{last_error},
  lowering=>LinkedSpec::call_spec_handler_subst('Top',$action)}),"\n";
 next unless $name eq 'healthy';
 my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
 print $json->encode({case=>$name, route=>'descriptor',
  rewriter=>$descriptor->{spec}{Top}{meta}{action_rewriter}}),"\n";
 my $source = LinkedSpec::emit_generated_source(\$spec,
  source_identity=>'punctuation-required-needle.spec');
 my $loaded = eval "package LinkedSpec::PunctuationRequiredNeedleProbe; $source; 1";
 my $error = "$@";
 my $fresh;
 if ($loaded) {
  my $fresh_input = 'x';
  $fresh = eval { LinkedSpec::PunctuationRequiredNeedleProbe::Execute(\$fresh_input) };
  $error = "$@";
 }
 print $json->encode({case=>$name, route=>'fresh', loaded=>$loaded?1:0,
  value=>$fresh, error=>$error, source=>$source}),"\n";
}

use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.29.2.6.1 — public parser-context helper roles.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
sub gap_source {
 my ($definitions, $action, $item_action) = @_;
 $item_action //= 'return(entry_text())';
 return "$definitions\nList::\n \@capture_gaps\n I {set(rows,array())}\n -> Item[word] {$action}\n LX {return(copy(rows))}\nItem:\n word=/[^,;]+/\n I {$item_action}\n";
}
sub check_source {
 my ($label, $source, $input, $expected, $rule, $helpers) = @_;
 subtest $label => sub {
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $native_input = $input;
  my $native = eval { $parser->(\$native_input) };
  ok(!$@ && !$context{last_error}, 'native has no host failure') or diag("$@");
  is($json->encode($native), $json->encode($expected), 'native exact values');
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'function-parser-context.spec');
  my $package = 'LinkedSpec::FunctionParserContext' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh source compiles') or diag($@);
  if ($loaded) {
   my $fresh_input = $input; no strict 'refs';
   my $fresh = eval { &{$package . '::Execute'}(\$fresh_input) };
   ok(!$@, 'fresh has no host failure') or diag($@);
   is($json->encode($fresh), $json->encode($expected), 'fresh exact values');
  }
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
  is($meta->{raw_perl_dependency_count}, 0, 'no raw fallback');
  if (@$helpers) {
   ok(!$meta->{language_agnostic_action_ir_ready}, 'parser-context function remains unready');
   my %found = map { $_ => 1 } @{$meta->{unresolved_helpers} // []};
   ok($found{$_}, "explicit forbidden helper $_") for @$helpers;
  } else {
   is($meta->{unresolved_helper_count}, 0, 'ordinary context resolves');
   ok($meta->{language_agnostic_action_ir_ready}, 'ordinary explicit values remain ready');
  }
 };
}
check_source('pure function cannot invoke a child parser', "fn selected(){return(call(Child))}\nTop:: I {return(selected())}\nChild: I {return(\"child\")}\n", 'x', undef, 'Top', ['call']);
check_source('pure function cannot read public gap context', gap_source('fn selected(){return([entry_slot(),gap_text(),gap_kind(),gap_span()])}', 'push(rows,selected())'), 'a,b', [[(undef)x4],[(undef)x4]], 'List', [qw(entry_slot gap_text gap_kind gap_span)]);
check_source('pure function cannot read incoming child slot', gap_source('fn selected(){return(entry_slot())}', 'push(rows,call(Item))', 'return(selected())'), 'a,b', [undef,undef], 'Item', ['entry_slot']);
check_source('ordinary parser call can supply an explicit pure-function value', "fn upper(text){return(text.uppercase())}\nTop:: I {return(upper(call(Child)))}\nChild: I {return(\"child\")}\n", 'x', 'CHILD', 'Top', []);
check_source('ordinary gap reads can supply explicit pure-function values', gap_source('fn selected(text,kind,span){return([text.uppercase(),kind,span])}', 'push(rows,selected(gap_text(),gap_kind(),gap_span()))'), 'a,b', [
 ['', 'prefix', {source_id=>'input',start=>0,end=>0,provenance=>'gap'}],
 [',', 'interstitial', {source_id=>'input',start=>1,end=>2,provenance=>'gap'}],
], 'List', []);
my $slot = {target_rule=>'Item',regex_index=>0,slot_id=>'word',selector_kind=>'named',authored_selector=>'word'};
check_source('ordinary incoming slot can supply an explicit pure-function argument', gap_source('fn identify(slot){return(slot)}', 'push(rows,call(Item))', 'return(identify(entry_slot()))'), 'a,b', [$slot,$slot], 'Item', []);
done_testing;

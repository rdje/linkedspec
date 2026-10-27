use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.29.2.1 — existing pure-function boundary.
my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub capture_source {
 my ($definitions, $action) = @_;
 return "$definitions\nTop::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n";
}
sub metadata {
 my ($source, $names) = @_;
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
 my $meta = $descriptor->{spec}{Value}{meta}{action_rewriter};
 is($meta->{raw_perl_dependency_count}, 0, 'no raw fallback');
 if (@$names) {
  ok(!$meta->{language_agnostic_action_ir_ready}, 'parser-state body remains unready');
  my %found = map { $_ => 1 } @{$meta->{unresolved_helpers} // []};
  ok($found{$_}, "explicit forbidden helper $_") for @$names;
 } else {
  is($meta->{unresolved_helper_count}, 0, 'pure values resolve');
  ok($meta->{language_agnostic_action_ir_ready}, 'pure values remain ready');
 }
}
sub execution {
 my ($source, $expected) = @_;
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'name=Alpha';
 my $native = eval { $parser->(\$input) };
 ok(!$@ && !$context{last_error}, 'native has no host error') or diag("$@");
 is($json->encode($native), $json->encode($expected), 'native exact values and kinds');
 my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'user-function-parser-state-boundary.spec');
 my $package = 'LinkedSpec::FunctionParserStateBoundary' . ++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh source compiles') or diag($@);
 if ($loaded) {
  my $fresh_input = 'name=Alpha';
  no strict 'refs';
  my $fresh = eval { &{$package . '::Execute'}(\$fresh_input) };
  ok(!$@, 'fresh has no host error') or diag($@);
  is($json->encode($fresh), $json->encode($expected), 'fresh exact values and kinds');
 }
}
subtest 'capture collection and group readers cannot capture caller parser state' => sub {
 my @names = qw(entry_groups match_groups entry_map match_map entry_named_map match_named_map entry_group match_group);
 my $calls = join(',', map { $_ . (/group$/ ? '(0)' : '()') } @names);
 my $source = capture_source('fn forbidden(){return([' . $calls . '])}', 'return(forbidden())');
 metadata($source, \@names);
 execution($source, [[(undef) x @names]]);
};
subtest 'nested pure calls and discarded statements retain the same boundary' => sub {
 my $source = capture_source("fn inner(){return(entry_groups())}\nfn outer(){match_map();return(inner())}", 'return(outer())');
 metadata($source, [qw(entry_groups match_map)]);
 execution($source, [undef]);
};
subtest 'capture mark and cursor helpers reject before operands or state changes' => sub {
 # Descriptor-only: no parser-state write is executed, including on the RED version.
 my $source = capture_source('fn forbidden(){save_cursor(point);return([capture_slice(),mark_pos(point),restore_cursor(point)])}', 'return(forbidden())');
 metadata($source, [qw(save_cursor capture_slice mark_pos restore_cursor)]);
};
subtest 'explicit caller values pure helpers locals and prefix-named functions remain valid' => sub {
 my $source = capture_source("fn entry_custom(text){local_text=text.uppercase();return(local_text)}\nfn capture_custom(text){return(entry_custom(text))}", 'return([capture_custom(entry_group(0)),capture_custom(match_named("value")),entry_groups().last().uppercase(),match_map()["value"].uppercase()])');
 metadata($source, []);
 execution($source, [['NAME','ALPHA','NAME','ALPHA']]);
};
done_testing;

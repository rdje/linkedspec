use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.30.1 — frozen Number reader value composition.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
sub read_file {
 my ($path) = @_;
 open my $fh, '<', $path or die "cannot read $path: $!";
 local $/;
 my $text = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $text;
}
sub check_source {
 my ($label, $source, $input, $expected, $rule, $unsupported) = @_;
 $unsupported //= [];
 subtest $label => sub {
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $native_input = $input;
  my $native = eval {$parser->(\$native_input)};
  ok(!$@ && !$context{last_error}, 'native has no host error') or diag("$@");
  is($json->encode($native), $json->encode($expected), 'native exact values and kinds');
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'entry-match-number-results.spec');
  my $package = 'LinkedSpec::EntryMatchNumberResults' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh source compiles') or diag($@);
  if ($loaded) {
   my $fresh_input = $input;
   no strict 'refs';
   my $fresh = eval {&{$package . '::Execute'}(\$fresh_input)};
   ok(!$@, 'fresh has no host error') or diag($@);
   is($json->encode($fresh), $json->encode($expected), 'fresh exact values and kinds');
  }
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
  is($meta->{raw_perl_dependency_count}, 0, 'no raw fallback');
  if (@$unsupported) {
   ok(!$meta->{language_agnostic_action_ir_ready}, 'forbidden function body stays unready');
   my %found = map {$_ => 1} @{$meta->{unresolved_helpers} // []};
   ok($found{$_}, "specific forbidden helper $_") for @$unsupported;
  } else {
   is($meta->{unresolved_helper_count}, 0, 'ordinary source helpers resolve');
   ok($meta->{language_agnostic_action_ir_ready}, 'ready metadata describes working code');
  }
 };
}
sub capture_source {
 my ($action) = @_;
 return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n";
}
check_source('unchanged frozen reader target', read_file('tests/fixtures/entry_match_number_result_values.spec'), 'name=Alpha', $json->decode(read_file('tests/fixtures/entry_match_number_result_values.json')), 'Value');
check_source('absent match Number uses one lazy fallback', 'Top:: I {order="";return([match_len().coalesce({order=cat(order,"F");7}).add(1),order])}', 'x', [8,'F'], 'Top');
check_source('legacy first-consumer policies and normalized Number guards stay distinct', capture_source(q{
 order="";
 result=match_len().add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 return([match_len().set_key("k",1),entry_len().take(1),result,order]);
}), 'name=Alpha', [[{k=>1},[],undef,'']], 'Value');
my @readers = qw(entry_len entry_start_pos entry_end_pos entry_line entry_start_line entry_end_line entry_col entry_start_col entry_end_col match_len match_start_pos match_end_pos match_line match_start_line match_end_line match_col match_start_col match_end_col);
my $body = join(',', map {$_ . '()'} @readers);
check_source('Number getters keep the pure-function parser-state fence', 'fn forbidden(){return([' . $body . '])} Top:: I {return(forbidden())}', 'x', [(undef)x@readers], 'Top', \@readers);
done_testing;

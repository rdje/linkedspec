use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.39.5: sparse action dispatch must not
# replace the full local structural sequence of a plain AND rule.
my $json = JSON::PP->new->canonical->allow_nonref->ascii;
my $sequence = 0;

sub check_shape {
 my ($name, $source, $variant, $family, $catalog_size, $cases, $structural_size) = @_;
 subtest $name => sub {
  my %ctx;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
  ok(ref($parser) eq 'CODE', 'native parser builds');
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $rule = $descriptor->{spec}{Value};
  is($rule->{meta}{selected_handler_variant}, $variant, 'selects the existing intended variant');
  is(scalar(@{$rule->{re}}), $catalog_size, 'retains the complete authored regex catalog');

  my $emitted = LinkedSpec::emit_generated_source(
   \$source, source_identity => 'sparse-and-single-action.spec',
  );
  my $package = 'LinkedSpec::SparseAndSingleActionTest' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'independent emitted package loads') or diag($@);
  return unless $loaded && ref($parser) eq 'CODE';
  no strict 'refs';
  my $metadata = &{$package . '::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version}, 2, 'generated format remains two');
  is($metadata->{contract_id}, 'linkedspec-generated-source-v2', 'generated contract is unchanged');
  my ($row) = grep {$_->{label} eq 'Value'} @{$metadata->{plan}};
  is_deeply($row, {label => 'Value', family => $family}, 'minimal plan reports the actual existing family');
  is_deeply(&{$package . '::LinkedSpecGeneratedPlan'}(), $metadata->{plan}, 'loaded plan agrees with metadata');
  if (defined $structural_size) {
   like($emitted, qr/while \(\$idx < \Q$structural_size\E\)/, 'emitted loop includes edge-less structural slots');
  }
  my @observations;
  for my $case (@$cases) {
   my ($input, $expected, $position) = @$case;
   my $native_text = $input;
   my $native = eval {$parser->(\$native_text)};
   my $native_error = $@ || $ctx{last_error};
   ok(!$native_error, "$input native has no execution error") or diag($json->encode($native_error));
   is($json->encode($native), $json->encode($expected), "$input native exact value and kinds");
   is(pos($native_text), $position, "$input native exact cursor");
   my $fresh_text = $input;
   my $fresh = eval {&{$package . '::Execute'}(\$fresh_text)};
   my $fresh_error = $@;
   is($fresh_error, '', "$input emitted execution has no error");
   is($json->encode($fresh), $json->encode($expected), "$input fresh exact value and kinds");
   is(pos($fresh_text), $position, "$input fresh exact cursor");
   push @observations, {input => $input, native => $native, fresh => $fresh,
    native_cursor => pos($native_text), fresh_cursor => pos($fresh_text)};
  }
  diag('SPARSE_AND_SINGLE_ACTUAL ' . $name . ' ' . $json->encode({variant => $rule->{meta}{selected_handler_variant}, plan => $row, cases => \@observations}));
 };
}

my $single = "Value:AND\n /H/\n /cat/\n -> Value[1] {return(\"BODY\")}\n";
check_shape('plain sparse single action requires its prefix',
 'Value::AND' . substr($single, length('Value:AND')), 'AND_ACODE', 'and_acode_seq', 2,
 [['Hcat', 'BODY', 4], ['cat', undef, 0], ['Hbad', undef, 1]], 2);

check_shape('three structural slots and one last action',
 "Value::AND\n /H/\n /_/\n /cat/ -> Value[2] {return([match_text(),cursor_pos()])}\n",
 'AND_ACODE', 'and_acode_seq', 3,
 [['H_cat', ['cat', 5], 5], ['cat', undef, 0], ['Hcat', undef, 1]], 3);

check_shape('incoming entry does not replace the child prefix',
 "Top::\n -> Value .push\n LX {return(copy(Top))}\n" . $single,
 'AND_ACODE', 'and_acode_seq', 2,
 [['HHcat', ['BODY'], 5], ['Hcat', [undef], 1]], 2);
check_shape('indexed incoming entry keeps the complete child sequence',
 "Top::\n -> Value[1] .push\n LX {return(copy(Top))}\n" . $single,
 'AND_ACODE', 'and_acode_seq', 2,
 [['catHcat', ['BODY'], 7]], 2);

for my $value ([zero => '0', 0], [empty => '""', ''], [null => 'undef', undef]) {
 my $source = 'Value::AND' . substr($single, length('Value:AND'));
 $source =~ s/"BODY"/$value->[1]/;
 check_shape('sparse action preserves ' . $value->[0],
  $source,
  'AND_ACODE', 'and_acode_seq', 2, [['Hcat', $value->[2], 4]], 2);
}

my $nonreturning = <<'SPEC';
Value::AND
 I {seen=[]}
 /H/
 /cat/
 /!/
 -> Value[1] {push(seen,match_text())}
 LE {if(eq(cursor_pos(),5)) {return([copy(seen),cursor_pos()])}}
SPEC
check_shape('nonreturning sparse action and edge-less tail keep effects', $nonreturning,
 'AND_ACODE', 'and_acode_seq', 3, [['Hcat!', [['cat'], 5], 5]], 3);

check_shape('one regex keeps the single-action variant',
 "Value::AND\n /cat/ -> Value {return(\"BODY\")}\n",
 'AND_SINGLE_ACODE', 'and_single_acode', 1, [['cat', 'BODY', 3]]);
my $cross_target = <<'SPEC';
Value::AND
 /H/
 /cat/
 -> Part[1] {return(match_text())}
Part:
 /unused/
 /cat/
SPEC
check_shape('one cross-target dependency remains a dependency', $cross_target,
 '_default', 'default', 2, [['cat', 'cat', 3], ['Hcat', undef, 0]]);

for my $shape ([reversed => 1, 'ba', 'b'], [duplicate => 0, 'aa', 'a']) {
 check_shape($shape->[0] . ' dependency slots preserve action order and identity',
  "Value::AND\n I {seen=[]}\n /a/\n /b/\n" .
  ' -> Value[' . $shape->[1] . "] {push(seen,match_text())}\n" .
  " -> Value[0] {return([copy(seen),match_text(),cursor_pos()])}\n",
  'AND_ACODE', 'and_acode_seq', 2,
  [[$shape->[2], [[$shape->[3]], 'a', 2], 2]], 2);
}

check_shape('repeated sparse groups retain minimum and reset behavior',
 "Value::AND{2}\n /H/\n /cat/ -> Value[1] {return(\"BODY\")}\n",
 'REP_AND_ACODE', 'rep_and_acode', 2,
 [['HcatHcat', ['BODY', 'BODY'], 8], ['Hcat', undef, 4]], 2);
check_shape('explicit early return still unwinds before the structural tail',
 "Value::AND\n /H/\n /cat/\n -> Value[0] {return(\"EARLY\")}\n",
 'AND_ACODE', 'and_acode_seq', 2, [['H', 'EARLY', 1]], 2);
check_shape('no-edge lifecycle behavior is outside this repair',
 "Value::AND\n /H/\n /cat/\n",
 '<none>', 'default', 2, [['Hcat', 0, 0]]);

done_testing();

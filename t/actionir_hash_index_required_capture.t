use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
my $loaded=do './t/actionir_hash_index_required_probe.pl';
die $@ || $! unless defined($loaded);
my $path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-native.json';
open my $fh,'<',$path or die "$path: $!";
my $capture=JSON::PP->new->decode(do {local $/;<$fh>});
close $fh or die "$path: $!";
my $native=JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my $current=LinkedSpecTest::MethodLocations::original_coordinates(HashIndexRequiredProbe::observations());
my $ordinary={target=>'meta',key=>'key',value=>'value'};
my $statement='SET(meta,KEY(key),VALUE(value))';

sub comparable {
 my ($original)=@_;
 my $row=JSON::PP->new->decode(JSON::PP->new->canonical->encode($original));
 if (defined($row->{error}) && !ref($row->{error})) {
  $row->{error}=~s{\bat [^\n]*?\bperl/LinkedSpec/ActionIR/MethodLowering\.pm line (\d+)(?:, <[^\n]+> line \d+)?\.\n\z}{at perl/LinkedSpec/ActionIR/MethodLowering.pm line $1.\n};
  $row->{error}=~s{(at \./t/actionir_hash_index_required_probe\.pl line 55), <[^\n]+> line \d+\.\n\z}{$1.\n};
 }
 if ($row->{name} eq 'lowerer-key_result-reference' || $row->{name} eq 'lowerer-payload_result-reference') {
  $row->{value}=~s/HASH\(0x[0-9a-f]+\)/HASH(<actual-address>)/g if defined($row->{value}) && !ref($row->{value});
 }
 return $row;
}

is($capture->{returncode},0,'first native hash-index command completed');
is(decode_base64($capture->{stderr_base64}),
 'Scalar value @_[0] better written as $_[0] at ./t/actionir_hash_index_required_probe.pl line 107.' . "\n",
 'first native warning remains retained');
is(scalar(keys %{$capture->{inputs}}),205,'complete original native input population');
my $cases=HashIndexRequiredProbe::callback_cases();
is(scalar(@{$native->{callbacks}}),12,'complete three-role/four-outcome native population');
for my $index (0..$#$cases) {
 my $case=$cases->[$index];my $row=$current->{callbacks}[$index];
 my $label='hash-index ordinary callback '.$case->{name};
 my $value=$case->{outcome}=~/^(string|effect)$/ ? $case->{owner} eq 'parser' ? {%$ordinary} : $statement : undef;
 $value='SET(meta,KEY(key),VALUE(value!))' if $case->{name} eq 'lowerer-trim_action_ir_value-effect';
 is_deeply(comparable($row),comparable($native->{callbacks}[$index]),"$label complete native effects and aliases");
 is_deeply($row->{value},$value,"$label authored result");
 is($row->{caller_after},'meta[key] = value',"$label caller scalar survives");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual maps survive");
 is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x scalar(@{$row->{trace}})],"$label scalar contexts");
 is_deeply([map {$_->{readonly}} @{$row->{trace}}],[map {[0]} @{$row->{trace}}],"$label native slot flags");
 is_deeply($row->{error},$case->{outcome} eq 'fatal' ? {type=>'HashIndexRequiredFatal',same_fatal=>1} : undef,
  "$label actual fatal identity or successful outcome");
 is($row->{success_error},$case->{outcome} eq 'fatal' ? undef : 'successful hash-index required callback',
  "$label native successful error effect");
}
my $branches=HashIndexRequiredProbe::branch_cases();
is(scalar(@$branches),96,'complete authored branch population');
for my $index (0..$#$branches) {
 my $case=$branches->[$index];my $row=$current->{branches}[$index];
 my $label='hash-index branch '.$case->{name};
 is_deeply(comparable($row),comparable($native->{branches}[$index]),"$label complete native observation");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual caller map survives");
 if ($case->{missing} || $case->{noncode}) {
  my $role=$case->{missing} || $case->{noncode};
  my $line=$case->{owner} eq 'parser' ? 7974 : 8064;
  is(comparable($row)->{error},"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$role' at perl/LinkedSpec/ActionIR/MethodLowering.pm line $line.\n",
   "$label exact diagnostic and source line");
  is_deeply($row->{events},[],"$label required validation before input guards and effects");
 }
}
my %by_name=map {$_->{name}=>$_} @{$current->{branches}};
for my $owner (qw(parser lowerer)) {
 for my $name (qw(undefined-input empty-input whitespace-input zero-input invalid-target no-bracket unclosed-bracket unclosed-quote equality arrow missing-value empty-key)) {
  is($by_name{$owner.'-'.$name}{value},undef,"hash-index $owner $name authored rejection");
 }
 is_deeply($by_name{$owner.'-ordinary'}{value},$owner eq 'parser' ? $ordinary : $statement,
  "hash-index $owner ordinary authored result");
 is_deeply($by_name{$owner.'-target-space'}{value},$owner eq 'parser' ? $ordinary : $statement,
  "hash-index $owner whitespace retains target/key/value");
 like(comparable($by_name{$owner.'-rhs-trim-effect'})->{error},
  qr/^Modification of a read-only value attempted at \.\/t\/actionir_hash_index_required_probe\.pl line 55\.\n$/,
  "hash-index $owner actual regex RHS mutation is readonly");
 is_deeply($by_name{$owner.'-rhs-trim-effect'}{trace}[-1]{readonly},[0],
  "hash-index $owner RHS flag alone does not predict mutation permission");
 my $undefined=$owner eq 'parser' ? 2 : 3;
 is($by_name{$owner.'-trim-result-'.$undefined.'-undefined'}{calls}{trim_action_ir_value},$owner eq 'parser' ? 3 : 4,
  "hash-index $owner trims key even after undefined RHS");
}
is_deeply($by_name{'parser-zero-key-value'}{value},{target=>'meta',key=>'0',value=>'0'},'hash-index parser accepts nonempty zero key/value');
is($by_name{'lowerer-zero-key-value'}{value},'SET(meta,KEY(0),VALUE(0))','hash-index lowerer accepts zero key/value');
is_deeply($by_name{'parser-replace-trim'}{events},[('trim_action_ir_value') x 3],
 'hash-index parser keeps eagerly selected trim after map replacement');
my @lowerer_events=('trim_action_ir_value','ast_parse','assign_hash_index','ast_parse','assign_nested_access','legacy_parse',
 (('trim_action_ir_value') x 3),'lower_scalar_access_key_expr','payload','assemble');
is_deeply($by_name{'lowerer-replace-key'}{events},\@lowerer_events,
 'hash-index lowerer key selection precedes trim map replacement');
my @replaced_trim=@lowerer_events;
@replaced_trim[6..8]=('replacement_trim') x 3;
is_deeply($by_name{'lowerer-replace-trim'}{events},\@replaced_trim,
 'hash-index nested parser acquires replacement trim at its own invocation');
for my $kind (qw(ast_hash ast_nested)) {
 my $zero=$by_name{'lowerer-'.$kind.'-zero'};my $reference=$by_name{'lowerer-'.$kind.'-reference'};
 is($zero->{value},'0',"hash-index $kind nonempty zero returns directly");
 is_deeply($reference->{value},{sentinel=>$kind},"hash-index $kind actual reference result");
 is($reference->{result_identity},1,"hash-index $kind returned object identity survives");
 ok(!(grep {$_ eq 'legacy_parse'} @{$reference->{events}}),"hash-index $kind bypasses legacy parser");
}
is_deeply([map {$_->{id}} @{$by_name{'lowerer-ordinary'}{ast_nodes}}],[1,2],
 'hash-index nested AST attempt reparses into a fresh node');
is_deeply($by_name{'lowerer-payload-mutation'}{parsed_after},[{target=>'meta',key=>'key',value=>'value!'}],
 'hash-index payload helper receives actual parsed value slot');
my ($key_effect)=grep {$_->{name} eq 'lowerer-lower_scalar_access_key_expr-effect'} @{$current->{callbacks}};
is($key_effect->{trace}[-1]{parsed_key_slot},1,'hash-index key callback receives actual parsed key slot');
is_deeply($key_effect->{parsed_after},[{target=>'meta',key=>'key!',value=>'value'}],
 'hash-index key mutation survives in actual parser result');
my %counts=('parser/trim_action_ir_value'=>3,'lowerer/trim_action_ir_value'=>4,'lowerer/lower_scalar_access_key_expr'=>1);
for my $pair (@{HashIndexRequiredProbe::roles()}) {
 my ($owner,$role)=@$pair;
 for my $known (0,1) {
  my $row=HashIndexRequiredProbe::authority($owner,$role,$known);
  my $label="hash-index authority $owner $role known$known";
  is_deeply($row->{ordinary},$owner eq 'parser' ? $ordinary : $statement,"$label actual ordinary result");
  is($row->{value},$owner eq 'parser' ? JSON::PP->new->canonical->encode($ordinary) : $statement,"$label outer value");
  is($row->{parent_packet},0,"$label no child publication donation");
  is_deeply($row->{eligible},[($known) x $counts{$owner.'/'.$role}],"$label actual callback identity");
  is($row->{selected_calls},$counts{$owner.'/'.$role},"$label fixed native effect count");
  ok($row->{map_identity},"$label actual caller callback remains");
 }
}
is_deeply($current->{public},$native->{public},'all three public Toolbox generated-source rows stay exact');
for my $row (@{$current->{public}}) {
 is($row->{error},undef,'public hash-index source has no error: '.$row->{source});
 like($row->{value},qr/LinkedSpec::BindingRuntime::nested_write\(/,'public hash-index source keeps typed nested write: '.$row->{source});
}
is_deeply($current->{cold},$native->{cold},'cold require-only full results and channels remain native');
is($current->{cold}{returncode},0,'cold hash-index command completed');
is($current->{cold}{value}{loaded_before},0,'cold hash-index starts without emission channel');
is($current->{cold}{value}{loaded_after},0,'cold required binding keeps emission channel lazy');
is_deeply($current->{cold}{value}{rows}[0]{value},$ordinary,'cold parser ordinary result');
is($current->{cold}{value}{rows}[2]{value},'meta,KEY,VALUE','cold lowerer ordinary result');
done_testing();

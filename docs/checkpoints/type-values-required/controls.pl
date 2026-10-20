use strict;
use warnings;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use Digest::SHA qw(sha256_hex);
use Test::More;
use LinkedSpec::ActionIR::MethodLowering ();
require './t/lib/LinkedSpecTest/MethodLocations.pm';
require './t/lib/LinkedSpecTest/EmittedValues.pm';

my $source = 'perl/LinkedSpec/ActionIR/MethodLowering.pm';
is($INC{'LinkedSpec/ActionIR/MethodLowering.pm'}, $source, 'actual loaded producer is the declared module');
open my $module, '<:raw', $source or die $!;
my $bytes = do {local $/; <$module>};
close $module or die $!;
diag('loaded_module_sha256=' . sha256_hex($bytes));
my $error;
eval {LinkedSpec::ActionIR::MethodLowering::_lower_hash_index_assignment_operator_statement(
 'meta[key] = value', {}); 1} or $error = $@;
like($error, qr/missing dependency callback 'trim_action_ir_value'/, 'actual native dependency error observed');
open my $file, '<:raw', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-native.json' or die $!;
my $capture = JSON::PP->new->decode(do {local $/; <$file>});
close $file or die $!;
my $native = JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my ($old) = grep {$_->{name} eq 'lowerer-missing-trim_action_ir_value'} @{$native->{branches}};
ok($old, 'independent frozen native row exists');
my $normal = LinkedSpecTest::MethodLocations::original_coordinates({error => $error});
is($normal->{error}, $old->{error}, 'same-routine correspondence matches the actual frozen native error');
for my $kind (qw(callback filename line)) {
 my $wrong = $error;
 if ($kind eq 'callback') {$wrong =~ s/trim_action_ir_value/another_callback/ or die 'callback control';}
 if ($kind eq 'filename') {$wrong =~ s{perl/LinkedSpec/ActionIR/MethodLowering.pm}{perl/LinkedSpec/ActionIR/Another.pm} or die 'file control';}
 if ($kind eq 'line') {$wrong =~ s/( line )(\d+)/$1 . ($2 + 1)/e or die 'line control';}
 my $actual = LinkedSpecTest::MethodLocations::original_coordinates({error => $wrong});
 isnt($actual->{error}, $old->{error}, "wrong $kind remains distinguishable");
}
is(LinkedSpecTest::MethodLocations::original_coordinates({value => $error})->{value}, $error,
 'non-error payload is not projected');
my @lines = split /\n/, $bytes;
my ($new) = grep {$lines[$_ - 1] =~ /^sub _materialize_list_operand_expr/} 1 .. @lines;
ok(defined $new, 'new helper statement is located in the actual producer');
my $accepted = eval {LinkedSpecTest::MethodLocations::original_line($new); 1};
ok(!$accepted && $@ =~ /no unchanged MethodLowering statement/, 'new unmatched statement rejects');
my @Top = (1, 'two');
sub nested {
 my ($source) = @_;
 my $execute = eval 'sub { ' . $source . ' }';
 die $@ unless ref($execute) eq 'CODE';
 return $execute->();
}
is_deeply(nested('return [[@Top]]'), [[1, 'two']], 'independent nested-value golden');
isnt(JSON::PP->new->canonical->encode(nested('return [@Top]')),
 JSON::PP->new->canonical->encode([[1, 'two']]), 'flattened return cannot satisfy nested golden');
is_deeply(LinkedSpecTest::EmittedValues::return_value('return 1'), {value => 1},
 'emitted-value observer executes its actual producer');
isnt(JSON::PP->new->canonical->encode(LinkedSpecTest::EmittedValues::return_value('return 2')),
 JSON::PP->new->canonical->encode({value => 1}), 'wrong emitted value remains distinguishable');
done_testing();

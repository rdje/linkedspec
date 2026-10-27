use strict;
use warnings;
use File::Path qw(make_path);
use File::Basename qw(dirname);
use JSON::PP ();

# Reconstruct only the three changed producers from the immutable clean base.
# No checkout, test file, or other repository is amended.
my $base = 'b4afbe7bc2897e90b898f844e4dfacd2da5a1425';
my $directory = '.linkedspec-data/verification/parser-expectation-baseline/perl';
my @modules = qw(LinkedSpec/ActionIR/AST/Parser.pm LinkedSpec/ActionIR/MethodLowering.pm LinkedSpec/ActionIR/ValueExpr.pm);
for my $relative (@modules) {
 my $file = './'.$directory.'/'.$relative;
 make_path(dirname($file));
 open my $git, '-|', 'git', 'show', "$base:perl/$relative" or die "git show: $!";
 local $/;
 my $bytes = <$git>;
 close $git or die "git show failed for $relative";
 open my $output, '>', $file or die "$file: $!";
 print {$output} $bytes;
 close $output or die "$file: $!";
 require $file;
 $INC{$relative} = $file;
}
require LinkedSpec;
my @observations;
for my $source (q{" x ".trim()}, q{return("abc".substr())}, q{return(["x","abc".substr()])}) {
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $source);
 my $execute = eval "sub { no warnings 'void'; $lowered }";
 my $error = "$@";
 my $value;
 if ($execute) {
  $value = eval { $execute->() };
  $error = "$@";
 }
 push @observations, {source => $source, lowered => $lowered, value => $value, error => $error};
}
print JSON::PP->new->canonical->pretty->encode({
 base_commit => $base,
 modules => {map { $_ => $INC{$_} } @modules},
 observations => \@observations,
});

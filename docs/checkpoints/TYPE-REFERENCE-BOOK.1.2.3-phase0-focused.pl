use strict;
use warnings;
use JSON::PP ();
use Test::More ();

my $plan = do { local $/; JSON::PP::decode_json(<STDIN>) };
my %wanted = map { $_->{number} => $_->{name} } @{$plan->{selected}};
die "duplicate selected root number\n" unless keys(%wanted) == @{$plan->{selected}};
my ($depth, $skipped) = (0, 0);
my %seen;
my $ordinary_subtest = \&Test::More::subtest;
{
    no warnings 'redefine';
    *Test::More::subtest = sub {
        my ($name) = @_;
        my $number = Test::More->builder->current_test + 1;
        if ($depth || (exists($wanted{$number}) && $wanted{$number} eq $name)) {
            ++$seen{$number} unless $depth;
            ++$depth;
            my ($value, $error);
            my $ok = eval { $value = $ordinary_subtest->(@_); 1 };
            $error = $@;
            --$depth;
            die $error unless $ok;
            return $value;
        }
        ++$skipped;
        return Test::More->builder->skip("focused actor excludes $name");
    };
}

# The actual test file and its ordinary imports/helpers remain intact. Reset
# FindBin's public state so relative test/spec paths have their normal meaning.
$0 = 't/phase0_regression.t';
require FindBin;
FindBin::again();
{
    local @ARGV;
    local $@;
    do './t/phase0_regression.t';
    die $@ if length $@;
}
my $builder = Test::More->builder;
my $complete = keys(%wanted) > 0
    && keys(%wanted) == keys(%seen)
    && !grep { ($seen{$_} // 0) != 1 } keys %wanted;
my $result = {
    selected => scalar(keys %seen),
    wanted => scalar(keys %wanted),
    skipped => $skipped,
    root_tests => $builder->current_test,
    complete_selection => $complete ? JSON::PP::true : JSON::PP::false,
    passing => $builder->is_passing ? JSON::PP::true : JSON::PP::false,
    loaded_method_lowering => $INC{'LinkedSpec/ActionIR/MethodLowering.pm'},
    scope => 'Focused adapter only; excluded root subtests are explicit TAP SKIP. Ordinary full Phase0 requires canonical CI.',
};
print '# FOCUSED_PHASE0_JSON ', JSON::PP->new->canonical->encode($result), "\n";
exit($complete && $builder->is_passing
    && $builder->current_test == $plan->{ordinary_root_tests} ? 0 : 1);

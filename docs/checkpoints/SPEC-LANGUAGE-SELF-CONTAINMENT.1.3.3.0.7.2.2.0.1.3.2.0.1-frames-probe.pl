use strict;
use warnings;
use utf8;
use LinkedSpec::ActionIR::MethodExpr ();
use JSON::PP ();
use Scalar::Util qw(refaddr);

my $json = JSON::PP->new->canonical->utf8;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my @rows;
for my $case (@$cases) {
    my ($returned, $count) = (undef, 0);
    my $callback = sub {
        ++$count;
        $returned = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr(@_);
        return $returned;
    };
    my $bridge = LinkedSpec::ActionIR::MethodExpr->can('_parse_method_with_source_frames');
    my $result = $bridge ? $bridge->($callback, $case->{source}, $case->{receiver})
                        : {call => $callback->($case->{source}, $case->{receiver}), source_frames => []};
    my ($array, $split_count) = (undef, 0);
    my $split = sub {
        ++$split_count;
        $array = LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv(@_);
        return $array;
    };
    my $csv_bridge = LinkedSpec::ActionIR::MethodExpr->can('_split_csv_with_source_frames');
    my @args = ($case->{payload}, ($case->{receiver} ? '.' : '').$case->{method});
    my $csv = $csv_bridge ? $csv_bridge->($split, @args)
                         : {arguments => $split->(@args), source_frames => []};
    push @rows, {id => $case->{id}, result => $result, csv => $csv, calls => $count,
                split_calls => $split_count,
                call_same => refaddr($result->{call}) == refaddr($returned) ? JSON::PP::true : JSON::PP::false,
                args_same => refaddr($result->{call}{args}) == refaddr($returned->{args}) ? JSON::PP::true : JSON::PP::false,
                csv_same => refaddr($csv->{arguments}) == refaddr($array) ? JSON::PP::true : JSON::PP::false};
}
print $json->pretty->encode(\@rows);

use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

my $literal = '{|| return("yes") }';
my $expression = 'with("context") { return(' . $literal . ') }';
my $source = "Top: /x/\n I { return($expression) }\n";
my $start = index($expression, $literal);
my $expected = {start => $start, end => $start + length($literal)};
my $parser = LinkedSpec::Get(\$source);
my $input = 'x';
my $native = $parser->(\$input);
my $emitted = LinkedSpec::emit_generated_source(\$source);
eval "package ScopedWithSpan; $emitted; 1" or die $@;
$input = 'x';
my $generated = ScopedWithSpan::Execute(\$input);
print JSON::PP->new->canonical->encode({
    expected => $expected, native => $native->{source_span},
    generated => $generated->{source_span}, expression => $expression,
}), "\n";

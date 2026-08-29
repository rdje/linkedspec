#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<:raw', $path or die "cannot read $path: $!";
 local $/;
 my $bytes = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $bytes
}

my $grammar = slurp("$Bin/../specs/spec.spec");
my $parser = LinkedSpec::Get(\$grammar, top_rule => 'spec_file');
ok(ref($parser) eq 'CODE', 'permanent self-hosted grammar compiles');

sub parse_source {
 my ($source) = @_;
 my $input = $source;
 return $parser->(\$input)
}

my $explicit = parse_source(qq{Top::\n I { return("same") }\n});
my $shorthand = parse_source(qq{Top::\n { return("same") }\n});

is_deeply(
 $explicit,
 [[
  {type => 'rule', label => 'Top', top => 1, mode => ''},
  {
   type => 'lifecycle',
   marker => 'I',
   code => '{ return("same") }',
   source_form => 'explicit',
  },
 ]],
 'reserved explicit I is owned by lifecycle syntax rather than a bare edge',
);
is_deeply(
 $shorthand,
 [[
  {type => 'rule', label => 'Top', top => 1, mode => ''},
  {
   type => 'lifecycle',
   marker => 'I',
   code => '{ return("same") }',
   source_form => 'bare',
  },
 ]],
 'standalone block projects as lifecycle I with bare provenance',
);

my $explicit_semantic = {%{$explicit->[0][1]}};
my $shorthand_semantic = {%{$shorthand->[0][1]}};
delete $explicit_semantic->{source_form};
delete $shorthand_semantic->{source_form};
is_deeply($shorthand_semantic, $explicit_semantic, 'explicit and shorthand projections are semantically equal');

for my $marker (qw(I LS LE LX E EX IT)) {
 my $ast = parse_source("Top::\n $marker { return(\"$marker\") }\n");
 is($ast->[0][1]{type}, 'lifecycle', "$marker complete-line block retains lifecycle ownership");
 is($ast->[0][1]{marker}, $marker, "$marker marker is preserved");
 ok(!exists($ast->[0][1]{targets}), "$marker is never projected as a bare-edge target");
}

done_testing();

#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();
use LinkedSpec::ActionIR::Contracts ();

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
}

my $typed_contract = slurp_json(File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'typed_source_location_contract.json',
));
is(
 $typed_contract->{contract_id},
 'linkedspec-typed-source-location-v1',
 'loads the frozen typed source-location contract',
);

my $projection_interface = LinkedSpec::ActionIR::Contracts->can(
 'typed_source_projection_rows',
);
ok(
 $projection_interface,
 'Perl ActionIR exposes the frozen internal typed-source projection catalog',
);
diag(
 'expected RED: LinkedSpec::ActionIR::Contracts::typed_source_projection_rows is not implemented yet',
) unless $projection_interface;

SKIP: {
 skip 'future typed-source projection interface is absent', 1
  unless $projection_interface;

 subtest 'all helper projections route through typed values without changing results' => sub {
  my $projection_rows = $projection_interface->();
  is_deeply(
   $projection_rows,
   $typed_contract->{helper_projections},
   'the Perl projection catalog matches all 92 neutral rows exactly',
  );

  my @projection_names = map {
   map { $_->[0] } @{$projection_rows->{$_}}
  } @{$typed_contract->{helper_projection_schema}{families}};
  is(
   scalar(@projection_names),
   $typed_contract->{expected_counts}{helper_projections},
   'the catalog exposes the exact helper count',
  );
  is(
   scalar(keys %{ {map { ($_ => 1) } @projection_names} }),
   scalar(@projection_names),
   'the catalog exposes each helper exactly once',
  );

  $projection_rows->{capture_mark}[0][1] = 'wrong';
  is_deeply(
   $projection_interface->(),
   $typed_contract->{helper_projections},
   'the projection catalog returns a detached immutable snapshot',
  );
  $projection_rows = $projection_interface->();

  my %two_mark_args = map { ($_ => 1) } qw(
   capture_between capture_len_between capture_take_between
   capture_take_between_len mark_copy
  );
  my %one_mark_arg = map { ($_ => 1) } qw(
   capture_from capture_len_from capture_rest_from capture_rest_len_from
   capture_take_len_from capture_take_rest_from capture_take_rest_len_from
   capture_take_until_cursor_from capture_take_until_cursor_len_from
   capture_until_cursor_from capture_until_cursor_len_from mark_capture_slice
   mark_exists mark_here mark_input_end mark_input_start mark_pos
   start_capture_slice_from clear_mark mark_col mark_entry_end
   mark_entry_start mark_line mark_match_end mark_match_start
  );
  my %indexed_arg = map { ($_ => 1) } qw(entry_group match_group);
  my %named_arg = map { ($_ => 1) } qw(entry_has entry_named match_has match_named);
  my %projection_by_name;
  for my $family (@{$typed_contract->{helper_projection_schema}{families}}) {
   for my $row (@{$projection_rows->{$family}}) {
    my ($name, $projection) = @$row;
    $projection_by_name{$name} = $projection;
    my $expression = $two_mark_args{$name} ? "$name(left, right)"
     : $one_mark_arg{$name} ? "$name(probe)"
     : $indexed_arg{$name} ? "$name(0)"
     : $named_arg{$name} ? "$name(named)"
     : $name eq 'capture_until_boundary' ? "$name(Boundary)"
     : $name eq 'input_slice' ? "$name(0, 1)"
     : "$name()";
   my $lowered = LinkedSpec::call_spec_handler_subst('Child', $expression);
   unlike(
    $lowered,
    qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/,
    "$expression remains a supported $family helper",
   );
   like(
    $lowered,
    qr/LinkedSpec::SourceLocation::Runtime::\Q$projection\E\b/,
    "$expression routes through its frozen $projection projection",
   );
   }
  }

  for my $alias (@{$typed_contract->{compatibility_aliases}}) {
   my ($name, $target) = @$alias;
   my $expression = "$name()";
   my $lowered = LinkedSpec::call_spec_handler_subst('Child', $expression);
   like(
    $lowered,
    qr/LinkedSpec::SourceLocation::Runtime::\Q$projection_by_name{$target}\E\b/,
    "$expression retains its result through the canonical $target projection",
   );
  }

  my $mark_contract = slurp_json(File::Spec->catfile(
   $Bin,
   '..',
   'capability_conformance',
   'complete_named_mark_contract.json',
  ));
  my $fixture = $mark_contract->{fixture};
  my %runtime_ctx;
  my $parser = LinkedSpec::Get(
   \$fixture->{spec_source},
   runtime_ctx_ref => \%runtime_ctx,
  );
  ok(ref($parser) eq 'CODE', 'the Unicode projection fixture compiles live');
  my $input = $fixture->{input};
  is_deeply(
   $parser->(\$input),
   $fixture->{expected},
   'live helper projections preserve the complete named-mark result',
  );
  ok(!exists($runtime_ctx{last_error}), 'live helper projections leave runtime diagnostics clear');

  my $source = LinkedSpec::emit_generated_source(
   \$fixture->{spec_source},
   source_identity => 'typed-source-location-perl-contract.spec',
  );
  like(
   $source,
   qr/LinkedSpec::SourceLocation::/,
   'standalone generated source uses the same typed projection route',
  );
  my $package = 'LinkedSpec::TypedSourceLocationPerlContractGenerated';
  my $loaded = eval "package $package; $source; 1";
  ok($loaded, 'standalone generated projection source loads') or diag($@);
  if ($loaded) {
   no strict 'refs';
   $input = $fixture->{input};
   my $generated_result;
   my $execute_ok = eval {
    $generated_result = &{"${package}::Execute"}(\$input);
    1
   };
   ok($execute_ok, 'standalone generated projection execution completes') or diag($@);
   is_deeply(
    $generated_result,
    $fixture->{expected},
    'standalone generated helper projections preserve the exact result',
   ) if $execute_ok;
  }
 };
}

done_testing();

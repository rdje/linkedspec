use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Scalar::Util qw(refaddr);
use Test::More;

use LinkedSpec ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<', $path or die "Could not read '$path': $!";
 local $/;
 return <$fh>
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'callable_signature_contract.json',
);
my $descriptor_contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'outward_descriptor_contract.json',
);
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp($contract_path));
my $descriptor_contract = $json->decode(slurp($descriptor_contract_path));

is($contract->{contract_id}, 'linkedspec-callable-signature-v1', 'loads the adopted callable-signature contract');

my $self_hosted_source = slurp(File::Spec->catfile($Bin, '..', 'specs', 'spec.spec'));
my $self_hosted_parser = LinkedSpec::Get(\$self_hosted_source, top_rule => 'spec_file');
ok(ref($self_hosted_parser) eq 'CODE', 'permanent self-hosted grammar compiles with variadic definition ownership');
my $self_hosted_input = $contract->{fixture}{spec_source};
my $self_hosted_ast = $self_hosted_parser->(\$self_hosted_input);
my @self_hosted_functions = grep {
 ref($_) eq 'HASH' && ($_->{type} // '') eq 'function_definition'
} map { ref($_) eq 'ARRAY' ? @$_ : () } @{ref($self_hosted_ast) eq 'ARRAY' ? $self_hosted_ast : []};
is_deeply(
 [map { $_->{name} } @self_hosted_functions],
 [qw(pair all_values collect)],
 'self-hosted grammar preserves fixed and variadic definitions in source order',
);
is_deeply(
 $self_hosted_functions[2]{signature},
 $contract->{definitions}[2]{signature},
 'self-hosted grammar emits the adopted version-2 signature',
);

my $spec = $contract->{fixture}{spec_source};
my %ctx;
my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1, runtime_ctx_ref => \%ctx);
ok(ref($descriptor) eq 'HASH', 'neutral variadic fixture builds a descriptor');
ok(!exists($ctx{last_error}), 'neutral variadic descriptor build leaves last_error clear');

my $functions = $descriptor->{functions};
ok(ref($functions) eq 'HASH', 'descriptor exposes the function registry');
is_deeply(
 [sort keys %{$functions->{pair}}],
 [sort @{$descriptor_contract->{function_record_keys}}],
 'fixed function retains the exact version-1 outward record shape',
);
is($functions->{pair}{version}, 1, 'fixed function remains version 1');
is_deeply($functions->{pair}{params}, [qw(left right)], 'fixed function retains ordered params');
is($functions->{pair}{arity}, 2, 'fixed function retains exact arity');
ok(!exists($functions->{pair}{signature}), 'fixed function does not gain a signature field');

my $variadic_fields = $contract->{definition_versions}{variadic}{record_fields};
for my $definition (@{$contract->{definitions}}) {
 next unless $definition->{function_version} == 2;
 my $name = $definition->{name};
 my $record = $functions->{$name};
 ok(ref($record) eq 'HASH', "$name variadic function is exposed");
 is_deeply([sort keys %$record], [sort @$variadic_fields], "$name uses the exact version-2 outward record shape");
 is($record->{version}, 2, "$name function record is version 2");
 is_deeply($record->{signature}, $definition->{signature}, "$name preserves the adopted callable signature");
 ok(!exists($record->{params}) && !exists($record->{arity}), "$name does not reinterpret version-1 params/arity");
 for my $field (qw(body_payload body_parse_job)) {
  my $staged = $record->{$field};
  ok(ref($staged) eq 'HASH', "$name $field is present");
  is_deeply($staged->{signature}, $definition->{signature}, "$name $field preserves the same signature");
  ok(!exists($staged->{params}) && !exists($staged->{arity}), "$name $field uses signature instead of params/arity");
 }
}

my $generated_source = '';
my $source_ok = eval {
 LinkedSpec::Get(
  \$spec,
  generate_only => 1,
  dump_parser_source => 1,
  parser_source_ref => \$generated_source,
 );
 1
};
ok($source_ok && length($generated_source), 'variadic fixture generates Perl parser source');
like($generated_source, qr/my \$items = \[/, 'generated source binds extras into a fresh rest array');
unlike($generated_source, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, 'generated source has no unsupported-helper sentinel');

my $parser = LinkedSpec::Get(\$spec);
ok(ref($parser) eq 'CODE', 'neutral variadic fixture compiles to a parser');
my $input = $contract->{fixture}{input};
my $result = $parser->(\$input);
is_deeply($result, $contract->{fixture}{expected}, 'Perl executes every valid neutral variadic call case exactly');
isnt(
 refaddr($result->{rest_only_empty}),
 refaddr($result->{fixed_prefix_empty_rest}{items}),
 'separate invocations receive distinct fresh empty rest arrays',
);

my $ordered_spec = <<'SPEC';
fn all_values(...items) { return(items) }
Top::
 /x/ -> Done {
   value = "";
   set(out, all_values(value = cat(value, "a"), value = cat(value, "b")));
   return([out, value])
 }
Done::
 /x/
SPEC
my $ordered_parser = LinkedSpec::Get(\$ordered_spec);
ok(ref($ordered_parser) eq 'CODE', 'ordered-evaluation fixture compiles');
my $ordered_input = 'xx';
is_deeply(
 $ordered_parser->(\$ordered_input),
 [['a', 'ab'], 'ab'],
 'variadic arguments evaluate exactly once from left to right before rest binding',
);

my %invalid_detail = (
 rest_not_final => qr/invalid user function definition/,
 multiple_rest => qr/invalid user function definition/,
 missing_rest_name => qr/invalid user function definition/,
 suffix_rest_marker => qr/invalid user function definition/,
 rest_marker_name_whitespace => qr/invalid user function definition/,
 duplicate_rest_name => qr/duplicate parameter 'item' in function/,
 reserved_rest_name => qr/parameter 'return' is reserved/,
);
for my $case (@{$contract->{invalid_definition_cases}}) {
 my $bad_spec = 'fn bad('.$case->{signature_source}.") { return(undef) }\nTop::\n /x/\n";
 my %bad_ctx;
 my $bad_descriptor = LinkedSpec::Get(\$bad_spec, return_descriptor => 1, runtime_ctx_ref => \%bad_ctx);
 ok(!defined($bad_descriptor), "$case->{id} definition is rejected");
 is($bad_ctx{last_error}{owner_stage}, 'compiler_pipeline:function_registry', "$case->{id} is owned by function_registry");
 like($bad_ctx{last_error}{detail} // '', $invalid_detail{$case->{id}}, "$case->{id} reports a stable definition diagnostic");
}

my $wrong_arity_spec = <<'SPEC';
fn pair(left, right) { return([left, right]) }
fn collect(prefix, ...items) { return(items) }
Top::
 /x/ -> Done { return([pair(1, 2, 3), collect()]) }
Done::
 /x/
SPEC
my $wrong_arity_descriptor = LinkedSpec::Get(\$wrong_arity_spec, return_descriptor => 1);
ok(ref($wrong_arity_descriptor) eq 'HASH', 'wrong-arity calls retain the diagnostic descriptor path');
my $wrong_arity_meta = $wrong_arity_descriptor->{spec}{Top}{meta}{action_rewriter};
is($wrong_arity_meta->{raw_perl_dependency_count} || 0, 0, 'wrong arity never falls back to raw Perl');
is_deeply(
 [sort @{$wrong_arity_meta->{unresolved_helpers} || []}],
 [qw(collect pair)],
 'fixed-extra and variadic-missing-prefix calls report their registered callees',
);

done_testing();

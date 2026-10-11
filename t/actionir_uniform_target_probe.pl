use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

my ($mode, $first) = @ARGV;
die 'usage: probe native|public array|hash' unless defined($mode) && $mode =~ /\A(?:native|public)\z/
 && defined($first) && $first =~ /\A(?:array|hash)\z/;
my $other = $first eq 'array' ? 'hash' : 'array';
my $json = JSON::PP->new->canonical->allow_nonref;
if ($mode eq 'native') {
 my @cases = (
  ['first', "$first(item)", $first, 'scalar'],
  ['other', "$other(item)", $other, 'scalar'],
  ['first-again', "$first(item)", $first, 'scalar'],
  ['other-again', "$other(item)", $other, 'scalar'],
  ['stale-wrong', "$first(item)", $other, 'scalar'],
  ['empty-wrong', "$first(item)", '', 'scalar'],
  ['empty-literal', '(item)', '', 'scalar'],
  ['literal-dot', 'array.(item)', 'array.', 'scalar'],
  ['dot-lookalike', 'arrayX(item)', 'array.', 'scalar'],
  ['bare', 'item', $other, 'array'],
  ['undefined-target', undef, $other, 'scalar'],
  ['undefined-container', "$first(item)", undef, 'scalar'],
  ['spaced', "$other ( item )", $other, 'scalar'],
  ['compound', "$other(item.other)", $other, 'scalar'],
  ['kind-array', "$other(item)", $other, 'array'],
  ['kind-undefined', "$other(item)", $other, undef],
  ['kind-zero', "$other(item)", $other, '0'],
  ['effect', "$other(item)", $other, 'scalar'],
  ['fatal', "$other(item)", $other, 'scalar'],
  ['trailing-newline', "$other(item)\n", $other, 'scalar'],
 );
 my @rows;
 for my $case (@cases) {
  my ($id, $input, $container, $kind) = @$case;
  my ($value, $error, $success_error);
  my @calls;
  my $fatal = bless {}, 'UniformTargetProbe::Fatal';
  my $deps = {bare_symbol_kind => sub {
   my $context = !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
   push @calls, {argument => $_[0], context => $context, incoming_error => $@};
   $_[0] .= '!' if $id eq 'effect';
   $@ = 'target success';
   die $fatal if $id eq 'fatal';
   return $kind;
  }};
  eval { $@ = 'target incoming';
   $value = LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol($input, $container, $deps);
   $success_error = $@; 1;
  } or $error = $@;
  push @rows, {id => $id, input => $case->[1], container => $container, kind => $kind,
   value => $value, caller_after => $input, calls => \@calls, success_error => $success_error,
   error => ref($error) ? {type => ref($error), actual => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
 }
 print $json->encode({mode => $mode, first => $first, rows => \@rows}), "\n";
 exit 0;
}

# Warm the exact private interpolation before loading the public facade. Public
# observations below are actual Toolbox calls; the warm-up is explicit state setup.
my $warm = LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol(
 "$first(item)", $first, {bare_symbol_kind => sub { return 'scalar' }});
require LinkedSpec;
open my $fh, '<', 'capability_conformance/uniform_binding_contract.json' or die $!;
my $contract = $json->decode(do { local $/; <$fh> });
close $fh or die $!;
my @lowering;
for my $action ('push(array(item), "x")', 'set_key(hash(item), "key", "x")',
 'push(item, "x")', 'set_key(item, "key", "x")') {
 my ($value, $error);
 eval { $value = LinkedSpec::call_spec_handler_subst('Top', $action); 1 } or $error = $@;
 push @lowering, {action => $action, value => $value, error => $error};
}
my $fixture = $contract->{fixture};
my $source = $fixture->{spec_source};
my (%ctx, $value, $error, $generated, $generated_value, $generated_error);
my $parser;
eval { $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
 my $input = $fixture->{input}; $value = $parser->(\$input) if ref($parser) eq 'CODE'; 1;
} or $error = $@;
eval {
 $generated = LinkedSpec::emit_generated_source(\$source, source_identity => 'uniform-target-probe.spec');
 my $loaded = eval "package UniformTargetProbe::Generated; $generated; 1";
 die $@ unless $loaded;
 my $input = $fixture->{input};
 $generated_value = UniformTargetProbe::Generated::Execute(\$input); 1;
} or $generated_error = $@;
print $json->encode({mode => $mode, first => $first, warm => $warm, lowering => \@lowering,
 parser_type => ref($parser), value => $value, error => $error, last_error => $ctx{last_error},
 generated => $generated, generated_value => $generated_value, generated_error => $generated_error}), "\n";

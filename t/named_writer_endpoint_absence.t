use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.49.1 — local-match writer endpoint presence.
my $json=JSON::PP->new->canonical->allow_nonref;
open my $file,'<:encoding(UTF-8)','tests/fixtures/named_writer_endpoint_absence.json' or die $!;
my $text;{local $/;$text=<$file>}close $file or die $!;
my $sequence=0;
for my $fixture (@{$json->decode($text)}) {
 subtest $fixture->{name} => sub {
  my $source=$fixture->{source};my (%context,@native_warnings);
  my $native;
  {local $SIG{__WARN__}=sub {push @native_warnings,@_};
   $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
  }
  ok(ref($native) eq 'CODE','native parser builds');
  return unless ref($native) eq 'CODE';
  my $input=$fixture->{input};my ($actual,$error);
  {local $SIG{__WARN__}=sub {push @native_warnings,@_};
   $actual=eval {$native->(\$input)};$error=$@;
  }
  ok(!$error && !defined($context{last_error}),'native writer succeeds without handler error');
  is($json->encode($actual),$json->encode($fixture->{expected}),'native values, types, effects and writer state');
  is(pos($input),$fixture->{expected_cursor},'native Unicode cursor');
  is_deeply(\@native_warnings,[],'native missing state never warns');
  my (@fresh_warnings,$emitted,$loaded,$load_error);
  my $package='LinkedSpec::NamedWriterEndpointTest'.++$sequence;
  {local $SIG{__WARN__}=sub {push @fresh_warnings,@_};
   $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'named-writer-endpoint-absence.spec');
   $loaded=eval "package $package; $emitted; 1";$load_error=$@;
  }
  ok($loaded,'emitted parser loads independently') or diag("$load_error");
  return unless $loaded;
  no strict 'refs';
  my $metadata=&{$package.'::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version},2,'public format stays two');
  my $fresh_input=$fixture->{input};my ($fresh,$fresh_error);
  {local $SIG{__WARN__}=sub {push @fresh_warnings,@_};
   $fresh=eval {&{$package.'::Execute'}(\$fresh_input)};$fresh_error=$@;
  }
  is("$fresh_error",'','fresh writer succeeds without typed span error');
  is($json->encode($fresh),$json->encode($fixture->{expected}),'fresh values, types, effects and writer state');
  is(pos($fresh_input),$fixture->{expected_cursor},'fresh Unicode cursor');
  is_deeply(\@fresh_warnings,[],'fresh unavailable endpoint never computes missing operands');
 };
}
done_testing();

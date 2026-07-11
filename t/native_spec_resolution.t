use strict;
use warnings;
use utf8;

use Encode qw(decode FB_CROAK LEAVE_SRC);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use JSON::PP qw(decode_json);
use Test::More;

use lib File::Spec->catdir($Bin, '..', 'perl');
use LinkedSpec::SpecLoader ();

my $repo_root = File::Spec->rel2abs(File::Spec->catdir($Bin, '..'));
my $contract_path = File::Spec->catfile(
 $repo_root,
 'capability_conformance',
 'native_spec_resolution_contract.json',
);
open my $contract_fh, '<:raw', $contract_path or die "cannot read $contract_path: $!";
local $/;
my $contract_bytes = <$contract_fh>;
close $contract_fh or die "cannot close $contract_path: $!";
my $contract = decode_json($contract_bytes);

sub fixture_path {
 my ($root, $portable_path) = @_;
 return File::Spec->catfile($root, split m{/}, $portable_path, -1)
}

sub write_entry {
 my ($root, $entry) = @_;
 my $path = fixture_path($root, $entry->{path});
 if ($entry->{kind} eq 'file') {
  make_path(File::Spec->catdir((File::Spec->splitpath($path))[1]));
  open my $fh, '>:raw', $path or die "cannot write $path: $!";
  print {$fh} 'fixture';
  close $fh or die "cannot close $path: $!";
 } elsif ($entry->{kind} eq 'directory' || $entry->{kind} eq 'non_regular') {
  make_path($path);
 } else {
  die "unsupported fixture kind '$entry->{kind}'";
 }
}

sub bytes_from_hex {
 my ($hex) = @_;
 return pack 'H*', $hex
}

sub capture_failure {
 my ($operation) = @_;
 my ($stdout, $stderr) = ('', '');
 local *STDOUT;
 local *STDERR;
 open STDOUT, '>', \$stdout or die "cannot capture stdout: $!";
 open STDERR, '>', \$stderr or die "cannot capture stderr: $!";
 my $ok = eval { $operation->(); 1 };
 my $error = $@;
 return ($ok, $error, $stdout, $stderr)
}

subtest 'consumes every neutral name-validation case' => sub {
 foreach my $case (@{$contract->{name_validation_cases}}) {
  my $request = LinkedSpec::SpecLoader::name_request($case->{value});
  my ($ok, $error) = capture_failure(sub {
   LinkedSpec::SpecLoader::validate_spec_request($request)
  });
  if ($case->{expect}{status} eq 'ok') {
   ok($ok, "$case->{id}: accepted") or diag("$error");
  } else {
   ok(!$ok, "$case->{id}: rejected");
   isa_ok($error, 'LinkedSpec::SpecLoader::Error', "$case->{id}: structured error");
   is($error->stage, $case->{expect}{stage}, "$case->{id}: stage");
   is($error->code, $case->{expect}{code}, "$case->{id}: code");
  }
 }
};

subtest 'consumes every neutral resolution and file-kind case' => sub {
 foreach my $case (@{$contract->{resolution_cases}}) {
  my $scratch = tempdir('linkedspec-perl-spec-resolution-XXXXXX', TMPDIR => 1, CLEANUP => 1);
  write_entry($scratch, $_) for @{$case->{entries}};
  my $cwd = fixture_path($scratch, $case->{cwd});
  make_path($cwd);
  my $options = LinkedSpec::SpecLoader::load_options(
   cwd => $cwd,
   search_roots => [map { fixture_path($scratch, $_) } @{$case->{search_roots}}],
  );
  my $request = $case->{request}{kind} eq 'name'
   ? LinkedSpec::SpecLoader::name_request($case->{request}{value})
   : LinkedSpec::SpecLoader::path_request($case->{request}{value});
  my ($resolved, $error);
  my $ok = eval { $resolved = LinkedSpec::SpecLoader::resolve_spec($request, $options); 1 };
  $error = $@;
  if ($case->{expect}{status} eq 'ok') {
   ok($ok, "$case->{id}: resolved") or diag("$error");
   is($resolved->path, fixture_path($scratch, $case->{expect}{path}), "$case->{id}: path");
   is($resolved->origin, $case->{expect}{origin}, "$case->{id}: origin");
  } else {
   ok(!$ok, "$case->{id}: rejected");
   isa_ok($error, 'LinkedSpec::SpecLoader::Error', "$case->{id}: structured error");
   is($error->stage, $case->{expect}{stage}, "$case->{id}: stage");
   is($error->code, $case->{expect}{code}, "$case->{id}: code");
   my $expected_path = exists($case->{expect}{resolved_path})
    ? fixture_path($scratch, $case->{expect}{resolved_path})
    : undef;
   is($error->resolved_path, $expected_path, "$case->{id}: resolved non-file");
  }
 }
};

subtest 'consumes every neutral strict-UTF-8 case' => sub {
 foreach my $case (@{$contract->{text_cases}}) {
  my $scratch = tempdir('linkedspec-perl-spec-text-XXXXXX', TMPDIR => 1, CLEANUP => 1);
  my $path = File::Spec->catfile($scratch, 'source.spec');
  open my $fh, '>:raw', $path or die "cannot write $path: $!";
  print {$fh} bytes_from_hex($case->{bytes_hex});
  close $fh or die "cannot close $path: $!";
  my ($loaded, $error);
  my $ok = eval {
   $loaded = LinkedSpec::SpecLoader::load_spec(
    LinkedSpec::SpecLoader::path_request('source.spec'),
    LinkedSpec::SpecLoader::load_options(cwd => $scratch),
   );
   1
  };
  $error = $@;
  if ($case->{expect}{status} eq 'ok') {
   ok($ok, "$case->{id}: loaded") or diag("$error");
   is($loaded->source_text, $case->{expect}{text}, "$case->{id}: exact text");
  } else {
   ok(!$ok, "$case->{id}: rejected");
   isa_ok($error, 'LinkedSpec::SpecLoader::Error', "$case->{id}: structured error");
   is($error->stage, $case->{expect}{stage}, "$case->{id}: stage");
   is($error->code, $case->{expect}{code}, "$case->{id}: code");
  }
 }
};

subtest 'composes full source compilation execution and identity' => sub {
 my $scratch = tempdir('linkedspec-perl-spec-pipeline-XXXXXX', TMPDIR => 1, CLEANUP => 1);
 my $specs = File::Spec->catdir($scratch, 'specs');
 make_path($specs);
 my $source = <<'SPEC';
fn label() {return("hit")}

Top::
 /x/ -> Done { return(label()) }
Done::
 /x/
SPEC
 my $path = File::Spec->catfile($specs, 'Demo.spec');
 open my $fh, '>:encoding(UTF-8)', $path or die "cannot write $path: $!";
 print {$fh} $source;
 close $fh or die "cannot close $path: $!";
 my $loaded = LinkedSpec::SpecLoader::load_and_compile_spec(
  LinkedSpec::SpecLoader::name_request('Demo'),
  LinkedSpec::SpecLoader::load_options(
   cwd => File::Spec->catdir($scratch, 'cwd'),
   search_roots => [$specs],
  ),
 );
 is($loaded->loaded->source_text, $source, 'exact loaded source retained');
 is($loaded->loaded->resolved->path, $path, 'resolved path retained');
 is($loaded->runtime_ctx->{spec_name}, 'Demo', 'runtime context retains requested name');
 is($loaded->runtime_ctx->{spec_path}, $path, 'runtime context retains resolved path');
 my $input = 'x';
 is($loaded->compiled->(\$input), 'hit', 'compiled parser executes staged user function');
};

subtest 'projects parse validation and missing failures as structured records' => sub {
 my $scratch = tempdir('linkedspec-perl-spec-errors-XXXXXX', TMPDIR => 1, CLEANUP => 1);
 foreach my $entry (
  ['parse.spec', "not a spec\n"],
  ['validation.spec', "Only:\n /x/\n"],
 ) {
  my $path = File::Spec->catfile($scratch, $entry->[0]);
  open my $fh, '>:raw', $path or die "cannot write $path: $!";
  print {$fh} $entry->[1];
  close $fh or die "cannot close $path: $!";
 }
 my $options = LinkedSpec::SpecLoader::load_options(cwd => $scratch);
 my (undef, $parse_error) = capture_failure(sub {
  LinkedSpec::SpecLoader::load_and_compile_spec(
   LinkedSpec::SpecLoader::path_request('parse.spec'),
   $options,
  )
 });
 is($parse_error->stage, 'parse_spec', 'parse failure stage');
 is($parse_error->code, 'spec_parse_failed', 'parse failure code');
 my (undef, $validation_error) = capture_failure(sub {
  LinkedSpec::SpecLoader::load_and_compile_spec(
   LinkedSpec::SpecLoader::path_request('validation.spec'),
   $options,
  )
 });
 is($validation_error->stage, 'validate_spec', 'validation failure stage');
 is($validation_error->code, 'spec_validation_failed', 'validation failure code');
 my (undef, $missing) = capture_failure(sub {
  LinkedSpec::SpecLoader::resolve_spec(
   LinkedSpec::SpecLoader::name_request('Missing'),
   $options,
  )
 });
 is_deeply(
  $missing->to_hash,
  {
   type => 'spec_pipeline_error',
   stage => 'resolve_spec_path',
   code => 'spec_path_not_found',
   summary => 'Spec path not found',
   request_kind => 'name',
   requested => 'Missing',
  },
  'missing name projects exact neutral error record',
 );
};

done_testing;

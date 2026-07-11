#------------------------------------------------------------------------------
# Package: LinkedSpec::SpecLoader
# Purpose: Portable native name/path resolution, strict UTF-8 loading, and
#          composition into the Perl reference compiler.
#------------------------------------------------------------------------------
package LinkedSpec::SpecLoader;

use 5.010;
use strict;
use warnings;
use utf8;

use Encode qw(decode FB_CROAK LEAVE_SRC);
use File::Spec ();
use Scalar::Util qw(blessed);

sub name_request {
 my ($name) = @_;
 return LinkedSpec::SpecLoader::Request->new('name', $name)
}

sub path_request {
 my ($path) = @_;
 return LinkedSpec::SpecLoader::Request->new('path', $path)
}

sub load_options {
 my (%args) = @_;
 return LinkedSpec::SpecLoader::Options->new(%args)
}

sub validate_spec_request {
 my ($request) = @_;
 _require_request($request);
 return _validate_name_request($request) if $request->kind eq 'name';
 return _validate_path_request($request)
}

sub resolve_spec {
 my ($request, $options) = @_;
 _require_request($request);
 $options = _normalize_options($options);
 validate_spec_request($request);

 my $first_non_regular;
 foreach my $candidate (_candidates($request, $options)) {
  my ($path, $origin) = @$candidate;
  return LinkedSpec::SpecLoader::ResolvedSpec->new(
   request => $request,
   path => $path,
   origin => $origin,
  ) if -f $path;
  $first_non_regular //= $path if -e $path;
 }

 _throw_error(
  $request,
  stage => 'resolve_spec_path',
  code => 'spec_path_not_file',
  summary => 'Spec path is not a file',
  resolved_path => $first_non_regular,
 ) if defined $first_non_regular;
 _throw_error(
  $request,
  stage => 'resolve_spec_path',
  code => 'spec_path_not_found',
  summary => 'Spec path not found',
 )
}

sub load_spec {
 my ($request, $options) = @_;
 my $resolved = resolve_spec($request, $options);
 my $path = $resolved->path;
 open my $fh, '<:raw', $path or _throw_error(
  $request,
  stage => 'load_spec_content',
  code => 'spec_read_failed',
  summary => 'Unable to read spec file',
  resolved_path => $path,
  detail => "$!",
 );
 local $/;
 my $bytes = <$fh>;
 unless (close $fh) {
  _throw_error(
   $request,
   stage => 'load_spec_content',
   code => 'spec_read_failed',
   summary => 'Unable to read spec file',
   resolved_path => $path,
   detail => "$!",
  );
 }
 my $source_text = eval { decode('UTF-8', $bytes, FB_CROAK | LEAVE_SRC) };
 if ($@) {
  _throw_error(
   $request,
   stage => 'decode_spec_content',
   code => 'invalid_utf8',
   summary => 'Spec file is not valid UTF-8',
   resolved_path => $path,
   detail => "$@",
  );
 }
 return LinkedSpec::SpecLoader::LoadedSpec->new(
  resolved => $resolved,
  source_text => $source_text,
 )
}

sub load_and_compile_spec {
 my ($request, $options, $compile_options) = @_;
 my $loaded = load_spec($request, $options);
 my $source_text = $loaded->source_text;
 if ($source_text =~ /^\x{FEFF}/u) {
  _throw_error(
   $request,
   stage => 'parse_spec',
   code => 'spec_parse_failed',
   summary => 'Unable to parse spec',
   resolved_path => $loaded->resolved->path,
   detail => 'leading source BOM is preserved and not valid rule syntax',
  );
 }

 require LinkedSpec;
 my %compile = ref($compile_options) eq 'HASH' ? %$compile_options : ();
 my $runtime_ctx = {
  spec_name => $request->kind eq 'name' ? $request->requested : undef,
  spec_path => $loaded->resolved->path,
 };
 $compile{runtime_ctx_ref} = $runtime_ctx;
 $compile{_preserve_runtime_ctx_spec_identity} = 1;
 my $compiled = LinkedSpec::Get(\$source_text, %compile);
 unless (defined($compiled) && ref($compiled) eq 'CODE') {
  my $runtime_error = ref($runtime_ctx->{last_error}) eq 'HASH'
   ? $runtime_ctx->{last_error}
   : {};
  my ($stage, $code) = _project_compile_failure($runtime_error);
  _throw_error(
   $request,
   stage => $stage,
   code => $code,
   summary => $stage eq 'parse_spec'
    ? 'Unable to parse spec'
    : $stage eq 'validate_spec'
     ? 'Spec validation failed'
     : 'Spec compilation failed',
   resolved_path => $loaded->resolved->path,
   detail => defined($runtime_error->{detail}) && length($runtime_error->{detail})
    ? $runtime_error->{detail}
    : defined($runtime_error->{summary})
     ? $runtime_error->{summary}
     : 'LinkedSpec::Get returned no parser',
  );
 }
 return LinkedSpec::SpecLoader::LoadedCompiledSpec->new(
  loaded => $loaded,
  compiled => $compiled,
  runtime_ctx => $runtime_ctx,
 )
}

sub _project_compile_failure {
 my ($runtime_error) = @_;
 my $owner_stage = $runtime_error->{owner_stage} // '';
 my $stage = $runtime_error->{stage} // '';
 my $summary = $runtime_error->{summary} // '';
 my $combined = "$owner_stage $stage";
 return ('parse_spec', 'spec_parse_failed')
  if $combined =~ /(?:bootstrap|parse)/i
  || $summary =~ /must start with a rule definition/i;
 return ('validate_spec', 'spec_validation_failed')
  if $combined =~ /validat/i;
 return ('compile_spec', 'spec_compile_failed')
}

sub _validate_name_request {
 my ($request) = @_;
 my $name = $request->requested;
 my @components = split m{/}, $name, -1;
 my $invalid = !length($name)
  || $name !~ /\S/u
  || $name =~ /^\s|\s$/u
  || $name =~ /\p{Cc}/u
  || $name =~ m{^/|^[A-Za-z]:/|\\}
  || grep { $_ eq '' || $_ eq '.' || $_ eq '..' } @components;
 _throw_error(
  $request,
  stage => 'validate_spec_name',
  code => 'invalid_spec_name',
  summary => 'Invalid spec name',
 ) if $invalid;
 return 1
}

sub _validate_path_request {
 my ($request) = @_;
 my $path = $request->requested;
 _throw_error(
  $request,
  stage => 'validate_spec_path',
  code => 'invalid_spec_path',
  summary => 'Invalid spec path',
 ) if !length($path) || $path =~ /\0/;
 return 1
}

sub _candidates {
 my ($request, $options) = @_;
 my @raw;
 if ($request->kind eq 'path') {
  my $path = File::Spec->file_name_is_absolute($request->requested)
   ? File::Spec->canonpath($request->requested)
   : File::Spec->canonpath(File::Spec->catfile($options->cwd, $request->requested));
  push @raw, [$path, 'path_exact'];
 } else {
  my $filename = $request->requested =~ /\.spec\z/
   ? $request->requested
   : $request->requested . '.spec';
  push @raw, [_named_path($options->cwd, $request->requested), 'cwd_exact'];
  push @raw, [_named_path($options->cwd, $filename), 'cwd_spec_suffix'];
  my $roots = $options->search_roots;
  for my $index (0 .. $#$roots) {
   push @raw, [_named_path($roots->[$index], $filename), "search_root:$index"];
  }
 }
 my %seen;
 return grep { !$seen{$_->[0]}++ } @raw
}

sub _named_path {
 my ($root, $portable_path) = @_;
 return File::Spec->canonpath(File::Spec->catfile($root, split m{/}, $portable_path, -1))
}

sub _normalize_options {
 my ($options) = @_;
 return $options if blessed($options) && $options->isa('LinkedSpec::SpecLoader::Options');
 return load_options() unless defined $options;
 return load_options(%$options) if ref($options) eq 'HASH';
 die 'SpecLoader options must be a LinkedSpec::SpecLoader::Options or hash reference'
}

sub _require_request {
 my ($request) = @_;
 die 'SpecLoader request must be a LinkedSpec::SpecLoader::Request'
  unless blessed($request) && $request->isa('LinkedSpec::SpecLoader::Request')
}

sub _throw_error {
 my ($request, %args) = @_;
 die LinkedSpec::SpecLoader::Error->new(
  type => 'spec_pipeline_error',
  request_kind => $request->kind,
  requested => $request->requested,
  %args,
 )
}

package LinkedSpec::SpecLoader::Request;

use strict;
use warnings;

sub new {
 my ($class, $kind, $requested) = @_;
 die "SpecLoader request kind must be 'name' or 'path'"
  unless defined($kind) && ($kind eq 'name' || $kind eq 'path');
 die 'SpecLoader requested value must be a defined non-reference scalar'
  unless defined($requested) && !ref($requested);
 return bless {kind => $kind, requested => "$requested"}, $class
}

sub kind { return $_[0]{kind} }
sub requested { return $_[0]{requested} }

package LinkedSpec::SpecLoader::Options;

use strict;
use warnings;

sub new {
 my ($class, %args) = @_;
 my $cwd = defined($args{cwd}) ? $args{cwd} : '.';
 my $roots = ref($args{search_roots}) eq 'ARRAY' ? $args{search_roots} : [];
 die 'SpecLoader cwd must be a defined non-reference scalar'
  unless defined($cwd) && !ref($cwd);
 die 'SpecLoader search roots must contain only defined non-reference scalars'
  if grep { !defined($_) || ref($_) } @$roots;
 return bless {cwd => "$cwd", search_roots => [map { "$_" } @$roots]}, $class
}

sub cwd { return $_[0]{cwd} }
sub search_roots { return [@{$_[0]{search_roots}}] }

package LinkedSpec::SpecLoader::ResolvedSpec;

use strict;
use warnings;

sub new { my ($class, %args) = @_; return bless {%args}, $class }
sub request { return $_[0]{request} }
sub path { return $_[0]{path} }
sub origin { return $_[0]{origin} }

package LinkedSpec::SpecLoader::LoadedSpec;

use strict;
use warnings;

sub new { my ($class, %args) = @_; return bless {%args}, $class }
sub resolved { return $_[0]{resolved} }
sub source_text { return $_[0]{source_text} }

package LinkedSpec::SpecLoader::LoadedCompiledSpec;

use strict;
use warnings;

sub new { my ($class, %args) = @_; return bless {%args}, $class }
sub loaded { return $_[0]{loaded} }
sub compiled { return $_[0]{compiled} }
sub runtime_ctx { return $_[0]{runtime_ctx} }

package LinkedSpec::SpecLoader::Error;

use strict;
use warnings;
use overload '""' => sub { return $_[0]{summary} }, fallback => 1;

sub new { my ($class, %args) = @_; return bless {%args}, $class }

sub to_hash {
 my ($self) = @_;
 return {
  map { $_ => $self->{$_} }
  grep { defined $self->{$_} }
  qw(type stage code summary request_kind requested resolved_path detail)
 }
}

sub stage { return $_[0]{stage} }
sub code { return $_[0]{code} }
sub summary { return $_[0]{summary} }
sub request_kind { return $_[0]{request_kind} }
sub requested { return $_[0]{requested} }
sub resolved_path { return $_[0]{resolved_path} }
sub detail { return $_[0]{detail} }

1;

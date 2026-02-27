package LinkedSpec::Resolver;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::Trace ();

use constant {
 DUMP_NONE   => LinkedSpec::Trace::DUMP_NONE(),
 DUMP_LOW    => LinkedSpec::Trace::DUMP_LOW(),
 DUMP_MEDIUM => LinkedSpec::Trace::DUMP_MEDIUM(),
};

sub validate_spec_name {
 my ($spec_name, $trace_scope) = @_;
 unless (defined $spec_name && !ref($spec_name) && $spec_name =~ /\S/o && $spec_name !~ /^\s|\s$/o && $spec_name !~ /[[:cntrl:]]/o) {
  LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Invalid spec name", "spec argument is undefined, empty, whitespace-only, non-scalar, contains control byte, or has leading/trailing whitespace");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'validate_spec_name' }, DUMP_LOW);
  return 0;
 }

 return 1;
}

sub _resolve_local_spec_path {
 my ($spec_name) = @_;
 return undef unless defined $spec_name && length $spec_name;

 return $spec_name if -f $spec_name;
 my $spec_file = $spec_name =~ /\.spec$/o ? $spec_name : "$spec_name.spec";
 return $spec_file if -f $spec_file;

 my $candidate;
 my $ok = eval {
  require Cwd;
  require File::Basename;
  require File::Spec;

  my $inc_key = __PACKAGE__;
  $inc_key =~ s{::}{/}go;
  $inc_key .= '.pm';
  my $module_path = Cwd::abs_path($INC{$inc_key});
  my $module_dir  = (File::Basename::fileparse($module_path))[1];
  my $root_dir    = Cwd::realpath(File::Spec->catdir($module_dir, File::Spec->updir(), File::Spec->updir()));
  my $local_spec  = File::Spec->catfile($root_dir, 'specs', $spec_file);
  $candidate      = $local_spec if -f $local_spec;
  1;
 };

 return $candidate if $ok && $candidate;

 return undef;
}

sub resolve_spec_path {
 my ($spec_name, $trace_scope) = @_;

 my $spec_path = _resolve_local_spec_path($spec_name);
 LinkedSpec::Trace::trace_decision('get_parser_local_resolution', defined($spec_path) ? 1 : 0, defined($spec_path) ? "resolved=$spec_path" : 'local resolution miss', DUMP_MEDIUM);
 my $is_explicit_path = ($spec_name =~ m{[/\\]}o);
 my $is_explicit_spec_name = ($spec_name =~ /\.spec$/o);
 unless ($spec_path) {
  if ($is_explicit_path || $is_explicit_spec_name) {
   if (-e $spec_name && !-f $spec_name) {
    my $path_type = -d $spec_name ? 'directory' : 'non-regular';
    LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path is not a file", "spec='$spec_name' resolved='$spec_name' type='$path_type'");
    LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'explicit_path_type', path_type => $path_type }, DUMP_LOW);
    return undef;
   }
   LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path not found", "spec='$spec_name' resolved='<undef>'");
   LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'explicit_path_missing' }, DUMP_LOW);
   return undef;
  }
 }
 unless ($spec_path) {
  LinkedSpec::Trace::trace_decision('get_parser_pathsearch_fallback', 1, "attempting PathSearch for '$spec_name'", DUMP_MEDIUM);
  my $ok = eval {require PathSearch; 1};
  unless ($ok) {
   LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Unable to resolve spec '$spec_name'", "PathSearch load failed: $@");
   LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'pathsearch_load' }, DUMP_LOW);
   return undef;
  }
  my $resolved_spec_path = eval { PathSearch->go($spec_name, 'spec') };
  if ($@) {
   LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Unable to resolve spec '$spec_name'", "PathSearch runtime failure: $@");
   LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'pathsearch_runtime' }, DUMP_LOW);
   return undef;
  }
  $spec_path = $resolved_spec_path;
  LinkedSpec::Trace::trace_decision('get_parser_pathsearch_result', defined($spec_path) ? 1 : 0, defined($spec_path) ? "resolved=$spec_path" : 'PathSearch returned undef', DUMP_MEDIUM);
 }
 if ($spec_path && -e $spec_path && !-f $spec_path) {
  my $path_type = -d $spec_path ? 'directory' : 'non-regular';
  LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path is not a file", "spec='$spec_name' resolved='$spec_path' type='$path_type'");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'resolved_path_type', path_type => $path_type }, DUMP_LOW);
  return undef;
 }

 unless ($spec_path && -f $spec_path) {
  LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path not found", "spec='$spec_name' resolved='".($spec_path // '<undef>')."'");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'resolved_path_missing' }, DUMP_LOW);
  return undef;
 }

 return $spec_path;
}

sub load_spec_content {
 my ($spec_path, $trace_scope) = @_;

 open(my $f, '<', $spec_path) or do {
  LinkedSpec::Trace::log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Unable to open spec file '$spec_path'", "OS Error: $!");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'open_spec_file', spec_path => $spec_path }, DUMP_LOW);
  return undef;
 };
 local $/;
 my $content = <$f>;
 close($f);

 return $content;
}

1;

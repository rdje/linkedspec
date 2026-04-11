#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
#------------------------------------------------------------------------------
# Package: PPlugin
# Purpose: Legacy `.plg` discovery, parsing, lookup, and execution adapter kept
#          for compatibility while LinkedSpec grows explicit plugin APIs.
#------------------------------------------------------------------------------
package PPlugin;

use 5.010;
use Cwd ();
use File::Basename ();
use File::Spec ();

 #------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Validate and return one injected legacy runtime dependency callback.
# Args    : ($deps, $name)
# Returns : coderef dependency callback
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(PPlugin::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

#------------------------------------------------------------------------------
# Function: _plugin_project_root
# Purpose : Resolve the project root used for legacy plugin-file discovery.
# Args    : ()
# Returns : absolute project-root path
#------------------------------------------------------------------------------
sub _plugin_project_root {
 my $module_path = Cwd::abs_path($INC{__PACKAGE__.'.pm'});
 my $module_dir = (File::Basename::fileparse($module_path))[1];
 return Cwd::realpath(File::Spec->catdir($module_dir, File::Spec->updir()))
}

#------------------------------------------------------------------------------
# Function: _legacy_plugin_search_roots
# Purpose : Build the ordered legacy search roots for `.plg` file discovery.
# Args    : ($cwd_root, $project_root)
# Returns : ordered deduped root list
#------------------------------------------------------------------------------
sub _legacy_plugin_search_roots {
 my ($cwd_root, $project_root) = @_;
 $cwd_root = File::Spec->rel2abs('.') unless defined $cwd_root;
 $project_root = _plugin_project_root() unless defined $project_root;

 my @roots = (
  $cwd_root,
  File::Spec->catdir($project_root, 'plugin'),
 );
 my %seen;
 return grep { defined($_) && length($_) && !$seen{$_}++ } @roots
}

#------------------------------------------------------------------------------
# Function: _legacy_plugin_files
# Purpose : Enumerate legacy `.plg` files across the configured search roots.
# Args    : (@roots)
# Returns : ordered deduped absolute plugin-file list
#------------------------------------------------------------------------------
sub _legacy_plugin_files {
 my @roots = @_;
 @roots = _legacy_plugin_search_roots() unless @roots;

 my @plugin_list;
 foreach my $root (@roots) {
  next unless defined $root && -d $root;
  opendir(my $dh, $root) or next;
  my @entries = sort grep { /\.plg\z/ && -f File::Spec->catfile($root, $_) } readdir($dh);
  closedir($dh);
  push @plugin_list, map { File::Spec->catfile($root, $_) } @entries;
 }

 my %seen;
 return grep { !$seen{$_}++ } @plugin_list
}

#------------------------------------------------------------------------------
# Function: _read_plugin_file
# Purpose : Read one legacy plugin file with explicit IO instead of relying on
#           global diamond-reader state.
# Args    : ($plugin_file)
# Returns : ($content, undef) on success, (undef, $error_message) on failure
#------------------------------------------------------------------------------
sub _read_plugin_file {
 my ($plugin_file) = @_;
 return (undef, "plugin file path is undefined")
  unless defined($plugin_file) && length($plugin_file);

 open(my $fh, '<', $plugin_file)
  or return (undef, "unable to read plugin file '$plugin_file': $!");
 local $/;
 my $content = <$fh>;
 close($fh)
  or return (undef, "unable to close plugin file '$plugin_file': $!");

 $content = '' unless defined $content;
 return ($content, undef)
}

#------------------------------------------------------------------------------
# Function: _build_plugin_registry
# Purpose : Parse discovered `.plg` files and build the legacy name-to-coderef
#           registry consumed by compatibility callers.
# Args    : ($get, @plugin_list)
# Returns : hashref plugin registry
#------------------------------------------------------------------------------
sub _build_plugin_registry {
 my ($get, @plugin_list) = @_;
 die "(PPlugin::_build_plugin_registry) -E- parser callback must be CODE"
  unless ref($get) eq 'CODE';

 my $saved_err = $@;
 my @plugins;
 foreach my $cplugin (@plugin_list) {
  my ($content, $read_err) = _read_plugin_file($cplugin);
  if (defined($read_err) && length($read_err)) {
   print "(PPlugin) -W- $read_err\n";
   next
  }

  $@ = '';
  my $rt = $get->(\$content);
  my $parse_err = $@;

  unless ($rt) {
   if (defined($parse_err) && length($parse_err)) {
    print $parse_err;
    print "\n" unless $parse_err =~ /\n\z/o;
   }
   print "(PPlugin) -W- Issue parsing plugin file '$cplugin'\n";
   next
  }

  push @plugins, %$rt;
 }

 my %plugins = @plugins;
 $@ = $saved_err;
 return \%plugins
}

#------------------------------------------------------------------------------
# Function: _load_linkedspec_parser
# Purpose : Lazy-load the `pplugin` parser through the shared owner-dispatch
#           seam instead of carrying a local `require LinkedSpec` branch.
# Args    : ()
# Returns : parser coderef for `pplugin`
#------------------------------------------------------------------------------
sub _load_linkedspec_parser {
 require LinkedSpec::OwnerDispatch;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec',
  'get_parser',
  'pplugin',
 )
}

#------------------------------------------------------------------------------
# Function: _default_deps
# Purpose : Build the default dependency callback map used by the legacy plugin
#           registry loader.
# Args    : ()
# Returns : hashref dependency map
#------------------------------------------------------------------------------
sub _default_deps {
 return {
  load_plugin_parser => \&_load_linkedspec_parser,
  discover_plugin_files => sub { return [_legacy_plugin_files()] },
  build_plugin_registry => sub { return _build_plugin_registry(@_) },
 }
}

#------------------------------------------------------------------------------
# Function: _load_legacy_registry
# Purpose : Build the cached legacy plugin registry through explicit owner deps.
# Args    : ($deps)
# Returns : hashref plugin registry
#------------------------------------------------------------------------------
sub _load_legacy_registry {
 my ($deps) = @_;
 $deps = _default_deps() unless ref($deps) eq 'HASH';

 my $load_plugin_parser = _require_dep($deps, 'load_plugin_parser');
 my $discover_plugin_files = _require_dep($deps, 'discover_plugin_files');
 my $build_plugin_registry = _require_dep($deps, 'build_plugin_registry');

 my $get = $load_plugin_parser->();
 my $plugin_list = $discover_plugin_files->();
 $plugin_list = [$plugin_list] unless ref($plugin_list) eq 'ARRAY';

 return $build_plugin_registry->($get, @$plugin_list)
}

#------------------------------------------------------------------------------
# Function: _normalize_plugin_name
# Purpose : Normalize a mixed subname/AUTOLOAD value into a bare plugin name.
# Args    : ($autoload_or_subname)
# Returns : normalized plugin name
#------------------------------------------------------------------------------
sub _normalize_plugin_name {
 my ($autoload_or_subname) = @_;
 my $display_name = defined($autoload_or_subname) ? $autoload_or_subname : '<undef>';
 my ($plugin_name) = defined($autoload_or_subname) ? ($autoload_or_subname =~ /(\w+)$/o) : ();
 die "(PPlugin::_normalize_plugin_name) -E- invalid plugin name '$display_name'"
  unless defined $plugin_name && length $plugin_name;
 return $plugin_name
}

#------------------------------------------------------------------------------
# Function: new
# Purpose : Construct the cached legacy plugin registry adapter object.
# Args    : ($class)
# Returns : blessed plugin-registry adapter
#------------------------------------------------------------------------------
sub new {
my $class = ref $_[0] || $_[0];

state $main_str = _load_legacy_registry();


 bless $main_str, $class;
}


#------------------------------------------------------------------------------
# Function: get
# Purpose : Look up one legacy plugin callback by normalized plugin name.
# Args    : ($self_or_class, $plugin_name)
# Returns : plugin coderef | undef
#------------------------------------------------------------------------------
sub get  {(ref $_[0] ? $_[0] : __PACKAGE__->new)->{$_[1]}}

#------------------------------------------------------------------------------
# Function: exec_plugin_name
# Purpose : Execute one legacy plugin by explicit normalized plugin name.
# Args    : ($self_or_class, $plugin_name, @args)
# Returns : plugin return payload
#------------------------------------------------------------------------------
sub exec_plugin_name {
my ($this, $plugin_name) = splice @_, 0, 2;
   $this = ref($this) ? $this : __PACKAGE__->new;

 die "(PPlugin::exec_plugin_name) -E- invalid explicit plugin name '$plugin_name'"
  unless defined($plugin_name) && $plugin_name =~ /\A\w+\z/o;

 my $plugin = $this->get($plugin_name);

 die "(PPlugin::exec_plugin_name) -E- Unknown plugin '$plugin_name'" unless $plugin;

 goto &$plugin
}

#------------------------------------------------------------------------------
# Function: exec
# Purpose : Compatibility mixed-name execution wrapper that normalizes names
#           before delegating to `exec_plugin_name(...)`.
# Args    : ($self_or_class, $autoload_or_subname, @args)
# Returns : plugin return payload
#------------------------------------------------------------------------------
sub exec {
my ($this, $autoload_or_subname) = splice @_, 0, 2;
 my $plugin_name = _normalize_plugin_name($autoload_or_subname);
 $this = ref($this) ? $this : __PACKAGE__->new;
 return $this->exec_plugin_name($plugin_name, @_)
}

#------------------------------------------------------------------------------
# Function: AUTOLOAD
# Purpose : Legacy AUTOLOAD compatibility entrypoint for `.plg` plugin calls.
# Args    : standard Perl AUTOLOAD args
# Returns : plugin return payload
#------------------------------------------------------------------------------
sub AUTOLOAD {__PACKAGE__->new->exec_plugin_name(_normalize_plugin_name($AUTOLOAD), @_)}

#------------------------------------------------------------------------------
# Function: DESTROY
# Purpose : No-op destructor that prevents AUTOLOAD from trapping object teardown.
# Args    : ()
# Returns : undef
#------------------------------------------------------------------------------
sub DESTROY  {}

1;

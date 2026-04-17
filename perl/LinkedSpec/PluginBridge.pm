#------------------------------------------------------------------------------
# Package: LinkedSpec::PluginBridge
# Purpose: Compatibility bridge between the modern explicit LinkedSpec plugin
#          APIs and the legacy `PPlugin` / `.plg` runtime.
#------------------------------------------------------------------------------
package LinkedSpec::PluginBridge;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Validate and return one injected dependency callback by name.
# Args    : ($deps, $name)
# Returns : coderef dependency callback
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::PluginBridge::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one owner package through the shared dispatch helper.
# Args    : ($pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg)
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Execute callback without clobbering caller-visible successful `$@`.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: _load_legacy_plugin_runtime
# Purpose : Lazy-load the legacy `PPlugin` runtime for compatibility dispatch.
# Args    : ()
# Returns : true on successful load
#------------------------------------------------------------------------------
sub _load_legacy_plugin_runtime {
 return _require_pkg('PPlugin')
}

#------------------------------------------------------------------------------
# Function: _exec_legacy_plugin
# Purpose : Execute one legacy plugin by explicit normalized plugin name.
# Args    : ($plugin_name, @args)
# Returns : plugin return payload
#------------------------------------------------------------------------------
sub _exec_legacy_plugin {
 my @args = @_;
 return _call_preserving_err(sub {
  return PPlugin->exec_plugin_name(@args)
 })
}

#------------------------------------------------------------------------------
# Function: _get_legacy_plugin
# Purpose : Look up one legacy plugin callback by explicit normalized name.
# Args    : ($plugin_name)
# Returns : plugin coderef | undef
#------------------------------------------------------------------------------
sub _get_legacy_plugin {
 my @args = @_;
 return _call_preserving_err(sub {
  return PPlugin->get(@args)
 })
}

#------------------------------------------------------------------------------
# Function: _resolve_registered_plugin
# Purpose : Resolve one explicitly registered plugin callback from the modern
#           in-memory registry.
# Args    : ($plugin_name)
# Returns : plugin coderef | undef
#------------------------------------------------------------------------------
sub _resolve_registered_plugin {
 my ($plugin_name) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::PluginRegistry',
  'get_plugin',
  $plugin_name,
 )
}

#------------------------------------------------------------------------------
# Function: _default_deps
# Purpose : Build the default dependency callback map used by bridge lookup and
#           dispatch operations.
# Args    : ()
# Returns : hashref dependency map
#------------------------------------------------------------------------------
sub _default_deps {
 return LinkedSpec::OwnerDispatch::build_dep_map(__PACKAGE__, __PACKAGE__, [
  'resolve_registered_plugin',
  { dep => 'load_plugin_runtime', cb => '_load_legacy_plugin_runtime' },
  { dep => 'get_plugin', cb => '_get_legacy_plugin' },
  { dep => 'exec_plugin', cb => '_exec_legacy_plugin' },
 ])
}

#------------------------------------------------------------------------------
# Function: _normalize_plugin_name
# Purpose : Normalize a fully-qualified AUTOLOAD name into the bare plugin name.
# Args    : ($autoload_name)
# Returns : normalized plugin name
#------------------------------------------------------------------------------
sub _normalize_plugin_name {
 my ($autoload_name) = @_;
 my $display_name = defined($autoload_name) ? $autoload_name : '<undef>';
 my ($plugin_name) = defined($autoload_name) ? ($autoload_name =~ /(\w+)$/o) : ();
 die "(LinkedSpec::PluginBridge::_normalize_plugin_name) -E- invalid autoload name '$display_name'"
  unless defined $plugin_name && length $plugin_name;
 return $plugin_name
}

#------------------------------------------------------------------------------
# Function: _require_plugin_name
# Purpose : Validate a bare explicit plugin name before lookup/dispatch.
# Args    : ($plugin_name)
# Returns : validated plugin name
#------------------------------------------------------------------------------
sub _require_plugin_name {
 my ($plugin_name) = @_;
 my $display_name = defined($plugin_name) ? $plugin_name : '<undef>';
 die "(LinkedSpec::PluginBridge::_require_plugin_name) -E- invalid plugin name '$display_name'"
  unless defined($plugin_name) && $plugin_name =~ /\A\w+\z/o;
 return $plugin_name
}

#------------------------------------------------------------------------------
# Function: _lookup_plugin_name
# Purpose : Resolve a plugin callback through the registry-first / legacy-
#           fallback policy without invoking it.
# Args    : ($plugin_name, $deps)
# Returns : plugin coderef | undef
#------------------------------------------------------------------------------
sub _lookup_plugin_name {
 my ($plugin_name, $deps) = @_;
 $deps = _default_deps() unless ref($deps) eq 'HASH';

 my $resolve_registered_plugin = (ref($deps->{resolve_registered_plugin}) eq 'CODE')
  ? $deps->{resolve_registered_plugin}
  : undef;
 my $load_plugin_runtime = _require_dep($deps, 'load_plugin_runtime');
 my $get_plugin = _require_dep($deps, 'get_plugin');
 $plugin_name = _require_plugin_name($plugin_name);

 return _call_preserving_err(sub {
  my $registered_plugin = $resolve_registered_plugin ? $resolve_registered_plugin->($plugin_name) : undef;
  return $registered_plugin if ref($registered_plugin) eq 'CODE';
  $load_plugin_runtime->();
  return $get_plugin->($plugin_name)
 })
}

#------------------------------------------------------------------------------
# Function: _dispatch_plugin_name
# Purpose : Execute a plugin through the registry-first / legacy-fallback
#           policy using an explicit plugin name.
# Args    : ($plugin_name, $args, $deps)
# Returns : plugin return payload
#------------------------------------------------------------------------------
sub _dispatch_plugin_name {
 my ($plugin_name, $args, $deps) = @_;
 $args = [] unless ref($args) eq 'ARRAY';
 $deps = _default_deps() unless ref($deps) eq 'HASH';

 my $resolve_registered_plugin = (ref($deps->{resolve_registered_plugin}) eq 'CODE')
  ? $deps->{resolve_registered_plugin}
  : undef;
 my $load_plugin_runtime = _require_dep($deps, 'load_plugin_runtime');
 my $exec_plugin = _require_dep($deps, 'exec_plugin');
 $plugin_name = _require_plugin_name($plugin_name);

 return _call_preserving_err(sub {
  my $registered_plugin = $resolve_registered_plugin ? $resolve_registered_plugin->($plugin_name) : undef;
  if (ref($registered_plugin) eq 'CODE') {
   return $registered_plugin->(@$args)
  }
  $load_plugin_runtime->();
  return $exec_plugin->($plugin_name, @$args)
 })
}

#------------------------------------------------------------------------------
# Function: _dispatch_autoload
# Purpose : Normalize an AUTOLOAD name and execute it through the explicit-name
#           bridge dispatch policy.
# Args    : ($autoload_name, $args, $deps)
# Returns : plugin return payload
#------------------------------------------------------------------------------
sub _dispatch_autoload {
 my ($autoload_name, $args, $deps) = @_;
 my $plugin_name = _normalize_plugin_name($autoload_name);
 return _dispatch_plugin_name($plugin_name, $args, $deps)
}

1;

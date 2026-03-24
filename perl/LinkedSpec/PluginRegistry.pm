#------------------------------------------------------------------------------
# Package: LinkedSpec::PluginRegistry
# Purpose: In-memory registry for explicit named plugin handlers used by the
#          modern LinkedSpec plugin API.
#------------------------------------------------------------------------------
package LinkedSpec::PluginRegistry;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

 #------------------------------------------------------------------------------
# Function: _registry
# Purpose : Return the shared in-memory plugin registry hashref.
# Args    : ()
# Returns : hashref registry storage
#------------------------------------------------------------------------------
sub _registry {
 state $registry = {};
 return $registry
}

#------------------------------------------------------------------------------
# Function: _require_plugin_name
# Purpose : Validate one explicit plugin name before registry operations.
# Args    : ($plugin_name)
# Returns : validated plugin name
#------------------------------------------------------------------------------
sub _require_plugin_name {
 my ($plugin_name) = @_;
 my $display_name = defined($plugin_name) ? $plugin_name : '<undef>';
 die "(LinkedSpec::PluginRegistry::_require_plugin_name) -E- invalid plugin name '$display_name'"
  unless defined($plugin_name) && $plugin_name =~ /\A\w+\z/o;
 return $plugin_name
}

#------------------------------------------------------------------------------
# Function: _require_plugin_handler
# Purpose : Validate one plugin handler coderef before registration.
# Args    : ($plugin_name, $handler)
# Returns : validated coderef handler
#------------------------------------------------------------------------------
sub _require_plugin_handler {
 my ($plugin_name, $handler) = @_;
 die "(LinkedSpec::PluginRegistry::_require_plugin_handler) -E- invalid plugin handler for '$plugin_name'"
  unless ref($handler) eq 'CODE';
 return $handler
}

#------------------------------------------------------------------------------
# Function: register_plugin
# Purpose : Register or replace one explicit plugin handler by name.
# Args    : ($plugin_name, $handler)
# Returns : registered coderef
#------------------------------------------------------------------------------
sub register_plugin {
 my ($plugin_name, $handler) = @_;
 $plugin_name = _require_plugin_name($plugin_name);
 $handler = _require_plugin_handler($plugin_name, $handler);
 _registry()->{$plugin_name} = $handler;
 return $handler
}

#------------------------------------------------------------------------------
# Function: register_plugins
# Purpose : Bulk-register multiple plugin handlers from a hashref or flat pairs.
# Args    : (\%plugins) | (%plugins)
# Returns : count of supplied plugin handlers
#------------------------------------------------------------------------------
sub register_plugins {
 my @args = @_;
 my %plugins;

 if (@args == 1 && ref($args[0]) eq 'HASH') {
  %plugins = %{$args[0]};
 } else {
  die "(LinkedSpec::PluginRegistry::register_plugins) -E- expected even plugin-name/plugin-handler pairs"
   if @args % 2 != 0;
  %plugins = @args;
 }

 foreach my $plugin_name (sort keys %plugins) {
  register_plugin($plugin_name, $plugins{$plugin_name});
 }

 return scalar(keys %plugins)
}

#------------------------------------------------------------------------------
# Function: get_plugin
# Purpose : Look up one registered plugin handler by explicit name.
# Args    : ($plugin_name)
# Returns : plugin coderef | undef
#------------------------------------------------------------------------------
sub get_plugin {
 my ($plugin_name) = @_;
 $plugin_name = _require_plugin_name($plugin_name);
 return _registry()->{$plugin_name}
}

#------------------------------------------------------------------------------
# Function: has_plugin
# Purpose : Check whether one explicit plugin name is present in the registry.
# Args    : ($plugin_name)
# Returns : 1 | 0
#------------------------------------------------------------------------------
sub has_plugin {
 my ($plugin_name) = @_;
 $plugin_name = _require_plugin_name($plugin_name);
 return exists _registry()->{$plugin_name} ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: clear_registered_plugins
# Purpose : Remove all registered plugin handlers from the shared registry.
# Args    : ()
# Returns : number of removed plugin handlers
#------------------------------------------------------------------------------
sub clear_registered_plugins {
 my $registry = _registry();
 my $count = scalar keys %{$registry};
 %{$registry} = ();
 return $count
}

1;

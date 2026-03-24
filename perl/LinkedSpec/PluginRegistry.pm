package LinkedSpec::PluginRegistry;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _registry {
 state $registry = {};
 return $registry
}

sub _require_plugin_name {
 my ($plugin_name) = @_;
 my $display_name = defined($plugin_name) ? $plugin_name : '<undef>';
 die "(LinkedSpec::PluginRegistry::_require_plugin_name) -E- invalid plugin name '$display_name'"
  unless defined($plugin_name) && $plugin_name =~ /\A\w+\z/o;
 return $plugin_name
}

sub _require_plugin_handler {
 my ($plugin_name, $handler) = @_;
 die "(LinkedSpec::PluginRegistry::_require_plugin_handler) -E- invalid plugin handler for '$plugin_name'"
  unless ref($handler) eq 'CODE';
 return $handler
}

sub register_plugin {
 my ($plugin_name, $handler) = @_;
 $plugin_name = _require_plugin_name($plugin_name);
 $handler = _require_plugin_handler($plugin_name, $handler);
 _registry()->{$plugin_name} = $handler;
 return $handler
}

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

sub get_plugin {
 my ($plugin_name) = @_;
 $plugin_name = _require_plugin_name($plugin_name);
 return _registry()->{$plugin_name}
}

sub has_plugin {
 my ($plugin_name) = @_;
 $plugin_name = _require_plugin_name($plugin_name);
 return exists _registry()->{$plugin_name} ? 1 : 0
}

sub clear_registered_plugins {
 my $registry = _registry();
 my $count = scalar keys %{$registry};
 %{$registry} = ();
 return $count
}

1;

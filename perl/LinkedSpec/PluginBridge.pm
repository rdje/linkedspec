package LinkedSpec::PluginBridge;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::PluginBridge::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _default_deps {
 return {
  load_plugin_runtime => sub {
   my $ok = eval { require PPlugin; 1 };
   die "(LinkedSpec::AUTOLOAD) -E- Unable to load PPlugin: $@" unless $ok;
   return 1
  },
  exec_plugin => sub { return PPlugin->exec(@_) },
 }
}

sub _dispatch_autoload {
 my ($autoload_name, $args, $deps) = @_;
 $args = [] unless ref($args) eq 'ARRAY';
 $deps = _default_deps() unless ref($deps) eq 'HASH';

 my $load_plugin_runtime = _require_dep($deps, 'load_plugin_runtime');
 my $exec_plugin = _require_dep($deps, 'exec_plugin');

 $load_plugin_runtime->();
 return $exec_plugin->($autoload_name, @$args)
}

1;

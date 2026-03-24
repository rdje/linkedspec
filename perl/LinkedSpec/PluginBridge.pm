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

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

sub _load_legacy_plugin_runtime {
 return _call_preserving_err(sub {
  my $ok = eval { require PPlugin; 1 };
  die "(LinkedSpec::AUTOLOAD) -E- Unable to load PPlugin: $@" unless $ok;
  return 1
 })
}

sub _exec_legacy_plugin {
 my @args = @_;
 return _call_preserving_err(sub {
  return PPlugin->exec_plugin_name(@args)
 })
}

sub _get_legacy_plugin {
 my @args = @_;
 return _call_preserving_err(sub {
  return PPlugin->get(@args)
 })
}

sub _resolve_registered_plugin {
 my ($plugin_name) = @_;
 return _call_preserving_err(sub {
  my $ok = eval { require LinkedSpec::PluginRegistry; 1 };
  die "(LinkedSpec::PluginBridge::_resolve_registered_plugin) -E- Unable to load LinkedSpec::PluginRegistry: $@" unless $ok;
  return LinkedSpec::PluginRegistry::get_plugin($plugin_name)
 })
}

sub _default_deps {
 return {
  resolve_registered_plugin => \&_resolve_registered_plugin,
  load_plugin_runtime => \&_load_legacy_plugin_runtime,
  get_plugin => \&_get_legacy_plugin,
  exec_plugin => \&_exec_legacy_plugin,
 }
}

sub _normalize_plugin_name {
 my ($autoload_name) = @_;
 my $display_name = defined($autoload_name) ? $autoload_name : '<undef>';
 my ($plugin_name) = defined($autoload_name) ? ($autoload_name =~ /(\w+)$/o) : ();
 die "(LinkedSpec::PluginBridge::_normalize_plugin_name) -E- invalid autoload name '$display_name'"
  unless defined $plugin_name && length $plugin_name;
 return $plugin_name
}

sub _require_plugin_name {
 my ($plugin_name) = @_;
 my $display_name = defined($plugin_name) ? $plugin_name : '<undef>';
 die "(LinkedSpec::PluginBridge::_require_plugin_name) -E- invalid plugin name '$display_name'"
  unless defined($plugin_name) && $plugin_name =~ /\A\w+\z/o;
 return $plugin_name
}

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

sub _dispatch_autoload {
 my ($autoload_name, $args, $deps) = @_;
 my $plugin_name = _normalize_plugin_name($autoload_name);
 return _dispatch_plugin_name($plugin_name, $args, $deps)
}

1;

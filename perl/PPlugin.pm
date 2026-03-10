#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package PPlugin;

use 5.010;

use LinkedSpec;

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(PPlugin::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _plugin_project_root {
 my $module_path = Cwd::abs_path($INC{__PACKAGE__.'.pm'});
 my $module_dir = (File::Basename::fileparse($module_path))[1];
 return Cwd::realpath(File::Spec->catdir($module_dir, File::Spec->updir()))
}

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

sub _build_plugin_registry {
 my ($get, @plugin_list) = @_;
 die "(PPlugin::_build_plugin_registry) -E- parser callback must be CODE"
  unless ref($get) eq 'CODE';

 my @plugins;
 foreach my $cplugin (@plugin_list) {
  my $content = do { local(@ARGV, $/) = $cplugin; <> };
  my $rt = $get->(\$content); say $@ if $@;

  unless ($rt) {
   print "(PPlugin) -W- Issue parsing plugin file '$cplugin'\n";
   next
  }

  push @plugins, %$rt;
 }

 my %plugins = @plugins;
 return \%plugins
}

sub _default_deps {
 return {
  load_plugin_parser => sub { return LinkedSpec::get_parser('pplugin') },
  discover_plugin_files => sub { return [_legacy_plugin_files()] },
  build_plugin_registry => sub { return _build_plugin_registry(@_) },
 }
}

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

sub _normalize_plugin_name {
 my ($autoload_or_subname) = @_;
 my $display_name = defined($autoload_or_subname) ? $autoload_or_subname : '<undef>';
 my ($plugin_name) = defined($autoload_or_subname) ? ($autoload_or_subname =~ /(\w+)$/o) : ();
 die "(PPlugin::_normalize_plugin_name) -E- invalid plugin name '$display_name'"
  unless defined $plugin_name && length $plugin_name;
 return $plugin_name
}

sub new {
my $class = ref $_[0] || $_[0];

state $main_str = _load_legacy_registry();


 bless $main_str, $class;
}


sub get  {(ref $_[0] ? $_[0] : __PACKAGE__->new)->{$_[1]}}
sub exec_plugin_name {
my ($this, $plugin_name) = splice @_, 0, 2;
   $this = ref($this) ? $this : __PACKAGE__->new;

 die "(PPlugin::exec_plugin_name) -E- invalid explicit plugin name '$plugin_name'"
  unless defined($plugin_name) && $plugin_name =~ /\A\w+\z/o;

 my $plugin = $this->get($plugin_name);

 die "(PPlugin::exec_plugin_name) -E- Unknown plugin '$plugin_name'" unless $plugin;

 goto &$plugin
}
sub exec {
my ($this, $autoload_or_subname) = splice @_, 0, 2;
 my $plugin_name = _normalize_plugin_name($autoload_or_subname);
 $this = ref($this) ? $this : __PACKAGE__->new;
 return $this->exec_plugin_name($plugin_name, @_)
}

sub AUTOLOAD {__PACKAGE__->new->exec_plugin_name(_normalize_plugin_name($AUTOLOAD), @_)}
sub DESTROY  {}

1;

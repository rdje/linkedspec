#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package PPlugin;

use 5.010;

use LinkedSpec;

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

sub new {
my $class = ref $_[0] || $_[0];

state $main_str = do { 
 my $get         = LinkedSpec::get_parser('pplugin');
 my @plugin_list = _legacy_plugin_files();

 my @plugins;
 foreach my $cplugin (@plugin_list) {
  my $content = do {local(@ARGV, $/) = $cplugin; <>};
  my $rt      = $get->(\$content); say $@ if $@;
 
  unless ($rt) {
   print "(PPlugin) -W- Issue parsing plugin file '$cplugin'\n";
   next
  }
 
  push @plugins, %$rt;
 }

  my %plugins = @plugins;
  # trying to directly output 
  #   {@plugins} 
  #
  # seems to infact output 
  #   @plugins
  #
  # I really can't explain this behaviour
  # I've seen this many times
  \%plugins
 };


 bless $main_str, $class;
}


sub get  {(ref $_[0] ? $_[0] : __PACKAGE__->new)->{$_[1]}}
sub exec {
my ($this, $autoload_or_subname) = splice @_, 0, 2;

 my ($method) = $autoload_or_subname =~ /(\w+)$/o;
 my $plugin = $this->get($method);
 
 die "(PPlugin::exec) -E- Unknown plugin '$method' (<- $autoload_or_subname)," unless $plugin; 

 goto &$plugin
}

sub AUTOLOAD {__PACKAGE__->new->exec($AUTOLOAD, @_)}
sub DESTROY  {}

1;

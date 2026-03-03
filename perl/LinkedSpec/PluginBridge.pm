package LinkedSpec::PluginBridge;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: dispatch_autoload
# Purpose : Lazy plugin bridge used by generated parsers for plugin dispatch.
# Args    : ($autoload_name, @args)
# Returns : whatever plugin call returns
#------------------------------------------------------------------------------
sub dispatch_autoload {
 my ($autoload_name, @args) = @_;
 my $ok = eval {require PPlugin; 1};
 die "(LinkedSpec::AUTOLOAD) -E- Unable to load PPlugin: $@" unless $ok;
 return PPlugin->exec($autoload_name, @args)
}

1;

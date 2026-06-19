#===================================================================
# Package: PluginUtils
# Purpose: Utility wrappers previously defined in plugin/common.plg.
#          Provides thin wrappers around Perl builtins and CPAN modules
#          that were called as plugin actions by other .plg files.
#
#          This package is the migration target for common.plg — once all
#          callers are updated to use PluginUtils directly, common.plg
#          can be deleted.
#===================================================================
package PluginUtils;

use 5.010;
use strict;
use warnings;

use Cwd ();
use File::Spec ();
use File::Path ();
use Storable ();
use Digest::MD5 ();
use Digest::file ();

#------------------------------------------------------------------------------
# config_read($name, @extra) — read a configuration file via HUtils/PathSearch
#------------------------------------------------------------------------------
sub config_read {
    require HUtils;
    require PathSearch;
    return HUtils::Conf(PathSearch::go($_[0], 'conf', @_[1 .. $#_]));
}

#------------------------------------------------------------------------------
# config_link($name, @extra) — link a configuration file via HUtils/PathSearch
#------------------------------------------------------------------------------
sub config_link {
    require HUtils;
    require PathSearch;
    return HUtils::Link(PathSearch::go($_[0], 'conf', @_[1 .. $#_]));
}

#------------------------------------------------------------------------------
# digest_file_hex(@args) — hex digest of a file
#------------------------------------------------------------------------------
sub digest_file_hex {
    return Digest::file::digest_file_hex(@_);
}

#------------------------------------------------------------------------------
# digest_md5_hex(@args) — MD5 hex digest
#------------------------------------------------------------------------------
sub digest_md5_hex {
    return Digest::MD5::md5_hex(@_);
}

#------------------------------------------------------------------------------
# private_state(@args) — per-caller private state keyed by MD5
#------------------------------------------------------------------------------
sub private_state {
    require Global;
    my $key = Digest::MD5::md5_hex(@_);
    return Global::set($key) //= {};
}

#------------------------------------------------------------------------------
# abs_path(@args) — absolute path resolution
#------------------------------------------------------------------------------
sub abs_path {
    return Cwd::abs_path(@_);
}

#------------------------------------------------------------------------------
# realpath($path) — real path, with Cygwin awareness
#------------------------------------------------------------------------------
sub realpath {
    if ($^O eq 'cygwin') {
        chomp(my $f = qx/cygpath -a -w $_[0]/);
        $f =~ s/\\/\\\\/go;
        return $f;
    }
    return Cwd::realpath($_[0]);
}

#------------------------------------------------------------------------------
# getcwd() — current working directory
#------------------------------------------------------------------------------
sub getcwd {
    return Cwd::getcwd();
}

#------------------------------------------------------------------------------
# rel2abs(@args) — relative to absolute path
#------------------------------------------------------------------------------
sub rel2abs {
    return File::Spec->rel2abs(@_);
}

#------------------------------------------------------------------------------
# abs2rel(@args) — absolute to relative path
#------------------------------------------------------------------------------
sub abs2rel {
    return File::Spec->abs2rel(@_);
}

#------------------------------------------------------------------------------
# splitdir(@args) — split directory path into components
#------------------------------------------------------------------------------
sub splitdir {
    return File::Spec->splitdir(@_);
}

#------------------------------------------------------------------------------
# catdir(@args) — join directory path components
#------------------------------------------------------------------------------
sub catdir {
    return File::Spec->catdir(@_);
}

#------------------------------------------------------------------------------
# catfile(@args) — join file path components
#------------------------------------------------------------------------------
sub catfile {
    return File::Spec->catfile(@_);
}

#------------------------------------------------------------------------------
# curdir() — current directory symbol
#------------------------------------------------------------------------------
sub curdir {
    return File::Spec->curdir();
}

#------------------------------------------------------------------------------
# devnull() — null device path
#------------------------------------------------------------------------------
sub devnull {
    return File::Spec->devnull();
}

#------------------------------------------------------------------------------
# splitpath(@args) — split a path into volume, directory, file
#------------------------------------------------------------------------------
sub splitpath {
    return File::Spec->splitpath(@_);
}

#------------------------------------------------------------------------------
# filename(@args) — extract filename from path
#------------------------------------------------------------------------------
sub filename {
    return (File::Spec->splitpath(@_))[-1];
}

#------------------------------------------------------------------------------
# dirname(@args) — extract directory from path
#------------------------------------------------------------------------------
sub dirname {
    return (File::Spec->splitpath(@_))[-2];
}

#------------------------------------------------------------------------------
# rmtree(@args) — recursive directory removal
#------------------------------------------------------------------------------
sub rmtree {
    return File::Path::rmtree(@_);
}

#------------------------------------------------------------------------------
# mkpath(@args) — recursive directory creation
#------------------------------------------------------------------------------
sub mkpath {
    return File::Path::mkpath(@_);
}

#------------------------------------------------------------------------------
# store(@args) — serialize and store to file
#------------------------------------------------------------------------------
sub store {
    return Storable::store(@_);
}

#------------------------------------------------------------------------------
# retrieve(@args) — deserialize from file
#------------------------------------------------------------------------------
sub retrieve {
    return Storable::retrieve(@_);
}

#------------------------------------------------------------------------------
# first_match_index($re, $aref) — find first array index matching regex
#------------------------------------------------------------------------------
sub first_match_index {
    my ($re, $aref) = @_;
    foreach my $i (0 .. $#$aref) {
        return $i if $$aref[$i] =~ $re;
    }
    return;
}

1;

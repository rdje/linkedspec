#!/usr/bin/env perl
use strict;
use warnings;
use Fcntl qw(S_ISDIR);
use File::Spec ();

# Read-only, immediate-entry census. Exit 0 means clear, 1 residue, 2 scan error.
sub scan_error {
    print STDERR "lua-legacy-census: $_[0]\n";
    exit 2;
}

@ARGV == 1 or scan_error('usage: check_lua_legacy_temp_residue.pl ROOT');
my ($root) = @ARGV;
opendir my $directory, $root or scan_error("cannot open root '$root': $!");
my $residue;
while (1) {
    $! = 0;
    my $name = readdir $directory;
    if (!defined $name) {
        scan_error("cannot enumerate root '$root': $!") if $!;
        last;
    }
    next unless index($name, 'linkedspec-lua-') == 0;
    my $path = File::Spec->catfile($root, $name);
    my @metadata = lstat $path;
    @metadata or scan_error("cannot inspect matching entry '$path': $!");
    # Match find's former -type d contract: do not follow directory symlinks.
    $residue //= $path if S_ISDIR($metadata[2]);
}
closedir $directory or scan_error("cannot close root '$root': $!");
if (defined $residue) {
    print STDERR "lua-legacy-census: Lua-owned directory remains: $residue\n";
    exit 1;
}
exit 0;

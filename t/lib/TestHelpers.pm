#==============================================================================
# Package: t::lib::TestHelpers
# Purpose: Shared test utilities for the LinkedSpec test suite.
#          Extracted from phase0_regression.t to enable independent test modules.
#==============================================================================
package t::lib::TestHelpers;

use 5.010;
use strict;
use warnings;

use File::Spec;
use File::Basename;
use File::Find;
use Exporter 'import';

our @EXPORT_OK = qw(
    discover_specs
    discover_dir_files_by_suffix
    slurp
    write_text
    normalize_error
    run_perl_snippet_in_subprocess
);

#------------------------------------------------------------------------------
# Function: slurp
# Purpose : Read entire file content. Dies on failure.
#------------------------------------------------------------------------------
sub slurp {
    my ($path) = @_;
    open(my $fh, '<', $path) or die "Cannot read '$path': $!";
    local $/;
    return <$fh>;
}

#------------------------------------------------------------------------------
# Function: write_text
# Purpose : Write content to a file, overwriting if it exists.
#------------------------------------------------------------------------------
sub write_text {
    my ($path, $content) = @_;
    open(my $fh, '>', $path) or die "Cannot write '$path': $!";
    print {$fh} $content;
    close($fh);
    return 1;
}

#------------------------------------------------------------------------------
# Function: discover_specs
# Purpose : List .spec files in a directory, sorted.
#------------------------------------------------------------------------------
sub discover_specs {
    my ($dir) = @_;
    opendir(my $dh, $dir) or die "Cannot open specs directory '$dir': $!";
    my @specs = sort grep { /\.spec\z/ } readdir($dh);
    closedir($dh);
    return @specs;
}

#------------------------------------------------------------------------------
# Function: discover_dir_files_by_suffix
# Purpose : Recursively find files with a given suffix under a directory.
#------------------------------------------------------------------------------
sub discover_dir_files_by_suffix {
    my ($dir, $suffix) = @_;
    return unless -d $dir;
    my @files;
    find(
        {
            wanted => sub { push @files, $File::Find::name if -f $_ && /\Q$suffix\E\z/ },
            no_chdir => 1,
        },
        $dir,
    );
    return sort @files;
}

#------------------------------------------------------------------------------
# Function: normalize_error
# Purpose : Normalise $@ / error detail for diag output.
#------------------------------------------------------------------------------
sub normalize_error {
    my ($err) = @_;
    return '' unless defined $err;
    $err =~ s/\n.*//s;
    $err =~ s/ at \S+ line \d+\..*//s;
    return $err;
}

#------------------------------------------------------------------------------
# Function: run_perl_snippet_in_subprocess
# Purpose : Execute a Perl snippet in a subprocess, capturing exit code, stdout,
#           and stderr.  Returns ($exit_code, $stdout, $stderr).
#------------------------------------------------------------------------------
sub run_perl_snippet_in_subprocess {
    my ($code) = @_;

    require File::Temp;
    my ($script_fh, $script_path) = File::Temp::tempfile(SUFFIX => '.pl', UNLINK => 1);
    print {$script_fh} $code;
    close($script_fh);

    my $perl_path = $^X;
    my $inc_paths = join(' ', map { "-I$_" } @INC);

    require IPC::Open3;
    require Symbol;
    my $out_buf = '';
    my $err_buf = '';
    my $child_err = Symbol::gensym();
    my $child_pid = IPC::Open3::open3(
        undef,
        my $child_out,
        $child_err,
        $perl_path,
        (split(' ', $inc_paths), $script_path),
    );

    {
        local $/;
        $out_buf = readline($child_out) // '';
    }
    {
        local $/;
        $err_buf = readline($child_err) // '';
    }

    waitpid($child_pid, 0);
    my $exit_code = $? >> 8;

    unlink($script_path) unless !-f $script_path;

    return ($exit_code, $out_buf, $err_buf);
}

1;

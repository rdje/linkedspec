use strict;
use warnings;
use FindBin qw($Bin);
use File::Spec ();
use File::Temp qw(tempdir);
use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use Test::More;

my $temporary_root = $ENV{TMPDIR};
($ENV{LINKEDSPEC_RUN_ACTIVE} // '') eq '1'
    && defined($temporary_root) && -d $temporary_root
    or die "run through tools/project_data_run.sh with managed TMPDIR\n";
my @repository_device = stat File::Spec->catdir($Bin, '..');
my @temporary_device = stat $temporary_root;
@repository_device && @temporary_device && $repository_device[0] == $temporary_device[0]
    or die "test fixtures must stay on the repository filesystem\n";
my $root = tempdir('lua-census-test-XXXXXX', DIR => $temporary_root, CLEANUP => 1);
my $scanner = File::Spec->catfile($Bin, '..', 'tools', 'check_lua_legacy_temp_residue.pl');

sub scan {
    my (@arguments) = @_;
    my $errors = gensym;
    my $pid = open3(my $input, my $output, $errors, $^X, $scanner, @arguments);
    close $input or die "close scanner input: $!";
    local $/;
    my $stdout = <$output> // '';
    my $stderr = <$errors> // '';
    waitpid($pid, 0) == $pid or die "wait for scanner: $!";
    return ($?, $stdout, $stderr);
}

sub outcome {
    my ($label, $expected_status, $message, @arguments) = @_;
    my ($status, $stdout, $stderr) = scan(@arguments);
    is($status, $expected_status << 8, "$label: exact process status");
    is($stdout, '', "$label: no success payload on stdout");
    if (defined $message) {
        like($stderr, $message, "$label: attributed failure");
    } else {
        is($stderr, '', "$label: quiet clear census");
    }
}

outcome('empty root', 0, undef, $root);
outcome('missing root', 2, qr/cannot open root/, "$root/missing");
outcome('missing argument', 2, qr/usage:/);
outcome('extra argument', 2, qr/usage:/, $root, $root);

my $ordinary_file = "$root/ordinary-file";
open my $file, '>', $ordinary_file or die "create fixture: $!";
close $file or die "close fixture: $!";
outcome('file used as root', 2, qr/cannot open root/, $ordinary_file);

my $prefix_file = "$root/linkedspec-lua-file";
open $file, '>', $prefix_file or die "create prefix file: $!";
close $file or die "close prefix file: $!";
outcome('matching regular file is not directory residue', 0, undef, $root);

my $residue = "$root/linkedspec-lua-owned directory";
mkdir $residue or die "create residue: $!";
outcome('matching directory', 1, qr/Lua-owned directory remains:/, $root);
rmdir $residue or die "remove exact fixture: $!";

my $unrelated = "$root/unrelated";
mkdir $unrelated or die "create unrelated directory: $!";
mkdir "$unrelated/linkedspec-lua-nested" or die "create nested fixture: $!";
outcome('census is immediate-entry only', 0, undef, $root);

my $link = "$root/linkedspec-lua-link";
symlink $unrelated, $link or die "create directory symlink: $!";
outcome('matching symlink is not followed', 0, undef, $root);
unlink $link or die "remove exact symlink fixture: $!";

END { chmod 0700, $unrelated if defined($unrelated) && -d $unrelated }
chmod 0000, $unrelated or die "protect unrelated fixture: $!";
outcome('unrelated protected directory is not inspected', 0, undef, $root);
chmod 0700, $unrelated or die "restore fixture permissions: $!";

done_testing;

use 5.010;
use strict;
use warnings;

use Cwd qw(abs_path getcwd);
use File::Copy qw(copy);
use File::Find ();
use File::Path qw(make_path);
use File::Spec;
use File::Temp ();
use FindBin qw($Bin);
use Test::More;
use Time::HiRes qw(time);

use lib "$Bin/../perl";
use LinkedSpec;

sub read_bytes {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "Cannot read '$path': $!";
    local $/;
    return <$fh>;
}

sub capture_lookup {
    my ($name) = @_;
    my ($out, $err) = ('', '');
    local *STDOUT;
    local *STDERR;
    open STDOUT, '>', \$out or die "Cannot capture stdout: $!";
    open STDERR, '>', \$err or die "Cannot capture stderr: $!";
    my $parser = LinkedSpec::get_parser($name);
    return ($parser, $out, $err);
}

# Run this file in a fresh process: PathSearch's lexical state must neither come
# from Phase0 nor survive into its later cases. Copy only this unchanged module;
# the public resolver and compiler are loaded from the actual checkout above.
ok(!exists $INC{'PathSearch.pm'}, 'fresh process has no legacy discovery state');
my $repo = abs_path("$Bin/..");
my $temporary = File::Temp->newdir(CLEANUP => 1);
my $temporary_path = abs_path("$temporary");
is((stat $temporary_path)[0], (stat $repo)[0], 'fixture stays on repository volume');
my $fixture = File::Spec->catdir($temporary_path, 'consumer');
my $module_dir = File::Spec->catdir($fixture, 'perl');
my $nested = File::Spec->catdir($fixture, 'nested', 'specs');
my $working = File::Spec->catdir($fixture, 'working');
my $excluded = File::Spec->catdir($temporary_path, 'unrelated-build');
make_path($module_dir, $nested, $working, $excluded);
my $module_source = File::Spec->catfile($repo, 'perl', 'PathSearch.pm');
my $module_copy = File::Spec->catfile($module_dir, 'PathSearch.pm');
copy($module_source, $module_copy) or die "Cannot copy PathSearch: $!";
is(read_bytes($module_copy), read_bytes($module_source), 'real PathSearch module is byte-identical');

my $name = 'isolated_legacy_fallback_' . $$;
my $missing = 'isolated_legacy_missing_' . $$;
my $source_spec = File::Spec->catfile($repo, 'specs', 'Lispish.spec');
my $target = File::Spec->catfile($nested, "$name.spec");
copy($source_spec, $target) or die "Cannot copy fallback spec: $!";
# This sibling represents arbitrarily large checkout build/cache storage. A
# discoverable decoy for the missing name makes accidental traversal observable.
for my $index (1 .. 512) {
    make_path(File::Spec->catdir($excluded, "output-$index", 'deps'));
}
copy($source_spec, File::Spec->catfile($excluded, "$missing.spec"))
    or die "Cannot copy excluded decoy: $!";

my $original_cwd = getcwd();
chdir $working or die "Cannot enter fixture working directory: $!";
unshift @INC, $module_dir;
require PathSearch;
is(abs_path($INC{'PathSearch.pm'}), $module_copy, 'legacy discovery is rooted at isolated module copy');
ok(!-e "$name.spec", 'cwd candidate is absent');
ok(!-e File::Spec->catfile($repo, 'specs', "$name.spec"), 'real resolver module-relative candidate is absent');

my ($go_calls, $find_calls, $discovery_seconds) = (0, 0, 0);
my (@visited, @search_roots);
my $real_go = \&PathSearch::go;
my $real_find = \&PathSearch::find;
{
    no warnings 'redefine';
    local *PathSearch::go = sub { ++$go_calls; return $real_go->(@_); };
    local *PathSearch::find = sub {
        my ($wanted, @roots) = @_;
        ++$find_calls;
        push @search_roots, @roots;
        # Fail before traversal if the fixture ever regresses to scanning the
        # actual checkout; never make a regression test enumerate dependencies.
        die "Discovery escaped isolated fixture\n"
            unless @roots == 1 && abs_path($roots[0]) eq $fixture;
        my $start = time();
        $real_find->(sub {
            push @visited, $File::Find::name;
            $wanted->();
        }, @roots);
        $discovery_seconds += time() - $start;
    };

    my ($parser, $out, $err) = capture_lookup($name);
    is($go_calls, 1, 'successful public lookup calls real fallback exactly once');
    is($find_calls, 1, 'cold fallback executes real filesystem discovery once');
    is_deeply(\@search_roots, [$fixture], 'discovery scans only the isolated consumer root');
    ok(ref($parser) eq 'CODE', 'real fallback returns a compiled parser');
    is($out . $err, '', 'successful fallback has no diagnostics');
    my $input = '(u v)';
    my $value = eval { $parser->(\$input) };
    is($@, '', 'fallback parser invocation succeeds');
    is_deeply($value, ['u', ['v']], 'fallback parser returns the exact Lispish value');
    ok(grep($_ eq $target, @visited), 'real recursive search reached the nested spec');
    ok(!grep(index($_, $excluded) == 0, @visited), 'large unrelated tree was never visited');
    is(scalar @visited, 7, 'discovery visit count is bounded independently of excluded storage');

    ($parser, $out, $err) = capture_lookup($missing);
    is($go_calls, 2, 'missing-name lookup calls real fallback once more');
    is($find_calls, 1, 'warm miss uses the real process-local discovery cache');
    ok(!defined $parser, 'excluded decoy cannot satisfy a missing-name lookup');
    like($out, qr/Spec path not found/, 'public miss diagnostic is preserved');
    like($err, qr/Unable to find file '\Q$missing\E\.spec'/, 'real PathSearch miss diagnostic is preserved');
    like($out . $err, qr/\Q$missing\E/, 'miss diagnostics identify the requested name');
    unlike($out . $err, qr/\Q$excluded\E/, 'miss diagnostics do not enumerate unrelated storage');

    ($parser, $out, $err) = capture_lookup(File::Spec->catfile($working, 'absent.spec'));
    is($go_calls, 2, 'explicit missing path still bypasses fallback');
    ok(!defined $parser, 'explicit missing path returns undef');
    like($out, qr/Spec path not found/, 'explicit missing path retains its diagnostic');
}

diag(sprintf 'cold legacy discovery: %d visits, %.6f seconds (excludes compilation)',
    scalar @visited, $discovery_seconds);
chdir $original_cwd or die "Cannot restore cwd: $!";
undef $temporary;
ok(!-e $temporary_path, 'owned fixture and excluded-tree decoy are removed');
done_testing();

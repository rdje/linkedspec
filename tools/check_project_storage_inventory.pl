#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use JSON::PP ();
use Encode qw(encode);
use Getopt::Long qw(GetOptions);

# Exact file populations supplement, rather than replace, allocation/device probes.
my ($kind, $stdin_owners);
GetOptions('kind=s' => \$kind, 'stdin-owners' => \$stdin_owners)
    or die "invalid storage inventory options\n";
my %scopes = (
    perl_temporary_owners => ['t/*.t', 't/**/*.pm', 'tools/*.pl', 'perl/**/*.pm'],
    python_temporary_owners => ['tools/*.py'],
    python_entrypoints => ['tools/*.py'],
    shell_temporary_owners => ['tools/*.sh', 'knowledge-map/scripts/*.sh'],
);
die "select one known storage inventory kind\n" unless defined($kind) && exists($scopes{$kind}) && !@ARGV;
chdir "$Bin/.." or die "cannot enter repository: $!\n";

sub raw_read {
    my ($path) = @_;
    die "not a regular nonsymlink source: $path\n" unless -f $path && !-l $path;
    open my $fh, '<:raw', $path or die "cannot open $path: $!\n";
    local $/;
    my $raw = <$fh> // '';
    close $fh or die "cannot close $path: $!\n";
    return $raw;
}

sub paths {
    my ($raw) = @_;
    die "unterminated NUL inventory\n" if length($raw) && substr($raw, -1) ne "\0";
    my @names = length($raw) ? split(/\0/, $raw, -1) : ();
    pop @names if @names;
    my %seen;
    for my $name (@names) {
        die "invalid repository-relative inventory path\n"
            unless length($name) && $name !~ m{\A/|(?:\A|/)\.\.?(?:/|\z)|//|\\};
        die "duplicate inventory path: $name\n" if $seen{$name}++;
    }
    return @names;
}

my $manifest = JSON::PP->new->utf8->decode(raw_read("doctrine/project_data_storage/$kind.json"));
die "invalid storage inventory manifest\n" unless ref($manifest) eq 'HASH'
    && join(',', sort keys %$manifest) eq 'kind,owner,owners,schema_version'
    && $manifest->{schema_version} == 1 && $manifest->{kind} eq $kind
    && $manifest->{owner} eq 'TYPE-REFERENCE-BOOK.1.2.20.1.19'
    && ref($manifest->{owners}) eq 'ARRAY' && @{$manifest->{owners}}
    && !grep { ref($_) || !defined($_) || index($_, "\0") >= 0 } @{$manifest->{owners}};
my @expected = paths(join('', map { encode('UTF-8', $_) . "\0" } @{$manifest->{owners}}));
die "unsorted storage inventory manifest\n" unless join("\0", @expected) eq join("\0", sort @expected);
my @actual;
my $perl_allocation = 'File::' . 'Temp|tempdir\\(|tempfile\\(';
if ($stdin_owners) {
    binmode STDIN, ':raw';
    local $/;
    @actual = paths(<STDIN> // '');
} else {
    open my $git, '-|', 'git', 'ls-files', '-z', '--', @{$scopes{$kind}}
        or die "cannot start Git census: $!\n";
    binmode $git, ':raw';
    my $raw = do { local $/; <$git> // '' };
    close $git or die "Git storage census failed\n";
    for my $name (paths($raw)) {
        next if $kind =~ /^python_/ && $name !~ m{\Atools/[^/]+\.py\z};
        next if $kind eq 'shell_temporary_owners' && $name !~ m{\A(?:tools|knowledge-map/scripts)/[^/]+\.sh\z};
        my $source = raw_read($name);
        my $selected = $kind eq 'perl_temporary_owners'
            ? $source =~ /$perl_allocation/
            : $kind eq 'python_temporary_owners'
            ? $source =~ /^\s*(?:import\s+tempfile\b|from\s+tempfile\s+import\b)/m
            : $kind eq 'python_entrypoints'
            ? $source =~ /\A#!\/usr\/bin\/env python3\n/
            : $source =~ /\$\(mktemp\b/;
        push @actual, $name if $selected;
    }
}
my %actual = map { $_ => 1 } @actual;
my %expected = map { $_ => 1 } @expected;
my @missing = grep { !$actual{$_} } @expected;
my @unexpected = sort grep { !$expected{$_} } @actual;
die "storage inventory mismatch ($kind): missing=[@missing] unexpected=[@unexpected]\n"
    if @missing || @unexpected;
printf "[storage-inventory] PASS %s: %d reviewed files\n", $kind, scalar @expected;

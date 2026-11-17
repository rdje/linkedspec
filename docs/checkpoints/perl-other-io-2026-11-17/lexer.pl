use strict;
use warnings;
use PPI ();
use JSON::PP ();
use Encode qw(encode_utf8);
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(refaddr);

binmode STDIN, ':raw';
binmode STDOUT, ':raw';
my $request = JSON::PP->new->utf8->decode(do { local $/; <STDIN> });
die "PPI version changed\n" unless "$PPI::VERSION" eq $request->{ppi_version};
my %wanted = map { $_ => 1 } qw(open sysopen read sysread readline glob opendir readdir readlink pipe);

sub literal {
    my ($token) = @_;
    return undef unless ref($token) && $token->isa('PPI::Token::Quote');
    my $value = $token->string;
    # PPI strips wrappers; do not evaluate escapes or interpolation.
    return defined($value) && $value =~ /\A[A-Za-z0-9_.\/<>:()|-]+\z/ ? $value : undef;
}

sub open_shape {
    my ($token) = @_;
    my $statement = $token->statement;
    my @children = $statement->schildren;
    return {role => 'unqualified-open-context'} unless @children && refaddr($children[0]) == refaddr($token);
    shift @children;
    my @arguments;
    if (@children && $children[0]->isa('PPI::Structure::List')) {
        my @inside = $children[0]->schildren;
        return {role => 'unqualified-open-list'} unless @inside == 1 && $inside[0]->isa('PPI::Statement');
        @arguments = $inside[0]->schildren;
    } else {
        @arguments = @children;
        my ($end) = grep { $arguments[$_]->content =~ /\A(?:or|\|\|)\z/ } 0 .. $#arguments;
        @arguments = @arguments[0 .. $end - 1] if defined($end) && $end > 0;
    }
    shift @arguments if @arguments && $arguments[0]->content eq 'my';
    pop @arguments if @arguments && $arguments[-1]->content eq ';';
    return {role => 'unqualified-open-arguments'} unless @arguments >= 5
        && $arguments[1]->content eq ',' && $arguments[3]->content eq ',';
    my $mode = literal($arguments[2]);
    return {role => 'unqualified-open-mode'} unless defined($mode);
    my @operand = @arguments[4 .. $#arguments];
    my $operand = join '', map { $_->content } @operand;
    my $role = 'unqualified-open-mode';
    if ($mode eq '-|' || $mode eq '|-') {
        $role = 'process-pipe-declaration';
    } elsif ($mode =~ /\A[<>](?::raw|:encoding\(UTF-8\))?\z/) {
        if (@operand == 2 && $operand[0]->content eq '\\' && $operand[1]->isa('PPI::Token::Symbol')
                && $operand[1]->content =~ /\A\$[A-Za-z_]\w*\z/) {
            $role = $mode =~ /^>/ ? 'scalar-output-declaration' : 'scalar-input-declaration';
        } elsif (@operand == 1 && defined(literal($operand[0]))) {
            $role = $mode =~ /^>/ ? 'literal-output-declaration' : 'literal-input-declaration';
        } else {
            $role = $mode =~ /^>/ ? 'unresolved-file-output-operand' : 'unresolved-file-input-operand';
        }
    }
    return {role => $role, mode => $mode, handle => $arguments[0]->content, operand => $operand};
}

my @documents;
for my $input (@{$request->{documents}}) {
    my $source = $input->{source};
    die "source digest mismatch\n" unless sha256_hex(encode_utf8($source)) eq $input->{sha256};
    my $document = PPI::Document->new(\$source, readonly => 1);
    die "PPI constructor refused\n" unless ref($document);
    $document->index_locations;
    my (@sites, @unknown);
    my @tokens = $document->tokens;
    for my $ordinal (0 .. $#tokens) {
        my $token = $tokens[$ordinal];
        push @unknown, $ordinal if ref($token) =~ /Unknown|Unmatched/;
        my $word = $token->content;
        $word =~ s/.*:://;
        my $readline = $token->isa('PPI::Token::QuoteLike::Readline');
        next unless $readline || ($token->isa('PPI::Token::Word') && $wanted{$word});
        my $previous = $token->sprevious_sibling;
        my $next = $token->snext_sibling;
        my $excluded = !$readline && ((ref($previous) && $previous->content =~ /\A(?:->|sub)\z/)
            || (ref($next) && $next->content eq '=>'));
        my $statement = $token->statement;
        my $location = $token->location;
        my $shape = $excluded ? {role => 'excluded-member-declaration-or-key'}
            : !$readline && $word eq 'open' ? open_shape($token)
            : {role => $readline ? 'readline-syntax-candidate' : 'non-open-word-candidate'};
        push @sites, {ordinal => $ordinal, class => ref($token), word => $readline ? 'readline-syntax' : $word,
            raw => $token->content, location => [@{$location}[0 .. 2]],
            statement => ref($statement) ? $statement->content : undef, %$shape};
    }
    push @documents, {path => $input->{path}, source_sha256 => $input->{sha256},
        roundtrip => $document->serialize eq $source ? JSON::PP::true : JSON::PP::false,
        unknown_tokens => \@unknown, sites => \@sites};
}
print JSON::PP->new->canonical->utf8->encode({ppi_version => "$PPI::VERSION", documents => \@documents}), "\n";

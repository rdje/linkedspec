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

sub position {
    my ($element) = @_;
    my $value = $element->location;
    return ref($value) eq 'ARRAY' ? [@{$value}[0 .. 2]] : [];
}

sub simple_quote {
    my ($token) = @_;
    return undef unless ref($token) && $token->isa('PPI::Token::Quote');
    # Public ->string strips wrappers; it is not a Perl evaluator.
    return $token->string;
}

sub open_shape {
    my ($token, $statement) = @_;
    return (undef, 'no source statement') unless ref($statement);
    my @children = $statement->schildren;
    return (undef, 'not a standalone open head')
        unless @children && refaddr($children[0]) == refaddr($token);
    shift @children;
    my (@arguments, @guard);
    if (@children && $children[0]->isa('PPI::Structure::List')) {
        my @inside = $children[0]->schildren;
        return (undef, 'unqualified parenthesized argument structure')
            unless @inside == 1 && $inside[0]->isa('PPI::Statement');
        @arguments = $inside[0]->schildren;
        @guard = @children[1 .. $#children];
    } else {
        my ($boundary) = grep {
            $children[$_]->content eq 'or' || $children[$_]->content eq '||'
        } 0 .. $#children;
        return (undef, 'no supported source load guard') unless defined($boundary) && $boundary > 0;
        @arguments = @children[0 .. $boundary - 1];
        @guard = @children[$boundary .. $#children];
    }
    return (undef, 'no supported source load guard') unless @guard >= 2
        && ($guard[0]->content eq 'or' || $guard[0]->content eq '||') && $guard[1]->content eq 'die';
    shift @arguments if @arguments && $arguments[0]->content eq 'my';
    return (undef, 'not the bounded three-argument open shape') unless @arguments == 5
        && $arguments[1]->content eq ',' && $arguments[3]->content eq ',';
    my $handle = $arguments[0]->content;
    return (undef, 'unqualified handle') unless $handle =~ /\A(?:\$[A-Za-z_]\w*|STDOUT|STDERR)\z/;
    my $mode = simple_quote($arguments[2]);
    return (undef, 'mode is not a supported literal file mode') unless defined($mode)
        && $mode =~ /\A[<>](?::raw|:encoding\(UTF-8\))?\z/;
    my $operand = $arguments[4];
    return (undef, 'operand is not a simple source symbol') unless $operand->isa('PPI::Token::Symbol')
        && $operand->content =~ /\A\$[A-Za-z_]\w*\z/;
    return ({handle => $handle, mode => $mode, symbol => $operand->content}, undef);
}

sub binding {
    my ($token, $statement) = @_;
    my ($open, $reason) = open_shape($token, $statement);
    return (undef, $reason) unless $open;
    my $previous = $statement->sprevious_sibling;
    return (undef, 'no adjacent variable declaration') unless ref($previous)
        && $previous->isa('PPI::Statement::Variable');
    return (undef, 'different PPI parent') unless refaddr($previous->parent) == refaddr($statement->parent);
    my @declaration = $previous->schildren;
    return (undef, 'not a single lexical-my literal initializer') unless @declaration == 5
        && $previous->type eq 'my' && $declaration[0]->content eq 'my'
        && $declaration[1]->isa('PPI::Token::Symbol') && $declaration[2]->content eq '='
        && $declaration[4]->content eq ';';
    return (undef, 'adjacent declaration names a different symbol')
        unless $declaration[1]->content eq $open->{symbol};
    my $value = simple_quote($declaration[3]);
    return (undef, 'initializer is not a simple quoted ASCII path') unless defined($value)
        && $value =~ /\A[A-Za-z0-9_.\/-]+\z/ && $value !~ m{\A/};
    my @parts = split m{/+}, $value;
    return (undef, 'parent traversal path excluded') if grep { $_ eq '..' } @parts;
    my $path = join '/', grep { length($_) && $_ ne '.' } @parts;
    return (undef, 'empty normalized path') unless length($path);
    return ({%$open, path => $path, source_path => $value,
        role => $open->{mode} =~ /\A</ ? 'declared-input-read' : 'declared-output-write',
        declaration_class => ref($previous), quote_class => ref($declaration[3]),
        declaration_location => position($previous), declaration => $previous->content,
        parent_class => ref($statement->parent),
        qualification => 'Adjacent significant declaration, same PPI parent, simple source symbol and restricted literal strings only; no runtime or callee proof.'}, undef);
}

my @documents;
for my $input (@{$request->{documents}}) {
    my $source = $input->{source};
    die "source digest mismatch\n" unless sha256_hex(encode_utf8($source)) eq $input->{sha256};
    my $document = eval { PPI::Document->new(\$source, readonly => 1) };
    die "PPI constructor refused $input->{path}: $@\n" unless ref($document);
    $document->index_locations;
    my (@unknown, @sites);
    my @tokens = $document->tokens;
    for my $ordinal (0 .. $#tokens) {
        my $token = $tokens[$ordinal];
        push @unknown, {ordinal => $ordinal, class => ref($token), content => $token->content}
            if ref($token) =~ /Unknown|Unmatched/;
        next unless $token->isa('PPI::Token::Word');
        my $word = $token->content;
        $word =~ s/.*:://;
        next unless $word eq 'open';
        my $statement = $token->statement;
        my ($found, $reason) = binding($token, $statement);
        push @sites, {ordinal => $ordinal, raw_word => $token->content, location => position($token),
            statement_class => ref($statement) || undef,
            statement => ref($statement) ? $statement->content : undef,
            matched => $found ? JSON::PP::true : JSON::PP::false,
            binding => $found, unmatched_reason => $reason};
    }
    push @documents, {path => $input->{path}, source_sha256 => $input->{sha256},
        roundtrip => $document->serialize eq $source ? JSON::PP::true : JSON::PP::false,
        unknown_tokens => \@unknown, token_count => scalar(@tokens), sites => \@sites};
}
print JSON::PP->new->canonical->utf8->encode({ppi_version => "$PPI::VERSION", documents => \@documents,
    limits => 'Bounded lexical adjacent initializer/open source bindings only. No LinkedSpec source execution, actual IO, Perl evaluation, alias/callee/full scope semantics, complete dependency graph or canonical/native custody.'}), "\n";

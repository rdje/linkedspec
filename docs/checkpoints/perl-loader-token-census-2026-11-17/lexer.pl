use strict;
use warnings;
use PPI;
use JSON::PP;
use Encode qw(encode_utf8);
use Digest::SHA qw(sha256_hex);

binmode STDIN, ':raw';
binmode STDOUT, ':raw';
my $request = JSON::PP->new->utf8->decode(do { local $/; <STDIN> });
die "PPI version changed\n" unless "$PPI::VERSION" eq $request->{ppi_version};
my %wanted = map { $_ => 1 } @{$request->{words}};
my $mention = join '|', map { quotemeta($_) } sort keys %wanted;

sub neighbor {
    my ($element) = @_;
    return undef unless ref($element);
    return {class => ref($element), content => $element->content};
}

my @documents;
for my $input (@{$request->{documents}}) {
    my $source = $input->{source};
    die "source digest mismatch: $input->{path}\n"
        unless sha256_hex(encode_utf8($source)) eq $input->{sha256};
    my $document = eval { PPI::Document->new(\$source, readonly => 1) };
    my $exception = "$@";
    if (!ref($document)) {
        push @documents, {path => $input->{path}, source_sha256 => $input->{sha256},
            status => 'constructor-refused', exception => $exception};
        next;
    }
    $document->index_locations;
    my $serialized = $document->serialize;
    my $roundtrip = $serialized eq $source;
    my (@sites, @mentions, @heredocs, @unknown);
    my %classes;
    my @tokens = $document->tokens;
    for my $ordinal (0 .. $#tokens) {
        my $token = $tokens[$ordinal];
        my $class = ref($token);
        ++$classes{$class};
        my $content = $token->content;
        my $location = $token->location;
        my @position = ref($location) eq 'ARRAY' ? @{$location}[0 .. 2] : ();
        if ($class =~ /Unknown|Unmatched/) {
            push @unknown, {ordinal => $ordinal, class => $class, content => $content, location => \@position};
        }
        if ($token->isa('PPI::Token::HereDoc')) {
            my $payload = join '', $token->heredoc;
            my %words;
            $words{$1} = 1 while $payload =~ /\b($mention)\b/g;
            push @heredocs, {ordinal => $ordinal, class => $class, declaration => $content,
                location => \@position, terminator => $token->terminator,
                payload_bytes => length(encode_utf8($payload)), payload_sha256 => sha256_hex(encode_utf8($payload)),
                words => [sort keys %words], role => 'separate heredoc payload; interpolation/nested execution unresolved'};
        }
        my $word = $content;
        $word =~ s/.*::// if $token->isa('PPI::Token::Word');
        if ($token->isa('PPI::Token::Word') && $wanted{$word}) {
            my $statement = $token->statement;
            my $previous = $token->sprevious_sibling;
            my $next = $token->snext_sibling;
            my $hint = 'word candidate; callee/phase/branch/runtime meaning unresolved';
            if (ref($previous) && $previous->content eq '->') {
                $hint = 'member-name candidate, not assumed to be a builtin';
            } elsif (ref($previous) && $previous->content eq 'sub') {
                $hint = 'subroutine declaration name';
            } elsif (ref($next) && $next->content eq '=>') {
                $hint = 'fat-comma key candidate';
            } elsif ($word eq 'do' && ref($next) && $next->isa('PPI::Structure::Block')) {
                $hint = 'inline do block, not a file-include expression';
            } elsif (ref($statement) && $statement->isa('PPI::Statement::Include')) {
                $hint = $word =~ /\A(?:use|no|require)\z/ ? 'include operator token' : 'include module/argument token';
            }
            push @sites, {ordinal => $ordinal, class => $class, word => $word, raw_word => $content, location => \@position,
                previous => neighbor($previous), next => neighbor($next), context_hint => $hint,
                statement_class => ref($statement) || undef,
                statement_content => ref($statement) ? $statement->content : undef,
                statement_limit => 'PPI content excludes heredoc payload; original source and separate payload identities retained'};
        } elsif (!$token->isa('PPI::Token::Word')) {
            my %words;
            $words{$1} = 1 while $content =~ /\b($mention)\b/g;
            if (%words) {
                push @mentions, {ordinal => $ordinal, class => $class, location => \@position,
                    content_bytes => length(encode_utf8($content)), content_sha256 => sha256_hex(encode_utf8($content)),
                    words => [sort keys %words], role => 'non-Word context; not counted as a Word site; interpolation/nested semantics unresolved'};
            }
        }
        if ($token->isa('PPI::Token::QuoteLike::Readline')
                || $token->isa('PPI::Token::QuoteLike::Backtick')
                || $token->isa('PPI::Token::QuoteLike::Command')) {
            push @sites, {ordinal => $ordinal, class => $class, content => $content, location => \@position,
                context_hint => 'quote-like IO/process candidate; runtime operand and phase unresolved'};
        }
    }
    my @includes;
    for my $include (@{$document->find('PPI::Statement::Include') || []}) {
        my $location = $include->location;
        my $version = $include->version;
        push @includes, {class => ref($include), type => $include->type, module => $include->module,
            version => defined($version) ? "$version" : undef, pragma_hint => scalar($include->pragma),
            location => ref($location) eq 'ARRAY' ? [@{$location}[0 .. 2]] : [],
            content => $include->content,
            role => 'PPI include syntax; module origin/conditional execution/import effects unresolved'};
    }
    my @helpers;
    for my $sub (@{$document->find('PPI::Statement::Sub') || []}) {
        my $name = $sub->name;
        next unless defined($name) && $name =~ /read|load|fixture|capture|persist|write|run|eval|emit/;
        my $location = $sub->location;
        push @helpers, {name => $name, class => ref($sub),
            location => ref($location) eq 'ARRAY' ? [@{$location}[0 .. 2]] : [],
            content_sha256 => sha256_hex(encode_utf8($sub->content)),
            role => 'named helper candidate; caller vocabulary/target edges require follow-up'};
    }
    my $row = {path => $input->{path}, source_sha256 => $input->{sha256},
        status => $roundtrip && !@unknown ? 'lexed-roundtrip' : 'lexical-qualification-needed',
        roundtrip => $roundtrip ? JSON::PP::true : JSON::PP::false,
        token_count => scalar(@tokens), token_classes => \%classes, sites => \@sites,
        non_word_mentions => \@mentions, heredocs => \@heredocs, unknown_tokens => \@unknown,
        includes => \@includes, helper_candidates => \@helpers};
    $row->{serialized_source} = $serialized unless $roundtrip;
    push @documents, $row;
}
print JSON::PP->new->canonical->utf8->encode({ppi_version => "$PPI::VERSION", documents => \@documents,
    limits => 'PPI lexical observations only. No LinkedSpec source compilation/test execution, complete Perl semantics, actual file read/process launch/module origin or full native/source-origin/per-read/physical custody.'}), "\n";

#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use FindBin;
use lib "$FindBin::Bin/../perl";
use LinkedSpec ();
use LinkedSpec::BootstrapSpec::Core ();
use LinkedSpec::RuleIR::EmitContext ();

sub _trim {
 my ($v) = @_;
 return '' unless defined $v;
 $v =~ s/^\s+|\s+$//g;
 return $v
}

sub _usage {
 return <<'USAGE';
Usage:
  perl tools/inspect_spec_codegen.pl --snippet '<snippet>'
  perl tools/inspect_spec_codegen.pl --label Top --snippet '<snippet>' --snippet '<snippet>'
  perl tools/inspect_spec_codegen.pl --snippet-file /path/to/snippets.txt

What this does:
  - Accepts pieces of .spec syntax (lifecycle snippets, action-edge snippets, or raw helper expressions)
  - Normalizes them to action-helper code
  - Runs LinkedSpec lowering
  - Prints generated Perl + canonical IR diagnostics

Accepted snippet forms:
  1) Lifecycle chain:
     I.lowercase_each(parts).filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)
  2) Lifecycle block:
     I { x = 1; return(x) }
  3) Action edge:
     /a/ -> Top .lowercase_each(parts).filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)
     /a/ -> Top { return(retv) }
  4) Raw helper/expression:
     filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)

Options:
  --label <name>         Default label context for non-edge snippets (default: Top)
  --snippet <text>       Add one snippet (repeatable)
  --snippet-file <path>  Read snippets (one per line, blank/# lines ignored)
  --help                 Show this help
USAGE
}

sub _extract_code_from_spec_snippet {
 my ($default_label, $snippet) = @_;
 my $s = _trim($snippet);
 return undef unless length $s;

 # Full action edge or shortened edge snippet.
 if ($s =~ /^(?:\/.*?\/\s*)?->\s*(?<label>\w+)(?:\[\d+\])?\s*(?<tail>.*)$/s) {
  my $label = $+{label};
  my $tail = _trim($+{tail});
  if (!length($tail)) {
   return {
    kind         => 'edge_empty_action',
    label        => $label,
    helper_code  => "call($label)",
    source_code  => "call($label)",
    source_snippet => $s,
   };
  }
  if ($tail =~ /^\{(?<code>.*)\}$/s) {
   my $code = _trim($+{code});
   return {
    kind           => 'edge_block',
    label          => $label,
    source_code    => $code,
    source_snippet => $s,
   };
  }
  if ($tail =~ /^(?<chain>\..+)$/s) {
   my $helper_code = LinkedSpec::BootstrapSpec::Core::_render_method_call_chain($label, $+{chain});
   return undef unless defined $helper_code;
   return {
    kind           => 'edge_chain',
    label          => $label,
    helper_code    => $helper_code,
    source_code    => $helper_code,
    source_snippet => $s,
   };
  }
  return {
   kind           => 'edge_tail_raw',
   label          => $label,
   source_code    => $tail,
   source_snippet => $s,
  };
 }

 # Lifecycle chain form (I./E./EX./IT./LX./LS./LE.).
 if ($s =~ /^(?<life>I|E|EX|IT|LX|LS|LE)\s*(?<chain>\..+)$/s) {
  my $helper_code = LinkedSpec::BootstrapSpec::Core::_render_method_call_chain($default_label, $+{chain});
  return undef unless defined $helper_code;
  return {
   kind           => 'lifecycle_chain',
   label          => $default_label,
   lifecycle      => $+{life},
   helper_code    => $helper_code,
   source_code    => $helper_code,
   source_snippet => $s,
  };
 }

 # Lifecycle block form.
 if ($s =~ /^(?<life>I|E|EX|IT|LX|LS|LE)\s*\{(?<code>.*)\}$/s) {
  return {
   kind           => 'lifecycle_block',
   label          => $default_label,
   lifecycle      => $+{life},
   source_code    => _trim($+{code}),
   source_snippet => $s,
  };
 }

 # Fallback: treat as raw helper/action expression.
 return {
  kind           => 'raw_expr',
  label          => $default_label,
  source_code    => $s,
  source_snippet => $s,
 }
}

my $label = 'Top';
my @snippets;
my $snippet_file;
my $help = 0;

GetOptions(
 'label=s'        => \$label,
 'snippet=s@'     => \@snippets,
 'snippet-file=s' => \$snippet_file,
 'help'           => \$help,
) or die _usage();

if ($help) {
 print _usage();
 exit 0;
}

if (defined $snippet_file) {
 open my $fh, '<', $snippet_file or die "Cannot open --snippet-file '$snippet_file': $!\n";
 while (my $line = <$fh>) {
  chomp $line;
  my $trim = _trim($line);
  next unless length $trim;
  next if $trim =~ /^#/;
  push @snippets, $line;
 }
 close $fh;
}

if (!@snippets) {
 print _usage();
 die "\nNo snippets provided. Use --snippet or --snippet-file.\n";
}

my $idx = 0;
foreach my $snippet (@snippets) {
 ++$idx;
 my $parsed = _extract_code_from_spec_snippet($label, $snippet);
 if (!$parsed) {
  print "=== CASE $idx ===\n";
  print "STATUS: parse_error\n";
  print "INPUT_SNIPPET: $snippet\n";
  print "ERROR: failed to parse snippet into lowerable code\n\n";
  next;
 }

 my ($lowered, $diag) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(
  $parsed->{label},
  $parsed->{source_code},
 );

 my @nodes = @{$diag->{canonical_action_ir_nodes} || []};
 my $fallback = $diag->{canonical_action_ir_fallback_count} || 0;
 my $unresolved = $diag->{unresolved_helper_count} || 0;

 print "=== CASE $idx ===\n";
 print "KIND: $parsed->{kind}\n";
 print "LABEL: $parsed->{label}\n";
 print "INPUT_SNIPPET:\n$parsed->{source_snippet}\n";
 if (defined $parsed->{helper_code}) {
  print "NORMALIZED_HELPER_CODE:\n$parsed->{helper_code}\n";
 } else {
  print "NORMALIZED_HELPER_CODE:\n$parsed->{source_code}\n";
 }
 print "GENERATED_PERL:\n$lowered\n";
 print "CANONICAL_IR_NODES: ".(@nodes ? join(', ', @nodes) : '(none)')."\n";
 print "RAW_PERL_FALLBACK_COUNT: $fallback\n";
 print "UNRESOLVED_HELPER_COUNT: $unresolved\n";
 print "\n";
}

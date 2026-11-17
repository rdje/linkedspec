---
id: perl-source-token-census
title: Perl loader census keeps lexical sites separate from runtime IO
answers:
  - "where is the Perl145 loader token census"
  - "how does the Perl census distinguish quoted open from a source Word"
  - "does a Perl Word site prove a file was opened"
  - "which inspected Perl consumers have non-block do sites"
  - "does PPI token content include heredoc payloads"
date: 2026-11-17
status: focused lexical census; target/caller/phase and native closure remain open
tags: [perl, loaders, tokens, ppi, provenance, discovery]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.0; docs/checkpoints/perl-loader-token-census-2026-11-17/ retains original source requests and producer outputs. All145 PPI1.270 documents round-trip/unknown0/stderr0/current162; four controlled specimens and actual promoted-Word/compiler-sentinel REDs pass. No LinkedSpec test execution."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/perl-loader-token-census-2026-11-17/review.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/perl-loader-token-census-2026-11-17/review.py --current"
---

The earlier145-source population is preserved with its original role dispositions
from [[perl-consumer-roles-and-selection]]. Installed PPI1.270 inspects source
strings and document serialization preserves their exact consumed text. This is
lexical observation, not compiler validation or execution of those tests.

Overlapping candidate populations contain122 IO/readline,143 eval/process,
84 named-helper,127 non-Word/heredoc and three non-block-do consumer files.
The vocabulary is bounded; these lists do not exhaust indirect library/helper
loaders or resolve runtime targets. All145 remain in the parent contract.

Non-block-do syntax occurs in the AST parser, scalar-copy and callable suites.
It names the assigned-regex suite, two scalar-copy probe files and eleven callable
includes. Expansion1 still qualifies caller/target/conditional/support roles;
probe files gain no standalone-suite or execution credit from this census.

A source Word called `open` can be a method, hash key or declaration. Quoted-only
keywords produce no Word sites in the controlled fixture; promoting one into
source gives actual Word1 versus the old expected0, observed RED at lexer exit0.
The mixed controlled BEGIN compiles with actual exit255/sentinel, while PPI
inspection succeeds. No LinkedSpec source is compiled by this proof.

PPI token/statement `content` excludes heredoc payloads. Document `serialize`
preserves them, with separate payload identities. Non-Word/quoted/interpolated
content can execute later and remains explicitly unqualified with generated/
inline2 and broader semantic reconciliation. No site count means a file was read.

Readonly default review recovers saved source/observations; `--current` checks
the original162 bodies/modes. Optional `--relex` repeats only the retained static
lexer, requires the recorded PPI version and exact original channels, and never
replays capture or compiles the tests. Full external PPI/Perl/library/native/
outer-first-use/per-read/source-origin/physical closure stays4.2/SESSION5.

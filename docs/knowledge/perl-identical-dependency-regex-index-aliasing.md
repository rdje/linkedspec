---
id: perl-identical-dependency-regex-index-aliasing
title: "Perl indexed dependency dispatch cannot distinguish identical regex alternatives"
answers:
  - "why does an AND action sequence report the wrong match index"
  - "what happens when two edge owned regex slots have the same pattern"
  - "why did the rule local cursor marker fixture need delimiter lookahead"
  - "where is identical dependency regex identity tracked"
  - "does LinkedRE preserve slot identity for duplicate regex patterns"
date: 2026-07-17
status: confirmed latent risk; repair owned by FUTURE-PARITY-BACKLOG.9.1.8.1
tags: [perl, regex, dependency-map, action-edge, index, trace, cursor, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.3.2, an AND marker fixture with explicit edges for all five slots still returned undef. Routed debug trace showed the second word at cursor position 10 matched dependency index 1 while the handler required index 3. Compiler::build_dependency_regex_map collects the two slot regexes in dependency order; LinkedRE::oredRE emits a left-to-right alternation with a branch-local $pos assignment. Because both alternatives were /\\w+/, Perl selected the first matching branch and therefore returned index 1 for both word positions. Making the slots mutually exclusive with /\\w+(?=,)/ and /\\w+(?=\\))/ produced indices 1 and 3 and restored the exact expected value. This is a pre-existing slot-identity limitation, not rule-local cursor semantics; the fixture migration is local and `.9.1.8.1` owns the cross-backend language decision and engine repair/rejection."
reverify: "LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl -MLinkedSpec -e 'my $s=join chr(10), q{Top::AND}, q{ /foo\\(/ -> Top[0] { }}, q{ /\\w+/ -> Top[1] { }}, q{ /,/ -> Top[2] { }}, q{ /\\w+/ -> Top[3] { }}, q{ /\\)/ -> Top[4] { return(1) }}, q{}; my $p=LinkedSpec::Get(\\$s); my $in=q{foo(alpha,beta)}; my $out=$p->(\\$in); print defined($out) ? $out : q{undef}, qq{\\n}' && rg -n 'sub oredRE|build_dependency_regex_map|FUTURE-PARITY-BACKLOG.9.1.8.1' perl/LinkedRE.pm perl/LinkedSpec/Compiler.pm docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

Perl action-sequence handlers dispatch by a dependency-alternative index. The
compiler gathers each edge-owned slot regex in dependency order, and
`LinkedRE::oredRE` builds one left-to-right Perl alternation whose branch-local
code sets the returned index. Textually identical alternatives are not distinct
to Perl's alternation engine: the first branch wins at every position where both
patterns match.

This matters when an ordered handler expects the later slot index. The matcher
can consume the correct text yet report the earlier identical slot, after which
the AND sequence rejects the result as out of order. Routed debug trace is the
decisive probe: compare `match_index` with `expected_index` on
`generated_handler_branch:and_acode_seq:<Rule>:required_sequence_index`.

The `.9.1.3.2` historical marker fixture did not define the language contract
for duplicate slots. It now uses delimiter-sensitive word patterns that are
mutually exclusive and therefore preserve its actual mark-trace purpose. The
portable expectation, five-backend inventory, and an engine-level identity
representation or typed rejection are separately owned by
`FUTURE-PARITY-BACKLOG.9.1.8.1`.

Related: [[perl-rule-local-cursor-rollout-boundaries]],
[[rule-local-cursor-and-bare-edge-contract]], and
[[FUTURE-PARITY-BACKLOG]].

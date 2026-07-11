---
id: perl-generated-source-capture-not-standalone
title: Perl captured parser source is not yet independently executable with equivalent dispatch
answers:
  - "is Perl dump_parser_source standalone parser source"
  - "why does independently compiled Perl generated source return undef"
  - "why is the Perl generated-source capability partial"
  - "what happens to dependency regex indexes in captured Perl source"
  - "what does FUTURE-PARITY-BACKLOG.3.1 repair"
date: 2026-07-11
status: current
tags: [perl, generated-source, LinkedRE, compiler, root-cause, parity]
evidence: "FUTURE-PARITY-BACKLOG.3.1.0 used LinkedSpec::Get twice on a minimal consume-mode action-edge spec: the normal returned parser returned 'ok'; generate_only + dump_parser_source + parser_source_ref produced source that eval-compiled in an isolated package but returned undef. Debug trace from the recompiled source recorded match_index=1 for the single alternative and skipped acode_index_0 before exhausting to undef. Compiler.pm build_dependency_regex_map constructs the working object with LinkedRE::oredRE, while its dump path stringifies that Regexp into qr/(?^:...(?{$pos=0}))/o. LinkedRE::or establishes lexical my $pos inside the outer matching regex. Recompiling the stringified inner qr binds its $pos marker outside that dynamic lexical relationship, so the match consumes input but the selected index is wrong or undefined. The current capture is diagnostic source, not a standalone behavior-equivalent module."
reverify: "PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::Trace -e 'my $spec = qq{Top::\\n /x/ -> Done { return(\"ok\") }\\n\\nDone::\\n /[a-z]+/\\n}; my $source = q{}; LinkedSpec::Get(\\$spec, parse_mode => q{consume}, generate_only => 1, dump_parser_source => 1, parser_source_ref => \\$source); print $source' && rg -n '_ored_re|build_dependency_regex_map|dependency_regex_map|flush_runtime_ctx_parser_source|sub or|sub oredRE' perl/LinkedSpec/Compiler.pm perl/LinkedSpec/RuntimeContext.pm perl/LinkedRE.pm"
---

# Perl captured generated source is diagnostic-only today

The Perl reference compiler genuinely generates handler source and executes it
inside the normal parser pipeline. That does not currently make the complete
text captured through `parser_source_ref` a standalone parser module.

The failing boundary is dependency-regex serialization:

1. the live compiler calls `LinkedRE::oredRE(...)` and keeps the resulting
   compiled `Regexp` object;
2. `LinkedRE::or(...)` wraps that object in a matching regex which initializes
   lexical `my $pos`, and embedded alternative markers set that index;
3. the source dump stringifies the compiled object as a `qr/...(?{$pos=N}).../`
   literal;
4. independent recompilation binds the marker outside the dynamic lexical
   relationship established by `LinkedRE::or`;
5. matching still consumes input, but `match_index` is wrong or undefined, so
   generated action dispatch can be skipped and the result drifts.

This invalidates the earlier `pass` classification for the complete
host-source compile/run capability. `FUTURE-PARITY-BACKLOG.3.1` now owns a
neutral executable contract, a Perl reconstruction repair, and final admission.
The corrected census is 56 pass, two partial, and two gap states until repair.

Related facts: [[generated-source-parity-audit]], [[handler-ir-design]],
[[user-observable-backend-cli-parity-contract]].

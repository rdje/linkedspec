---
id: perl-generated-source-capture-not-standalone
title: Perl captured parser source formerly lost dependency indexes; contract-v1 reconstruction fixes it
answers:
  - "is Perl dump_parser_source standalone parser source"
  - "why does independently compiled Perl generated source return undef"
  - "why is the Perl generated-source capability partial"
  - "does Perl generated source pass the capability census"
  - "what happens to dependency regex indexes in captured Perl source"
  - "what does FUTURE-PARITY-BACKLOG.3.1 repair"
date: 2026-07-11
status: resolved
tags: [perl, generated-source, LinkedRE, compiler, root-cause, parity]
evidence: "FUTURE-PARITY-BACKLOG.3.1.0 used LinkedSpec::Get twice on a minimal consume-mode action-edge spec: the normal returned parser returned 'ok'; generate_only + dump_parser_source + parser_source_ref produced source that eval-compiled in an isolated package but returned undef. Debug trace from the recompiled source recorded match_index=1 for the single alternative and skipped acode_index_0 before exhausting to undef. Compiler.pm build_dependency_regex_map constructs the working object with LinkedRE::oredRE, while its dump path stringifies that Regexp into qr/(?^:...(?{$pos=0}))/o. LinkedRE::or establishes lexical my $pos inside the outer matching regex. Recompiling the stringified inner qr binds its $pos marker outside that dynamic lexical relationship, so the match consumes input but the selected index is wrong or undefined. The current capture is diagnostic source, not a standalone behavior-equivalent module."
evidence_update_2026_07_11_repair: "FUTURE-PARITY-BACKLOG.3.1.2 changes Compiler.pm to reconstruct each dependency alternation as LinkedRE::oredRE over canonical referenced rule regexes instead of stringifying the compiled alternation. LinkedSpec::GeneratedSource and the public LinkedSpec::emit_generated_source facade add deterministic v1 markers, ordered family plan validation, semantic trace roles, and structured errors; legacy capture emits identical text. t/generated_source_contract.t proves exact independent results, arbitrary-package loading, indexes zero and one, a slash-bearing regex, identity/metadata, all four plan rejections, emission/execution errors, and trace roles. Existing generated trace suites pass and Phase 0 reaches 1..1030 after two stale source-wrapper locks are migrated."
evidence_update_2026_07_11_admission: "FUTURE-PARITY-BACKLOG.3.1.3.3 passes the 69-assertion focused contract and canonical Perl gate including Phase 0 1..1030 and 61x2 CLI, promotes Perl generated source to pass, and closes .3.1. The old partial classification is historical; the current census is 57/1/2."
reverify: "PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::Trace -e 'my $spec = qq{Top::\\n /x/ -> Done { return(\"ok\") }\\n\\nDone::\\n /[a-z]+/\\n}; my $source = q{}; LinkedSpec::Get(\\$spec, parse_mode => q{consume}, generate_only => 1, dump_parser_source => 1, parser_source_ref => \\$source); print $source' && rg -n '_ored_re|build_dependency_regex_map|dependency_regex_map|flush_runtime_ctx_parser_source|sub or|sub oredRE' perl/LinkedSpec/Compiler.pm perl/LinkedSpec/RuntimeContext.pm perl/LinkedRE.pm"
---

# Perl captured source formerly lost dependency indexes

The Perl reference compiler always generated handler source inside the normal
parser pipeline. Before `.3.1.2`, the complete text captured through
`parser_source_ref` was not a behavior-equivalent standalone module.

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

This invalidated the earlier `pass` classification until the repair had direct
proof. `FUTURE-PARITY-BACKLOG.3.1` subsequently defined the neutral contract,
repaired reconstruction, and completed explicit admission. Perl generated
source now passes; after later Rust breadth admission the current census is
58 pass, zero partial, and two gaps.

The fix rebuilds each emitted dependency alternation with `LinkedRE::oredRE`
from canonical referenced-rule regexes at generated-module load time. Public
`emit_generated_source(...)` and legacy capture now emit identical source that
loads in arbitrary packages and returns exact indexed results.

Related facts: [[generated-source-parity-audit]], [[handler-ir-design]],
[[user-observable-backend-cli-parity-contract]].

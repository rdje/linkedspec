---
id: pplugin-descriptor-ready-legacy-runtime-boundary
title: pplugin.spec is descriptor-ready while .plg execution remains legacy Perl runtime behavior
answers:
  - "is pplugin a compatibility-surface spec"
  - "does pplugin have blocked language agnostic rules"
  - "why does pplugin still return Perl coderefs"
  - "does pplugin.spec return coderefs"
  - "where are pplugin body coderefs created"
  - "is .plg execution backend neutral"
  - "what is the pplugin descriptor readiness status"
date: 2026-07-08
status: current
tags: [pplugin, mdbook, compatibility-surface, descriptor, legacy-runtime]
evidence: "SPEC-SOURCE-TERSE-CLOSEOUT.1: t/phase0_regression.t pplugin_helper_flow_eliminates_raw_fallback + pplugin_parser_smoke; specs/pplugin.spec subdef[1] returns array(entry_named(subname), capture_slice()); perl/PPlugin.pm _normalize_plugin_registry_payload wraps body text into legacy coderefs"
evidence_update_2026_09_13: "SUPPORTING-SOURCE-READING.1.17 reads all 33 source lines. A separate grammar-only probe returns the exact hash foo => body text with surrounding spaces for foo { 1 + 2 }; PPlugin.pm remains unloaded. The full descriptor-only .4 probe remains unchanged evidence. The preferred focused reading probe is SUPPORTING_GRAMMAR_AST_PROBE in spec-spec-self-hosted-grammar.md; the older composite reverify below additionally executes legacy adapter behavior and was not run for this reading."
reverify: "perl -Iperl -MLinkedSpec -MPPlugin -e 'my $d=LinkedSpec::get_parser(\"pplugin\", return_descriptor=>1); my $m=$d->{meta}{action_rewriter_migration}; print join(\"\\n\", $m->{language_agnostic_ready_ratio}, $m->{language_agnostic_blocked_rule_count}, $m->{compatibility_surface_rule_count}), \"\\n\"; my $p=LinkedSpec::get_parser(\"pplugin\"); my $s=\"foo { 1 + 2 }\"; my $ast=$p->(\\$s); print $ast->{foo},\"\\n\"; my $r=PPlugin::_normalize_plugin_registry_payload($ast); print $r->{foo}->(),\"\\n\"'"
---

`pplugin.spec` currently reports descriptor readiness for the `.spec` parser itself:
`language_agnostic_ready_ratio = 1.0000`, `language_agnostic_blocked_rule_count = 0`,
and `compatibility_surface_rule_count = 0`.

That does not make `.plg` execution a portable runtime target. `pplugin.spec` now returns
name-to-body-text pairs; `subdef[1]` uses `array(entry_named(subname), capture_slice())`.
The legacy Perl `PPlugin` runtime normalizes that parsed payload into name-to-coderef pairs
for older callers. Treat those coderefs as reference-runtime behavior, not as a
cross-backend contract.

The September13 source reading confirms that the top rule collects parsed
name/body pairs and converts them to a hash. Nested curly blocks and quoted text
have their own subordinate rules; `subdef[1]` returns the captured name and body
slice. The small focused probe verifies the exact body-text result and absence of
the legacy adapter. It grants no portable callback-execution contract.

Related: [[pplugin-pluginbridge-transition-machinery]].

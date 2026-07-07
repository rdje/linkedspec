---
id: pplugin-descriptor-ready-legacy-runtime-boundary
title: pplugin.spec is descriptor-ready while .plg execution remains legacy Perl runtime behavior
answers:
  - "is pplugin a compatibility-surface spec"
  - "does pplugin have blocked language agnostic rules"
  - "why does pplugin still return Perl coderefs"
  - "is .plg execution backend neutral"
  - "what is the pplugin descriptor readiness status"
date: 2026-07-07
status: current
tags: [pplugin, mdbook, compatibility-surface, descriptor, legacy-runtime]
evidence: "t/phase0_regression.t pplugin_helper_flow_eliminates_raw_fallback; specs/pplugin.spec subdef[1]; perl/PPlugin.pm legacy runtime owner"
reverify: "perl -Iperl -MLinkedSpec -e 'my $d=LinkedSpec::get_parser(\"pplugin\", return_descriptor=>1); my $m=$d->{meta}{action_rewriter_migration}; print join(\"\\n\", $m->{language_agnostic_ready_ratio}, $m->{language_agnostic_blocked_rule_count}, $m->{compatibility_surface_rule_count}), \"\\n\"'"
---

`pplugin.spec` currently reports descriptor readiness for the `.spec` parser itself:
`language_agnostic_ready_ratio = 1.0000`, `language_agnostic_blocked_rule_count = 0`,
and `compatibility_surface_rule_count = 0`.

That does not make `.plg` execution a portable runtime target. The legacy Perl `PPlugin`
runtime still parses `.plg` files with `pplugin.spec` and receives name-to-coderef pairs;
`subdef[1]` returns a Perl callback containing `eval substr(...)` for plugin-body execution.
Treat those coderefs as reference-runtime behavior, not as a cross-backend contract.

Related: [[pplugin-pluginbridge-transition-machinery]].

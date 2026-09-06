---
id: pplugin-pluginbridge-transition-machinery
title: PPlugin and PluginBridge are transition/removal machinery, not the target architecture; dynamic plugin loading is legacy-removal territory
answers:
  - "are PPlugin and PluginBridge part of the target architecture"
  - "should new code use plugin dispatch"
  - "what is the plugin modernization status"
  - "is LinkedSpec still a plugin-hosting framework"
  - "does registered Perl plugin dispatch load the legacy PPlugin runtime"
  - "where do Perl plugin replacement and bulk registration live"
date: 2026-09-06
status: current
tags: [architecture, plugin, legacy, modernization]
evidence: "ARCHITECTURE_STATE.md §Current Strategic Judgments: 'LinkedSpec is no longer best understood as a plugin-hosting framework'; PLUGIN-MODERNIZATION tree completed (5 leaves, 2026-05-17)"
reverify: "grep -n 'transition.removal.machinery\|plugin-hosting framework' ARCHITECTURE_STATE.md"
---

The current architecture direction explicitly treats `PPlugin` and `PluginBridge` as
transition/removal machinery, not as the future identity of LinkedSpec. Key points:

- **`LinkedSpec.pm` still exposes** `run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`,
  and `AUTOLOAD` — all marked `DEPRECATED` with retirement tied to `PLUGIN-MODERNIZATION.5`.
- **`PluginBridge`** is a registry-first dispatch shim over the older `.plg` runtime; it
  assembles its default callback map through `OwnerDispatch::build_dep_map`.
- **`PPlugin`** owns legacy `.plg` discovery, reads files through explicit IO, parses via the
  `pplugin` spec, and lazy-loads its default parser callback through `OwnerDispatch`.
- **The lazy compatibility cycle**: `LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`.
- **17 dead `.plg` files** deleted (1,030 lines, 45 actions) in `PLUGIN-ACTION-MIGRATION`.
  The earlier census of **19 `.plg` files** is historical; the September 6 Git census contains
  **13**, all under `noncore/plugin/`.
- **Extracted helper owners** (`HTTP::FileAccess`, `QC::Flow`, `Timing::SetupHold`, etc.) now
  live outside `LinkedSpec::*` under domain packages. Direct Perl callers use these owners
  instead of routing through `LinkedSpec::run_plugin(...)`.

The clearer core story: named `.spec` lookup, parser compilation, parser runtime, action
lowering, diagnostics. Dynamic plugin loading was historically useful but is not the
architectural center anymore.

`RUST-PARITY.7.3.6` only added the empty `pplugin_empty` syntax smoke to the Rust oracle
corpus. `SPEC-SOURCE-TERSE-CLOSEOUT.1` later moved plugin-body coderef wrapping out of
`specs/pplugin.spec`: the parser now returns body text and the Perl `PPlugin` adapter
wraps it for legacy callers. Richer `pplugin` subdefinitions still are not evidence that
the legacy plugin runtime is a backend-neutral target; promoting them to the Rust oracle
requires a separate Rust parser/runtime parity owner.

`LUA-BACKEND-PARITY.6.2.3` makes the existing empty `pplugin_empty` smoke pass on Lua by
implementing the neutral `hash(flat_array(...))` constructor boundary. That result proves
hash/list-context parity for the syntax smoke; it does not broaden Lua into legacy plugin
runtime execution.

Related: [[ownerdispatch-shared-seam]], [[lua-flat-array-hash-splicing]].

## September 6 bridge and registry ownership

Reading checkpoint `.3.2.39` covers PluginBridge 1–199 and PluginRegistry 1–130. The bridge validates
bare explicit names separately from AUTOLOAD suffix normalization, requires its injected fallback callbacks,
and resolves registered CODE handlers before lazy legacy loading. OwnerDispatch preserves successful caller
error state. PluginRegistry owns process-local state, replacement, sorted bulk registration, lookup/presence,
and clear counts. Bulk registration iterates entries; this does not promise transactional rollback.

An isolated public-facade control verifies two registrations, argument-preserving dispatch, callback lookup,
replacement, two-entry clear, invalid-name rejection, preserved caller error state, and no PPlugin load.
Legacy fallback execution and the full Phase 0 suite are not rerun in this reading checkpoint.

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict;use warnings;my $j=JSON::PP->new->canonical;
LinkedSpec::clear_registered_plugins();
die 'legacy eagerly loaded' if exists $INC{'PPlugin.pm'};
my $count=LinkedSpec::register_plugins({reading_probe=>sub{ return join(':',@_) },reading_other=>sub{0}});
die 'bulk count' unless $count==2;
$@="saved-reading-error\n";my $value=LinkedSpec::run_plugin('reading_probe','a','b');
die 'dispatch/error state' unless $value eq 'a:b' && $@ eq "saved-reading-error\n";
my $cb=LinkedSpec::get_plugin('reading_probe');die 'lookup' unless ref($cb) eq 'CODE' && $cb->('c') eq 'c';
LinkedSpec::register_plugin('reading_probe',sub{'replaced'});
die 'replacement' unless LinkedSpec::run_plugin('reading_probe') eq 'replaced';
die 'legacy loaded by registered dispatch' if exists $INC{'PPlugin.pm'};
my $removed=LinkedSpec::clear_registered_plugins();die 'clear count' unless $removed==2;
my $ok=eval{LinkedSpec::register_plugin('invalid-name',sub{1});1};die 'invalid name accepted' if $ok;
print $j->encode({bulk_count=>$count,dispatch=>$value,lookup=>'c',replacement=>'replaced',removed=>$removed,invalid_name=>'rejected',legacy_loaded=>JSON::PP::false,error_state=>'preserved'}),"\n";
PERL
```

## September 6 legacy discovery and configuration reading

`.3.2.53` completes PPlugin 331 lines, PathSearch 47 lines, and env.conf 51 lines alongside the
function registry (1,202 lines / 45,829 bytes total), all baseline-identical. PPlugin's default
ordered roots are the invocation working directory and repository `plugin/`; it does not automatically
search the 13 parked `noncore/plugin/` files. Per-root filenames are sorted and deduplicated; the
legacy registry is cached on first construction. Body text becomes Perl eval callbacks only in this
legacy adapter. Registered PluginBridge dispatch remains independent, as proven in `.3.2.39`.

PathSearch is older generic recursive discovery: it caches a directory census, adds caller directories,
deduplicates via a hash, and returns the first discovered matching basename/extension. No deterministic
root-precedence guarantee is inferred from that hash order. env.conf retains legacy program/configuration
and system-tool spellings; neither file was executed or treated as current portable parser authority.
The parked plugin census uses `git ls-files -- '*.plg'`, not recursive runtime discovery. No legacy
callback, network/configured service, or cleanup command is invoked by this reading checkpoint.

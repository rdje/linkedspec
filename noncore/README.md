# `noncore/` — modules NOT in the LinkedSpec import tree (parked, fate undecided)

Everything here was **proven unreachable** from the LinkedSpec product — i.e. from
`perl/LinkedSpec.pm` (the `.spec` engine), the 20 shipped `specs/*.spec`, and `conf/`/`ebnf/`/
`tablescript/` — by the dependency-tree extraction in `docs/tasks/NONCORE-QUARANTINE.md`
(`.1`). It is mostly old EDA / chip-design-flow Perl tooling.

**Status:** *parked*. Nothing here is loaded by the engine. Each entry can be `git rm`'d at any
time. We relocate (`git mv`) rather than delete so the option to **refactor / port / publish /
delete** stays open and reversible. Package layout is preserved, so a module stays loadable with
`perl -Inoncore ...` if we ever revive it.

**This is a ledger, not a contract.** The "fate hint" is a non-binding first read to save
future-us from re-deciding from zero; everything is still *undecided*.

## Fate hints
- `revive-candidate` — a generalizable kernel worth a clean rewrite (LLM-assisted), using the old
  code as a reference spec — NOT a port of the cruft.
- `replaceable` — generic, but 2026 has good equivalents; low reason to revive.
- `likely-rm` — domain-specific glue tied to dead/renamed vendor tools, Windows OLE, or Tcl::Tk;
  expected eventual `git rm`.

## Ledger — `.pm` (36)

| Module | Fate hint | Note | Relocated? |
| --- | --- | --- | --- |
| `Lispish` | revive-candidate | tiny S-expression parser (most reusable kernel) | pending (cluster) |
| `LispML` | revive-candidate | Lisp-ish markup atop Lispish | pending (cluster) |
| `LibReader` | revive-candidate | Liberty (`.lib`) reader — real, widely-used EDA format | ✅ moved |
| `HUtils` | replaceable | hash/list/recurse/keygrep utilities | pending (cluster) |
| `Table` / `Table2SS` / `TableGrep` / `TableScript` / `TableSort` / `Table::GenericFilter` | replaceable | table munging → `Spreadsheet::WriteExcel` | pending (cluster) |
| `XLSreader` | replaceable | Excel reader | ✅ moved |
| `HTML::PathLinks` | replaceable | path-token HTML links (contains a hanging regex) | pending (cluster) |
| `HTTP::FileAccess` | replaceable | file-link HTML + lighttpd/httpd launch | pending (cluster) |
| `Text::VariableSubstitution` | replaceable | string var substitution | pending (cluster) |
| `InteractivePrompt` | replaceable | yes/no prompts | pending (cluster) |
| `Global` | replaceable | shared config accessor (legacy-island only) | pending (cluster) |
| `HLinkSubst` | replaceable | hyperlink substitution | pending (cluster) |
| `AmbiTiming` / `EncounTiming` / `MagmaTiming` / `PTiming` / `Reportiming` | likely-rm | vendor STA/synth parsers (Ambit/Encounter/**Magma=defunct**/PrimeTime) | ✅ moved |
| `Timing::SetupHold` / `Timing::StanBackend` / `Timing::StanOmap2430cBackend` | likely-rm | chip-specific STA backends | pending (cluster) |
| `QC::Flow` / `QC::Summary` / `QC::TclInterconn` | likely-rm | internal quality-check flows | pending (cluster) |
| `MSOffice::Excel` | likely-rm | `Win32::OLE` Excel automation (Windows-only) | pending (cluster) |
| `TkGui` / `EasyTk` / `HDisplay` | likely-rm | `Tcl::Tk` GUIs (obsolete) | ✅ moved |
| `TcFlow` | likely-rm | test-control flow glue | pending (cluster) |
| `rvp` | likely-rm | verilog parsing helper | ✅ moved |
| `PluginUtils` | likely-rm | orphan plugin-migration stub (0 refs) | ✅ moved |

## Ledger — `.plg` (13, all `likely-rm`)
`common, duty_cycle_degradation, network, qc_summary, qcflow, raw, setup_hold_tmax_tmin, skew,
spyglass, stan_backend, stan_omap2430c_backend, test, tree` — the legacy AUTOLOAD plugin corpus;
no shipped spec/conf references any. Relocated to `noncore/plugin/` in a later batch (with their
phase0 smoke tests removed). *(pending)*

## NOT here (stays in core, for now)
The plugin *machinery* — `LinkedSpec/PPlugin.pm`, `LinkedSpec/PluginBridge.pm`,
`LinkedSpec/PluginRegistry.pm` + the deprecated `LinkedSpec.pm` stubs (`run_plugin`/`get_plugin`/
`dispatch_plugin_autoload_name`/AUTOLOAD/`register_plugin*`) — is reachable from the core via those
stubs, so its retirement is a separate, later core-facade decision (`NONCORE-QUARANTINE.N`).

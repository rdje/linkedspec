---
id: perl-root-rule-selection-admission
title: "Perl root-selection admission is topology-locked at the 65-case primary reference"
answers:
  - "is Perl root rule selection fully admitted"
  - "how many shared primary CLI cases does Perl pass"
  - "which shared CLI cases lock first marker and markerless default selection"
  - "what topology does the Perl root selection checker require"
  - "which Perl root selection tests run in canonical CI"
  - "what is the root selection rollout count after Perl"
  - "which variants still lack root selection parity"
  - "why do Rust Dart Julia and Lua still have a staged primary manifest mismatch"
date: 2026-07-18
status: confirmed composed Perl admission; later backend rollout staged
tags: [perl, root-rule, top-rule, cli, conformance, topology, rollout, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.1.3 adds `success_default_first_authored_marker` and `success_markerless_first_authored_rule` to the shared primary manifest beside the existing explicit ordinary, unknown selector, default request-trace, and escaped explicit request-trace cases. Perl passes all 65 cases with `POSIXLY_CORRECT` unset and set. `tools/check_root_rule_selection_contract.py` requires the core consumer to read neutral selection/failure/strict rows; the routes consumer to cover loaded, SpecLoader, generated roles, metadata, configured unknown selection, and effective trace; canonical CI to require and run both; and the manifest/trace fixtures to retain exact source topology and bytes. The focused pair passes 12 tests. Only `perl_reference` advances, so the seven-leg ledger is 2 complete / 5 pending; Rust, Dart, Julia, Lua, and final admission remain `.9.1.1.2.2-.6`."
evidence_update_2026_07_18_signoff: "Focused root/generated/CLI proof passes 5 files / 27 tests. Canonical local CI passes all four doctrines, root core 7, routes 5, cursor admission 288, primary 65/65 in default and POSIX environments, and Phase 0 1,031/1,031 in 611 seconds before exit 0. Knowledge Map is 598 facts / 4,277 question keys."
evidence_update_2026_07_18_rust_admission: "Rust subsequently reaches the same 65/65 default/POSIX boundary through one topology-checked 15-role consumer, advancing rollout to 3 complete / 4 pending. Dart, Julia, Lua, and final admission remain staged."
reverify: "python3 tools/check_root_rule_selection_contract.py && PERL5LIB= prove -Iperl t/root_rule_selection_perl_core.t t/root_rule_selection_perl_routes.t && PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec && POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec"
---

# Perl root-selection admission

Perl is the first runtime backend admitted to ADR `0046`'s exact precedence. Its library, loaded/reconstructed,
generated direct/traced/Get, descriptor, structured diagnostic, runtime/request trace, strict-unused, and primary
routes all consume the same explicit selector > first authored marker > first authored rule model.

The shared CLI manifest is reference-first during rollout. Its two new success cases make the default branches
observable in exact bytes:

- `success_default_first_authored_marker` proves a first `Rule::` beats an earlier ordinary rule and a later
  marker, returning `"marked"\n`;
- `success_markerless_first_authored_rule` proves a markerless two-rule source enters its first rule, returning
  `"first"\n`.

Existing cases retain the other public boundaries: explicit `--top-rule Alternate` wins, an unknown selector exits
1 with `linkedspec: parser invocation failed`, `<default>` records omission in request trace, and an escaped
explicit selector cannot forge a second trace record.

This 65-case manifest is not yet an all-variant parity claim. Rust is now admitted to the same bytes, while Dart,
Julia, and Lua still reject markerless source before reaching their existing fallback helpers. Their ordered leaves
must converge before final five-backend admission.

Related: [[root-rule-selection-precedence]], [[perl-root-rule-selection-core]],
[[perl-root-rule-selection-routes]], and [[perl-root-rule-selection-preflight]].

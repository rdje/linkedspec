# 0044 - Rule families own cursor policy and bare edge ownership

- Date: 2026-07-17
- Status: accepted; implemented and public no-drift closed
- Tags: architecture, grammar, cursor, parse-mode, and-rule, or-rule, edges, descriptors, generated-source, cli, parity

## Context

`FUTURE-PARITY-BACKLOG.9.1.0` proved that the former public `parse_mode` option was a whole-grammar override. At
that audit boundary Perl, Dart, Julia, and Lua defaulted the override to seek, while Rust derived AND=consume and OR/default=seek before
permitting an execution-wide override. The same default `Top::AND` grammar therefore already behaves differently
across backends. The audit also proved that seek and consume are both legitimate low-level matcher algorithms, but
found no semantic objective for letting a caller silently rewrite every nested rule.

The director then fixed the composition boundary in `.9.1.1.0`: every rule owns its cursor behavior. Parent mode
never propagates to a child through a blind call, action edge, explicit `call(...)`, or recursion. The remaining
decision is the exact grammar, metadata, migration, generated-source, diagnostic, and conformance contract.

## Decision

### 1. Rule family is the cursor authority

Every authored rule has one intrinsic, read-only cursor policy:

- AND-family rules (`&`, `AND`, `AND+`, and `AND{...}`) use `consume`;
- OR/default-family rules (bare/default, `|`, `+`, `*`, `?`, `OR`, `OR+`, and `OR{...}`) use `seek`.

`consume` anchors the next match at the current cursor. `seek` selects the earliest next match at or after the
cursor. `::` only marks the rule entered first; it does not alter family or cursor policy. Edge kind also does not
alter cursor policy. In particular, the Rust special case that currently assigns consume merely because a rule has
blind-call dispatch is not part of the accepted contract.

A child begins at the caller's current cursor and then applies its own policy. An OR child beneath an AND parent may
seek; an AND child beneath an OR parent must consume. On success the caller resumes from the child's resulting
cursor. Low-level seek/consume matcher APIs remain implementation primitives, not public grammar overrides.

The two useful historical cross-combinations remain expressible structurally. Ordered landmarks are an AND rule
composed from OR/default child rules. Anchored choice is an OR rule composed from one-anchor AND child rules. No
rule-local or caller-global cursor escape hatch is added.

### 2. Bare rule-edge lines resolve from the parent family

A bare edge is a complete rule-paragraph member beginning with a declared rule label, with no leading `->` or
`=>`. It may have the same block or fluent suffix as the edge kind to which it resolves. Bare edges are line-level
syntax: they do not begin after a regex or another paragraph member on the same physical line. Forward-declared
rule labels are valid because resolution occurs after the complete specification is known.

- In an AND-family rule, `Child`, `Child { ... }`, and `Child.method(...)` normalize to the corresponding explicit
  blind-call forms `=> Child`, `=> Child { ... }`, and `=> Child.method(...)`.
- In an OR/default-family rule, the same forms normalize to the corresponding explicit action-edge forms
  `-> Child`, `-> Child { ... }`, and `-> Child.method(...)`.

Normalization happens before validation, typed AST/IR admission, descriptor projection, or code generation. All
later stages consume the resolved action/blind ownership; runtime dispatch must not repeatedly infer it from source
text.

Lifecycle names `I`, `LS`, `LE`, `LX`, `E`, `EX`, and `IT` remain reserved at paragraph-member start and take
lexical precedence over bare-edge recognition. A rule with one of those labels remains callable, but its edge must
use explicit `->` or `=>`. Any other bare identifier must resolve to a declared rule; it is not an implicit helper,
user-function, lifecycle, or arbitrary code-block name.

### 3. Explicit edges remain legal and authoritative

`->` always means parent-owned action/regex-slot dispatch and `=>` always means child-owned blind parser dispatch.
Explicit spelling wins over the parent-family default:

- explicit `->` remains legal in AND-family rules;
- explicit `=>` remains legal in OR/default-family rules;
- `-> Child[N]` remains the only indexed blind/action-disambiguating form in every family;
- `=> Child[N]` remains invalid, including `[0]`;
- `-> A | B { ... }` remains valid in every family and the shared block remains mandatory;
- grouped blind calls do not exist, so bare `A | B { ... }` is valid only in OR/default-family rules;
- fluent suffixes and attached blocks retain the existing semantics of the resolved edge kind.

After bare normalization, a rule still may not mix action and blind ownership. For example, an AND rule containing
a bare `Child` (resolved blind) and an explicit `-> Other` is invalid. Authors who intentionally use action edges
inside an AND rule spell every edge with `->`; authors who intentionally use blind calls inside an OR rule spell
every edge with `=>`.

Action edges continue to let the parent select a target regex slot and expose that match/capture state to the edge
action. Blind calls continue to invoke the child parser without parent preselection. A block or fluent suffix runs
after the selected child result is available through the existing child-result channel. The parent rule family
controls sequence/choice/repetition orchestration; neither edge marker changes the child's family.

### 4. Public override migration is removal, not ignore-and-continue

The public `parse_mode` / `parseMode` constructor and execution option is removed from all five native APIs,
loaded-spec factories, corpus adapters, emitters, and generated roles. A dynamic options boundary that receives the
legacy key fails before parsing input or evaluating user code with portable code `parse_mode_override_removed`,
stage `prepare_options`, and field `option_name = "parse_mode"`. Statically typed methods such as Rust
`ExecutionOptions::with_parse_mode` are deleted.

Primary commands omit `--parse-mode` from help. They continue to recognize it only far enough to return usage exit
2 and the targeted message: `--parse-mode has been removed; cursor policy is derived from each rule
(OR/default=seek, AND=consume)`. The flag is never accepted and ignored.

Tests and specs that used global consume or seek must migrate to authored families and composition. A compatibility
shim, environment variable, hidden CLI flag, or per-rule cursor suffix would recreate the rejected ambiguity and
is not permitted by this decision.

### 5. Descriptors expose derived rule facts

The descriptor-wide `meta.parse_mode` field is removed. Each rule exposes
`spec.<label>.meta.cursor_policy = "seek" | "consume"`, derived only from its authored family, and descriptor
metadata exposes `meta.cursor_contract = "linkedspec-rule-local-cursor-v1"`. No descriptor input may override the
derived value. Public descriptor projections do not expose a field named `parse_mode` after migration.

Bare edges appear only as their resolved action/blind kind in compiled descriptor state. Source-aware
introspection may additionally retain a non-semantic `source_form = "bare" | "explicit"`, but dispatch and parity
must never depend on that provenance field.

### 6. Generated source moves to version 2 and derives policy from family

New generated artifacts identify `linkedspec-generated-source-v2` / format version 2. Their ordered plan rows
remain the minimal `{label, family}` shape; cursor policy is deliberately not serialized as an independent mutable
field. It is derived by the validator/runtime from the ten admitted families:

- seek: `default`, `or_acode`, `or_bcode`, `rep_acode`, `rep_bcode`;
- consume: `and_single_acode`, `and_acode_seq`, `and_bcode`, `rep_and_acode`, `rep_and_bcode`.

The generated plan validator keeps exact row/label/family checks and rejects a v1 plan at a v2 reconstruction
boundary with `generated_source_contract_version_mismatch`. Newly emitted source contains no global parse-mode
constructor or metadata. Existing self-contained v1 artifacts cannot be retroactively changed; they are legacy
artifacts outside v2 admission and must be regenerated from their `.spec` source.

### 7. Diagnostics and conformance are portable

The neutral contract must lock at least these diagnostic codes before backend rollout:

- `parse_mode_override_removed` for legacy API/engine/emitter options;
- `bare_edge_target_undefined` for a non-reserved bare identifier that is not a rule;
- `bare_edge_index_requires_action` for indexed bare syntax in an AND-family rule;
- `bare_edge_group_requires_action` for grouped bare syntax in an AND-family rule;
- `mixed_edge_ownership` after bare-edge normalization;
- the existing grouped-action shared-block and blind-index failures for explicit forms;
- `generated_source_contract_version_mismatch` at v1/v2 reconstruction boundaries.

Conformance covers every rule-family spelling, default-AND leading junk, default-OR forward seeking, both structural
cross-combinations, mixed parent/child families across every call mechanism, bare/explicit equivalence, indexed,
grouped, fluent, block, reserved-name, mixed-ownership, API/CLI retirement, descriptor shape, generated-v2 family
derivation, trace attribution, both Lua ABIs, and native/reconstructed/generated/primary projections.

## Implementation and admission

Implementation completed in dependency order under `FUTURE-PARITY-BACKLOG.9.1.2-.9`: neutral executable contract
and migration inventory; Perl reference; Rust; Dart; Julia; Lua/LuaJIT; symmetric five-backend/generated/CLI
admission; recurring proof; then public no-drift. The executable ledger is 75 migration files,
8 complete / 0 pending, and 60 rejected drift mutations. The recurring driver is
`tools/check_rule_local_cursor_five_backend.sh`; explicit repeated-OR action-result shape remains separately owned
by `.9.1.10`, so semantic parents remain active until that child is resolved.

## Consequences

- The same `.spec` has one cursor meaning regardless of caller or nesting context.
- Bare edge syntax becomes concise without erasing the explicit ownership markers needed for exceptions.
- Cross-family explicit edges retain current expressive power, while mixed ownership remains a clear structural
  error.
- Descriptor and generated contracts can prove cursor policy without carrying a contradictory override.
- Removing the global option is intentionally breaking. Targeted diagnostics and structural migration recipes are
  preferred over indefinite compatibility that preserves semantic drift.
- Generated-source version 2 is required because changing cursor authority while retaining the v1 identity would
  misrepresent old artifacts as current.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.9.1.1.1`, follow-ons `.9.1.2-.9`)
- Audit: `docs/knowledge/and-or-cursor-ownership-audit.md`
- Parent/child decision: `docs/knowledge/rule-local-cursor-ownership-decision.md`
- Existing explicit edge contract: `docs/knowledge/spec-edge-syntax-contract.md`
- Top-rule boundary: ADR `0010`

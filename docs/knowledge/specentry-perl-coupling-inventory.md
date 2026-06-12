---
id: specentry-perl-coupling-inventory
title: SpecEntry.pm Perl coupling inventory — every eval site, generated-code pattern, and LinkedRE dependency across 10 handler-variant builders
answers:
  - what Perl coupling points exist in SpecEntry.pm
  - how are handler variants built in SpecEntry
  - what does SpecEntry eval
  - how does SpecEntry depend on LinkedRE::or
  - what Perl variables are assumed by generated handlers
  - how many handler variant builders are in SpecEntry
date: 2026-06-12
status: current
evidence: |
  Full read of perl/LinkedSpec/SpecEntry.pm (918 lines). 10 variant builders
  dispatched from _build_handler_variants, each generating Perl source strings
  that are eval'd by _build_runtime_handler.
reverify: |
  wc -l perl/LinkedSpec/SpecEntry.pm && grep -c 'sub _build_.*_variant\|sub _build_.*_body' perl/LinkedSpec/SpecEntry.pm
source: docs/knowledge/specentry-perl-coupling-inventory.md
---

# SpecEntry.pm — Perl Coupling Inventory

**Module**: `perl/LinkedSpec/SpecEntry.pm` (918 lines)
**Role**: Compile parsed rule entries into runtime handler coderefs via Perl source generation + `eval`.

## 1. Architecture Overview

SpecEntry is the **strongest backend-portability ceiling** in LinkedSpec. Every handler is
compiled by:
1. Building a Perl source string from a template
2. Wrapping it in `sub { ... }` with a `#line` directive
3. `eval`-ing the string to produce a coderef
4. Wrapping the coderef in a runtime handler that traps errors

## 2. The eval Site (Primary Perl Coupling)

**Location**: `_build_runtime_handler` (line 726–816)

```perl
my $handler_source = qq{#line 1 "$handler_source_directive_label"\nsub {\n$handler\n}};
$compiled_handler = eval $handler_source;
```

This is the **single point** where Perl source becomes executable code. All generated handler
code flows through this `eval`. To eliminate string-based generation:
- Replace `$handler` (string) with a data structure (HandlerIR)
- Replace `eval` with an interpreter or closure-based composition

### Runtime Wrapper (line 752–815)

The eval'd coderef is wrapped in a closure that:
- Traces entry/exit via `LinkedSpec::Trace`
- Catches compile errors (`$compile_error`) and execution errors (`$eval_error`)
- Reports structured errors through `LinkedSpec::RuntimeContext`
- Returns `undef` on failure, `$retv` on success

## 3. Generated-Code Patterns (All 10 Handler Variants)

Each variant builder generates Perl source strings with these **Perl-specific assumptions**:

### 3.1 Common Variables (all variants)

| Variable | Purpose | Perl coupling |
|----------|---------|---------------|
| `$descr` | Descriptor hashref | `$$descr{dependency_regex_map}{$label}` — nested deref |
| `$STRING` | Input scalar ref | `pos $$STRING`, `$$info{...}` — passed by caller |
| `$info` | Match info hashref | `$$info{match}`, `$$info{match_list}`, `$$info{index}` |
| `$LMATCH` | Last match text | `$$minfo{match}` — regex match result |
| `@LMATCH_LIST` | Match capture groups | `@{$$minfo{match_list}}` — Perl array deref |
| `@{$label}_collect` | Result collection array | `my @rule_collect` — Perl native array |
| `$$minfo{index}` | Which regex alternative matched | Integer comparison for dispatch |

### 3.2 AND_SINGLE_ACODE (line 237–272)

```perl
my @{$label}_collect;
my $minfo = LinkedRE::or($STRING, $$descr{dependency_regex_map}{$label}, $info);
unless($minfo) { return undef }
unless($$minfo{index} == 0) { return undef }  # HARDCODED index check
```

**Coupling**: Hardcoded `index == 0` check. Only processes the first regex alternative.
Rejects child-rule dependency matches at other indices. This is the root cause of
the MEDIUM-IMPACT.3.4 blocker.

### 3.3 AND_ACODE (line 274–317)

Sequential index matching loop: `while ($idx < $acode_count)`. Matches regexes in order
(`$$minfo{index} == $idx`). No E-block support.

### 3.4 AND_BCODE (line 203–230)

```perl
my $label;                          # Return value of each child call
my @{$label}_collect;
foreach my $call (qw($bcalls)) {    # Edge names
    bcodes                           # Per-call body code dispatch
    unless ($label) { return undef } # Child call failed
    push @{$label}_collect, $label   # DEFAULT LE: collect result
}
return \@{$label}_collect            # DEFAULT E: return collected
```

**Supports**: LE and E lifecycle blocks. **Never used** by shipped specs (0 rules have both
AND node type and bcode_count > 0).

### 3.5 REP_ACODE (line 545–598)

```perl
while(1) {
    my $minfo = LinkedRE::or(...);
    unless($minfo) { if ($ccount >= $min) { return \@collect } else { return undef } }
    # extract match groups
    acodes                           # Dispatched by $$minfo{index}
    ++$ccount;
    push @{$label}_collect, $label   # DEFAULT IT: collect result (return→assignment transform)
    last unless $ccount < $max
}
```

**Key fix** (line 620–622): `return` → `$label =` transformation prevents REP loop from
exiting on first match. This is the pattern that should be adapted for AND handlers.

### 3.6 REP_AND_ACODE (line 496–543)

Wraps AND_ACODE in a repeat loop with min/max bounds. Used by `spec_file::AND+`.

### 3.7 REP_AND_BCODE (line 440–494)

Wraps AND_BCODE in a repeat loop. Supports I/LS/LE/LX/E/EX/IT lifecycle blocks.

### 3.8 REP_BCODE (line 378–438)

Wraps OR_BCODE in a repeat loop. Includes **zero-progress guard**: `$loop_end_pos == $loop_start_pos`.

### 3.9 OR_ACODE (line 349–371)

Single match, no index check, no loop. Returns match info from acode (no collection array).

### 3.10 OR_BCODE (line 324–347)

First-match-wins loop over bcalls. Returns on first successful child match.

## 4. LinkedRE::or Dependency

**Location**: `_linkedre_or_expr` (line 120–129)

Every variant uses `LinkedRE::or($STRING, $$descr{dependency_regex_map}{$label}, ...)` to
match against the dependency regex. This is the **sole mechanism** for calling child rules
via regex matching.

Two modes:
- `seek`: ungrounded match (`//gcp`, matches anywhere in `$$STRING`)
- `consume`: `\G`-anchored match (contiguous from `pos($$STRING)`)

The `$$descr{dependency_regex_map}{$label}` lookup ties generated code to the descriptor
structure — handlers depend on the descriptor hashref being available at runtime.

## 5. Handler Variant Dispatch

**Location**: `_build_handler_variants` (line 600–715) and `_select_handler_variant` (line 717–724)

The variant is selected by `RuleIR::_select_rule_handler_variant` based on:
- `node_type` (AND, OR, REP, REP_AND)
- `acode_count` (per-regex action code)
- `bcode_count` (per-edge body code)
- `regex_count`

**Coupling**: The variant selection logic is **duplicated** between RuleIR (line 26–49) and
SpecEntry (line 600–715). RuleIR sets `handler_variant` in metadata; SpecEntry builds the
corresponding variant. If a new variant is added, both files must be updated.

**MIXED_ACTIONS constraint**: If both `acode_count` and `bcode_count` are > 0, RuleIR returns
`MIXED_ACTIONS` (error state). This prevents AND rules from having both per-regex I-blocks
and per-edge body code — the exact pattern needed for MEDIUM-IMPACT.3.4.

## 6. Perl Variable Assumptions in Generated Code

### 6.1 Descriptor structure (`$descr`)

```perl
$$descr{spec}{RuleName}{handler}    # Handler coderefs for each rule
$$descr{dependency_regex_map}{...}  # Compiled dependency regexes
```

### 6.2 Match info structure (`$info`, `$minfo`)

```perl
$$info{match}       # Full match text
$$info{match_list}  # Capture groups (ARRAY ref)
$$info{match_hash}  # Named captures (HASH ref)
$$info{index}       # Which alternative matched
$$info{marks}       # Named position markers
```

### 6.3 String reference (`$STRING`)

```perl
pos $$STRING        # Current parse position
$$STRING            # The input text
```

### 6.4 Collection variables

Each variant declares `my @{$label}_collect` or uses `$label` as the current return value.
The preamble declares `my @{$label}` which is **separate** from the body's `@{$label}_collect`.

## 7. Preamble vs Body Disconnect

**Location**: `_build_handler_preamble` (line 131–145)

The preamble declares `my @{$label}` and inserts the ICODE (per-regex initialization).
The handler body (variant) declares `my @{$label}_collect` — a **different array**.

For AND rules, the ICODE runs in the preamble and `return()` exits the entire handler sub
before the body runs. REP rules avoid this by routing per-regex code to `acode_entries`
instead of ICODE (see RuleIR.pm line 207).

## 8. Lifecycle Block Support by Variant

| Variant | I | LS | LE | LX | E | EX | IT | Loop |
|---------|---|---|----|----|---|---|----|------|
| AND_SINGLE_ACODE | preamble | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| AND_ACODE | preamble | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | seq |
| AND_BCODE | ✗ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ | edges |
| OR_ACODE | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| OR_BCODE | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | ✗ | edges |
| REP_ACODE | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | while |
| REP_AND_ACODE | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | while |
| REP_AND_BCODE | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | while |
| REP_BCODE | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ | while |

**Key gap**: AND_SINGLE_ACODE and AND_ACODE lack E-block support, preventing post-edge
result assembly. Adding E-block to AND_SINGLE_ACODE would fix MEDIUM-IMPACT.3.4.

## 9. External Dependencies

| Dependency | Via | Purpose |
|------------|-----|---------|
| `LinkedRE::or` | Direct call in generated code | Regex matching for dependency dispatch |
| `LinkedSpec::Trace` | OwnerDispatch | Trace entry/exit/decision/log |
| `LinkedSpec::RuntimeContext` | OwnerDispatch | Structured error reporting, parser-source capture |
| `LinkedSpec::RuleIR` | OwnerDispatch | Rule IR collection, planning, validation |
| `LinkedSpec::RuleIR::EmitContext` | OwnerDispatch | ActionIR lowering, acode/bcode construction |
| `LinkedSpec::OwnerDispatch` | Direct use | Lazy loading, callback resolution, $@ preservation |
| `Data::Dumper` | OwnerDispatch (lazy) | Debug dump of IR structures |

## 10. Decoupling Path (toward HandlerIR)

1. **Replace `$handler` source string** with a HandlerIR data structure
2. **Replace `eval`** with a HandlerIR interpreter or closure composer
3. **Eliminate `$descr` assumptions** — pass structured data instead of hashref derefs
4. **Eliminate `LinkedRE::or` dependency** — abstract regex dispatch behind an interface
5. **Unify `@{$label}` and `@{$label}_collect`** — single collection mechanism
6. **Add E-block to all variants** that lack it (AND_SINGLE_ACODE, AND_ACODE, OR_ACODE)

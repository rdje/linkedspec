# Language-Neutral Test Corpus

This directory contains test entries every LinkedSpec backend must validate against.
Each entry is a directory with:

- `input.spec` — the `.spec` grammar file (identical across all backends)
- `input.txt` — the text to parse
- `expected.json` — the canonical expected parse result as JSON
- `README.md` — what this test covers and why

## Format

### input.spec

A standard LinkedSpec `.spec` file. Same format every backend reads natively.

### input.txt

Plain text — the exact string passed to the generated parser.

### expected.json

A JSON document with this schema:

```json
{
  "_meta": {
    "spec_file": "input.spec",
    "description": "What this test verifies",
    "top_rule": "Main",
    "backend_version": "1.0.0"
  },
  "result": {
    // The canonical parse result — structure is .spec-defined.
    // Arrays represent ordered children. Objects represent named results.
    // Strings are leaf values. null represents undef/absent.
  }
}
```

**Conventions:**
- Result keys that start with `?` are rule tags added by the `.spec` (e.g., `"?result:"`).
- Result keys without `?` are data keys from hash returns.
- Arrays preserve child order.
- `null` means the value was undef or absent.

## Backend Compliance

A backend is compliant when, for every entry in this corpus:

1. It compiles `input.spec` without error.
2. It parses `input.txt` and produces a result structurally equivalent to `expected.json`.
3. Structural equivalence means:
   - Same keys (order-independent for objects).
   - Same values (strings, numbers, booleans, null match exactly).
   - Same array lengths and element order.
   - Extra keys in the actual result that are not in `expected.json` are acceptable
     (backends may add metadata).
   - Missing keys from `expected.json` in the actual result are **not** acceptable.

## Adding Tests

1. Create a directory: `tests/corpus/<test_name>/`
2. Add `input.spec`, `input.txt`, and `expected.json`.
3. Add a `README.md` explaining the test.
4. Generate `expected.json` from the Perl reference backend:
   ```bash
   perl -MLinkedSpec -e '
     my $parser = LinkedSpec::Get(\"spec content here");
     # ... parse input, serialize result as JSON
   '
   ```
5. Verify the test passes on all backends.

## Current Coverage

| Test | Spec | What it covers |
|---|---|---|
| `lispish` | Lispish grammar | Recursive nested constructs, parentheses matching, basic AST |
| `simple_grammar` | Minimal two-rule spec | Rule labels, action edges, lifecycle blocks, regex anchors |
| `tablegrep` | TableGrep grammar | Action edges, capture groups, LS/LE lifecycle, accumulator |

## Roadmap

- Seed with representative specs (Phase 8.6).
- Expand to cover all 12 body element patterns.
- Add error-path entries (invalid input, malformed spec).
- Add lifecycle-specific entries (all 7 markers).
- Add edge-case entries (deep nesting, fluent chains, switch/if cross-nesting).

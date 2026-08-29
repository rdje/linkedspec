# Inspecting `.spec` Code Generation

Use `tools/inspect_spec_codegen.pl` when you need to see how a small `.spec` fragment is normalized and lowered
without hand-reading emitter code. The inspector accepts four authoring categories:

1. raw helper or expression;
2. lifecycle block;
3. lifecycle chain; and
4. action-edge block or chain.

## One snippet

```bash
perl tools/inspect_spec_codegen.pl --label Top --snippet 'return(copy(items))'
```

The report contains the parsed kind and label, original snippet, normalized helper code, generated Perl, canonical
IR nodes, raw-Perl fallback count, and unresolved-helper count. For the example above, the canonical node is
`RETURN`; a fully portable lowering reports both counts as zero.

## Compare blocks and chains

Repeat `--snippet` to inspect several forms in one deterministic report:

```bash
perl tools/inspect_spec_codegen.pl --label Top \
  --snippet 'I { x = 1; return(x) }' \
  --snippet 'I.lowercase_each(parts).filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)' \
  --snippet '/a/ -> Top .lowercase_each(parts).filter_match(uniq(uppercase_each(parts)), /^[A-Z_]+$/)' \
  --snippet '/a/ -> Top { return(retv) }'
```

The lifecycle block lowers to assignment plus return. Both chain forms normalize their fluent calls with `Top` as
the injected rule label and produce the same canonical array-transform nodes. The action-edge block lowers to a
plain `RETURN`. This makes semantic twins easy to compare without compiling an entire fixture.

For a reusable list, place one snippet on each nonblank line and use `--snippet-file`. Lines whose trimmed form
starts with `#` are ignored:

```bash
perl tools/inspect_spec_codegen.pl --label Top --snippet-file examples/inspection-snippets.txt
```

## Ownership and regression safety

Fluent-chain parsing/rendering belongs to `LinkedSpec::BootstrapSpec::Core`. ActionIR lowering and canonical
diagnostics belong to `LinkedSpec::RuleIR::EmitContext`. The inspector calls those internal owners explicitly; the
public `LinkedSpec` facade is intentionally not a codegen-inspection API.

That distinction matters because the Phase 1A facade extraction removed obsolete private forwarding methods.
Calling the removed names through the facade falls into plugin AUTOLOAD and misreports them as unknown plugins.
The recurring `t/inspect_spec_codegen.t` test locks the explicit owner call sites and executes raw helper,
lifecycle block, lifecycle chain, action-edge block, and action-edge chain cases in canonical CI.

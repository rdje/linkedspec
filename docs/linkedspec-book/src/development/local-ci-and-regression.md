# Local CI and Regression

LinkedSpec relies heavily on a strong regression gate.

## Main local gate

Run:

```bash
bash tools/run_ci_local.sh
```

This keeps local validation aligned with the GitHub CI gate.

## Why the regression discipline is important

This project is changing internals aggressively:

- naming cleanup
- compiler-state refactors
- diagnostics tightening
- helper-surface evolution

The regression suite is what makes that sustainable.

## Important test surface

The main regression spine is:

```text
t/phase0_regression.t
```

That file is large because it is doing real work: protecting runtime behavior, compiler contracts, shipped specs, and migration slices.

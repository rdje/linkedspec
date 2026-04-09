# Shipped Specs and Corpora

The repository ships real specs and real corpora, not only toy examples.

## Why that matters

This gives LinkedSpec a stronger quality loop:

- compile real shipped specs
- run regression checks across representative inputs
- keep behavior grounded in actual usage

## Important repo areas

- `specs/`
- `t/phase0_regression.t`
- `plugin/`
- `conf/`
- `tablescript/`
- `ebnf/`

The goal is for the book to eventually walk through the important shipped specs and explain what each one demonstrates about the system.

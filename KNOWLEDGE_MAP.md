# Knowledge Map

> **AUTO-GENERATED — DO NOT EDIT.** Regenerate with `knowledge-map/scripts/gen_knowledge_map.sh`.
> Source of truth = YAML front-matter in: `docs/knowledge docs/decisions`. Edit the fact files, never this map.
> A fact is any `.md` whose front-matter has a non-empty `answers:` list.
> **6** facts · **29** question keys.

## Questions → fact

- "can a spec introduce a compatibility-surface rule" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "does perl/LinkedSpec/ActionRewriter.pm still exist" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "how do I run CI / the regression gate" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "how does LinkedSpec.pm dispatch into owner modules" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "how should .spec language changes land" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "is ActionRewriter a live module in linkedspec" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "is GitHub Actions CI running for linkedspec" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "is LinkedSpec.pm the implementation center" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "is it safe to use LX on a repeated (AND+) rule" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "is there a self-hosted .spec grammar" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "parser infinite loop with Late Exit lifecycle marker" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "what does green CI mean here" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "what does the phase0 regression gate enforce about specs" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what is language_agnostic_ready_ratio and what value is required" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "what is specs/spec.spec" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "what is the AND++LX hang" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "what is the practical compile/runtime spine" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "what must every shipped .spec satisfy" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "where did LinkedSpec::ActionRewriter go" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where did call_spec_handler_subst / rewrite_action_code_for_compat move" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "where does the memory-arch and knowledge-map check run" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "where does the real implementation live in linkedspec" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- "where is the LinkedSpec language defined in LinkedSpec itself" -> [spec-spec-self-hosted-grammar](docs/knowledge/spec-spec-self-hosted-grammar.md) · 2026-06-05 · reverify: `ls specs/spec.spec`
- "where is the helper-rewrite compatibility entrypoint now" -> [actionrewriter-removed-phase1](docs/knowledge/actionrewriter-removed-phase1.md) · 2026-06-05 · reverify: `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- "why did phase0 fail on my new spec" -> [phase0-all-target-actionir-ready-invariant](docs/knowledge/phase0-all-target-actionir-ready-invariant.md) · 2026-06-05 · reverify: `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- "why did spec.spec hang while parsing" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "why does the generated parser hang on an AND+ rule with LX" -> [andplusplus-lx-parser-hang](docs/knowledge/andplusplus-lx-parser-hang.md) · 2026-06-05 · reverify: `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- "why is .github/workflows/ci.yml guarded off (workflow_dispatch / if false)" -> [hosted-ci-disabled-run-local-gate](docs/knowledge/hosted-ci-disabled-run-local-gate.md) · 2026-06-05 · reverify: `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- "why is LinkedSpec.pm so small" -> [linkedspec-pm-is-thin-facade](docs/knowledge/linkedspec-pm-is-thin-facade.md) · 2026-06-05 · reverify: `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`

## Facts (by id)

### actionrewriter-removed-phase1
_ActionRewriter.pm was deleted in Phase 1; the helper-rewrite compat entrypoint is now in RuleIR::EmitContext_

- **answers:** does perl/LinkedSpec/ActionRewriter.pm still exist | where did LinkedSpec::ActionRewriter go | where is the helper-rewrite compatibility entrypoint now | where did call_spec_handler_subst / rewrite_action_code_for_compat move | is ActionRewriter a live module in linkedspec
- **date:** 2026-06-05 · **status:** current
- **evidence:** `commit 4f8e0b6 (PHASE1-PARSER-CORE-ISOLATION.2) deleted the 118-line forwarding shim; zero references remain under perl/`
- **reverify:** `! test -f perl/LinkedSpec/ActionRewriter.pm && grep -q rewrite_action_code_for_compat perl/LinkedSpec/RuleIR/EmitContext.pm`
- **source:** [`docs/knowledge/actionrewriter-removed-phase1.md`](docs/knowledge/actionrewriter-removed-phase1.md)

### andplusplus-lx-parser-hang
_GOTCHA — an LX lifecycle marker on an AND+ rule hangs the generated parser (loop re-entry)_

- **answers:** why does the generated parser hang on an AND+ rule with LX | why did spec.spec hang while parsing | what is the AND++LX hang | is it safe to use LX on a repeated (AND+) rule | parser infinite loop with Late Exit lifecycle marker
- **date:** 2026-06-05 · **status:** current
- **evidence:** `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (PHASE7-SELF-HOSTED-SPEC.4): spec_file::AND+ with LX hung; fixed by replacing LX with E`
- **reverify:** `grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`
- **source:** [`docs/knowledge/andplusplus-lx-parser-hang.md`](docs/knowledge/andplusplus-lx-parser-hang.md)

### hosted-ci-disabled-run-local-gate
_Hosted GitHub Actions CI is disabled; run the local gate tools/run_ci_local.sh_

- **answers:** is GitHub Actions CI running for linkedspec | how do I run CI / the regression gate | why is .github/workflows/ci.yml guarded off (workflow_dispatch / if false) | what does green CI mean here | where does the memory-arch and knowledge-map check run
- **date:** 2026-06-05 · **status:** current
- **evidence:** `.github/workflows/ci.yml uses workflow_dispatch + job if: false; docs/decisions/0004-hosted-ci-disabled-local-gate.md`
- **reverify:** `grep -n 'workflow_dispatch' .github/workflows/ci.yml`
- **source:** [`docs/knowledge/hosted-ci-disabled-run-local-gate.md`](docs/knowledge/hosted-ci-disabled-run-local-gate.md)

### linkedspec-pm-is-thin-facade
_LinkedSpec.pm is a thin lazy façade; the real compile spine is ParserFactory -> Runtime -> Compiler_

- **answers:** where does the real implementation live in linkedspec | is LinkedSpec.pm the implementation center | what is the practical compile/runtime spine | how does LinkedSpec.pm dispatch into owner modules | why is LinkedSpec.pm so small
- **date:** 2026-06-05 · **status:** current
- **evidence:** `perl/LinkedSpec.pm is ~258 lines; static imports are essentially File::Basename + LinkedSpec::OwnerDispatch`
- **reverify:** `wc -l perl/LinkedSpec.pm; test -f perl/LinkedSpec/OwnerDispatch.pm`
- **source:** [`docs/knowledge/linkedspec-pm-is-thin-facade.md`](docs/knowledge/linkedspec-pm-is-thin-facade.md)

### phase0-all-target-actionir-ready-invariant
_Every shipped .spec must compile ActionIR-ready (ratio == 1.0000, zero compatibility-surface rules)_

- **answers:** what must every shipped .spec satisfy | what does the phase0 regression gate enforce about specs | what is language_agnostic_ready_ratio and what value is required | can a spec introduce a compatibility-surface rule | why did phase0 fail on my new spec
- **date:** 2026-06-05 · **status:** current
- **evidence:** `docs/decisions/0002-all-target-actionir-ready-invariant.md; t/phase0_regression.t asserts language_agnostic_ready_ratio == 1.0000 with zero blocked / compatibility-surface rules`
- **reverify:** `grep -n language_agnostic_ready_ratio t/phase0_regression.t`
- **source:** [`docs/knowledge/phase0-all-target-actionir-ready-invariant.md`](docs/knowledge/phase0-all-target-actionir-ready-invariant.md)

### spec-spec-self-hosted-grammar
_specs/spec.spec is the self-hosted .spec grammar and the preferred surface for .spec evolution_

- **answers:** is there a self-hosted .spec grammar | what is specs/spec.spec | how should .spec language changes land | where is the LinkedSpec language defined in LinkedSpec itself
- **date:** 2026-06-05 · **status:** current
- **evidence:** `specs/spec.spec exists and compiles at language_agnostic_ready_ratio == 1.0000; docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (5 leaves, done)`
- **reverify:** `ls specs/spec.spec`
- **source:** [`docs/knowledge/spec-spec-self-hosted-grammar.md`](docs/knowledge/spec-spec-self-hosted-grammar.md)

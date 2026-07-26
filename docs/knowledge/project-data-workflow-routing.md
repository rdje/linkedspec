---
id: project-data-workflow-routing
title: Standard workflows self-initialize repository-filesystem project data
answers:
  - which LinkedSpec workflows source the project data initializer automatically
  - does the pre commit hook initialize repository local storage
  - do doctrine checks initialize repository local storage
  - does canonical local CI initialize repository local storage
  - do Rust Dart Julia and Lua local gates initialize repository local storage
  - how should I build the mdBook with repository local storage
  - can standard workflows run outside the repository cwd with hostile temp variables
  - how is standard workflow storage routing tested
  - do standard LinkedSpec workflows use managed per run scratch
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, workflow, hook, ci, mdbook, backend, portability, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.1.2 initially routes tools/project_data_env.sh at 14 self-rooted boundaries. PROJECT-DATA-SSD-ROOTING.2.1 adds the primary matrix and Perl storage oracle; .2.2 adds the targeted Cargo wrapper and Rust storage oracle; .2.3 adds the Dart storage oracle; .2.4 adds the targeted Julia wrapper, Julia storage oracle, primary checker, and eight Julia-consuming cross-backend checkers, bringing recurring proof to 30 boundaries. The portable Knowledge Map bundle consumes generic KM_ENV_INITIALIZER and KM_RUN_INITIALIZER configured in root .knowledge_map.conf. tools/test_project_data_workflow_routing.sh rejects missing/late initialization, launches lightweight workflows and backend preflights from another filesystem with hostile inherited roots, proves all selected directories use the repository device, and requires no completed-run residue."
reverify: "bash -n tools/test_project_data_workflow_routing.sh && bash tools/test_project_data_workflow_routing.sh && bash tools/run_mdbook_local.sh && bash scripts/check_doctrines.sh"
---

The standard storage-routing boundary consists of `.githooks/pre-commit`, the doctrine driver and registered checks,
both Knowledge Map scripts, `tools/run_ci_local.sh` (the canonical Perl/reference gate),
`tools/run_{rust,dart,julia,lua}_local.sh`, `tools/run_primary_cli_matrix.sh`, `tools/run_cargo_local.sh`,
`tools/run_julia_project_data.sh`, the four backend storage oracles, the Julia primary checker, the eight
Julia-consuming cross-backend checkers, and `tools/run_mdbook_local.sh`. Each derives its current checkout and
routes `tools/project_data_env.sh` and enters one managed run before any language runtime or project-data allocator
can start. The portable Knowledge Map scripts use generic `KM_ENV_INITIALIZER` plus `KM_RUN_INITIALIZER`;
LinkedSpec's root `.knowledge_map.conf` supplies the repo-relative helper and its run function without coupling the
bundle to this project. The mdBook's
supported command is therefore `bash tools/run_mdbook_local.sh`, not a bare `mdbook build`.

The focused workflow oracle checks 30 source-before-runtime boundaries. From an available other-filesystem cwd, it
supplies hostile external temp/cache variables and a unique same-filesystem project-data root, executes the
lightweight doctrine/Knowledge Map/mdBook flows, and reaches each backend runner's post-initialization preflight.
Every created scratch/cache/tool directory is checked against the repository device, backend preflights must reach
their configured runtime check, and every completed managed run must be gone. Direct low-level commands remain
responsible for explicitly sourcing the initializer; `.2.1-.2.6` still own backend/tool default and old-data migration.

Related facts: [[project-data-env-initializer]], [[project-data-run-lifecycle]],
[[project-data-ssd-storage-locality]], [[rust-project-data-ssd-storage]], [[dart-project-data-ssd-storage]],
[[julia-project-data-ssd-storage]].

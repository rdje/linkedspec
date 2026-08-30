---
id: tool-project-data-ssd-storage
title: Python, Knowledge Map, mdBook, and tool output stay on the repository filesystem
answers:
  - how should a LinkedSpec Python checker be run
  - where does LinkedSpec store Python bytecode
  - where do Unicode contract checkers create temporary files
  - can KM_OUTPUT point to another filesystem
  - how does Knowledge Map validate generated output
  - can mdBook output be written to another volume
  - how are mdBook destination overrides validated
  - do relative mdBook destination overrides validate and execute from the same base
  - why can a validated relative mdBook destination resolve outside the repository
  - which oracle proves tool project data stays on the SSD
  - how many Python temporary allocation owners exist
  - how many shell temporary allocation owners exist
  - how many Python checker entrypoints exist
  - where do TAP and oracle capture artifacts go
  - what old tool data was deleted from private tmp
date: 2026-08-17
status: current
tags: [storage, ssd, python, bytecode, knowledge-map, mdbook, tap, oracle, temporary-data, portability]
evidence: "PROJECT-DATA-SSD-ROOTING.2.6 adds tools/run_python_project_data.sh and tools/test_tool_project_data_storage.sh; exports retained PYTHONPYCACHEPREFIX from tools/project_data_env.sh; gives both Unicode generators explicit validated scratch; configures generic KM_OUTPUT_VALIDATOR in .knowledge_map.conf; validates Knowledge Map output before/after generation and mdBook output before/after build; routes canonical/current checker commands; and deletes the exact unreferenced 88-line /private/tmp/linkedspec-julia-reverify-cards.txt after classification. MDBOOK-DESTINATION-ROOT-ALIGNMENT.1 runs mdBook from BOOK_ROOT as build ., and its argument-aware fake proves split, equals, compact, environment, and absolute destinations plus pre-launch hostile/symlink rejection. Real default and relative builds each produce 79 files / 14,120 KiB on the repository volume."
evidence_update_2026_08_17: "FUTURE-PARITY-BACKLOG.14.6.1 adds the repository-routed progressive span-dispatch checker. Canonical tool-storage proof freezes the resulting 31 Python tool entrypoints together with the unchanged three Python temporary owners and 14 shell allocator owners."
evidence_update_2026_08_25: "FUTURE-PARITY-BACKLOG.14.7.2 adds the repository-routed staged-AST enrichment checker. Canonical tool-storage proof freezes the resulting 32 Python tool entrypoints together with the unchanged three Python temporary owners and 14 shell allocator owners."
evidence_update_2026_08_29: "FUTURE-PARITY-BACKLOG.15.2 adds the repository-routed standalone lifecycle-block checker and five-backend driver. Canonical attempt five catches the deliberately stale entrypoint census; focused proof then catches the new driver's managed mktemp owner. The Python checker owns no temporary allocator, while the shell driver is enrolled in the project-data routing oracle and allocates/removes its backend fixture workspace beneath validated repository-local TMPDIR. The storage oracle freezes 33 Python tool entrypoints, the unchanged three Python temporary owners, and 15 shell allocator owners."
evidence_update_2026_08_29_task_index_markers: "FUTURE-PARITY-BACKLOG.22 adds tools/check_task_tree_closed_capability_markers.py through the repository-routed Python wrapper and existing TASK-TREE-METADATA doctrine. The checker allocates no temporary workspace. The storage oracle therefore advances only the Python tool-entrypoint census from 33 to 34; Python temporary owners remain three and shell allocator owners remain 15."
evidence_update_2026_08_29_memory_handoff: "FUTURE-PARITY-BACKLOG.22.1 adds tools/check_memory_handoff_state.py through the same repository-routed wrapper and existing MEMORY-ARCH doctrine. Its mutation proof is in-memory and allocates no temporary workspace. The storage oracle therefore advances only the Python tool-entrypoint census from 34 to 35; Python temporary owners remain three and shell allocator owners remain 15."
reverify: "bash tools/test_tool_project_data_storage.sh; bash knowledge-map/scripts/check_knowledge_map.sh; bash tools/run_mdbook_local.sh"
---

# Tool project data on repository storage

Use `bash tools/run_python_project_data.sh tools/<checker>.py [args...]` for a maintained Python checker. The
wrapper accepts a repository-root-relative nonsymlink script, enters managed scratch, and retains imported bytecode
under `/.linkedspec-data/cache/python-pycache/`. The two Python checkers that regenerate Unicode artifacts also
select an explicit same-device temporary root, including when invoked directly.

LinkedSpec configures the portable Knowledge Map bundle's optional `KM_OUTPUT_VALIDATOR` through the repo-relative
environment initializer. Generation validates before creating output and after writing it; checking validates the
configured committed map before use. The mdBook wrapper validates default, environment, and CLI destinations from
the book root, rejects another-filesystem or symlink output before launch, then executes `mdbook build .` from that
same root and verifies created output. Relative split, equals, and compact CLI forms therefore execute the exact
path that validation approved, independently of the caller's current working directory.

`tools/test_tool_project_data_storage.sh` freezes three Python temporary owners, 15 actual shell allocator owners,
and 35 Python checker entrypoints. It proves real bytecode, map, HTML, CLI workspace, TAP, and oracle capture paths
use the repository device and hostile external destinations remain absent. Its deliberate cross-volume reads are
limited to device and exact-path absence checks required for that rejection proof.

The old-root census found one missed disposable audit list,
`/private/tmp/linkedspec-julia-reverify-cards.txt` (88 lines, 4,646 bytes). Metadata, content, and repository-reference
checks proved it contained only derived knowledge-card path names; the exact file was deleted, and both frozen old
temporary roots then contained zero exact LinkedSpec tool residue.

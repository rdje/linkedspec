---
id: rust-build-requirements-documentation-gap
title: Rust README compiler requirement conflicts with locked local dependency declarations
answers:
  - what minimum Rust compiler does the README claim
  - why is the Rust README 1.85 requirement stale
  - which required local dependencies declare Rust 1.95
  - does Cargo metadata prove the earliest working Rust compiler
  - who owns the Rust build requirements and command documentation repair
date: 2026-09-07
status: verified declared-requirement mismatch; compiler support floor and documentation repair pending
tags: [rust, cargo, requirements, documentation, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.3.2 reads the complete Rust README and manifests, then resolves locked offline Cargo metadata: 199 packages, empty stderr, required local pgen 1.0.0 and rgx-core 0.1.0 declaring Rust 1.95 against README line 472's 1.85+. No older compiler was run. Existing repair .41.7 owns the requirements, managed commands, and stale primary-case count; .41.2 owns generated-classifier wording."
reverify: "bash tools/run_cargo_local.sh metadata --manifest-path rust/Cargo.toml --locked --offline --format-version 1"
---

`rust/README.md` line 472 claims Rust 1.85+ with edition 2024. The workspace and
core manifests use the relative local `rgx` dependency. Locked offline metadata
resolves 199 packages and declares the following requirements above 1.85:

| Package | Version | Declared rust_version | Source |
| --- | --- | --- | --- |
| wasip2 | 1.0.4+wasi-0.2.12 | 1.87.0 | registry |
| wasip3 | 0.4.0+wasi-0.3.0-rc-2026-01-06 | 1.87.0 | registry |
| wit-bindgen | 0.51.0 | 1.87.0 | registry |
| wit-bindgen-core | 0.51.0 | 1.87.0 | registry |
| wit-bindgen-rust | 0.51.0 | 1.87.0 | registry |
| ar_archive_writer | 0.5.2 | 1.88.0 | registry |
| home | 0.5.12 | 1.88 | registry |
| pgen | 1.0.0 | 1.95 | local |
| rgx-core | 0.1.0 | 1.95 | local |

The required local declarations contradict the README. Platform-specific registry
rows do not establish a universal host requirement. Metadata describes package
declarations, not the earliest compiler on which the complete project has been
tested. This checkpoint neither runs an older compiler nor changes dependencies,
pins, manifests, or the public support promise. It reads necessary Cargo metadata,
not excluded nested dependency source.

The exact managed census is reproducible without fetching dependencies:

```bash
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'RUSTMSRVREAD'
import subprocess, json
run = subprocess.run([
    'bash', 'tools/run_cargo_local.sh', 'metadata', '--manifest-path',
    'rust/Cargo.toml', '--locked', '--offline', '--format-version', '1'
], capture_output=True, text=True, check=True)
data = json.loads(run.stdout)
def parts(version):
    return tuple(int(x) for x in version.split('.')[:2])
higher = [
    {'name': p['name'], 'version': p['version'],
     'rust_version': p['rust_version'],
     'source_kind': 'registry' if (p.get('source') or '').startswith('registry+') else 'local'}
    for p in data['packages']
    if p.get('rust_version') and parts(p['rust_version']) > (1, 85)
]
print(json.dumps({
    'metadata_packages': len(data['packages']),
    'declared_above_readme_1_85': sorted(higher, key=lambda p: (parts(p['rust_version']), p['name'])),
    'stderr': run.stderr
}))
RUSTMSRVREAD
```

`SESSION-STARTUP-READING.41.7` owns an actual managed compiler/build proof before
publishing a corrected support floor, root-relative managed Cargo examples, and
the README's stale 63-case primary claim against the current 66-case authority.
`.41.2` owns reconciliation of the subset wording with the unconditional 105-case
generated-source classifier. A classifier's existence is separate from whether
the optional full Rust gate ran in a particular canonical invocation. The current
reading checkpoint does not claim fresh execution of that optional gate.

Related: [[rust-project-data-ssd-storage]],
[[rust-generated-source-full-manifest-classification]], [[rust-local-verification-gate]].

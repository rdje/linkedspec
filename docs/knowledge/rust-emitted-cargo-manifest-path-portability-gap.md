---
id: rust-emitted-cargo-manifest-path-portability-gap
title: Nine Rust emitted-test manifest writers persist absolute runtime dependencies
answers:
  - "which Rust emitted test manifests persist absolute crate paths"
  - "does same-volume scratch storage make emitted Cargo inputs relocatable"
  - "what repair owns relative dependencies in generated Rust test workspaces"
  - "how can I reproduce the emitted Cargo path gap without building dependencies"
date: 2026-09-08
status: confirmed generated-input portability defect; repair SESSION-STARTUP-READING.78 pending
tags: [rust, emitted-source, Cargo, paths, portability, verification]
evidence: "Startup .3.3.58 compiles exact original workspace constructors and manifest-writing blocks from unchanged recognition and recursive-observation consumers. Both persist absolute runtime dependencies; a relative input control resolves the identical crate; original Drop removes each workspace. A source census finds nine absolute writers and five relative sites in four other test files. This is construction/source proof, not emitted parser execution or a moved-workspace Cargo build."
reverify: "bash tools/project_data_run.sh python3 -c 'from pathlib import Path; s=Path(\"docs/knowledge/rust-emitted-cargo-manifest-path-portability-gap.md\").read_text(); exec(s.split(\"```python\\n\",1)[1].split(\"\\n```\",1)[0])'"
---

ADR 0052.1 includes authored generated dependency inputs. These Cargo manifests store an absolute
runtime-crate path obtained from CARGO_MANIFEST_DIR. The workspaces can be on the correct filesystem
while their dependency inputs still retain the old checkout location after a move. ADR 0052.6 separately
permits ignored tool-generated cache/debug metadata; this finding does not expand that policy.

Repair SESSION-STARTUP-READING.78 owns relative paths derived for each actual workspace layout,
proper TOML spelling, ordinary emitted execution and moved-workspace dependency resolution. It must audit
analogous first-party writers before implementation; the current census is bounded to runtime Rust tests.
The classifier process-status defect remains separately owned by SESSION-STARTUP-READING.77.

All paths in this table are beneath rust/linkedspec-runtime/tests. Source inspection on September 8 finds:

| Consumer | Manifest dependency line | Evidence |
| --- | ---: | --- |
| recognition_transaction_contract.rs | 883 | Executable construction probe below |
| recursive_observation_contract.rs | 401 | Executable construction probe below |
| generated_source_full_manifest_classifier.rs | 86 | Source: runtime_manifest.display() |
| inter_match_gap_capture_contract.rs | 537 | Source: debug formatting of runtime_manifest |
| logical_helper_contract.rs | 472 | Source: runtime_manifest.display() |
| progressive_span_dispatch_contract.rs | 548 | Source: debug formatting of CARGO_MANIFEST_DIR |
| semantic_index_runtime_observation.rs | 613 | Source: runtime_manifest.display() |
| source_emitter.rs | 286 | Source: runtime_manifest.display() |
| staged_ast_enrichment_contract.rs | 2068 | Source: debug formatting of CARGO_MANIFEST_DIR |

Relative source controls exist in callable_codeblock_literal_contract.rs at 558 and 889,
source_boundary_compatibility_aliases.rs at 158, map_leaves_mutation_contract.rs at 709 and
write_vivification_contract.rs at 569. They use ../../../linkedspec-runtime for their specific
workspace depth. Gap and logical-helper consumers check child success but still write absolute dependencies;
status validation and path portability are independent properties.

The two probes reproduce the construction results retained in commit d6f37492. They pin each whole source,
extract the unchanged constructor/Drop and writer, and replace only the ephemeral manifest dependency for
the relative control. Both exit 0 with absolute_dependency=true, relative_control_same_target=true and
exact_workspace_removed=true. The new dedented-constructor-then-writer SHA-256 identities are:

- recognition: d004e40d73a2e291189bba760b2668e07150486b8d381d4c07bb6f3231ac3972
- observation: d35e1f9124ce00c0df3d169061908de6ec8a5f3ae120300d6e16ef0d3fcd8ea7

The extracted-hash layout differs from the original retained probe; whole-owner identities agree.
No child Cargo build runs, no production source changes, and no parser or current relocation failure is
inferred. The managed scratch directory and both original test workspaces are removed after success.
The installed Rust compiler is a required read-only toolchain dependency; generated probe data stays on the
repository device. Source pins intentionally fail after repair and must then yield to governed regression proof.

```python
from pathlib import Path
import hashlib, json, os, re, subprocess, tempfile, textwrap

owners = [
    ("recognition_transaction_contract", "ed7d28d4d380db7c44a786b1dfd778445b5b3199c3f9b2af48a216590b7534c2", "transaction"),
    ("recursive_observation_contract", "57caf58049aca5008ad8d03676b101c6a4704b4abe8eadeb24a976869d529b71", "observation"),
]
root = Path.cwd().resolve()
manifest_dir = root / "rust/linkedspec-runtime"
with tempfile.TemporaryDirectory(prefix="emitted-manifest-construction-") as temporary:
    scratch = Path(temporary)
    assert scratch.stat().st_dev == root.stat().st_dev
    for name, expected, kind in owners:
        owner = Path("rust/linkedspec-runtime/tests") / (name + ".rs")
        raw = owner.read_bytes()
        assert hashlib.sha256(raw).hexdigest() == expected
        source = raw.decode()
        constructor = re.search(r"(?m)^([ \t]*)struct EmittedProject \{.*?(?=^[ \t]*#\[test\])", source, re.S).group(0)
        constructor = textwrap.dedent(constructor)
        writer = re.search(r"(?m)^[ \t]*let runtime_manifest =.*?\.expect\(\"write emitted " + kind + r" manifest\"\);", source, re.S).group(0)
        writer = textwrap.dedent(writer)
        program = """use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};
""" + constructor + "\nfn main() {\nlet project = EmittedProject::new();\n" + writer + r'''
    assert!(runtime_manifest.is_absolute());
    let manifest = fs::read_to_string(project.root.join("Cargo.toml")).unwrap();
    let original = format!("path = {:?}", runtime_manifest);
    assert_eq!(manifest.matches(&original).count(), 1);
    let relative = "../../../linkedspec-runtime";
    assert_eq!(
        project.root.join(relative).canonicalize().unwrap(),
        runtime_manifest.canonicalize().unwrap()
    );
    let control = manifest.replace(&original, &format!("path = {:?}", relative));
    fs::write(project.root.join("Cargo.toml"), &control).unwrap();
    assert_eq!(fs::read_to_string(project.root.join("Cargo.toml")).unwrap(), control);
    assert!(!control.contains(&original));
    let workspace = project.root.clone();
    drop(project);
    assert!(!workspace.exists());
    println!("absolute_dependency=true relative_control_same_target=true exact_workspace_removed=true");
}
'''
        src = scratch / (name + ".rs")
        executable = scratch / name
        src.write_text(program)
        environment = os.environ.copy()
        environment["CARGO_MANIFEST_DIR"] = str(manifest_dir)
        subprocess.run(["rustc", "--edition=2024", str(src), "-o", str(executable)],
                       env=environment, check=True, capture_output=True, text=True)
        result = subprocess.run([str(executable)], check=True, capture_output=True, text=True)
        assert result.stdout.strip() == "absolute_dependency=true relative_control_same_target=true exact_workspace_removed=true"
        print(json.dumps({
            "owner": owner.as_posix(), "owner_sha256": expected,
            "dedented_constructor_then_writer_sha256": hashlib.sha256((constructor + writer).encode()).hexdigest(),
            "observation": result.stdout.strip(), "harness_exit": result.returncode
        }, sort_keys=True))
assert not scratch.exists()
print("managed_probe_directory_removed=true; child_cargo_builds=0")
```

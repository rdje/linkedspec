---
id: rust-generated-classifier-child-status-gap
title: Rust generated-source classifier can accept a failed child when every pass marker is present
answers:
  - "can the Rust generated-source classifier pass after child Cargo failure"
  - "does HOST_RUN_PASS prove the child process exited successfully"
  - "what repair owns the generated classifier host_run exit-status gap"
  - "how can I reproduce failed-child false success without a real Cargo failure"
date: 2026-09-08
status: confirmed defect; repair SESSION-STARTUP-READING.77 pending
tags: [rust, verification, classifier, child-process, generated-source]
evidence: "Startup .3.3.51 replays six source-extracted Rust controls against unchanged classifier source SHA-256 25f37479a76a3022758cc09aeb4b162d3086d7d069be267ef7cd1f565eaa9dc7. Exit 101 with all 105 real manifest markers produces CLASSIFY SUMMARY total=105 pass=105 fail=0 and a successful harness exit. An in-memory status guard rejects that result. Success/all and success/missing-marker controls preserve the distinction. The original results were also retained in d6f37492; no production code changes or real Cargo failure are inferred."
reverify: "bash tools/project_data_run.sh python3 -c 'from pathlib import Path; s=Path(\"docs/knowledge/rust-generated-classifier-child-status-gap.md\").read_text(); exec(s.split(\"```python\\n\",1)[1].split(\"\\n```\",1)[0])'"
---

The classifier checks host compilation status, then collects host-run pass markers into a set.
It records the run status as diagnostic text but never requires success before counting a marked case as passed.
All markers therefore satisfy both final assertions even if the child process exited unsuccessfully.
This is a verifier defect; it does not establish a parser-output defect or invalidate a particular recorded CI run.

| Injected child result | Original harness exit | In-memory guard exit |
| --- | --- | --- |
| Success, all 105 markers | 0; 105 pass / 0 fail | 0; 105 pass / 0 fail |
| Exit 101, all 105 markers | **0; 105 pass / 0 fail** | 101; rejects before accounting |
| Success, one marker missing | 101; 104 pass / 1 fail | 101; 104 pass / 1 fail |

Repair `SESSION-STARTUP-READING.77` must bind process success to exact marker/accounting evidence,
cover nonzero/signal/missing/duplicate/unknown controls and execute the actual emitted Cargo route.
It follows required reading and policy alignment; this intake does not implement the repair.
Historical classifier admission evidence stays dated in [[rust-generated-source-full-manifest-classification]].

The Unix probe below preserves the complete `cargo_failure_detail`, `record_failure` and classifier bodies.
Only `#[test]` is removed to call the classifier from a standalone main; the extracted tail has SHA-256
`f1848092d5c6d0b3f6ec9d52627f8f13d39aa189d9da31f28afcefe8afce1261`.
Adapters replace preparation/filesystem/Cargo operations and supply the 105 actual manifest names.
The guard variant adds only a process-status assertion in memory. It is a causal control, not the final fix.

Run this `CLASSIFIER_STATUS_PROBE` code with `bash tools/project_data_run.sh python3`.
The managed temporary directory is on the repository device and is removed after both compiled probes finish.
It uses the installed Rust toolchain read-only as a required compiler dependency. Source pins deliberately fail
after a classifier change; the repair must then replace this defect reproduction with its governed regression proof.

```python
from pathlib import Path
import hashlib, json, os, re, subprocess, tempfile

owner = Path("rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs")
source = owner.read_text()
assert hashlib.sha256(owner.read_bytes()).hexdigest() == "25f37479a76a3022758cc09aeb4b162d3086d7d069be267ef7cd1f565eaa9dc7"
tail = source[source.index("fn cargo_failure_detail"):].replace("#[test]\n", "")
assert hashlib.sha256(tail.encode()).hexdigest() == "f1848092d5c6d0b3f6ec9d52627f8f13d39aa189d9da31f28afcefe8afce1261"
names = json.loads(Path("rust/linkedspec-runtime/tests/corpus/manifest.json").read_text())["cases"]
assert len(names) == len(set(names)) == 105
# Fixture names are checked before using their JSON spelling as Rust literals.
assert all(re.fullmatch(r"[A-Za-z0-9_]+", name) for name in names)
adapters = r'''
use std::collections::BTreeSet;
use std::path::{Path, PathBuf};
use std::process::{Output, ExitStatus};
use std::os::unix::process::ExitStatusExt;
const COMPLETED_STAGES: &str = "read,parse,validate,compile,interpreter_oracle,emit_source,host_compile,host_run";
const NAMES: &[&str] = __NAMES__;
struct CorpusManifest { cases: Vec<String>, case_count: usize }
struct CaseFailure { stage: &'static str, detail: String }
impl CaseFailure {
    fn new(stage: &'static str, detail: impl Into<String>) -> Self {
        Self { stage, detail: detail.into() }
    }
}
struct PreparedCase;
struct TempProject;
fn corpus_dir() -> PathBuf { std::env::current_dir().unwrap() }
fn load_manifest(_: &Path) -> CorpusManifest {
    CorpusManifest { cases: NAMES.iter().map(|s| s.to_string()).collect(), case_count: NAMES.len() }
}
fn prepare_case(_: &Path, _: &str) -> Result<PreparedCase, CaseFailure> { Ok(PreparedCase) }
impl TempProject {
    fn new() -> Self { Self }
    fn write_cases(&self, _: &[(String, PreparedCase)]) -> Result<(), CaseFailure> { Ok(()) }
    fn cargo(&self, args: &[&str]) -> std::io::Result<Output> {
        if args.contains(&"--no-run") {
            return Ok(Output { status: ExitStatus::from_raw(0), stdout: vec![], stderr: vec![] });
        }
        let mode = std::env::var("CLASSIFIER_PROBE_MODE").unwrap();
        let limit = NAMES.len() - usize::from(mode == "success_missing_marker");
        let text: String = NAMES[..limit].iter().map(|n| format!("HOST_RUN_PASS {n}\n")).collect();
        let code = if mode == "failed_all_markers" { 101 } else { 0 };
        Ok(Output { status: ExitStatus::from_raw(code << 8), stdout: text.into_bytes(), stderr: vec![] })
    }
}
'''.replace("__NAMES__", "&[" + ",".join(json.dumps(n) for n in names) + "]")
needle = "            let stdout = String::from_utf8_lossy(&run_output.stdout);"
assert tail.count(needle) == 1
variants = {
    "original": tail,
    "guard_control": tail.replace(needle, '            assert!(run_output.status.success(), "host_run rejected");\n' + needle),
}
modes = ["success_all_markers", "failed_all_markers", "success_missing_marker"]
expected = {"original": [0, 0, 101], "guard_control": [0, 101, 101]}
results = []
# The repository-managed wrapper supplies TMPDIR; reject another volume.
scratch_root = Path(os.environ["TMPDIR"])
assert scratch_root.stat().st_dev == Path(".").stat().st_dev
with tempfile.TemporaryDirectory(prefix="classifier-status-probe-", dir=scratch_root) as raw:
    workspace = Path(raw)
    for variant, body in variants.items():
        rust = workspace / (variant + ".rs")
        executable = workspace / variant
        rust.write_text(adapters + body + "\nfn main() { classify_all_generated_source_manifest_cases(); }\n")
        subprocess.run(["rustc", "--edition=2021", str(rust), "-o", str(executable)],
                       check=True, capture_output=True, text=True, timeout=60)
        for mode, expected_exit in zip(modes, expected[variant]):
            run_env = os.environ.copy()
            run_env["CLASSIFIER_PROBE_MODE"] = mode
            run = subprocess.run([str(executable)], env=run_env, capture_output=True, text=True, timeout=60)
            assert run.returncode == expected_exit, (variant, mode, run.returncode, run.stderr)
            summary = next((line for line in run.stdout.splitlines() if line.startswith("CLASSIFY SUMMARY")), None)
            if mode == "success_all_markers" or (variant == "original" and mode == "failed_all_markers"):
                assert summary == "CLASSIFY SUMMARY total=105 pass=105 fail=0"
            elif mode == "success_missing_marker":
                assert summary == "CLASSIFY SUMMARY total=105 pass=104 fail=1"
            else:
                assert summary is None
            results.append({"variant": variant, "child_result": mode, "harness_exit": run.returncode, "summary": summary})
assert not workspace.exists()
print(json.dumps({"source_sha256": hashlib.sha256(owner.read_bytes()).hexdigest(),
                  "tail_sha256": hashlib.sha256(tail.encode()).hexdigest(), "results": results,
                  "scratch_removed": True}, indent=2))

```

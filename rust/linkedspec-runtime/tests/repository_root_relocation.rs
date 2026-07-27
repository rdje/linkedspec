use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::time::{SystemTime, UNIX_EPOCH};

const MARKER: &str = "specs/user_function_definition.spec";
const SENTINEL_NAME: &str = "RelocationSentinel";

struct OwnedScratch {
    path: PathBuf,
    run_root: PathBuf,
}

impl OwnedScratch {
    fn new() -> Self {
        let run_root = PathBuf::from(
            env::var_os("LINKEDSPEC_RUN_DIR")
                .expect("repository relocation test requires the managed project-data wrapper"),
        );
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system clock must follow the Unix epoch")
            .as_nanos();
        let path = run_root.join(format!(
            "repository-root-relocation-{}-{nonce}",
            std::process::id()
        ));
        fs::create_dir(&path).expect("create owned relocation scratch");
        Self { path, run_root }
    }
}

impl Drop for OwnedScratch {
    fn drop(&mut self) {
        assert!(
            self.path.starts_with(&self.run_root),
            "cleanup target must remain below the managed run"
        );
        if self.path.exists() {
            fs::remove_dir_all(&self.path).expect("remove owned relocation scratch");
        }
    }
}

fn write_repository(root: &Path, result: &str) {
    let specs = root.join("specs");
    fs::create_dir_all(&specs).expect("create synthetic repository specs directory");
    fs::write(root.join(MARKER), b"repository marker\n")
        .expect("write synthetic repository marker");
    fs::write(
        specs.join(format!("{SENTINEL_NAME}.spec")),
        format!("Top::\n /x/\n E {{ return(\"{result}\") }}\n"),
    )
    .expect("write unique relocation sentinel spec");
}

fn invoke(primary: &Path, cwd: &Path) -> Output {
    Command::new(primary)
        .args(["--spec", SENTINEL_NAME, "--input", "x"])
        .current_dir(cwd)
        .output()
        .expect("launch copied Rust primary")
}

#[test]
fn copied_primary_uses_its_moved_repository_and_requires_its_marker() {
    let scratch = OwnedScratch::new();
    let moved_root = scratch.path.join("moved repository");
    let ambient_root = scratch.path.join("ambient repository");
    let outside = scratch.path.join("outside");
    write_repository(&moved_root, "relocated-root");
    write_repository(&ambient_root, "ambient-wrong-root");
    fs::create_dir(&outside).expect("create outside cwd");

    let copied_primary = moved_root.join("bin/linkedspec-rust");
    fs::create_dir_all(copied_primary.parent().expect("copied primary parent"))
        .expect("create copied primary directory");
    fs::copy(env!("CARGO_BIN_EXE_linkedspec-rust"), &copied_primary)
        .expect("copy freshly built Rust primary");

    let relocated = invoke(&copied_primary, &ambient_root);
    assert_eq!(relocated.status.code(), Some(0));
    assert_eq!(relocated.stdout, b"\"relocated-root\"\n");
    assert!(relocated.stderr.is_empty());

    fs::remove_file(moved_root.join(MARKER)).expect("remove moved-root marker mutation");
    let incomplete = invoke(&copied_primary, &outside);
    assert_eq!(incomplete.status.code(), Some(1));
    assert!(incomplete.stdout.is_empty());
    assert_eq!(
        incomplete.stderr,
        b"linkedspec: parser compilation failed\n"
    );
}

use linkedspec_runtime::primary_cli;
use std::io::Write;

fn main() {
    let output = primary_cli::run(std::env::args_os().skip(1).collect());
    if let Err(error) = std::io::stdout().write_all(&output.stdout) {
        let _ = writeln!(
            std::io::stderr(),
            "linkedspec: stdout write failed: {error}"
        );
        std::process::exit(1);
    }
    if let Err(error) = std::io::stderr().write_all(&output.stderr) {
        let _ = writeln!(
            std::io::stderr(),
            "linkedspec: stderr write failed: {error}"
        );
        std::process::exit(1);
    }
    std::process::exit(output.exit_code);
}

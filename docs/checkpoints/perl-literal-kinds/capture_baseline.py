"""Run the corrected oracle against accepted runtime sources and restore exactly."""
import os
import subprocess
import common as c
import context

PATHS = ("perl/LinkedSpec/CodeblockRuntime.pm", "perl/LinkedSpec/BindingRuntime.pm")


def main():
    candidate = {path: c.read(path) for path in PATHS}
    accepted = {path: subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT) for path in PATHS}
    epoch = context.snapshot()
    c.write_new("verified-baseline-controller-inputs.json.gz", dict(context=epoch,
        producer=c.read(c.PREFIX + "capture_baseline.py"), candidate_sources=candidate,
        accepted_sources={path: dict(base64=c.encode(raw), sha256=c.sha(raw)) for path, raw in accepted.items()}))
    run = None
    try:
        for path, raw in accepted.items():
            c.source(path).write_bytes(raw)
        run = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "capture.py", "verified-before"])
    finally:
        for path, item in candidate.items():
            c.source(path).write_bytes(c.decode(item["base64"]))
            os.chmod(c.source(path), item["mode"])
    restored = {path: c.identity(path) for path in PATHS}
    unchanged = c.unchanged(epoch["inputs"])
    c.write_new("verified-baseline-controller-runs.json.gz", dict(run=run,
        restored_sources=restored, inputs_restored=unchanged))
    assert unchanged and run is not None and run["returncode"] == 0, run
    print(c.decode(run["stdout_base64"]).decode(), end="", flush=True)
    print("Corrected accepted baseline retained; both candidate runtime sources restored byte/mode-exact.", flush=True)


if __name__ == "__main__":
    main()

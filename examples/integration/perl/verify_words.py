"""Verify the native Perl word consumer in a managed project-local environment."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    root = Path(__file__).resolve().parents[3]
    options = argparse.ArgumentParser(description=__doc__)
    options.add_argument("--perl", default="perl")
    options.add_argument("--perl-root", type=Path, default=root / "perl")
    options.add_argument("--consumer", type=Path, default=Path(__file__).with_name("parse_words.pl"))
    options.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    args = options.parse_args()
    modules = args.perl_root.resolve(strict=True)
    consumer = args.consumer.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    scratch = Path(os.environ["TMPDIR"]).resolve(strict=True)
    assert scratch.stat().st_dev == root.stat().st_dev, "scratch must be on the repository volume"
    environment = dict(os.environ, PERL5LIB="", PERL5OPT="", PERL_UNICODE="")
    command = [args.perl, "-I" + str(modules), str(consumer)]
    checked = []

    def run(label, arguments, cwd, expected=None, error=None):
        result = subprocess.run(command + arguments, cwd=cwd, env=environment,
                                capture_output=True, timeout=120, check=False)
        if error is None:
            assert result.returncode == 0, (label, result.returncode, result.stderr)
            assert result.stderr == b"", (label, result.stderr)
            assert [json.loads(line) for line in result.stdout.splitlines()] == expected, label
        else:
            assert result.returncode == 1 and result.stdout == b"", (label, result)
            record = json.loads(result.stderr)
            assert record["type"] == error, (label, record)
            if error == "spec_pipeline_error":
                assert record["stage"] == "resolve_spec_path", record
                assert record["code"] == "spec_path_not_found", record
                assert record["request_kind"] == "path", record
        checked.append(label)

    with tempfile.TemporaryDirectory(prefix="perl-integration-", dir=scratch) as directory:
        work = Path(directory)
        report = work / "modules.json"
        audit = subprocess.run([args.perl, "-I" + str(modules),
            str(Path(__file__).with_name("inspect_modules.pl")), str(report),
            str(consumer), str(grammar), "alpha", "Beta"], cwd=root,
            env=environment, capture_output=True, timeout=120, check=False)
        assert audit.returncode == 0 and audit.stderr == b"", audit
        assert [json.loads(line) for line in audit.stdout.splitlines()] == [["alpha"], ["Beta"]]
        provenance = json.loads(report.read_text())
        owned = [m for m in provenance["modules"] if m["project_owned"] and m["path"].endswith(".pm")]
        external = [m for m in provenance["modules"] if not m["project_owned"]]
        assert owned and external, "expected project modules and Perl core modules"
        assert all((root / m["path"]).is_relative_to(modules) for m in owned), owned
        assert all(m["in_core_catalog"] for m in external), external
        core_roots = [Path(path).resolve(strict=True) for path in provenance["core_library_roots"]]
        for path in [m["path"] for m in external] + provenance["shared_objects"]:
            assert any(Path(path).resolve(strict=True).is_relative_to(base) for base in core_roots), path
        assert not {"PathSearch.pm", "PPlugin.pm"} & {m["key"] for m in provenance["modules"]}
        checked.append("explicit module origin and Perl core closure")
        run("independent inputs and repeat", [str(grammar), "alpha", "Beta", "123",
            "123 alpha rest", "", "alpha", "café"], work,
            expected=[["alpha"], ["Beta"], [], ["alpha", "rest"], [], ["alpha"], ["caf"]])
        local = work / "specs é"
        local.mkdir()
        shutil.copyfile(grammar, local / "words.spec")
        run("caller-relative Unicode grammar and cwd", ["words.spec", "one two"], local,
            expected=[["one", "two"]])
        run("missing grammar", ["absent.spec", "alpha"], work, error="spec_pipeline_error")
        run("missing arguments", [], work, error="consumer_error")
        run("missing input", [str(grammar)], work, error="consumer_error")
        if os.name == "posix":
            run("invalid UTF-8 input", [str(grammar), b"\xff"], work, error="consumer_error")
            run("invalid UTF-8 grammar path", [b"\xff", "alpha"], work, error="consumer_error")
    assert not work.exists(), "owned verification fixtures were not removed"
    print(json.dumps({"status": "PASS", "checks": checked, "fixture_cleanup": True,
                      "perl": provenance["perl"], "project_modules": len(owned),
                      "core_modules": len(external), "native_libraries": len(provenance["shared_objects"])}))


if __name__ == "__main__":
    main()

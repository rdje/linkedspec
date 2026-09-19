"""Verify native Dart values, application package roots and required grammar assets."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
from urllib.parse import unquote, urljoin, urlparse


def file_uri_path(uri):
    parsed = urlparse(uri)
    assert parsed.scheme == "file" and not parsed.netloc, uri
    return Path(unquote(parsed.path)).resolve(strict=True)


def main():
    root = Path(__file__).resolve().parents[3]
    options = argparse.ArgumentParser(description=__doc__)
    options.add_argument("--package", type=Path, default=Path(__file__).resolve().parent)
    options.add_argument("--library-root", type=Path, default=root)
    options.add_argument("--grammar", type=Path, default=root / "examples/integration/word.spec")
    args = options.parse_args()
    package = args.package.resolve(strict=True)
    library = args.library_root.resolve(strict=True)
    grammar = args.grammar.resolve(strict=True)
    scratch = Path(os.environ["TMPDIR"]).resolve(strict=True)
    assert scratch.stat().st_dev == root.stat().st_dev
    data = package / ".app-data/linkedspec"
    environment = dict(os.environ, LINKEDSPEC_PROJECT_DATA_ROOT=str(data),
        LINKEDSPEC_CACHE_ROOT=str(data / "cache"), LINKEDSPEC_SCRATCH_ROOT=str(data / "scratch"),
        PUB_CACHE=str(data / "cache/dart-pub"), LINKEDSPEC_DART_HOME=str(data / "cache/dart-home"))
    wrapper = ["bash", str(library / "tools/run_dart_project_data.sh")]
    setup = subprocess.run(wrapper + ["pub", "get", "--offline"], cwd=package,
        env=environment, capture_output=True, timeout=120, check=False)
    assert setup.returncode == 0, setup
    config_path = package / ".dart_tool/package_config.json"
    config = json.loads(config_path.read_text())
    roots = {item["name"]: file_uri_path(urljoin(config_path.as_uri(), item["rootUri"]))
             for item in config["packages"]}
    assert roots == {"linkedspec_dart": library / "dart", "linkedspec_integration_example": package}, roots
    assert file_uri_path(config["pubCache"]) == data / "cache/dart-pub"
    assert all(path.stat().st_dev == root.stat().st_dev for path in roots.values())
    checked = ["offline resolution has exactly two local package roots"]
    command = wrapper + ["--packages=" + str(config_path), str(package / "bin/parse_words.dart")]

    def run(label, arguments, cwd, expected=None, error=None):
        result = subprocess.run(command + [str(arg) for arg in arguments], cwd=cwd,
            env=environment, capture_output=True, timeout=120, check=False)
        if error is None:
            assert result.returncode == 0 and result.stderr == b"", (label, result)
            assert [json.loads(line) for line in result.stdout.splitlines()] == expected, (label, result.stdout)
        else:
            assert result.returncode == 1 and result.stdout == b"", (label, result)
            record = json.loads(result.stderr)
            for key, value in error.items():
                assert record[key] == value, (label, record)
        checked.append(label)

    with tempfile.TemporaryDirectory(prefix="dart-integration-", dir=scratch) as directory:
        work = Path(directory)
        # The staged file loader searches cwd ancestors for this grammar even
        # when the application grammar contains no function definition.
        specs = work / "specs"
        specs.mkdir()
        support = specs / "user_function_definition.spec"
        support_bytes = (library / "specs/user_function_definition.spec").read_bytes()
        support.write_bytes(support_bytes)
        run("independent values and repeated input", [grammar, "alpha", "Beta", "123",
            "123 alpha rest", "", "alpha", "café"], work,
            expected=[["alpha"], ["Beta"], [], ["alpha", "rest"], [], ["alpha"], ["caf"]])
        local = work / "specs é"
        local.mkdir()
        (local / "word.spec").write_bytes(grammar.read_bytes())
        run("caller-relative Unicode grammar and cwd", ["word.spec", "one two"], local,
            expected=[["one", "two"]])
        run("missing grammar", [work / "absent.spec", "x"], work,
            error={"type": "spec_pipeline_error", "stage": "resolve_spec_path", "code": "spec_path_not_found"})
        invalid = work / "invalid.spec"
        invalid.write_bytes(b"\xff")
        run("strict UTF-8 grammar", [invalid, "x"], work,
            error={"type": "spec_pipeline_error", "stage": "decode_spec_content", "code": "invalid_utf8"})
        run("missing arguments", [], work, error={"type": "consumer_error"})
        run("missing input", [grammar], work, error={"type": "consumer_error"})
        # A controlled bad copy proves lookup selected this owned asset, rather
        # than silently finding the original checkout above the temporary root.
        support.write_text("not a spec\n", encoding="utf-8")
        try:
            run("controlled supporting-grammar selection", [grammar, "alpha"], work,
                error={"type": "spec_pipeline_error", "stage": "parse_spec", "code": "spec_parse_failed"})
        finally:
            support.write_bytes(support_bytes)
        run("restored supporting grammar", [grammar, "alpha"], work, expected=[["alpha"]])
        assert support.read_bytes() == support_bytes
    assert not work.exists()
    assert all(path.stat().st_dev == root.stat().st_dev for path in data.rglob("*"))
    print(json.dumps({"status": "PASS", "checks": checked, "fixture_cleanup": True,
                      "sdk": config["generatorVersion"], "local_packages": sorted(roots)}))


if __name__ == "__main__":
    main()

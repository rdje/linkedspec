#!/usr/bin/env python3
"""Verify native document files, errors and relocation against authored values.

Run through tools/run_python_project_data.sh from the LinkedSpec root. The
deployed consumer uses Rust directly; Python is only verification tooling.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", required=True, type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    binary = args.binary.resolve(strict=True)
    grammar = root / "specs/SExprDocumentV1.spec"
    contract_path = root / "tests/sexpr-document-v1/contract.json"
    scratch = Path(os.environ.get("LINKEDSPEC_SCRATCH_ROOT", root / ".linkedspec-data/scratch"))
    scratch.mkdir(parents=True, exist_ok=True)
    for path in (binary, grammar, contract_path, scratch):
        if path.stat().st_dev != root.stat().st_dev:
            parser.error(f"verification inputs and workspace must share the repository volume: {path}")
    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    cases = contract["cases"]
    assert len(cases) == 37
    accepted = [case for case in cases if case["outcome"] == "accept"]
    rejected = [case for case in cases if case["outcome"] == "reject"]
    assert (len(accepted), len(rejected)) == (21, 16)
    original_hashes = {path: hashlib.sha256(path.read_bytes()).hexdigest()
                       for path in (binary, grammar, contract_path)}
    checks = []
    with tempfile.TemporaryDirectory(prefix="rust-sexpr-", dir=scratch) as temporary:
        workspace = Path(temporary)
        outside = workspace / "unrelated working directory 雪"
        outside.mkdir()
        documents = workspace / "documents é"
        documents.mkdir()

        def fixture(name, text):
            path = documents / name
            path.write_bytes(text.encode("utf-8"))
            return path

        def run(label, executable, arguments, *, expected=(), failure=False,
                error_text=None, error_fields=None):
            result = subprocess.run(
                [str(executable), *map(str, arguments)], cwd=outside,
                capture_output=True, text=True, encoding="utf-8", timeout=600, check=False,
            )
            assert result.returncode == (1 if failure else 0), (label, result.returncode, result.stderr)
            actual = [json.loads(line) for line in result.stdout.splitlines()]
            assert actual == list(expected), (label, actual, expected)
            if not failure:
                assert result.stderr == "", (label, result.stderr)
            else:
                assert result.stderr, (label, "failure must identify its cause")
                if error_text is not None:
                    assert error_text in result.stderr, (label, result.stderr)
                if error_fields is not None:
                    record = json.loads(result.stderr)
                    assert all(record.get(key) == value for key, value in error_fields.items()), (label, record)
            checks.append(label)

        files = {case["id"]: fixture(case["id"] + ".sexp", case["input"]) for case in cases}
        run("21 authored documents / one engine", binary,
            ["--grammar", grammar, *(files[case["id"]] for case in accepted)],
            expected=[case["expected"] for case in accepted])
        published = fixture("published-document.sexp", '(v 1 "1")\n(done)\n')
        run("published file example", binary, ["--grammar", grammar, published], expected=[{
            "format": "linkedspec-sexpr-v1", "forms": [
                {"kind": "list", "items": [
                    {"kind": "symbol", "lexeme": "v"},
                    {"kind": "number", "lexeme": "1"},
                    {"kind": "string", "lexeme": '"1"'},
                ]},
                {"kind": "list", "items": [{"kind": "symbol", "lexeme": "done"}]},
            ],
        }])
        for case in rejected:
            path = files[case["id"]]
            run(case["id"], binary, ["--grammar", grammar, path], failure=True,
                error_fields={"type": "document_parse_error", "input": str(path),
                              "cause": {"type": "runtime_exit_now", "status": 1}})

        good = next(case for case in accepted if case["id"] == "reuse_after_rejection")
        bad = rejected[0]
        run("earlier value retained / stop at rejected document", binary,
            ["--grammar", grammar, files[good["id"]], files[bad["id"]], documents / "not-attempted.sexp"],
            expected=[good["expected"]], failure=True,
            error_fields={"type": "document_parse_error", "input": str(files[bad["id"]]),
                          "cause": {"type": "runtime_exit_now", "status": 1}})

        shutil.copy2(grammar, outside / "grámmar 雪.spec")
        (outside / "--grammar").write_bytes(good["input"].encode("utf-8"))
        run("caller-relative Unicode grammar / option-like file", binary,
            ["--grammar", "grámmar 雪.spec", "--", "--grammar"], expected=[good["expected"]])
        missing_grammar = {"type": "spec_pipeline_error", "stage": "resolve_spec_path",
                           "code": "spec_path_not_found"}
        run("missing explicit grammar", binary,
            ["--grammar", workspace / "missing.spec", files[good["id"]]],
            failure=True, error_fields=missing_grammar)
        invalid_grammar = workspace / "invalid-utf8.spec"
        invalid_grammar.write_bytes(b"\xff")
        run("invalid UTF-8 grammar", binary,
            ["--grammar", invalid_grammar, files[good["id"]]], failure=True,
            error_fields={"type": "spec_pipeline_error", "stage": "decode_spec_content", "code": "invalid_utf8"})
        malformed = fixture("invalid-code.spec", "Document:: I { return(@invalid) }\n")
        run("grammar compilation fails before input loading", binary,
            ["--grammar", malformed, documents / "missing-input.sexp"], failure=True,
            error_fields={"type": "spec_pipeline_error", "stage": "compile_spec", "code": "spec_compile_failed"})
        run("historical Lispish is not a Document grammar", binary,
            ["--grammar", root / "specs/Lispish.spec", files[good["id"]]], failure=True,
            error_fields={"type": "document_parse_error", "input": str(files[good["id"]])})
        run("missing input", binary, ["--grammar", grammar, documents / "absent.sexp"],
            failure=True, error_text="absent.sexp")
        run("directory is not an input file", binary, ["--grammar", grammar, documents],
            failure=True, error_text=str(documents))
        invalid_input = documents / "invalid-utf8.sexp"
        invalid_input.write_bytes(b"(valid)\n(\xff)")
        run("invalid UTF-8 input / no prefix output", binary,
            ["--grammar", grammar, invalid_input], failure=True, error_text=str(invalid_input))
        for label, arguments in [("no arguments", []), ("missing grammar argument", ["--grammar"]),
                                 ("missing file argument", ["--grammar", grammar]), ("empty file list", ["--"])]:
            run(label, binary, arguments, failure=True, error_text="usage: sexpr_file")
        if os.name == "posix":
            result = subprocess.run([os.fsencode(binary), b"\xff"], cwd=outside,
                                    capture_output=True, timeout=600, check=False)
            assert result.returncode == 1 and not result.stdout
            assert b"arguments must be UTF-8" in result.stderr
            checks.append("invalid UTF-8 argument")

        bundle = workspace / "application bundle"
        (bundle / "specs").mkdir(parents=True)
        deployed = bundle / binary.name
        packaged_grammar = bundle / "specs/SExprDocumentV1.spec"
        shutil.copy2(binary, deployed)
        shutil.copy2(grammar, packaged_grammar)
        run("packaged / outside cwd", deployed,
            [files[good["id"]], files["empty"]], expected=[good["expected"], {"format": contract["format"], "forms": []}])
        moved = workspace / "relocated application 雪"
        bundle.rename(moved)
        run("relocated / all authored valid files", moved / binary.name,
            [files[case["id"]] for case in accepted], expected=[case["expected"] for case in accepted])
        assert hashlib.sha256((moved / binary.name).read_bytes()).hexdigest() == original_hashes[binary]
        assert hashlib.sha256((moved / "specs/SExprDocumentV1.spec").read_bytes()).hexdigest() == original_hashes[grammar]
        # A caller-owned copy cannot replace a missing executable-relative asset.
        (outside / "specs").mkdir()
        shutil.copy2(grammar, outside / "specs/SExprDocumentV1.spec")
        (moved / "specs/SExprDocumentV1.spec").unlink()
        run("missing owned grammar / no cwd fallback", moved / binary.name,
            [files[good["id"]]], failure=True, error_fields=missing_grammar)
        run("explicit grammar overrides absent packaged copy", moved / binary.name,
            ["--grammar", grammar, files[good["id"]]], expected=[good["expected"]])

    assert not workspace.exists(), "owned temporary fixtures must be removed"
    for path, expected_hash in original_hashes.items():
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected_hash, path
    print(json.dumps({"status": "PASS", "authored_cases": len(cases),
                      "accepted_files": len(accepted), "rejected_files": len(rejected),
                      "checks": checks}, ensure_ascii=False))


if __name__ == "__main__":
    main()

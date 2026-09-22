#!/usr/bin/env python3
"""Check the file consumer and relocatable bundle against explicit expectations.

Run through tools/run_python_project_data.sh from the LinkedSpec root. Python is
needed only for this verifier, not for the Rust consumer or deployed application.
"""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", required=True, type=Path)
    parser.add_argument("--grammar", default="specs/Lispish.spec", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    binary, grammar = args.binary.resolve(strict=True), args.grammar.resolve(strict=True)
    scratch = Path(os.environ.get("LINKEDSPEC_SCRATCH_ROOT", root / ".linkedspec-data/scratch"))
    scratch.mkdir(parents=True, exist_ok=True)
    for path in (binary, grammar, scratch):
        if path.stat().st_dev != root.stat().st_dev:
            parser.error(f"verification input/workspace must share the repository volume: {path}")

    checks = []
    with tempfile.TemporaryDirectory(prefix="rust-lispish-", dir=scratch) as temporary:
        workspace = Path(temporary)
        outside = workspace / "unrelated working directory"
        outside.mkdir()

        def run(label, executable, arguments, *, expected=None, error_text=None, error_fields=None):
            result = subprocess.run(
                [str(executable), *map(str, arguments)], cwd=outside,
                capture_output=True, text=True, encoding="utf-8", timeout=600, check=False,
            )
            if expected is not None:
                actual = [json.loads(line) for line in result.stdout.splitlines()]
                assert result.returncode == 0, (label, result.returncode, result.stderr)
                assert result.stderr == "", (label, result.stderr)
                assert actual == expected, (label, actual, expected)
            else:
                assert result.returncode == 1, (label, result.returncode, result.stderr)
                assert result.stdout == "", (label, result.stdout)
                if error_text:
                    assert error_text in result.stderr, (label, result.stderr)
                if error_fields:
                    actual = json.loads(result.stderr)
                    assert all(actual.get(key) == value for key, value in error_fields.items()), (label, actual)
            checks.append(label)

        def fixture(name, text):
            path = workspace / name
            path.write_text(text, encoding="utf-8")
            return path

        # Several files in one invocation prove reuse on independent inputs.
        cases = [
            ("flat", "(a b c)", ["a", "b", "c"]),
            ("nested", "(a (b c) d)", ["a", ["b", "c"], "d"]),
            ("empty", "()", []),
            ("nested-empty", "(())", [[]]),
            ("unicode", '(é λ "東京")', ["é", "λ", "東京"]),
            ("atoms", '(123 -4 1.25 "x y")', ["123", "-4", "1.25", "x y"]),
            ("escapes", r'("a\"b" "a\nb")', ['a\\"b', r"a\nb"]),
            ("comment", "(a ;comment\n b)", ["a", "b"]),
            ("brackets", "([a[b]c] {a{b}c} {})", ["[a[b]c]", "a{b}c", ""]),
            ("adjacent", '(a" b"[c]{d})', ["a b[c]d"]),
            ("single-quotes", "('x y')", ["'x", "y'"]),
            # SEMULITH/LS-001: exact controls and formerly corrupted LF payloads.
            ('semulith-01-control-one-line', '(r (a "x y"))\n', ['r', ['a', 'x y']]),
            ('semulith-02-control-parens', '(r (a "see (2) ok"))\n', ['r', ['a', 'see (2) ok']]),
            ('semulith-03-control-tab', '(r (a "x\ty"))\n', ['r', ['a', 'x\ty']]),
            ('semulith-04-control-cr', '(r (a "x\ry"))\n', ['r', ['a', 'x\ry']]),
            ('semulith-05-lf-data-only', '(r (a "x\ny"))\n', ['r', ['a', 'x\ny']]),
            ('semulith-06-lf-indented', '(r (a "x\n   y"))\n', ['r', ['a', 'x\n   y']]),
            ('semulith-07-lf-sibling-follows', '(r (a "x\n   y") (b "z"))\n', ['r', ['a', 'x\n   y'], ['b', 'z']]),
            ('semulith-08-lf-close-paren', '(r (a "p\n   q) r") (b "z"))\n', ['r', ['a', 'p\n   q) r'], ['b', 'z']]),
            # Characterization of historical limitations, not desired validation.
            ("extra-text", "prefix (a) suffix", ["a"]),
            ("two-forms", "(a)\n(b)", ["a"]),
            ("extra-close", "(a))", ["a"]),
            ("unclosed-quote", '("abc)', ["abc"]),
            ("empty-brackets", "([])", []),
            ("eof-comment", "(a ;comment)", ["a", "comment"]),
            ("reuse-control", "(again)", ["again"]),
        ]
        files = [fixture(f"{name}.sexp", text) for name, text, _ in cases]
        expected = [value for _, _, value in cases]
        run(f"{len(cases)} file values / one engine", binary, ["--grammar", grammar, *files], expected=expected)
        run("published settings file", binary,
            ["--grammar", grammar, root / "examples/integration/rust/settings.sexp"],
            expected=[["application", ["name", "ARCHOGEN"], ["paths", "src", "output"], ["enabled", "true"]]])
        shutil.copy2(grammar, outside / "relative.spec")
        (outside / "--grammar").write_text("(relative)", encoding="utf-8")
        run("caller-relative paths / option terminator", binary,
            ["--grammar", "relative.spec", "--", "--grammar"], expected=[["relative"]])
        for name, text in [("empty-file", ""), ("bare-atom", "atom"), ("missing-close", "(a b")]:
            run(name, binary, ["--grammar", grammar, fixture(name, text)],
                error_text="Lispish returned no parenthesized form")
        run("leading unmatched close", binary,
            ["--grammar", grammar, fixture("unmatched-close", ") (a)")],
            error_fields={"message": "exit_now(1)"})
        result = subprocess.run(
            [str(binary), "--grammar", str(grammar), str(files[0]), str(workspace / "unmatched-close")],
            cwd=outside, capture_output=True, text=True, encoding="utf-8", timeout=600, check=False,
        )
        assert result.returncode == 1
        assert [json.loads(line) for line in result.stdout.splitlines()] == [expected[0]]
        failure = json.loads(result.stderr)
        assert failure["message"] == "exit_now(1)" and isinstance(failure["diagnostic"], dict)
        checks.append("earlier output retained on later runtime failure")
        missing = workspace / "missing.spec"
        pipeline = {"type": "spec_pipeline_error", "stage": "resolve_spec_path", "code": "spec_path_not_found"}
        run("missing grammar", binary, ["--grammar", missing, files[0]], error_fields=pipeline)
        run("missing input", binary, ["--grammar", grammar, workspace / "absent.sexp"], error_text="absent.sexp")
        invalid = workspace / "invalid-utf8.sexp"
        invalid.write_bytes(b"(\xff)")
        run("invalid UTF-8 input", binary, ["--grammar", grammar, invalid], error_text="invalid-utf8.sexp")
        run("no arguments", binary, [], error_text="usage: lispish_file")
        run("missing grammar argument", binary, ["--grammar"], error_text="usage: lispish_file")
        run("missing input argument", binary, ["--grammar", grammar], error_text="usage: lispish_file")
        if os.name == "posix":
            result = subprocess.run([os.fsencode(binary), b"\xff"], cwd=outside,
                                    capture_output=True, timeout=600, check=False)
            assert result.returncode == 1 and not result.stdout
            assert b"arguments must be UTF-8" in result.stderr
            checks.append("invalid UTF-8 argument")

        bundle = workspace / "application bundle"
        (bundle / "specs").mkdir(parents=True)
        deployed = bundle / binary.name
        shutil.copy2(binary, deployed)
        shutil.copy2(grammar, bundle / "specs/Lispish.spec")
        run("packaged / outside cwd", deployed, [files[0], files[4]], expected=[expected[0], expected[4]])
        moved = workspace / "relocated application bundle"
        bundle.rename(moved)
        run("relocated / outside cwd", moved / binary.name, [files[1]], expected=[expected[1]])
        (moved / "specs/Lispish.spec").unlink()
        run("missing packaged grammar", moved / binary.name, [files[0]], error_fields=pipeline)
    print(json.dumps({"status": "PASS", "checks": checks, "file_values": len(cases)}, ensure_ascii=False))


if __name__ == "__main__":
    main()

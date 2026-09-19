"""Verify Perl application packaging, diagnostics and failure boundaries."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    root = Path(__file__).resolve().parents[3]
    examples = Path(__file__).resolve().parent
    options = argparse.ArgumentParser(description=__doc__)
    options.add_argument("--perl", default="perl")
    options.add_argument("--library-root", type=Path, default=root)
    options.add_argument("--consumer", type=Path, default=examples / "parse_words.pl")
    args = options.parse_args()
    library = args.library_root.resolve(strict=True)
    consumer = args.consumer.resolve(strict=True)
    scratch = Path(os.environ["TMPDIR"]).resolve(strict=True)
    assert scratch.stat().st_dev == root.stat().st_dev, "scratch must be on the repository volume"
    environment = dict(os.environ, PERL5LIB="", PERL5OPT="", PERL_UNICODE="0")
    command = [args.perl, "-I" + str(library / "perl"), str(consumer)]
    checks = []

    def run(label, argv, cwd, values, records, status=0, prefix=None, env=None):
        result = subprocess.run((prefix or command) + [str(a) for a in argv], cwd=cwd,
            env=env or environment, capture_output=True, timeout=120, check=False)
        assert result.returncode == status, (label, result.returncode, result.stderr)
        assert [json.loads(line) for line in result.stdout.splitlines()] == values, (label, result.stdout)
        decoded = [json.loads(line) for line in result.stderr.splitlines()]
        if callable(records):
            records(decoded)
        else:
            assert decoded == records, (label, decoded)
        checks.append(label)
        print("PASS: " + label, flush=True)

    def error(kind, **fields):
        def check(records):
            assert len(records) == 1, records
            assert records[0]["type"] == kind, records
            for key, value in fields.items():
                assert records[0][key] == value, records
        return check

    def snapshot(base):
        return {str(path.relative_to(base)): hashlib.sha256(path.read_bytes()).hexdigest()
                for path in base.rglob("*") if path.is_file()}

    with tempfile.TemporaryDirectory(prefix="perl-deployment-", dir=scratch) as directory:
        work = Path(directory)
        diagnostic = examples / "diagnostics.spec"
        events = [
            {"type": "diagnostic", "event": {"helper_name": "say", "rule_label": "Top", "message": "héllo 雪\n"}},
            {"type": "diagnostic", "event": {"helper_name": "print", "rule_label": "Top", "message": "done"}},
        ]
        run("quiet diagnostic helpers", [diagnostic, "x"], work, ["ok"], [])
        run("ordered Unicode diagnostic events", ["--diagnostics", diagnostic, "x", "x"],
            work, ["ok", "ok"], events * 2)
        # Raw JSON streams must remain correct even with inherited Unicode streams.
        run("explicit raw streams", ["--diagnostics", diagnostic, "x"], work, ["ok"], events,
            env=dict(environment, PERL_UNICODE=""))
        run("typed exit retains earlier result and stops later input",
            ["--diagnostics", examples / "exit.spec", "x", "y", "x"], work, ["ok"], [
                {"type": "diagnostic", "event": {"helper_name": "say", "rule_label": "Top", "message": "before\n"}},
                {"type": "runtime_exit_now", "status": 7, "rule_label": "Top"}], status=1)
        run("quiet typed exit", [examples / "exit.spec", "y"], work, [],
            error("runtime_exit_now", status=7, rule_label="Top"), status=1)
        run("missing grammar", [work / "missing.spec", "x"], work, [],
            error("spec_pipeline_error", stage="resolve_spec_path", code="spec_path_not_found"), status=1)
        invalid = work / "invalid.spec"
        invalid.write_bytes(b"\xff")
        run("invalid UTF-8 grammar", [invalid, "x"], work, [],
            error("spec_pipeline_error", stage="decode_spec_content", code="invalid_utf8"), status=1)
        trace_file = work / "inherited-trace.log"
        trace_file.write_bytes(b"preserve existing trace\n")
        ambient = dict(environment, LINKEDSPEC_TRACE_LEVEL="debug",
            LINKEDSPEC_TRACE_FILE=str(trace_file), LINKEDSPEC_TRACE_RESET_FILE="1",
            LINKEDSPEC_TRACE_MIRROR_STDOUT="1")
        run("inherited trace settings do not alter JSON or files", [diagnostic, "x"],
            work, ["ok"], [], env=ambient)
        malformed = work / "unclosed-action.spec"
        malformed.write_text('Top::\n -> Hit { return("unclosed")\nHit:\n /x/\n', encoding="utf-8")
        run("malformed grammar has structured compile failure", [malformed, "x"],
            work, [], error("spec_pipeline_error", stage="validate_spec", code="spec_validation_failed"),
            status=1, env=ambient)
        assert trace_file.read_bytes() == b"preserve existing trace\n"
        arity = work / "arity.spec"
        arity.write_text('Top::\n -> Hit { say() }\nHit:\n /x/\n', encoding="utf-8")
        run("typed diagnostic arity failure", [arity, "x"], work, [],
            error("runtime_diagnostic_output_error", code="helper_arity_mismatch",
                  helper_name="say", actual_arity=0, arguments_evaluated=0), status=1)
        null = work / "null.spec"
        null.write_text('Top::\n -> Hit { return(undef) }\nHit:\n /x/\n', encoding="utf-8")
        run("undefined value without runtime failure", [null, "x"], work, [None], [])
        shutil.copyfile(diagnostic, work / "--diagnostics")
        run("option terminator", ["--", "--diagnostics", "x"], work, ["ok"], [])

        # Force the real generated handler's error path after normal compilation.
        # This affects only this isolated test process, never library source.
        injection = work / "force_handler_failure.pl"
        injection.write_text('''use strict;
use warnings;
use LinkedSpec::SpecLoader ();
my $consumer = shift @ARGV;
my $load = \\&LinkedSpec::SpecLoader::load_and_compile_spec;
{
 no warnings qw(redefine once);
 local *LinkedSpec::SpecLoader::load_and_compile_spec = sub {
  my $loaded = $load->(@_);
  *LinkedRE::or = sub { die "INTEGRATION_HANDLER_FAILURE\\n" };
  return $loaded;
 };
 my $ok = do $consumer;
 die "Consumer did not complete: $@ $!\\n" unless $ok;
}
''', encoding="utf-8")

        def runtime_failure(records):
            error("runtime_error")(records)
            context = records[0]["context"]
            assert context["type"] == "runtime_handler", context
            assert context["stage"] == "rule_handler_eval", context
            assert context["rule_label"] == "Top", context
            assert "INTEGRATION_HANDLER_FAILURE" in context["detail"], context
            assert "exception" not in records[0], records

        run("nonthrowing generated handler failure", [root / "examples/integration/word.spec", "alpha"],
            work, [], runtime_failure, status=1,
            prefix=[args.perl, "-I" + str(library / "perl"), str(injection), str(consumer)])

        # Package source/runtime tools, retaining sibling specs, with no build products
        # or Git metadata. Grammar assets and the application adapter stay separate.
        app = work / "application"
        vendor = app / "vendor/linkedspec"
        vendor.mkdir(parents=True)
        for name in ("perl", "specs", "tools"):
            shutil.copytree(library / name, vendor / name)
        (app / "bin").mkdir()
        (app / "specs").mkdir()
        shutil.copyfile(consumer, app / "bin/parse_words.pl")
        shutil.copyfile(examples / "parse-words", app / "bin/parse-words")
        shutil.copyfile(root / "examples/integration/word.spec", app / "specs/word.spec")
        before = {name: snapshot(vendor / name) for name in ("perl", "specs", "tools")}
        grammar_before = snapshot(app / "specs")
        run("packaged launch outside application cwd", [app / "specs/word.spec", "alpha", "123"],
            work, [["alpha"], []], [], prefix=["bash", str(app / "bin/parse-words")])
        moved = work / "relocated é application"
        app.rename(moved)
        run("relocated launch with caller-relative grammar", ["specs/word.spec", "one two"],
            moved, [["one", "two"]], [], prefix=["bash", str(moved / "bin/parse-words")])
        run("relocated launch outside application cwd", [moved / "specs/word.spec", "Beta"],
            work, [["Beta"]], [], prefix=["bash", str(moved / "bin/parse-words")])
        vendor = moved / "vendor/linkedspec"
        assert {name: snapshot(vendor / name) for name in before} == before
        assert snapshot(moved / "specs") == grammar_before
        assert (moved / ".app-data/linkedspec").is_dir()
        assert not (vendor / "rgx").exists()
        assert all(p.stat().st_dev == root.stat().st_dev for p in moved.rglob("*"))
        checks.append("same-volume stores and unchanged packaged sources/grammars")
    assert not work.exists(), "owned verification fixtures were not removed"
    print(json.dumps({"status": "PASS", "checks": checks, "fixture_cleanup": True}))


if __name__ == "__main__":
    main()

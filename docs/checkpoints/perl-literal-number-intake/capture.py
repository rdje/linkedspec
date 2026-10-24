"""Retain the superseded candidate and compare public scalar-literal producer routes."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import context

PREFIX = "docs/checkpoints/perl-literal-number-intake/"
encode = lambda data: base64.b64encode(data).decode()


def write(name, value):
    raw = gzip.compress((json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0)
    with (ROOT / PREFIX / name).open("xb") as output:
        output.write(raw)


def main():
    assert c.load("green-inputs.json.gz")["sources"] == {path: c.read(path) for path in c.SOURCES}
    diff = subprocess.run(["git", "diff", "--cached", "--full-index", "--binary"], cwd=ROOT, capture_output=True)
    assert diff.returncode == 0
    fingerprint = hashlib.sha256(diff.stdout).hexdigest()
    assert fingerprint == "34796a33f7ff0ed40fd75eb86c9bc87392189dca913bbab14b90ce6e580a0d50"
    names = subprocess.check_output(["git", "diff", "--cached", "--name-only"], cwd=ROOT).decode().splitlines()
    index = subprocess.check_output(["git", "ls-files", "--stage", "-z"], cwd=ROOT)
    entries = {}
    for row in index.split(b"\0"):
        if row:
            meta, path = row.split(b"\t", 1)
            mode, oid, stage = meta.decode().split()
            assert stage == "0"
            if path.decode() in names:
                raw = subprocess.check_output(["git", "show", ":" + path.decode()], cwd=ROOT)
                packet = dict(mode=mode, git_oid=oid, sha256=c.sha(raw))
                if not path.endswith((b".gz", b".part")):
                    packet["base64"] = encode(raw)
                else:
                    assert c.identity(path.decode())["sha256"] == packet["sha256"]
                entries[path.decode()] = packet
    assert set(entries) == set(names)
    write("candidate-before.json.gz", dict(base=c.BASE, fingerprint=fingerprint,
        index_base64=encode(index), candidate=entries,
        actual_ci_log=c.read(".linkedspec-data/verification/signed-perl-canonical1.log"),
        ci_termination=dict(observed_tool_exit_code=143, process_group=21781,
            qualification="Coordinator deliberately terminated and joined its own canonical process group after reproducing a new scalar-kind edge. This incomplete run earns no canonical success/receipt."),
        sealed_publication={name: c.read(name) for name in (
            c.PREFIX + "publication-inputs.json.gz", c.PREFIX + "publication.json", "docs/claims/" + c.OWNER + ".json")},
        scope="Exact original129-file staged candidate, all plain source images and immutable archive identities. The binary staged diff is independently hashed; its oversized transport is not recursively copied. Accepted Git and unchanged committed-to-be immutable inputs recover the candidate."))
    plan = dict(cases=[])
    programs = {
        "assigned_float": 'items=[10,20,30]; cb={|| chosen=-1.0; return([items[chosen],chosen]) }; return(cb())',
        "returned_float": 'cb={|| return(-1.0) }; return(cb())',
        "literal_float": 'items=[10,20,30]; cb={|| return(items[-1.0]) }; return(cb())',
        "parameter_float": 'items=[10,20,30]; cb={|chosen| return([items[chosen],chosen]) }; return(cb(-1.0))',
        "assigned_integer": 'items=[10,20,30]; cb={|| chosen=-1; return([items[chosen],chosen]) }; return(cb())',
        "assigned_fractional": 'items=[10,20,30]; cb={|| chosen=-1.5; return([items[chosen],chosen]) }; return(cb())',
        "assigned_positive_float_write": 'items=[10,20,30]; cb={|| chosen=1.0; items[chosen]=99; return(items) }; return(cb())',
        "literal_positive_float_write": 'items=[10,20,30]; cb={|| items[1.0]=99; return(items) }; return(cb())',
        "assigned_string": 'items=[10,20,30]; cb={|| chosen="-1"; return([items[chosen],chosen]) }; return(cb())',
        "literal_false": 'cb={|| return(false) }; return(cb())',
        "literal_true": 'cb={|| return(true) }; return(cb())',
        "boolean_array": 'cb={|| return([false,true]) }; return(cb())',
        "compiled_boolean": 'cb={|chosen| return(chosen) }; return(cb(false))',
        "assigned_boolean_write": 'items=[10,20,30]; cb={|| chosen=false; items[chosen]=99; return(items) }; return(cb())',
        "literal_boolean_write": 'items=[10,20,30]; cb={|| items[false]=99; return(items) }; return(cb())',
        "null_control": 'cb={|| chosen=undef; return(chosen) }; return(cb())',
    }
    for name, body in programs.items():
        plan["cases"].append(dict(id=name, source="Top: /x/\n I { " + body + " }\n", input="x"))
    epoch = context.snapshot()
    write("inputs.json.gz", dict(context=epoch, producer=c.read(PREFIX + "capture.py"),
        worker=c.read(c.PREFIX + "perl_probe.pl"), plan=plan,
        current_sources={path: c.read(path) for path in c.SOURCES},
        accepted_sources={path: dict(base64=encode(subprocess.check_output(
            ["git", "show", c.BASE + ":" + path], cwd=ROOT))) for path in c.SOURCES[:2]},
        initial_diagnostic=c.read(".linkedspec-data/verification/signed-perl-float-origin-probe.json"),
        scope="Preliminary ownership intake for22, separate from the sealed finite signed publication. Fresh current and accepted-runtime-shadow processes use the same exact sources and probe. No producer repair or admission here."))
    observations = {}
    for route in ("descriptor", "native", "generated"):
        observations["current/" + route] = c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
            c.PREFIX + "perl_probe.pl", route], input=json.dumps(plan).encode())
    with tempfile.TemporaryDirectory(prefix="literal-kind-accepted-", dir=os.environ["TMPDIR"]) as folder:
        shadow = Path(folder)
        assert shadow.stat().st_dev == ROOT.stat().st_dev
        for path in c.SOURCES[:2]:
            destination = shadow / Path(path).relative_to("perl")
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=ROOT))
        for route in ("native", "generated"):
            observations["accepted/" + route] = c.run(["bash", "tools/project_data_run.sh", "perl",
                "-I" + str(shadow), "-Iperl", "-MLinkedSpec::CodeblockRuntime",
                c.PREFIX + "perl_probe.pl", route], input=json.dumps(plan).encode())
    write("runs.json.gz", dict(observations=observations, inputs_unchanged=c.unchanged(epoch["inputs"])))
    assert c.unchanged(epoch["inputs"])
    for name, run in observations.items():
        assert run["returncode"] == 0, name
        value = json.loads(c.decode(run["stdout_base64"]))
        print(name, json.dumps([{key: row[key] for key in ("id", "value", "scalar_flags", "runtime_detail", "generated_cause")}
            for row in value["rows"]], sort_keys=True), flush=True)


if __name__ == "__main__":
    main()

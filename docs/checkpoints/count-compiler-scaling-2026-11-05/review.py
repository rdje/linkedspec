"""Read-only historical review of the bounded Count compiler-path controls."""
import gzip
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = "e7b9197ae006e85ea5a306573f257d7933c04c12"
IDS = {"original_receiver", "free_twin", "receiver_no_copy", "minimal_block_receiver"}


def text(path):
    path = HERE / path
    return (gzip.decompress(path.read_bytes()) if path.suffix == ".gz" else path.read_bytes()).decode()


def git(path):
    return subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT)


def stream(path):
    raw = text(path)
    decoder = json.JSONDecoder()
    return [decoder.raw_decode(raw[m.start():])[0] for m in re.finditer(r"(?m)^\{", raw)]


def bodies(path):
    result = {}
    metadata = {}
    names = set()
    with tarfile.open(HERE / path) as archive:
        for member in archive.getmembers():
            assert str(PurePosixPath(member.name)) not in names
            names.add(str(PurePosixPath(member.name)))
            if member.isdir():
                continue
            assert member.isfile() and member.name not in result
            result[member.name] = archive.extractfile(member).read()
    for name in list(result):
        item = PurePosixPath(name)
        if item.name.startswith("._"):
            paired = str(item.with_name(item.name[2:]))
            # BSD tar adds AppleDouble xattrs; these are not Perl input files.
            assert result[name].startswith(bytes.fromhex("0005160700020000"))
            assert paired in names and not PurePosixPath(paired).name.startswith("._")
            metadata[name] = result.pop(name)
    if metadata:
        print("QUALIFIED AppleDouble packaging metadata:", path, len(metadata))
    return result


stages = {label + "-" + phase for label in IDS for phase in ("parse_only", "substitution", "native")}
cold = stream("current/results.stream.json")
warm = stream("warm/results.stream.json")
assert {r["id"] for r in cold} == {r["id"] for r in warm} == stages
assert len(cold) == len(warm) == len(stages)
assert all(r["completed"] == int(r["id"].endswith("-substitution")) for r in cold)
assert all(r["completed"] == 1 and r["status"] == 0 for r in warm)
assert text("warm/results.stream.json").startswith("WARM_BEGIN\nWARM_READY\n")
assert text("warm/results.stream.json").endswith("WORKER_STATUS 0\n")
assert json.loads(text("current/cases.json")) == json.loads(text("warm/cases.json"))
for label in IDS:
    raw = text("warm/" + label + "-native.stdout.gz")
    value = json.JSONDecoder().raw_decode(raw.split("VALUE ", 1)[1])[0]
    assert value == {"error": None, "value": 2 if label == "minimal_block_receiver" else [None, "S"]}
    assert not text("warm/" + label + "-native.stderr.gz")
print("PASS: cold starts qualified; warmed public stages complete and return the authored values")

archive = bodies("warm/before-first-run.tar.gz")
for path, body in archive.items():
    if path.startswith("perl/") or path == "specs/spec.spec":
        assert body == git(path), path
    elif path.endswith("/probe.pl"):
        assert body == (HERE / "current/producer.pl").read_bytes()
original = archive["perl/LinkedSpec/ActionIR/MethodLowering.pm"].decode()
old = "my $guarded_copy_chain = ($ordinary_has_key_result_chain || $ordinary_contains_result_chain\n    || $ordinary_index_result_chain || $ordinary_count_result_chain)"
assert original.count(old) == 1
mutant = (HERE / "mutant-MethodLowering.pm").read_text()
assert mutant == original.replace(old, old.replace(" || $ordinary_count_result_chain", ""))
for phase in ("profile-current", "profile-mutant", "profile-paths"):
    rows = stream(phase + "/results.jsonl")
    assert {r["id"] for r in rows} == IDS and len(rows) == len(IDS)
    for row in rows:
        stopped = phase != "profile-current" and row["id"] in ("original_receiver", "free_twin")
        assert row["completed"] == int(not stopped)
        assert row["status"] == (None if stopped else 0)
        owner = text(phase + "/" + row["id"] + ".stdout.gz").splitlines()[0]
        assert owner.startswith("OWNER ")
        assert owner.endswith("/perl/LinkedSpec/ActionIR/MethodLowering.pm") if phase == "profile-current" else owner.endswith("/mutant-MethodLowering.pm")
for label in ("original_receiver", "free_twin"):
    entries = [json.loads(line[len("ENTER "):]) for line in text("profile-paths/" + label + ".stdout.gz").splitlines() if line.startswith("ENTER ")]
    assert entries and entries[-1]["compat"] == 1
    assert entries[-1]["source"].startswith("do {") and "my $__ls_copy_value" in entries[-1]["source"]
paths = bodies("profile-paths/before-first-run.tar.gz")
assert paths["docs/checkpoints/count-compiler-scaling-2026-11-05/mutant-MethodLowering.pm"] == mutant.encode()
assert paths["docs/checkpoints/count-compiler-scaling-2026-11-05/profile.pl"] == (HERE / "profile-paths/producer.pl").read_bytes()
assert paths["docs/checkpoints/count-compiler-scaling-2026-11-05/warm/cases.json"] == (HERE / "warm/cases.json").read_bytes()
print("PASS: single-condition counterfactual restores the bounded stops and generated-Perl compatibility re-entry")

normal = bodies("normal/before-first-run.tar.gz")
rows = json.loads(normal["tests/fixtures/count_copy_source_cases.json"])
prior = json.loads(git("tests/fixtures/count_copy_source_cases.json"))
historical = json.loads(git("docs/checkpoints/count-copy-perl-2026-11-05/before/cases.json"))
long = next(row for row in historical if row["id"] == "receiver_repeated_copy_rejection")
assert next(row for row in json.loads(text("warm/cases.json")) if row["id"] == "original_receiver")["source"] == long["source"]
assert rows[:-1] == prior and rows[-1] == dict(long, id="long_receiver_repeated_copy_rejection")
assert normal["t/count_copy_source_composition.t"] == git("t/count_copy_source_composition.t")
tap = text("normal/stdout.tap.gz")
assert re.findall(r"(?m)^ok \d+ - (.+)$", tap) == ["rejection_through_copy", "legitimate_null_through_copy", "count_copy_needed_source_error", "long_receiver_repeated_copy_rejection"]
assert "not ok" not in tap and tap.endswith("1..4\n") and text("normal/exit.txt").strip() == "0"
modules = bodies("normal/emitted.tar.gz")
assert set(modules) == {str(i) + ".pl" for i in range(1, 5)} and all(modules.values())
print("PASS: original long source restored unchanged; four selected native/fresh groups and preserved first19 inputs")

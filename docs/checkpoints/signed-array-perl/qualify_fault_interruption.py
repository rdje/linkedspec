"""Preserve a verification-epoch interruption and prepare a distinct complete rerun."""
import common as c

epoch = c.load("restore-nested-reader-inputs.json.gz")["context"]
changed = {path: dict(before=item, after=c.identity(path)) for path, item in epoch["inputs"].items()
    if c.identity(path) != item}
assert set(changed) == {c.PREFIX + "review.py"}, changed
assert not c.load("restore-nested-reader-runs.json.gz")["inputs_unchanged"]
assert c.load("fault-controller-inputs.json.gz")["sources"] == {
    path: c.read(path) for path in c.SOURCES[:2]}
c.write_new("fault-interruption.json.gz", dict(
    producer=c.read(c.PREFIX + "qualify_fault_interruption.py"),
    actual_log=c.read(".linkedspec-data/verification/signed-perl-faults.log"),
    sole_change=changed,
    reviewer_before=epoch["overrides"][c.PREFIX + "review.py"],
    reviewer_after=c.read(c.PREFIX + "review.py"),
    runtime_restored=True,
    qualification="The coordinator edited the new read-only reviewer while a later restoration epoch included it. The conservative all-input unchanged check correctly stops the actor. Both production sources restore in finally. Original partial observations stay immutable and earn no completed fault-suite credit; a distinct entire eight-variant run follows with no concurrent edits."))
raw = c.source(c.PREFIX + "faults.py").read_text()
raw = raw.replace('"fault-controller-inputs.json.gz"', '"verified-fault-controller-inputs.json.gz"')
raw = raw.replace('observe("fault-" + name', 'observe("verified-fault-" + name')
raw = raw.replace('observe("restore-" + name', 'observe("verified-restore-" + name')
raw = raw.replace('"faults.json.gz"', '"verified-faults.json.gz"')
with (c.ROOT / c.PREFIX / "faults_verified.py").open("x") as output:
    output.write(raw)
print("Partial run qualified, production exactly restored; distinct full actor prepared.")

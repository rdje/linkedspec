"""One-shot recovery of the original validator import and bounded republication."""
import base64
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c

ADMISSION = "docs/checkpoints/signed-array-contract-admission/"
ACTOR = ADMISSION + "repair_import_epoch.py"
HELPER = ADMISSION + "import_epoch.py"
READER = c.PREFIX + "review.py"
CLAIM = "docs/claims/" + c.OWNER + ".json"
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
assert not (c.ROOT / c.PREFIX / "validator-import-before.json.gz").exists()
assert not c.decode(c.run(["git", "diff", "--name-only"])["stdout_base64"])
actor = c.read(ACTOR)
helper = c.read(HELPER)
baseline = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert baseline["returncode"] == 0 and not c.decode(baseline["stderr_base64"])
manifest = c.load("publication-inputs.json.gz")
assert len(manifest["inputs"]) == 40
inputs = {path: c.read(path) for path in manifest["inputs"]}
for path, packet in inputs.items():
    assert all(packet[key] == manifest["inputs"][path][key] for key in ("sha256", "mode"))
outputs = {path: c.read(path) for path in [
    c.PREFIX + "publication-inputs.json.gz", c.PREFIX + "publication.json", CLAIM]}
controls = c.load("artifact-controls-inputs.json.gz")
historical = c.load("artifact-controls.json.gz")
spec = importlib.util.spec_from_file_location("validator_epoch_repair", c.ROOT / HELPER)
epoch = importlib.util.module_from_spec(spec)
spec.loader.exec_module(epoch)
recovered = epoch.recover_reader(inputs[READER])
expected = controls["cases"]["scope"]["model_producer"]["good"]["actual"][READER]
assert c.sha(recovered) == expected["sha256"]
assert inputs[READER]["sha256"] != expected["sha256"]
recovered_packet = dict(base64=c.encode(recovered), sha256=c.sha(recovered), mode=expected["mode"])
bundle = dict(format=1, actual_import=recovered_packet, published_reader=inputs[READER],
    other_sources={path: inputs[path] for path in epoch.DEPENDENCIES},
    captured_control_inputs=inputs[c.PREFIX + "artifact-controls-inputs.json.gz"],
    scope="Original validator-import source, recovered exactly against its independently captured filesystem identity. The later published reader is a distinct epoch. No original observations, targets or capture producers are relabeled.")
epoch.verify_sources(bundle, controls)
diff = c.run(["git", "diff", "--cached", "--binary", "--full-index"])
before = dict(base=c.BASE, inputs=inputs, outputs=outputs, baseline=baseline,
    staged_binary_diff=diff, staged_diff_sha256=c.sha(c.decode(diff["stdout_base64"])),
    actor=actor, helper=helper, recovery=dict(actual_import=recovered_packet, published_reader=inputs[READER]),
    continuity={path: c.read(path) for path in (TREE, "MEMORY.md", "CHANGES.md", "DEVELOPMENT_NOTES.md")},
    interrupted_ci="Session11273/owned group54250 terminated143 after all10 doctrines and partial runtime checks; no completed canonical PASS or receipt.",
    scope="Whole unpublished40-input publication/claim/manifest and all40 whole inputs precede changes. This repair closes a recorded imported-source epoch that the later retained reader alone did not explicitly preserve.")
# Copy the interrupted public build log as opaque bytes; do not inspect dependency implementation.
log_name = ADMISSION + "canonical3-interrupted.log.gz"
digest = hashlib.sha256()
size = 0
with c.source(".linkedspec-data/verification/signed-contract-canonical3.log").open("rb") as source:
    with (c.ROOT / log_name).open("xb") as target:
        with gzip.GzipFile(filename="", mode="wb", fileobj=target, mtime=0) as compressed:
            for block in iter(lambda: source.read(1024 * 1024), b""):
                compressed.write(block)
                digest.update(block)
                size += len(block)
before["interrupted_log"] = dict(path=log_name, raw_sha256=digest.hexdigest(), raw_bytes=size,
    compressed=c.identity(log_name))
raw_before = gzip.compress((json.dumps(before, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0)
with (c.ROOT / ADMISSION / "import-epoch-before.json.gz").open("xb") as output:
    output.write(raw_before)

text = Path(TREE).read_text()
start = text.index("- ID: " + chr(96) + c.OWNER + chr(96))
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("Status: " + chr(96) + "completed" + chr(96) + " / neutral target only",
    "Status: " + chr(96) + "active" + chr(96) + " / validator import custody repair", 1)
node += "  Owned custody issue / fix now before landing: artifact-controls-inputs records review.py SHA ea8c35069e44e70b25ca2485a61a75ff311fc46930eca272c96da0d8b1ed567d, but the later retained reader is0cdbc550a60c153ee0128d81d64aef508b31b97c0cd9f95d3b7106c1362f6240. The publisher imports review during the original validator runs. Removing the subsequently added artifact_detail helper/call recovers the exact recorded earlier bytes. Retain that epoch, all imported source modules and the actual recovery/replay producers; reject the later epoch by identity even when its unused added functions leave all control outcomes identical. Whole original40-input publication and actual readonly0 precede changes; canonical attempt3 is deliberately terminated143 without final PASS credit. No authority/model/runtime change or retargeting of old observations. This current leaf owns closure before the next staged canonical run.\n\n"
Path(TREE).write_text(text[:start] + node + text[end:])
Path("MEMORY.md").write_text("# MEMORY\n\n- activation_commit: " + chr(96) + c.BASE + chr(96) + " — clean neutral17.1 base; derive HEAD from Git.\n- latest_completed_leaf: " + chr(96) + "TYPE-REFERENCE-BOOK.1.2.17.8" + chr(96) + " —9dd5e3555; CLI fix accepted.\n- active_work_unit: " + chr(96) + c.OWNER + chr(96) + "; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.\n- next_action: Close validator imported-reader source custody, retain exact old source and all bounded replay inputs, republish without retargeting observations, then exact staged canonical CI and commit17.1.\n- in_flight_uncommitted: Neutral17.1 and source-custody repair; attempt3 stopped143, no background CI. Whole unpublished40-input state/actual readonly0 precedes bound changes.\n- proof: docs/checkpoints/signed-array-contract-admission/import-epoch-before.json.gz; old observations and authority bytes remain unchanged. Never rerun historical writers.\n- steering: Negative integer i selects L+i only in an existing array position. Backend17.2–6/admission17.7 follow this clean commit; no push until PNT exhausted.\n- limits: Other repositories/submodules read-only black boxes; all project data on-volume.\n")

def copy_packet(path, packet):
    raw = c.decode(packet["base64"])
    assert c.sha(raw) == packet["sha256"]
    with (c.ROOT / path).open("xb") as output:
        output.write(raw)
    (c.ROOT / path).chmod(packet["mode"])
    assert c.read(path) == packet

copy_packet(c.PREFIX + "import_epoch.py", helper)
copy_packet(c.PREFIX + "repair_import_epoch.py", actor)
with (c.ROOT / c.PREFIX / "validator-import-before.json.gz").open("xb") as output:
    output.write(raw_before)
c.write_new("validator-import-sources.json.gz", bundle)
for destination, source in (
    ("publication1-inputs.json.gz", c.PREFIX + "publication-inputs.json.gz"),
    ("publication1.json", c.PREFIX + "publication.json"),
    ("publication1-claim.json", CLAIM),
):
    copy_packet(c.PREFIX + destination, outputs[source])
identity = {}
for name, variant in (("actual_import", "actual_import"), ("published_reader", "published_reader"), ("restored", "actual_import")):
    run = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "import_epoch.py", "--variant", variant])
    assert run["returncode"] == (1 if name == "published_reader" else 0)
    assert not c.decode(run["stderr_base64"])
    identity[name] = run
replays = dict(epochs={}, identity_checks=identity, runner_base64=controls["runner_base64"])
for variant in ("actual_import", "published_reader"):
    source_packets = {**bundle["other_sources"], READER: bundle[variant]}
    with tempfile.TemporaryDirectory(prefix="validator-import-replay-", dir=os.environ["TMPDIR"]) as directory:
        root = Path(directory)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path, packet in source_packets.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(packet["base64"]))
            target.chmod(packet["mode"])
        (root / "runner.py").write_bytes(c.decode(controls["runner_base64"]))
        runs = {}
        for category, cases in historical.items():
            runs[category] = {}
            for name, phases in cases.items():
                runs[category][name] = {}
                for phase, original in phases.items():
                    subject = root / "publisher.py"
                    subject.write_bytes(c.decode(original["source_base64"]))
                    subject.chmod(original["mode"])
                    (root / "inputs.json").write_text(json.dumps(original["payload"], sort_keys=True))
                    command = ["python3", "-B", "runner.py", "publisher.py", "inputs.json", category]
                    result = subprocess.run(command, cwd=root, capture_output=True)
                    run = dict(command=command, returncode=result.returncode,
                        stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
                    assert all(run[key] == original["run"][key] for key in ("returncode", "stdout_base64", "stderr_base64"))
                    runs[category][name][phase] = dict(run=run, payload=original["payload"],
                        subject_source_base64=original["source_base64"], subject_mode=subject.stat().st_mode & 0o7777)
        replays["epochs"][variant] = dict(runs=runs,
            copied_sources={path: {key: packet[key] for key in ("sha256", "mode")} for path, packet in source_packets.items()})
verified = epoch.verify_replays(bundle, replays, historical)
c.write_new("validator-import-replays.json.gz", replays)

# Extend the semantic reader without changing the original publisher/validators.
reader = c.decode(inputs[READER]["base64"])
needle = b'    supplied = c.load("artifact-controls-inputs.json.gz")\n'
addition = b'''    import import_epoch
    source_bundle = c.load("validator-import-sources.json.gz")
    import_epoch.verify_sources(source_bundle, supplied)
    custody = import_epoch.verify_replays(source_bundle, c.load("validator-import-replays.json.gz"), c.load("artifact-controls.json.gz"))
    required = {c.PREFIX + name for name in ("import_epoch.py", "repair_import_epoch.py",
        "validator-import-before.json.gz", "validator-import-sources.json.gz", "validator-import-replays.json.gz",
        "publication1-inputs.json.gz", "publication1.json", "publication1-claim.json")}
    assert required <= set(publish.input_paths()), "validator import required inputs"
'''
assert reader.count(needle) == 1
reader = reader.replace(needle, needle + addition, 1)
marker = b"\n\ndef check():\n"
assert reader.count(marker) == 1
reader = reader.replace(marker, b"\n    return custody\n" + marker, 1)
assert reader.count(b"    artifact_detail()\n") == 1
reader = reader.replace(b"    artifact_detail()\n", b"    custody = artifact_detail()\n", 1)
reader = reader.replace(b"        prior_git_images=len(images),\n",
    b"        prior_git_images=len(images), validator_import=custody,\n", 1)
Path(READER).write_bytes(reader)
Path(c.PREFIX + "README.md").write_text(c.decode(inputs[c.PREFIX + "README.md"]["base64"]).decode()
    + "\n## Validator import custody\n\nThe original validator runs imported an earlier review.py. Its filesystem SHA\nwas recorded, but the first publication retained the later reader. The exact\nolder source is recovered by removing the subsequently added artifact_detail\nhelper/call and checking the recorded SHA; both complete epochs are retained.\nThe default reader now requires and verifies that source bundle and40 actual\nisolated replay commands. Both module epochs reproduce the20 original validator\noutcomes, while the identity oracle rejects the later epoch and restores GREEN\nfor the original. Equal outcomes do not identify the actual imported source.\n\npublication1 copies and validator-import-before preserve the whole original\nunpublished40-input state and actual readonly0 before changes. Only reader and\nREADME inputs change; original cases, targets, functional/book/model/source-fault\nand validator observations remain unchanged. Added source packets, producers and\nreplays close the import epoch without backend admission. The publisher itself\nis unchanged. Never rerun repair_import_epoch.py; import_epoch.py is read-only.\n")
assert all(c.read(path) == packet for path, packet in inputs.items() if path not in (READER, c.PREFIX + "README.md"))
assert c.read(ACTOR) == actor and c.read(HELPER) == helper
for path, packet in outputs.items():
    assert c.read(path) == packet
for path in outputs:
    c.source(path).unlink()
publication = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py", "--capture"])
assert publication["returncode"] == 0, c.decode(publication["stderr_base64"]).decode()
readonly = c.run(["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py"])
assert readonly["returncode"] == 0, c.decode(readonly["stderr_base64"]).decode()
with (c.ROOT / ADMISSION / "import-epoch-result.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(dict(verified=verified, publication=publication, readonly=readonly,
        helper=c.read(c.PREFIX + "import_epoch.py"), producer=c.read(c.PREFIX + "repair_import_epoch.py"),
        scope="Source custody closure only. Original40-input state and every original observation remain preserved; final staged canonical CI still required."), sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
print("Validator import source retained;40 replay outcomes identical; wrong epoch RED; publication recaptured and read-only GREEN")

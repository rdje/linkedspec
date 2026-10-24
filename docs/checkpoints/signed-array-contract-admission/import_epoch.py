"""Read-only identity and replay checks for the historical validator imports."""
import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = "docs/checkpoints/signed-array-contract/"
READER = PREFIX + "review.py"
DEPENDENCIES = {PREFIX + name for name in ("common.py", "book.py", "publish.py")}


def packet_bytes(packet):
    raw = base64.b64decode(packet["base64"], validate=True)
    if hashlib.sha256(raw).hexdigest() != packet["sha256"]:
        raise ValueError("source packet bytes")
    return raw


def recover_reader(published):
    raw = packet_bytes(published)
    begin = raw.index(b"def artifact_detail():\n")
    end = raw.index(b"def check():\n", begin)
    marker = b"    artifact_detail()\n"
    if raw.count(marker) != 1:
        raise ValueError("published reader call marker")
    return (raw[:begin] + raw[end:]).replace(marker, b"", 1)


def verify_sources(bundle, ledger, variant="actual_import"):
    if bundle["format"] != 1 or variant not in ("actual_import", "published_reader"):
        raise ValueError("import source format/variant")
    captured = packet_bytes(bundle["captured_control_inputs"])
    if json.loads(gzip.decompress(captured)) != ledger:
        raise ValueError("captured control ledger")
    population = ledger["cases"]["scope"]["model_producer"]["good"]["actual"]
    expected = population[READER]
    recovered = recover_reader(bundle["published_reader"])
    if recovered != packet_bytes(bundle["actual_import"]):
        raise ValueError("reader reconstruction")
    selected = bundle[variant]
    packet_bytes(selected)
    if any(selected[key] != expected[key] for key in ("sha256", "mode")):
        raise ValueError("validator import source epoch mismatch")
    if set(bundle["other_sources"]) != DEPENDENCIES:
        raise ValueError("import dependency population")
    for path, packet in bundle["other_sources"].items():
        packet_bytes(packet)
        if any(packet[key] != population[path][key] for key in ("sha256", "mode")):
            raise ValueError("import dependency identity: " + path)
    return dict(source_files=4, actual_reader_sha256=bundle["actual_import"]["sha256"],
        published_reader_sha256=bundle["published_reader"]["sha256"])


def verify_replays(bundle, data, original):
    if set(data["epochs"]) != {"actual_import", "published_reader"}:
        raise ValueError("replay epoch population")
    count = 0
    for epoch, values in data["epochs"].items():
        expected_sources = {**bundle["other_sources"], READER: bundle[epoch]}
        identities = {path: {key: packet[key] for key in ("sha256", "mode")}
            for path, packet in expected_sources.items()}
        if values["copied_sources"] != identities:
            raise ValueError("replay import inputs")
        if set(values["runs"]) != set(original):
            raise ValueError("replay category population")
        for category, cases in original.items():
            if set(values["runs"][category]) != set(cases):
                raise ValueError("replay case population")
            for name, phases in cases.items():
                actual = values["runs"][category][name]
                if set(actual) != set(phases):
                    raise ValueError("replay phase population")
                for phase, historical in phases.items():
                    row = actual[phase]
                    if row["subject_source_base64"] != historical["source_base64"] or row["payload"] != historical["payload"]:
                        raise ValueError("replay subject/payload")
                    if row["subject_mode"] != historical["mode"]:
                        raise ValueError("replay subject mode")
                    command = row["run"]["command"]
                    if command != ["python3", "-B", "runner.py", "publisher.py", "inputs.json", category]:
                        raise ValueError("replay command")
                    for key in ("returncode", "stdout_base64", "stderr_base64"):
                        if row["run"][key] != historical["run"][key]:
                            raise ValueError("replay outcome: " + epoch + "/" + category + "/" + name + "/" + phase)
                    count += 1
    if count != 40:
        raise ValueError("replay outcome count")
    identity = data["identity_checks"]
    if set(identity) != {"actual_import", "published_reader", "restored"}:
        raise ValueError("identity control population")
    for name, row in identity.items():
        code = 1 if name == "published_reader" else 0
        if row["returncode"] != code or base64.b64decode(row["stderr_base64"]):
            raise ValueError("identity control outcome")
        observed = json.loads(base64.b64decode(row["stdout_base64"]))
        if code:
            if observed != dict(accepted=False, reason="validator import source epoch mismatch"):
                raise ValueError("identity control reason")
        elif not observed["accepted"]:
            raise ValueError("identity restoration")
    return dict(replay_rows=count, source_identity_denials=1,
        actual_reader_sha256=bundle["actual_import"]["sha256"])


def load(name):
    path = ROOT / PREFIX / name
    return json.loads(gzip.decompress(path.read_bytes()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--variant", choices=("actual_import", "published_reader"), default="actual_import")
    args = parser.parse_args()
    bundle = load("validator-import-sources.json.gz")
    ledger = load("artifact-controls-inputs.json.gz")
    try:
        result = verify_sources(bundle, ledger, args.variant)
    except ValueError as error:
        print(json.dumps(dict(accepted=False, reason=str(error)), sort_keys=True))
        raise SystemExit(1)
    print(json.dumps(dict(accepted=True, **result), sort_keys=True))


if __name__ == "__main__":
    main()

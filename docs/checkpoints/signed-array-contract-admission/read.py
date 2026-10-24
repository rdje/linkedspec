"""Read-only independent review of admission and source custody."""
import copy
import gzip
import json
import re
import subprocess
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c

PREFIX = "docs/checkpoints/signed-array-contract-admission/"
OLD = "docs/knowledge/write-vivification-neutral-contract.md"
NEW = "docs/knowledge/signed-array-selector-neutral-contract.md"
POLICY_CARD = "docs/knowledge/readme-routing-pressure-closure-plan.md"


def load(name):
    return json.loads(gzip.decompress((c.ROOT / PREFIX / name).read_bytes()))


def raw(packet):
    value = c.decode(packet["base64"])
    assert c.sha(value) == packet["sha256"]
    return value


def questions(packet):
    text = raw(packet).decode().split("\ndate:", 1)[0]
    return set(re.findall(r"^  - .*", text, flags=re.M))


def git_cards():
    records = {}
    for entry in subprocess.check_output(["git", "ls-tree", "-rz", c.BASE, "docs/knowledge"], cwd=c.ROOT).split(b"\0"):
        if entry:
            meta, name = entry.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            path = name.decode()
            if path.endswith(".md") and path.count("/") == 2:
                assert kind == "blob" and mode in ("100644", "100755")
                records[path] = (mode, oid)
    process = subprocess.run(["git", "cat-file", "--batch"], cwd=c.ROOT,
        input="".join(oid + "\n" for mode, oid in records.values()).encode(), capture_output=True)
    assert process.returncode == 0 and not process.stderr
    cursor = 0
    values = {}
    for path, (mode, oid) in records.items():
        end = process.stdout.index(b"\n", cursor)
        actual, kind, length = process.stdout[cursor:end].decode().split()
        assert actual == oid and kind == "blob"
        start = end + 1
        value = process.stdout[start:start + int(length)]
        cursor = start + int(length) + 1
        assert process.stdout[cursor - 1:cursor] == b"\n"
        values[path] = value
    assert cursor == len(process.stdout)
    return values


def validate_knowledge(before, after, accepted):
    assert before["base"] == c.BASE
    assert set(before["census"]) == set(accepted) | {NEW}
    assert set(after["census"]) == set(accepted)
    assert len(before["census"]) == 1351 and len(after["census"]) == 1350
    assert before["gate"]["returncode"] == 1 and after["gate"]["returncode"] == 0
    channels = c.decode(before["gate"]["stdout_base64"]) + c.decode(before["gate"]["stderr_base64"])
    assert b"knowledge_cards exceeds control: files 1351/1350" in channels
    for path, item in before["census"].items():
        value = raw(before["inputs"][NEW]) if path == NEW else accepted[path]
        assert item["sha256"] == c.sha(value)
        assert item["bytes"] == len(value) and item["lines"] == len(value.splitlines())
    assert accepted[OLD] == raw(before["inputs"][OLD])
    assert accepted[POLICY_CARD] == raw(before["inputs"][POLICY_CARD])
    for path, item in after["census"].items():
        if path == OLD:
            value = raw(after["card"])
        elif path == POLICY_CARD:
            value = raw(after["policy_card"])
        else:
            value = accepted[path]
            assert item == before["census"][path]
        assert item["sha256"] == c.sha(value)
        assert item["bytes"] == len(value) and item["lines"] == len(value.splitlines())
    total = sum(item["bytes"] for item in after["census"].values())
    assert total == 8384703
    assert questions(before["inputs"][OLD]) | questions(before["inputs"][NEW]) == questions(after["card"])
    assert questions(before["inputs"][POLICY_CARD]) <= questions(after["policy_card"])
    retired = after["retired_header_rows"]
    assert len(retired) == 7
    assert all(line.encode() in accepted[OLD] and line.encode() not in raw(after["card"]) for line in retired)
    registry = raw(before["inputs"]["doctrine/readme_stability/routes.jsonl"])
    assert registry == raw(after["registry"])
    surface = next(json.loads(line) for line in registry.splitlines() if json.loads(line).get("id") == "knowledge_cards")
    assert surface["members"] == ["docs/knowledge/*.md"]
    assert surface["limits"]["max_files"] == 1350 and surface["limits"]["max_total_bytes"] == 8388608
    assert total <= surface["limits"]["max_total_bytes"]
    return total


def main():
    first, repaired = load("before.json.gz"), load("result.json.gz")
    assert first["base"] == c.BASE
    assert first["direct_gate"]["returncode"] == 1 and repaired["direct_gate"]["returncode"] == 0
    original_task = raw(first["task"])
    repaired_task = raw(repaired["task"])
    assert b"**LOCKSTEP** \xe2\x80\x94 Explicit pending book" in original_task
    assert b"**LOCKSTEP** \xe2\x80\x94 Explicit target-only book" in repaired_task
    rule = raw(first["inputs"]["scripts/check_diagnosis_evidence.sh"])
    assert b"<[^>]+>|TODO|TBD|pending" in rule
    assert b"literal " + bytes([96]) + b"pending" + bytes([96]) in raw(first["inputs"]["docs/knowledge/task-acceptance-evidence-gate-boundary.md"])
    for value in (first, load("knowledge-before.json.gz")):
        assert value["staged_binary_diff"]["returncode"] == 0
        assert c.sha(c.decode(value["staged_binary_diff"]["stdout_base64"])) == value["staged_diff_sha256"]
    before, after = load("knowledge-before.json.gz"), load("knowledge-result.json.gz")
    accepted = git_cards()
    total = validate_knowledge(before, after, accepted)
    generation = load("knowledge-generation.json.gz")
    assert generation["generator"]["returncode"] == 0
    assert not c.decode(generation["generator"]["stdout_base64"])
    assert c.decode(generation["generator"]["stderr_base64"]) == b"knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10509 question keys)\n"
    assert b'"$nq" >&2' in raw(generation["generator_source"])
    assert b'assert generated["returncode"] == 0 and not c.decode(generated["stderr_base64"])' in raw(generation["prior_actor"])
    # The later source-custody repair preserves the complete unpublished state.
    import import_epoch
    custody_before = c.load("validator-import-before.json.gz")
    assert custody_before["base"] == c.BASE and len(custody_before["inputs"]) == 40
    assert custody_before["baseline"]["returncode"] == 0
    old_manifest_path = c.PREFIX + "publication-inputs.json.gz"
    old_manifest = json.loads(gzip.decompress(raw(custody_before["outputs"][old_manifest_path])))
    assert set(old_manifest["inputs"]) == set(custody_before["inputs"])
    for path, packet in custody_before["inputs"].items():
        raw(packet)
        assert all(packet[key] == old_manifest["inputs"][path][key] for key in ("sha256", "mode"))
        if path not in (c.PREFIX + "review.py", c.PREFIX + "README.md"):
            assert c.read(path) == packet
    for alias, original in (
        ("publication1-inputs.json.gz", old_manifest_path),
        ("publication1.json", c.PREFIX + "publication.json"),
        ("publication1-claim.json", "docs/claims/" + c.OWNER + ".json"),
    ):
        assert c.read(c.PREFIX + alias) == custody_before["outputs"][original]
    source_bundle = c.load("validator-import-sources.json.gz")
    assert source_bundle["published_reader"] == custody_before["inputs"][c.PREFIX + "review.py"]
    source_identity = import_epoch.verify_sources(source_bundle, c.load("artifact-controls-inputs.json.gz"))
    replay_identity = import_epoch.verify_replays(source_bundle, c.load("validator-import-replays.json.gz"), c.load("artifact-controls.json.gz"))
    assert source_identity["source_files"] == 4 and replay_identity["replay_rows"] == 40
    for value, key in ((first, "prior_neutral_readonly"), (repaired, "neutral_readonly"),
                       (before, "neutral_readonly"), (after, "neutral_readonly")):
        assert value[key]["returncode"] == 0
    # Distinguish a jointly omitted README and a mislabeled successful-before gate.
    denials = []
    for name in ("omit_readme", "relabel_before_gate"):
        bad_before, bad_after = copy.deepcopy(before), copy.deepcopy(after)
        if name == "omit_readme":
            del bad_before["census"]["docs/knowledge/README.md"]
            del bad_after["census"]["docs/knowledge/README.md"]
        else:
            bad_before["gate"]["returncode"] = 0
        try:
            validate_knowledge(bad_before, bad_after, accepted)
        except AssertionError:
            denials.append(name)
        else:
            raise AssertionError("reader control admitted: " + name)
    print(json.dumps(dict(accepted_git_cards=len(accepted), before_files=1351, contained_files=1350,
        contained_epoch_bytes=total, lookup_questions_preserved=True, reader_denials=denials,
        validator_import=replay_identity,
        limits="Dated admission metadata; original generation channels are unavailable and explicitly uncredited. Interrupted canonical attempts provide no complete CI receipt. Final staged canonical gate remains separate."), sort_keys=True))


if __name__ == "__main__":
    main()

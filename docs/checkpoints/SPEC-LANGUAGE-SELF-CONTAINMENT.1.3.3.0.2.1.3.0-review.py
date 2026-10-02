"""Review the captured public controls; never run an archived command."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess

BASE = "e63a20c635ea74981e7476107750fbb1410a1be0"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0"
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / ".linkedspec-data/scratch/selfcontain13302130"
FAILED = {"xy", "rest-y", "ending-q", "xy-restored"}
EXPECTED_IDS = {"xy", "left-right", "xz", "y-first", "rest-y", "ending-q",
                "xy-intervention", "xy-restored"}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def review(native, fresh):
    assert {r["id"] for r in native} == EXPECTED_IDS and len(native) == len(EXPECTED_IDS)
    assert {r["id"] for r in fresh} == EXPECTED_IDS and len(fresh) == len(EXPECTED_IDS)
    fresh_by_id = {r["id"]: r for r in fresh}
    for row in native:
        ident = row["id"]
        child = fresh_by_id[ident]
        assert row["ast"]["kind"] == "codeblock_literal", ident
        assert row["source_sha256"] == digest(row["source"].encode()), ident
        assert row["dump_sha256"] == digest(row["dump"].encode()), ident
        assert row["emitted_sha256"] == digest(row["emitted"].encode()), ident
        assert child["emitted_sha256"] == row["emitted_sha256"], ident
        meta = row["metadata"]
        assert meta["language_agnostic_action_ir_ready"] == 1, ident
        assert all(meta[k] == 0 for k in ("raw_perl_dependency_count",
                   "canonical_action_ir_fallback_count", "unresolved_helper_count")), ident
        if ident in FAILED:
            assert row["native"]["value"] is None and row["native"]["error"], ident
            assert child["value"] is None and child["load_error"], ident
            assert len(row["statement_split"]) == 1, ident
            assert row["statement_split"][0] == row["action"], ident
            assert row["pipe_mode_events"] and row["pipe_mode_events"][0]["returned"] == 1, ident
        else:
            assert row["native"]["value"] == "ok" and row["native"]["error"] is None, ident
            assert child["value"] == "ok" and child["load_error"] is None, ident
            assert len(row["statement_split"]) == 2, ident
            assert "pack(\"H*\"" in row["substitution"], ident
        assert row["diagnostic_bypass_hits"] > 0 if ident == "xy-intervention" else row["diagnostic_bypass_hits"] == 0
    xy = next(r for r in native if r["id"] == "xy")
    restored = next(r for r in native if r["id"] == "xy-restored")
    intervention = next(r for r in native if r["id"] == "xy-intervention")
    assert xy["source"] == restored["source"] == intervention["source"]
    assert xy["pipe_mode_events"][0]["segments"] == 2
    assert "{|x,y|" in xy["substitution"] and "{|x,y|" not in intervention["substitution"]
    assert "Transliteration pattern not terminated" in xy["native"]["error"]["detail"]
    assert 'near "{|"' in fresh_by_id["xy"]["load_error"]


native = json.loads((OUT / "native.json").read_text())
fresh = json.loads((OUT / "fresh.json").read_text())
review(native, fresh)
rejected = []
for name in ("healthy-xy-result", "separated-xy-tail"):
    corrupt = copy.deepcopy(native)
    xy = next(r for r in corrupt if r["id"] == "xy")
    if name == "healthy-xy-result":
        xy["native"]["value"] = "ok"
    else:
        xy["statement_split"] = [xy["action"].split("; ", 1)[0], xy["action"].split("; ", 1)[1]]
    try:
        review(corrupt, fresh)
    except AssertionError:
        rejected.append(name)
    else:
        raise AssertionError(f"bad observation accepted: {name}")

production = subprocess.check_output(["git", "ls-files", "perl"], cwd=ROOT).decode().splitlines()
authorities = ["capability_conformance/callable_codeblock_contract.json",
               "capability_conformance/callable_signature_contract.json"]
inputs = []
for path in production + authorities:
    data = (ROOT / path).read_bytes()
    previous = subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT)
    assert data == previous, f"production/authority moved: {path}"
    inputs.append({"path": path, "sha256": digest(data), "role": "input"})
for suffix in ("probe.pl", "fresh.pl", "review.py"):
    path = f"docs/checkpoints/{OWNER}-{suffix}"
    inputs.append({"path": path, "sha256": digest((ROOT / path).read_bytes()), "role": "producer"})
for path in ("tools/project_data_env.sh", "tools/project_data_run.sh",
             "tools/run_python_project_data.sh"):
    inputs.append({"path": path, "sha256": digest((ROOT / path).read_bytes()), "role": "input"})

capture = {"owner": OWNER, "activation_commit": BASE, "native": native, "fresh": fresh,
           "review": {"paired_controls": len(native), "failed_baselines": sorted(FAILED),
                      "rejected_observation_corruptions": rejected,
                      "unchanged_production_and_authority_inputs": len(production) + len(authorities)},
           "inputs": inputs,
           "limits": ["Diagnostic monkeypatch is scoped to the exact x,y signature closer, not a production repair.",
                      "No full pipeline, other-backend, historical runtime or new admission proof."]}
checkpoint_path = f"docs/checkpoints/{OWNER}-diagnosis.json"
(ROOT / checkpoint_path).write_text(json.dumps(capture, indent=2, ensure_ascii=True) + "\n")
inputs.append({"path": checkpoint_path, "sha256": digest((ROOT / checkpoint_path).read_bytes()), "role": "input"})
claim = {"version": 1, "owner": OWNER, "claims": [{
    "name": "literal-signature-pipe-diagnosis",
    "statement": "The selected accepted literals fail because the action splitter mistakes an operator-named final parameter's closing pipe for host quote syntax; bypassing only the exact x,y closer restores both public routes, and restoring it restores failure.",
    "scope": "Eight named native/fresh emitted diagnostic controls on unchanged e63 production/authority bytes, including an exact scoped intervention and restoration. Metadata is recorded independently of actual compilation. This is source-located diagnosis, not production repair or general pipeline acceptance.",
    "rederive": {"status": "checked", "command": f"bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/{OWNER}-probe.pl; bash tools/run_python_project_data.sh docs/checkpoints/{OWNER}-review.py",
                 "granularity": "Each exact source/AST/splitter event/metadata/substitution/dump/native outcome and hash-matched fresh emitted outcome; whole production/authority membership is enumerated and compared to activation Git blobs.",
                 "result": "Eight paired controls: four failing baselines and four healthy controls including the targeted intervention; restored x,y fails again. Two actual corrupted-observation controls reject."},
    "falsify": {"status": "checked", "hypothesis": "The standalone literal is invalid, or the runtime bridge independently causes the failure.",
                "oracle": "The same source has a valid standalone typed literal; actual splitter mode entry merges its tail. Rename/reorder controls avoid mode entry. Bypass only the x,y signature closer with production/runtime bytes unchanged: complete native and independent emitted execution return ok; restore and both fail again. The review also rejects a fabricated healthy native result and fabricated split tail.",
                "red_control": "Original and restored x,y fail native handler compilation and fresh generated loading; rest-y/ending-q exhibit the same scanner entry. Both deliberately corrupted observations raise AssertionError; actual capture passes again."},
    "durability": {"status": "checked", "mode": "live", "inputs": inputs}
}]}
(ROOT / f"docs/claims/{OWNER}.json").write_text(json.dumps(claim, indent=2) + "\n")
print(json.dumps(capture["review"], sort_keys=True))

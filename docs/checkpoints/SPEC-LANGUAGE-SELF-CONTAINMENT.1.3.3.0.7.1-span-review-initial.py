"""Read-only review of bounded span, lifecycle ownership and gate failure proof."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
BASE = "c9673d7eff39836fdc94d59b8d47639db5e937d4"
TEST = "t/actionir_nested_block_source_spans.t"


def require(value, message):
    if not value:
        raise ValueError(message)


def read(suffix):
    return (ROOT / (PREFIX + suffix)).read_bytes()


def load(name, suffix):
    spec = importlib.util.spec_from_file_location(name, ROOT / (PREFIX + suffix))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


SPAN = load("span_coordinate_oracle", "span-normalize.py")


def captures(record, mode, cases):
    require(record["owner"] == OWNER and record["mode"] == mode and
            record["seeds"] == ["0", "1", "2"] and record["perturbation"] == "2",
            "span capture population")
    found = {}
    for row in record["rows"]:
        require(row["exit"] == 0 and row["stderr"] == "" and
                json.loads(row["stdout"]) == row["observation"], "span actual producer")
        require(len(row["observation"]["cases"]) == 1, "span per-process source")
        x = row["observation"]["cases"][0]
        key = (x["id"], x["seed"])
        require(key not in found and key[0] in cases and key[1] in record["seeds"] and
                x["source"] == cases[key[0]]["source"] and
                row["command"] == ["perl", "-Iperl", PREFIX + "span-probe.pl", key[0]],
                "span source identity")
        require(x["source_sha256"] == hashlib.sha256(x["source"].encode()).hexdigest() and
                x["emitted_sha256"] == x["fresh"]["emitted_sha256"] ==
                hashlib.sha256(x["emitted"].encode()).hexdigest(), "span emitted/source identity")
        require(x["native"]["exception"] is None and x["native"]["context_error"] is None and
                x["fresh"]["exception"] is None and
                all(x[route][channel] == "" for route in ("native", "fresh")
                    for channel in ("stdout", "stderr")), "span healthy runtime channels")
        fallback = 0 if key[0] == "mark" else 1
        meta = x["metadata"]
        require(meta["canonical_action_ir_fallback_count"] == meta["raw_perl_dependency_count"] == fallback
                and meta["language_agnostic_action_ir_ready"] == 1 - fallback,
                "span original canonical fallback/readiness")
        if mode == "after":
            require(meta["raw_perl_expression_dependencies"] ==
                    meta["raw_perl_expression_source_units"] == [], "span generated ownership")
        found[key] = x
    require(set(found) == {(name, seed) for name in cases for seed in record["seeds"]},
            "span complete capture")
    return found


def compare(before, after):
    for key, new in after.items():
        old = before[key]
        require(new["ast"] == SPAN.ast(old["ast"]), "span bounded AST coordinates")
        for field in ("action_probe_source", "substitution", "dump", "emitted"):
            require(SPAN.source_equal(old[field], new[field]), "span bounded compiler source: " + field)
        require({k: v for k, v in new["metadata"].items() if k not in
                 {"raw_perl_expression_dependencies", "raw_perl_expression_source_units"}} == old["metadata"],
                "span unchanged event metadata")
        for route in ("native", "fresh"):
            require({k: v for k, v in new[route].items() if k != "emitted_sha256"} ==
                    {k: v for k, v in old[route].items() if k != "emitted_sha256"},
                    "span unchanged runtime observations")


def tap(record, mode):
    require(record["owner"] == OWNER and record["mode"] == mode and len(record["rows"]) == 1,
            "span TAP population")
    row = record["rows"][0]
    require(row["command"][-1] == TEST and row["exit"] == (14 if mode == "before" else 0) and
            re.findall(r"^1\.\.(\d+)$", row["stdout"], re.M) == ["20"], "span TAP plan/exit")
    failures = re.findall(r"^not ok (\d+) -", row["stdout"], re.M)
    require(failures == ([str(x) for x in list(range(1, 7)) + list(range(10, 16)) + [19, 20]]
                         if mode == "before" else []), "span exact RED/GREEN")
    if mode == "after":
        require("Result: PASS" in row["stdout"] and re.search(r"Files=1, Tests=20\b", row["stdout"]),
                "span complete GREEN")


def reject(name, operation, reason):
    try:
        operation()
    except ValueError as error:
        require(str(error) == reason, "unrelated span rejection: " + name + ": " + str(error))
        return {"name": name, "reason": str(error)}
    raise ValueError("span corruption accepted: " + name)


def main():
    cases = {x["id"]: x for x in json.loads(read("span-cases.json"))}
    require(set(cases) == {"mark", "move_pos", "capture_slice", "capture_from_here"}, "span four marker sources")
    records = {mode: json.loads(read("span-" + mode + ".json")) for mode in ("before", "after")}
    before, after = (captures(records[mode], mode, cases) for mode in ("before", "after"))
    compare(before, after)
    for mode in ("before", "after"):
        tap(json.loads(read("span-tests-" + mode + ".json")), mode)
    # Exact three handoffs, no unrelated parser change or grammar expansion.
    prior_parser = read("before-span-Parser.pm")
    require(prior_parser == subprocess.check_output(["git", "show", BASE + ":perl/LinkedSpec/ActionIR/AST/Parser.pm"], cwd=ROOT),
            "span activation parser identity")
    expected = prior_parser
    for old, new in (
        (b"my $block = parse_action_block($attached->{body});", b"my $block = parse_action_block($attached->{body}, { base_start => $block_start + 1 });"),
        (b"my $body = parse_action_block($attached->{body});", b"my $body = parse_action_block($attached->{body}, { base_start => $start + $attached->{open_idx} + 1 });"),
        (b"my $block = parse_action_block($payload);", b"my $block = parse_action_block($payload, { base_start => $start + 1 });"),
    ):
        require(expected.count(old) == 1, "span exact handoff anchor")
        expected = expected.replace(old, new, 1)
    require(expected == (ROOT / "perl/LinkedSpec/ActionIR/AST/Parser.pm").read_bytes(), "span exact parser repair")
    require(read("before-span-phase0.t") == (ROOT / "t/phase0_regression.t").read_bytes(), "span unchanged Phase0 oracle")
    controls = []
    altered = copy.deepcopy(after)
    altered[("mark", "0")]["ast"]["source_span"]["start"] += 1
    controls.append(reject("unrelated AST shift", lambda: compare(before, altered), "span bounded AST coordinates"))
    altered = copy.deepcopy(after)
    altered[("mark", "0")]["emitted"] += "# changed executable bytes\n"
    controls.append(reject("outside payload drift", lambda: compare(before, altered), "span bounded compiler source: emitted"))
    altered = copy.deepcopy(records["after"])
    row = next(x for x in altered["rows"] if x["observation"]["cases"][0]["id"] == "move_pos")
    row["observation"]["cases"][0]["metadata"]["raw_perl_dependency_count"] = 0
    row["stdout"] = json.dumps(row["observation"])
    controls.append(reject("old fallback hidden", lambda: captures(altered, "after", cases), "span original canonical fallback/readiness"))
    altered_tap = json.loads(read("span-tests-after.json"))
    altered_tap["rows"][0]["exit"] = 1
    controls.append(reject("span failed TAP hidden", lambda: tap(altered_tap, "after"), "span TAP plan/exit"))
    keyword_before = json.loads(read("keyword-before.json"))
    keyword_after = json.loads(read("keyword-after.json"))
    old_keyword = next(row["observation"]["cases"][0] for row in keyword_before["rows"]
                       if row["observation"]["cases"][0]["id"] == "bridge_keyword_effects")
    new_keyword = next(row["observation"]["cases"][0] for row in keyword_after["rows"]
                       if row["observation"]["cases"][0]["id"] == "bridge_keyword_effects")
    require(old_keyword["emitted"] != new_keyword["emitted"] and
            SPAN.source_equal(old_keyword["emitted"], new_keyword["emitted"]), "actual serialized coordinate change")
    # Corrupt an actual changed AST operand, preserving all surrounding Perl.
    pair = next((left, right) for left, right in zip(SPAN.PACK.finditer(old_keyword["emitted"]),
                                                   SPAN.PACK.finditer(new_keyword["emitted"]))
                if left.group(1) != right.group(1))
    for field, value in (("kind", "changed_node_kind"), ("source", "changed_authored_source")):
        match = pair[1]
        payload = json.loads(bytes.fromhex(match.group(1)))
        require(isinstance(payload, dict) and field in payload, "serialized AST mutation anchor")
        payload[field] = value
        altered_source = (new_keyword["emitted"][:match.start(1)] +
                          json.dumps(payload, separators=(",", ":")).encode().hex() +
                          new_keyword["emitted"][match.end(1):])
        controls.append(reject("serialized non-coordinate " + field,
                               lambda: require(SPAN.source_equal(old_keyword["emitted"], altered_source),
                                               "serialized AST semantic drift"), "serialized AST semantic drift"))
    failure_module = load("span_canonical_failure", "canonical-span-failure.py")
    failure = json.loads(read("canonical-span-before.json"))
    raw = failure_module.validate(failure)
    for field, value, reason in (("base64", "!", "runtime canonical base64"),
                                 ("compressed_sha256", "0" * 64, "runtime canonical compressed identity"),
                                 ("bytes", len(raw) + 1, "runtime canonical raw identity")):
        altered_failure = copy.deepcopy(failure)
        altered_failure["log_envelope"][field] = value
        controls.append(reject("span failure envelope " + field, lambda: failure_module.validate(altered_failure), reason))
    paths = {TEST, "perl/LinkedSpec/ActionIR/AST/Parser.pm", "perl/LinkedSpec/RuleIR.pm",
             "perl/LinkedSpec/RuleIR/EmitContext.pm", "perl/LinkedSpec/ActionIR/RawDependencies.pm",
             "perl/LinkedSpec/ActionIR/Diagnostics.pm", "t/phase0_regression.t"}
    paths.update(PREFIX + suffix for suffix in (
        "span-normalize.py", "span-review.py", "span-probe.pl", "span-fresh.pl", "span-capture.py", "span-cases.json",
        "span-before.json", "span-after.json", "span-phase0.py", "span-tests-before.json", "span-tests-after.json",
        "keyword-before.json", "keyword-after.json",
        "before-span-Parser.pm", "before-span-RuleIR.pm", "before-span-EmitContext.pm", "before-span-Diagnostics.pm",
        "before-span-RawDependencies.pm", "before-span-phase0.t", "canonical-span-failure.py", "canonical-span-before.json",
        "before-EmitContext.pm", "before-Diagnostics.pm"))
    print(json.dumps({"owner": OWNER, "result": "PASS", "sources": len(cases), "native_fresh_pairs": len(after),
                      "top_level_TAP_tests": 20, "actual_RED": {"plan": 20, "failed_top_level": 14},
                      "third_canonical_failure_log_bytes": len(raw), "controls": controls,
                      "tracked_inputs": {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in sorted(paths)},
                      "limits": "Three child-frame coordinate repairs only; generated lifecycle exact slot/source provenance suppresses added scanning, preserving prior canonical fallback. Authored twins and replaced slots remain visible. Nine positive forms and nine typed diagnostics include Unicode/CRLF and nonzero bases; no new grammar, runtime or backend admission."}, indent=2))


if __name__ == "__main__":
    main()

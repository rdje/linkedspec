"""One-shot source custody and complete checked-live claim census before repair."""
import json
import subprocess
import common as c
import context

PLANNED = {
    "perl/LinkedSpec/CodeblockRuntime.pm", "t/callable_codeblock_literal_contract.t",
    "docs/knowledge/perl-codeblock-boolean-literal-kind-drift.md",
    "docs/knowledge/terse-primitive-literal-parity.md",
    "docs/knowledge/write-vivification-perl-reference.md", "KNOWLEDGE_MAP.md",
    "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md",
    "MEMORY.md", "CHANGES.md", "DEVELOPMENT_NOTES.md", "LIVE_ACHIEVEMENT_STATUS.md",
    "ROADMAP.md", "ROADMAP_V2.md", "docs/TASK_TREE.md", "docs/tasks/TYPE-REFERENCE-BOOK.md",
    "docs/tasks/SESSION-STARTUP-READING.04-49.md", "docs/tasks/SESSION-STARTUP-READING.index.jsonl",
}


def main():
    records = {}
    claim_count = 0
    for path in subprocess.check_output(["git", "ls-files", "docs/claims"], cwd=c.ROOT).decode().splitlines():
        value = json.loads(c.source(path).read_bytes())
        live = [claim for claim in value["claims"] if claim["durability"].get("status") == "checked"
            and claim["durability"].get("mode") == "live"]
        if live:
            names = {item["path"] for claim in live for item in claim["durability"]["inputs"]}
            assert not PLANNED & names, (path, sorted(PLANNED & names))
            claim_count += len(live)
            records[path] = dict(packet=c.read(path), inputs=sorted(names))
    for path in ("perl/LinkedSpec/CodeblockRuntime.pm", "t/callable_codeblock_literal_contract.t"):
        assert c.source(path).read_bytes() == subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
    epoch = context.snapshot()
    c.write_new("activation-inputs.json.gz", dict(context=epoch, producer=c.read(c.PREFIX + "activate.py"),
        planned=sorted(PLANNED), live_records=records, checked_live_claims=claim_count,
        accepted_boolean_issue=c.read("docs/knowledge/perl-codeblock-boolean-literal-kind-drift.md")))
    previous = c.run(["bash", "tools/run_python_project_data.sh",
        "docs/checkpoints/perl-literal-number-intake/read.py"])
    assert previous["returncode"] == 0, previous
    assert c.unchanged(epoch["inputs"])
    c.write_new("activation-runs.json.gz", dict(previous_intake=previous, inputs_unchanged=True,
        scope="Clean committed Perl17.2 activation; existing boolean issue35 retains its dated ownership. No runtime repair or broad admission is claimed by activation."))
    print(json.dumps(dict(base=c.BASE, checked_live_records=len(records), checked_live_claims=claim_count,
        planned_intersections=0, previous_intake="PASS"), sort_keys=True))


if __name__ == "__main__":
    main()

"""Publish the retained original dedicated-producer diagnosis and precise limits."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0"
PREFIX = "docs/checkpoints/" + OWNER + "-"
REVISION = "3482a5d220bd7063a910c09de883faa903d24135"
PREVIOUS = "docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7.json"
TESTS = [
    "t/staged_ast_enrichment_perl_contract.t", "t/progressive_span_dispatch_perl_contract.t",
    "t/recognition_transaction_perl_contract.t", "t/recursive_observation_perl_contract.t",
    "t/actionir_helper_source_provenance.t", "t/actionir_statement_source_frames.t",
    "t/actionir_ast_parser.t", "t/canonical_event_occurrence_order.t",
    "t/actionir_nested_block_source_spans.t",
]


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def load(name):
    return json.loads((ROOT / (PREFIX + name + ".json")).read_bytes())


runtime, book, freeze, manifest = [load(name) for name in
                                   ("verification", "book-verification", "freeze", "inputs")]
assert runtime["complete"] and book["complete"]
assert runtime["revision"] == freeze["revision"] == manifest["revision"] == REVISION
assert runtime["regular_inputs"] == len(manifest["entries"]) == 4593
assert tuple(runtime[key] for key in ("overlays", "commands", "contracts", "cases", "seeds",
                                    "events", "statement_frames", "source_origins",
                                    "compiler_cases", "fixture_suites", "fixture_groups")) == (
    3, 4, 7, 22, 3, 42, 63, 0, 4, 9, 544,
)
assert len(runtime["controls"]) == 108
assert all(control["observed"] == "RED" and control["reason"] for control in runtime["controls"])
assert (book["book_inputs"], book["rendered_examples"], book["rendered_sections"],
        len(book["controls"]), freeze["bound_inputs"]) == (58, 22, 4, 37, 103)
assert all(control["rejected"] and control["reason"] for control in book["controls"])
for result, producer in ((runtime, "review.py"), (book, "book.py"), (freeze, "freeze.py")):
    assert result["instrument_sha256"] == digest(PREFIX + producer)
before = load("before-legacy-claim")
for claim in before["claims"]:
    claim["durability"].update(mode="historical", revision=REVISION)
assert json.loads((ROOT / PREVIOUS).read_bytes()) == before, "mode/revision-only historical freeze"

# Every immutable runtime input is recoverable from the named Git boundary and
# its object/content/mode manifest. Bind authored overlays, actual instruments,
# reviewed channels and the complete mutable publication directly.
paths = [path.relative_to(ROOT).as_posix()
         for path in (ROOT / "docs/checkpoints").glob(OWNER + "-*") if path.is_file()]
paths += [PREVIOUS,
          "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py",
          "docs/knowledge/perl-dedicated-producer-source-diagnosis.md",
          "perl/LinkedSpec.pm", "perl/LinkedSpec/ActionIR/Scanner.pm",
          "perl/LinkedSpec/ActionIR/ScannerCore.pm", "perl/LinkedSpec/ActionIR/Contracts.pm",
          "perl/LinkedSpec/ActionIR/MethodExpr.pm",
          "perl/LinkedSpec/ActionIR/StatementSplit/Core.pm",
          "perl/LinkedSpec/ActionIR/StagedParseJob.pm",
          "perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm",
          "perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm",
          "tools/project_data_env.sh", "tools/project_data_run.sh",
          "tools/run_python_project_data.sh"]
paths += TESTS
paths += [entry["path"] for entry in load("book-inputs")["entries"]]
inputs = [{"path": path, "sha256": digest(path),
           "role": "producer" if path.endswith((".py", ".pl", ".pm", ".t", ".sh")) else "input"}
          for path in sorted(set(paths))]
statement = (
    "Original immutable3482a5d22 diagnosis supplies4593 regular committed Git inputs plus three "
    "authored overlays/four guarded commands. Seven dedicated contracts cover22 literal cases,42 "
    "events/63 original statement frames and zero event-source origins per seed. Actual dispatcher "
    "returned-array/event/argument identities and every complete callback/Toolbox channel agree "
    "across three hash seeds; four compiler-construction examples retain dedicated nodes and "
    "constructor spellings. Nine unchanged suites pass544 ordered groups;108 effective reason-specific "
    "evidence controls observe RED. Complete58-input book renders22 examples across four chapters "
    "with37 rejection controls; all103 preceding Legacy claim input hashes verify before its "
    "historical mode/revision-only freeze."
)
scope = (
    "Immutable clean " + REVISION + " conservative complete regular Git supplied-input superset, "
    "not minimal observed I/O; every original byte/object/mode/member is recoverable through that "
    "commit and the tracked manifest. Three exact authored case/probe/oracle overlays add no runtime "
    "implementation. Original independent event/argument literals and assembled Unicode-scalar "
    "intervals distinguish repeated statements and quoted-only controls. Identities are measured at "
    "the actual family dispatcher return, not every intermediate constructor. Staged payload provenance "
    "is distinct from authored-action event provenance. The four Toolbox examples build Get parsers, "
    "capture substitution and descriptor ActionIR metadata, and dump complete parser source; this "
    "probe does not execute those parsers. Nine existing consumers separately execute their covered "
    "runtime routes once. Three seeds establish sampled full-channel equality, not arbitrary host "
    "syntax/callback guarantees. Book examples are rendered teaching, not further runtime execution. "
    "Production/spec/standard tests, static policies, carrier formats, CI/storage/dependency bytes "
    "and public admission do not change. Staged .1.5.1, progressive .1.5.2, recognition/observation "
    ".1.5.3 and canonical family .1.5.4 own implementation; all-producer composition, executable "
    "quoted/comment membership and exact replacement remain separate. Existing token-order, "
    "resource ceilings, restoration/boolean-kind, marker lifetime, named-mark observation and wrapper "
    "lifecycle defects retain their recorded owners; recovery/purge remain prohibited. Other "
    "backends and global historical audits are unassessed. Necessary OS/Perl/Python/prove/mdBook/Git "
    "prerequisites are read-only; all project scratch/output stays repository-local. Gitlinks and "
    "nonregular metadata exclude payloads; RGX/PGEN remain black boxes and other repositories read-only."
)
record = {"version": 1, "owner": OWNER, "claims": [{
    "name": "original-dedicated-producer-source-diagnosis",
    "statement": statement, "scope": scope,
    "rederive": {
        "status": "checked",
        "command": "; ".join("bash tools/run_python_project_data.sh " + PREFIX + name
                            for name in ("inventory.py", "capture.py", "review.py", "freeze.py",
                                         "book.py --review")),
        "granularity": "4593 immutable inputs/3 overlays/4 commands;7 contracts/22 cases/3 seeds/42 events/63 frames/0 origins/4 compiler cases;9 suites/544 groups;58 book inputs/22 examples/4 chapters;103 prior hashes.",
        "result": statement,
    },
    "falsify": {
        "status": "checked",
        "hypothesis": "Dropped events, cloned equal references, repeated wrong intervals, fabricated origins or incomplete callback/compiler/TAP/input channels could falsely establish an original producer diagnosis.",
        "oracle": "Independently authored complete event/argument literals and assembled scalar statement boundaries, actual dispatcher-returned object identities, original callback equality, dedicated compiler node/constructor checks, complete immutable Git input identity and ordered positive TAP with nested-failure rejection.",
        "red_control": "108 effective reason-specific RED controls omit every nonempty selected event row, falsify array/event/argument references across all seven contracts, invent origins, substitute wrong repeated intervals, lose callbacks, remove dedicated compiler nodes/constructors, forge or truncate commands/guards/exits/instruments/channels/TAP/Git inputs/overlays.37 render controls reject missing original/new examples, scope/authority teaching and forged or failed rendering evidence.",
    },
    "durability": {"status": "checked", "mode": "live", "inputs": inputs},
}]}
target = ROOT / ("docs/claims/" + OWNER + ".json")
target.write_text(json.dumps(record, indent=2) + "\n")
assert target.stat().st_size <= 131072, "bounded claim record"
print("Published original dedicated diagnosis with " + str(len(inputs)) + " retained bindings")

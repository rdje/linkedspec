"""Retain original dedicated producers and independently author diagnosis literals."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix("inventory.py")
OWNERS = {
    "staged": "perl/LinkedSpec/ActionIR/StagedParseJob.pm",
    "progressive": "perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm",
    "recognition": "perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm",
}
CONTRACTS = [
    "staged_parse_job", "progressive_span_dispatch", "observe_recognition",
    "recognition_checkpoint", "recognize_once", "recognition_commit",
    "recognition_rollback",
]


def save(name, value):
    Path(PREFIX + name).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def staged_args(text, options_source, plan, options):
    validation = {"ok": 1, "options": options, "text_plan": plan}
    return {
        "target": "job", "argument_count": 2,
        "text_operand": text, "options_operand": options_source,
        "validation": validation, "text_plan": plan, "options": options,
    }


options_source = 'hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","replace_marker","on_error","fail")'
options = {
    "node_kind": "expression", "payload_kind": "text", "spec": "expr-v1",
    "result_policy": "replace_marker", "on_error": "fail", "required_capabilities": [],
}
base = {
    "staged_parse_job": (
        "job = parse_job(entry_text(), " + options_source + ")",
        staged_args("entry_text()", options_source,
                    {"kind": "direct_span", "source": "entry_text"}, options),
    ),
    "progressive_span_dispatch": (
        'child = dispatch_span("expr-v1", "Expr", span)',
        {"result": "child", "argument_count": 3, "parser_operand": '"expr-v1"',
         "top_rule_operand": '"Expr"', "span_operand": "span",
         "parser_id": "expr-v1", "top_rule": "Expr", "span_binding": "span"},
    ),
    "observe_recognition": (
        "value = observe_recognition(observation, call(Done))",
        {"result": "value", "target": "observation", "operand": "call(Done)", "callee": "Done"},
    ),
    "recognition_checkpoint": ("scope = recognition_checkpoint()", {"token": "scope"}),
    "recognize_once": (
        "matched = recognize_once(scope, call(Done))",
        {"matched": "matched", "token": "scope", "operand": "call(Done)", "callee": "Done"},
    ),
    "recognition_commit": ("payload = recognition_commit(scope)", {"payload": "payload", "token": "scope"}),
    "recognition_rollback": ("recognition_rollback(scope)", {"token": "scope"}),
}
cases = []


def assemble(case_id, segments, selected):
    """Offsets come from authored segment boundaries, never observed event text."""
    position = 0
    statements = []
    for raw in segments:
        statements.append({"source_span": {"start": position, "end": position + len(raw)}, "raw": raw})
        position += len(raw) + 3  # literal separator is semicolon, space, Unicode em space
    action = "; \u2003".join(segments) + "\r\n"
    rows = []
    for contract, items in selected.items():
        rows.append({
            "contract": contract,
            "expected_events": [{"raw": segments[index], "args": args} for index, args in items],
            "original_spans": [[statements[index]["source_span"]["start"],
                                statements[index]["source_span"]["end"]] for index, _ in items],
        })
    cases.append({"id": case_id, "action": action, "statements": statements, "rows": rows})


def repeated(case_id, contract, raw, args):
    quoted = "literal = " + json.dumps("雪 " + raw, ensure_ascii=False)
    assemble(case_id, [quoted, raw, raw], {contract: [(1, args), (2, args)]})


for contract in CONTRACTS:
    raw, args = base[contract]
    repeated(contract, contract, raw, args)
    assemble(contract + "-quoted-only",
             ["literal = " + json.dumps("雪 " + raw, ensure_ascii=False)], {contract: []})

derived_source = 'hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","append_child","on_error","keep_text","top","Expr","into","children","required_capabilities",array("z.cap","a.cap"))'
derived_options = {
    "node_kind": "expression", "payload_kind": "text", "spec": "expr-v1",
    "result_policy": "append_child", "on_error": "keep_text", "top": "Expr",
    "into": "children", "required_capabilities": ["a.cap", "z.cap"],
}
derived_text = "cat(entry_group(1), cat(match_text(), entry_text()))"
derived_plan = {
    "kind": "derived_text", "policy": "concatenate_in_order",
    "segments": [
        {"kind": "direct_span", "source": "entry_group", "index": 1},
        {"kind": "direct_span", "source": "match_text"},
        {"kind": "direct_span", "source": "entry_text"},
    ],
}
repeated("staged-derived-options", "staged_parse_job",
         "job = parse_job(" + derived_text + ", " + derived_source + ")",
         staged_args(derived_text, derived_source, derived_plan, derived_options))
bad_options_source = options_source[:-1] + ',"unknown","value")'
repeated("staged-unknown-option", "staged_parse_job",
         "job = parse_job(entry_text(), " + bad_options_source + ")",
         {"target": "job", "argument_count": 2, "text_operand": "entry_text()",
          "options_operand": bad_options_source,
          "validation": {"ok": 0, "code": "staged_parse_job_option_unknown", "option": "unknown"}})
repeated("progressive-dynamic-parser", "progressive_span_dispatch",
         'child = dispatch_span(parser, "Expr", span)',
         {"result": "child", "argument_count": 3, "parser_operand": "parser",
          "top_rule_operand": '"Expr"', "span_operand": "span"})
repeated("progressive-extra-argument", "progressive_span_dispatch",
         'child = dispatch_span("expr-v1", "Expr", span, other)',
         {"result": "child", "argument_count": 4, "parser_operand": '"expr-v1"',
          "top_rule_operand": '"Expr"', "span_operand": "span"})
repeated("recognition-value-operand", "recognize_once",
         "matched = recognize_once(scope, value)",
         {"matched": "matched", "token": "scope", "operand": "value"})
repeated("observation-missing-operand", "observe_recognition",
         "value = observe_recognition(observation)",
         {"result": "value", "target": "observation", "operand": "",
          "argument_count": 1, "operand_kind": "missing"})
repeated("observation-extra-argument", "observe_recognition",
         "value = observe_recognition(observation, call(Done), extra)",
         {"result": "value", "target": "observation", "operand": "call(Done)",
          "argument_count": 3, "callee": "Done"})

mixed = [base[contract][0] for _ in range(2) for contract in CONTRACTS]
assemble("mixed-repeated-dedicated-producers", mixed,
         {contract: [(index, base[contract][1]) for index in (i, i + len(CONTRACTS))]
          for i, contract in enumerate(CONTRACTS)})
toolbox = [
    {"id": "staged", "action": base["staged_parse_job"][0] + "; return(job)"},
    {"id": "progressive", "action": "span = entry_span(); " + base["progressive_span_dispatch"][0] + "; return(child)"},
    {"id": "recognition", "action": "; ".join(base[key][0] for key in
        ("recognition_checkpoint", "recognize_once", "recognition_commit")) + "; return(payload)"},
    {"id": "observation", "action": base["observe_recognition"][0] + "; return(value)"},
]
owners = []
for family, path in OWNERS.items():
    raw = (ROOT / path).read_bytes()
    text = raw.decode()
    if family == "recognition":
        dispatch = text.split("my %dispatch = (", 1)[1].split(" );", 1)[0]
        pairs = re.findall(r"(\w+)\s*=>\s*\\&(\w+)", dispatch)
    else:
        pairs = [(re.search(r"id\s*=>\s*'([^']+)'", text)[1], "try_scan_contract_ir_events")]
    owners.append({
        "family": family, "path": path, "bytes": len(raw),
        "sha256": hashlib.sha256(raw).hexdigest(),
        "contracts": [{"id": contract, "handler": handler} for contract, handler in pairs],
        "private_source_recorder_calls": len(re.findall(r"\b_record_(?:statement|scanned)_source_event\s*\(", text)),
    })
assert [item["id"] for owner in owners for item in owner["contracts"]] == CONTRACTS
assert all(owner["private_source_recorder_calls"] == 0 for owner in owners)
save("inventory.json", {"owners": owners, "contracts": CONTRACTS,
                       "scope": "Exact dedicated scanner dispatch population; no helper or runtime admission."})
save("cases.json", {"contracts": CONTRACTS, "cases": cases, "toolbox": toolbox,
                   "scope": "Independent literal event/argument and scalar-interval diagnosis; no implementation change."})
print("Original dedicated producer inventory and authored literals retained")

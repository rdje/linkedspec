"""Read-only validation of the original public precision diagnosis."""
import json
import re
import common as c


def numbers(node):
    if isinstance(node, dict):
        if node.get("kind") == "number":
            yield node
        for value in node.values():
            yield from numbers(value)
    elif isinstance(node, list):
        for value in node:
            yield from numbers(value)


def check():
    inputs = c.load("precision-inputs.json.gz")
    runs = c.load("precision-runs.json.gz")
    assert runs["inputs_unchanged"] and runs["run"]["returncode"] == 0
    assert not c.decode(runs["run"]["stderr_base64"])
    rows = json.loads(c.decode(runs["run"]["stdout_base64"]))["rows"]
    assert len(rows) == 8
    for index, row in enumerate(rows):
        deferred = "cb=" in row["body"]
        fractional = "1000000000000000.5" in row["body"]
        assert row["route"] == ("native" if index % 2 == 0 else "generated")
        assert row["flags"] == dict(integer=int(deferred), floating=int(not deferred), string=0)
        expected = "0x1.c6bf52634p+49" if deferred else "0x1.c6bf526340004p+49"
        assert row["hexadecimal"] == (expected if fractional else "-0x1p+0")
        if deferred:
            source = row.get("dump", row.get("emitted"))
            observed = []
            for hex_value in re.findall(r'pack\("H\*",\s*"([0-9a-f]+)"\)', source):
                observed.extend(numbers(json.loads(bytes.fromhex(hex_value))))
            assert len(observed) == 1
            node = observed[0]
            assert node["source"] == ("1000000000000000.5" if fractional else "-1.0")
            assert node["value"] == (1000000000000000 if fractional else -1)
    return dict(public_observations=8, routes=2, actual_fractional_payload_loss=True,
        original_literal_spelling_retained=True, inputs=len(inputs["context"]["inputs"]),
        scope="Dated before-repair diagnosis. Hexadecimal values were observed before JSON reporting; direct compiled twins distinguish actual deferred payload loss from final display rounding.")


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))

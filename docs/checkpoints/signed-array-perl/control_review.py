"""Read-only validation of actual input/scope controls and restored source bytes."""
import json
import common as c
import publish


def check():
    supplied = c.load("artifact-inputs.json.gz")
    value = c.load("artifact-controls.json.gz")
    assert value["exact_restoration"]
    assert supplied["producer"] == c.read(c.PREFIX + "publish.py")
    original = c.decode(supplied["producer"]["base64"])
    marker = b"def validate_inputs(declared, actual):\n"
    for phase, row in value["identity"].items():
        expected = original.replace(marker, marker + b"    return\n", 1) if phase == "bypass" else original
        raw = c.decode(row["producer"]["base64"])
        assert raw == expected and c.sha(raw) == row["producer"]["sha256"]
        assert row["run"]["command"] == ["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py", "--identity-controls"]
        assert row["run"]["returncode"] == 0 and not c.decode(row["run"]["stderr_base64"])
        observed = json.loads(c.decode(row["run"]["stdout_base64"]))
        assert set(observed) == {"missing", "bytes", "mode"}
        if phase == "bypass":
            assert all(not item["rejected"] for item in observed.values())
        else:
            assert observed == publish.controls()
            assert observed["missing"] == dict(rejected=True, reason="input population")
            for name in ("bytes", "mode"):
                assert observed[name] == dict(rejected=True, reason="input " + name + ": " + c.PREFIX + "perl_probe.pl")
    assert set(value["identity"]) == {"healthy", "bypass", "restored"}
    assert set(value["scope"]) == {c.PREFIX + "perl_probe.pl", c.PREFIX + "green-inputs.json.gz"}
    for path, phases in value["scope"].items():
        marker = b"return sorted((owned | set(WRAPPERS) | set(FIXED)) - {MANIFEST, PUBLICATION, CLAIM})"
        faulty = original.replace(marker,
            b"return sorted((owned | set(WRAPPERS) | set(FIXED)) - {MANIFEST, PUBLICATION, CLAIM, "
            + repr(path).encode() + b"})", 1)
        assert set(phases) == {"healthy", "omitted", "bypass", "validator_restored", "restored"}
        for phase, row in phases.items():
            expected = original if phase in ("healthy", "restored") else faulty
            if phase == "bypass":
                expected = expected.replace(b"def validate_scope(actual):\n", b"def validate_scope(actual):\n    return\n", 1)
            raw = c.decode(row["producer"]["base64"])
            assert raw == expected and c.sha(raw) == row["producer"]["sha256"]
            assert row["producer"]["mode"] == supplied["producer"]["mode"]
            run = row["run"]
            assert run["command"] == ["bash", "tools/run_python_project_data.sh", c.PREFIX + "publish.py", "--scope-check"]
            if phase in ("omitted", "validator_restored"):
                assert run["returncode"] == 1 and not c.decode(run["stdout_base64"])
                assert c.decode(run["stderr_base64"]).decode().endswith("AssertionError: required input: " + path + "\n")
            else:
                assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
                assert c.decode(run["stdout_base64"]) == b"Required-input scope PASS\n"
    return dict(input_denials=3, identity_bypass_admissions=3, required_input_omissions=2,
        scope_bypass_admissions=2, exact_restoration=True)


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))

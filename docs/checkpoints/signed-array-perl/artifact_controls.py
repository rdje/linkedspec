"""Actual input/scope validator bypasses and restoration before publication."""
import copy
import json
import common as c
import context

PRODUCER = c.PREFIX + "publish.py"


def main():
    original = c.read(PRODUCER)
    raw = c.decode(original["base64"])
    actual = {c.PREFIX + "perl_probe.pl": c.identity(c.PREFIX + "perl_probe.pl")}
    cases = {name: copy.deepcopy(actual) for name in ("missing", "bytes", "mode")}
    cases["missing"].pop(c.PREFIX + "perl_probe.pl")
    cases["bytes"][c.PREFIX + "perl_probe.pl"]["sha256"] = "0" * 64
    cases["mode"][c.PREFIX + "perl_probe.pl"]["mode"] ^= 0o100
    c.write_new("artifact-inputs.json.gz", dict(context=context.snapshot(), producer=original,
        controller=c.read(c.PREFIX + "artifact_controls.py"), actual=actual, cases=cases))

    def execute(argument):
        run = c.run(["bash", "tools/run_python_project_data.sh", PRODUCER, argument])
        return dict(producer=c.read(PRODUCER), run=run)

    def set_source(value):
        c.source(PRODUCER).write_bytes(value)
        c.source(PRODUCER).chmod(original["mode"])

    def bypass(value, function):
        marker = ("def " + function + "(declared, actual):\n" if function == "validate_inputs"
            else "def validate_scope(actual):\n").encode()
        assert value.count(marker) == 1
        return value.replace(marker, marker + b"    return\n", 1)

    identity, scope = {}, {}
    try:
        identity["healthy"] = execute("--identity-controls")
        set_source(bypass(raw, "validate_inputs"))
        identity["bypass"] = execute("--identity-controls")
        set_source(raw)
        identity["restored"] = execute("--identity-controls")
        for path in (c.PREFIX + "perl_probe.pl", c.PREFIX + "green-inputs.json.gz"):
            marker = b"return sorted((owned | set(WRAPPERS) | set(FIXED)) - {MANIFEST, PUBLICATION, CLAIM})"
            assert raw.count(marker) == 1
            faulty = raw.replace(marker,
                b"return sorted((owned | set(WRAPPERS) | set(FIXED)) - {MANIFEST, PUBLICATION, CLAIM, "
                + repr(path).encode() + b"})", 1)
            rows = {"healthy": execute("--scope-check")}
            set_source(faulty)
            rows["omitted"] = execute("--scope-check")
            set_source(bypass(faulty, "validate_scope"))
            rows["bypass"] = execute("--scope-check")
            set_source(faulty)
            rows["validator_restored"] = execute("--scope-check")
            set_source(raw)
            rows["restored"] = execute("--scope-check")
            scope[path] = rows
    finally:
        set_source(raw)
    c.write_new("artifact-controls.json.gz", dict(identity=identity, scope=scope,
        exact_restoration=c.read(PRODUCER) == original))
    print("Actual artifact validator channels retained; read-only control review follows.")


if __name__ == "__main__":
    main()

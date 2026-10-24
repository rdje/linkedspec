"""Resolve the rerun controller's inherited convenience pointer from its whole epoch."""
import common as c

first = c.load("verified-fault-inverse-inputs.json.gz")["context"]
old = c.load("verified-fault-controller-inputs.json.gz")["producer"]
actual_path = c.PREFIX + "faults_verified.py"
actual = first["overrides"][actual_path]
assert actual == c.read(actual_path)
raw = c.decode(old["base64"])
assert c.sha(raw) == old["sha256"]
expected = raw.replace(b'"fault-controller-inputs.json.gz"', b'"verified-fault-controller-inputs.json.gz"')
expected = expected.replace(b'observe("fault-" + name', b'observe("verified-fault-" + name')
expected = expected.replace(b'observe("restore-" + name', b'observe("verified-restore-" + name')
expected = expected.replace(b'"faults.json.gz"', b'"verified-faults.json.gz"')
assert expected == c.decode(actual["base64"])
assert c.load("verified-faults.json.gz")["exact_restoration"]
c.write_new("verified-producer-bridge.json.gz", dict(producer=c.read(c.PREFIX + "bridge_fault_producer.py"),
    actual_path=actual_path, actual_producer=actual, original_pointer=old,
    inputs={actual_path: first["inputs"][actual_path]},
    scope="The distinct rerun inherited a convenience producer field pointing to faults.py. Its complete actual faults_verified.py bytes/mode already precede the first observed command in the whole source epoch, and every subsequent epoch retains them. Exact independent transformation and current identity close that pointer; no input bytes, observation, producer or run is regenerated. Original field stays unchanged."))
print("Actual rerun producer recovered exactly from its pre-command whole source epoch.")

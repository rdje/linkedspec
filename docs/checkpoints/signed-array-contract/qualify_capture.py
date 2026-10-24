"""Preserve an instrument's over-specific expected failure marker."""
from pathlib import Path
import common as c

path = c.PREFIX + "capture.py"
before = c.read(path)
assert not (c.ROOT / c.PREFIX / "neutral-runs.json.gz").exists()
run = c.run(["bash", "tools/run_python_project_data.sh", path])
assert run["returncode"] == 1
stderr = c.decode(run["stderr_base64"])
assert b"AssertionError: ('reject_all_negative'" in stderr
assert b"read fixture outside signed integer/quoted-key scope" in stderr
assert c.read(path) == before
old = b'b"write: last"'
new = b'b"read fixture outside signed integer/quoted-key scope"'
source = c.decode(before["base64"])
assert source.count(old) == 1
c.write_new("capture-qualification.json.gz", dict(
    producer_before=before, reproduction=run,
    scope="The reject-all-negative source control actually failed at the earlier read fixture, while the actor expected a later write marker. No product failure, backend support or final capture credit comes from this unpublished attempt. This is a distinct exact-source reproduction of the original interactive failure. Change only that expected marker; all model source/fixtures stay unchanged.",
))
Path(path).write_bytes(source.replace(old, new, 1))
print("Qualified earlier read rejection; corrected only the actor's expected marker")

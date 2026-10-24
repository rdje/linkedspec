"""Retain the first reader's false rejection before correcting its argv offset."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
reader = HERE / "read.py"
original = reader.read_bytes()
assert original.count(b'run["command"][4]') == 1
runs = json.loads(gzip.decompress((HERE / "runs.json.gz").read_bytes()))
run = runs["observations"]["accepted/native"]
observed = json.loads(base64.b64decode(run["stdout_base64"]))
assert run["command"][4] == "-Iperl"
assert observed["inc"]["LinkedSpec/CodeblockRuntime.pm"] == run["command"][3][2:] + "/LinkedSpec/CodeblockRuntime.pm"
value = dict(original_source_base64=base64.b64encode(original).decode(), sha256=hashlib.sha256(original).hexdigest(),
    actual_command=run["command"], actual_loaded_module=observed["inc"]["LinkedSpec/CodeblockRuntime.pm"],
    qualification="The first preliminary reader falsely rejects because its origin check selects argv4 (-Iperl) instead of argv3 (the actual shadow). Correct only this reader offset; actual sources, commands and observed outcomes stay unchanged. No product RED credit.")
with (HERE / "reader-origin-qualification.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(value, sort_keys=True) + "\n").encode(), mtime=0))
reader.write_bytes(original.replace(b'run["command"][4]', b'run["command"][3]', 1))

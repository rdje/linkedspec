"""Rehydrate exact ignored recovery aliases, then execute the unchanged reviewer."""
import json
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c
import storage_partition

storage_partition.ensure_all()
run = c.run(["bash", "tools/run_python_project_data.sh",
    storage_partition.PREFIX + "storage_inventory.py"])
assert run["returncode"] == 0, c.decode(run["stderr_base64"]).decode()
json.loads(c.decode(run["stdout_base64"]))
sys.stdout.buffer.write(c.decode(run["stdout_base64"]))
sys.stderr.buffer.write(c.decode(run["stderr_base64"]))

"""Capture the routing review once with an explicitly bounded input lifetime."""
import subprocess
import route as r

a = r.artifact()
assert not (r.ROOT / a.RAW).exists()
with a.materialized_original():
    command = ['python3', r.PREFIX + 'review.py', '--capture']
    run = subprocess.run(command, cwd=r.ROOT)
assert not (r.ROOT / a.RAW).exists()
assert run.returncode == 0, run.returncode

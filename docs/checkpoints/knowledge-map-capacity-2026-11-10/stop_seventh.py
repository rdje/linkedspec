"""Stop only the verified own canonical attempt; preserve process provenance."""
import gzip
import json
import os
from pathlib import Path
import signal
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT_PID = 77165
EXPECTED = '/opt/homebrew/bin/bash -c CARGO_BUILD_JOBS=1 bash tools/run_ci_local.sh > .linkedspec-data/knowledge-capacity-ci-seventh.log 2>&1'
command = subprocess.check_output(['ps', '-p', str(ROOT_PID), '-o', 'command='], text=True).strip()
assert command == EXPECTED, 'refuse an unrelated runner'
output = HERE / 'canonical-seventh-stop.json.gz'
assert not output.exists()
frozen = set()
snapshots = []
for _ in range(8):
    rows = [line.split(None, 2) for line in subprocess.check_output(['ps', '-axo', 'pid=,ppid=,comm='], text=True).splitlines()]
    tree = {ROOT_PID}
    while True:
        children = {int(pid) for pid, parent, _ in rows if int(parent) in tree}
        expanded = tree | children
        if expanded == tree: break
        tree = expanded
    selected = [dict(pid=int(pid), ppid=int(parent), comm=name) for pid, parent, name in rows if int(pid) in tree]
    snapshots.append(selected)
    added = tree - frozen
    for pid in sorted(added):
        try: os.kill(pid, signal.SIGSTOP)
        except ProcessLookupError: pass
    frozen |= tree
    output.write_bytes(gzip.compress(json.dumps(dict(root=ROOT_PID, verified_command=command, snapshots=snapshots, frozen=sorted(frozen)), sort_keys=True).encode(), mtime=0))
    if not added: break
else: raise AssertionError('process tree did not stabilize')
for sig in (signal.SIGTERM, signal.SIGCONT):
    for pid in sorted(frozen - {ROOT_PID}) + [ROOT_PID]:
        try: os.kill(pid, sig)
        except ProcessLookupError: pass
time.sleep(1)
remaining = []
for pid in sorted(frozen):
    result = subprocess.run(['ps', '-p', str(pid), '-o', 'stat='], capture_output=True, text=True)
    if result.returncode == 0 and result.stdout.strip() and not result.stdout.strip().startswith('Z'):
        remaining.append(pid)
assert not remaining, ('own process residue', remaining)
print(json.dumps(dict(result='stopped', root=ROOT_PID, processes=len(frozen), no_live_residue=True), sort_keys=True))

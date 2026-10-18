"""Readonly custody check of the historical warned-child kernel sample."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.4/'
record = json.loads((ROOT / (PREFIX + 'group-observation.json')).read_bytes())
source = json.loads(gzip.decompress((ROOT / (PREFIX + 'group-observation-source.json.gz')).read_bytes()))
raw = base64.b64decode(source['bytes_base64'], validate=True)
assert hashlib.sha256(raw).hexdigest() == source['sha256'] == record['producer_sha256']
assert source['path'] == PREFIX + 'group-observation.py' and source['mode'] == 0o644
assert record['repair_owner'] == 'SESSION-STARTUP-READING.7'
assert record['pid_from_actual_warning'] == record['pgid'] == 29169 and record['matches_warned_pid']
assert hashlib.sha256((ROOT / 'tools/project_data_run.sh').read_bytes()).hexdigest() == record['wrapper_sha256']
assert b'child setpgid (29169 to 29169): Operation not permitted\n' in base64.b64decode(
    record['actual_launch_tool_output_base64'], validate=True)
print('Historical warned-child sample retained: numeric PID/PGID match; cause/lifecycle guarantees unassessed')

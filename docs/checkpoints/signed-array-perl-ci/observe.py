"""Fresh-process actual governance verifier against independently supplied CI bytes."""
import base64
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

path = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location("signed_ci_observed_audit", path)
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
plan = json.load(sys.stdin)
rows = []
for case in plan["cases"]:
    raw = base64.b64decode(case["ci_base64"])
    try:
        result = audit.verify_governance_evolution("tools/run_ci_local.sh", raw, plan["historical_hash"])
    except ValueError as error:
        rows.append(dict(id=case["id"], accepted=False, error=str(error)))
    else:
        rows.append(dict(id=case["id"], accepted=True, result=result))
print(json.dumps(dict(auditor_sha256=hashlib.sha256(path.read_bytes()).hexdigest(), rows=rows), sort_keys=True))

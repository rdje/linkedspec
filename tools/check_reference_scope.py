"""Verify complete maintained-reference scope against one stable repository view."""
import argparse
from reference_scope import Snapshot, verify

parser = argparse.ArgumentParser(description=__doc__)
parser.parse_args()
snapshot = Snapshot()
try:
    members, pages = verify(snapshot)
    snapshot.finish()
except Exception as error:
    snapshot.abort()
    parser.exit(1, f"reference-scope: FAIL: {error}\n")
print(f"reference-scope: PASS {members} declared members / {pages} bounded pages")

"""Retain the deliberately superseded gate; it made no canonical admission."""
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

first=c.load('admission/first.json.gz')
assert c.unchanged(first['inputs'])
log=c.read('.linkedspec-data/verification/type-drop-canonical.log')
status=c.read('.linkedspec-data/verification/type-drop-canonical.status')
assert c.decode(status['base64']).strip()==b'143'
assert b'[ci] local CI gate passed' not in c.decode(log['base64'])
c.write_new('admission/canonical-abort.json.gz',dict(log=log,status=status,
    wrapper_pid=71195,child_process_group=71563,actual_joined_exit=143,
    producer=c.read(c.PREFIX+'admission/record_abort.py'),
    reason='Final review found a stale current fact reverify and missing drop inverse record. '
           'Preserve the first unpublished candidate and actual readonly0, then stop only its '
           'identified canonical wrapper through documented TERM forwarding before any bound edit. '
           'The gate was superseded, not accepted; runtime implementation and prior observations remain unchanged.'))
print('Superseded canonical143 and full first-candidate log retained before bound corrections')

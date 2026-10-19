"""Retain and review the completed unchanged host-oracle validation."""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/knowledge-fields'))
import common as c

PREFIX = 'docs/checkpoints/knowledge-fields-canonical2/'
SOURCE = 'tools/test_project_data_process_locality.sh'
assert sys.argv[1:] in ([], ['--capture'])
expected = (b'[project-data-process-test] relocated six-family driver passed\n'
    b'[project-data-process-test] PASS: relocated Perl/Rust/Dart/Julia/Lua/tool IO is repository-contained\n')
if sys.argv[1:]:
    log = c.read('.linkedspec-data/verification/knowledge-fields-process-locality-host.log')
    assert c.decode(log['base64']) == expected
    source = c.read(SOURCE)
    assert c.decode(source['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + SOURCE], cwd=ROOT)
    c.write_new(PREFIX + 'host-result.json', dict(result='PASS', observed_tool_exit=0,
        command=['bash', SOURCE], execution='approved host execution; original oracle profile intact',
        actual_shell_command='bash tools/test_project_data_process_locality.sh > .linkedspec-data/verification/knowledge-fields-process-locality-host.log 2>&1',
        complete_combined_log=log, oracle=source, base_commit=c.BASE,
        producer_sha256=c.sha(Path(__file__).read_bytes()),
        scope='Reverification of the documented execution prerequisite after canonical2 exit1. '
              'Actual tool session9554 completed0. This targeted success does not supply a canonical '
              'receipt or establish a new general kernel/process/lifecycle claim. The exact fully '
              'staged candidate must run complete canonical CI in approved host execution.'))
record = json.loads((ROOT / (PREFIX + 'host-result.json')).read_bytes())
assert record['result'] == 'PASS' and record['observed_tool_exit'] == 0
assert record['command'] == ['bash', SOURCE] and record['base_commit'] == c.BASE
assert record['producer_sha256'] == c.sha(Path(__file__).read_bytes())
assert c.decode(record['complete_combined_log']['base64']) == expected
assert c.sha(expected) == record['complete_combined_log']['sha256']
assert c.decode(record['oracle']['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + SOURCE], cwd=ROOT)
assert c.sha(c.decode(record['oracle']['base64'])) == record['oracle']['sha256']
print('Host-oracle retained result PASS: unchanged six-family driver/profile; fresh canonical receipt still required')

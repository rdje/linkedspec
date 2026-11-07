"""Check only the changed path-fact, task and final handoff metadata."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
OUT = BASE / 'storage-doc-checks'
OUT.mkdir()
commands = (
    ('knowledge-map', ['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']),
    ('change-history', ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']),
    ('engineering-history', ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--check']),
    ('memory', ['bash', 'scripts/check_memory_architecture.sh']),
    ('reference-scope', ['bash', 'tools/run_python_project_data.sh', 'tools/update_reference_scope.py', '--owner', 'TYPE-REFERENCE-BOOK.1.2.23.3.78.2']),
    ('diff', ['git', 'diff', '--check']),
)
for tag, command in commands:
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag + ' failed; first channels preserved'
    print(tag + ':0', flush=True)

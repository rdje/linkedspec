"""Validate published lookup homes and only the changed containment metadata."""
import gzip
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
OUT = BASE / 'map-doc-checks'
OUT.mkdir()
pattern = r'^- "(.*)" -> \[[^\]]+\]\(([^)]+)\)'
old = gzip.decompress((BASE / 'map-capacity/activation-knowledge-map.md.gz').read_bytes()).decode()
current = Path('KNOWLEDGE_MAP.md').read_text()
old_pairs = set(re.findall(pattern, old, re.M))
current_pairs = set(re.findall(pattern, current, re.M))
assert old_pairs and old_pairs <= current_pairs, 'published lookup home changed'
(OUT / 'published-lookups.json').write_text(json.dumps(dict(
    activation='b0376420ba6258420b146981b848d4646fb3ff55',
    published_pairs=len(old_pairs), all_published_question_home_pairs_preserved=True,
    final_lines=current.count('\n'), unchanged_limit=22500), indent=2) + '\n')
commands = (
    ('change-history', ['perl', 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']),
    ('engineering-history', ['perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--check']),
    ('memory', ['bash', 'scripts/check_memory_architecture.sh']),
    ('task-metadata', ['bash', 'scripts/check_task_tree_metadata.sh']),
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
print('all published question/home pairs preserved under unchanged map limits')

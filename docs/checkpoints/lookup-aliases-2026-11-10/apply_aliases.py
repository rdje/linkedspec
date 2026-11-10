"""Append authored aliases without changing any existing fact bytes."""
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = 'bcd02e8516a650aa24928f3351b088c63db66509'
aliases = json.loads((HERE / 'aliases.json').read_bytes())
old_map = subprocess.check_output(['git', 'show', BASE + ':KNOWLEDGE_MAP.md'], cwd=ROOT).decode()
questions = [question for values in aliases.values() for question in values]
assert len(questions) == len(set(questions))
for question in questions:
    assert '- ' + json.dumps(question) + ' -> ' not in old_map, 'pre-existing question'
for name, questions in aliases.items():
    relative = 'docs/knowledge/' + name + '.md'
    path = ROOT / relative
    original = subprocess.check_output(['git', 'show', BASE + ':' + relative], cwd=ROOT).decode()
    assert path.read_text() == original, 'one-shot source-preserving append'
    header_end = original.index('\n---\n', 4)
    lines = original[:header_end].splitlines(keepends=True)
    start = next(index for index, line in enumerate(lines) if line == 'answers:\n') + 1
    end = start
    while end < len(lines) and lines[end].startswith('  '):
        end += 1
    position = sum(map(len, lines[:end]))
    additions = ''.join('  - ' + json.dumps(question) + '\n' for question in questions)
    updated = original[:position] + additions + original[position:]
    if name == 'normal-hook-archive-reference-contracts':
        updated += (HERE / 'header-note.txt').read_text()
    path.write_text(updated)
print('Authored aliases appended; original source prefixes and suffixes retained.')

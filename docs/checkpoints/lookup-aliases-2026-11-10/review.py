"""Verify exact authored routing against the accepted source and public map."""
from collections import Counter
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = 'bcd02e8516a650aa24928f3351b088c63db66509'
MARKER = '\n## Facts (by id)\n'


def original(name):
    return subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT).decode()


def validate_map(before, after, aliases):
    old_questions, old_facts = before.split(MARKER, 1)
    new_questions, new_facts = after.split(MARKER, 1)
    assert old_facts == new_facts, 'Facts projection changed'
    rows = lambda text: Counter(line for line in text.splitlines() if line.startswith('- "'))
    old, new = rows(old_questions), rows(new_questions)
    assert not (old - new), 'original question route lost'
    extra = new - old
    expected = Counter()
    for name, questions in aliases.items():
        for question in questions:
            prefix = '- ' + json.dumps(question) + ' -> [' + name + ']'
            matches = [line for line in extra if line.startswith(prefix)]
            assert len(matches) == 1, 'new alias target missing or ambiguous'
            line = matches[0]
            assert '(docs/knowledge/' + name + '.md)' in line
            expected[line] += 1
    assert extra == expected, 'unexpected question route delta'
    assert new == old + expected, 'question multiplicity changed'
    pattern = r'^> \*\*(\d+)\*\* facts · \*\*(\d+)\*\* question keys\.$'
    old_header = re.findall(pattern, before, re.M)
    new_header = re.findall(pattern, after, re.M)
    assert len(old_header) == len(new_header) == 1
    assert old_header[0][0] == new_header[0][0], 'fact total changed'
    assert int(old_header[0][1]) == sum(old.values()), 'old question total mismatch'
    assert int(new_header[0][1]) == sum(new.values()), 'new question total mismatch'
    header = lambda row: '> **' + row[0] + '** facts · **' + row[1] + '** question keys.'
    restored = after.replace(header(new_header[0]), header(old_header[0]), 1)
    for line, repetitions in expected.items():
        for _ in range(repetitions):
            restored = restored.replace(line + '\n', '', 1)
    assert restored == before, 'non-alias projection bytes changed'


def review():
    aliases = json.loads((HERE / 'aliases.json').read_bytes())
    authored = [question for questions in aliases.values() for question in questions]
    assert len(authored) == len(set(authored)), 'duplicate authored alias'
    before_map = original('KNOWLEDGE_MAP.md')
    for question in authored:
        assert '- ' + json.dumps(question) + ' -> ' not in before_map, 'pre-existing alias'
    for name, questions in aliases.items():
        path = 'docs/knowledge/' + name + '.md'
        before = original(path)
        after = (ROOT / path).read_text()
        additions = ''.join('  - ' + json.dumps(question) + '\n' for question in questions)
        if name == 'normal-hook-archive-reference-contracts':
            note = (HERE / 'header-note.txt').read_text()
            assert after.endswith(note)
            after = after[:-len(note)]
        assert after.count(additions) == 1
        assert after.replace(additions, '', 1) == before, 'original fact source changed'
        assert after.index(additions) < after.index('\n---\n', 4)
    before = before_map
    after = (ROOT / 'KNOWLEDGE_MAP.md').read_text()
    validate_map(before, after, aliases)
    rejected = []
    old_route = next(line for line in before.splitlines() if line.startswith('- "'))
    first_name, questions = next(iter(aliases.items()))
    prefix = '- ' + json.dumps(questions[0]) + ' -> [' + first_name + ']'
    new_route = next(line for line in after.splitlines() if line.startswith(prefix))
    header = lambda text: next(line for line in text.splitlines()
                              if re.match(r'^> \*\*\d+\*\* facts', line))
    for label, candidate in (
        ('lost-original-route', after.replace(old_route + '\n', '', 1)),
        ('wrong-new-target', after.replace(new_route, new_route.replace('[' + first_name + ']', '[unrelated-fact]', 1), 1)),
        ('stale-question-total', after.replace(header(after), header(before), 1)),
        ('changed-facts', after + '\nchanged fact\n')):
        try:
            validate_map(before, candidate, aliases)
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('routing corruption admitted: ' + label)
    return dict(result='PASS', original_fact_source='preserved with explicit aliases and append-only header note',
        original_route_multiplicity='preserved', facts_projection='byte-exact',
        authored_targets='exact', rejected_controls=rejected,
        scope='Authored navigation/preservation only; no new runtime/population or evidence-admission measurement.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))

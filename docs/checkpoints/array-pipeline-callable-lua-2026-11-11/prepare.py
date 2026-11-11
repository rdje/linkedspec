"""Author safe installed-Lua source questions; import no peer outcome policy."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '9a6b229ce3f944ef3822e71935b1c40c109f74b9'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
prior = Path('docs/checkpoints/array-pipeline-result-guard-lua-2026-11-11/prepare.py')
raw = prior.read_bytes()
assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(prior)])
(BASE / 'ordinary-prepare.py.gz').write_bytes(gzip.compress(raw, mtime=0))
text = raw.decode().split('shared = json.loads(')[0]
replacements = [
    ('2d764b05f76e7d7359fe8dcd75b78f1765aa678f', ACTIVATION),
    ("source='Value:: I {' + body", "source='fn supply(seed) {return(seed)}\\n\\nValue:: I {' + body"),
    ("    arguments = [", "    source = 'supply(' + source + ')'\n    arguments = ["),
    ("helper + '([\"head\"])'", "helper + '(supply([\"head\"]))'"),
    ("'[\"head\"].' + helper", "'supply([\"head\"]).' + helper"),
    ("('count', '[1].count()')", "('count', 'supply([1]).count()')"),
    ("('key_count', '{\"a\":1}.count_keys()')", "('key_count', 'supply({\"a\":1}).count_keys()')"),
    ("('length', '\"abc\".length()')", "('length', 'supply(\"abc\").length()')"),
    ("('hash', 'set_key({},\"k\",1)')", "('hash', 'set_key(supply({}),\"k\",1)')"),
    ("('copy', 'copy(3)')", "('copy', 'copy(supply(3))')"),
    ("('view', 'sorted_keys({\"a\":1})')", "('view', 'sorted_keys(supply({\"a\":1}))')"),
    ("'[\"head:tail\"].split_each", "'supply([\"head:tail\"]).split_each"),
    ("'split_each([\"head:tail\"],", "'split_each(supply([\"head:tail\"]),"),
    ("'[\"head\"].filter_match", "'supply([\"head\"]).filter_match"),
    ("'filter_match([\"head\"],", "'filter_match(supply([\"head\"]),"),
    ('out=uniq(source);return([out,source])', 'out=uniq(supply(source));return([out,source])'),
    ('trim_each(source),filter_nonempty(source),uniq(source),source',
        'trim_each(supply(source)),filter_nonempty(supply(source)),uniq(supply(source)),source'),
]
for old, new in replacements:
    assert text.count(old) == 1, old
    text = text.replace(old, new)
text += "(BASE / 'profile-sources.json').write_text(json.dumps(rows, indent=2) + '\\n')\nprint('Authored137 own Lua callable source questions with safe pattern-operand errors')\n"
generator = BASE / 'own_questions.py'
assert not generator.exists()
generator.write_text(text)
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(generator)]
(BASE / 'preparation-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=ROOT)
for channel in ('stdout', 'stderr'):
    (BASE / ('preparation-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'preparation-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b''
identities = {str(prior): dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())}
questions = json.loads((BASE / 'profile-sources.json').read_bytes())
for name in ('signature-sources.json', 'pattern-sources.json'):
    source = Path('docs/checkpoints/array-pipeline-callable-julia-2026-11-11') / name
    body = source.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(source)])
    (BASE / ('source-only-' + name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
    rows = json.loads(body)
    assert len(rows) == 10 and all('expected' not in row and 'actual' not in row for row in rows)
    identities[str(source)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
    (BASE / name).write_bytes(body)
    questions += rows
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
assert len(shared) == 37
cases = shared + questions
assert len(cases) == len({row['id'] for row in cases}) == 194
assert all('[z-a]' not in row['source'] and 'invalid_range' not in row['id'] for row in cases)
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'template-identities.json').write_text(json.dumps(identities, indent=2) + '\n')
print('Safe shared37/own137/signature10/pattern10 authored; no peer outcomes imported')

"""Author separate terminal counterparts; preserve the original240 unchanged."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
assert not (HERE / 'terminal-cases.json').exists()
raw = (HERE / 'cases.json').read_bytes()
(HERE / 'terminal-case-source.json.gz').write_bytes(gzip.compress(raw, mtime=0))
original = json.loads(raw)
consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
tail = '.with(){order=cat(order,"W");return("ran")}'
rows = []
for old in original:
    if not old['id'].startswith('own_') or old.get('question') not in ('excluded-helper-arity', 'needed-source-error', 'needed-operand-error'):
        continue
    row = copy.deepcopy(old)
    body = old['body']
    if old['question'] == 'excluded-helper-arity':
        assert body.startswith('order="";out=') and body.endswith(';return([out,order])')
        expression = body[len('order="";out='):-len(';return([out,order])')]
        assert expression.endswith(tail)
        expression = expression[:-len(tail)]
        if consumer in expression:
            assert expression.endswith(consumer)
            expression = expression[:-len(consumer)]
    else:
        assert body.startswith('order="";return(') and body.endswith(')')
        expression = body[len('order="";return('):-1]
        ending = consumer + '.coalesce("masked")'
        assert expression.endswith(ending)
        expression = expression[:-len(ending)]
    row['id'] = old['id'] + '_terminal_probe'
    row['paired_with'] = old['id']
    row['body'] = 'order="";out=' + expression + ';return([out,order])'
    prefix = old['source'].split('\n\nValue:: I {', 1)[0]
    row['source'] = prefix + '\n\nValue:: I {' + row['body'] + '}\n'
    row['question'] = old['question'] + '-terminal'
    rows.append(row)
assert len(rows) == len({row['id'] for row in rows}) == 48
(HERE / 'terminal-cases.json').write_text(json.dumps(rows, indent=2) + '\n')
templates = {}
for name in ('observer.pl', 'capture.py'):
    body = (HERE / name).read_bytes()
    target = HERE / ('terminal-' + name + '-template.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    templates[str(BASE / name)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
observer = (HERE / 'observer.pl').read_text()
assert observer.count(str(BASE / 'cases.json')) == 1
(HERE / 'terminal_observer.pl').write_text(observer.replace(str(BASE / 'cases.json'), str(BASE / 'terminal-cases.json')))
capture = (HERE / 'capture.py').read_text()
assert capture.count("OUT = BASE / 'intake'") == 1
capture = capture.replace("OUT = BASE / 'intake'", "OUT = BASE / 'terminal'")
assert capture.count("'cases.json'") == capture.count("'observer.pl'") == 2
capture = capture.replace("'cases.json'", "'terminal-cases.json'").replace("'observer.pl'", "'terminal_observer.pl'")
needle = 'records = {}'
assert capture.count(needle) == 1
capture = capture.replace(needle, "paths += [BASE / name for name in ('capture_terminal.py', 'prepare_terminal.py', 'run_extra.py',\n"
    "    'terminal-preparation.json', 'terminal-case-source.json.gz',\n"
    "    'terminal-observer.pl-template.gz', 'terminal-capture.py-template.gz',\n"
    "    'extra-capture-producer-images.json.gz', 'cases.json', 'observer.pl')]\n" + needle)
(HERE / 'capture_terminal.py').write_text(capture)
(HERE / 'terminal-preparation.json').write_text(json.dumps(dict(original_questions=len(original),
    terminal_questions=len(rows), groups={q:sum(row['question']==q for row in rows) for q in sorted({row['question'] for row in rows})},
    source_sha256=hashlib.sha256(raw).hexdigest(), templates=templates,
    scope='Separate terminal oracle acquisition only; no original source, observation, expectation or SDK body is changed.'), indent=2) + '\n')
print(json.dumps(dict(result='PASS', original_questions=len(original), terminal_questions=len(rows),
    next='new source-bound terminal capture before classification'), sort_keys=True))

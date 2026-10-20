"""Record the verified historical inverse and contributor procedure with bounded facts."""
import datetime
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
FACT = 'docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
review = json.loads((ROOT / (P + 'historical-final-review.json')).read_bytes())
assert review['result'] == 'PASS' and review['input_bytes_modes_unchanged']
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert c.read(c.CLAIM) == preserved['original_claim']
before = {path: c.read(path) for path in (FACT, BOOK)}
assert before[FACT] == preserved['before'][FACT]
assert all(before[BOOK][key] == preserved['inputs'][BOOK][key] for key in ('sha256', 'mode'))
fact = c.decode(before[FACT]['base64']).decode()
lines = fact.splitlines(keepends=True)
fields = dict(title='"Historical Phase0 audits admit exact reviewed source inverses"',
              date=datetime.datetime.now(datetime.timezone.utc).date().isoformat(), status='current')
for key, value in fields.items():
    selected = [i for i, line in enumerate(lines) if line.startswith(key + ': ')]
    assert len(selected) == 1
    lines[selected[0]] = key + ': ' + value + '\n'
fact = ''.join(lines)
start = fact.index('reverify:\n')
end = fact.index('\n---\n', start)
assert sum(line.startswith('  - ') for line in fact[start:end].splitlines()) == 2
fact = fact[:start] + ('reverify:\n'
    '  - "bash tools/run_python_project_data.sh docs/checkpoints/type-evaluated-values/publish.py"\n'
    '  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"') + fact[end:]
fact += (f"\nThe evaluated-value admission adds an exact inverse of {review['fragments']} reviewed\n"
    f"Phase0 fragments relative to real c053 source. All {review['original_controls']['governance_mutations_rejected']} original controls\n"
    f"remain effective; {review['added_source_denials']} fragment denials and a valid-JSON whitespace\n"
    "identity fault reject. The full historical hash, archive recovery and zero\n"
    "original-log/tracked-write boundary remain unchanged. The first added-control\n"
    "KeyError and two-reference correction stay separate in\n"
    "docs/checkpoints/type-values-signature/. Both reverify routes are readonly.\n")
book = c.decode(before[BOOK]['base64']).decode()
book += ("\nHistorical audits keep the original executable source hashes when test\n"
    "representations evolve. Give each reviewed delta an owning task and an exact\n"
    "inverse that recovers the complete original file. Keep the existing denial\n"
    "controls and add missing, duplicated, altered and unrelated-edit controls.\n"
    "Retain the inverse table as an explicit input to the recurring proof, then\n"
    "run that proof before retrying canonical CI. Preserve rejected instruments\n"
    "and their channels separately from behavioral RED evidence.\n")
texts = {FACT: fact, BOOK: book}
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before[path]['mode'])
         for path, text in texts.items()}
graph = json.loads(gzip.decompress((ROOT / (c.PREFIX + 'graph-phase0-inputs.json.gz')).read_bytes()))['inputs']
assert graph[FACT] == before[FACT]
old_bytes = sum(len(c.decode(item['base64'])) for path, item in graph.items() if path.startswith('docs/knowledge/'))
new_bytes = old_bytes + len(fact.encode()) - len(c.decode(before[FACT]['base64']))
assert new_bytes <= 8388608, (old_bytes, new_bytes)
c.write_new(P + 'docs-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'docs.py'), knowledge_bytes_before=old_bytes, knowledge_bytes_after=new_bytes,
    scope='Existing fact reused. Both reverify list items remain and now select readonly '
          'current proof; the original routes and bytes remain recoverable. The book '
          'explains the source-integrity procedure. No fact/question/list-item count '
          'or budget increase; new graph/book observations are separate.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
    assert c.read(path) == item
print('Historical inverse fact/book updated; knowledge bytes', new_bytes, '/8388608')

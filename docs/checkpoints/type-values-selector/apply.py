"""Admit only exact reviewed diagnostic-test revisions; keep all historical hashes intact."""
import ast
import gzip
import json
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-selector/'
saved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
baseline = json.loads((ROOT / (P + 'baseline.json')).read_bytes())
assert baseline['run']['returncode'] == 0 and baseline['inputs_bytes_modes_unchanged']
assert c.read(c.CLAIM) == baseline['claim'] == saved['original_claim']
scanner = 'tools/check_executable_aggregate_selector_sources.py'
before = c.read(scanner)
assert before == saved['before'][scanner]
namespace = runpy.run_path(str(ROOT / scanner))
paths = ('t/actionir_method_general_return_capture.t', 't/actionir_small_kind_capture.t',
         't/actionir_source_assignment_kind_capture.t')
fixtures = {}
rows = []
for path in paths:
    old = c.run(['git', 'show', c.BASE + ':' + path])
    assert old['returncode'] == 0
    historical = c.decode(old['stdout_base64'])
    current = c.read(path)
    prior = c.sha(historical)
    assert namespace['HISTORICAL_DIAGNOSTIC_INPUTS'][path] == prior
    occurrences = namespace['SELECTOR'].findall(historical.decode())
    assert occurrences and occurrences == namespace['SELECTOR'].findall(c.decode(current['base64']).decode())
    fixtures[path] = dict(original=old, current=current, occurrences=occurrences)
    rows.append(f"    {path!r}: (\n        {c.OWNER!r},\n        {prior!r},\n"
                f"        {current['sha256']!r},\n    ),\n")
text = c.decode(before['base64']).decode()
anchor = 'SELECTOR = re.compile(\n'
assert text.count(anchor) == 1
text = text.replace(anchor,
    '# Exact owned revisions of maintained diagnostic consumers. Historical registrations\n'
    '# remain unchanged; edited bytes, copied paths and foreign owners do not qualify.\n'
    'REVIEWED_DIAGNOSTIC_EVOLUTIONS = {\n' + ''.join(rows) + '}\n' + anchor, 1)
old = '''    if historical_digest is not None:
        return hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == historical_digest
'''
new = '''    if historical_digest is not None:
        digest = hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
        if digest == historical_digest:
            return True
        evolved = REVIEWED_DIAGNOSTIC_EVOLUTIONS.get(path)
        return (evolved is not None
                and evolved[0] == 'TYPE-REFERENCE-BOOK.1.2.3'
                and evolved[1] == historical_digest
                and evolved[2] == digest)
'''
assert text.count(old) == 1
text = text.replace(old, new, 1)
ast.parse(text, filename=scanner)
after = dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before['mode'])
c.write_new(P + 'proposals.json.gz', dict(before={scanner: before}, after={scanner: after},
    fixtures=fixtures, producer=c.read(P + 'apply.py'),
    scope='Each original registration remains exact. A separate owner/prior/current '
          'triple admits only three reviewed current test files with identical selector '
          'occurrences. No public syntax, selector regex, generic compatibility branch '
          'or original diagnostic capture/hash changes.'), packed=True)
assert c.read(scanner) == before
(ROOT / scanner).write_bytes(text.encode())
(ROOT / scanner).chmod(before['mode'])
assert c.read(scanner) == after
print('Three exact owned diagnostic revisions admitted; original registry unchanged')

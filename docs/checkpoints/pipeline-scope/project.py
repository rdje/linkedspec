"""One-shot preflight and lossless transport/current documentation projection."""
import json
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, CLAIM, NATIVE, CARD, WORKFLOW, load, load_namespace, native_view, sha, encode, decode

original = load()
namespace = load_namespace(original)
assert len(namespace['inputs']) == len(namespace['added_names']) == 161
replay = json.loads((ROOT / (PREFIX + 'replay-final.json')).read_bytes())
assert replay['returncode'] == 0 and not decode(replay['stderr_base64'])
assert replay['original_inputs_unchanged'] and replay['claim_sha256'] == original['claim_sha256']
for path, item in original['inputs'].items():
    source = ROOT / path
    assert sha(source.read_bytes()) == item['sha256'] and source.stat().st_mode & 0o7777 == item['mode']
assert (ROOT / CLAIM).read_bytes() == decode(original['claim_base64'])
preparation = json.loads(decode(original['inputs'][OLD + 'documentation-preparation.json']['base64']))
cards = preparation['changed_cards']
assert len(cards) == 15 and CARD in cards
values = {path: decode(original['inputs'][path]['base64']) for path in cards + [WORKFLOW]}
old_values = dict(values)
for path in cards:
    header, body = values[path].split(b'\n---\n', 1)
    assert header.count((OLD + 'publish.py').encode()) == 1
    header = header.replace((OLD + 'publish.py').encode(), (PREFIX + 'publish.py').encode())
    if path == CARD:
        marker = b'date: 2026-10-18\n'
        assert header.count(marker) == 1
        header = header.replace(marker,
            b'  - "why does a captured native include argument fail repository portability"\n'
            b'  - "does the pipeline625 publication bind its raw current claim namespace"\n' + marker)
        body += b'''
Pipeline .6 captured its actual runtime-derived Perl include argument as plain
JSON text; the unchanged path gate rejects that transport. A standard JSON
solidus-escaped view preserves every decoded value, argument and raw observation.
The complete original bytes remain recoverable, and the inverse is checked.
The original uncommitted625-binding/123401-byte draft and its actual readonly
baseline are retained without inventing a Git revision. Restoring it exposes an
undeclared fixed claim namespace: unchanged review-runtime-final.py reads raw
claims that review-current.py omitted from its input union. A distinct pre-write
supplement supplies all161 fixed-BASE claims, including the actual .7 freeze;
the corrected original-reader replay passes. Current verification checks the
transport and documentation separately. No native writer is replayed, and no
observed diagnostic or argument becomes an operational repository root.
'''
    values[path] = header + b'\n---\n' + body
section = b'''### Pipeline observation transport

The native load-context record retains the actual include argument used by Perl.
Its standard JSON transport escapes solidus characters without changing any
decoded value. Exact original bytes, arguments and channels remain recoverable;
the unchanged original readers verify a restored copy on repository storage.

That restoration exposed an input declaration gap. The original draft declared
625 bindings in 123,401 bytes, but its reader also inspected a fixed Git claim
namespace. The current proof supplies all 161 missing claim inputs, including the
actual prior-claim freeze, and retains the first failed replay. It gives no Git
revision to the original uncommitted draft. Original runtime measurements keep
their original sources and dates; the current factory suite also checks the
decoded transport. Production code, the path gate and native observations stay
unchanged by this representation repair.

'''
marker = b'### Historical claim populations\n'
assert values[WORKFLOW].count(marker) == 1
values[WORKFLOW] = values[WORKFLOW].replace(marker, section + marker)
total = sum(path.stat().st_size for path in (ROOT / 'docs/knowledge').rglob('*.md'))
assert total == 8384111
total += sum(len(values[path]) - len(old_values[path]) for path in cards)
assert total <= 8388608, ('unchanged Knowledge cap', total)
proposal = {NATIVE: native_view(original), **values}
report = dict(result='PASS', base='uncommitted625 draft; activation64b66167c is earlier',
              original_claim_sha256=original['claim_sha256'], original_declared_inputs=625,
              supplied_claim_namespace=161, changed_cards=cards, changed_body_from_draft=[CARD],
              knowledge_bytes=total, proposed={path: dict(base64=encode(value), sha256=sha(value),
                  mode=original['inputs'][path]['mode']) for path, value in proposal.items()},
              originals={path: original['inputs'][path] for path in proposal},
              producer_sha256=sha(Path(__file__).read_bytes()),
              scope='Complete actual proposal is serialized before bound writes. Native view uses '
                    'standard JSON solidus escaping, with decoded equality and exact byte inverse. '
                    'Fifteen current routes and one card body change; runtime source/observations, '
                    'old producers/readers and all original rendered tables remain archived exactly.')
with (ROOT / (PREFIX + 'projection-preflight.json')).open('x') as output:
    output.write(json.dumps(report, indent=1) + '\n')
for path, value in proposal.items():
    (ROOT / path).write_bytes(value)
print('Lossless native transport and current documentation projected; Knowledge bytes:', total)

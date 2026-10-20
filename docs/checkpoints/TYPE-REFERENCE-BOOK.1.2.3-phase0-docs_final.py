"""Retain current known-limit and Phase0 compatibility documentation before writes."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
chapter = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
fact = 'docs/knowledge/terse-type-method-surface-inventory.md'
readme = c.PREFIX + 'README.md'
before = {path: c.read(path) for path in (chapter, fact, readme)}
for path, item in before.items():
    assert all(item[key] == preserved['identities'][path][key] for key in ('sha256', 'mode'))
texts = {path: c.decode(item['base64']).decode() for path, item in before.items()}
assert texts[chapter].count('### Current Perl deferred-body limits') == 1
texts[chapter] = texts[chapter].replace('### Current Perl deferred-body limits', '### Current Perl limits', 1)
marker = '## Per-rule default accumulator'
assert texts[chapter].count(marker) == 1
texts[chapter] = texts[chapter].replace(marker, (
    'Loading generated Perl for §drop_keys(meta, "debug")§ with one literal key\n'
    'currently emits a scalar hash-slice compiler advisory, while returning the\n'
    'correct harray. A caller that treats syntax warnings as fatal cannot load\n'
    'that generated parser. This known compiler-diagnostic repair is pending.\n\n'
    + marker).replace('§', chr(96)), 1)
assert texts[fact].count('date: 2026-10-19\n') == 1
texts[fact] = texts[fact].replace('date: 2026-10-19\n',
    '  - "does Perl drop_keys warn for a single literal key"\ndate: 2026-10-19\n', 1)
marker = 'The complete July4 table'
assert texts[fact].count(marker) == 1
texts[fact] = texts[fact].replace(marker, (
    'The complete original Phase0 run retains140 source-spelling assertion failures\n'
    'and one wrong-invocation volume failure; the temporary fixture cleanup passes.\n'
    'Separate source-bound historical/manual fixtures retain130 value goldens and\n'
    'two explicitly attributed compiler advisories. Their values are independent\n'
    'of the candidate lowering producer. Public descriptor/Get succeed quietly for\n'
    'single-key drop_keys; generated loading warns, and a caller fatal syntax\n'
    'profile rejects it. Actual emitted delete @__ls_drop{"debug"} maps to the\n'
    'MethodLowering drop_keys producer. TYPE-REFERENCE-BOOK.1.2.6 owns the separate\n'
    'repair after .1.2.4/.1.2.5 and before full enumeration. No warning gate changes.\n\n'
    + marker), 1)
old = 'remain exact; publication-final.json is the current receipt.'
assert texts[readme].count(old) == 1
texts[readme] = texts[readme].replace(old,
    'remain exact; publication-final.json retains the second draft.\n'
    'publication-phase0.json is the current receipt.', 1)
texts[readme] += (
    '\nPhase0 follow-up artifacts use the sibling TYPE-REFERENCE-BOOK.1.2.3-phase0-\n'
    'prefix. The whole second573/full92573 draft and actual readonly baseline\n'
    'precede bound edits. The original bare1035 run is retained with52 failing\n'
    'roots:140 obsolete source-spelling assertions and a wrapper-bypass volume\n'
    'failure, whose explicit fixture cleanup passes. The final test source keeps\n'
    'all plans and native/descriptor/fluent checks, uses130 literal value and\n'
    'diagnostic goldens, nine binding/API regexes and one projection identity.\n'
    'Goldens come from accepted historical test source and independent manual\n'
    'fixtures, never the candidate producer. Original preparation, package-loader\n'
    'and zero-stderr postcondition failures remain exact. A separate instrument\n'
    'attributes both actual compiler advisories without suppressing them.\n'
    'Full wrapped Phase0 and canonical exact-candidate admission are required.\n'
    'Public single-key drop_keys generated warning/FATAL loading failure is owned\n'
    'by .1.2.6; it is not silently closed by the evaluated-value repair.\n')
after = {}
for path, text in texts.items():
    raw = text.encode()
    after[path] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before[path]['mode'])
c.write_new(P + 'docs-proposals-final.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'docs_final.py'),
    rejected_producer=c.read(P + 'docs.py'),
    rejected_combined_output=c.read('.linkedspec-data/verification/type-values-phase0-docs.log'), helper=c.read(c.PREFIX + 'common.py'),
    public_diagnostic=c.read(P + 'warning-routes-run.json.gz'),
    scope='Full actual old573-bound documentation bytes/modes precede these additional declared '
          'proposals. The original inventory/book/graph and both publication epochs remain immutable. '
          'New current warning limit is separately owned by .1.2.6; no runtime or warning gate edits.'), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    assert c.read(path) == item
print('Current compiler-diagnostic limit and Phase0 evidence documented with full before/after custody')

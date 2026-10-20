"""Preserve the first complete documentation epoch, then repair its reverify routing."""
import common as c

card = 'docs/knowledge/terse-type-method-surface-inventory.md'
readme = 'docs/checkpoints/type-evaluated-values/README.md'
actor = c.PREFIX + 'doc_check.py'
before = {path: c.read(path) for path in (card, readme, actor)}
text = {path: c.decode(item['base64']).decode() for path, item in before.items()}
old = 'docs/checkpoints/type-evaluated-values/publish.py'
new = 'docs/checkpoints/type-scoped-with/publish.py'
assert text[card].count(old) == 1
after = {card: text[card].replace(old, new).replace('date: 2026-10-19', 'date: 2026-10-20')}
after[readme] = text[readme].replace('# Perl evaluated-value repair\n', '# Perl evaluated-value repair\n\n'
    'Historical capture: TYPE-REFERENCE-BOOK.1.2.4 freezes this whole claim at accepted Git '
    '2fca7d8489038c226fe0454a105f12a2af696a1f after an actual clean readonly pass. '
    'Recover the original bytes from that revision and full modes from its receipt in an isolated '
    'same-volume workspace when replaying it. The current scoped proof is '
    'docs/checkpoints/type-scoped-with/publish.py; its callable suite also retains evaluated-value regressions.\n', 1)
after[actor] = text[actor]
for old, new in (('doc-inputs.json', 'doc-final-inputs.json'),
                 ('doc-run.json.gz', 'doc-final-run.json.gz'),
                 ("['--capture']", "['--capture-final']")):
    assert old in after[actor]
    after[actor] = after[actor].replace(old, new)
c.write_new('doc-refinement.json.gz', dict(before=before,
    after={path: c.encode(value.encode()) for path, value in after.items()},
    original_inputs=c.identity(c.PREFIX + 'doc-inputs.json'),
    original_run=c.identity(c.PREFIX + 'doc-run.json.gz'),
    producer=c.read(c.PREFIX + 'doc_final.py'),
    scope='The first complete graph/book epoch remains immutable. Its exact actor and changed graph card '
          'bytes survive here. Current fact reverify routing follows the new publication; the old README '
          'explicitly identifies its real historical capture. Final graph/book identities precede fresh commands.'))
for path, value in after.items():
    (c.ROOT / path).write_text(value)
print('Historical reader notice and current fact routing repaired; first documentation epoch preserved')

"""One-shot bounded model clarification after complete accepted-proof preservation."""
import gzip
import json
import re
import common as c

preserved = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
assert c.read(c.OLD_CLAIM) == preserved['original']
for item in preserved['live'].values():
    for path, expected in item['inputs'].items():
        actual = c.read(path)
        assert all(actual[key] == expected[key] for key in ('sha256', 'mode'))
assert json.loads((c.ROOT / (c.PREFIX + 'migration-replay.json')).read_bytes())['result'] == 'PASS'

proposals = {}
path = 'docs/knowledge/terse-type-method-surface-inventory.md'
text = (c.ROOT / path).read_text()
text = text.replace('status: current\n', 'status: historical July4 inventory; current model qualified below\n', 1)
text = text.replace('Current receiver families:', 'Dated July4 receiver families (including spellings later retired):', 1)
text = text.replace('Booleans and flow-result values are terminal today.',
    'The July4 inventory described booleans and flow-result values as terminal.', 1)
text += '''
## October19 current model and repair boundaries

Uniform bindings hold scalar, array, harray or codeblock; integer/real notation does not
create separate binding namespaces. Strings, numbers, boolean and null remain distinct
primitive values. Numeric helpers reject boolean/null; numeric comparisons return 1/0,
while logical helpers preserve boolean kind. Scalar normalization accepts false as "0".
Current Perl probes show false.cat("q") = "0q" and false.with() retaining false: the
July4 terminal statement is historical, not a current blanket restriction.

Deferred codeblocks read current caller slots; eager blocks execute immediately.
A called codeblock's array result can feed sorted(); this does not establish codeblock
dot-methods. Actual emitted source isolates two owned Perl defects: array constructors
and codeblock arguments can read a scalar after a later callback mutates it (.1.2.3);
attached with creates $value but omits its callable-name projection (.1.2.4), silently
yielding null for value(). Explicit callback parameters or copying value to a named
binding work. Both repairs precede complete operation inventory under TYPE-REFERENCE-BOOK.
Full source/model evidence and limits: docs/checkpoints/type-reference-inventory/README.md.
'''
proposals[path] = text

path = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
text = (c.ROOT / path).read_text()
needle = '## Per-rule default accumulator\n'
assert text.count(needle) == 1
addition = '''## Value kinds, numeric notation and callable results

One working name holds one current value: scalar, array, harray (hash), or codeblock.
Assigning a different kind replaces that binding. Integer and real notation describe
numeric values, rather than separate variable namespaces. Strings, numbers, booleans
and null (`undef`) remain observably different: numeric helpers accept finite numbers
and their contracted decimal strings, reject boolean/null, and return numeric `1`/`0`
for comparisons. Logical helpers return booleans. Scalar text normalization converts
false to `"0"`, so `flag = false; return(flag.cat("q"))` returns `"0q"`.

An eager expression block executes now; a deferred `{|parameters| ... }` codeblock
executes when called and reads the caller's current working bindings. Receiver
operations apply to the yielded value. For example, this returns `["a", "b"]`:

```text
Top: /x/
 I { cb = {|| return(["b","a"]) }; return(cb().sorted()) }
```

This demonstrates an array operation on the call result. It supplies no separate
codeblock method table or guarantee that every operation accepts every kind.

Two Perl defects are currently owned for repair. In `[marker, cb(), marker]` (also
`array(...)` and codeblock argument lists), a callback that rebinds `marker` can change
the earlier element too. Save the earlier value in a separate binding before calling.
An attached `cb.with() { return(value()) }` currently returns null because its scoped
`value` call is not recognized. `with(cb, {|callback| return(callback()) })` works.
These limits apply to the observed Perl parser and emitted source; they establish no
cross-backend result. Complete per-operation reference coverage remains in progress.

'''
proposals[path] = text.replace(needle, addition + needle, 1)

# A historical publication must never remain the advertised current readonly route.
old = 'docs/checkpoints/type-reference-migrations/publish.py'
new = c.PREFIX + 'publish.py'
routes = []
for source in sorted((c.ROOT / 'docs/knowledge').glob('*.md')):
    path = source.relative_to(c.ROOT).as_posix()
    text = proposals.get(path, source.read_text())
    if not text.startswith('---\n') or '\n---\n' not in text:
        continue
    front, body = text.split('\n---\n', 1)
    if old in front:
        front = front.replace(old, new)
        proposals[path] = front + '\n---\n' + body
        routes.append(path)
assert len(routes) == 17
path = 'docs/knowledge/terse-type-method-surface-inventory.md'
text = proposals[path]
text, count = re.subn(r'^reverify: .*$', 'reverify: "bash tools/run_python_project_data.sh ' + new + '"', text, count=1, flags=re.M)
assert count == 1
proposals[path] = text

path = 'docs/linkedspec-book/src/development/documentation-workflow.md'
text = (c.ROOT / path).read_text()
text += '''
### Type inventory and execution evidence

A shared call-name registry checks vocabulary presence in source, fixtures and prose.
It does not count all language operations, certify per-type documentation depth, or
execute every operation. Keep literals, operators, constructors, free helpers,
receiver methods and callable invocation distinct. Resolve surprising results with
public descriptor/emitted-source tools and distinguishing controls; give confirmed
defects repair owners before publishing a healthy taxonomy. Preserve complete prior
live claims before updating any of their bound documentation inputs.
'''
proposals[path] = text

before = {path: c.read(path) for path in proposals}
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before[path]['mode'])
         for path, text in proposals.items()}
c.write_new(c.PREFIX + 'docs-proposals.json.gz', dict(before=before, proposals=after,
    producer=c.read(c.PREFIX + 'prepare_docs_final.py'), helper=c.read(c.PREFIX + 'common.py'), routes=routes), packed=True)
raw = c.decode(preserved['original']['base64'])
assert raw.count(b'"mode": "live"') == 1
frozen = raw.replace(b'"mode": "live"', ('"mode": "historical",\n    "revision": "' + c.BASE + '"').encode(), 1)
parsed = json.loads(raw)
parsed['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
assert json.loads(frozen) == parsed
(c.ROOT / c.OLD_CLAIM).write_bytes(frozen)
for path, item in after.items():
    assert c.read(path) == before[path]
    (c.ROOT / path).write_bytes(c.decode(item['base64']))
print('Only accepted migration claim frozen at real Git BASE; bounded model and17 current routes written')

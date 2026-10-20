"""Publish verified evaluated-value behavior and explicit remaining interpreter limits."""
import gzip
import json
import re
import common as c

green = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'final-green.json.gz')).read_bytes()))
inverse = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'inverse-run.json.gz')).read_bytes()))
assert all(run['returncode'] == 0 for run in green['syntax'] + green['runs']) and green['inputs_unchanged']
assert inverse['main_inputs_unchanged'] and len(inverse['runs']) == 8
assert not inverse['runs'][0]['mismatched_cases'] and not inverse['runs'][-1]['mismatched_cases']
assert all(row['mismatched_cases'] for row in inverse['runs'][1:-1])
proposals = {}
path = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
text = (c.ROOT / path).read_text()
start = text.index('Two Perl defects are currently owned for repair.')
end = text.index('\n## Per-rule default accumulator', start)
replacement = '''### Evaluated values and later side effects

Perl retains each evaluated array element, hash key/value and callable argument
before the next operand executes. A later assignment or mutation updates the
working binding; earlier values retain what was read. This returns
`["before","inside","inside"]`:

```text
Top: /x/
 I { marker = "before"; change = {|| marker = "inside"; return(marker) }; return([marker, change(), marker]) }
```

The same rule covers `array(...)`, `hash(...)`, dynamic hash keys, eager blocks
and assignment expressions. Explicit `flat`, `flat_array` and `flat_hash` splices
keep their list behavior; ordinary container values stay nested.

Array mutation creates an updated binding. For `items = ["old"]` and a callback
that runs `push(items,"new")`, `[items, change(), items]` retains `["old"]` first
and the updated `["old","new"]` last. A separately saved earlier binding also
stays old. This follows the existing mutation contract; the evaluation boundary
does not add recursive copying of arbitrary host objects.

### Current Perl deferred-body limits

An attached `cb.with() { return(value()) }` currently returns null because its
scoped call is not recognized. `with(cb, {|callback| return(callback()) })`
works. A direct `num_add` inside a deferred body currently raises the typed
`unknown_helper` diagnostic even though ordinary numeric helper calls work.
Boolean literals inside deferred bodies still yield numeric `1`/`0`; boolean
arguments passed into a codeblock retain their kind. These separately owned
repairs remain pending. The observations establish no new cross-backend result,
and complete per-operation reference coverage remains in progress.
'''
proposals[path] = text[:start] + replacement + text[end:]

path = 'docs/knowledge/terse-type-method-surface-inventory.md'
text = (c.ROOT / path).read_text()
front, old_body = text.split('\n---\n', 1)
front = re.sub(r'^title: .*$', 'title: "Value kinds and Perl evaluated-value boundaries; dated method inventory"', front, count=1, flags=re.M)
front = re.sub(r'^date: .*$', 'date: 2026-10-19', front, count=1, flags=re.M)
front = re.sub(r'^status: .*$', 'status: current value model and bounded Perl repair; full method inventory pending', front, count=1, flags=re.M)
front = re.sub(r'^evidence: .*$', 'evidence: "TYPE-REFERENCE-BOOK.1.2.3 retains the accepted-runtime RED and native/generated23 GREEN, complete test-input supplement and six effective source inverses. The first oracle, candidate and incomplete supplied test context remain retained; a saved-binding control and existing copy-on-write contract justify the corrected expectation."', front, count=1, flags=re.M)
front = re.sub(r'^reverify: .*$', 'reverify: "bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py"', front, count=1, flags=re.M)
needle = 'date: 2026-10-19\n'
assert front.count(needle) == 1
front = front.replace(needle, '  - "why did a later callback change an earlier Perl array element"\n'
    '  - "do Perl hash keys and callable arguments retain evaluated values"\n'
    '  - "can Perl num_add run inside a deferred codeblock"\n' + needle, 1)
body = '''
# Current value model and evaluated-value boundary

Uniform bindings hold scalar, array, harray or codeblock. Integer/real notation
does not create separate binding namespaces. String, number, boolean and null
remain distinct primitive values. Scalar numeric comparisons yield numeric 1/0;
logical helpers yield booleans. False normalizes to "0" for scalar text and can
pass through generic with as false. The July4 terminal-boolean statement is dated.

Deferred codeblocks use current caller slots; eager blocks execute immediately.
A called codeblock's array result may feed sorted(). That establishes an array
operation on the result, not a separate codeblock method table.

Perl now materializes each emitted list operand before later operands execute.
Array/harray literals and constructors, dynamic hash keys and callable arguments
retain earlier reads across later assignments or calls. A private list temporary
preserves explicit flat splices and scalar kinds without adding a deep copy.
The source owner is MethodLowering::_materialize_list_operand_expr; AST-to-DSL
source rendering and deferred-body interpretation remain unchanged.

The first push question wrongly treated late slot observation as shared-reference
mutation. Independent saved-binding controls and [[perl-uniform-binding-runtime]]
show copy-on-write: push produces an updated binding while the earlier value
stays old. The rejected oracle and first candidate remain intact; the corrected
accepted-runtime baseline rejects19 cases, the candidate matches all23, and six
actual source inverses reject and restore. Host identity controls are separate
and do not establish general DSL alias/deep-copy parity.

Remaining Perl limits: attached with omits callable projection for scoped value
(.1.2.4); num_add inside a deferred body reaches unknown_helper (.1.2.5).
[[perl-codeblock-boolean-literal-kind-drift]] remains owned by startup .35;
explicit boolean arguments avoid that separate literal defect in this repair.

The complete July4 table, including later-retired spellings, is retained in the
accepted c053c9dcf Git version and the inventory docs-proposals capsule. It already
listed substr and the scalar/array/hash/number receiver families. Treat it as
dated navigation. Current full operation/spelling enumeration is still owned by
TYPE-REFERENCE-BOOK.1.2.1; no exhaustive method, backend or reference admission
follows from this bounded repair. Full evidence/limits are under
docs/checkpoints/type-evaluated-values/.
'''
proposals[path] = front + '\n---\n' + body

old = 'docs/checkpoints/type-reference-inventory/publish.py'
new = c.PREFIX + 'publish.py'
routes = []
for source in sorted((c.ROOT / 'docs/knowledge').glob('*.md')):
    path = source.relative_to(c.ROOT).as_posix()
    text = proposals.get(path, source.read_text())
    if not text.startswith('---\n') or '\n---\n' not in text:
        continue
    front, body = text.split('\n---\n', 1)
    if old in front:
        proposals[path] = front.replace(old, new) + '\n---\n' + body
        routes.append(path)
assert len(routes) == 17
path = 'docs/linkedspec-book/src/development/documentation-workflow.md'
text = (c.ROOT / path).read_text()
text += '''

### Test inputs and rejected oracles

An explicit suffix selection can be useful source custody while omitting `.t`
scripts or fixture data in another tree. Before running a supplied test context,
retain the actual selected scripts, their data dependencies and modes. A failed
file lookup is not a behavioral RED. Keep that incomplete reconstruction and use
a separate complete-input epoch.

Likewise, a baseline observation is not automatically the intended behavior.
Distinguish a late variable read from container mutation with a saved-binding
control and the existing mutation contract before choosing the expected value.
Retain rejected expectations and actual failures. When internal emitted text
changes, execute the relevant AST-derived values while preserving poisoned-source
denials and trace checks.
'''
proposals[path] = text
before = {path: c.read(path) for path in proposals}
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before[path]['mode'])
         for path, text in proposals.items()}
c.write_new(c.PREFIX + 'docs-proposals.json.gz', dict(before=before, proposals=after, routes=routes,
    producer=c.read(c.PREFIX + 'prepare_docs.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Bounded current repair, remaining interpreter limits and current readonly routes. '
          'The whole old inventory and actual baseline/replay precede these changes. The full '
          'dated table remains in accepted Git and captured before-images; no history is rewritten.'), packed=True)
for path, item in after.items():
    assert c.read(path) == before[path]
    (c.ROOT / path).write_bytes(c.decode(item['base64']))
print('Verified value-order book, bounded current fact and17 readonly routes written')

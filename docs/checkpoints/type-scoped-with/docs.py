"""Preserve and revise the existing canonical facts and public with contract."""
import json
import re
import common as c

card = 'docs/knowledge/perl-generic-final-codeblock-normalization.md'
inventory = 'docs/knowledge/terse-type-method-surface-inventory.md'
chapter = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
paths = (card, inventory, chapter)
before = {path: c.read(path) for path in paths}
old = {path: c.decode(item['base64']).decode() for path, item in before.items()}
front = old[card].split('---\n', 2)[1]
front = front.replace('date: 2026-07-12', 'date: 2026-10-20')
front = front.replace('date: 2026-10-20', '  - "why can Perl call value inside with"\n'
    '  - "how does Perl with restore callable bindings"\n'
    '  - "does calling a non callable with value report a typed error"\ndate: 2026-10-20')
front = re.sub(r'^evidence: .*$', 'evidence: "Original generic normalization and dated closeout evidence '
    'remain in this same card at accepted Git 2fca7d8489038c226fe0454a105f12a2af696a1f. '
    'TYPE-REFERENCE-BOOK.1.2.4 owns the scoped callable repair and its complete proof under '
    'docs/checkpoints/type-scoped-with/."', front, flags=re.M)
front = re.sub(r'^reverify: .*$', 'reverify: "bash tools/run_python_project_data.sh '
    'docs/checkpoints/type-scoped-with/publish.py && bash tools/project_data_run.sh '
    'prove -q -Iperl t/callable_codeblock_literal_contract.t"', front, flags=re.M)
body = """# Perl Generic Final-Codeblock Normalization

LinkedSpec::CallableContract governs builtin helper, receiver and typed user-function final arguments.
The parser recognizes attached receiver syntax without a method-name allowlist; callable metadata grants
semantics. Attached and parenthesized contextual braces normalize to the same version-1 codeblock_argument,
with zero positional parameters and typed body/source payload. Unknown receiver methods still fail validation.

User functions declare only a final value kind, for example callback: codeblock. Definitions, staged bodies
and staged parse jobs retain ordered params, exact arity and parameter_kinds. The declaration has no callback
argument list; an explicit {|item, ...rest| ...} literal owns its invocation signature. Typed functions use
the dynamic codeblock runtime. Immediate helpers retain their existing full-breadth block lowering.
Harrays are never promoted: an invalid final value yields final_argument_not_codeblock. Non-final,
nested-signature, nameless and unknown-type declarations fail before parser construction.

Builtin contracts cover helper with and receiver with, walk_leaves, map_leaves and reduce_leaves.
Contextual blocks read current dynamic values; explicit literals retain their own parameters.
No lexical environment or stored host coderef is introduced. The original July normalization closeout
and its exact historical measurements remain at the Git revision in evidence above; backend progress
belongs to the task trees.

October20 scoped repair: immediate with projects value as a scalar working binding only within its typed
body and dynamic invocation vocabulary. A callable receiver can therefore run as value(), including nested
with and registered-function bodies. The original AST retains authored spans. A function's shared binding
frame temporarily points value at the local slot and restores it on success or error. Other caller effects
remain visible. Helpers and registered functions retain static precedence; bound false/null/string/array/
harray calls reach value_not_callable. Unsupported deferred calls retain their distinct unknown_helper cause.
This finite Perl repair does not admit exhaustive methods or another backend.

Related facts: [[final-codeblock-parameter-declaration]], [[callable-codeblock-literal-contract]],
[[perl-callable-codeblock-dynamic-invocation]], [[perl-final-codeblock-signature-declaration-gap]].
"""
updated = {card: '---\n' + front + '---\n\n' + body}
assert len(updated[card].encode()) < len(c.decode(before[card]['base64']))
needle = 'Remaining Perl limits: attached with omits callable projection for scoped value\n(.1.2.4); num_add inside a deferred body reaches unknown_helper (.1.2.5).'
replacement = ('Scoped callable with is repaired under .1.2.4; '
    '[[perl-generic-final-codeblock-normalization]] owns its local vocabulary/frame mechanism.\n'
    'Remaining Perl limit: num_add inside a deferred body reaches unknown_helper (.1.2.5).')
assert old[inventory].count(needle) == 1
updated[inventory] = old[inventory].replace(needle, replacement)
start = old[chapter].index('An attached ')
end = old[chapter].index('Boolean literals inside deferred bodies', start)
tick = chr(96)
updated[chapter] = (old[chapter][:start] + 'A direct ' + tick + 'num_add' + tick
    + ' inside a deferred body currently raises the typed\n' + tick + 'unknown_helper' + tick
    + ' diagnostic even though ordinary numeric helper calls work.\n' + old[chapter][end:])
cases = json.loads((c.ROOT / 'tests/scoped-with/cases.json').read_bytes())['cases']
examples = '\n\n'.join(tick * 3 + 'text\n' + next(case['body'] for case in cases if case['id'] == name)
    + '\n' + tick * 3 for name in ('receiver-attached', 'nested-scopes', 'outer-callable-restored'))
addition = """
### Callable values in with

In Perl, a scoped value that contains a codeblock can be invoked as value().
The following expressions return "yes", ["first","second","first"], and
["inner","outer"], respectively:

""" + examples + """

The receiver evaluates once. Nested blocks restore the surrounding value;
the same rule holds inside registered functions and while unwinding a callable
error. A callback invoked inside the block reads the current scoped value
through its dynamic caller context. Mutations to other caller bindings persist.
Governed helpers and registered functions keep precedence over variables with
the same names.

Calling value() when the scoped value is false, null, a string, an array or a
harray raises the typed value_not_callable cause. An unsupported call inside
the invoked codeblock instead retains unknown_helper and the authored name.
Explicit callback parameters remain supported, for example
""" + tick + 'with(cb, {|callback| return(callback()) })' + tick + """.

"""
anchor = 'Across all backends this shipped surface'
assert updated[chapter].count(anchor) == 1
updated[chapter] = updated[chapter].replace(anchor, addition + anchor)
proposals = {path: dict(before=before[path], after=c.encode(text.encode()))
             for path, text in updated.items()}
c.write_new('docs-proposals.json.gz', dict(proposals=proposals, producer=c.read(c.PREFIX + 'docs.py'),
    scope='Existing fact questions and unique contracts remain; duplicated dated measurements have an exact '
          'Git pointer to the complete prior card. Source-byte total decreases without changing a cap.'))
for path, text in updated.items():
    (c.ROOT / path).write_text(text)
print('Scoped with book examples and canonical facts updated; original bytes preserved')

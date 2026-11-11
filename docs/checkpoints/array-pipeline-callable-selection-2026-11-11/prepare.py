"""Repair owned current pointers and author finite callable-source questions."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '7955c16ca0a98c373dd437284d578e80432b1321'
assert not (BASE / 'cases.json').exists()
pointer = ROOT / 'docs/checkpoints/type-operation-inventory/helpers.md'
original = pointer.read_bytes()
(BASE / 'helpers-before.md.gz').write_bytes(gzip.compress(original, mtime=0))
text = original.decode()
old = re.search(r'^Current finite frontier:.*$', text, re.M).group()
new = ('Current finite frontier: All bounded pure-pipeline79 backend outcomes are focused-checked on recorded routes/hosts, '
       'including installed Lua79.5. Remaining-feature selection23.1.40 independently assesses registered-function pipeline '
       'receivers under the existing function MVP; no callable outcome or complete feature admission is inferred. '
       'Full source/context/native-cache-transitive custody/registration/declared5.4/full23.4/routing18.2 remain separate. '
       'Evidence: docs/checkpoints/array-pipeline-result-guard-lua-2026-11-11/REVIEW.md.')
old_tail = 'Current selection23.1.39/family79 owns pure-pipeline results; Perl79.1 is next after its clean selection handoff, full23.4 separate.'
new_tail = 'All bounded79 outcomes are now recorded; remaining-feature selection23.1.40 is current, full23.4 separate.'
assert text.count(old) == text.count(old_tail) == 1
changed = text.replace(old, new).replace(old_tail, new_tail)
pointer.write_text(changed)
(BASE / 'pointer-repair.json').write_text(json.dumps(dict(path=str(pointer.relative_to(ROOT)),
    before_sha256=hashlib.sha256(original).hexdigest(), after_sha256=hashlib.sha256(pointer.read_bytes()).hexdigest(),
    replacements=[[old, new], [old_tail, new_tail]]), indent=2) + '\n')

cases = []


def add(identifier, body, expected=None, error=None, profile=False):
    row = dict(id=identifier, body=body,
        source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n', input='x', rule='Value')
    if error:
        row['expected_error'] = error
    elif profile:
        row['profile_only'] = True
    else:
        row['expected'] = expected
    cases.append(row)


roles = (
    ('split_each', '["head:tail"]', '":"', ['head', 'tail']),
    ('trim_each', '[" head "," tail "]', None, ['head', 'tail']),
    ('filter_nonempty', '["head","","tail"]', None, ['head', 'tail']),
    ('lowercase_each', '["HEAD","TAIL"]', None, ['head', 'tail']),
    ('uppercase_each', '["head","tail"]', None, ['HEAD', 'TAIL']),
    ('uniq', '["head","tail","head"]', None, ['head', 'tail']),
    ('filter_match', '["head","other"]', '/^h/', ['head']),
)
consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
for name, source, argument, result in roles:
    call = 'supply(' + source + ')'
    free = name + '(' + call + (',' + argument if argument else '') + ')'
    receiver = call + '.' + name + '(' + (argument or '') + ')'
    add(name + '_compatible', 'return([' + free + ',' + receiver + '])', [result, result])
    for form, expression in (('free', free), ('receiver', receiver)):
        add(name + '_' + form + '_hash_guard', 'order="";out=' + expression + consumer + ';return([out,order])', [None, ''])
for identifier, expression, tail in (
    ('trim_later_with', 'supply([" tail "]).trim_each()', '.with(){order=cat(order,"W");return("ran")}'),
    ('uniq_copy_later_with', 'supply(["tail","tail"]).uniq()', '.copy().with(){order=cat(order,"W");return("ran")}'),
    ('lower_logical_later_with', 'supply(["TAIL"]).lowercase_each()', '.and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'),
):
    add(identifier, 'order="";out=' + expression + consumer + tail + ';return([out,order])', [None, ''])
add('source_once', 'order="";out=supply({order=cat(order,"S");[" tail "]}).trim_each().last().uppercase();return([out,order])', ['TAIL', 'S'])
add('source_snapshot', 'items=["head:tail"];out=supply(items).split_each({items=["changed"];":"});return([out,items])', [['head', 'tail'], ['changed']])
add('valid_empty_with', 'order="";out=supply([""]).filter_nonempty().with(){order=cat(order,"W");return(value.count())};return([out,order])', [0, 'W'])
for role, expression in (
    ('source', 'supply({items="bad";items+=1;["head"]}).trim_each()'),
    ('delimiter', 'supply(["head:tail"]).split_each({items="bad";items+=1;":"})'),
    ('pattern', 'supply(["head"]).filter_match({items="bad";items+=1;"^h"})'),
):
    for composed in (False, True):
        add('needed_' + role + ('_composed' if composed else '_terminal'),
            'order="";return(' + expression + (consumer + '.coalesce("masked")' if composed else '') + ')',
            error='binding_kind_mismatch')
for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
    add('initial_' + kind + '_terminal', 'return([trim_each(supply(' + source + ')),supply(' + source + ').trim_each()])', profile=True)
    add('initial_' + kind + '_composed', 'order="";out=supply(' + source + ').trim_each()' + consumer
        + '.with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
assert len(cases) == len({row['id'] for row in cases}) == 39
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')

# Preserve own public observer templates; import no prior observations.
prior = ROOT / 'docs/checkpoints/array-pipeline-result-selection-2026-11-10'
full = ROOT / 'docs/checkpoints/array-pipeline-composition-perl-2026-11-10/observer_prefix.pl'
templates = {str(prior / 'observer.pl'): (prior / 'observer.pl').read_bytes(), str(full): full.read_bytes()}
identities = {}
for index, (name, body) in enumerate(templates.items()):
    (BASE / ('observer-template-' + str(index) + '.gz')).write_bytes(gzip.compress(body, mtime=0))
    identities[name.removeprefix(str(ROOT) + '/')] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
observer = templates[str(prior / 'observer.pl')].decode()
full_text = templates[str(full)].decode()
observer = observer[:observer.index('sub error_value {')] + full_text[full_text.index('sub plain_error_value {'):full_text.index('sub persist {')] + observer[observer.index('sub persist {'):]
observer = observer.replace('array-pipeline-result-selection-2026-11-10', BASE.name)
observer = observer.replace('array-pipeline-selection.spec', 'array-pipeline-callable-selection.spec')
observer = observer.replace('ArrayPipelineSelectionProbe', 'ArrayPipelineCallableSelectionProbe')
observer = observer.replace('ARRAY_PIPELINE_', 'ARRAY_PIPELINE_CALLABLE_')
(BASE / 'observer.pl').write_text(observer)
(BASE / 'template-identities.json').write_text(json.dumps(identities, indent=2) + '\n')
print('Two stale pointers repaired;39 full-source callable questions authored before SDK observations')

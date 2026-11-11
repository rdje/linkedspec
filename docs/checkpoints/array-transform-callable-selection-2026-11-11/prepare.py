"""Repair current pointers and author finite existing-MVP transform questions."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
ACTIVATION = 'e29638a99224be51fe454a1935a428c2a1a9a270'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (HERE / 'cases.json').exists(), 'one-shot preparation'
repairs = []


def repair(name, replacements):
    path = ROOT / name
    before = path.read_bytes()
    original = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name])
    index = len(repairs)
    for suffix, raw in (('before', before), ('activation', original)):
        target = HERE / ('pointer-' + str(index) + '-' + suffix + '.gz')
        target.write_bytes(gzip.compress(raw, mtime=0))
        assert gzip.decompress(target.read_bytes()) == raw
    body = before.decode()
    for old, new in replacements:
        assert body.count(old) == 1, (name, old)
        body = body.replace(old, new)
    path.write_text(body)
    repairs.append(dict(path=name, before_sha256=hashlib.sha256(before).hexdigest(),
        activation_sha256=hashlib.sha256(original).hexdigest(), after_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
        replacements=replacements, mode=path.stat().st_mode & 0o777))


helper = 'docs/checkpoints/type-operation-inventory/helpers.md'
text = (ROOT / helper).read_text()
old = re.search(r'^Current finite frontier:.*$', text, re.M).group()
new = ('Current finite frontier: All bounded ordinary79/callable79.6 backend outcomes are focused-checked on recorded routes/hosts. '
    'Remaining-feature selection23.1.41 reconciles unassessed registered-function Array-transform composition under the existing function MVP; '
    'its retained public observations and frozen next owner live at docs/checkpoints/array-transform-callable-selection-2026-11-11/REVIEW.md. '
    'MEMORY.md owns current activation. Full source/context/native-cache-transitive custody/registration/formatter/declared5.4/full23.4/routing18.2 remain separate; finite samples imply no completeness.')
old_tail = 'All bounded ordinary79 outcomes are recorded; callable79.6 Perl arity79.6.1.1 is focused-checked before pending result79.6.1.2; full23.4 remains separate.'
new_tail = 'All bounded ordinary79 and callable79.6 backend outcomes are recorded; selection23.1.41 owns the next bounded assessment and its retained next-owner pointer, full23.4 remains separate.'
repair(helper, [(old, new), (old_tail, new_tail)])
overview = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
text = (ROOT / overview).read_text()
parent = re.search(r'^- ID: `TYPE-REFERENCE-BOOK\.1\.2\.23\.1`\n.*?(?=^- ID: |\Z)', text, re.M | re.S).group()
children = re.search(r'^  Children:.*$', parent, re.M).group()
assert children.endswith('`.23.1.40`.') and '.23.1.41`' not in children
repair(overview, [(children, children[:-1] + ', `.23.1.41`.')])
part = 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
text = (ROOT / part).read_text()
parent = re.search(r'^- ID: `TYPE-REFERENCE-BOOK\.1\.2\.23\.3\.78`\n.*?(?=^- ID: |\Z)', text, re.M | re.S).group()
frontier = re.search(r'^  Frontier:.*$', parent, re.M).group()
old_next = 'After clean Lua landing, selection23.1.39 reconciles the next roadmap requirement before any new implementation or deferred verification.'
assert frontier.count(old_next) == 1
updated = frontier.replace('All bounded78 backend outcomes now exist', 'All bounded ordinary78 backend outcomes now exist').replace(old_next,
    'Later ordinary79/callable79.6 outcomes are recorded; remaining-feature selection23.1.41 now owns unassessed registered-function composition and the next bounded owner before implementation or deferred verification.')
repair(part, [(frontier, updated)])
(HERE / 'pointer-repairs.json').write_text(json.dumps(dict(activation=ACTIVATION, repairs=repairs), indent=2) + '\n')

cases = []


def add(identifier, body, expected=None, error=None, profile=False):
    row = dict(id=identifier, body=body,
        source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n', input='x', rule='Value')
    if profile: row['profile_only'] = True
    elif error: row['expected_error'] = error
    else: row['expected'] = expected
    cases.append(row)


roles = (
    ('take', '["head","tail"]', '1', ['head']),
    ('take_last', '["head","tail"]', '1', ['tail']),
    ('drop_front', '["head","tail"]', '1', ['tail']),
    ('drop_back', '["head","tail"]', '1', ['head']),
    ('slice', '["head","tail","other"]', '1,1', ['tail']),
    ('sorted', '["tail","head"]', '', ['head', 'tail']),
    ('reversed', '["head","tail"]', '', ['tail', 'head']),
    ('concat_arrays', '["head"]', '["tail"]', ['head', 'tail']),
)
consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
for name, source, arguments, result in roles:
    call = 'supply(' + source + ')'
    free = name + '(' + call + (',' + arguments if arguments else '') + ')'
    receiver = call + '.' + name + '(' + arguments + ')'
    add(name + '_compatible', 'return([' + free + ',' + receiver + '])', [result, result])
    for form, expression in (('free', free), ('receiver', receiver)):
        add(name + '_' + form + '_hash_guard', 'order="";out=' + expression + consumer + ';return([out,order])', [None, ''])
for identifier, expression, tail in (
    ('take_later_with', 'supply(["head"]).take(1)', '.with(){order=cat(order,"W");return("ran")}'),
    ('reverse_copy_later_with', 'supply(["head"]).reversed()', '.copy().with(){order=cat(order,"W");return("ran")}'),
    ('drop_logical_later_with', 'supply(["head","tail"]).drop_front(1)', '.and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'),
):
    add(identifier, 'order="";out=' + expression + consumer + tail + ';return([out,order])', [None, ''])
add('source_once', 'order="";out=supply({order=cat(order,"S");["head","tail"]}).take(1).last().uppercase();return([out,order])', ['HEAD', 'S'])
add('source_snapshot', 'items=["head","tail"];out=supply(items).take({items=["changed"];1});return([out,items])', [['head'], ['changed']])
add('valid_empty_with', 'order="";out=supply(["head"]).take(0).with(){order=cat(order,"W");return(value.count())};return([out,order])', [0, 'W'])
add('nested_kinds', 'return(supply([false,0,undef,{"k":[1]}]).reversed())', [{'k': [1]}, None, 0, False])
add('selected_hash_bridge', 'return(supply([{"k":"head"}]).take(1).first().pick_keys("k").count_keys())', 1)
for kind, expression in (
    ('source', 'take(supply({items="bad";items+=1;["head"]}),1)'),
    ('count', 'supply(["head"]).take({items="bad";items+=1;1})'),
):
    for composed in (False, True):
        add('needed_' + kind + ('_composed' if composed else '_terminal'),
            'order="";return(' + expression + (consumer + '.coalesce("masked")' if composed else '') + ')', error='binding_kind_mismatch')
add('constructor_rejection_oracle', 'order="";out=["head"]' + consumer + '.with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
    add('initial_' + kind + '_terminal', 'return([take(supply(' + source + '),1),supply(' + source + ').take(1)])', profile=True)
    add('initial_' + kind + '_composed', 'order="";out=supply(' + source + ').take(1)' + consumer
        + '.with(){order=cat(order,"W");return("ran")};return([out,order])', profile=True)
add('source_effect_before_rejection', 'order="";out=supply({order=cat(order,"S");["head"]}).take(1)' + consumer
    + '.with(){order=cat(order,"W");return("ran")};return([out,order])', [None, 'S'])
assert len(cases) == len({row['id'] for row in cases}) == 44
(HERE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')

template = 'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/observer.pl'
raw = (ROOT / template).read_bytes()
(HERE / 'observer-template.pl.gz').write_bytes(gzip.compress(raw, mtime=0))
assert gzip.decompress((HERE / 'observer-template.pl.gz').read_bytes()) == raw
observer = raw.decode().replace('array-pipeline-callable-selection-2026-11-11', BASE.name)
observer = observer.replace('array-pipeline-callable-selection.spec', 'array-transform-callable-selection.spec')
observer = observer.replace('ArrayPipelineCallableSelectionProbe', 'ArrayTransformCallableSelectionProbe')
observer = observer.replace('ARRAY_PIPELINE_CALLABLE_', 'ARRAY_TRANSFORM_CALLABLE_')
(HERE / 'observer.pl').write_text(observer)
(HERE / 'template-identities.json').write_text(json.dumps({template: dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())}, indent=2) + '\n')
print(json.dumps(dict(result='PASS', authored_questions=len(cases), supported_questions=38, source_profiles=6,
    pointer_repairs=len(repairs)), sort_keys=True))

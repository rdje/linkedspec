"""Prepare fresh shared84/legacy312 and own source-only concat policy questions."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'b15ca562e8044d9a8a369e613926bf016598f708'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
OLD = 'docs/checkpoints/array-concat-open-arity-selection-2026-11-12'
paths = [OLD + '/cases.json', OLD + '/observer.pl', OLD + '/capture.py', OLD + '/run_stage.py',
    'tests/fixtures/array_transform_callable_result_guard_perl_cases.json',
    't/array_transform_callable_result_guard_composition.t', 't/array_transform_result_guard_composition.t',
    'tests/fixtures/array_transform_result_guard_cases.json',
    'tests/fixtures/array_transform_result_guard_perl_profiles.json',
    'tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json']
templates = {}
for index, name in enumerate(paths):
    body = Path(name).read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name])
    target = BASE / ('template-' + str(index) + '.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    templates[name] = dict(image=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(templates, indent=2, sort_keys=True) + '\n')
shared = json.loads(Path(paths[0]).read_bytes())
legacy = json.loads(Path(paths[4]).read_bytes())
assert len(shared) == 84 and len(legacy) == 312
cases = copy.deepcopy(shared)
for row in cases:
    row['origin'] = 'selection84'
for profile in legacy:
    case = {key: profile['case'][key] for key in ('id', 'body', 'source', 'input', 'rule')}
    case.update(origin='legacy312', profile_only=True)
    cases.append(case)
own = []


def add(identifier, body, question, definition='', **fields):
    row = dict(id='own80_' + identifier, body=body, source=definition + 'Value:: I {' + body + '}\n',
        input='x', rule='Value', origin='own', profile_only=True, question=question, **fields)
    cases.append(row)
    own.append(row)


definition = 'fn supply(seed) {return(seed)}\n\n'
wrong = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).copy().and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'
for kind, value in (('number', '3'), ('null', 'undef'), ('hash', '{"k":1}'), ('bool', 'false'), ('string', '"bad"')):
    for source_kind in ('ordinary', 'function'):
        source = 'source' if source_kind == 'ordinary' else 'supply({order=cat(order,"S");' + value + '})'
        setup = 'source=' + value + ';' if source_kind == 'ordinary' else ''
        for count in (1, 3):
            rest = [] if count == 1 else ['{order=cat(order,"T");["tail"]}', '{order=cat(order,"U");["end"]}']
            for form in ('free', 'receiver'):
                prefix = 'concat_arrays(' + ','.join([source] + rest) + ')' if form == 'free' else source + '.concat_arrays(' + ','.join(rest) + ')'
                for tail, suffix in (('terminal', ''), ('with', '.with(){order=cat(order,"W");return(value.count())}')):
                    body = setup + 'order="";out=' + prefix + suffix + ';return([out,order])'
                    add('initial_' + kind + '_' + source_kind + '_' + str(count) + '_' + form + '_' + tail,
                        body, 'initial-producer-policy', definition if source_kind == 'function' else '',
                        source_kind=source_kind, array_count=count, form=form, tail=tail)
for signature, declaration, source in (
    ('fixed_missing', 'fn pair(left,right) {return(left)}\n\n', 'pair({order=cat(order,"S");["head"]})'),
    ('rest_missing', 'fn keep(seed,...extras) {return(seed)}\n\n', 'keep()'),
    ('rest_empty', 'fn keep(seed,...extras) {return(seed)}\n\n', 'keep({order=cat(order,"S");["head"]})'),
    ('rest_multi', 'fn keep(seed,...extras) {return(seed)}\n\n', 'keep({order=cat(order,"S");["head"]},{order=cat(order,"X");9})')):
    for form in ('free', 'receiver'):
        args = ['{order=cat(order,"T");["tail"]}', '{order=cat(order,"U");["end"]}']
        prefix = 'concat_arrays(' + ','.join([source] + args) + ')' if form == 'free' else source + '.concat_arrays(' + ','.join(args) + ')'
        for tail, suffix in (('terminal', ''), ('composed', wrong)):
            add('signature_' + signature + '_' + form + '_' + tail,
                'order="";out=' + prefix + suffix + ';return([out,order])',
                'invalid-signature' if signature.endswith('missing') else 'valid-rest-source', declaration,
                form=form, tail=tail, signature=signature)
for source_kind in ('ordinary', 'function'):
    for form in ('free', 'receiver'):
        source = 'items' if source_kind == 'ordinary' else 'supply(items)'
        rest = ['{items+="changed";["tail"]}', '["end"]']
        prefix = 'concat_arrays(' + ','.join([source] + rest) + ')' if form == 'free' else source + '.concat_arrays(' + ','.join(rest) + ')'
        for tail, suffix in (('terminal', ''), ('hash', '.set_key("k",1)')):
            add('snapshot_' + source_kind + '_' + form + '_' + tail,
                'items=["head"];out=' + prefix + suffix + ';return([out,items])',
                'source-snapshot', definition if source_kind == 'function' else '', source_kind=source_kind, form=form, tail=tail)
        nested = '["", "0", false, 0, undef, {"k":[1]}, [false,0]]'
        source = nested if source_kind == 'ordinary' else 'supply(' + nested + ')'
        # Ordinary receiver uses an explicit working Array, avoiding the separately
        # owned initial literal/Hash-consumer question.
        setup = 'items=' + nested + ';' if source_kind == 'ordinary' and form == 'receiver' else ''
        if setup:
            source = 'items'
        expression = 'concat_arrays(' + source + ',["tail"],["end"])' if form == 'free' else source + '.concat_arrays(["tail"],["end"])'
        add('nested_' + source_kind + '_' + form, setup + 'return(' + expression + ')',
            'nested-kinds', definition if source_kind == 'function' else '', source_kind=source_kind, form=form)
assert len(own) == 108 and len(cases) == len({row['id'] for row in cases}) == 504
for name, value in (('cases.json', cases), ('own-questions.json', own)):
    (BASE / name).write_text(json.dumps(value, indent=2) + '\n')
observer = Path(paths[1]).read_text().replace(OLD, str(BASE))
observer = observer.replace('ARRAY_CONCAT_OPEN_PERL', 'ARRAY_CONCAT_PERL').replace('ARRAY_CONCAT_OPEN_INPUT', 'ARRAY_CONCAT_INPUT')
# Keep the selection's source identity and package so actual first84 source/error
# contrasts are comparable; this changes only owned capture routing and frame tags.
(BASE / 'observer.pl').write_text(observer)
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']) == b''
print('Prepared shared84 + own legacy312 +108 source-only policy questions; no production change')

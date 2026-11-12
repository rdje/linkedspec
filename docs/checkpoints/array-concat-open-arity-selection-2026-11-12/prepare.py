"""Author finite valid-Array concat questions from existing contracts, no peer outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'd21b84a4c8da663ee2a7600a2dc814d354502612'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
old = 'docs/checkpoints/array-transform-callable-perl-2026-11-11'
names = [old + '/observer.pl', 'docs/checkpoints/array-transform-callable-lua-2026-11-12/run_stage.py']
templates = {}
for index, name in enumerate(names):
    body = Path(name).read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name])
    target = BASE / ('template-' + str(index) + '.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    templates[name] = dict(image=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(templates, indent=2, sort_keys=True) + '\n')
cases = []


def add(identifier, source_kind, count, form, tail, expression, expected=None, error=None, empty=False):
    prefix = 'fn supply(seed) {return(seed)}\n\n' if source_kind == 'function' else ''
    body = 'order="";out=' + expression + ';return([out,order])'
    row = dict(id=identifier, source_kind=source_kind, array_count=count, form=form, tail=tail,
        empty=empty, body=body, source=prefix + 'Value:: I {' + body + '}\n', input='x', rule='Value')
    if error:
        row['expected_error'] = error
    else:
        row['expected'] = expected
    cases.append(row)


def source(kind, empty=False, error=False):
    if error:
        value = '{items="bad";items+=1;' + ('[]' if kind == 'function' else '"head"') + '}'
    elif kind == 'function':
        value = '{order=cat(order,"S");' + ('[]' if empty else '["head"]') + '}'
    elif empty:
        return 'array()'
    else:
        value = '{order=cat(order,"S");"head"}'
    return ('supply' if kind == 'function' else 'array') + '(' + value + ')'


def expression(kind, count, form, empty=False, source_error=False, operand_error=False):
    args = [source(kind, empty, source_error)]
    for index, (effect, value) in enumerate((('T', 'tail'), ('U', 'end')), 2):
        if count >= index:
            args.append('{items="bad";items+=1;[]}' if operand_error and index == 3
                else '{order=cat(order,"' + effect + '");["' + value + '"]}')
    return 'concat_arrays(' + ','.join(args) + ')' if form == 'free' else args[0] + '.concat_arrays(' + ','.join(args[1:]) + ')'


wrong = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
tails = dict(terminal='', compatible='.last().uppercase()', with_='.with(){order=cat(order,"W");return(value.count())}',
    hash=wrong, later=wrong + '.copy().and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}')
for kind in ('ordinary', 'function'):
    for count in (1, 2, 3):
        effects = 'STU'[:count]
        items = ['head', 'tail', 'end'][:count]
        for form in ('free', 'receiver'):
            prefix = expression(kind, count, form)
            for tail, suffix in tails.items():
                value = items if tail == 'terminal' else items[-1].upper() if tail == 'compatible' else count if tail == 'with_' else None
                expected = [value, effects + ('W' if tail == 'with_' else '')]
                add(kind + '_' + str(count) + '_' + form + '_' + tail, kind, count, form, tail, prefix + suffix, expected)
    for form in ('free', 'receiver'):
        for tail in ('terminal', 'with_'):
            effects = 'S' if kind == 'function' else ''
            expected = [[], effects] if tail == 'terminal' else [0, effects + 'W']
            add(kind + '_empty_' + form + '_' + tail, kind, 1, form, tail,
                expression(kind, 1, form, empty=True) + tails[tail], expected, empty=True)
        for fault in ('source', 'operand'):
            for tail in ('terminal', 'hash'):
                add(kind + '_needed_' + fault + '_' + form + '_' + tail, kind, 3, form, tail,
                    expression(kind, 3, form, source_error=fault == 'source', operand_error=fault == 'operand') + tails[tail],
                    error='binding_kind_mismatch')
assert len(cases) == len({row['id'] for row in cases}) == 84
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
observer = Path(names[0]).read_text().replace(old, str(BASE)).replace('ARRAY_TRANSFORM_CALLABLE_PERL_PERL', 'ARRAY_CONCAT_OPEN_PERL')
observer = observer.replace('ARRAY_TRANSFORM_CALLABLE_PERL_INPUT', 'ARRAY_CONCAT_OPEN_INPUT')
observer = observer.replace('array-transform-callable-perl.spec', 'array-concat-open-arity-selection.spec')
observer = observer.replace('LinkedSpec::ArrayTransformCallablePerlIntakeProbe', 'LinkedSpec::ArrayConcatOpenAritySelection')
observer = observer.replace('use IO::Compress::Gzip qw(gzip $GzipError);', 'use IO::Compress::Gzip qw(gzip $GzipError);\nuse IO::Uncompress::Gunzip qw(gunzip $GunzipError);')
anchor = ' gzip \\$body => $path or die $GzipError;\n'
assert observer.count(anchor) == 1
observer = observer.replace(anchor, anchor + ' my $retained;gunzip $path => \\$retained or die $GunzipError;\n die "artifact readback drift" unless $retained eq $body;\n')
(BASE / 'observer.pl').write_text(observer)
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']) == b''
print('Prepared84 valid-Array concat questions and public Toolbox observer; no production change')

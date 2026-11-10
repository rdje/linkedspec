"""Author missing prefix/source/arity questions before result production edits."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'c34813f071403ae50580d785643957b6e0e3dd47'
target = BASE / 'prefix-cases.json'
assert not target.exists()
rows = []


def add(key, expression, purpose, seed='empty', with_result=True):
    body = ('order="";out=' + expression + '.with(){order=cat(order,"W");return(value)};return([out,order])'
            if with_result else expression)
    rows.append(dict(id=key, source='Value:: I {' + body + '}\n', body=body,
                     rule='Value', input='x', seed=seed, purpose=purpose))


for helper in ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match'):
    args = '":"' if helper == 'split_each' else '/^head/' if helper == 'filter_match' else ''
    for kind, source, seeds in (('number', '3', ('empty', 'main', 'outer')),
                                ('null', 'undef', ('empty',)), ('hash', '{"k":"tail"}', ('empty',))):
        for seed in seeds:
            add('prefix_' + kind + '_' + helper + '_' + seed,
                source + '.' + helper + '(' + args + ')', 'source-prefix', seed)
    add('prefix_computed_number_' + helper, '{3}.' + helper + '(' + args + ')', 'source-prefix', 'main')
    add('empty_with_' + helper, '[].' + helper + '(' + args + ')', 'empty-with')
    add('missing_free_' + helper, helper + '()', 'arity-exclusion')
for helper in ('split_each', 'filter_match'):
    for route, expression in (('free', helper + '(["head"])'), ('receiver', '["head"].' + helper + '()')):
        add('missing_operand_' + helper + '_' + route, expression, 'arity-exclusion')
assert len(rows) == 60
target.write_text(json.dumps(rows, indent=2) + '\n')
source = Path('docs/checkpoints/array-pipeline-source-perl-2026-11-10/observer.pl')
raw = source.read_bytes()
(BASE / 'prefix-template-observer.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'prefix-template-identity.json').write_text(json.dumps(dict(path=str(source), bytes=len(raw),
    sha256=hashlib.sha256(raw).hexdigest()), indent=2) + '\n')
observer = raw.decode().replace('docs/checkpoints/array-pipeline-source-perl-2026-11-10', str(BASE))
observer = observer.replace('/cases.json', '/prefix-cases.json')
(BASE / 'observer_prefix.pl').write_text(observer)
print('Authored60 independent source-prefix/empty-with/missing-arity questions')

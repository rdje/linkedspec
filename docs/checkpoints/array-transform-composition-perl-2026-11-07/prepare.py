"""Activate bounded composition and acquire missing prefix/arity fences first."""
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ACTIVATION = '4bfe17f75c20851bc9a634c151071b6d196de57d'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
text = task.read_text(); start = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1`\n'); end = text.index('- ID:', start + 7)
node = text[start:end].replace('Status: `pending`', 'Status: `in_progress`', 1)
node += '''  Activation: Clean4bfe17f75c20851bc9a634c151071b6d196de57d after source78.0 all10/post-pointer/brief0/clean Git. Frozen78/37, own123 policies, source0 input/artifact qualification, actual first-producer and retained/copy/logical/with dispatch paths and current book/Knowledge are read. Source78.0 remains intact. Cleanup November7 05:37UTC remains within24h; serial Perl uses modest RAM.
  Verification tier: `focused`
  Focused checks: Current unchanged37/own123 plus minimal literal-prefix/host/arity acquisition before production; new composition normal, direct source78.0 and Hash-result normals, exact private old/current inverse and readonly recovery/corruptions, syntax/book/Knowledge/history/task/memory/diff and mandatory hooks. No broad suite.
  Canonical trigger: Full23.4/final clean push after feature coverage; no new arity, format, public authority or infrastructure.
  Claim verification: none: Finite authored feature and preservation controls, no population/performance/full-source/context admission measurement.

'''
task.write_text(text[:start] + node + text[end:])
cases = []


def add(identifier, body, seed='empty'):
    cases.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n', input='x', rule='Value', seed=seed))


for name in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
    args = ['1', '1'] if name == 'slice' else ['["extra"]'] if name == 'concat_arrays' else [] if name in ('sorted', 'reversed') else ['1']
    for kind, source, seeds in (('number', '3', ('empty', 'main', 'outer')), ('null', 'undef', ('empty',)), ('hash', '{"k":"tail"}', ('empty',))):
        for seed in seeds:
            add('prefix_' + kind + '_' + name + '_' + seed,
                'return(' + source + '.' + name + '(' + ','.join(args) + ').with(){return(value)})', seed)
    add('missing_free_' + name, 'return(' + name + '().with(){return(value)})')
for route, expression in (('free', 'slice(["head","tail"])'), ('receiver', '["head","tail"].slice()')):
    add('missing_slice_start_' + route, 'return(' + expression + '.with(){return(value)})')
for route, expression in (('free', 'concat_arrays(["head"])'), ('receiver', '["head"].concat_arrays()')):
    add('excluded_single_concat_' + route, 'return(' + expression + '.with(){return(value)})')
assert len(cases) == 52
(BASE / 'prefix_cases.json').write_text(json.dumps(cases, indent=2) + '\n')
prior = Path('docs/checkpoints/array-transform-result-perl-2026-11-07')
observer = (prior / 'observer_host.pl').read_text().replace('array-transform-result-perl-2026-11-07', 'array-transform-composition-perl-2026-11-07').replace('/host_cases.json', '/prefix_cases.json')
(BASE / 'observer_prefix.pl').write_text(observer)
capture = (prior / 'capture_qualified.py').read_text().replace("('preflight', 'after', 'inverse', 'restored')", "('prefix_intake',)")
capture = capture.replace("BASE / 'observer.pl'", "BASE / 'observer_prefix.pl'").replace("BASE / 'cases.json'", "BASE / 'prefix_cases.json'")
(BASE / 'capture_prefix.py').write_text(capture)
print('Composition activated; authored52 literal-prefix/host/excluded-arity controls before production')

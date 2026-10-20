"""Capture once or verify readonly; fixed input selection is stable across Git staging."""
import gzip
import json
import sys
from pathlib import Path
import common as c
import review_recurrence as review


def input_paths():
    paths = set(c.load('focused-final-inputs.json.gz')['inputs'])
    paths.update(c.load('doc-final-inputs.json.gz')['book'])
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
                 if path.is_file() and path.name not in ('publication-recurrence-inputs.json', 'publication-recurrence.json'))
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / 'tests/numeric-codeblocks').iterdir()
                 if path.is_file())
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / 'docs/checkpoints/type-numeric-admission').iterdir()
                 if path.is_file())
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / 'docs/checkpoints/type-numeric-admission/recurrence').rglob('*')
                 if path.is_file() and '__pycache__' not in path.parts)
    paths.add('tests/language-readiness/scalar-numeric-regression-evolution.json.gz')
    # Own outputs cannot be their own inputs. New tracked-file discovery is not a hidden staging dependency.
    paths.discard('docs/claims/' + c.OWNER + '.json')
    return sorted(paths)


def record(result):
    producers = [path for path in input_paths() if path.startswith((c.PREFIX, 'docs/checkpoints/type-numeric-admission/')) and path.endswith(('.py', '.pl'))]
    bindings = [dict(path=path, sha256=c.identity(path)['sha256'], role='producer') for path in producers]
    bindings.append(dict(path=c.PREFIX + 'publication-recurrence-inputs.json',
                         sha256=c.identity(c.PREFIX + 'publication-recurrence-inputs.json')['sha256'], role='input'))
    claim = dict(name='perl-scalar-numeric-codeblocks-and-snapshots',
        statement='Perl deferred scalar numeric calls, aliases and receiver methods use the scalar numeric contract; '
                  'ordinary variadic operands retain their evaluated values.',
        scope=result['limits'],
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish_recurrence.py',
            granularity='Fixed authored case and typed value/cause across descriptor/Get/fresh generated source; '
                        'actual source fault/restoration; retained suite execution and full input epoch; book source/anchor.',
            result='318 GREEN;169 accepted-source RED/129 controls;20 additional C1 cases/9 RED;13 actual faults '
                   'and restorations; retained17/1962 with10006 inputs; accepted prior replay14/1924 with10000 inputs; '
                   '89 book inputs/3 executed examples and displaced-heading RED; whole first10142-input '
                   'draft/readonly0, exact rejected candidate and actual owner RED/GREEN plus14 controls; whole second10162-input draft/readonly0,10175 source images, historical578+66 controls and two auditor faults.'),
        falsify=dict(status='checked', hypothesis='Missing dispatch, wrong aliases/kinds, late operand reads, '
                     'invalid-shape effects or permissive test observers silently produce a false pass.',
            oracle='Unchanged neutral numeric contract; independent authored expected values, saved-slot controls, '
                   'actual accepted source/C1 epochs, frozen test fragments and real generated source; book anchor.',
            red_control='169 accepted-source failures;9 later C1 mixed-chain failures;12 engine faults and one actual '
                        'AST observer fault reject and restore;21 Phase0 observer failures and missing-selector rejection; '
                        'omitted prior producer fault rejects/restores; displaced book heading fails anchor acceptance; '
                        'actual dual-owner RED becomes sole-owner GREEN; candidate corruption/truncation/order reject;66 numeric inverse controls and two actual auditor faults reject and restore.'),
        durability=dict(status='checked', mode='live', inputs=sorted(bindings, key=lambda item: item['path'])))
    return dict(version=1, owner=c.OWNER, claims=[claim])


def main():
    assert sys.argv[1:] in ([], ['--capture'])
    capture = sys.argv[1:] == ['--capture']
    path = c.ROOT / ('docs/claims/' + c.OWNER + '.json')
    first = json.loads(gzip.decompress((c.ROOT / 'docs/checkpoints/type-numeric-admission/recurrence/canonical2.json.gz').read_bytes()))
    if capture:
        assert c.read('docs/claims/' + c.OWNER + '.json') == first['claim']
    inputs = {path: c.identity(path) for path in input_paths()}
    if capture:
        c.write_new('publication-recurrence-inputs.json', dict(inputs=inputs,
            scope='All regular tracked files from the actual focused context, current complete book/Knowledge '
                  'and every new proof/fixture file. Full filesystem modes and hashes precede fresh proof. '
                  'Historical epochs recover from explicit full-byte draft packets or real accepted Git. '
                  'Original4 context qualification remains explicit. Installed tools/core libraries are '
                  'read-only prerequisites; Gitlinks and symlink targets are not inspected. Own outputs excluded.'))
    assert c.load('publication-recurrence-inputs.json')['inputs'] == inputs
    result = review.check()
    assert c.unchanged(inputs)
    raw = (json.dumps(record(result), separators=(',', ':')) + '\n').encode()
    assert len(raw) <= 131072
    publication = dict(result=result, record_base64=c.encode(raw))
    if capture:
        assert c.read('docs/claims/' + c.OWNER + '.json') == first['claim']
        c.write_new('publication-recurrence.json', publication)
        path.write_bytes(raw)
    else:
        assert path.read_bytes() == raw and c.load('publication-recurrence.json') == publication
    print('Current numeric recurrence publication PASS:', len(inputs), 'closed inputs;318 GREEN;169 accepted RED;13 faults')


if __name__ == '__main__':
    main()

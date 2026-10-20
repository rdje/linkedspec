"""Explicit current publisher: premeasurement manifest, readonly proof, bounded record."""
import gzip
import json
import sys
from pathlib import Path
import common as c
import review_required as review
import required_records as records


def input_paths():
    original = json.loads(c.decode(records.required_load('preservation.json.gz')['original_claim']['base64']))
    paths = {item['path'] for item in original['claims'][0]['durability']['inputs']}
    assert len(paths) == 823
    prepared = review.load('final-inputs.json.gz')['inputs']
    paths.update(records.current_proposals(prepared, review.load('docs-proposals.json.gz')))
    paths.update(c.PREFIX + name for name in (
        'required_records.py', 'review_required.py', 'publish_required.py', 'current_required.py',
        'graph-required-inputs.json.gz', 'graph-required-run.json.gz',
        'book-required-inputs.json.gz', 'book-required-run.json.gz'))
    paths.update(('t/lib/method_locations.py', 't/lib/LinkedSpecTest/MethodLocations.pm',
                  't/lib/LinkedSpecTest/EmittedValues.pm',
                  'docs/checkpoints/type-values-required/capsules.py',
                  'docs/checkpoints/type-values-required/closure-final.json'))
    return paths


def make_claim(result, bindings):
    g, h, r = result['graph'], result['historical'], result['required']
    return dict(name='perl-evaluated-list-values',
        statement='Finite Perl list operands retain evaluated values across later effects, preserving flat splices and copy-on-write.',
        scope='Real c053 plus retained proposals. No exhaustive methods, cross-backend or private/parent admission. '
              'Scoped-with4/numeric5/drop6 and startup32/35 remain owned. Focused52 retains1651 inputs/982 skips. '
              'Earlier incomplete closures, wrong oracle, compiler/preparation failures, baseline guard limits '
              'and uncommitted draft epochs remain disclosed in their preserved records. No historical observation is refreshed.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Each23 value/kind; seven suites/277 inputs; focused52; complete Knowledge/list/book; whole prior reader; '
                        'historical inverse/recovery; recurring12 suites and native15 captures.',
            result=f"23 GREEN/19 accepted RED; graph{g}; Knowledge{result['knowledge_bytes']}; book89/heading denial; "
                   f"prior388/full68814/2706 context; historical{h}; recurring{r}."),
        falsify=dict(status='checked',
            hypothesis='Late reads, erased splices, null/all-skip observers, permissive historical inverses or diagnostic projection could hide differences.',
            oracle='Fixed independent23 values/kinds, saved bindings, real c053 source,130 historical/manual goldens, '
                   'original archive/hash/census, frozen native rows and independent emitted-value/ABI goldens.',
            red_control='Emitter faults19/14/2/1/1/1; observer129 plus one null; missing selector; heading loss; '
                        '368 original plus210 fragment denials and equal-JSON byte fault; mapper198 failures and exact restoration; '
                        'wrong callback/file/line, unmatched statement, flattened return and wrong value. '
                        'All original823 direct inputs remain; new support inputs use a closed hash-checked manifest.'),
        durability=dict(status='checked', mode='live', inputs=bindings))


def record_bytes(record):
    raw = (json.dumps(record, separators=(',', ':')) + '\n').encode()
    assert json.loads(raw) == record and len(raw) <= 131072, (len(raw), len(record['claims'][0]['durability']['inputs']))
    return raw


def main():
    assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
    capture = sys.argv[1:] == ['--capture']
    paths = input_paths()
    identities = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
    manifest_path = c.PREFIX + 'publication-required-final-inputs.json'
    if sys.argv[1:] == ['--preflight']:
        result = review.review(fresh=False)
        bindings = [dict(path=path, sha256=item['sha256'],
            role='producer' if Path(path).suffix in ('.py', '.pl', '.sh', '.t', '.pm') else 'input')
            for path, item in identities.items()]
        bindings.append(dict(path=manifest_path, sha256='0' * 64, role='input'))
        bindings.sort(key=lambda item: item['path'])
        raw = record_bytes(dict(version=1, owner=c.OWNER, claims=[make_claim(result, bindings)]))
        print('Publication format/input preflight PASS:', len(bindings), 'bindings;', len(raw), 'bytes')
        return
    if capture:
        c.write_new(manifest_path, dict(inputs=identities,
            producer=c.read(c.PREFIX + 'publish_required.py'),
            entrypoint=c.read(c.PREFIX + 'publish.py'),
            reviewer=c.read(c.PREFIX + 'review_required.py'),
            scope='Actual identities/modes precede fresh current review. Complete original drafts '
                  'and source snapshots remain immutable. The manifest itself is directly bound.'))
    manifest = review.load('publication-required-final-inputs.json')
    assert manifest['inputs'] == identities
    assert manifest['producer'] == c.read(c.PREFIX + 'publish_required.py')
    assert manifest['entrypoint'] == c.read(c.PREFIX + 'publish.py')
    assert manifest['reviewer'] == c.read(c.PREFIX + 'review_required.py')
    result = review.review()
    assert result['result'] == 'PASS'
    bindings = [dict(path=path, sha256=item['sha256'],
        role='producer' if Path(path).suffix in ('.py', '.pl', '.sh', '.t', '.pm') else 'input')
        for path, item in identities.items()]
    manifest_item = c.read(manifest_path)
    bindings.append(dict(path=manifest_path, sha256=manifest_item['sha256'], role='input'))
    bindings.sort(key=lambda item: item['path'])
    record = dict(version=1, owner=c.OWNER, claims=[make_claim(result, bindings)])
    raw = record_bytes(record)
    assert identities == {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in paths}
    receipt_path = c.PREFIX + 'publication-required-final.json'
    if capture:
        preserved = json.loads(gzip.decompress(
            (c.ROOT / 'docs/checkpoints/type-values-required/preservation.json.gz').read_bytes()))
        assert c.read(c.CLAIM) == preserved['original_claim']
        (c.ROOT / c.CLAIM).write_bytes(raw)
        c.write_new(receipt_path, dict(result='PASS', record_base64=c.encode(raw),
            record_sha256=c.sha(raw), review=result,
            input_modes={**{path: item['mode'] for path, item in identities.items()}, manifest_path: manifest_item['mode']}))
    else:
        assert (c.ROOT / c.CLAIM).read_bytes() == raw
        receipt = review.load('publication-required-final.json')
        assert receipt['record_base64'] == c.encode(raw) and receipt['review'] == result
    print('Current Perl evaluated values publication PASS:', len(bindings), 'inputs;', len(raw),
          'bytes;23 GREEN/19 baseline RED; focused52/982 skips')


if __name__ == '__main__':
    main()

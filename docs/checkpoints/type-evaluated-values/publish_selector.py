"""Explicit current publisher: premeasurement manifest, readonly proof, bounded record."""
import gzip
import json
import sys
from pathlib import Path
import common as c
import review_selector as review
import selector_records as records


def input_paths():
    original = json.loads(c.decode(records.selector_load('preservation.json.gz')['original_claim']['base64']))
    paths = {item['path'] for item in original['claims'][0]['durability']['inputs']}
    assert len(paths) == 837
    logical = 'docs/checkpoints/type-values-admission/canonical1-candidate.patch.gz'
    paths.remove(logical)
    paths.add(records.storage.INDEXES[logical])
    prepared = review.load('final-inputs.json.gz')['inputs']
    paths.update(records.current_proposals(prepared, review.load('docs-proposals.json.gz')))
    paths.update(c.PREFIX + name for name in (
        'selector_records.py', 'review_selector.py', 'publish_selector.py', 'current_selector.py'))
    paths.add('docs/checkpoints/type-values-selector/closure-final.json')
    return paths


def make_claim(result, bindings):
    g, h, s = result['graph'], result['historical'], result['selector']
    return dict(name='perl-evaluated-list-values',
        statement='Finite Perl list operands retain evaluated values across later effects, preserving flat splices and copy-on-write.',
        scope='c053 plus owned proposals; no exhaustive method/backend/private admission. Scoped4/numeric5/drop6/startup32/35 stay owned. '
              'Rejected/supplemental epochs retain their limits. Original837 logical inputs survive; one physical path becomes indexed chunks. No fake historical revision.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='23 values/kinds; seven suites; complete graph/list/book and prior reader; historical audit;12 recurring suites;3 scanner fixtures;2 byte streams.',
            result=f"23 GREEN/19 RED; suites7/277; focused52/982 skips; ordinary1035; private5001; "
                   f"graph{g['markdown']}/{g['facts']}/{g['question_keys']},lists{g['list_items']}/{g['list_fields']},"
                   f"bytes{result['knowledge_bytes']}; book89; prior388/full68814; history{h['fragments']}/578; "
                   f"selector28/fault9,6,3; exact2 streams/31 chunks; scanner{s['scanner_candidates']}."),
        falsify=dict(status='checked', hypothesis='Late reads or permissive source/storage checks hide differences.',
            oracle='Fixed values, saved bindings, c053, frozen native rows, original byte hashes/modes and historical archive.',
            red_control='Emitter19/14/2/1/1/1; observer129/null; skip/heading; history368+210/equal-JSON; mapper198; '
                        'callback/file/line/value; scanner28/fault9,6,3; partition10/fault2; metadata4/fault1; exact restoration.'),
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
    manifest_path = c.PREFIX + 'publication-selector-inputs.json'
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
            producer=c.read(c.PREFIX + 'publish_selector.py'),
            entrypoint=c.read(c.PREFIX + 'publish.py'),
            reviewer=c.read(c.PREFIX + 'review_selector.py'),
            scope='Actual identities/modes precede fresh current review. Complete original drafts '
                  'and source snapshots remain immutable. The manifest itself is directly bound.'))
    manifest = review.load('publication-selector-inputs.json')
    assert manifest['inputs'] == identities
    assert manifest['producer'] == c.read(c.PREFIX + 'publish_selector.py')
    assert manifest['entrypoint'] == c.read(c.PREFIX + 'publish.py')
    assert manifest['reviewer'] == c.read(c.PREFIX + 'review_selector.py')
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
    receipt_path = c.PREFIX + 'publication-selector.json'
    if capture:
        preserved = records.selector_load('preservation.json.gz')
        assert c.read(c.CLAIM) == preserved['original_claim']
        (c.ROOT / c.CLAIM).write_bytes(raw)
        c.write_new(receipt_path, dict(result='PASS', record_base64=c.encode(raw),
            record_sha256=c.sha(raw), review=result,
            input_modes={**{path: item['mode'] for path, item in identities.items()}, manifest_path: manifest_item['mode']}))
    else:
        assert (c.ROOT / c.CLAIM).read_bytes() == raw
        receipt = review.load('publication-selector.json')
        assert receipt['record_base64'] == c.encode(raw) and receipt['review'] == result
    print('Current Perl evaluated values publication PASS:', len(bindings), 'inputs;', len(raw),
          'bytes;23 GREEN/19 baseline RED; focused52/982 skips')


if __name__ == '__main__':
    main()

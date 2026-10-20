"""Explicit current publisher: premeasurement manifest, readonly proof, bounded record."""
import gzip
import json
import sys
from pathlib import Path
import common as c
import review_portable as review
import phase0_records_portable as records


def input_paths():
    paths = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
             if path.is_file() and path.name not in ('publication-portable.json', 'publication-portable-inputs.json')}
    prepared = review.load('final-inputs.json.gz')['inputs']
    paths.update(path for path in prepared if path.startswith('perl/'))
    paths.update(review.load('test-inputs.json.gz')['inputs'])
    paths.update(review.load('book-phase0-inputs.json.gz')['inputs'])
    paths.update(records.current_proposals(prepared, review.load('docs-proposals.json.gz')))
    paths.update(path for path in review.load('graph-phase0-inputs.json.gz')['inputs']
                 if not path.startswith(('docs/knowledge/', 'docs/decisions/')))
    paths.update(path.relative_to(c.ROOT).as_posix() for path in
                 (c.ROOT / 'docs/checkpoints').glob('TYPE-REFERENCE-BOOK.1.2.3-*') if path.is_file())
    paths.update('docs/checkpoints/type-values-admission/' + name for name in (
        'preservation.json.gz', 'baseline.json', 'canonical1.json.gz',
        'canonical1-candidate.patch.gz', 'ordinary-phase0.json.gz',
        'portable-proposals.json.gz', 'portable.py', 'archive.py'))
    paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,
                  'docs/checkpoints/type-reference-migrations/normalize_inc.py'))
    preserved = review.load('preservation.json.gz')
    for key, item in preserved['live'].items():
        if key != c.OLD_CLAIM + '#0':
            paths.add(key.rsplit('#', 1)[0])
            paths.update(item['inputs'])
    return paths


def make_claim(result, bindings):
    graph = result['graph']
    return dict(name='perl-evaluated-list-values',
        statement=(
            'Perl emitted array/harray members, constructor operands, dynamic keys and callable '
            'arguments retain each evaluated value before later sibling effects. Accepted runtime '
            'rejects19 of23 finite cases with four healthy controls; candidate Get/fresh generated '
            'match all23 values/kinds. Seven selected suites pass from declared277 test/data/bin '
            'inputs. Six actual source faults reject19/14/2/1/1/1 cases and restore. Additional '
            'focused52 uses a frozen1651-input snapshot,982 explicit skipped roots,130 value/diagnostic '
            'goldens and unchanged native/descriptor checks. An actual observer fault rejects129 '
            'goldens with one valid null control and exact restoration; a missing selector rejects '
            'all-skip false acceptance. Two historical compiler advisories remain explicit data. '
            f"Current Knowledge {graph['markdown']}/{graph['facts']}/{graph['question_keys']} preserves"
            f"{graph['list_items']} entries/{graph['list_fields']} fields at {result['knowledge_bytes']} bytes. "
            'Complete89-input book/heading denial and whole prior388/full68814 reader in2706 supplied '
            'files pass with exact prior channels and supplied bytes/modes unchanged. Generated '
            'single-key drop warns and fatal caller loading rejects; .1.2.6 owns that separate defect.'),
        scope=(
            'Finite Perl evaluated-list repair at real c053 source boundary plus declared proposals. '
            'Explicit splices retain list behavior; no deep-copy/alias, exhaustive methods, cross-backend '
            'or private/parent admission. Wrong push oracle, first candidate, no-write source/doc '
            'writers, incomplete syntax2/TAP2 context, dated graph count failure and uncommitted '
            '568/91709 and573/92573 drafts remain recoverable with actual bytes/modes. No fabricated '
            'historical revision. Original bare Phase01035 transcript is supplemental: no initial '
            'environment snapshot/separate channels/full per-read closure;140 spelling failures plus '
            'a wrapper-bypass volume failure with explicit fixture cleanup. Source-closed focused52 '
            'has982 explicit skips and is not ordinary all1035 admission. Three first focused fixture '
            'compile failures remain retained; caller presence maps fix fixtures without changing '
            'goldens. Historical-oracle preparation/load/zero-stderr failures remain exact, and two '
            'actual advisories are attributed without suppression. Static publication rewrite/format '
            'errors are retained separately before any domain execution. Scoped-with4, numeric5, '
            'generated drop6, boolean literal startup35 and caller shadowing startup32 remain owned. '
            'Canonical exact-staged receipt, ordinary all1035 and normal hooks are separately required before landing.'),
        rederive=dict(status='checked',
            command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Each23 native/generated value/kind; seven selected suites;130 historical/manual '
                'compatibility goldens; focused52 names/numbers and explicit skip population; supplied '
                'snapshot bytes/modes; complete current graph/book; whole prior publication.',
            result='Accepted19 RED/four controls; candidate23 GREEN; seven suites0; focused52 PASS with '
                '982 skips; observer129 RED/one null control/restoration and selector RED; current '
                'graph/book/whole original reader PASS. Generated-drop warning/FATAL RED remains owned .1.2.6.'),
        falsify=dict(status='checked',
            hypothesis='Lvalues could change earlier observations; scalar snapshots could erase splices; '
                'an observer could return null, a selector could skip everything, warnings could be '
                'dropped, or environment/missing inputs could be mistaken for behavior.',
            oracle='Independent fixed23 values/kinds, saved-binding/host controls, accepted source,106 '
                'historical test expectations plus24 independent manual cases, original root names/'
                'numbers, intact ordinary-file assertions, rendered anchors and actual prior channels.',
            red_control='Accepted runtime19 RED. Six actual emitter faults reject19/14/2/1/1/1 and restore. '
                'Actual observer execution bypass rejects129 assertions with one genuine null; healthy '
                'source restores52. Absent selector exits nonzero despite excluded SKIPs. Changed '
                'heading builds0 but loses anchor. Three fixture compile errors reject value goldens. '
                'Public generated drop emits one advisory and caller FATAL syntax rejects loading; '
                'global warning policy remains unchanged.'),
        durability=dict(status='checked', mode='live', inputs=bindings))


def record_bytes(record):
    claim = record['claims'][0]
    bindings = claim['durability']['inputs']
    display = dict(record, claims=[dict(claim, durability=dict(claim['durability'], inputs='__INPUTS__'))])
    raw = json.dumps(display, indent=1).replace('"__INPUTS__"', '[\n' + ',\n'.join(
        '     ' + json.dumps(item, separators=(',', ':')) for item in bindings) + '\n    ]')
    raw = (raw + '\n').encode()
    assert json.loads(raw) == record and len(raw) <= 131072, (len(raw), len(bindings))
    return raw


def main():
    assert sys.argv[1:] in ([], ['--capture'])
    capture = bool(sys.argv[1:])
    paths = input_paths()
    identities = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
    manifest_path = c.PREFIX + 'publication-portable-inputs.json'
    if capture:
        c.write_new(manifest_path, dict(inputs=identities,
            producer=c.read(c.PREFIX + 'publish_portable.py'),
            entrypoint=c.read(c.PREFIX + 'publish.py'),
            reviewer=c.read(c.PREFIX + 'review_portable.py'),
            scope='Actual identities/modes precede fresh current review. Complete original drafts '
                  'and source snapshots remain immutable. The manifest itself is directly bound.'))
    manifest = review.load('publication-portable-inputs.json')
    assert manifest['inputs'] == identities
    assert manifest['producer'] == c.read(c.PREFIX + 'publish_portable.py')
    assert manifest['entrypoint'] == c.read(c.PREFIX + 'publish.py')
    assert manifest['reviewer'] == c.read(c.PREFIX + 'review_portable.py')
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
    receipt_path = c.PREFIX + 'publication-portable.json'
    if capture:
        preserved = json.loads(gzip.decompress(
            (c.ROOT / 'docs/checkpoints/type-values-admission/preservation.json.gz').read_bytes()))
        assert c.read(c.CLAIM) == preserved['original_claim']
        (c.ROOT / c.CLAIM).write_bytes(raw)
        c.write_new(receipt_path, dict(result='PASS', record_base64=c.encode(raw),
            record_sha256=c.sha(raw), review=result,
            input_modes={**{path: item['mode'] for path, item in identities.items()}, manifest_path: manifest_item['mode']}))
    else:
        assert (c.ROOT / c.CLAIM).read_bytes() == raw
        receipt = review.load('publication-portable.json')
        assert receipt['record_base64'] == c.encode(raw) and receipt['review'] == result
    print('Current Perl evaluated values publication PASS:', len(bindings), 'inputs;', len(raw),
          'bytes;23 GREEN/19 baseline RED; focused52/982 skips')


if __name__ == '__main__':
    main()

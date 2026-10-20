"""Explicit current publisher: premeasurement manifest, readonly proof, bounded record."""
import gzip
import json
import sys
from pathlib import Path
import common as c
import review_signature as review
import signature_records as records


def input_paths():
    paths = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
             if path.is_file() and path.name not in ('publication-signature.json', 'publication-signature-inputs.json')}
    prepared = review.load('final-inputs.json.gz')['inputs']
    paths.update(path for path in prepared if path.startswith('perl/'))
    paths.update(review.load('test-inputs.json.gz')['inputs'])
    paths.update(review.load('book-signature-inputs.json.gz')['inputs'])
    paths.update(records.current_proposals(prepared, review.load('docs-proposals.json.gz')))
    paths.update(path for path in review.load('graph-signature-inputs.json.gz')['inputs']
                 if not path.startswith(('docs/knowledge/', 'docs/decisions/')))
    paths.update(path.relative_to(c.ROOT).as_posix() for path in
                 (c.ROOT / 'docs/checkpoints').glob('TYPE-REFERENCE-BOOK.1.2.3-*') if path.is_file())
    paths.update('docs/checkpoints/type-values-admission/' + name for name in (
        'preservation.json.gz', 'baseline.json', 'canonical1.json.gz',
        'canonical1-candidate.patch.gz', 'ordinary-phase0.json.gz',
        'portable-proposals.json.gz', 'portable.py', 'archive.py'))
    signature = c.ROOT / 'docs/checkpoints/type-values-signature'
    paths.update(path.relative_to(c.ROOT).as_posix() for path in signature.iterdir() if path.is_file())
    paths.update(records.signature_load('historical-final-inputs.json')['inputs'])
    paths.update(records.signature_load('baseline-isolated-inputs.json')['inputs'])
    paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,
                  'docs/checkpoints/type-reference-migrations/normalize_inc.py'))
    preserved = review.load('preservation.json.gz')
    for key, item in preserved['live'].items():
        if key != c.OLD_CLAIM + '#0':
            paths.add(key.rsplit('#', 1)[0])
            paths.update(item['inputs'])
    return paths


def make_claim(result, bindings):
    g, h = result['graph'], result['historical']
    return dict(name='perl-evaluated-list-values',
        statement=(
            'Perl emitted array/harray members, constructor operands, dynamic keys and callable '
            'arguments retain evaluated values across later effects. Accepted runtime rejects19 '
            'of23 cases; four controls stay healthy and candidate Get/fresh generated match all23. '
            f"The historical auditor reverses{h['fragments']} reviewed Phase0 fragments: "
            f"{h['original_denials']} original and{h['added_denials']} added denials pass. "
            'Archive134/full84613241,22 recovery controls and both isolated source-audit sides '
            'retain their calibrated original-log/tracked-write denial boundary.'),
        scope=(
            'Finite Perl repair from real c053 plus explicit proposals. Flat splices and existing '
            'copy-on-write semantics remain; exhaustive methods, cross-backend and private/parent '
            'admissions remain separately owned. Scoped-with4, numeric5, generated-drop6, startup '
            'boolean35 and caller-shadowing32 stay open. The focused52 snapshot retains1651 inputs, '
            'its original auditor and982 explicit skips. Current auditor evolution has independent '
            '184-input recovery proof and a separate original-control baseline with initial '
            'restored modes. The earlier outer baseline uses original log locations; its missing '
            'initial mode/guard observations remain disclosed and supplemental. Historical runtime '
            'observations, hashes and logs are unchanged. Wrong push oracle/first candidate, '
            'no-write writers, incomplete syntax2/TAP2, dated metadata count, three fixture compile '
            'errors, static publisher failures and the first new-control KeyError/two-reference '
            'correction remain recoverable. Drafts568/full91709,573/full92573 and649/full106855 '
            'retain whole records, original inputs/modes, changed-before bytes and actual readonly '
            'baselines without fabricated historical commits. Ordinary all1035, canonical exact '
            'staged receipt and normal hooks separately govern landing.'),
        rederive=dict(status='checked',
            command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Each23 JSON value/kind;277 selected test/data/bin inputs and seven suites; '
                'focused52 original names/numbers;130 historical/manual value/diagnostic goldens; '
                'actual producer faults; complete graph/list rows and89 book inputs; whole prior '
                'publication; full historical source inverse and actual isolated recovery controls.',
            result=(
                'Accepted19 RED/four controls; candidate23 GREEN; seven suites0; focused52 PASS/982 '
                'skips; observer129 RED/one null/restoration and missing-selector RED. '
                f"Graph{g['markdown']}/{g['facts']}/{g['question_keys']}, lists{g['list_items']}/"
                f"{g['list_fields']}, Knowledge{result['knowledge_bytes']} bytes. Book89/heading "
                'denial and whole accepted388/full68814 reader in2706 supplied files pass. '
                f"Historical{h['fragments']} fragments: original{h['original_denials']} + "
                f"added{h['added_denials']} = {h['current_denials']} denials;134 restored inputs, "
                '22 recovery controls,184 explicit proof inputs and both isolated denial guards '
                'pass. Semantic-JSON-preserving table byte fault rejects; reader restores.')),
        falsify=dict(status='checked',
            hypothesis='Earlier lvalues could be read late, snapshots could erase splices, an '
                'observer could return null or skip all roots, or missing inputs could look like '
                'behavioral RED. A historical inverse could forgive foreign edits or ignore table bytes.',
            oracle='Independent fixed23 values/kinds, saved-binding/host controls, accepted c053 '
                'source,106 historical expectations plus24 manual cases, original root names/numbers, '
                'complete original historical Git bytes/hash, unchanged archive/census and original '
                'control population; rendered anchor presence is distinct from build success.',
            red_control='Six actual emitter faults reject19/14/2/1/1/1 and restore. Actual observer '
                'bypass rejects129 goldens with one genuine null; healthy source restores52. Missing '
                'selector exits nonzero despite SKIPs. Changed heading builds0 but loses anchor. '
                'Original auditor rejects the reviewed Phase0 delta; each70 fragment is removed, '
                'duplicated and altered for210 added denials. Existing foreign-edit controls remain. '
                'A whitespace-only table byte change preserves valid/equal JSON but rejects by '
                'identity; restored reader accepts. Generated scalar-drop advisory/FATAL loading '
                'RED is separately owned by6; no warning policy changes.'),
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
    manifest_path = c.PREFIX + 'publication-signature-inputs.json'
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
            producer=c.read(c.PREFIX + 'publish_signature.py'),
            entrypoint=c.read(c.PREFIX + 'publish.py'),
            reviewer=c.read(c.PREFIX + 'review_signature.py'),
            scope='Actual identities/modes precede fresh current review. Complete original drafts '
                  'and source snapshots remain immutable. The manifest itself is directly bound.'))
    manifest = review.load('publication-signature-inputs.json')
    assert manifest['inputs'] == identities
    assert manifest['producer'] == c.read(c.PREFIX + 'publish_signature.py')
    assert manifest['entrypoint'] == c.read(c.PREFIX + 'publish.py')
    assert manifest['reviewer'] == c.read(c.PREFIX + 'review_signature.py')
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
    receipt_path = c.PREFIX + 'publication-signature.json'
    if capture:
        preserved = json.loads(gzip.decompress(
            (c.ROOT / 'docs/checkpoints/type-values-signature/preservation.json.gz').read_bytes()))
        assert c.read(c.CLAIM) == preserved['original_claim']
        (c.ROOT / c.CLAIM).write_bytes(raw)
        c.write_new(receipt_path, dict(result='PASS', record_base64=c.encode(raw),
            record_sha256=c.sha(raw), review=result,
            input_modes={**{path: item['mode'] for path, item in identities.items()}, manifest_path: manifest_item['mode']}))
    else:
        assert (c.ROOT / c.CLAIM).read_bytes() == raw
        receipt = review.load('publication-signature.json')
        assert receipt['record_base64'] == c.encode(raw) and receipt['review'] == result
    print('Current Perl evaluated values publication PASS:', len(bindings), 'inputs;', len(raw),
          'bytes;23 GREEN/19 baseline RED; focused52/982 skips')


if __name__ == '__main__':
    main()

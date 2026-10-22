"""Bind the private guard admission and its bounded documentation to a new candidate."""
from pathlib import Path
import subprocess
import sys
ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
PREFIX = 'docs/checkpoints/type-array-count-first/'
sys.path.insert(0, str(ROOT / PREFIX))
import common as c
import context


def main():
    paths = [PREFIX + name for name in ['review.py', 'publish.py', 'README.md']]
    paths += ['docs/linkedspec-book/src/development/documentation-workflow.md',
              'docs/knowledge/terse-type-method-surface-inventory.md']
    before = {path: c.read(path) for path in paths}
    c.write_new('publication4-preparation-inputs.json.gz', dict(context=context.snapshot(),
        producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()), before=before))
    with (ROOT / PREFIX / 'prepare_private_publication.py').open('xb') as output:
        output.write(Path(__file__).read_bytes())
    text = c.decode(before[PREFIX + 'review.py']['base64']).decode()
    text = text.replace("'history-doc-addendum2.json.gz')", "'history-doc-addendum2.json.gz','history-doc-addendum3.json.gz')", 1)
    text = text.replace("    phase0 = verify_phase0()", "    phase0 = verify_phase0()\n    import private_review\n    private = private_review.check(fresh=fresh)", 1)
    text = text.replace('doc4-', 'doc5-').replace('artifact3-', 'artifact4-')
    text = text.replace("historical_controls=phase0['current'],", "private=private,historical_controls=phase0['current'],", 1)
    c.source(PREFIX + 'review.py').write_text(text)
    path = PREFIX + 'publish.py'
    text = c.decode(before[path]['base64']).decode()
    text = text.replace('publication3', 'publication4').replace('artifact3-', 'artifact4-').replace("c.load('draft2.json.gz')['packets']['claim']", "c.load('draft3.json.gz')['packets']['claim']")
    marker = "    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(set(producers))]"
    assert text.count(marker) == 1
    text = text.replace(marker, "    producers += ['t/actionir_method_kind_capture.t','t/actionir_method_kind_probe.pl',\n        't/actionir_method_kind_authority_probe.pl','t/lib/LinkedSpecTest/MethodLocations.pm','t/lib/LinkedSpecTest/EmittedValues.pm']\n" + marker, 1)
    marker = "    continuity = dict(name='finite-selection-history-continuity',"
    assert text.count(marker) == 1
    text = text.replace(marker, "    runtime['rederive']['result'] += f\" Private count fixture:{result['private']['assertions']} assertions; three exact current guard expectations preserve original native captures.\"\n    runtime['falsify']['red_control'] += (' Whole draft3 and actual readonly0/full canonical2 failure survive. Three stale private count expectations are repaired without editing native captures. Actual expectation omission rejects; matched old guard and source expectation reject solely through independent array/nonarray execution; exact restoration passes.')\n" + marker, 1)
    c.source(path).write_text(text)
    for old, new, first, second in [('artifacts3.py','artifacts4.py','artifact3','artifact4'),
                                     ('doc_proof4.py','doc_proof5.py','doc4','doc5')]:
        with (ROOT / PREFIX / new).open('x') as output:
            output.write(c.source(PREFIX + old).read_text().replace(first, second))
    path = 'docs/linkedspec-book/src/development/documentation-workflow.md'
    text = c.decode(before[path]['base64']).decode()
    marker = 'Prove wrong callbacks, files and lines still differ, then bypass the actual\n'
    assert text.count(marker) == 1
    text = text.replace(marker, 'For generated count guards, select only reviewed rows and execute both array\nand nonarray operands; retain the original capture and every other row field.\n' + marker, 1)
    c.source(path).write_text(text)
    path = 'docs/knowledge/terse-type-method-surface-inventory.md'
    old = c.decode(before[path]['base64']).decode()
    text = old.replace('date: 2026-10-21', 'date: 2026-10-22')
    text = text.replace('  - "why do malformed fluent arguments leak a Perl array-reference error"',
        '  - "why do malformed fluent arguments leak a Perl array-reference error"\n  - "why do private count captures expect old defined guards"')
    text = text.replace('Bindings hold scalar/array/harray/codeblock. Deferred bodies read caller slots;\nconstructors/keys/arguments retain values; updates use copy-on-write.',
        'Scalar/array/harray/codeblock bindings retain evaluated constructor/key/argument\nvalues; deferred bodies read caller slots; updates use copy-on-write.')
    text = text.replace('Serialized fluent args must be arrays before preflight; no backend admission.',
        'Fluent args require arrays before preflight. Three private count goldens retain\nnative captures; current guards execute against arrays/nonarrays. No backend admission.')
    text = text.replace('Accepted7 HTML differs only by its search-index reference: decoded payload changes\nare15 body-whitespace strings. Strict rejection remains; no general normalization.',
        'Accepted7 HTML: only the search-index reference differs; decoded changes are15\nbody-whitespace strings. Strict rejection remains.')
    text = text.replace('Context hash-gates gzip/chunks.37 verified32MiB parts restore three byte/mode aliases;\nnested-Git guards apply. Recursive originals: accepted49ce.',
        'Context hash-gates gzip/37 verified32MiB chunks and three byte/mode aliases;\nnested-Git guards apply. Recursive originals:49ce.')
    text = text.replace('Aggregate Numeric policies differ. Shape checks precede effects;', 'Aggregate Numeric differs. Shape precedes effects;')
    text = text.replace('Perl checks every decimal\nterm: empty sum0, othersundef; Rust filters differently.', 'Perl checks each decimal\nterm: empty sum0, othersundef; Rust filters differently.')
    text = text.replace('Perl deferred sorted/take use free/receiver forms. Sort is lexical; copied\ncomparands preserve numeric/string kinds through clones/indexes. Storable can\ncache private iOK on floats: measure flags before cloning.',
        'Deferred sorted/take have free/receiver forms. Lexical sort preserves copied\nnumeric/string kinds across clones/indexes; measure flags before Storable caches\nprivate iOK on floats.')
    text = text.replace('drop_keys copies keys/splices, stays FATAL-warning quiet and retains null\ndiagnostics. c053c9dcf inventoried substr/typed receivers; references remain pending.',
        'drop_keys copies keys/splices, keeps null diagnostics and FATAL-warning silence.\nc053c9dcf inventories substr/typed receivers; references pending.')
    text = text.replace('Type checkpoints retain epochs;10 verifies count/first.', 'Type epochs retained; count/first10 verified.')
    text = text.replace('Scoped with: [[', 'See [[')
    assert len(text.encode()) <= len(old.encode()) + 36, (len(text.encode()),len(old.encode()))
    c.source(path).write_text(text)
    # Extend only this slice's own live records; every earlier record stays exact.
    addendum = {}
    latest = c.load('history-doc-addendum2.json.gz')
    for surface, item in latest['surfaces'].items():
        previous = item['after']
        root = 'CHANGES.md' if surface == 'change_history' else 'DEVELOPMENT_NOTES.md'
        assert c.read(root) == previous
        old_record = item['new_record']
        new_record = old_record.rstrip('\n') + ' Three private count goldens retain native captures;236 assertions and semantic RED pass.\n\n'
        raw = c.decode(previous['base64'])
        assert raw.count(old_record.encode()) == 1
        changed = raw.replace(old_record.encode(), new_record.encode(), 1)
        assert len(changed) <= 32768
        c.source(root).write_bytes(changed)
        addendum[surface] = dict(before=previous,after=c.read(root),old_record=old_record,new_record=new_record)
    c.write_new('history-doc-addendum3.json.gz', dict(surfaces=addendum,
        scope='Only current count/first10 records gain the verified private guard admission; all prior records, archives and manifests stay exact.'))
    path = PREFIX + 'README.md'
    text = c.decode(before[path]['base64']).decode()
    text = text.replace('publication3.json and its manifest govern the final candidate.',
        'publication3.json and its manifest remain frozen; publication4.json and its manifest govern this candidate.')
    text += '''\nDraft3 retains11100 inputs/full modes, actual readonly0 and complete canonical2\nfailure:90 private files pass, three count-source expectations in the remaining\nfile are stale. Native captures stay exact. Three reviewed current expectations\nplus independent array/nonarray execution pass236 assertions. Actual expectation\nomission rejects; a matched old guard/source expectation rejects only in behavior\nchecks. Production and test restore exactly. Distinct doc5 and artifact4 bind the\ncurrent book and publication validator. Exact staged canonical admission remains\nrequired; earlier publications, original observations and failed logs stay frozen.\n'''
    c.source(path).write_text(text)
    c.write_new('publication4-preparation.json.gz', dict(before=before,
        after={path:c.read(path) for path in paths},history_addendum='history-doc-addendum3.json.gz'))
    print('Publication4 sources and bounded book/fact/continuity prepared; prior native captures and publications remain exact')


if __name__ == '__main__':
    main()

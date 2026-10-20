"""Default readonly publication; capture binds all current inputs before fresh proof."""
import json
import sys
from pathlib import Path
import common as c
import review


def input_paths():
    paths = set(c.load('green-inputs.json')['inputs'])
    paths.update(c.load('focused-inputs.json')['inputs'])
    docs = c.load('doc-final-inputs.json')
    paths.update(docs['book'])
    paths.update(docs['graph'])
    paths.update(('KNOWLEDGE_MAP.md', 'docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json',
                  'docs/checkpoints/type-evaluated-values/README.md'))
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
                 if path.is_file() and path.name not in ('publication-inputs.json', 'publication.json'))
    return sorted(paths)


def record(result, manifest):
    direct = [dict(path=c.PREFIX + name, sha256=c.identity(c.PREFIX + name)['sha256'],
                   role='producer' if name.endswith(('.py', '.pl')) else 'input')
              for name in manifest if name.endswith(('.py', '.pl'))]
    direct.append(dict(path=c.PREFIX + 'publication-inputs.json',
                       sha256=c.identity(c.PREFIX + 'publication-inputs.json')['sha256'], role='input'))
    assert len(direct) == len({item['path'] for item in direct})
    claim = dict(name='perl-scoped-with-callable-values',
        statement='Immediate Perl with exposes its scoped callable value and dynamic binding frame, restoring outer values on success/error.',
        scope='30 fixed contract cases through descriptor/Get/fresh generated source; authored-span oracle; '
              'six actual producer faults/restorations; retained direct suites; complete current book/Knowledge inputs. '
              'Whole prior845 is historical only at real accepted 2fca7d848. Initial observer/preparation and '
              'documentation epochs retain their limits. No exhaustive or cross-backend admission.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
            granularity='Named value/diagnostic case in both execution routes, authored source offsets, '
                        'actual source fault, supplied test suite, complete book render.',
            result=f"{result['runtime_cases']} GREEN/{result['baseline_red']} RED/"
                   f"{result['baseline_controls']} controls; six source faults and exact restorations; "
                   f"retained{result['retained_suites']}/{result['retained_tap_tests']} TAP in "
                   f"{result['test_inputs']} inputs; book{result['book_inputs']}/changed-heading denial; "
                   f"whole prior{result['prior_inputs']}/readonly0 preserved."),
        falsify=dict(status='checked', hypothesis='Scoped lookup, caller-frame shadowing, restoration or source spans silently drift.',
            oracle='Contract-derived values and typed causes, real delegated invocation frame, authored literal offsets, '
                   'accepted pre-fix source and rendered heading.',
            red_control='Pre-fix19 reject/11 controls; actual scoped-kind, dynamic-name, function-name, '
                        'frame-shadow, frame-restoration and authored-span faults each reject then restore; '
                        'changed-heading render loses the required anchor.'),
        durability=dict(status='checked', mode='live', inputs=sorted(direct, key=lambda item: item['path'])))
    return dict(version=1, owner=c.OWNER, claims=[claim])


def main():
    assert sys.argv[1:] in ([], ['--capture'])
    capture = sys.argv[1:] == ['--capture']
    paths = input_paths()
    identities = {path: c.identity(path) for path in paths}
    names = sorted(Path(path).name for path in paths if path.startswith(c.PREFIX))
    if capture:
        c.write_new('publication-inputs.json', dict(inputs=identities,
            scope='Closed current owned execution/test/neutral/book/Knowledge and all repair artifact inputs. '
                  'Hashes and full modes precede fresh readonly proof. Historical input bytes/modes recover '
                  'from the real prior revision and retained manifests/capsules. External installed toolchains '
                  'are read-only prerequisites; no dependency implementation is inspected.'))
    assert c.load('publication-inputs.json')['inputs'] == identities
    result = review.review()
    assert c.unchanged(identities)
    value = record(result, names)
    raw = (json.dumps(value, separators=(',', ':')) + '\n').encode()
    assert len(raw) <= 131072
    path = c.ROOT / ('docs/claims/' + c.OWNER + '.json')
    if capture:
        c.write_new('publication.json', dict(result=result, record_base64=c.encode(raw)))
        with path.open('xb') as output:
            output.write(raw)
    else:
        assert path.read_bytes() == raw
        assert c.load('publication.json') == dict(result=result, record_base64=c.encode(raw))
    print('Scoped with publication PASS:', len(identities), 'closed inputs;',
          result['runtime_cases'], 'GREEN;', result['baseline_red'], 'baseline RED')


if __name__ == '__main__':
    main()

"""Retain the actual UTF-8 warning epoch and correct only the new observer transport."""
import json
import common as c


def main():
    observed = c.load('accepted-observed.json.gz')
    report = c.load('accepted-run.json.gz')
    assert observed['inputs_unchanged'] and report['inputs_unchanged']
    run = observed['run']
    assert run['returncode'] == 0
    assert c.decode(run['stderr_base64']) == b'Wide character in print at docs/checkpoints/type-array-pipelines/probe.pl line 72.\n'
    assert len(json.loads(c.decode(run['stdout_base64']))['rows']) == len(c.load('cases.json')['cases'])
    old_observer_path = 'docs/checkpoints/type-array-pipelines/probe.pl'
    old_observer = c.read(old_observer_path)
    names = ['docs/tasks/TYPE-REFERENCE-BOOK.md', c.PREFIX + 'README.md', c.PREFIX + 'measure.py']
    before = {path: c.read(path) for path in names}
    after = {path: c.decode(packet['base64']).decode() for path, packet in before.items()}
    path = names[0]
    marker = '  Schedule: Finish13 before deferred count/first10, registered sorted/ordinary length11 and deferred indexed-write12. Keep reducer95 and complete operation inventory separately owned.\n'
    assert after[path].count(marker) == 1
    entry = '  Observer correction owned here: First116-case run has unchanged inputs and exit0, but the old public observer prints unencoded wide-character JSON to byte stdout. Its exact warning rejects the strict transport check before loaded-source validation. Preserve all original channels/context; a distinct UTF-8 observer and accepted2 rerun repair transport without changing runtime or weakening diagnostics.\n'
    after[path] = after[path].replace(marker, entry + marker, 1)
    after[c.PREFIX + 'README.md'] += '\nObserver transport intake: accepted-inputs/observed/run retain the first116-case attempt. Inputs stay unchanged and Perl exits0 with116 decoded rows, but its final unencoded JSON print emits an actual wide-character warning. This is a failed observer check, not an input mutation or a successful comparison. The new probe.pl enables UTF-8 output; the original pipeline observer stays exact. Separate accepted2 outputs must verify transport and compare the retained payload before implementation.\n'
    path = c.PREFIX + 'measure.py'
    text = after[path]
    text = text.replace("r'accepted|candidate[1-9][0-9]*'", "r'accepted(?:[1-9][0-9]*)?|candidate[1-9][0-9]*'", 1)
    assert text.count("stem == 'accepted'") == 2
    text = text.replace("stem == 'accepted'", "stem.startswith('accepted')")
    text = text.replace("'docs/checkpoints/type-array-pipelines/probe.pl'", "c.PREFIX + 'probe.pl'", 1)
    text = text.replace("    assert stable and len(loaded) == len(c.SOURCES) + 1", "    assert stable, 'supplied input changed'\n    assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), 'observer transport failed; retained raw channels'\n    assert len(loaded) == len(c.SOURCES) + 1, 'loaded source identity check incomplete'", 1)
    compile(text, path, 'exec')
    after[path] = text
    original = c.decode(old_observer['base64'])
    needle = b'print JSON::PP->new->canonical->allow_nonref->encode'
    assert original.count(needle) == 1
    corrected = original.replace(needle, b'print JSON::PP->new->utf8->canonical->allow_nonref->encode', 1)
    # Record the owned issue before changing the observer; production sources stay exact.
    (c.ROOT / names[0]).write_text(after[names[0]])
    with (c.ROOT / c.PREFIX / 'probe.pl').open('xb') as output:
        output.write(corrected)
    (c.ROOT / c.PREFIX / 'probe.pl').chmod(old_observer['mode'])
    for path in names[1:]:
        (c.ROOT / path).write_text(after[path])
    assert c.read(old_observer_path) == old_observer
    c.write_new('observer-correction.json.gz', dict(producer=c.read(c.PREFIX + 'correct_observer.py'),
        before=before, after={path: c.read(path) for path in names},
        old_observer=old_observer, corrected_observer=c.read(c.PREFIX + 'probe.pl'),
        scope='Actual first observer warning and full source epoch remain frozen. Only the new observer UTF-8 output and precise transport assertion diagnostics change; old producer, runtime, fixed116 plan and typed-value oracle stay unchanged.'))
    print('Actual UTF-8 observer warning owned; original source/channels frozen; new transport and accepted2 selected without changing runtime')


if __name__ == '__main__':
    main()

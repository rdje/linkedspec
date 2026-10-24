"""One-shot publication, then read-only verification of all retained inputs."""
import json
import sys
import common as c

MANIFEST = c.PREFIX + 'publication-inputs.json.gz'
PUBLICATION = c.PREFIX + 'publication.json'
CLAIM = 'docs/claims/' + c.OWNER + '.json'


def input_paths():
    import metadata_review
    owned = {path.relative_to(c.ROOT).as_posix()
        for path in (c.ROOT / c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(metadata_review.PRODUCERS)) - {MANIFEST, PUBLICATION, CLAIM})


def validate_inputs(declared, actual):
    assert set(declared) == set(actual), 'input population'
    for path, item in actual.items():
        assert declared[path]['sha256'] == item['sha256'], 'input bytes: ' + path
        assert declared[path]['mode'] == item['mode'], 'input mode: ' + path


def controls():
    value = c.load('artifact2-inputs.json.gz')
    result = {}
    for name, declared in value['cases'].items():
        try:
            validate_inputs(declared, value['actual'])
        except AssertionError as error:
            result[name] = dict(rejected=True, reason=str(error))
        else:
            result[name] = dict(rejected=False, reason='')
    return result


def record(result):
    bindings = [dict(path=path, sha256=c.identity(path)['sha256'],
        role='producer' if path.endswith(('.py', '.pl', '.sh')) else 'input')
        for path in input_paths()]
    bindings.append(dict(path=MANIFEST, sha256=c.identity(MANIFEST)['sha256'], role='input'))
    metadata = result['metadata']
    claim = dict(name='dated-artifact-retention-review',
        statement=f"At {metadata['at_utc']}, the review retained {metadata['parent_files']} parent candidates/{metadata['parent_bytes']} bytes and checked six explicit Rust locations; zero artifact removals.",
        scope=metadata['scope'] + ' Independent complete declared populations and per-file metadata; retained Dart/Julia/Lua conventions. This is a dated observation, not a current-state or disposal admission.',
        rederive=dict(status='checked',
            command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'review.py',
            granularity='Every retained parent and Rust candidate row, suffix aggregate and declared population; both actual census channels and independent scandir/lstat observations.',
            result=json.dumps(result, sort_keys=True)),
        falsify=dict(status='checked',
            hypothesis='Aggregate agreement can conceal wrong sizes, omitted candidates, failed channels, altered producers or incomplete evidence bindings.',
            oracle='Independent OS scandir population and per-file lstat; exact actual command channels and source identities; complete supplied book inputs and rendered maintenance marker.',
            red_control='Five actual reason-sensitive corrupted metadata commands reject; healthy/restored pass. Missing book example yields actual rendered-marker RED. Three missing/byte/mode declarations reject, admit only with the actual publication-validator bypass, then reject after exact restoration.'),
        durability=dict(status='checked', mode='live', inputs=bindings))
    return dict(version=1, owner=c.OWNER, claims=[claim])


def main():
    if sys.argv[1:] == ['--controls']:
        print(json.dumps(controls(), sort_keys=True))
        return
    assert sys.argv[1:] in ([], ['--capture'])
    capture = sys.argv[1:] == ['--capture']
    inputs = {path: c.identity(path) for path in input_paths()}
    if capture:
        assert not (c.ROOT / CLAIM).exists()
        c.write_new('publication-inputs.json.gz', dict(base=c.BASE, inputs=inputs,
            scope='Complete bounded producers, wrappers and retained metadata/book/control packets. Historical inputs stay immutable; future mutable continuity is not gratuitously bound.'))
    validate_inputs(c.load('publication-inputs.json.gz')['inputs'], inputs)
    import review
    result = review.check()
    validate_inputs(inputs, {path: c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result), separators=(',', ':')) + '\n').encode()
    publication = dict(result=result, record_base64=c.encode(raw))
    if capture:
        c.write_new('publication.json', publication)
        with (c.ROOT / CLAIM).open('xb') as output:
            output.write(raw)
    else:
        assert c.source(CLAIM).read_bytes() == raw
        assert c.load('publication.json') == publication
    print('Maintenance22 publication PASS; retained dated metadata, actual controls and exact inputs; zero artifact removals.')


if __name__ == '__main__':
    main()

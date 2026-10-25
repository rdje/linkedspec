"""Execute corrected key probes using the retained actual pre-repair CLI."""
import gzip
import json
import common as c


def main():
    binary=c.load('before-cli-binary.json')['artifact']
    compressed=b''.join(c.source(part['path']).read_bytes() for part in binary['parts'])
    raw=gzip.decompress(compressed)
    assert len(raw)==binary['bytes'] and c.sha(raw)==binary['sha256']
    path='.linkedspec-data/verification/numeric55-historical-cli'
    with (c.ROOT/path).open('xb') as output:
        output.write(raw)
    (c.ROOT/path).chmod(binary['mode'])
    fixture=json.loads(c.source('tests/numeric-conversion/programs.json').read_text())
    cases=[row for row in fixture['cases'] if row['id'].startswith('text-consumer/')]
    assert len(cases)==4
    c.save('historical-key-inputs.json.gz',dict(
        producer=c.read(c.PREFIX+'historical_keys.py'),helper=c.read(c.PREFIX+'common.py'),
        fixture=c.read('tests/numeric-conversion/programs.json'),cases=cases,
        binary=binary,original_source_epoch=c.load('before-cli-inputs.json.gz'),
        scope='Actual archived pre-repair CLI bytes, freshly restored to an owned '
            'same-volume executable path. No fresh old-source build or current-source '
            'epoch is claimed; original whole build inputs and actual original build '
            'are retained separately. Corrected documented hash constructor probes '
            'replace the invalid numeric harray bracket instruments.'))
    runs=[]
    for row in cases:
        channels={level:c.run([str(c.ROOT/path),'--inline-spec',row['source'],
            '--input',row['input'],'--trace',level]) for level in ('none','low')}
        assert all(run['returncode']==0 for run in channels.values())
        actual=json.loads(c.decode(channels['none']['stdout_base64']))
        expected=row['expected']['ok']['exact']
        assert actual!=expected
        runs.append(dict(id=row['id'],actual=actual,expected=expected,channels=channels))
    stable=c.identity(path)=={key:binary[key] for key in ('sha256','mode')}
    c.save('historical-key-runs.json.gz',dict(runs=runs,executable_unchanged=stable))
    assert stable
    print('Four corrected helper/key probes observe actual pre-repair CLI mismatches; eight full channels retained.')


if __name__ == '__main__':
    main()

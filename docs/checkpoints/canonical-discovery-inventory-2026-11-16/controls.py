"""Exercise selector omissions through actual Bash, with an independent oracle."""
import gzip
import importlib.util
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent


def load(name):
    spec = importlib.util.spec_from_file_location('discovery_' + name, BASE / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    assert not (BASE / 'controls.json').exists(), 'one-shot controls'
    reader = load('review')
    capture = load('capture')
    report, sources, _ = reader.read_evidence()
    source = sources['tools/run_ci_local.sh'].decode()
    expected = reader.expected_events(source)
    lines = source.splitlines(keepends=True)
    prove = next(line for line in lines if line.startswith('PERL5LIB= prove '))
    syntax = next(line for line in lines if line.startswith('perl -c ') and 't/' in line)
    suite_start = source.index('private_factory_suites=(\n') + len('private_factory_suites=(\n')
    suite = source[suite_start:source.index('\n', suite_start) + 1]
    helper_start = source.index('private_factory_helpers=(\n') + len('private_factory_helpers=(\n')
    helper = source[helper_start:source.index('\n', helper_start) + 1]
    variants = [
        ('disabled-prove', source.replace(prove, 'true\n', 1)),
        ('duplicate-prove', source.replace(prove, prove + prove, 1)),
        ('disabled-syntax', source.replace(syntax, 'true\n', 1)),
        ('missing-private-suite', source[:suite_start] + source[suite_start:].replace(suite, '', 1)),
        ('missing-private-helper', source[:helper_start] + source[helper_start:].replace(helper, '', 1)),
    ]
    rejected = []
    folder = BASE / 'controls'
    folder.mkdir()
    for name, changed in variants:
        assert changed != source
        (folder / (name + '-source.sh.gz')).write_bytes(gzip.compress(changed.encode(), mtime=0))
        script, _ = capture.selector_script(changed)
        path = folder / (name + '.sh')
        path.write_text(script)
        wire = capture.native('controls/' + name, ['bash', '--noprofile', '--norc', str(path)])
        actual = reader.events(wire)
        try:
            assert actual == expected, 'actual selector population/order differs'
        except AssertionError as error:
            assert str(error) == 'actual selector population/order differs'
            rejected.append(dict(name=name, oracle='RED', reason=str(error), shell_exit=0))
        else:
            raise AssertionError('ineffective selector control:' + name)
    (BASE / 'controls.json').write_text(json.dumps(dict(rejected=rejected,
        scope='Actual mutated selector Bash executions use stubs; independent healthy-source oracle rejects. No SDK or full canonical run.'), indent=2) + '\n')
    print(json.dumps(dict(result='PASS', rejected=[row['name'] for row in rejected]), sort_keys=True))


if __name__ == '__main__':
    main()

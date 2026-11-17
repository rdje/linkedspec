"""Record a separate positive locator control and readonly qualified review."""
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def run(label, argv):
    stem = BASE / 'commands' / label
    with stem.with_suffix('.json').open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / 'commands' / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (BASE / 'commands' / (label + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and not result.stderr, result.stderr.decode()
    return result.stdout


def main():
    assert not (BASE / 'completion-inputs.tar.gz').exists(), 'one-shot qualified recording'
    identities = {}
    with tarfile.open(BASE / 'completion-inputs.tar.gz', 'x:gz') as archive:
        for leaf in ('complete_review.py', 'review_epoch_qualified.py', 'reader-epoch.json', 'used_review_expanded.py', 'repair_reader_epoch.py'):
            path = BASE / leaf
            data = path.read_bytes()
            identities[str(path)] = dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=str(path), recursive=False)
    (BASE / 'completion-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    plan = json.loads((BASE / 'plan.json').read_bytes())
    stdout = run('positive', ['git', 'grep', '-l', '-z', '-F', 'array_concat_open_arity_result_guard_composition_test.lua',
        plan['activation'], '--', *plan['roots']])
    assert (plan['activation'] + ':lua/test/run.lua').encode() in stdout.split(b'\0')
    output = run('qualified', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_epoch_qualified.py'), '--current'])
    print(output.decode(), end='')


if __name__ == '__main__':
    main()

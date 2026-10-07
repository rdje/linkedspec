"""Render corrected compiler grouped-pattern teaching with canonical acceptance open."""
from pathlib import Path
import argparse
import base64
import copy
import gzip
import hashlib
import html
import io
import json
import re
import shutil
import stat
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('book.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
EXAMPLES = [
    'Top:: I { return("set(counter, 2)") }\n# result: "set(counter, 2)"',
    'Top:: I { return(cat("set(counter, 2)","; if(true); return(inner)")) }\n# result: "set(counter, 2); if(true); return(inner)"',
    'Top:: I { return(matches("if(true)", /if\\(true\\)/)) }\n# result: 1',
    'Top:: I { cb={|x,y| return(x) }; return(cb("ok","unused")) }\n# result: "ok"',
    'Top:: I { cb={|x,y| return(matches("setcounter,1,x", /(set(counter,1)).*x/)) }; return(cb("ok","unused")) }\n# result: 1',
]


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete channel identity'
    return raw


def population():
    return sorted(p for p in subprocess.check_output(
        ['git', 'ls-files', '-z', '--', 'docs/linkedspec-book'], cwd=ROOT).decode().split('\0')
        if p and not p.startswith('docs/linkedspec-book/book/'))


def read_inputs(manifest):
    capsule = Path(PREFIX + 'book-inputs.tar.gz').read_bytes()
    assert sha(capsule) == manifest['capsule_sha256'], 'capsule identity'
    files = {}
    with tarfile.open(fileobj=io.BytesIO(capsule), mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and member.name not in files, 'regular unique publication member'
            files[member.name] = (archive.extractfile(member).read(), member.mode)
    assert sorted(files) == population() == [e['path'] for e in manifest['entries']], 'complete publication inputs'
    for entry in manifest['entries']:
        raw, mode = files[entry['path']]
        assert (len(raw), sha(raw), mode) == (entry['bytes'], entry['sha256'], entry['mode']), 'publication member identity'
        assert raw == (ROOT / entry['path']).read_bytes(), 'current publication bytes'
    return files


def check(report, manifest):
    assert report['complete'] is True and report['exit'] == 0, 'actual render completion'
    assert report['capsule_sha256'] == manifest['capsule_sha256'], 'actual capsule'
    assert report['instrument_sha256'] == sha(Path(__file__).read_bytes()), 'actual instrument'
    assert report['inputs_before'] == report['inputs_after'] == len(manifest['entries']), 'publication input guards'
    assert report['command'] == ['bash', 'tools/project_data_run.sh', 'mdbook', 'build', report['input_tree'] + '/docs/linkedspec-book'], 'actual render command'
    decode(report['stdout']); decode(report['stderr'])
    rendered = decode(report['html']).decode()
    blocks = [html.unescape(re.sub(r'<[^>]*>', '', b)).rstrip('\n')
              for b in re.findall(r'<code class="language-spec">(.*?)</code>', rendered, re.S)]
    assert all(e in blocks for e in EXAMPLES), 'original runtime examples'
    plain = re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))).replace('’', "'")
    for needle in ('EmitContext callback now uses this selector', 'ordinary scanner API still returns all syntactic',
                   'original event and argument objects', 'compiler-marker diagnostic origin',
                   "another backend's behavior", 't/actionir_compiler_source_membership.t',
                   "action splitter's existing newline boundary", 'does not admit host quotes as portable',
                   'Independent corrected committed recurrence verifies the bounded membership fixtures and callable signatures',
                   'Callable signature delimiters now retain their existing lexical ownership',
                   'Compiler membership acceptance remains open',
                   'Grouped helper patterns inside callable bodies therefore retain their data interiors',
                   'helper/canonical metadata event lists',
                   'ordinary scanner and default operand query retain their existing policy',
                   'statement-splitter signature repair still holds'):
        assert needle in plain, 'repair teaching: ' + needle


def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--review', action='store_true')
    args = parser.parse_args()
    if not args.review:
        entries, output = [], io.BytesIO()
        with gzip.GzipFile(fileobj=output, mode='wb', filename='', mtime=0) as compressed:
            with tarfile.open(fileobj=compressed, mode='w|', format=tarfile.USTAR_FORMAT) as archive:
                for path in population():
                    source = ROOT / path
                    assert source.is_file() and not source.is_symlink(), 'regular book input'
                    raw = source.read_bytes(); mode = stat.S_IMODE(source.stat().st_mode)
                    member = tarfile.TarInfo(path); member.size = len(raw); member.mode = mode
                    archive.addfile(member, io.BytesIO(raw))
                    entries.append({'path': path, 'bytes': len(raw), 'sha256': sha(raw), 'mode': mode})
        capsule = output.getvalue(); Path(PREFIX + 'book-inputs.tar.gz').write_bytes(capsule)
        manifest = {'capsule_sha256': sha(capsule), 'entries': entries}
        Path(PREFIX + 'book-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
        files = read_inputs(manifest)
        scratch = ROOT / '.linkedspec-data/scratch/compiler-source-membership'; scratch.mkdir(parents=True, exist_ok=True)
        tree = Path(tempfile.mkdtemp(prefix='book-', dir=scratch)); assert tree.stat().st_dev == ROOT.stat().st_dev
        for path, (raw, mode) in files.items():
            target = tree / path; target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(mode)
        relative = tree.relative_to(ROOT).as_posix()
        command = ['bash', 'tools/project_data_run.sh', 'mdbook', 'build', relative + '/docs/linkedspec-book']
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        report = {'command': command, 'input_tree': relative, 'exit': result.returncode,
                  'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
                  'capsule_sha256': manifest['capsule_sha256'], 'complete': False,
                  'inputs_before': len(files), 'instrument_sha256': sha(Path(__file__).read_bytes()),
                  'mdbook_sha256': sha(Path(shutil.which('mdbook')).resolve().read_bytes())}
        Path(PREFIX + 'book.json').write_text(json.dumps(report, indent=2) + '\n')
        assert result.returncode == 0, 'successful actual render'
        actual = {p.relative_to(tree).as_posix() for p in tree.rglob('*') if p.is_file()
                  and not p.relative_to(tree).as_posix().startswith('docs/linkedspec-book/book/')}
        assert actual == set(files), 'unchanged input population'
        for path, (raw, mode) in files.items():
            target = tree / path
            assert target.read_bytes() == raw and stat.S_IMODE(target.stat().st_mode) == mode, 'unchanged input bytes/modes'
        report.update(inputs_after=len(files), html=envelope(
            (tree / 'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html').read_bytes()), complete=True)
        Path(PREFIX + 'book.json').write_text(json.dumps(report, indent=2) + '\n')
    manifest = json.loads(Path(PREFIX + 'book-inputs.json').read_bytes()); read_inputs(manifest)
    report = json.loads(Path(PREFIX + 'book.json').read_bytes()); check(report, manifest)
    controls = []
    for name, mutate in [
        ('failed render', lambda r: r.update(exit=1)),
        ('lost input guard', lambda r: r.update(inputs_after=0)),
        ('forged channel', lambda r: r['html'].update(sha256='0' * 64)),
        ('lost exact examples', lambda r: r.update(html=envelope(b'<html>no examples</html>'))),
        ('hidden diagnostic owner', lambda r: r.update(html=envelope(decode(r['html']).replace(
            b'compiler-marker diagnostic origin', b'owner removed')))),
        ('hidden signature correction', lambda r: r.update(html=envelope(decode(r['html']).replace(
            b'Callable signature delimiters now retain', b'signature correction removed')))),
        ('hidden membership boundary', lambda r: r.update(html=envelope(decode(r['html']).replace(
            b'Compiler membership acceptance', b'membership boundary removed')))),
        ('hidden grouped-pattern correction', lambda r: r.update(html=envelope(decode(r['html']).replace(
            b'Grouped helper patterns inside callable bodies', b'correction removed')))),
        ('lost grouped runtime example', lambda r: r.update(html=envelope(decode(r['html']).replace(
            b'setcounter,1,x', b'changed subject', 1)))),
    ]:
        candidate = copy.deepcopy(report); mutate(candidate); assert candidate != report, 'effective control'
        try:
            check(candidate, manifest)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected render control: ' + name)
    summary = {'book_inputs': len(manifest['entries']), 'exact_examples': len(EXAMPLES),
               'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'book-verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))


if __name__ == '__main__':
    main()

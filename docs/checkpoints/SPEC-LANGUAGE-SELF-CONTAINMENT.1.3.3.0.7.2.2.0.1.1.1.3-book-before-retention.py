"""Freeze, render and independently check complete publication inputs."""
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
CHAPTER = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
EXAMPLES = ['text="my $x"; my $x; my $x;', 'my #inside\n $x;', 'return (7 #inside\n);', "my $result = LinkedSpec::ActionIR::StatementSplit::Core::_split_with_source_frames(\n    $default_split, 'my $x; my $x;'\n);\n# source_frames spans: [0, 5), [7, 12)", "my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => 'my_declare_bare'}, 'my $x; my $x;', $scanner_deps\n);\n# source_origins spans: [0, 5), [7, 12)"]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'book channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'],validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'book channel bytes'
    return raw


def population():
    rows = subprocess.check_output(['git','ls-files','-z','--','docs/linkedspec-book'],cwd=ROOT).decode().split('\0')
    return sorted(p for p in rows if p and not p.startswith('docs/linkedspec-book/book/'))


def read_inputs(manifest):
    raw = Path(PREFIX+'book-inputs.tar.gz').read_bytes()
    assert sha(raw) == manifest['capsule_sha256'], 'book capsule identity'
    files = {}
    with tarfile.open(fileobj=io.BytesIO(raw),mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and member.name not in files, 'regular unique book member'
            files[member.name] = (archive.extractfile(member).read(),member.mode)
    assert sorted(files) == population() == [e['path'] for e in manifest['entries']], 'complete book membership'
    for entry in manifest['entries']:
        raw, mode = files[entry['path']]
        assert len(raw) == entry['bytes'] and sha(raw) == entry['sha256'] and mode == entry['mode'], 'book member identity'
        assert raw == (ROOT/entry['path']).read_bytes(), 'current publication bytes'
    return files


def check_report(report,manifest):
    assert report['complete'] is True and report['exit'] == 0, 'complete actual render'
    assert report['instrument_sha256'] == sha(Path(__file__).read_bytes()), 'actual book instrument'
    assert report['capsule_sha256'] == manifest['capsule_sha256'], 'actual render capsule'
    assert report['inputs_before'] == report['inputs_after'] == len(manifest['entries']), 'book input guards'
    assert report['command'] == ['bash','tools/project_data_run.sh','mdbook','build',report['input_tree']+'/docs/linkedspec-book'], 'actual book command'
    decode(report['stdout']);decode(report['stderr'])
    rendered = decode(report['html']).decode()
    blocks = [html.unescape(re.sub(r'<[^>]*>','',block)).rstrip('\n') for block in re.findall(r'<code class="language-perl">(.*?)</code>',rendered,re.S)]
    assert all(example in blocks for example in EXAMPLES), 'original authored rendered examples'
    assert 'All eleven basic statement event producers now connect' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'actual documented diagnosis boundary'


def main():
    args = argparse.ArgumentParser();args.add_argument('--review',action='store_true');args = args.parse_args()
    if not args.review:
        entries, output = [], io.BytesIO()
        with gzip.GzipFile(fileobj=output,mode='wb',filename='',mtime=0) as compressed:
            with tarfile.open(fileobj=compressed,mode='w|',format=tarfile.USTAR_FORMAT) as archive:
                for path in population():
                    source = ROOT/path
                    assert source.is_file() and not source.is_symlink(), 'regular book input'
                    raw = source.read_bytes();mode = stat.S_IMODE(source.stat().st_mode)
                    member = tarfile.TarInfo(path);member.size=len(raw);member.mode=mode
                    archive.addfile(member,io.BytesIO(raw))
                    entries.append({'path':path,'bytes':len(raw),'sha256':sha(raw),'mode':mode})
        capsule = output.getvalue();Path(PREFIX+'book-inputs.tar.gz').write_bytes(capsule)
        manifest = {'capsule_sha256':sha(capsule),'entries':entries,'boundary':'Complete final working book publication, separate from immutable Git ab2c statement-family recurrence.'}
        Path(PREFIX+'book-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
        files = read_inputs(manifest)
        scratch = ROOT/'.linkedspec-data/scratch/basic-statement-provenance';scratch.mkdir(parents=True,exist_ok=True)
        tree = Path(tempfile.mkdtemp(prefix='book-',dir=scratch));assert tree.stat().st_dev == ROOT.stat().st_dev
        for path,(raw,mode) in files.items():
            target=tree/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw);target.chmod(mode)
        relative = tree.relative_to(ROOT).as_posix()
        command = ['bash','tools/project_data_run.sh','mdbook','build',relative+'/docs/linkedspec-book']
        result = subprocess.run(command,cwd=ROOT,capture_output=True)
        report = {'command':command,'input_tree':relative,'exit':result.returncode,'stdout':envelope(result.stdout),'stderr':envelope(result.stderr),
                  'capsule_sha256':manifest['capsule_sha256'],'complete':False,'inputs_before':len(files),
                  'instrument_sha256':sha(Path(__file__).read_bytes()),'mdbook_sha256':sha(Path(shutil.which('mdbook')).resolve().read_bytes())}
        Path(PREFIX+'book.json').write_text(json.dumps(report,indent=2)+'\n')
        assert result.returncode == 0, 'actual successful book render'
        actual = {p.relative_to(tree).as_posix() for p in tree.rglob('*') if p.is_file() and not p.relative_to(tree).as_posix().startswith('docs/linkedspec-book/book/')}
        assert actual == set(files), 'render input population'
        for path,(raw,mode) in files.items():
            target=tree/path
            assert target.read_bytes() == raw and stat.S_IMODE(target.stat().st_mode) == mode, 'render input bytes/modes'
        report.update(inputs_after=len(files),html=envelope((tree/'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html').read_bytes()),complete=True)
        Path(PREFIX+'book.json').write_text(json.dumps(report,indent=2)+'\n')
    manifest=json.loads(Path(PREFIX+'book-inputs.json').read_bytes());read_inputs(manifest)
    report=json.loads(Path(PREFIX+'book.json').read_bytes());check_report(report,manifest)
    controls=[]
    for name,change,reason in [('promote failed render',lambda d:d.update(exit=1),'complete actual render'),
                               ('erase render guard',lambda d:d.update(inputs_after=0),'book input guards'),
                               ('forge renderer',lambda d:d.update(instrument_sha256='0'*64),'actual book instrument'),
                               ('forge rendered channel',lambda d:d['html'].update(sha256='0'*64),'book channel bytes'),
                               ('erase actual examples',lambda d:d.update(html=envelope(b'<html>examples absent</html>')),'original authored rendered examples')]:
        candidate=copy.deepcopy(report);change(candidate)
        try: check_report(candidate,manifest)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'rejected':True,'reason':reason})
        else: raise AssertionError('accepted corruption: '+name)
    summary={'book_inputs':len(manifest['entries']),'rendered_examples':len(EXAMPLES),'controls':controls,'complete':True,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'book-verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(str(summary['book_inputs'])+' complete book inputs; five original rendered examples; five RED controls')


if __name__ == '__main__':
    main()

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
EXAMPLES.append("split(items, input, ',')\n# planner split op: source_expr => '$input'\n# current scanner event: source => '$input'\n# lowering still reads $input")
EXAMPLES.append("my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => 'push'}, \"push(items, '雪'); push(items, '雪');\", $scanner_deps\n);\n# source_origins spans: [0, 16), [18, 34)")
EXAMPLES.append('split(items, \' 雪,β \', \',\')\n# args.source => "\' 雪,β \'"\nsplit(items, cat(\'雪\', \',β\'), \',\')\n# args.source => "cat(\'雪\', \',β\')"')
EXAMPLES.extend(["my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => 'scalar_assignment_operator'}, 'value = 7; value = 7;', $scanner_deps\n);\n# source_origins spans: [0, 9), [11, 20)", 'my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => \'hash_index_assignment_operator\'}, "tree[\'key\'] = \'雪\'; tree[\'key\'][0] = \'雪\';", $scanner_deps\n);\n# source_origins spans: [0, 17), [19, 39)'])

EXAMPLES.extend(['otherwise { next }  -> else_flow raw: otherwise { next }, args: {}\nendif              -> endif_flow raw: endif, args: {}\nwhile(false) { next() } -> while_flow args.condition: false', 'switch(kind, case("inline", case("nested")), default(default())); case("tail")\n# case_flow event order:\n# case("tail"), case("inline", case("nested")), case("nested")'])
EXAMPLES.extend(["my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => 'elseif_flow'}, 'elseif(true); elseif(true)', $scanner_deps\n);\n# source_origins spans: [0, 12), [14, 26)", "my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => 'else_flow'}, 'otherwise', $scanner_deps\n);\n# event raw: otherwise; source_origins span: [0, 9)", "my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => 'next_stmt'}, 'note(); next; next()', $scanner_deps\n);\n# source_origins spans: [8, 12), [14, 20)"])

EXAMPLES.extend([' call( same, ,same )\n# source: call( same, ,same )\n# args: [same, same]\n# authored scalar argument intervals in the original input: [7, 11), [13, 17)', 'matches("x,雪", /(x),雪/imu)\n# args: ["x,雪", /(x),雪/imu]\nfilter_match(/(x),雪/imu)  # receiver parser context\n# args: [/(x),雪/imu]'])

EXAMPLES.append("my $result = LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames(\n    $default_parse, ' call( same, ,same )'\n);\n# call.args: [same, same]\n# source_frames spans: [7, 11), [13, 17)")

EXAMPLES.append('my $result = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(\n    {id => \'case_flow\'}, \'case("outer") { case("inner") }\', $scanner_deps\n);\n# event order: outer, inner\n# source_origins spans: [0, 31), [16, 29)\n# both source fields contain the complete original action')

EXAMPLES.extend(['call(Done); call(Done)\n# original scalar intervals: [0, 10), [12, 22)', 'recognize_once(scope, call(Hidden)); call(Done)\n# the selected original occurrence is call(Done)', 'push(items, true); push(items, target)\n# the target-push contract selects only push(items, target)'])

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
    blocks = [html.unescape(re.sub(r'<[^>]*>','',block)).rstrip('\n') for block in re.findall(r'<code class="language-(?:perl|text)">(.*?)</code>',rendered,re.S)]
    assert all(example in blocks for example in EXAMPLES), 'original authored rendered examples'
    assert 'mixed twenty-contract proof now uses one shared action input' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))), 'rendered twenty-contract composition teaching'
    assert 'A fresh immutable Git recurrence repeats all twenty contracts' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))), 'rendered immutable family closeout teaching'
    assert 'All eleven full-input regex pipeline contracts now retain private source origins' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))), 'rendered pipeline regex source teaching'
    assert 'The split scanner now reports the normalized source expression' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))), 'rendered corrected source metadata teaching'
    assert 'A fresh immutable Git recurrence now repeats all nineteen pipeline contracts' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))), 'rendered pipeline family acceptance teaching'
    assert 'Legacy scanner source work is partitioned by producer mechanism' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered Legacy safe partition teaching'
    assert 'The call/return/push family now retains its selected original scalar occurrences' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered Legacy call source teaching'
    developer = decode(report['development_html']).decode()
    assert 'A logical compile filename supplies coordinates; it does not bind the source text' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', developer))), 'rendered diagnostic source teaching'
    assert 'All eight statement contracts now carry original occurrence frames' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', rendered))), 'rendered pipeline statement source teaching'
    assert 'Equal JSON values do not establish reference identity' in re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>', ' ', developer))), 'rendered returned reference identity teaching'
    assert 'Case/default first scan marker matches' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered Flow composite traversal teaching'
    assert 'recursive case/default producers now translate their original block and parsed argument frames' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered recursive Flow origin teaching'
    assert 'A fresh immutable family recurrence repeats all sixteen Flow contracts' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered Flow family acceptance teaching'
    assert 'All fourteen direct Flow contracts now retain original occurrence' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered direct Flow source teaching'
    assert 'publishes an aligned argument-frame sidecar without changing the ordinary result' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',rendered))), 'rendered implemented argument authority boundary'
    regression=decode(report['regression_html']).decode()
    assert 'classifies the two retained pipeline diagnosis artifacts by exact repository-relative path and full SHA-256 identity' in re.sub(r'\s+',' ',html.unescape(re.sub(r'<[^>]*>',' ',regression))), 'rendered historical input classification teaching'
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
        manifest = {'capsule_sha256':sha(capsule),'entries':entries,'boundary':'Complete final Legacy call-source publication; separate from immutable before/after runtime inputs at0083dc7af44fe64f329339da6b764d0806cf1717.'}
        Path(PREFIX+'book-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
        files = read_inputs(manifest)
        scratch = ROOT/'.linkedspec-data/scratch/legacy-call-source';scratch.mkdir(parents=True,exist_ok=True)
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
        report.update(inputs_after=len(files),html=envelope((tree/'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html').read_bytes()),development_html=envelope((tree/'docs/linkedspec-book/book/development/documentation-workflow.html').read_bytes()),regression_html=envelope((tree/'docs/linkedspec-book/book/development/regression-fixtures.html').read_bytes()),complete=True)
        Path(PREFIX+'book.json').write_text(json.dumps(report,indent=2)+'\n')
    manifest=json.loads(Path(PREFIX+'book-inputs.json').read_bytes());read_inputs(manifest)
    report=json.loads(Path(PREFIX+'book.json').read_bytes());check_report(report,manifest)
    controls=[]
    for name,change,reason in [('erase Legacy call hooks',lambda d:d.update(html=envelope(decode(d['html']).replace(b'The call/return/push family now retains',b'Legacy call hooks erased'))),'rendered Legacy call source teaching'),('erase Legacy partition',lambda d:d.update(html=envelope(decode(d['html']).replace(b'Legacy scanner source work is partitioned by producer mechanism',b'Legacy partition erased'))),'rendered Legacy safe partition teaching'),('erase Flow acceptance',lambda d:d.update(html=envelope(decode(d['html']).replace(b'A fresh immutable family recurrence repeats all sixteen Flow contracts',b'Flow acceptance erased'))),'rendered Flow family acceptance teaching'),('erase recursive Flow teaching',lambda d:d.update(html=envelope(decode(d['html']).replace(b'recursive case/default producers now translate',b'recursive origin teaching erased'))),'rendered recursive Flow origin teaching'),('erase argument boundary',lambda d:d.update(html=envelope(decode(d['html']).replace(b'publishes an aligned argument-frame sidecar',b'argument boundary erased'))),'rendered implemented argument authority boundary'),('erase direct Flow hooks',lambda d:d.update(html=envelope(decode(d['html']).replace(b'All fourteen direct Flow contracts now retain original occurrence',b'direct Flow teaching absent'))),'rendered direct Flow source teaching'),('erase Flow traversal',lambda d:d.update(html=envelope(decode(d['html']).replace(b'Case/default first scan marker matches',b'Flow teaching absent'))),'rendered Flow composite traversal teaching'),('promote failed render',lambda d:d.update(exit=1),'complete actual render'),
                               ('erase render guard',lambda d:d.update(inputs_after=0),'book input guards'),
                               ('forge renderer',lambda d:d.update(instrument_sha256='0'*64),'actual book instrument'),
                               ('forge rendered channel',lambda d:d['html'].update(sha256='0'*64),'book channel bytes'),
                               ('erase actual examples',lambda d:d.update(html=envelope(b'<html>examples absent</html>')),'original authored rendered examples'),
                               ('erase composition teaching',lambda d:d.update(html=envelope(decode(d['html']).replace(b'mixed twenty-contract proof now uses one shared action input', b'composition teaching absent'))),'rendered twenty-contract composition teaching'),
                               ('erase family closeout teaching',lambda d:d.update(html=envelope(decode(d['html']).replace(b'A fresh immutable Git recurrence repeats all twenty contracts', b'family closeout teaching absent'))),'rendered immutable family closeout teaching'),
                               ('erase pipeline diagnosis',lambda d:d.update(html=envelope(decode(d['html']).replace(b'contracts now retain private', b'diagnosis absent'))),'rendered pipeline regex source teaching'),
                               ('erase corrected metadata',lambda d:d.update(html=envelope(decode(d['html']).replace(b'The split scanner now reports', b'correction absent'))),'rendered corrected source metadata teaching'),
                               ('erase diagnostic teaching',lambda d:d.update(development_html=envelope(b'<html>teaching absent</html>')),'rendered diagnostic source teaching'),
                               ('erase historical input classification',lambda d:d.update(regression_html=envelope(b'<html>teaching absent</html>')),'rendered historical input classification teaching'),
                               ('erase statement teaching',lambda d:d.update(html=envelope(decode(d['html']).replace(b'All eight statement contracts now carry original', b'statement teaching absent'))),'rendered pipeline statement source teaching'),
                               ('erase returned identity teaching',lambda d:d.update(development_html=envelope(decode(d['development_html']).replace(b'Equal JSON values do not establish reference identity', b'identity teaching absent'))),'rendered returned reference identity teaching'),
                               ('erase pipeline family acceptance',lambda d:d.update(html=envelope(decode(d['html']).replace(b'A fresh immutable Git recurrence now repeats all nineteen pipeline contracts', b'family acceptance absent'))),'rendered pipeline family acceptance teaching')]:
        candidate=copy.deepcopy(report);change(candidate)
        try: check_report(candidate,manifest)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'rejected':True,'reason':reason})
        else: raise AssertionError('accepted corruption: '+name)
    summary={'book_inputs':len(manifest['entries']),'rendered_examples':len(EXAMPLES),'rendered_sections':3,'controls':controls,'complete':True,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'book-verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(str(summary['book_inputs'])+' complete book inputs; '+str(len(EXAMPLES))+' original rendered examples/three chapters; '+str(len(controls))+' RED controls')


if __name__ == '__main__':
    main()

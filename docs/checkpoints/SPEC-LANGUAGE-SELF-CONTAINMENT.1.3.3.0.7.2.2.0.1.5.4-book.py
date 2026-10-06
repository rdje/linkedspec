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
EXAMPLES = ['Top::\n I { body = capture_until_boundary("a,b,c", end); return(hash("body", body, "cursor", cursor_pos(), "rest", cursor_rest())) }\nb: /b/\nend: /END/', 'capture_until_boundary("end", \'b\')  # input: xx b END; body: "xx "; cursor: 3\ncapture_until_boundary("", \'\', end) # empty labels omitted; input: xx END; cursor: 3', 'Top::\n I { body = capture_until_boundary("a\\,b", end); return(hash("body", body, "cursor", cursor_pos(), "rest", cursor_rest())) }\nend: /END/']

ANONYMOUS_EXAMPLES = ['$CAPTURE; $CAPTURE\n# original scalar intervals: [0, 8), [10, 18)', 'capture_take(); capture_take()\n# capture_take_slice dispatcher; scalar intervals: [0, 14), [16, 30)']

NAMED_EXAMPLES = ['capture_from(edge); capture_from(edge)\n# mark: edge; scalar intervals: [0, 18), [20, 38)', 'capture_between(first, second); capture_between(first, second)\n# start: first; end: second; scalar intervals: [0, 30), [32, 62)']

MARK_EXAMPLES = ['mark_here(edge); mark_here(edge)\n# mark: edge; scalar intervals: [0, 15), [17, 32)', 'mark_copy(first, second); mark_copy(first, second)\n# target: first; source: second; scalar intervals: [0, 24), [26, 50)']

CURSOR_EXAMPLES = ['cursor_pos(); cursor_pos()\n# original scalar intervals: [0, 12), [14, 26)', 'input_slice(1, nested("a,b")); input_slice(1, nested("a,b"))\n# empty scanner args; scalar intervals: [0, 29), [31, 60)']

ENTRY_EXAMPLES = ['entry_group(2); entry_group(2)\n# index argument: "2"; scalar intervals: [0, 14), [16, 30)', 'match_named(part); match_named(part)\n# name argument: part; scalar intervals: [0, 17), [19, 36)', 'entry_start_line(); entry_line()\n# distinct spellings; scalar intervals: [0, 18), [20, 32)']

HISTORY_EXAMPLES = ['perl tools/roll_document_history.pl --surface change_history --check\nperl tools/roll_document_history.pl --surface engineering_notes --check', "bash tools/project_data_run.sh python3 - <<'HISTORY_SOURCE'\nfrom pathlib import Path\nimport json, subprocess\nrows = Path('docs/history/changes/manifest.jsonl').read_text().splitlines()\nrow = json.loads(rows[1])\nsource = subprocess.check_output(['git', 'show', row['source_commit'] + ':' + row['source_path']])\narchive = Path(row['target_path']).read_bytes()\nassert source.endswith(archive)\noriginal_prefix = source[:-len(archive)]\nassert original_prefix + archive == source\nprint(row['source_commit'])\nHISTORY_SOURCE"]
HISTORY_EXAMPLES.append('bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py')

FAMILY_EXAMPLE = 'bash tools/project_data_run.sh prove -v -Iperl \\\n  t/actionir_helper_source_provenance.t t/generated_source_contract.t'

DEDICATED_EXAMPLES = ['job = parse_job(entry_text(), hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","replace_marker","on_error","fail"))', 'child = dispatch_span("expr-v1", "Expr", span)\nchild = dispatch_span(parser, "Expr", span)  # rejected: parser identity must be literal', 'scope = recognition_checkpoint()\nmatched = recognize_once(scope, call(Done))\npayload = recognition_commit(scope)\n# Alternative terminal: recognition_rollback(scope)']
DEDICATED_COMMAND = 'bash tools/project_data_run.sh prove -v -Iperl \\\n  t/staged_ast_enrichment_perl_contract.t \\\n  t/progressive_span_dispatch_perl_contract.t \\\n  t/recognition_transaction_perl_contract.t \\\n  t/recursive_observation_perl_contract.t'

STAGED_EXAMPLES = ['job = parse_job(cat(entry_group(1), cat(match_text(), entry_text())), hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","append_child","on_error","keep_text","top","Expr","into","children","required_capabilities",array("z.cap","a.cap")))', 'job = parse_job(entry_text(), hash("node_kind","expression","payload_kind","text","spec","expr-v1","result_policy","replace_marker","on_error","fail","unknown","value"))']

PROGRESSIVE_EXAMPLES = ['child = dispatch_span("expr-v1", "Expr", span); child = dispatch_span("expr-v1", "Expr", span)\n# original scalar intervals: [0, 46), [48, 94)', 'child = dispatch_span("expr-v1", "Expr", span, other)\n# rejected: dispatch_span requires exactly three operands']

RECOGNITION_EXAMPLES = ['scope = recognition_checkpoint(); scope = recognition_checkpoint()\n# original scalar intervals: [0, 32), [34, 66)', 'value = observe_recognition(observation, call(Done)); value = observe_recognition(observation, call(Done))\n# original scalar intervals: [0, 52), [54, 106)', 'matched = recognize_once(scope, Done)\nvalue = observe_recognition(observation)\nvalue = observe_recognition(observation, call(Done), extra)\n# rejected: static call operand, missing observation operand, extra observation operand']

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
    decode(report['stdout']); decode(report['stderr'])
    rendered = decode(report['html']).decode()
    blocks = [html.unescape(re.sub(r'<[^>]*>','',block)).rstrip('\n') for block in re.findall(r'<code class="language-text">(.*?)</code>',rendered,re.S)]
    assert all(example in blocks for example in EXAMPLES), 'original rendered boundary examples'
    plain = lambda key: re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]*>',' ',decode(report[key]).decode())))
    assert 'a quoted argument is one boundary label even when it contains commas' in plain('html'), 'whole quoted label teaching'
    assert 'It also works inside assignments, returns and hash values' in plain('html'), 'nested unknown-escape teaching'
    assert 'they do not establish the other backends' in plain('html'), 'explicit cross-backend scope'
    assert 'Perl quoted labels' in plain('development_html'), 'public catalog quoted-label contract'
    assert 'every decoded atom agrees with the typed arguments' in plain('regression_html'), 'structural lexical authority teaching'
    assert 'helper-looking literal data can still be rewritten as code' in plain('regression_html'), 'explicit quoted-source repair owner'
    anonymous_blocks=[html.unescape(re.sub(r'<[^>]*>','',block)).rstrip('\n') for block in re.findall(r'<code class="language-text">(.*?)</code>',decode(report['regression_html']).decode(),re.S)]
    assert all(example in anonymous_blocks for example in ANONYMOUS_EXAMPLES), 'original anonymous source examples'
    assert 'Each producer snapshots its regex bounds before constructing arguments or decoding boundary labels' in plain('regression_html'), 'anonymous original producer authority'
    assert all(example in anonymous_blocks for example in NAMED_EXAMPLES), 'original named source examples'
    assert 'Named captures preserve their original symbolic mark arguments and start/end order' in plain('regression_html'), 'named original producer authority'
    assert all(example in anonymous_blocks for example in MARK_EXAMPLES), 'original mark source examples'
    assert 'Mark-control producers preserve target/source order and their original event objects' in plain('regression_html'), 'mark original producer authority'
    assert all(example in anonymous_blocks for example in CURSOR_EXAMPLES), 'original cursor/input source examples'
    assert 'Its scanner arguments remain empty' in plain('regression_html'), 'cursor/input original argument authority'
    assert all(example in anonymous_blocks for example in ENTRY_EXAMPLES), 'original entry/match source examples'
    assert 'Entry/match producers retain their original raw spelling and argument objects' in plain('regression_html'), 'entry/match original producer authority'
    family_blocks=[html.unescape(re.sub(r'<[^>]*>','',block)).rstrip('\n') for block in re.findall(r'<code class="language-sh">(.*?)</code>',decode(report['regression_html']).decode(),re.S)]
    assert FAMILY_EXAMPLE in family_blocks, 'complete-family fixture example'
    assert 'Complete-family validation replays all112 original internal contracts through115 literal cases' in plain('regression_html'), 'complete-family validation scope'
    assert 'a syntactic source origin alone does not authorize rewriting' in plain('regression_html'), 'explicit executable-membership boundary'
    assert all(example in anonymous_blocks for example in DEDICATED_EXAMPLES), 'dedicated annotation examples'
    assert DEDICATED_COMMAND in family_blocks, 'dedicated behavior fixture example'
    assert 'All five recognition/observation scanners now retain their selected private whole-statement origins' in plain('regression_html'), 'recognition current origins'
    assert 'This diagnosis changes no static policy, recognition behavior or public event fields' in plain('regression_html'), 'dedicated policy preservation'
    assert all(example in anonymous_blocks for example in STAGED_EXAMPLES), 'staged preserved text/options examples'
    assert 'The staged producer now retains a private source origin' in plain('regression_html'), 'staged current source origin'
    assert 'Copied splitter arrays, foreign source and changed raw text gain no invented coordinates' in plain('regression_html'), 'staged private coordinate boundary'
    assert 'Nested scans keep independent recorder contexts' in plain('regression_html'), 'staged nested recorder independence'
    assert all(example in anonymous_blocks for example in PROGRESSIVE_EXAMPLES), 'progressive repeated and arity examples'
    assert 'The progressive producer now retains a private source origin' in plain('regression_html'), 'progressive current source origin'
    assert 'Private source provenance does not grant parser authority or relax static policy' in plain('regression_html'), 'progressive authority boundary'
    assert 'progressive coordinates; nested scans restore independent recorder contexts' in plain('regression_html'), 'progressive coordinate and nested boundary'
    assert all(example in anonymous_blocks for example in RECOGNITION_EXAMPLES), 'recognition repeated and malformed examples'
    assert 'same returned event and argument objects' in plain('regression_html'), 'recognition original object authority'
    assert 'Malformed operands and arity retain their original scanner fields for static policy to reject' in plain('regression_html'), 'recognition malformed static boundary'
    assert 'Source origins do not repair token order, restoration, boolean payload kind' in plain('regression_html'), 'recognition runtime defect boundary'
    assert 'Complete dedicated-family validation replays all seven original contracts through 22 literal cases' in plain('regression_html'), 'committed dedicated-family acceptance scope'
    history_blocks=[html.unescape(re.sub(r'<[^>]*>','',block)).rstrip('\n') for block in re.findall(r'<code class="language-sh">(.*?)</code>',decode(report['history_html']).decode(),re.S)]
    assert all(example in history_blocks for example in HISTORY_EXAMPLES), 'original rendered history examples'
    assert 'Rollover removes terminal LF separators' in plain('history_html'), 'hot-root terminal separator teaching'
    assert 'four-character JSON string' in plain('history_html'), 'pending metadata string identity teaching'
    assert '`--all` returns archive bytes only' .replace('`','') in plain('history_html'), 'explicit archive-only query scope'
    assert 'Historical recovery keeps the original hashes' in plain('history_html'), 'historical audit identity preservation'
    assert 'It does not re-execute historical runtime producers' in plain('history_html'), 'historical runtime scope'


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
        manifest = {'capsule_sha256':sha(capsule),'entries':entries,'boundary':'Complete complete dedicated-family acceptance publication; separate from immutable runtime inputs at7dc393211a12d54d5986c8f6a5462c25615ccbc4.'}
        Path(PREFIX+'book-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
        files = read_inputs(manifest)
        scratch = ROOT/'.linkedspec-data/scratch/dedicated-family-acceptance';scratch.mkdir(parents=True,exist_ok=True)
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
        report.update(inputs_after=len(files),html=envelope((tree/'docs/linkedspec-book/book/dsl/source-boundary-helper-reference.html').read_bytes()),development_html=envelope((tree/'docs/linkedspec-book/book/appendix/helper-contract-catalog.html').read_bytes()),regression_html=envelope((tree/'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html').read_bytes()),history_html=envelope((tree/'docs/linkedspec-book/book/development/documentation-workflow.html').read_bytes()),complete=True)
        Path(PREFIX+'book.json').write_text(json.dumps(report,indent=2)+'\n')
    manifest=json.loads(Path(PREFIX+'book-inputs.json').read_bytes());read_inputs(manifest)
    report=json.loads(Path(PREFIX+'book.json').read_bytes());check_report(report,manifest)
    controls=[]
    for name,change,reason in [
        ('failed render',lambda d:d.update(exit=1),'complete actual render'),
        ('missing guard',lambda d:d.update(inputs_after=0),'book input guards'),
        ('forged instrument',lambda d:d.update(instrument_sha256='0'*64),'actual book instrument'),
        ('forged channel',lambda d:d['html'].update(sha256='0'*64),'book channel bytes'),
        ('missing examples',lambda d:d.update(html=envelope(b'<html>no examples</html>')),'original rendered boundary examples'),
        ('missing label teaching',lambda d:d.update(html=envelope(decode(d['html']).replace(b'a quoted argument is one boundary label',b'label teaching removed'))),'whole quoted label teaching'),
        ('hidden nested behavior',lambda d:d.update(html=envelope(decode(d['html']).replace(b'It also works inside assignments, returns and hash values',b'behavior removed'))),'nested unknown-escape teaching'),
        ('hidden backend scope',lambda d:d.update(html=envelope(decode(d['html']).replace(b'they do not establish the other backends',b'scope removed'))),'explicit cross-backend scope'),
        ('missing catalog contract',lambda d:d.update(development_html=envelope(b'<html>contract removed</html>')),'public catalog quoted-label contract'),
        ('missing mechanism',lambda d:d.update(regression_html=envelope(b'<html>mechanism removed</html>')),'structural lexical authority teaching'),
        ('hidden quoted source debt',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'helper-looking literal data can still be rewritten as',b'debt removed'))),'explicit quoted-source repair owner'),
        ('missing anonymous examples',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'$CAPTURE; $CAPTURE',b'examples removed'))),'original anonymous source examples'),
        ('missing anonymous producer authority',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Each producer snapshots its regex bounds',b'authority removed'))),'anonymous original producer authority'),
        ('missing named examples',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'capture_from(edge); capture_from(edge)',b'examples removed'))),'original named source examples'),
        ('missing named producer authority',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Named captures preserve their original symbolic mark arguments',b'authority removed'))),'named original producer authority'),
        ('missing mark examples',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'mark_here(edge); mark_here(edge)',b'examples removed'))),'original mark source examples'),
        ('missing mark producer authority',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Mark-control producers preserve target/source order',b'authority removed'))),'mark original producer authority'),
        ('missing cursor/input examples',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'cursor_pos(); cursor_pos()',b'examples removed'))),'original cursor/input source examples'),
        ('missing cursor/input argument authority',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Its scanner arguments',b'authority removed'))),'cursor/input original argument authority'),
        ('missing entry/match examples',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'entry_group(2); entry_group(2)',b'examples removed'))),'original entry/match source examples'),
        ('missing entry/match producer authority',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Entry/match producers retain',b'authority removed'))),'entry/match original producer authority'),
        ('missing family fixture example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b't/actionir_helper_source_provenance.t t/generated_source_contract.t',b'example removed'))),'complete-family fixture example'),
        ('missing family validation scope',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Complete-family validation',b'validation removed'))),'complete-family validation scope'),
        ('missing executable-membership boundary',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'a syntactic source origin alone',b'boundary removed'))),'explicit executable-membership boundary'),
        ('missing staged annotation example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'job = parse_job(entry_text()',b'example removed'))),'dedicated annotation examples'),
        ('missing progressive annotation example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'child = dispatch_span(parser',b'example removed'))),'dedicated annotation examples'),
        ('missing recognition annotation example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'# Alternative terminal: recognition_rollback(scope)',b'example removed'))),'dedicated annotation examples'),
        ('missing dedicated fixture command',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b't/staged_ast_enrichment_perl_contract.t',b'example removed'))),'dedicated behavior fixture example'),
        ('hidden recognition origin repair',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'All five recognition/observation scanners now retain their',b'repair removed'))),'recognition current origins'),
        ('hidden dedicated policy scope',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'This diagnosis changes no static policy',b'scope removed'))),'dedicated policy preservation'),
        ('missing staged derived example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'job = parse_job(cat(entry_group(1)',b'example removed'))),'staged preserved text/options examples'),
        ('missing staged invalid option example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'"unknown"',b'option removed'))),'staged preserved text/options examples'),
        ('hidden staged origin repair',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'The staged producer now retains',b'repair removed'))),'staged current source origin'),
        ('hidden staged coordinate boundary',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Copied splitter arrays',b'boundary removed'))),'staged private coordinate boundary'),
        ('hidden nested staged recorder',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Nested scans keep independent recorder contexts',b'context removed'))),'staged nested recorder independence'),
        ('missing progressive repeated intervals',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'# original scalar intervals: [0, 46)',b'intervals removed'))),'progressive repeated and arity examples'),
        ('missing progressive arity example',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'# rejected: dispatch_span requires exactly three operands',b'example removed'))),'progressive repeated and arity examples'),
        ('hidden progressive origin repair',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'The progressive producer now retains',b'repair removed'))),'progressive current source origin'),
        ('hidden progressive authority boundary',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Private source provenance does not grant parser authority',b'authority removed'))),'progressive authority boundary'),
        ('hidden progressive nested boundary',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'progressive coordinates; nested scans restore independent recorder contexts',b'boundary removed'))),'progressive coordinate and nested boundary'),
        ('missing recognition checkpoint intervals',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'# original scalar intervals: [0, 32)',b'intervals removed'))),'recognition repeated and malformed examples'),
        ('missing observation intervals',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'# original scalar intervals: [0, 52)',b'intervals removed'))),'recognition repeated and malformed examples'),
        ('missing malformed observation examples',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'# rejected: static call operand, missing observation operand, extra observation operand',b'example removed'))),'recognition repeated and malformed examples'),
        ('hidden recognition object authority',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'same returned event and argument objects',b'authority removed'))),'recognition original object authority'),
        ('hidden recognition malformed boundary',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Malformed operands and arity retain',b'boundary removed'))),'recognition malformed static boundary'),
        ('hidden recognition runtime debt',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Source origins do not repair token order',b'debt removed'))),'recognition runtime defect boundary'),
        ('hidden dedicated-family acceptance scope',lambda d:d.update(regression_html=envelope(decode(d['regression_html']).replace(b'Complete dedicated-family validation',b'validation removed'))),'committed dedicated-family acceptance scope'),
        ('missing history examples',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'original_prefix = source',b'examples removed'))),'original rendered history examples'),
        ('missing terminal separator teaching',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'Rollover removes terminal LF separators',b'teaching removed'))),'hot-root terminal separator teaching'),
        ('missing pending string identity',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'four-character JSON string',b'identity removed'))),'pending metadata string identity teaching'),
        ('missing archive-only scope',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'returns archive bytes only',b'scope removed'))),'explicit archive-only query scope'),
        ('missing audit replay example',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'0.4.2.1-proof.py',b'0.4.2.1-other.py'))),'original rendered history examples'),
        ('missing historical hash preservation',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'Historical recovery keeps the original hashes',b'history removed'))),'historical audit identity preservation'),
        ('missing historical runtime scope',lambda d:d.update(history_html=envelope(decode(d['history_html']).replace(b'It does not re-execute historical runtime producers',b'scope removed'))),'historical runtime scope'),
    ]:
        candidate=copy.deepcopy(report); change(candidate); assert candidate != report, 'effective book corruption'
        try: check_report(candidate,manifest)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append({'name':name,'rejected':True,'reason':reason})
        else: raise AssertionError('accepted corruption: '+name)
    summary={'book_inputs':len(manifest['entries']),'rendered_examples':len(EXAMPLES)+len(ANONYMOUS_EXAMPLES)+len(NAMED_EXAMPLES)+len(MARK_EXAMPLES)+len(CURSOR_EXAMPLES)+len(ENTRY_EXAMPLES)+len(HISTORY_EXAMPLES)+1+len(DEDICATED_EXAMPLES)+1+len(STAGED_EXAMPLES)+len(PROGRESSIVE_EXAMPLES)+len(RECOGNITION_EXAMPLES),'rendered_sections':4,'controls':controls,'complete':True,'instrument_sha256':sha(Path(__file__).read_bytes())}
    Path(PREFIX+'book-verification.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(str(summary['book_inputs'])+' complete book inputs; '+str(len(EXAMPLES)+len(ANONYMOUS_EXAMPLES)+len(NAMED_EXAMPLES)+len(MARK_EXAMPLES)+len(CURSOR_EXAMPLES)+len(ENTRY_EXAMPLES)+len(HISTORY_EXAMPLES)+1+len(DEDICATED_EXAMPLES)+1+len(STAGED_EXAMPLES)+len(PROGRESSIVE_EXAMPLES)+len(RECOGNITION_EXAMPLES))+' original rendered examples/four chapters; '+str(len(controls))+' RED controls')


if __name__ == '__main__':
    main()

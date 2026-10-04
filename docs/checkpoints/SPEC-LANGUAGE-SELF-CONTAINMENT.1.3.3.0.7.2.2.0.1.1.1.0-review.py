"""Independent authored-segment oracle for the fixed-input statement diagnosis."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import stat
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = 'c02ce88826f815c201a652d5b29bd3cf044d2740'
CONTRACTS = {
    'return_bare': 'return 7', 'exit_bare': 'exit 7',
    'linecount_prefix_newline_matches': r'my @lines = substr($$STRING, 0, $IPOS) =~ /\n/g',
    'print_capture_substr': r'print "<" . substr($$STRING, $IPOS, $LSPOS - $IPOS - 1) . ">\n"',
    'my_declare_bare': 'my $x', 'assign_match_my': 'my $x = $CAPTURE',
    'destructure_imatch_list_my': 'my ($x, $y) = @IMATCH_LIST',
    'regex_subst_assignment': '$x =~ s/a/b/g', 'next_bare': 'next LOOP',
    'ref_field_assign': 'my $x = $node->{key}[0]', 'position_tracking': '$x = pos($$STRING)',
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and digest(raw) == value['sha256'], 'channel bytes'
    return raw


def author_cases():
    # Each tuple is a literal original segment and its role: omitted boundary,
    # unrecognized statement, or recognized statement. Positions accumulate
    # over the author's input construction, never a raw-text search.
    B, S, E = 'boundary', 'statement', 'event'
    plans = [
      ('leading_comment_repeated_declare', [("# lead",S),("\r\n\t",B),("my $x",E),(";  ",B),("my $x",E),(";",B)]),
      ('internal_comment_declare', [("my #inside",S),("\r\n ",B),("$x",S),(";",B)]),
      ('internal_comment_exit', [("exit #inside",E),("\r\n ",B),("7",S),(";",B)]),
      ('quoted_twin_declare', [('text="my $x"',S),('; ',B),('my $x',E),('; ',B),('my $x',E),(';',B)]),
      ('unicode_crlf_return', [('# α',S),('\r\n \t',B),('return 7',E),('; ',B),('return 7',E),(';',B)]),
      ('attached_boundary', [('my $x',E),('; ',B),('if(true) { my $x; }',S),(' ',B),('else { my $x; }',S),('; ',B),('my $x',E),(';',B)]),
    ]
    for contract, text in CONTRACTS.items():
        plans.append((contract + '_repeated', [('# α',S),('\r\n \t',B),(text,E),(';\r\n ',B),(text,E),(';',B)]))
    plans += [
      ('nested_comment_return', [('return (7 #inside\r\n)',S),(';',B)]),
      ('hash_in_quoted_return', [('return "#inside; my $x"',E),(';',B)]),
      ('slashes_and_comments', [('$x =~ s/a#;b/c#;d/g',E),(';\r\n',B),('# next',S),('\r\n',B),('$x =~ s/a#;b/c#;d/g',E),(';',B)]),
      ('unicode_space_declare', [('\u00a0',B),('my $x',E),(';\u2003',B),('my $x',E),(';',B)]),
      ('trailing_comment_declare', [('my $x #inside;',S),('\r\n',B),('my $x',E),(';',B)]),
    ]
    result = []
    for identifier, pieces in plans:
        action, spans, events, offset = '', [], [], 0
        for text, kind in pieces:
            if kind != B:
                span = {'start': offset, 'end': offset + len(text), 'raw': text}
                spans.append(span)
                if kind == E:
                    events.append(len(spans) - 1)
            action += text
            offset += len(text)
        result.append({'id':identifier,'action':action,'statements':spans,'event_indices':events})
    return result


def check_rows(data, expected):
    assert data['dependency_keys'] == sorted(['build_array_pipeline_plan_from_expr', 'normalize_method_args_with_optional_scope', 'parse_method_function_expr', 'split_action_ir_statements', 'trim_action_ir_value']), 'five dependency keys'
    assert data['split_callback']['file'] == 'perl/LinkedSpec/RuleIR/EmitContext.pm', 'canonical split callback'
    assert isinstance(data['split_callback']['line'], int), 'callback source location'
    assert len(data['rows']) == len(expected), 'case population'
    totals = {'statements':0, 'events':0}
    for row, plan in zip(data['rows'], expected):
        assert row['case']['id'] == plan['id'] and row['case']['action'] == plan['action'], 'authored case/source order'
        contracts = ['my_declare_bare','my_declare_bare','exit_bare','my_declare_bare','return_bare','my_declare_bare'] + list(CONTRACTS) + ['return_bare','return_bare','regex_subst_assignment','my_declare_bare','my_declare_bare']
        assert row['case']['contract'] == contracts[expected.index(plan)], 'authored contract population'
        statements = plan['statements']
        for span in statements:
            assert plan['action'][span['start']:span['end']] == span['raw'], 'authored scalar interval'
        assert row['split'] == [{'split_text':s['raw'],'trimmed':s['raw']} for s in statements], 'original contiguous statement text'
        events = row['public_events']
        assert [e['raw'] for e in events] == [statements[i]['raw'] for i in plan['event_indices']], 'recognized statement order'
        assert all(set(e) == {'raw','args'} and isinstance(e['args'],dict) for e in events), 'public event shape'
        assert row['private_result'] == {'events':events,'source_origins':[]}, 'private missing-origin baseline'
        assert row['failure'] is None, 'Toolbox compile/inspection failure'
        assert isinstance(row['substitution'],str) and isinstance(row['diagnostics'],dict), 'complete compiler inspection'
        assert row['dump'].startswith('# LinkedSpec generated parser source.'), 'complete parser source inspection'
        assert row['internal_stdout'] == row['internal_stderr'] == '', 'internal compiler channels'
        totals['statements'] += len(statements)
        totals['events'] += len(events)
    return totals


def check_spans(expected):
    for case in expected:
        previous = -1
        for s in case['statements']:
            assert previous <= s['start'] < s['end'] <= len(case['action']), 'ordered scalar interval'
            assert case['action'][s['start']:s['end']] == s['raw'], 'authored scalar interval'
            previous = s['end']
        assert len(set(case['event_indices'])) == len(case['event_indices']), 'event occurrence identity'
        assert all(0 <= i < len(case['statements']) for i in case['event_indices']), 'event statement membership'


def check_inputs(manifest):
    assert manifest['revision'] == REVISION, 'input revision'
    listing = subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT)
    git_rows, excluded = {}, []
    for raw in filter(None, listing.split(b'\0')):
        meta, path = raw.split(b'\t',1)
        mode, kind, oid, size = meta.split()
        path = path.decode()
        if kind == b'blob' and mode in (b'100644',b'100755'):
            git_rows[path] = (mode.decode(),oid.decode(),int(size))
        else:
            excluded.append({'path':path,'mode':mode.decode(),'kind':kind.decode()})
    entries = manifest['entries']
    assert len({e['path'] for e in entries}) == len(entries), 'unique input members'
    supplied = {e['path']:e for e in entries if not e.get('overlay')}
    assert supplied.keys() == git_rows.keys(), 'complete Git input membership'
    assert manifest['excluded_metadata'] == excluded, 'black-box exclusions'
    process = subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path, (mode,oid,size) in git_rows.items():
            entry = supplied[path]
            assert (entry['mode'],entry['oid'],entry['bytes']) == (mode,oid,size), 'Git input identity'
            process.stdin.write((oid+'\n').encode());process.stdin.flush()
            header = process.stdout.readline().split()
            assert header == [oid.encode(),b'blob',str(size).encode()], 'Git blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'Git blob framing'
            assert digest(raw) == entry['sha256'], 'Git input bytes'
            assert hashlib.sha1(b'blob '+str(size).encode()+b'\0'+raw).hexdigest() == oid, 'Git object content'
    finally:
        process.stdin.close();process.stdout.close();assert process.wait() == 0
    overlays = {e['path']:e for e in entries if e.get('overlay')}
    assert set(overlays) == {str(Path(PREFIX+n).relative_to(ROOT)) for n in ('cases.json','probe.pl')}, 'explicit overlay membership'
    for path, entry in overlays.items():
        raw = (ROOT/path).read_bytes()
        assert entry['mode'] == '100644' and len(raw) == entry['bytes'] and digest(raw) == entry['sha256'], 'overlay bytes'
    return len(git_rows), len(overlays)


def check_report(report, manifest, expected):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete exact-input report'
    assert report['instrument_sha256'] == digest(Path(PREFIX+'capture.py').read_bytes()), 'actual capture instrument'
    assert [r['seed'] for r in report['runs']] == [0,1,42], 'hash-seed population'
    previous = None
    totals = None
    for run in report['runs']:
        assert run['perturb'] == 2 and run['exit'] == 0, 'actual successful probe'
        assert run['command'] == ['bash','tools/project_data_run.sh','perl','-Iperl',str(Path(PREFIX+'probe.pl').relative_to(ROOT))], 'actual probe command'
        assert run['inputs_before'] == run['inputs_after'] == len(manifest['entries']) and 'input_failure' not in run, 'input boundary guards'
        assert decode(run['stderr']) == b'', 'complete outer stderr'
        raw = decode(run['stdout'])
        data = json.loads(raw)
        totals = check_rows(data,expected)
        assert previous is None or raw == previous, 'actual cross-seed stream identity'
        previous = raw
    return totals


def main():
    manifest = json.loads(Path(PREFIX+'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX+'observations.json').read_bytes())
    expected = author_cases()
    check_spans(expected)
    cases = json.loads(Path(PREFIX+'cases.json').read_bytes())
    assert [(c['id'],c['action']) for c in cases] == [(c['id'],c['action']) for c in expected], 'independent authored fixture population'
    inputs, overlays = check_inputs(manifest)
    totals = check_report(report,manifest,expected)
    controls = []
    def reject(name, change, reason, subject, check):
        candidate = copy.deepcopy(subject)
        change(candidate)
        try:
            check(candidate)
        except (AssertionError, KeyError) as error:
            assert error.args[0] == reason, (name,str(error),reason)
            controls.append({'name':name,'rejected':True,'reason':reason})
        else:
            raise AssertionError('accepted corruption: '+name)
    data = json.loads(decode(report['runs'][0]['stdout']))
    reject('erase repeated event', lambda d:d['rows'][0]['public_events'].pop(), 'recognized statement order',data,lambda d:check_rows(d,expected))
    reject('invent private origins', lambda d:d['rows'][0]['private_result']['source_origins'].append({}), 'private missing-origin baseline',data,lambda d:check_rows(d,expected))
    reject('strip comment text', lambda d:d['rows'][1]['split'][0].update(split_text='my',trimmed='my'), 'original contiguous statement text',data,lambda d:check_rows(d,expected))
    reject('join comment-separated statement', lambda d:d['rows'][1]['split'].__setitem__(slice(None),[{'split_text':'my $x','trimmed':'my $x'}]), 'original contiguous statement text',data,lambda d:check_rows(d,expected))
    reject('invent nested declaration', lambda d:d['rows'][5]['public_events'].append({'raw':'my $x','args':{}}), 'recognized statement order',data,lambda d:check_rows(d,expected))
    reject('erase compiler failure', lambda d:d['rows'][0].update(failure='injected compiler failure'), 'Toolbox compile/inspection failure',data,lambda d:check_rows(d,expected))
    reject('drop case', lambda d:d['rows'].pop(), 'case population',data,lambda d:check_rows(d,expected))
    reject('add dependency', lambda d:d['dependency_keys'].append('source_frames'), 'five dependency keys',data,lambda d:check_rows(d,expected))
    reject('quoted twin source offset', lambda d:d[3]['statements'][1].update(start=6,end=11), 'ordered scalar interval',expected,check_spans)
    reject('Unicode byte offset', lambda d:d[4]['statements'][1].update(start=d[4]['statements'][1]['start']+1), 'authored scalar interval',expected,check_spans)
    reject('reuse repeated occurrence', lambda d:d[0].update(event_indices=[1,1]), 'event occurrence identity',expected,check_spans)
    reject('missing regular input',lambda d:d['entries'].pop(0),'complete Git input membership',manifest,check_inputs)
    reject('forge Git input hash',lambda d:d['entries'][0].update(sha256='0'*64),'Git input bytes',manifest,check_inputs)
    reject('forge mode',lambda d:d['entries'][0].update(mode='100755' if d['entries'][0]['mode']=='100644' else '100644'),'Git input identity',manifest,check_inputs)
    reject('promote partial capture',lambda d:d.update(complete=False),'complete exact-input report',report,lambda d:check_report(d,manifest,expected))
    reject('forge instrument',lambda d:d.update(instrument_sha256='0'*64),'actual capture instrument',report,lambda d:check_report(d,manifest,expected))
    reject('omit actual input guard',lambda d:d['runs'][0].update(inputs_after=0),'input boundary guards',report,lambda d:check_report(d,manifest,expected))
    reject('forge actual exit',lambda d:d['runs'][0].update(exit=1),'actual successful probe',report,lambda d:check_report(d,manifest,expected))
    reject('forge channel hash',lambda d:d['runs'][0]['stdout'].update(sha256='0'*64),'channel bytes',report,lambda d:check_report(d,manifest,expected))
    result = {'revision':REVISION,'git_inputs':inputs,'overlays':overlays,'runs':len(report['runs']),'cases_per_run':len(expected),**totals,'expected':expected,'controls':controls,'review_instrument_sha256':digest(Path(__file__).read_bytes())}
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
    print({k:v for k,v in result.items() if k not in ('expected','controls')})
    print(str(len(controls))+' reason-checked RED controls')


if __name__ == '__main__':
    main()

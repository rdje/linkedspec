"""Read-only source, native artifact, oracle and rendered-book intake review."""
import hashlib
import gzip
import json
import os
from pathlib import Path
import subprocess
import tempfile
import zlib
import common as c
import book
import document2 as document
import inspect_native
import inspect_perl
import oracle

EPOCHS = ['perl-inputs.json.gz','key-control-inputs.json.gz','native-inputs.json.gz',
    'rust-clamp-inputs.json.gz','oracle-inputs.json.gz','documentation-preflight-inputs.json.gz',
    'documentation-inputs.json.gz','book-inputs.json.gz']
WRITE_ERRORS = ['write-last','write-first','write-dynamic','write-underflow','write-empty',
    'write-absent','write-null','write-mixed','callable-write','callable-copied-parameter-write',
    'write-fractional','write-string-negative-on-array']
PORTABLE_CONTROLS = ['read-quoted-key','read-positive','read-negative-zero','write-quoted-key',
    'write-append','callable-positive-write','write-positive-effects']


def packet(raw):
    value = c.decode(raw['base64'])
    assert c.sha(value) == raw['sha256']
    assert isinstance(raw['mode'],int) and 0 <= raw['mode'] <= 0o7777
    return value


def regular_tree():
    result = {}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name = row.split(b'\t',1)
            mode,kind,oid = metadata.decode().split()
            if mode in ('100644','100755'):
                assert kind == 'blob'
                result[name.decode()] = dict(mode=mode,oid=oid)
    return result


def git_digests(oids):
    """Read each required main-repository blob once; never traverse a Gitlink."""
    result = {}
    with tempfile.TemporaryFile(dir=os.environ['TMPDIR']) as requests, tempfile.TemporaryFile(dir=os.environ['TMPDIR']) as errors:
        requests.write(('\n'.join(sorted(oids))+'\n').encode())
        requests.seek(0)
        process = subprocess.Popen(['git','cat-file','--batch'],cwd=c.ROOT,
            stdin=requests,stdout=subprocess.PIPE,stderr=errors)
        try:
            for expected in sorted(oids):
                header = process.stdout.readline().decode().split()
                assert len(header) == 3 and header[:2] == [expected,'blob'], 'Git source object'
                remaining = int(header[2])
                digest = hashlib.sha256()
                while remaining:
                    raw = process.stdout.read(min(remaining,1024*1024))
                    assert raw, 'truncated Git source object'
                    digest.update(raw)
                    remaining -= len(raw)
                assert process.stdout.read(1) == b'\n'
                result[expected] = digest.hexdigest()
            assert process.wait() == 0
            errors.seek(0)
            assert not errors.read()
        finally:
            if process.poll() is None:
                process.kill()
            process.wait()
            process.stdout.close()
    return result


def source_epochs():
    tree = regular_tree()
    epochs = [c.load(name)['context'] for name in EPOCHS]
    objects = {tree[path]['oid'] for epoch in epochs for path in epoch['inputs']
        if path not in epoch['overrides'] and path in tree}
    digests = git_digests(objects)
    for epoch in epochs:
        assert epoch['base'] == epoch['head'] == c.BASE
        assert set(epoch['overrides']) <= set(epoch['inputs'])
        for path,item in epoch['inputs'].items():
            assert not Path(path).is_absolute() and '..' not in Path(path).parts
            assert isinstance(item['mode'],int) and 0 <= item['mode'] <= 0o7777
            if path in epoch['overrides']:
                supplied = epoch['overrides'][path]
                packet(supplied)
                assert {key:supplied[key] for key in ('sha256','mode')} == item, 'epoch override identity'
            elif path in tree:
                assert digests[tree[path]['oid']] == item['sha256'], 'Git epoch bytes: '+path
                assert bool(item['mode'] & 0o100) == (tree[path]['mode'] == '100755'), 'Git executable identity'
            else:
                assert path.startswith(c.PREFIX) and path.endswith(('.gz','.part')), 'unsupplied new input: '+path
                assert c.identity(path) == item, 'retained immutable epoch input: '+path
    return dict(epochs=len(epochs),base=c.BASE,unique_git_blobs=len(objects),
        limits='Complete conservative recorded source epochs, with full changed/new plain images and retained immutable inputs. Git identity and complete captured filesystem permissions remain distinct. No dependency implementation or minimal-I/O claim.')


def archive(value):
    digest = hashlib.sha256()
    decoder = zlib.decompressobj(wbits=31)
    size = 0
    seen = set()
    for part in value['parts']:
        path = part['path']
        assert path.startswith(c.PREFIX) and path.endswith('.part') and path not in seen
        seen.add(path)
        assert c.identity(path) == {key:part[key] for key in ('sha256','mode')}, 'archived artifact identity'
        assert c.source(path).stat().st_size == part['bytes'] and 0 < part['bytes'] < 32*1024*1024
        with c.source(path).open('rb') as stream:
            for raw in iter(lambda:stream.read(1024*1024),b''):
                expanded = decoder.decompress(raw)
                digest.update(expanded)
                size += len(expanded)
    tail = decoder.flush()
    digest.update(tail)
    size += len(tail)
    assert decoder.eof and not decoder.unused_data
    assert size == value['bytes'] and digest.hexdigest() == value['sha256'], 'archived executable bytes'
    assert value['mode'] & 0o100
    return dict(parts=len(seen),bytes=size,sha256=value['sha256'])


def parsed(run,exit_code=0):
    assert run['returncode'] == exit_code and not c.decode(run['stderr_base64'])
    return json.loads(c.decode(run['stdout_base64']))


def check(epochs=True):
    source = source_epochs() if epochs else dict(scope='source-epoch review selected separately')
    activation = c.load('activation.json.gz')
    assert activation['base'] == c.BASE and not activation['direct_intersections']
    assert activation['status']['returncode'] == 0 and not c.decode(activation['status']['stdout_base64'])
    assert activation['baseline']['returncode'] == 0 and not c.decode(activation['baseline']['stderr_base64'])
    old_inputs = json.loads(gzip.decompress(packet(activation['manifest'])))['inputs']
    assert old_inputs == activation['inputs']
    assert len(activation['images']) == len(old_inputs)+3 == 55
    prior_scope = c.load('perl-inputs.json.gz')['context']['inputs']
    tree = regular_tree()
    for path,image in activation['images'].items():
        assert {key:image[key] for key in ('sha256','mode')} == prior_scope[path]
        assert {key:image['git'][key] for key in ('mode','oid')} == tree[path]
    proof = activation['git_verification']
    assert proof['returncode'] == 0 and not c.decode(proof['stderr_base64'])
    assert c.decode(proof['stdout_base64']).decode().splitlines() == [
        activation['images'][path]['git']['oid'] for path in sorted(activation['images'])]
    old_claim = 'docs/claims/REPO-HYGIENE.21.json'
    assert c.read(old_claim) == activation['claim']
    assert json.loads(packet(activation['publication']))['record_base64'] == activation['claim']['base64']
    assert repr(c.decode(activation['producer_source']).decode()) in c.source(c.PREFIX+'activate.py').read_text()
    for name,fields in {
        'perl-inputs.json.gz':dict(producer='perl_capture.py',probe='perl_probe.pl',plan='cases.json'),
        'native-inputs.json.gz':dict(producer='native_capture.py',plan='cases.json'),
        'key-control-inputs.json.gz':dict(producer='qualify_key_control.py'),
        'rust-clamp-inputs.json.gz':dict(producer='rust_clamp.py'),
        'documentation-preflight-inputs.json.gz':dict(producer='contain_documentation.py',writer='document.py'),
        'documentation-inputs.json.gz':dict(producer='document2.py'),
    }.items():
        supplied = c.load(name)
        for key,filename in fields.items():
            assert supplied[key] == c.read(c.PREFIX+filename), 'actual producer: '+filename
    for path,value in c.load('oracle-inputs.json.gz')['producers'].items():
        assert value == c.read(path), 'actual oracle producer'
    docs_scope = c.load('documentation-inputs.json.gz')
    assert not docs_scope['direct_intersections']
    assert docs_scope['prior_readonly']['returncode'] == 0 and not c.decode(docs_scope['prior_readonly']['stderr_base64'])
    for path,entry in docs_scope['live_claims'].items():
        assert c.read(path) == entry['packet'], 'unrelated live claim changed'
    cases = c.load('cases.json')['cases']
    names = [case['id'] for case in cases]
    assert len(names) == len(set(names)) == 32
    plans = {case['id']:case for case in cases}
    perl_packet = c.load('perl-baseline.json.gz')
    assert perl_packet['inputs_unchanged']
    perl_raw = parsed(perl_packet['run'])
    assert [row['id'] for row in perl_raw['rows']] == names
    perl = {row['id']:row for row in inspect_perl.inspect()}
    for name,row in perl.items():
        meta = row['descriptor']
        assert meta['status'] == 'value' and not meta['warnings'] and not meta['stdout']
        assert meta['value']['canonical_action_ir_fallback_count'] == 0
        assert meta['value']['raw_perl_dependency_count'] == 0
        for route in ('native','generated'):
            value = row['routes'][route]
            if name in WRITE_ERRORS:
                assert value['status'] == 'error' and value['code'] in (
                    'nested_write_segment_invalid','nested_write_kind_conflict')
            else:
                assert value['status'] == 'value' and not value['warnings'] and not value['stdout']
        assert row['routes']['native']['value'] == row['routes']['generated']['value']
    for name in PORTABLE_CONTROLS+['read-positive-receiver-retention']:
        assert perl[name]['routes']['native']['requested_match'] is True
    qualification = c.load('key-control-qualification.json')
    supplied = c.load('key-control-inputs.json.gz')
    assert qualification['id'] == 'read-dynamic-quoted-key'
    assert qualification['original_comparison_target'] == plans[qualification['id']]['requested_value'] == 'key'
    assert qualification['qualified_current_control_value'] is None
    assert perl[qualification['id']]['routes']['native']['value'] is None
    card = 'docs/knowledge/terse-direct-access-bare-path-atoms.md'
    assert supplied['canonical']['sha256'] == c.load('perl-inputs.json.gz')['context']['inputs'][card]['sha256']
    assert b'non-reserved bare path atoms are scalar array indexes' in packet(supplied['canonical'])
    raw = next(row for row in perl_raw['rows'] if row['id'] == qualification['id'])
    assert 'ref($__ls_read_value) eq "ARRAY"' in raw['native']['dump']
    completion = c.load('native-completion.json.gz')
    assert completion['inputs_unchanged'] and completion['case_ids'] == names
    assert completion['runtimes'] == oracle.RUNTIMES
    assert completion['producer'] == c.read(c.PREFIX+'native_capture.py')
    journal = [json.loads(line) for line in packet(completion['journal']).splitlines()]
    expected_journal = []
    native = {}
    for runtime in oracle.RUNTIMES:
        rows = c.load('native-'+runtime+'.json.gz')['rows']
        assert [row['id'] for row in rows] == names
        for row,case in zip(rows,cases):
            assert row['run']['command'][-4:] == ['--inline-spec',case['source'],'--input',case['input']]
            expected_journal.append(dict(runtime=runtime,**row))
        values = {row['id']:row for row in inspect_native.inspect(runtime)}
        for name,row in values.items():
            actual = row['observed']
            if name in WRITE_ERRORS and runtime != 'perl':
                assert (actual['exit'],actual['stdout'],actual['stderr']) == (1,'','linkedspec: parser invocation failed\n')
            else:
                assert actual['status'] == 'value'
                if name in WRITE_ERRORS:
                    assert actual['value'] is None
        for name in PORTABLE_CONTROLS:
            assert values[name]['comparison'] is True, (runtime,name)
        native[runtime] = dict(values=sum(row['observed']['status']=='value' for row in values.values()),
            rejected=sum(row['observed']['status']=='rejected' for row in values.values()),
            read_last=values['read-last']['observed']['value'],
            callable_read=values['callable-read']['observed']['value'])
    assert journal == expected_journal
    rust = c.load('native-rust-artifact.json')
    artifacts = dict(rust=archive(rust))
    assert c.load('native-rust-build.json.gz')['returncode'] == 0
    for abi in ('puc','luajit'):
        assert c.load('native-'+abi+'-build.json.gz')['returncode'] == 0
        artifacts[abi] = {name:archive(value) for name,value in c.load('native-'+abi+'-artifacts.json').items()}
        assert artifacts[abi]
    clamp_inputs = c.load('rust-clamp-inputs.json.gz')
    clamp = c.load('rust-clamp-run.json.gz')
    assert clamp['inputs_unchanged'] and parsed(clamp['run']) == clamp['value'] == [-2,10,10,10,10]
    packet(clamp['trace'])
    assert clamp_inputs['binary'] == rust
    engine = packet(clamp_inputs['engine'])
    assert b'let idx: usize = idx_val.as_number().unwrap_or(0.0) as usize;' in engine
    assert b'(RuntimeValue::Number(-1.0), serde_json::json!("a"))' in engine
    controls = c.load('oracle-runs.json.gz')
    assert controls['inputs_unchanged']
    routes = ['perl/get','perl/generated']+[runtime+'/cli' for runtime in oracle.RUNTIMES]
    assert set(controls['requested']) == set(routes)
    failures = {}
    for route in routes:
        value = parsed(controls['requested'][route],1)
        assert value == oracle.requested(route) and value['failures']
        failures[route] = len(value['failures'])
    for runtime in oracle.RUNTIMES:
        value = parsed(controls['cli'][runtime],1 if runtime == 'perl' else 0)
        assert value == oracle.cli_failures(runtime)
        assert bool(value['failures']) == (runtime == 'perl')
    docs = c.load('documentation.json.gz')
    assert docs['knowledge_byte_delta'] == sum(
        len(packet(docs['after'][path]))-len(packet(docs['before'][path])) for path in document.CARDS) <= 0
    for path in document.CARDS:
        before = packet(docs['before'][path]).decode().split('answers:\n',1)[1].split('\ndate:',1)[0]
        after = packet(docs['after'][path]).decode().split('answers:\n',1)[1].split('\ndate:',1)[0]
        assert after.startswith(before+'\n'), 'old Knowledge questions'
    preflight = c.load('documentation-preflight-replay.json.gz')
    assert preflight['inputs_unchanged'] and preflight['run']['returncode'] == 1
    assert b"AssertionError: ('Knowledge must not grow', 947)" in c.decode(preflight['run']['stderr_base64'])
    containment = c.load('documentation-containment.json.gz')
    assert containment['before'] == c.read(c.PREFIX+'document.py')
    assert containment['after'] == c.read(c.PREFIX+'document2.py')
    book_inputs = c.load('book-inputs.json.gz')
    assert book_inputs['producer'] == c.read(c.PREFIX+'book.py')
    for supplied in book_inputs['inputs'].values():
        packet(supplied)
    book_runs = c.load('book-runs.json.gz')
    assert book_runs['inputs_unchanged']
    book.validate(book_runs['healthy'],book_inputs['inputs'])
    reasons = dict(heading='book heading',source='rendered executable source',cli='CLI limitation')
    assert set(book_runs['faults']) == set(reasons)
    for name,reason in reasons.items():
        try:
            book.validate(book_runs['faults'][name],book_inputs['inputs'])
        except AssertionError as error:
            assert str(error) == reason
        else:
            raise AssertionError('changed rendered book admitted')
    example_rows = parsed(c.load('book-runtime.json.gz'))['rows']
    assert [row['id'] for row in example_rows] == list(document.EXAMPLES.values())
    for row in example_rows:
        for route in ('native','generated'):
            actual = row[route]
            assert actual['completed'] and not actual['exception'] and not actual['last_error']
            assert not actual['warnings'] and not actual['stdout']
            assert actual['value'] == book.EXPECTED[row['id'].replace('-','_')]
    return dict(source=source,prior_custody_images=55,perl_sources=32,native_sources=32,native_observations=len(journal),
        native=native,requested_oracle_failures=failures,cli_failure_red='perl',cli_failure_green=oracle.RUNTIMES[1:],
        artifacts=artifacts,book_inputs=len(book_inputs['inputs']),book_examples=2,book_source_denials=3,
        knowledge_byte_delta=docs['knowledge_byte_delta'],
        limits='Dated baseline from unchanged runtime sources at accepted92c98fb3d plus retained instrument epochs. No signed implementation/admission or repaired CLI claim. Native non-Perl emitted routes remain mandatory in backend children; SDK/OS/public dependency outputs are read-only prerequisites. One wrong comparison target and one rejected documentation proposal are qualified separately, without product RED credit.')


if __name__ == '__main__':
    print(json.dumps(check(),sort_keys=True))

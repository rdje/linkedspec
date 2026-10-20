"""Retain and correct diagnostic-review and selector preparation mistakes."""
import common as c
import context


def main():
    paths = [c.PREFIX+'oracle.py',c.PREFIX+'migrate_phase0.py']
    before = {path:c.read(path) for path in paths}
    snapshot = context.snapshot([c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
                                +['tests/drop-generated/cases.json','t/drop_keys_generated.t'])
    run = c.run(['bash','tools/run_python_project_data.sh',paths[0]])
    assert run['returncode'] != 0 and b"('diagnostic/call/null-key', 'generated')" in c.decode(run['stderr_base64'])
    assert c.unchanged(snapshot['inputs'])
    text = c.decode(before[paths[0]]['base64']).decode()
    old = "            assert not row[route]['warnings'] and not row[route]['stdout'], (name,route)\n"
    new = '''            assert not row[route]['stdout'], (name,route)
            expected_warnings = [] if route == 'native' else [
                item for item in old[name]['generated']['warnings']
                if not item.startswith('Scalar value @__ls_drop{')]
            # Preserve the existing uninitialized-key diagnostic, including its
            # severity/count. Only the compiler's new private carrier changes.
            warnings = lambda items: [normalize(re.sub(
                r'\\$DropGeneratedProbe\\d+::null|\\$__ls_drop_keys\\[0\\]', '<key-slot>', item)) for item in items]
            assert warnings(row[route]['warnings']) == warnings(expected_warnings), (name,route)
'''
    assert text.count(old)==1
    text=text.replace(old,new,1)
    old="                assert result['value'] == old[name]['descriptor']['value'] or result['value'] == {\n"
    assert text.count(old)==1
    text=text.replace(old,"                assert result['value'] == {\n",1)
    text=text.replace('dynamic eval/line coordinates. Hash-key raw shape leakage',
                      'dynamic eval/line coordinates and the named uninitialized-key carrier. Hash-key raw shape leakage')
    migration=c.decode(before[paths[1]]['base64']).decode()
    assert migration.count("c.load('phase0-before-run.json.gz')")==1
    migration=migration.replace("c.load('phase0-before-run.json.gz')","c.load('phase0-before2-run.json.gz')",1)
    after={paths[0]:text.encode(),paths[1]:migration.encode()}
    for path,raw in after.items():compile(raw,path,'exec')
    c.write_new('review-refinement.json.gz',dict(before=before,after={path:c.encode(raw) for path,raw in after.items()},
        inputs=snapshot,failed_oracle=run,inputs_unchanged=True,producer=c.read(c.PREFIX+'refine_review.py'),
        scope='The first oracle incorrectly demanded quiet invalid-null diagnostics; retain its actual RED and '
              'whole source before preserving the accepted uninitialized warning. The first focused selector '
              'was preparation exit255; only the complete five-root before2 run supplies the five actual '
              'obsolete source/warning assertion failures. No runtime result or warning policy is refreshed.'))
    for path,raw in after.items():(c.ROOT/path).write_bytes(raw)
    print('Retained failed review; preserve underlying null-key warning and use complete five-root baseline')


if __name__=='__main__':
    main()

"""Recover the interrupted history reviewer using the documented EOF separator contract."""
import json
import subprocess
import traceback
import common as c
import context


def main():
    producer = c.read(c.PREFIX+'history.py')
    pressure = c.load('change_history-pressure.json.gz')
    rows = c.source('docs/history/changes/manifest.jsonl').read_bytes().splitlines(keepends=True)
    entry = json.loads(rows[1])
    actual_root = c.source('CHANGES.md').read_bytes()
    archived = c.source(entry['target_path']).read_bytes()
    source = subprocess.check_output(['git','show',c.BASE+':CHANGES.md'],cwd=c.ROOT)
    record = pressure['record']
    try:
        assert actual_root.replace(record.encode(),b'',1)+archived == source
    except AssertionError:
        failure = traceback.format_exc()
    else:
        raise AssertionError('Original reconstruction assumption unexpectedly passed')
    prefix = source[:-len(archived)]
    retained = actual_root.replace(record.encode(),b'',1)
    assert retained == prefix.rstrip(b'\n')+b'\n'
    separator = prefix[len(retained):]
    assert separator == b'\n' and retained+separator+archived == source
    c.write_new('history-interruption.json.gz',dict(producer=producer,context=context.snapshot(),
        original_assertion=failure,current=c.read('CHANGES.md'),manifest=c.read('docs/history/changes/manifest.jsonl'),
        entry=entry,separator_base64=c.encode(separator),
        authority=c.read('docs/knowledge/document-history-rollover-eof-separator.md'),
        scope='The normal roller has already published the exact archive and normalized one mutable-root LF, as the existing canonical fact documents. The first reviewer omitted that LF and stopped. Its first apply channels were not retained before the assertion; do not describe them as retained. Resume retains actual no-op apply/check channels, exact current/archive/old Git reconstruction and every prior immutable identity; no archive or manifest rewrite.'))
    text = c.decode(producer['base64']).decode()
    text = text.replace("c.write_new('history-inputs.json.gz',context.snapshot())",
        "c.write_new('history-resume-inputs.json.gz',context.snapshot())",1)
    old = "    tree = tree.replace(marker,'  Commit prerequisite owned here:"
    assert text.count(old) == 1
    text = text.replace(old,"    tree = tree if '  Commit prerequisite owned here:' in tree else tree.replace(marker,'  Commit prerequisite owned here:",1)
    begin = text.index('        before = c.read(root)')
    end = text.index("        applied = c.run(",begin)
    replacement = '''        manifest_path = 'docs/history/'+family+'/manifest.jsonl'
        pressure_path = c.ROOT/c.PREFIX/(surface+'-pressure.json.gz')
        if pressure_path.exists():
            previous = c.load(surface+'-pressure.json.gz')
            assert previous['record'] == record
            before,manifest_before = previous['before'],previous['manifest_before']
            old_members,pressure = previous['old_members'],previous['run']
        else:
            before = c.read(root)
            manifest_before = c.read(manifest_path)
            old_members = {path.relative_to(c.ROOT).as_posix():c.identity(path.relative_to(c.ROOT).as_posix())
                for path in (c.ROOT/'docs/history'/family).glob('*') if path.is_file()}
            value = c.decode(before['base64']).decode()
            start = re.search(r'^## ',value,re.M).start()
            c.source(root).write_text(value[:start]+record+value[start:])
            pressure = c.run(['perl','tools/roll_document_history.pl','--surface',surface,'--check'])
            c.write_new(surface+'-pressure.json.gz',dict(before=before,manifest_before=manifest_before,
                record=record,run=pressure,old_members=old_members))
        assert pressure['returncode'] != 0 and b'rollover required' in c.decode(pressure['stderr_base64'])
'''
    text = text[:begin]+replacement+text[end:]
    old = "        assert actual_root.replace(record.encode(),b'',1)+archived == source"
    replacement = '''        prefix = source[:-len(archived)]
        retained = actual_root.replace(record.encode(),b'',1)
        assert retained == prefix.rstrip(b'\\n')+b'\\n'
        separator = prefix[len(retained):]
        assert retained+separator+archived == source
'''.rstrip()
    assert text.count(old) == 1
    text = text.replace(old,replacement,1)
    text = text.replace("current=c.read(root),manifest=c.read(manifest_path),segment=c.read(entry['target_path']),",
        "current=c.read(root),manifest=c.read(manifest_path),segment=c.read(entry['target_path']),separator_base64=c.encode(separator),",1)
    with (c.ROOT/c.PREFIX/'resume_history.py').open('x') as output:
        output.write(text)
    print('Exact one-LF producer contract verified; resume writer prepared without archive changes')


if __name__ == '__main__':
    main()

"""Exclude dated trace transport timestamps while preserving diagnostic text."""
import common as c


def main():
    path=c.PREFIX+'oracle.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b"('diagnostic/array-source', 'native')" in c.decode(run['stderr_base64'])
    old="        value = re.sub(r'\\(eval \\d+\\)', '(eval N)', value)\n"
    new=old+"        value = re.sub(r'(?m)^\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\]', '[TIME]', value)\n"
    raw=c.decode(before['base64']).decode()
    assert raw.count(old)==1
    after=raw.replace(old,new,1).encode()
    c.write_new('review-refinement3.json.gz',dict(before=before,after_base64=c.encode(after),failed_oracle=run,
        producer=c.read(c.PREFIX+'refine_review3.py'),
        scope='Third rejected oracle differs only in the accepted trace timestamp. Preserve all three '
              'trace lines/severity/mechanism; normalize only the leading exact date/time transport field.'))
    (c.ROOT/path).write_bytes(after)


if __name__=='__main__':main()

"""Keep ordinary invalid-receiver warnings observable rather than assuming quietness."""
import common as c


def main():
    path=c.PREFIX+'review_baseline.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b'ordinary/sum/receiver-arity' in c.decode(run['stderr_base64'])
    raw=c.decode(before['base64']).decode()
    old="        for route in ('descriptor','native','generated'):\n            assert not row[route]['warnings'],(row['id'],route,row[route]['warnings'])\n"
    assert raw.count(old)==1
    after=raw.replace(old,'')
    after=after.replace("'last_error','stdout')}","'last_error','stdout','warnings')}")
    after=after.replace("and row[route]['last_error'] is None and not row[route]['stdout']",
        "and row[route]['last_error'] is None and not row[route]['stdout'] and not row[route]['warnings']")
    c.write_new('baseline-policy-preparation.json.gz',dict(before=before,run=run,after_base64=c.encode(after.encode()),
        scope='Ordinary invalid receiver arity can warn. Preserve that diagnostic as actual baseline, '
              'not a global quietness assumption or newly assigned policy. Fixed desired cases require quiet success.'))
    (c.ROOT/path).write_text(after)


if __name__=='__main__':main()

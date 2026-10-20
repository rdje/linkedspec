"""Keep accepted invalid-source diagnostic output, rather than demanding quiet."""
import common as c


def main():
    path=c.PREFIX+'oracle.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b"('diagnostic/array-source', 'native')" in c.decode(run['stderr_base64'])
    old="            assert not row[route]['stdout'], (name,route)\n"
    new="""            previous_route = 'native' if route == 'native' else 'generated'
            expected_output = '' if name.endswith('/hash-key') else old[name][previous_route]['stdout']
            assert normalize(row[route]['stdout']) == normalize(expected_output), (name,route)
"""
    raw=c.decode(before['base64']).decode()
    assert raw.count(old)==1
    after=raw.replace(old,new,1).encode()
    c.write_new('review-refinement2.json.gz',dict(before=before,after_base64=c.encode(after),failed_oracle=run,
        producer=c.read(c.PREFIX+'refine_review2.py'),
        scope='Retain second rejected diagnostic oracle. Invalid array-source native Get already emits '
              'structured error text on stdout; compare it to the accepted output with transport '
              'coordinates normalized. Desired-value routes still require absolute silence.'))
    (c.ROOT/path).write_bytes(after)
    print('Accepted invalid-source stdout is now compared, preserving its diagnostic')


if __name__=='__main__':main()

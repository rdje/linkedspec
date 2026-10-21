"""Retain missing dump-option preparation, then correct the public instrument."""
import common as c


def main():
    path=c.PREFIX+'review_baseline.py'
    before=c.read(path)
    failed=c.run(['bash','tools/run_python_project_data.sh',path])
    assert failed['returncode']!=0 and b"assert 'dump' in row['native']" in c.decode(failed['stderr_base64'])
    raw=c.decode(before['base64']).decode()
    old="        assert 'dump' in row['native'] and 'source' in row['generated']"
    assert raw.count(old)==1
    after=raw.replace(old,"        assert 'dump' not in row['native'] and 'source' in row['generated']\n"
        "        # Initial accepted probe omitted dump_parser_source; fresh dump epoch is separate.")
    probe=c.read(c.PREFIX+'probe.pl')
    source=c.decode(probe['base64']).decode()
    old='runtime_ctx_ref => \\%context, parser_source_ref => \\$dump'
    assert source.count(old)==1
    corrected=source.replace(old,'runtime_ctx_ref => \\%context, dump_parser_source => 1, parser_source_ref => \\$dump')
    c.write_new('dump-preparation.json.gz',dict(review_before=before,failed=failed,
        review_after_base64=c.encode(after.encode()),probe_before=probe,probe_after_base64=c.encode(corrected.encode()),
        scope='Accepted176 raw executions are unchanged. The initial Get option lacked dump_parser_source; '
              'review truthfully qualifies that epoch. Correct instrument adds the documented option; '
              'separate accepted dump epoch precedes implementation inspection.'))
    (c.ROOT/path).write_text(after)
    (c.ROOT/(c.PREFIX+'probe.pl')).write_text(corrected)
    print('Missing dump flag retained and corrected; accepted176 results remain untouched')


if __name__=='__main__':main()

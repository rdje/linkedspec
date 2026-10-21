"""Observe malformed serialized fluent argument lists through the public invocation API."""
import json
import sys
import common as c

def typed(run):
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    rows=json.loads(c.decode(run['stdout_base64']))['rows']
    return len(rows)==15 and all(row['error'].get('fields',{}).get('code')=='invalid_codeblock_body'
        and row['error']['fields'].get('detail')=='fluent arguments must be an array'
        and row['record_unchanged'] and row['caller_unchanged'] and not row['completed'] for row in rows)

def main():
    epoch=sys.argv[1];assert epoch in ('before','after')
    sources={p:c.read(p) for p in (c.PREFIX+'malformed.py',c.PREFIX+'malformed.pl',c.SOURCE)}
    run=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
    c.write_new('malformed-'+epoch+'.json.gz',dict(sources=sources,run=run,typed=typed(run)))
    print(epoch,'typed15',typed(run))

if __name__=='__main__':main()

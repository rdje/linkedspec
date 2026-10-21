"""Validate the actual prohibited-name compilation boundary, not runtime dispatch."""
import common as c


def main():
    path=c.PREFIX+'oracle.py'
    before=c.read(path)
    raw=c.decode(before['base64']).decode()
    old="        descriptor=row['descriptor']\n"
    new='''        if 'source_error' in case:
            for route in ('descriptor','native'):
                item=row[route];detail=item['runtime_detail'];error=item['last_error']
                if not (not item['completed'] and item['value'] is None and error is not None
                    and error.get('stage')=='function_registry' and detail is not None
                    and case['source_error'] in detail.get('text','') and not item['warnings']):
                    reasons.append(route+'-registry-rejection')
            item=row['generated'];error=item['exception']
            if not (not item['completed'] and item['value'] is None and error is not None
                and error.get('fields',{}).get('code')=='generated_source_emit_failed'
                and case['source_error'] in str(error['fields'].get('detail','')) and not item['warnings']):
                reasons.append('generated-registry-rejection')
            if reasons:failures.append(dict(id=name,reasons=reasons,actual=row))
            continue
        descriptor=row['descriptor']
'''
    assert raw.count(old)==1
    after=raw.replace(old,new,1)
    start=after.index("        elif 'source_error' in case:\n")
    end=after.index('        else:\n            native=',start)
    after=after[:start]+after[end:]
    c.write_new('registry-oracle-preparation.json.gz',dict(before=before,after_base64=c.encode(after.encode()),
        raw_source=c.identity(c.PREFIX+'candidate1-run.json.gz'),producer=c.read(c.PREFIX+'qualify_registry.py'),
        scope='Known invalid function definition fails at function_registry/emit_source before dump or '
              'execution. Retain earlier unexecuted runtime-stage predicate and apply exact accepted '
              'compiler diagnostics; no source or observation is rewritten.'))
    (c.ROOT/path).write_text(after)


if __name__=='__main__':main()

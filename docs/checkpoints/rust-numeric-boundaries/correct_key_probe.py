"""Retain and correct a typed-selector mistake in the helper/key probe."""
import json
import re
import common as c


def main():
    name='tests/numeric-conversion/programs.json'
    before=c.read(name)
    fixture=json.loads(c.decode(before['base64']))
    changed=[]
    for row in fixture['cases']:
        if not row['id'].startswith('text-consumer/'):
            continue
        pattern=r'h=\{\}; h\[(.*?)\]=7; return\(\[trim\((.*?)\),length\((.*?)\),h\]\)'
        match=re.search(pattern,row['source'])
        assert match and len(set(match.groups()))==1
        value=match.group(1)
        row['source']=(row['source'][:match.start()]+'return([trim('+value+'),length('
            +value+'),hash('+value+',7)])'+row['source'][match.end():])
        changed.append(row['id'])
    assert len(changed)==4
    fixture['version']=3
    (c.ROOT/name).write_text(json.dumps(fixture,indent=2)+'\n')
    c.save('key-probe-qualification.json.gz',dict(before=before,after=c.read(name),
        producer=c.read(c.PREFIX+'correct_key_probe.py'),changed=changed,
        original_after=c.load('runtime-after-run.json.gz'),
        cause='Numeric harray bracket assignment is an array selector and correctly '
            'fails the typed nested-write contract. The four authored source cases '
            'were invalid instruments for numeric hash-key coercion; their16 original '
            'rows in each four-carrier epoch earn no conversion product-RED credit. '
            'Use documented hash(value,7) to exercise the actual to_str key consumer. '
            'All fixed expected values and the other45 selected cases stay unchanged. '
            'No production repair or selector-policy change follows.'))
    print('Four key-consumer source probes corrected; original whole sources/outcomes retained.')


if __name__ == '__main__':
    main()

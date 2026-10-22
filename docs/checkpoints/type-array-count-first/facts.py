"""Refresh existing canonical cards within their measured aggregate budget."""
import json
import re
import common as c
import context


def field(text,name,value):
    text,count = re.subn(r'^'+re.escape(name)+r':.*$',lambda _:name+': '+value,text,count=1,flags=re.M)
    assert count == 1
    return text


def main():
    paths = ['docs/knowledge/terse-type-method-surface-inventory.md',
        'docs/knowledge/finite-engineering-notes-member-0131.md',
        'docs/linkedspec-book/src/development/local-ci-and-regression.md']
    before = {path:c.read(path) for path in paths}
    c.write_new('facts-inputs.json.gz',context.snapshot())
    values = {}
    text = c.decode(before[paths[0]]['base64']).decode()
    text = field(text,'title','"Perl value and helper contracts"')
    text = field(text,'status','bounded Perl; inventory pending')
    text = field(text,'evidence','"Type checkpoints retain exact epochs;10 verifies count/first."')
    text = field(text,'reverify','"bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py"')
    text = text.replace('  - "can Perl sorted and take run inside a deferred codeblock"',
        '  - "can Perl count and first run inside deferred codeblocks"\n  - "can Perl sorted and take run inside a deferred codeblock"',1)
    start = text.index('Bindings hold ')
    end = text.index('\ndrop_keys',start)
    text = text[:start]+'''Bindings hold scalar/array/harray/codeblock. Deferred bodies read caller slots;
constructors/keys/arguments retain values; updates use copy-on-write.
Scoped with: [[perl-generic-final-codeblock-normalization]].

Scalar/aggregate Numeric policies differ. Shape checks precede effects;
comparisons/reducers terminate. Aggregates take one array; receivers no operands.
Scalar min/max evaluates operands before rejection. Perl checks every decimal
term: empty sum0, othersundef; Rust filters differently. Reducer95:
[[perl-numeric-reducer-string-result-kinds]]. Boolean35, Unicode20/constructor94
remain separate.

Perl deferred sorted/take use free/receiver forms. Sort is lexical; copied
comparands preserve numeric/string kinds through clones/indexes. Storable can
cache private iOK on floats: measure flags before cloning.
take defaults1; integer spelling only; negative/invalid0; oversized clamp.
Nonarrays yield[] and skip count; sources/results stay independent.
count/first execute deferred: free calls take one operand, terminal receivers none.
Nonarrays yield0/undef; first preserves kinds/callables; invalid shapes skip effects.
11 owns registered sorted/ordinary length,12 indexed writes,14 last.
Serialized fluent args must be arrays before preflight; no backend admission.
'''+text[end:]
    values[paths[0]] = text
    text = c.decode(before[paths[1]]['base64']).decode()
    text = field(text,'status','ADR0137 finite history; canonical admission required')
    text = field(text,'evidence','"ADR0137 admits two measured history members and exact manifest/decision overhead. Actual old-cap refusals and source reconstruction survive."')
    text = field(text,'reverify','"bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py"')
    marker = '## Current finite continuity: ADR0136'
    assert text.count(marker) == 1
    text = text.replace(marker,'''## Current finite continuity: ADR0137

Count/first10 rolls one change and one note member from real a8bd8620a. Only
measured member/manifest and sole decision/index overhead changes. Every older
immutable byte stays exact; omitted root LF separators recover from Git. Actual
old-cap refusal and corrected reviewers survive in type-array-count-first/.
No future archive reserve.

## Prior finite continuity: ADR0136''',1)
    values[paths[1]] = text
    text = c.decode(before[paths[2]]['base64']).decode()
    old = 'including engineering-notes segment 4992, remain recorded in ADRs `0081` and `0083`.'
    assert text.count(old) == 1
    values[paths[2]] = text.replace(old,old+' ADR `0137` admits only the two measured count/first history members and their exact manifest/decision overhead; it grants no future archive reserve.',1)
    cards = list((c.ROOT/'docs/knowledge').glob('*.md'))
    total = sum(len(values.get(path.relative_to(c.ROOT).as_posix(),path.read_text()).encode()) for path in cards)
    surface = next(json.loads(line) for line in c.source('doctrine/readme_stability/routes.jsonl').read_text().splitlines()
        if json.loads(line).get('id') == 'knowledge_cards')
    assert total <= surface['limits']['max_total_bytes'], total
    for path,value in values.items():
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    generated = c.run(['bash','knowledge-map/scripts/gen_knowledge_map.sh'])
    c.write_new('facts.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        knowledge=generated,card_bytes=total,
        scope='Existing cards keep their retrieval questions and earlier finite-admission bodies. Compact current wording routes retained older context to the same checkpoints; no file or byte ceiling changes.'))
    assert generated['returncode'] == 0
    print('Canonical facts and finite-history teaching aligned; card bytes',total)


if __name__ == '__main__':
    main()

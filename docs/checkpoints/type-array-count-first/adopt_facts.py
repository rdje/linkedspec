"""Retain the preflight budget refusal and prepare smaller current fact wording."""
import traceback
import common as c
import context
import facts


def main():
    original = c.read(c.PREFIX+'facts.py')
    supplied = context.snapshot()
    c.write_new('facts-refusal-inputs.json.gz',supplied)
    writer = c.write_new
    def suppress_existing_snapshot(name,value):
        assert name == 'facts-inputs.json.gz'
    try:
        c.write_new = suppress_existing_snapshot
        try:
            facts.main()
        except AssertionError as error:
            total = int(str(error))
            refusal = traceback.format_exc()
        else:
            raise AssertionError('Original over-budget proposal unexpectedly passed')
    finally:
        c.write_new = writer
    assert c.unchanged(supplied['inputs'])
    c.write_new('facts-budget-refusal.json.gz',dict(producer=original,total=total,traceback=refusal,
        inputs_unchanged=True,scope='Execute the actual original proposal with only its already-existing snapshot write suppressed. Its aggregate preflight rejects before any source/card/book mutation. This is a rejected proposal, not a successful first publication.'))
    text = c.decode(original['base64']).decode()
    text = text.replace("'facts-inputs.json.gz'","'facts2-inputs.json.gz'",1)
    text = text.replace("'docs/knowledge/finite-engineering-notes-member-0131.md',\n        'docs/linkedspec-book/src/development/local-ci-and-regression.md']",
        "'docs/knowledge/finite-engineering-notes-member-0131.md']",1)
    begin = text.index("    text = c.decode(before[paths[2]]")
    end = text.index('    cards = ',begin)
    text = text[:begin]+text[end:]
    text = text.replace('ADR0137 finite history; canonical admission required','ADR0137; canonical admission required')
    text = text.replace('ADR0137 admits two measured history members and exact manifest/decision overhead. Actual old-cap refusals and source reconstruction survive.',
        'ADR0137: two members; exact overhead; old-cap RED and source reconstruction retained.')
    old = ('Count/first10 rolls one change and one note member from real a8bd8620a. Only\n'
        'measured member/manifest and sole decision/index overhead changes. Every older\n'
        'immutable byte stays exact; omitted root LF separators recover from Git. Actual\n'
        'old-cap refusal and corrected reviewers survive in type-array-count-first/.\n'
        'No future archive reserve.')
    new = ('At a8bd8620a, count/first10 rolls two history members with exact manifest and\n'
        'sole decision/index overhead. Prior bytes and root-LF reconstruction survive\n'
        'in type-array-count-first/. No future reserve.')
    assert text.count(old) == 1
    text = text.replace(old,new,1)
    text = text.replace('"Perl value and helper contracts"','"Perl value/helper contracts"',1)
    text = text.replace('Type checkpoints retain exact epochs;10 verifies count/first.',
        'Type checkpoints retain epochs;10 verifies count/first.',1)
    with (c.ROOT/c.PREFIX/'facts2.py').open('x') as output:
        output.write(text)
    print('Original budget preflight refusal retained:',total,'bytes; smaller card proposal prepared')


if __name__ == '__main__':
    main()

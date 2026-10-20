"""Qualify the old TAP-context claim without replacing its original observations."""
import json
import common as c


def main():
    restored = c.load('prior-focused-restoration.json')
    assert restored['restored'] and c.unchanged(restored['sources'])
    run = c.load('prior-focused-run.json.gz')
    assert run['run']['returncode'] == 0 and run['inputs_unchanged']
    context = c.load('prior-focused-inputs.json.gz')
    assert len(context['selected']) == 14 and len(context['inputs']) == 10000
    path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json'
    before = c.read(path)
    retired = c.load('prior-retirement.json.gz')
    assert c.decode(before['base64']) == c.decode(retired['claim_after'])
    record = json.loads(c.decode(before['base64']))
    limitation = (' Qualification by TYPE-REFERENCE-BOOK.1.2.5: the original retained14-suite TAP has549 '
        'declared prefix inputs, omitting consumed docs/checkpoint producers, fixtures and the integration '
        'book. Its original test-context completeness is not established; those counts are retained-log '
        'metrics. A distinct fresh accepted203cde315 replay passes14/1924 with10000 captured regular '
        'tracked inputs and explicit current overrides, plus actual omitted-producer RED/restoration. '
        'This new replay does not invent the original process environment or alter its observations.')
    for claim in record['claims']:
        assert claim['durability']['mode'] == 'historical' and claim['durability']['revision'] == c.BASE
        claim['scope'] += limitation
    raw = (json.dumps(record, separators=(',', ':')) + '\n').encode()
    readme = 'docs/checkpoints/type-scoped-with/README.md'
    old_readme = c.read(readme)
    note = ('Input-scope correction: the original focused manifest omitted consumed\n'
            'checkpoint producers/fixtures and integration-book input. Retained14/1924\n'
            'TAP remains an original log metric. Numeric5 preserves that record and\n'
            'adds a distinct accepted-source replay with10000 captured regular tracked\n'
            'inputs and actual producer fault/restoration; see its README.\n\n').encode()
    new_readme = note + c.decode(old_readme['base64'])
    c.write_new('prior-qualification.json.gz', dict(claim_before=before, claim_after=c.encode(raw),
        readme_before=old_readme, readme_after=c.encode(new_readme),
        producer=c.read(c.PREFIX + 'qualify_prior.py'),
        scope='All original claims, metrics, three legs and bindings remain; only explicit scope qualification '
              'is appended to the preserved historical record. Fresh proof has its own actual context.'))
    (c.ROOT / path).write_bytes(raw)
    (c.ROOT / readme).write_bytes(new_readme)
    print('Prior4 original TAP scope qualified; fresh complete-context replay retained separately')


if __name__ == '__main__':
    main()

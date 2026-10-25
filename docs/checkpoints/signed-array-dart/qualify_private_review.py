"""Retain the observer-namespace assertion before correcting its comparison."""
import json
import common as c

fixture=c.load('private2-cases.json')
authority=json.loads(c.file('capability_conformance/signed_array_selector_contract.json').read_bytes())
actual=fixture['cases'][0];original=authority['read_cases'][0]
assert actual['id']=='read/'+original['id']
assert all(actual[key]==value for key,value in original.items() if key!='id')
c.save('review-private-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_private_review.py'),
    failed_reader=c.read(c.PREFIX+'review.py'),
    channels=c.read('.linkedspec-data/verification/signed-dart17-review3.log'),
    original=original,projected=actual,
    qualification='The private observer namespaces read/write IDs while retaining every original '
        'authority field. The first readonly comparison incorrectly demands original ID equality '
        'after selecting the namespaced row. Require the exact prefix separately, then compare '
        'all remaining original fields. No runtime, target, source, result or capture changes.'))

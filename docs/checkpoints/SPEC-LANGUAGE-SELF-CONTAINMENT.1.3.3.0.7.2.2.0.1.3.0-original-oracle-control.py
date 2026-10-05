"""Retain actual rejection of the original omitted quoted Flow expectation."""
from pathlib import Path
import importlib.util
import json

PREFIX=__file__.removesuffix('original-oracle-control.py')


def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
    return result


review=module('flow_current_review',PREFIX+'review.py')
original=module('flow_original_author',PREFIX+'oracle.py')
case=next(c for c in original.author() if c['id']=='arguments')
report=json.loads(Path(PREFIX+'observations.json').read_bytes())
row=next(r for r in report['runs'] if r['kind']=='arguments')
data=json.loads(review.decode(row['stdout']))
try:review.check_case(data,case)
except AssertionError as error:
    assert str(error)=='literal original event arguments and composite order'
    result={'observed':'RED','reason':str(error),'case':'arguments','seed':row['seed'],
            'instrument_sha256':review.sha(Path(__file__).read_bytes()),
            'scope':'Actual original capture rejects a false omitted quoted-case expectation. Runtime source/contracts and original inputs remain unchanged; corrected review oracle authors the extra original syntactic interval.'}
    Path(PREFIX+'original-oracle-control.json').write_text(json.dumps(result,indent=2)+'\n')
    print('Original omitted-quoted-case hypothesis RED: '+str(error))
else:raise AssertionError('false original expectation accepted')

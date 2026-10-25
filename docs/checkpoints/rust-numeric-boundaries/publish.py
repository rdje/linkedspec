"""Read-only publication review. Capture writers are deliberately separate."""
import json
import sys
import common as c
import custody
import review_numeric
import review_processes
import review_faults
import review_book
import review_history
import review_compatibility
import review_controls


def check(provisional=False):
    manifest=c.load('publication.json')
    assert manifest['owner']==c.OWNER and manifest['base']==c.BASE
    assert manifest['provisional'] is provisional, 'publication phase'
    result=dict(custody=custody.check(manifest),numeric=review_numeric.check(),
        processes=review_processes.check(),faults=review_faults.check(),book=review_book.check(),
        historical=review_history.check(),compatibility=review_compatibility.check())
    if not provisional:
        result['input_controls']=review_controls.check()
    return result


if __name__=='__main__':
    assert sys.argv[1:] in ([], ['--provisional'])
    print(json.dumps(check(provisional=bool(sys.argv[1:])),sort_keys=True))
